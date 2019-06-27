//
//  HOOPWarnSettingVC.swift
//  hoopeu
//  报警设置
//  Created by gouyz on 2019/2/27.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON
import AudioToolbox

class HOOPWarnSettingVC: GYZBaseVC {
    
    var timeArr: [String] = [String]()
    /// 每周循环时间 ,ONCE:仅此一次,EVERYDAY :每天,WEEKDAY:工作日,WEEKEND:每周末,USER_DEFINE:自定义
    var week_time: String = ""
    /// 用户自定义时间选择，可多选。EVERY_MONDAY:每周一,EVERY_TUESDAY:每周二,EVERY_WEDNESDAY:每周三,EVERY_THURSDAY:每周四,EVERY_FRIDAY:每周五,EVERY_SATURDAY:每周六,EVERY_SUNDAY:每周日
    var user_define_times: [String] = [String]()
    /// 用户想要播报的语句的时间
    var day_time: String = ""
    /// 延时布防时间(秒)
    var guard_delay: String = "8"
    /// 是否需要获取信息
    var isRequest: Bool = true
    /// 是否设置定时布防
    var isSetDayTime: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "报警设置"
        
        for i in 1...30 {
            timeArr.append("\(i)")
        }
        setupUI()
        
        iconWarnTimeView.addOnClickListener(target: self, action: #selector(onClickedEditTime))
        iconWarnTimeView.isUserInteractionEnabled = isSetDayTime
        iconTimeView.addOnClickListener(target: self, action: #selector(onSelectTime))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mqttSetting()
    }
    
    /// 创建UI
    func setupUI(){
        view.addSubview(desLab)
        view.addSubview(personSwitchView)
        view.addSubview(bgView)
        bgView.addSubview(warnTimeLab)
        bgView.addSubview(iconWarnTimeView)
        view.addSubview(desLab1)
        view.addSubview(bgView1)
        bgView1.addSubview(timeLab)
        bgView1.addSubview(iconTimeView)
        view.addSubview(saveBtn)
        
        desLab.snp.makeConstraints { (make) in
            make.top.equalTo(kTitleAndStateHeight)
            make.left.equalTo(kMargin)
            make.width.equalTo(160)
            make.height.equalTo(kTitleHeight)
        }
        personSwitchView.snp.makeConstraints { (make) in
            make.left.equalTo(desLab.snp.right).offset(kMargin)
            make.centerY.equalTo(desLab)
        }
        bgView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(desLab.snp.bottom)
            make.height.equalTo(60)
        }
        warnTimeLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.top.bottom.equalTo(bgView)
            make.right.equalTo(iconWarnTimeView.snp.left).offset(-kMargin)
        }
        iconWarnTimeView.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.centerY.equalTo(bgView)
            make.size.equalTo(CGSize.init(width: 24, height: 26))
        }
        desLab1.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(desLab)
            make.top.equalTo(bgView.snp.bottom)
        }
        bgView1.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(bgView)
            make.top.equalTo(desLab1.snp.bottom)
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
        lab.text = "定时布防"
        
        return lab
    }()
    /// 定时布防 开关
    lazy var personSwitchView: UISwitch = {
        let sw = UISwitch()
        sw.isOn = isSetDayTime
        sw.addTarget(self, action: #selector(onSwitchViewChange), for: .valueChanged)
        return sw
    }()
    ///
    lazy var bgView : UIView = {
        let line = UIView()
        line.backgroundColor = kWhiteColor
        return line
    }()
    lazy var warnTimeLab : UILabel = {
        let lab = UILabel()
        lab.textColor = kBlackFontColor
        lab.font = k15Font
        lab.textAlignment = .center
        lab.numberOfLines = 2
        lab.text = "未设置"
        
        return lab
    }()
    /// icon
    lazy var iconWarnTimeView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_naozhong"))
    ///
    lazy var desLab1 : UILabel = {
        let lab = UILabel()
        lab.textColor = kBlackFontColor
        lab.font = k15Font
        lab.text = "延时布防1-30（秒）"
        
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
        lab.text = "\(guard_delay)秒"
        
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
    /// 开关状态
    @objc func onSwitchViewChange(){
        //默认震动效果
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        isSetDayTime = personSwitchView.isOn
        iconWarnTimeView.isUserInteractionEnabled = isSetDayTime
        if !isSetDayTime {
            warnTimeLab.text = "未设置"
            day_time = ""
            week_time = ""
            user_define_times.removeAll()
        }
    }
    /// 保存
    @objc func clickedSaveBtn(){
//        if day_time.isEmpty {
//            MBProgressHUD.showAutoDismissHUD(message: "请选择定时布防时间")
//            return
//        }
//        if week_time.isEmpty {
//            MBProgressHUD.showAutoDismissHUD(message: "请选择定时布防执行周期")
//            return
//        }
        if guard_delay.isEmpty {
            guard_delay = "8"
        }
        sendSaveMqttCmd()
    }
    
    /// 编辑时间
    @objc func onClickedEditTime(){
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        let vc = HOOPWarnEditTimeVC()
        vc.resultBlock = {[weak self] (dayTime, weekTime,customWeek) in
            
            self?.isRequest = false
            self?.week_time = weekTime
            self?.day_time = dayTime
            self?.user_define_times = customWeek
            self?.setGuardTime()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 选择时间
    @objc func onSelectTime(){
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        UsefulPickerView.showSingleColPicker("选择延时布防(1-30秒)", data: timeArr, defaultSelectedIndex: nil) {[weak self] (index, value) in
            self?.timeLab.text = value + "秒"
            self?.guard_delay = value
        }
    }
    
    /// mqtt发布主题
    func sendSaveMqttCmd(){
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["device_id":userDefaults.string(forKey: "devId") ?? "","user_id":userDefaults.string(forKey: "phone") ?? "","msg":["is_set":isSetDayTime,"guard_time":["day_time":day_time,"week_time":week_time,"user_define_times":user_define_times],"guard_delay":guard_delay],"msg_type":"guard_setting","app_interface_tag":""]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// 安防设置信息查询
    func sendMqttCmd(){
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["device_id":userDefaults.string(forKey: "devId") ?? "","user_id":userDefaults.string(forKey: "phone") ?? "","msg_type":"guard_setting_query","app_interface_tag":""]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    
    /// 重载CocoaMQTTDelegate
    override func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        super.mqtt(mqtt, didStateChangeTo: state)
        if state == .connected {
            if isRequest{
                sendMqttCmd()
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
            if type == "guard_setting_re" && phone == userDefaults.string(forKey: "phone"){
                hud?.hide(animated: true)
                if result["ret"].intValue == 1{
                    clickedBackBtn()
                    MBProgressHUD.showAutoDismissHUD(message: "设置成功")
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: "设置失败")
                }
            }else if type == "guard_setting_query_re" && phone == userDefaults.string(forKey: "phone"){
                hud?.hide(animated: true)
                if result["ret"].intValue == 1{
                    day_time = result["guard_time"]["day_time"].stringValue
                    if !day_time.isEmpty{
                        isSetDayTime = true
                        iconWarnTimeView.isUserInteractionEnabled = isSetDayTime
                    }
                    week_time = result["guard_time"]["week_time"].stringValue
                    if result["guard_delay"].intValue > 0 {
                        guard_delay = result["guard_delay"].stringValue
                        timeLab.text = guard_delay + "秒"
                    }
                    
                    guard let itemInfo = result["guard_time"]["user_define_times"].array else { return }
                    for item in itemInfo{
                        user_define_times.append(item.stringValue)
                    }
                    setGuardTime()
                    
                }
            }
            
        }
    }
    /// 解析时间
    func setGuardTime(){
        
        if week_time == "USER_DEFINE" {// 自定义
            var days: String = ""
            for item in user_define_times{
                days += GUARDBUFANGTIMEBYWEEKDAY[item]! + ","
            }
            if days.count > 0{
                days = days.subString(start: 0, length: days.count - 1)
            }
            warnTimeLab.text = day_time + "\n" + days
        }else{
            if !day_time.isEmpty && !week_time.isEmpty{
                warnTimeLab.text = day_time + "\n" + GUARDBUFANGTIME[week_time]!
            }
        }
    }
}
