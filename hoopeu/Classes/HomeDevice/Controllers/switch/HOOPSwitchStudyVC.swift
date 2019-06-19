//
//  HOOPSwitchStudyVC.swift
//  hoopeu
//  智能开关学习
//  Created by gouyz on 2019/4/3.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import CocoaMQTT
import MBProgressHUD
import SwiftyJSON

class HOOPSwitchStudyVC: GYZBaseVC {
    
    var switchName: String = "智能开关"
    var switchId:String = ""
    var duration: Int = 100
    var timer: DispatchSourceTimer?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = switchName
        
        setUpUI()
        mqttSetting()
    }
    
    func setUpUI(){
        view.addSubview(bgView)
        bgView.addSubview(iconView)
        iconView.addSubview(circleProgress)
        iconView.addSubview(onOffBtn)
        bgView.addSubview(timeLab)
        bgView.addSubview(desLab)
        bgView.addSubview(desContentLab)
        
        iconView.isUserInteractionEnabled = true
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(kTitleAndStateHeight + 20)
            make.bottom.equalTo(-20)
        }
        iconView.snp.makeConstraints { (make) in
            make.top.equalTo(kTitleAndStateHeight)
            make.centerX.equalTo(bgView)
            make.size.equalTo(CGSize.init(width: 220, height: 220))
        }
        onOffBtn.snp.makeConstraints { (make) in
            make.center.equalTo(iconView)
            make.size.equalTo(CGSize.init(width: 50, height: 50))
        }
        timeLab.snp.makeConstraints { (make) in
            make.top.equalTo(iconView.snp.bottom)
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.height.equalTo(kTitleHeight)
        }
        desLab.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(timeLab)
            make.top.equalTo(timeLab.snp.bottom).offset(kMargin)
        }
        desContentLab.snp.makeConstraints { (make) in
            make.left.right.equalTo(desLab)
            make.top.equalTo(desLab.snp.bottom).offset(kMargin)
        }
        
        circleProgress.initializeProgress()
    }
    
    lazy var bgView: UIView = {
        let bgview = UIView()
        bgview.backgroundColor = kWhiteColor
        bgview.cornerRadius = 10
        bgview.isUserInteractionEnabled = true
        
        return bgview
    }()
    lazy var iconView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_switch_bg_default"))
    
    lazy var circleProgress: SYRingProgressView = {
        let progress = SYRingProgressView.init(frame: CGRect.init(x: 10, y: 10, width: 200, height: 200))
        progress.backgroundColor = UIColor.clear
        progress.lineColor = kBlueFontColor
        progress.progressColor = kWhiteColor
        progress.lineRound = true
        progress.lineWidth = 10
        progress.isAnimation = true
        progress.progress = 0
        progress.isUserInteractionEnabled = true
        
        return progress
    }()

    /// 按钮
    lazy var onOffBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kWhiteColor
        btn.setImage(UIImage.init(named: "icon_switch_btn"), for: .normal)
        btn.setImage(UIImage.init(named: "icon_switch_btn_failed"), for: .selected)
        
        btn.addTarget(self, action: #selector(clickedOnOffBtn), for: .touchUpInside)
        
        return btn
    }()
    ///
    lazy var timeLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlueFontColor
        lab.text = "\(duration)s"
        lab.textAlignment = .center
        
        return lab
    }()
    ///
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlueFontColor
        lab.text = "说明："
        
        return lab
    }()
    ///
    lazy var desContentLab : UILabel = {
        let lab = UILabel()
        lab.font = k13Font
        lab.textColor = kBlackFontColor
        lab.text = "1.初次加载请长按智能开关按钮，进行配置学习.\n2.长按智能开关上板按键4-6秒，听到“嘀嘀嘀”的声音后，松开按键."
        lab.numberOfLines = 0
        
        return lab
    }()
    /// 开关
    @objc func clickedOnOffBtn(){
        startSMSWithDuration(duration: duration)
        sendStudyMqttCmd()
    }
    
    /// 倒计时
    ///
    /// - Parameter duration: 倒计时时间
    func startSMSWithDuration(duration:Int){
        var times = duration
        
        timer = DispatchSource.makeTimerSource(flags: [], queue:DispatchQueue.global())
        
        timer?.setEventHandler {
            if times > 0{
                DispatchQueue.main.async(execute: {
                    self.circleProgress.progress += 1.0 / CGFloat.init(duration)
                    self.timeLab.text = "\(times)s"
                    times -= 1
                })
            } else{
                DispatchQueue.main.async(execute: {
                    self.timer?.cancel()
                    self.showStudyFailedAlert()
                })
            }
        }
        
        // timer.scheduleOneshot(deadline: .now())
        timer?.schedule(deadline: .now(), repeating: .seconds(1), leeway: .milliseconds(100))
        
        timer?.resume()
        
        // 在调用DispatchSourceTimer时, 无论设置timer.scheduleOneshot, 还是timer.scheduleRepeating代码 不调用cancel(), 系统会自动调用
        // 另外需要设置全局变量引用, 否则不会调用事件
    }
    
    /// 学习失败
    func showStudyFailedAlert(){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "学习失败，请重新尝试", cancleTitle: "取消", viewController: self, buttonTitles: "重新配置") { (index) in
            
            if index == cancelIndex{//取消,删除开关
                weakSelf?.sendDelMqttCmd()
            }else{// 重新学习
                weakSelf?.circleProgress.progress = 0
                weakSelf?.circleProgress.lineColor = kBlueFontColor
                weakSelf?.circleProgress.progressColor = kWhiteColor
                weakSelf?.timeLab.text = "\((weakSelf?.duration)!)s"
                weakSelf?.startSMSWithDuration(duration: (weakSelf?.duration)!)
                weakSelf?.sendStudyMqttCmd()
            }
        }
    }
    /// 学习成功
    func showStudySuccessAlert(){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "智能开关添加成功！", cancleTitle: nil, viewController: self, buttonTitles: "我知道了") { (index) in
            
            if index != cancelIndex{
                let _ = weakSelf?.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    /// mqtt发布主题 学习
    func sendStudyMqttCmd(){
        
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","ctrl_dev_id":switchId,"phone":userDefaults.string(forKey: "phone") ?? "","msg_type":"app_switch_study","app_interface_tag":""]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// mqtt发布主题 删除
    func sendDelMqttCmd(){
        
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","ctrl_dev_id":switchId,"phone":userDefaults.string(forKey: "phone") ?? "","msg_type":"app_switch_all_del","app_interface_tag":""]
        
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
            if type == "app_switch_study_re" && phone == userDefaults.string(forKey: "phone"){
                //                hud?.hide(animated: true)
                MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                
                timer?.cancel()
                timer = nil
                
                if result["code"].intValue == kQuestSuccessTag{
                    
                    showStudySuccessAlert()
                }else{// 学习失败
                    showStudyFailedAlert()
                }
            }else if type == "app_switch_all_del_re" && phone == userDefaults.string(forKey: "phone"){// 删除
               
                MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                
                if result["code"].intValue == kQuestSuccessTag{
                    
                    clickedBackBtn()
                }
            }
            
        }
    }
}
