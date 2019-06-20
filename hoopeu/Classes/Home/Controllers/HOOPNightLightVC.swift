//
//  HOOPNightLightVC.swift
//  hoopeu
//  小夜灯设置
//  Created by gouyz on 2019/2/26.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON
import AudioToolbox

class HOOPNightLightVC: GYZBaseVC {
    /// 光感控制
    var light_tri: Bool = true
    /// 体感控制
    var body_tri: Bool = true
    var off_delay: String = "1"
    var timeArr: [String] = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "夜灯设置"
        
        for i in 1...5 {
            timeArr.append("\(i)")
        }
        
        setupUI()
        iconTimeView.addOnClickListener(target: self, action: #selector(onSelectTime))
        mqttSetting()
    }
    
    /// 创建UI
    func setupUI(){
        view.addSubview(desLab)
        view.addSubview(bgView)
//        bgView.addSubview(controlLab1)
//        bgView.addSubview(lightSwitchView)
//        bgView.addSubview(lineView)
        bgView.addSubview(controlLab2)
        bgView.addSubview(personSwitchView)
        view.addSubview(desLab1)
        view.addSubview(bgView1)
        bgView1.addSubview(timeLab)
        bgView1.addSubview(iconTimeView)
        view.addSubview(saveBtn)
        
        desLab.snp.makeConstraints { (make) in
            make.top.equalTo(kTitleAndStateHeight)
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.height.equalTo(kTitleHeight)
        }
        bgView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(desLab.snp.bottom)
            make.height.equalTo(60)
        }
        controlLab2.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.top.equalTo(bgView)
            make.right.equalTo(personSwitchView.snp.left).offset(-kMargin)
            make.height.equalTo(60)
        }
        personSwitchView.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.centerY.equalTo(controlLab2)
        }
//        lineView.snp.makeConstraints { (make) in
//            make.left.right.equalTo(bgView)
//            make.top.equalTo(controlLab1.snp.bottom)
//            make.height.equalTo(klineWidth)
//        }
//        controlLab2.snp.makeConstraints { (make) in
//            make.left.equalTo(kMargin)
//            make.top.equalTo(lineView.snp.bottom)
//            make.bottom.equalTo(bgView)
//            make.right.equalTo(personSwitchView.snp.left).offset(-kMargin)
//        }
//        personSwitchView.snp.makeConstraints { (make) in
//            make.right.equalTo(-kMargin)
//            make.centerY.equalTo(controlLab2)
//        }
        desLab1.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(desLab)
            make.top.equalTo(bgView.snp.bottom)
        }
        bgView1.snp.makeConstraints { (make) in
            make.left.right.equalTo(bgView)
            make.top.equalTo(desLab1.snp.bottom)
            make.height.equalTo(60)
        }
        timeLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(iconTimeView.snp.left).offset(-kMargin)
            make.top.bottom.equalTo(bgView1)
        }
        iconTimeView.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.centerY.equalTo(timeLab)
            make.size.equalTo(CGSize.init(width: 24, height: 24))
        }
        saveBtn.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(kBottomTabbarHeight)
        }
    }
    
    ///
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.textColor = kBlackFontColor
        lab.font = k15Font
        lab.text = "控制选项"
        
        return lab
    }()
    ///
    lazy var bgView : UIView = {
        let line = UIView()
        line.backgroundColor = kWhiteColor
        return line
    }()
