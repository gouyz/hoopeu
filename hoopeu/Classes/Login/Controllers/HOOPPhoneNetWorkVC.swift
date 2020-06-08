//
//  HOOPPhoneNetWorkVC.swift
//  hoopeu
//  手机配网
//  Created by gouyz on 2020/4/19.
//  Copyright © 2020 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

class HOOPPhoneNetWorkVC: GYZBaseVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "手机配网"
        self.view.backgroundColor = kWhiteColor
        
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mqttSetting()
    }
    /// 创建UI
    func setupUI(){
        view.addSubview(linkBtn)
        view.addSubview(noLinkBtn)
        
        noLinkBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-30)
            make.left.equalTo(30)
            make.bottom.equalTo(self.view.snp.centerY).offset(-kTitleHeight)
            make.height.equalTo(kUIButtonHeight)
        }
        linkBtn.snp.makeConstraints { (make) in
            make.height.left.right.equalTo(noLinkBtn)
            make.top.equalTo(self.view.snp.centerY).offset(kTitleHeight)
        }
    }
    
    /// 设备已联网
    lazy var linkBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBlueFontColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("设备已联网", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = 8
        
        btn.addTarget(self, action: #selector(clickedLinkBtn), for: .touchUpInside)
        
        return btn
    }()
    /// 设备未联网
    lazy var noLinkBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBlueFontColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("设备未联网", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = 8
        
        btn.addTarget(self, action: #selector(clickedNoLinkBtn), for: .touchUpInside)
        
        return btn
    }()
    
    /// 设备已联网
    @objc func clickedLinkBtn(){
        sendMqttCmdBle()
        goResetNetWorkVC()
    }
    func goResetNetWorkVC(){
        let vc = HOOPBlueToothContentVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 设备未联网
    @objc func clickedNoLinkBtn(){
        let vc = HOOPLinkPowerVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// mqtt发布主题 打开设备蓝牙
    func sendMqttCmdBle(){
//        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["device_id":userDefaults.string(forKey: "devId") ?? "","user_id":userDefaults.string(forKey: "phone") ?? "","msg_type":"bt_open","app_interface_tag":""]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    
    /// 重载CocoaMQTTDelegate
    override func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        super.mqtt(mqtt, didConnectAck: ack)
        if ack == .accept {
            mqtt.subscribe("hoopeu_app", qos: CocoaMQTTQOS.qos1)
        }
    }
    override func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        super.mqtt(mqtt, didReceiveMessage: message, id: id)
        
        if let data = message.string {
            let result = JSON.init(parseJSON: data)
            let type = result["msg_type"].stringValue
            if let tag = result["app_interface_tag"].string{
                if tag.hasPrefix("system_"){
                    return
                }
            }
            
            if type == "bt_open_re" && result["user_id"].stringValue == userDefaults.string(forKey: "phone"){
//                hud?.hide(animated: true)
                
//                if result["ret"].intValue == 1{
//                    goResetNetWorkVC()
//                }else{
//                    MBProgressHUD.showAutoDismissHUD(message: "请先打开设备蓝牙，然后进行重新配网")
//                }
                
            }
            
        }
    }
}
