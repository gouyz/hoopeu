//
//  HOOPChuanGanDeviceVC.swift
//  hoopeu
//  添加设备 传感设备
//  Created by gouyz on 2019/3/5.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

class HOOPChuanGanDeviceVC: GYZBaseVC {
    
    /// 临时id
    var deviceId: String = ""
    var waitAlert: GYZCustomWaitAlert?
    var ctrlDevType: Int = 1
    /// 记录学习时返回的code码
    var codesDic: [[String: Any]] = [[String: Any]]()
    let titleArray = ["求助设备", "门磁设备", "防盗设备", "烟雾报警设备", "煤气报警设备","通用传感器"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "传感设备"
        
        setUpUI()
        requestDeviceId()
        mqttSetting()
    }
    
    func setUpUI(){
        view.addSubview(bgView)
        bgView.addSubview(iconView)
        
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(kTitleAndStateHeight + 20)
            make.bottom.equalTo(-20)
        }
        iconView.snp.makeConstraints { (make) in
            make.center.equalTo(bgView)
            make.size.equalTo(CGSize.init(width: 100, height: 266))
        }
    }
    
    lazy var bgView: UIView = {
        let bgview = UIView()
        bgview.backgroundColor = kWhiteColor
        bgview.cornerRadius = 10
        bgview.isUserInteractionEnabled = true
        
        return bgview
    }()
    lazy var iconView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_chuangan_device"))
    
    /// 获取临时id
    func requestDeviceId(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("homeCtrl", parameters: nil,  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                weakSelf?.deviceId = response["data"].stringValue
                weakSelf?.showStudyAlert()
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    /// 开始学习
    func showStudyAlert(){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: titleArray[ctrlDevType - 1] + "安装好电池\n点击“开始学习”", cancleTitle: "取消", viewController: self, buttonTitles: "开始学习") { (index) in
            
            if index != cancelIndex{
                weakSelf?.sendStudyMqttCmd()
                weakSelf?.showWaitAlert()
            }else{
                weakSelf?.clickedBackBtn()
            }
        }
    }
    /// 正在等待
    func showWaitAlert(){
        var content: String = "打开" + titleArray[ctrlDevType - 1] + "开关"
        if ctrlDevType == 2{
            content = "请将门磁设备分开或靠近，至红色指示灯亮起"
        }
        waitAlert = GYZCustomWaitAlert.init()
        waitAlert?.titleLab.text = content
        waitAlert?.action = {[weak self]() in
            self?.showStudyFailedAlert()
        }
        waitAlert?.show()
    }
    
    /// 学习失败
    func showStudyFailedAlert(){
        codesDic.removeAll()
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "学习失败，请重新尝试", cancleTitle: "取消", viewController: self, buttonTitles: "重新配置") { (index) in
            
            if index != cancelIndex{
                weakSelf?.showStudyAlert()
            }else{
                weakSelf?.clickedBackBtn()
            }
        }
    }
    /// 学习成功
    func showStudySuccessAlert(){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "新功能学习成功", cancleTitle: nil, viewController: self, buttonTitles: "完成") { (index) in
            
            if index != cancelIndex{
                weakSelf?.goSaveVC()
            }
        }
    }
    
    func goSaveVC(){
        let vc = HOOPSaveChuanGanDeviceVC()
        vc.chuanGanDeviceId = deviceId
        vc.codesDic = self.codesDic
        vc.ctrlDevType = self.ctrlDevType
        navigationController?.pushViewController(vc, animated: true)
    }
    /// mqtt发布主题 学习
    func sendStudyMqttCmd(){
        
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","ctrl_dev_id":deviceId,"phone":userDefaults.string(forKey: "phone") ?? "","msg_type":"app_sensor_study","ctrl_dev_type":ctrlDevType,"func_num":1,"func_id":0,"app_interface_tag":""]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    
    /// 重载CocoaMQTTDelegate
    override func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        super.mqtt(mqtt, didConnectAck: ack)
        if ack == .accept {
            mqtt.subscribe("api_receive", qos: CocoaMQTTQOS.qos1)
        }
    }
    override func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        super.mqtt(mqtt, didReceiveMessage: message, id: id)
        
        if let data = message.string {
            let result = JSON.init(parseJSON: data)
            let phone = result["phone"].stringValue
            let type = result["msg_type"].stringValue
            if let tag = result["app_interface_tag"].string{
                if tag.hasPrefix("system_"){
                    return
                }
            }
            if type == "app_sensor_study_re" && phone == userDefaults.string(forKey: "phone"){
                //                hud?.hide(animated: true)
                MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                waitAlert?.hide()
                
                if result["code"].intValue == kQuestSuccessTag{
                    
                    //1：成功；0：失败 2：学习开始（为区分学习返回时的第二次携码返回）
                    if result["data"]["ret"].intValue == 1{
                        
                        let funcId = result["data"]["func_id"].intValue
                        let dic: [String: Any] = ["func_id":funcId,"code":result["data"]["code"].stringValue]
                        codesDic.append(dic)
                        showStudySuccessAlert()
                    }else if result["data"]["ret"].intValue == 0{// 学习失败
                        showStudyFailedAlert()
                    }
                    
                }else{// 学习失败
                    showStudyFailedAlert()
                }
            }
            
        }
    }
}