//    lazy var controlLab1 : UILabel = {
//        let lab = UILabel()
//        lab.textColor = kBlackFontColor
//        lab.font = k15Font
//        lab.textAlignment = .center
//        lab.text = "光感"
//
//        return lab
//    }()
//    /// 光感开关
//    lazy var lightSwitchView: UISwitch = {
//        let sw = UISwitch()
//        sw.tag = 101
//        sw.isOn = light_tri
//        sw.addTarget(self, action: #selector(onSwitchViewChange(sender:)), for: .valueChanged)
//        return sw
//    }()
//    /// 分割线
//    lazy var lineView : UIView = {
//        let line = UIView()
//        line.backgroundColor = kGrayLineColor
//        return line
//    }()
    lazy var controlLab2 : UILabel = {
        let lab = UILabel()
        lab.textColor = kBlackFontColor
        lab.font = k15Font
        lab.textAlignment = .center
        lab.text = "人体"
        
        return lab
    }()
    /// 人体 开关
    lazy var personSwitchView: UISwitch = {
        let sw = UISwitch()
        sw.tag = 102
        sw.isOn = body_tri
        sw.addTarget(self, action: #selector(onSwitchViewChange(sender:)), for: .valueChanged)
        return sw
    }()
    ///
    lazy var desLab1 : UILabel = {
        let lab = UILabel()
        lab.textColor = kBlackFontColor
        lab.font = k15Font
        lab.text = "关灯延时时间设置1-5（分钟）"
        
        return lab
    }()
    ///
    lazy var bgView1 : UIView = {
        let line = UIView()
        line.backgroundColor = kWhiteColor
        line.isUserInteractionEnabled = true
        return line
    }()
    ///
    lazy var timeLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        lab.textAlignment = .center
        lab.text = "1分钟"
        
        return lab
    }()
    /// icon
    lazy var iconTimeView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_scene_edit"))
    /// 保存
    lazy var saveBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("保存", for: .normal)
        btn.titleLabel?.font = k15Font
        
        btn.addTarget(self, action: #selector(clickedSaveBtn), for: .touchUpInside)
        
        return btn
    }()
    /// 保存
    @objc func clickedSaveBtn(){
        sendSaveMqttCmd()
    }
    
    /// 开关状态
    @objc func onSwitchViewChange(sender: UISwitch){
        //默认震动效果
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        let row = sender.tag
        if row == 101 {
            light_tri = sender.isOn
        }else{
            body_tri = sender.isOn
        }
    }
    /// 选择时间
    @objc func onSelectTime(){
        UsefulPickerView.showSingleColPicker("选择延时时间(分钟)", data: timeArr, defaultSelectedIndex: nil) {[weak self] (index, value) in
            self?.timeLab.text = value + "分钟"
            self?.off_delay = value
        }
    }
    
    /// mqtt发布主题
    func sendSaveMqttCmd(){
        let paramDic:[String:Any] = ["device_id":userDefaults.string(forKey: "devId") ?? "","user_id":userDefaults.string(forKey: "phone") ?? "","msg":["tri_type":["light_tri":light_tri,"body_tri":body_tri],"off_delay":off_delay],"msg_type":"ni_light_setting","app_interface_tag":""]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// 夜灯设置信息查询
    func sendMqttCmd(){
        //        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["device_id":userDefaults.string(forKey: "devId") ?? "","user_id":userDefaults.string(forKey: "phone") ?? "","msg_type":"ni_light_setting_query","app_interface_tag":""]

        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    
    /// 重载CocoaMQTTDelegate
    override func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        super.mqtt(mqtt, didStateChangeTo: state)
        if state == .connected {
            sendMqttCmd()
        }
    }
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
            let phone = result["user_id"].stringValue
            let type = result["msg_type"].stringValue
            if let tag = result["app_interface_tag"].string{
                if tag.hasPrefix("system_"){
                    return
                }
            }
            if type == "ni_light_setting_re" && phone == userDefaults.string(forKey: "phone"){
                //                hud?.hide(animated: true)
                if result["ret"].intValue == 1{
                    MBProgressHUD.showAutoDismissHUD(message: "设置成功")
                    clickedBackBtn()
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: "设置失败")
                }
            }else if type == "ni_light_setting_query_re" && phone == userDefaults.string(forKey: "phone"){
                //                hud?.hide(animated: true)
                if result["ret"].intValue == 1{
                    light_tri = result["tri_type"]["light_tri"].boolValue
                    body_tri = result["tri_type"]["body_tri"].boolValue
                    off_delay = result["off_delay"].stringValue
                    
//                    lightSwitchView.isOn = light_tri
                    personSwitchView.isOn = body_tri
                    timeLab.text = off_delay + "分钟"
                }
            }
            
        }
    }
}
