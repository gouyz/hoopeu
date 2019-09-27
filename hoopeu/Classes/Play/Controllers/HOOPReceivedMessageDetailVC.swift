//
//  HOOPReceivedMessageDetailVC.swift
//  hoopeu
//  收到留言 详情
//  Created by gouyz on 2019/3/27.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import CocoaMQTT
import MBProgressHUD
import SwiftyJSON

class HOOPReceivedMessageDetailVC: GYZBaseVC {

    /// 留言id
    var messageId: String = ""
    
    var dataModel: HOOPLeaveMessageModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "收到留言"
        self.view.backgroundColor = kWhiteColor
        
        let rightBtn = UIButton(type: .custom)
        rightBtn.setTitle("删除", for: .normal)
        rightBtn.titleLabel?.font = k15Font
        rightBtn.setTitleColor(kRedFontColor, for: .normal)
        rightBtn.frame = CGRect.init(x: 0, y: 0, width: kTitleHeight, height: kTitleHeight)
        rightBtn.addTarget(self, action: #selector(onClickRightBtn), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBtn)
        
        setUpUI()
        requestMessageInfo()
        mqttSetting()
    }
    
    func setUpUI(){
        view.addSubview(desLab)
        view.addSubview(contentLab)
        view.addSubview(lineView)
        view.addSubview(dateLab)
        
        desLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.top.equalTo(kTitleAndStateHeight + 20)
            make.size.equalTo(CGSize.init(width: kTitleHeight, height: 20))
        }
        contentLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.top.equalTo(desLab.snp.bottom).offset(kMargin)
            make.height.equalTo(0)
        }
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.height.equalTo(klineWidth)
            make.top.equalTo(contentLab.snp.bottom).offset(kMargin)
        }
        dateLab.snp.makeConstraints { (make) in
            make.left.right.equalTo(lineView)
            make.top.equalTo(lineView.snp.bottom)
            make.height.equalTo(kTitleHeight)
        }
    }
    
    /// 说明
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlueFontColor
        lab.text = "留言"
        lab.textAlignment = .center
        lab.borderColor = kBlueFontColor
        lab.borderWidth = klineWidth
        lab.cornerRadius = kCornerRadius
        
        return lab
    }()
    
    /// 留言
    lazy var contentLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        lab.numberOfLines = 0
        lab.text = "如：单次 09：25"
        
        return lab
    }()
    /// 分割线
    var lineView : UIView = {
        let line = UIView()
        line.backgroundColor = kGrayLineColor
        return line
    }()
    ///
    lazy var dateLab : UILabel = {
        let lab = UILabel()
        lab.font = k13Font
        lab.textColor = kGaryFontColor
        lab.textAlignment = .right
        lab.text = "2019-03-27 09:30:00"
        
        return lab
    }()
    
    /// 留言信息
    func requestMessageInfo(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("leavemsg/listInfo", parameters: ["id":messageId,"deviceId":userDefaults.string(forKey: "devId") ?? ""],method : .get,  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let data = response["data"].dictionaryObject else { return }
                weakSelf?.dataModel = HOOPLeaveMessageModel.init(dict: data)
                weakSelf?.setMessageInfo()
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    func setMessageInfo(){
        if dataModel != nil {
            contentLab.text = dataModel?.msg
            dateLab.text = (dataModel?.yml)! + " " + (dataModel?.day_time)!
        }
        
    }
    
    /// 删除
    @objc func onClickRightBtn(){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "确定要删除此留言吗?", cancleTitle: "取消", viewController: self, buttonTitles: "确定") { (index) in
            
            if index != cancelIndex{
                weakSelf?.sendSaveDeleteMqttCmd()
            }
        }
    }
    
    /// mqtt发布主题 删除留言
    func sendSaveDeleteMqttCmd(){
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","leavemsg_id":messageId,"phone":userDefaults.string(forKey: "phone") ?? "","msg_type":"app_leavemsg_del","app_interface_tag":""]
        
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
            if type == "app_leavemsg_del_re" && phone == userDefaults.string(forKey: "phone"){
                MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                if result["code"].intValue == kQuestSuccessTag{
                    
                    clickedBackBtn()
                }
            }
        }
    }
}
