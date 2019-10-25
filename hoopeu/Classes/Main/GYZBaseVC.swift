//
//  GYZBaseVC.swift
//  flowers
//  基控制器
//  Created by gouyz on 2016/11/7.
//  Copyright © 2016年 gouyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

class GYZBaseVC: UIViewController {
    
    var hud : MBProgressHUD?
//    var statusBarShouldLight = true
    var mqtt: CocoaMQTT?
    /// mqtt是否断开链接
    var isDisConnect: Bool = true
    /// mqtt是否是手动h关闭
    var isUserDisConnect: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = kBackgroundColor
        
        if navigationController?.children.count > 1 {
            // 添加返回按钮,不被系统默认渲染,显示图像原始颜色
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back")?.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(clickedBackBtn))
        }
        
    }
    
    /// 重载设置状态栏样式
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        if statusBarShouldLight {
//
//            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: kWhiteColor, NSAttributedStringKey.font: k18Font]
//
//            navigationController?.navigationBar.barTintColor = kNavBarColor
//            navigationController?.navigationBar.tintColor = kWhiteColor
//
//            return .lightContent
//        } else {
//
//            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: kBlackColor, NSAttributedStringKey.font: k18Font]
//
//            navigationController?.navigationBar.barTintColor = kWhiteColor
//            navigationController?.navigationBar.tintColor = kBlackColor
//
//            return .default
//        }
//    }
//
//    /// 设置状态栏样式为default,设置导航栏透明
//    func setStatusBarStyle(){
//
//        navBarBgAlpha = 0
//        navBarTintColor = kBlackColor
//        statusBarShouldLight = false
//        setNeedsStatusBarAppearanceUpdate()
//    }
    /// 返回
    @objc func clickedBackBtn() {
        _ = navigationController?.popViewController(animated: true)
    }
    /// 关闭屏幕旋转
    override var shouldAutorotate: Bool{
        return false
    }
    /// 创建HUD
    func createHUD(message: String){
        if hud != nil {
            hud?.hide(animated: true)
            hud = nil
        }
        
        hud = MBProgressHUD.showHUD(message: message,toView: view)
    }
    /// 创建mqtt
    func mqttSetting() {
        let clientID = "hoopeu-" + String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: kDefaultMQTTHost, port: kDefaultMQTTPort)
        mqtt!.username = kDefaultMQTTUserName
        mqtt!.password = kDefaultMQTTUserPwd
        //        mqtt!.willMessage = CocoaMQTTWill(topic: "hoopeu_app", message: "dieout")
        mqtt!.keepAlive = 60
        mqtt!.delegate = self
        //        mqtt?.didReceiveMessage = { mqtt, message, id in
        //            print("Message received in topic \(message.topic) with payload \(message.string!)")
        //        }
        mqtt!.connect()
        //        mqtt!.subscribe("hoopeu_app", qos: CocoaMQTTQOS.qos1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if mqtt != nil {
            isUserDisConnect = true
            /// 关闭mqtt
            mqtt?.disconnect()
            mqtt = nil
        }
    }
    
    /// 倒计时
    ///
    /// - Parameter duration: 倒计时时间
    func startMqttWithDuration(duration:Int){
        var times = duration
        
        let timer:DispatchSourceTimer = DispatchSource.makeTimerSource(flags: [], queue:DispatchQueue.global())
        
        timer.setEventHandler {
            if times > 0{
                DispatchQueue.main.async(execute: {
                    
                    times -= 1
                })
            } else{
                DispatchQueue.main.async(execute: {
                    
                    if self.hud != nil {
                        self.hud?.hide(animated: true)
                    }
                    if self.isDisConnect{
//                        if self.hud != nil {
//                            self.hud?.hide(animated: true)
//                        }
                        MBProgressHUD.showAutoDismissHUD(message: "当前网络异常，操作可能失效！")
                    }
                    
                    timer.cancel()
                })
            }
        }
        
        // timer.scheduleOneshot(deadline: .now())
        timer.schedule(deadline: .now(), repeating: .seconds(1), leeway: .milliseconds(100))
        
        timer.resume()
        
        // 在调用DispatchSourceTimer时, 无论设置timer.scheduleOneshot, 还是timer.scheduleRepeating代码 不调用cancel(), 系统会自动调用
        // 另外需要设置全局变量引用, 否则不会调用事件
    }
}

extension GYZBaseVC: CocoaMQTTDelegate {
    
    // Optional ssl CocoaMQTTDelegate
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        /// Validate the server certificate
        ///
        /// Some custom validation...
        ///
        /// if validatePassed {
        ///     completionHandler(true)
        /// } else {
        ///     completionHandler(false)
        /// }
        completionHandler(true)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
       
        if ack == .accept {
            mqtt.subscribe("api_receive", qos: CocoaMQTTQOS.qos1)
//            mqtt.subscribe("hoopeu_app", qos: CocoaMQTTQOS.qos1)
            mqtt.subscribe("hoopeu_device", qos: CocoaMQTTQOS.qos1)
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        GYZLog("new state: \(state)")
        if state == .disconnected && !isUserDisConnect {
            isUserDisConnect = false
            if self.hud != nil {
                self.hud?.hide(animated: true)
            }
//            MBProgressHUD.showAutoDismissHUD(message: "当前网络异常，操作可能失效！")
        }else if state == .disconnected && self.mqtt != nil{//   断线重连
            self.mqtt?.connect()
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        GYZLog("message: \(message.string!.description), id: \(id)")
        startMqttWithDuration(duration: 5)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        GYZLog("id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        GYZLog("message: \(message.string!.description), id: \(id)")
        isDisConnect = false
        
        if let data = message.string {
            let result = JSON.init(parseJSON: data)
            let type = result["msg_type"].stringValue
            if result["code"].int == -200 || (type == "app_login" && result["user_id"].stringValue == userDefaults.string(forKey: "phone") && result["msg"].stringValue != userDefaults.string(forKey: "token")){
                MBProgressHUD.showAutoDismissHUD(message: "账号在其他设备登录")
                KeyWindow.rootViewController = GYZBaseNavigationVC(rootViewController: HOOPLoginVC())
                
                return
            }else if result["code"].int == -203{
                MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                let vc = HOOPLinkPowerVC()
                navigationController?.pushViewController(vc, animated: true)
                return
            }
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        GYZLog("topic: \(topic)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        GYZLog("topic: \(topic)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        GYZLog("\(err.debugDescription)")
//        mqttSetting()
    }
}
