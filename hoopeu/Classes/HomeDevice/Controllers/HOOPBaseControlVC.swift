//
//  HOOPBaseControlVC.swift
//  hoopeu
//  遥控器基类
//  Created by gouyz on 2019/7/1.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

class HOOPBaseControlVC: GYZBaseVC {
    
    /// 自定义编辑
    var isEdit: Bool = false
    /// 所选品牌的方案
    var deviceModelList: [DeviceM] = [DeviceM]()
    /// 所有品牌
    var brandList: [[String:String]] = [[String:String]]()
    var dataModel: HOOPControlModel?
    /// 遥控器id
    var controlId: String = ""
    var ir_type: String = "ir_air"
    /// 遥控器code
    var controlCode: Data?
    var waitAlert: GYZCustomWaitAlert?

    override func viewDidLoad() {
        super.viewDidLoad()

        mqttSetting()
        setRightBtn()
    }
    
    ///提示
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.font = k13Font
        lab.textColor = kRedFontColor
        lab.text = "您可以点击任意键开始自定义学习啦！"
        lab.textAlignment = .center
        
        return lab
    }()
    
    func setRightBtn(){
        if isEdit {
            let rightBtn = UIButton(type: .custom)
            rightBtn.setTitle("完成", for: .normal)
            rightBtn.titleLabel?.font = k15Font
            rightBtn.setTitleColor(kBlackFontColor, for: .normal)
            rightBtn.frame = CGRect.init(x: 0, y: 0, width: kTitleHeight, height: kTitleHeight)
            rightBtn.addTarget(self, action: #selector(onClickFinishedBtn), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBtn)
            desLab.isHidden = false
        }else{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_device_setting")?.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(clickedSettingBtn))
            desLab.isHidden = true
        }
    }
    
    /// 完成
    @objc func onClickFinishedBtn(){
        isEdit = false
        setRightBtn()
    }
    /// 设置
    @objc func clickedSettingBtn(){
        GYZAlertViewTools.alertViewTools.showSheet(title: nil, message: nil, cancleTitle: "取消", titleArray: ["自定义","删除"], viewController: self) { [weak self](index) in
            
            if index == 0{//自定义
                self?.isEdit = true
                self?.setRightBtn()
            }else if index == 1{//删除
                self?.showDeleteAlert()
            }
        }
    }
    
    /// 删除
    func showDeleteAlert(){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "确定要删除此遥控器吗?", cancleTitle: "取消", viewController: self, buttonTitles: "确定") { (index) in
            
            if index != cancelIndex{
                weakSelf?.sendDelMqttCmd()
            }
        }
    }
    
    /// 遥控器控制
    func sendCmdMqtt(studyCode: String){
        
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","msg_type":"app_ir_ctrl","phone":userDefaults.string(forKey: "phone") ?? "","ir_id":controlId,"ir_type":ir_type,"study_code":studyCode,"app_interface_tag":""]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// 遥控器自定义学习
    func sendStudyMqttCmd(funcId:Int){
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","msg_type":"app_ir_extra_study","phone":userDefaults.string(forKey: "phone") ?? "","ir_id":controlId,"ir_type":ir_type,"func_id":funcId,"app_interface_tag":String.init(format: "%d", funcId)]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// 遥控器删除
    func sendDelMqttCmd(){
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","msg_type":"app_ir_del","phone":userDefaults.string(forKey: "phone") ?? "","ir_id":controlId,"app_interface_tag":""]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    
    /// 遥控器自定义按键控制、学习测试控制
    func sendCmdCustomMqtt(isTest: Bool,funcId:Int,code: String){
        
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","msg_type":"app_ir_extra_ctrl","phone":userDefaults.string(forKey: "phone") ?? "","ir_id":controlId,"ir_type":ir_type,"ctrl_test":isTest,"func_id":funcId,"code":code,"app_interface_tag":""]
        
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
            self.hud?.hide(animated: true)
            
            if type == "app_ir_extra_ctrl_re" && phone == userDefaults.string(forKey: "phone"){
                MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                //                if result["code"].intValue == kQuestSuccessTag{
                //
                //                }
            }else if type == "app_ir_del_re" && phone == userDefaults.string(forKey: "phone"){
                MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                if result["code"].intValue == kQuestSuccessTag{
                    self.clickedBackBtn()
                }
            }
            
        }
    }
}
