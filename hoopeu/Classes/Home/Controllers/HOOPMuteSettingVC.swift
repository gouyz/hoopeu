//
//  HOOPMuteSettingVC.swift
//  hoopeu
//  静音设置
//  Created by iMac on 2020/6/29.
//  Copyright © 2020 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON
import AudioToolbox

class HOOPMuteSettingVC: GYZBaseVC {
    
    /// 用户想要设置的定时静音起始时间,默认为”22:00
    var start_time: String = "22:00"
    /// 用户想要设置的定时静音结束时间.默认为”07:00”
    var end_time: String = "07:00"
    /// 是否开启定时静音，默认为 true
    var mute_timer_state: Bool = true
    /// 是否需要获取信息
    var isRequest: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "静音设置"
        
        setupUI()
        
        iconWarnTimeView.addOnClickListener(target: self, action: #selector(onClickedStartTime))
        iconTimeView.addOnClickListener(target: self, action: #selector(onSelectEndTime))
        mqttSetting()
    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        mqttSetting()
//    }
    
    /// 创建UI
    func setupUI(){
        view.addSubview(desLab)
        view.addSubview(personSwitchView)
        view.addSubview(bgView)
        bgView.addSubview(startTimeDesLab)
        bgView.addSubview(startTimeLab)
        bgView.addSubview(iconWarnTimeView)
        view.addSubview(bgView1)
        bgView1.addSubview(endTimeDesLab)
        bgView1.addSubview(endTimeLab)
        bgView1.addSubview(iconTimeView)
        view.addSubview(saveBtn)
        
        desLab.snp.makeConstraints { (make) in
            make.top.equalTo(kTitleAndStateHeight)
            make.left.equalTo(kMargin)
            make.width.equalTo(160)
            make.height.equalTo(kTitleHeight)
        }
        personSwitchView.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.centerY.equalTo(desLab)
        }
        bgView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(desLab.snp.bottom)
            make.height.equalTo(60)
        }
        startTimeDesLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.top.bottom.equalTo(bgView)
            make.width.equalTo(80)
        }
        startTimeLab.snp.makeConstraints { (make) in
            make.left.equalTo(startTimeDesLab.snp.right)
            make.top.bottom.equalTo(bgView)
            make.right.equalTo(iconWarnTimeView.snp.left).offset(-kMargin)
        }
        iconWarnTimeView.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.centerY.equalTo(bgView)
            make.size.equalTo(CGSize.init(width: 24, height: 26))
        }
        bgView1.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(bgView)
            make.top.equalTo(bgView.snp.bottom).offset(kTitleHeight)
        }
        endTimeDesLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.width.equalTo(80)
            make.top.bottom.equalTo(bgView1)
        }
        endTimeLab.snp.makeConstraints { (make) in
            make.left.equalTo(endTimeDesLab.snp.right)
            make.right.equalTo(iconTimeView.snp.left).offset(-kMargin)
            make.top.bottom.equalTo(bgView1)
        }
        iconTimeView.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.centerY.equalTo(bgView1)
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
        lab.text = "定时静音"
        
        return lab
    }()
    /// 定时静音 开关
    lazy var personSwitchView: UISwitch = {
        let sw = UISwitch()
        sw.isOn = mute_timer_state
        sw.addTarget(self, action: #selector(onSwitchViewChange), for: .valueChanged)
        return sw
    }()
    ///
    lazy var bgView : UIView = {
        let line = UIView()
        line.backgroundColor = kWhiteColor
        return line
    }()
    lazy var startTimeDesLab : UILabel = {
        let lab = UILabel()
        lab.textColor = kBlackFontColor
        lab.font = k15Font
        lab.text = "起始时间"
        
        return lab
    }()
    lazy var startTimeLab : UILabel = {
        let lab = UILabel()
        lab.textColor = kBlackFontColor
        lab.font = k15Font
        lab.textAlignment = .center
        lab.text = "22:00"
        
        return lab
    }()
    /// icon
    lazy var iconWarnTimeView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_naozhong"))

    ///
    lazy var bgView1 : UIView = {
        let line = UIView()
        line.backgroundColor = kWhiteColor
        line.isUserInteractionEnabled = true
        return line
    }()
    ///
    lazy var endTimeDesLab : UILabel = {
        let lab = UILabel()
        lab.textColor = kBlackFontColor
        lab.font = k15Font
        lab.text = "终止时间"
        
        return lab
    }()
    ///
    lazy var endTimeLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        lab.textAlignment = .center
        lab.text = "07:00"
        
        return lab
    }()
    /// icon
    lazy var iconTimeView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_naozhong"))
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
    /// 开关状态
    @objc func onSwitchViewChange(){
        //默认震动效果
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        
        mute_timer_state = personSwitchView.isOn
    }
    /// 保存
    @objc func clickedSaveBtn(){
        sendSaveMqttCmd()
    }
    
    /// 选择开始时间
    @objc func onClickedStartTime(){
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        var setting = DatePickerSetting.init()
        setting.dateMode = .time
        UsefulPickerView.showDatePicker("选择起始时间", datePickerSetting: setting) { [unowned self](date) in
            self.start_time = date.dateToStringWithFormat(format: "HH:mm")
            self.startTimeLab.text = self.start_time
        }
    }
    
    /// 选择结束时间
    @objc func onSelectEndTime(){
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        var setting = DatePickerSetting.init()
        setting.dateMode = .time
        UsefulPickerView.showDatePicker("选择终止时间", datePickerSetting: setting) { [unowned self](date) in
            self.end_time = date.dateToStringWithFormat(format: "HH:mm")
            self.endTimeLab.text = self.end_time
        }
    }
    
    /// mqtt发布主题
    func sendSaveMqttCmd(){
        if mqtt?.connState == CocoaMQTTConnState.disconnected{
            mqtt?.connect()
            return
        }
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["device_id":userDefaults.string(forKey: "devId") ?? "","user_id":userDefaults.string(forKey: "phone") ?? "","msg":["mute_timer_state":mute_timer_state,"start_time":start_time,"end_time":end_time],"msg_type":"mute_setting","app_interface_tag":""]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// 静音设置信息查询
    func sendMqttCmd(){
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["device_id":userDefaults.string(forKey: "devId") ?? "","user_id":userDefaults.string(forKey: "phone") ?? "","msg_type":"mute_setting_query","app_interface_tag":""]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    
    /// 重载CocoaMQTTDelegate
    override func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        super.mqtt(mqtt, didStateChangeTo: state)
        if state == .connected {
            if isRequest {
                sendMqttCmd()
            }else{
                sendSaveMqttCmd()
            }
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
            if type == "mute_setting_re" && phone == userDefaults.string(forKey: "phone"){
                hud?.hide(animated: true)
                if result["ret"].intValue == 1{
                    clickedBackBtn()
                    MBProgressHUD.showAutoDismissHUD(message: "设置成功")
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: "设置失败")
                }
            }else if type == "mute_setting_query_re" && phone == userDefaults.string(forKey: "phone"){
                hud?.hide(animated: true)
                if result["ret"].intValue == 1{
                    isRequest = false
                    mute_timer_state = result["mute_timer_state"].boolValue
                    personSwitchView.isOn = mute_timer_state
                    start_time = result["start_time"].stringValue
                    end_time = result["end_time"].stringValue
                    
                    startTimeLab.text = start_time
                    endTimeLab.text = end_time
                }
            }
            
        }
    }
}
