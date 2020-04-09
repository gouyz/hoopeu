//
//  AppDelegate.swift
//  hoopeu
//
//  Created by gouyz on 2019/1/3.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var timer: Timer?
    var mqtt: CocoaMQTT?
    /// mqtt是否断开
    var isNetWorkMqtt = false
    
    /// 是否检测过版本更新
    var isFirstCheckVersion: Bool = false
    /// 当前系统版本
    var currSystemVersion: String = ""
    /// 最新系统版本model
    var newSystemVersionModel: HOOPVersionModel?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        /// 检测网络状态
        networkManager?.startListening()
        
        /// 设置键盘控制
        setKeyboardManage()
        
        ///设置极光推送
        setJPush()
        #if DEBUG
        JPUSHService.setup(withOption: launchOptions, appKey: kJPushAppKey, channel: "app store", apsForProduction: false)
        #else
        JPUSHService.setup(withOption: launchOptions, appKey: kJPushAppKey, channel: "app store", apsForProduction: true)
        #endif
        // badge清零
        resetBadge()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = kWhiteColor
        
        //如果未登录进入登录界面，登录后进入首页
        if userDefaults.bool(forKey: kIsLoginTagKey) {
            let menuContrainer = FWSideMenuContainerViewController.container(centerViewController: GYZMainTabBarVC(), centerLeftPanViewWidth: 20, centerRightPanViewWidth: 20, leftMenuViewController: HOOPLeftMenuVC(), rightMenuViewController: nil)
            menuContrainer.leftMenuWidth = kLeftMenuWidth

            window?.rootViewController = menuContrainer

        }else{
            window?.rootViewController = GYZBaseNavigationVC(rootViewController: HOOPRegisterFirstVC())
        }
//        window?.rootViewController = GYZBaseNavigationVC(rootViewController: HOOPRegisterFirstVC())
        window?.makeKeyAndVisible()
        
        setTimer()
        mqttSetting()
        requestVersion()
        // 获取推送消息
        let remote = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable : Any]
        // 如果remote不为空，就代表应用在未打开的时候收到了推送消息
        if remote != nil {
            // 收到推送消息实现的方法
            self.perform(#selector(receivePush), with: remote, afterDelay: 1.0);
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    ///（App即将进入前台）中将小红点角标清除
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        application.applicationIconBadgeNumber = 0
        application.cancelAllLocalNotifications()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    /// 极光推送注册成功后会调用AppDelegate的下面方法，得到设备的deviceToken
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        JPUSHService.registerDeviceToken(deviceToken)
        print("Notification token: ", deviceToken)
    }
    ///处理接收推送错误的情况(一般不会…)
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("error: Notification setup failed: ", error)
    }
    /// App在后台时收到推送时的处理,iOS7及以上系统
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        JPUSHService.handleRemoteNotification(userInfo)
        
        //        let aps = userInfo["aps"] as! [String : Any]
        //        let alert = aps["alert"] as! String
        
        
        //        var badge: Int = aps["badge"] as! Int
        //        badge -= 1
        //        JPUSHService.setBadge(badge)
        /**
         *  iOS的应用程序分为3种状态
         *      1、前台运行的状态UIApplicationStateActive；
         *      2、后台运行的状态UIApplicationStateBackground；
         *      3、app待激活状态UIApplicationStateInactive。
         */
        // 应用在前台 或者后台开启状态下，不跳转页面，让用户选择。
        if (application.applicationState == .active) || (application.applicationState == .background){
            showWarnAlert()
        }else{
            receivePush(userInfo)
        }
        // badge清零
        resetBadge()
        completionHandler(.newData)
    }
    
    // 接收到推送实现的方法
    @objc func receivePush(_ userInfo : [AnyHashable : Any]) {
        /// 消息推送通知
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kJPushRefreshData), object: nil,userInfo:userInfo)
    }
    
    /// 极光推送重置角标
    func resetBadge(){
        // badge清零
        UIApplication.shared.applicationIconBadgeNumber = 0
        JPUSHService.resetBadge()
    }
    /// APP在后台或运行时，接收到报警推送
    func showWarnAlert(){
        let alert = UIAlertView.init(title: "提示", message: "有新的报警信息，请先去处理!", delegate: self, cancelButtonTitle: "去处理")
        alert.tag = 101
        alert.show()
    }
    
    /// 极光推送设置
    func setJPush(){
        
        if #available(iOS 12.0, *){
            let entiity = JPUSHRegisterEntity()
            entiity.types = Int(JPAuthorizationOptions.alert.rawValue | JPAuthorizationOptions.providesAppNotificationSettings.rawValue |
                JPAuthorizationOptions.badge.rawValue |
                JPAuthorizationOptions.sound.rawValue)
            JPUSHService.register(forRemoteNotificationConfig: entiity, delegate: self)
        } else if #available(iOS 10.0, *){
            let entiity = JPUSHRegisterEntity()
            entiity.types = Int(UNAuthorizationOptions.alert.rawValue |
                UNAuthorizationOptions.badge.rawValue |
                UNAuthorizationOptions.sound.rawValue)
            JPUSHService.register(forRemoteNotificationConfig: entiity, delegate: self)
        } else if #available(iOS 8.0, *) {
            let types = UIUserNotificationType.badge.rawValue |
                UIUserNotificationType.sound.rawValue |
                UIUserNotificationType.alert.rawValue
            JPUSHService.register(forRemoteNotificationTypes: types, categories: nil)
        }else {
            let type = UIRemoteNotificationType.badge.rawValue |
                UIRemoteNotificationType.sound.rawValue |
                UIRemoteNotificationType.alert.rawValue
            JPUSHService.register(forRemoteNotificationTypes: type, categories: nil)
        }
    }

    /// 设置键盘控制
    func setKeyboardManage(){
        //控制自动键盘处理事件在整个项目内是否启用
        IQKeyboardManager.shared.enable = true
        //点击背景收起键盘
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        //隐藏键盘上的工具条(默认打开)
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    /// 请求服务器版本
    func requestVersion(){
        weak var weakSelf = self
        GYZNetWork.requestNetwork("appVersion/app/ios",isToken:false, parameters: nil,method:.get, success:{ (response) in
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                let data = response["data"]
                let content = data["updateMessage"].stringValue
                let version = data["versionName"].stringValue
                weakSelf?.checkVersion(newVersion: version, content: content)
            }
        }, failture: { (error) in
            GYZLog(error)
        })
    }
    ///获取设备版本信息
    func requestDeviceVersion(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        
        GYZNetWork.requestNetwork("appVersion",parameters: nil,method:.get,  success: { (response) in
            
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let data = response["data"].dictionaryObject else { return }
                
                weakSelf?.newSystemVersionModel = HOOPVersionModel.init(dict: data)
                weakSelf?.showSystemVersion()
            }
            
        }, failture: { (error) in
            
            GYZLog(error)
        })
    }
    // 设备系统升级
    func showSystemVersion(){
        if newSystemVersionModel != nil && newSystemVersionModel?.versionName != currSystemVersion {
            let alert = UIAlertView.init(title: "系统升级", message: newSystemVersionModel?.updateMessage ?? "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确认")
            alert.tag = 105
            alert.show()
        }
//        else{
//            let alert = UIAlertView.init(title: nil, message: "当前已是最新版本", delegate: nil, cancelButtonTitle: "我知道了")
//            alert.show()
//        }
        
    }
    
    /// 检测APP更新
    func checkVersion(newVersion: String,content: String){
        
        let type: UpdateVersionType = GYZUpdateVersionTool.compareVersion(newVersion: newVersion)
        switch type {
        case .update:
            updateVersion(version: newVersion, content: content)
        case .updateNeed:
            updateNeedVersion(version: newVersion, content: content)
        default:
            break
        }
    }
    /**
     * //不强制更新
     * @param version 版本名称
     * @param content 更新内容
     */
    func updateVersion(version: String,content: String){
        let alert = UIAlertView.init(title: "发现新版本\(version)", message: content, delegate: self, cancelButtonTitle: "残忍拒绝", otherButtonTitles: "立即更新")
        alert.tag = 103
        alert.show()
    }
    /**
     * 强制更新
     * @param version 版本名称
     * @param content 更新内容
     */
    func updateNeedVersion(version: String,content: String){
        
        let alert = UIAlertView.init(title: "发现新版本\(version)", message: content, delegate: self, cancelButtonTitle: "立即更新")
        alert.tag = 104
        alert.show()
    }
    
}

// MARK: - JPUSHRegisterDelegate 极光推送代理
extension AppDelegate : JPUSHRegisterDelegate{
    
    @available(iOS 12.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification?) {
        
        if notification != nil {//从通知界面直接进入应用
            
        }
        
    }
    
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        
        print(">JPUSHRegisterDelegate jpushNotificationCenter willPresent")
        let userInfo = notification.request.content.userInfo
        if (notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))!{
            JPUSHService.handleRemoteNotification(userInfo)
        }
        completionHandler(Int(UNAuthorizationOptions.alert.rawValue | UNAuthorizationOptions.sound.rawValue))// 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
    }
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        
        print(">JPUSHRegisterDelegate jpushNotificationCenter didReceive")
        let userInfo = response.notification.request.content.userInfo
        
        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))!{
            JPUSHService.handleRemoteNotification(userInfo)
            
            /**
             *  iOS的应用程序分为3种状态
             *      1、前台运行的状态UIApplicationStateActive；
             *      2、后台运行的状态UIApplicationStateBackground；
             *      3、app待激活状态UIApplicationStateInactive。
             */
            // 应用在前台 或者后台开启状态下，不跳转页面，让用户选择。
            if (UIApplication.shared.applicationState == .active) || (UIApplication.shared.applicationState == .background){
                showWarnAlert()
            }else{
                receivePush(userInfo)
            }
        }
        // 系统要求执行这个方法
        completionHandler()
        // 应用打开的时候收到推送消息
        //        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName_ReceivePush), object: NotificationObject_Sueecess, userInfo: userInfo)
    }
}

extension AppDelegate : UIAlertViewDelegate{
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        let tag = alertView.tag
        if tag == 101 {  // 处理报警
            if buttonIndex == 0 {//去处理
                if let menuVC = self.window?.rootViewController as? FWSideMenuContainerViewController{
                    if let tabBarVC = menuVC.centerViewController as? UITabBarController{
                        let nvc: UINavigationController = tabBarVC.selectedViewController as! UINavigationController
                        let currVC = nvc.visibleViewController
                        if UIApplication.shared.applicationState == .active{
                            //防止同一界面多次 push
                            if !(currVC?.isMember(of: HOOPWarnLogVC.self))!{
                                let logVC = HOOPWarnLogVC()
                                currVC?.navigationController?.pushViewController(logVC, animated: true)
                            }
                        }
                    }
                    
                }
            }
        }else if tag == 102{// 处理断网
            if buttonIndex == 1 {//去配网
                if let menuVC = self.window?.rootViewController as? FWSideMenuContainerViewController{
                    if let tabBarVC = menuVC.centerViewController as? UITabBarController{
                        let nvc: UINavigationController = tabBarVC.selectedViewController as! UINavigationController
                        let currVC = nvc.visibleViewController
                        if UIApplication.shared.applicationState == .active{
                            //防止同一界面多次 push
                            if !(currVC?.isMember(of: HOOPLinkPowerVC.self))!{
                                let logVC = HOOPLinkPowerVC()
                                currVC?.navigationController?.pushViewController(logVC, animated: true)
                            }
                        }
                    }
                    
                }
            }
        }else if tag == 103{
            if buttonIndex == 1{//立即更新
                GYZUpdateVersionTool.goAppStore()
            }
        }else if tag == 104{
            if buttonIndex == 0{//立即更新
                GYZUpdateVersionTool.goAppStore()
            }
        }else if tag == 105{
            if buttonIndex == 1 { //设备更新
                sendMqttCmdUpdateVerison()
            }
        }
    }
}
extension AppDelegate: CocoaMQTTDelegate {
    
    func setTimer(){
        timer = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(onClickTimer), userInfo: nil, repeats: true)
    }
    
    @objc func onClickTimer(){
        if mqtt == nil {
            return
        }
        
        if mqtt?.connState == CocoaMQTTConnState.disconnected{
            mqtt?.connect()
        }else{
            sendMqttCheckOnlineCmd()
        }
    }
    
    /// 检测网络信息查询
    func sendMqttCheckOnlineCmd(){
        if userDefaults.string(forKey: "devId") == nil {
            return
        }
        if !isFirstCheckVersion {
            self.isNetWorkMqtt = true
            return
        }
        
        let paramDic:[String:Any] = ["device_id":userDefaults.string(forKey: "devId") ?? "","user_id":userDefaults.string(forKey: "phone") ?? "","msg_type":"query_online","app_interface_tag":"ok"]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// mqtt发布主题 系统更新检测
    func sendMqttCmdVerison(){
        if userDefaults.string(forKey: "devId") == nil {
            return
        }
        let paramDic:[String:Any] = ["device_id":userDefaults.string(forKey: "devId") ?? "","user_id":userDefaults.string(forKey: "phone") ?? "","msg_type":"get_dev_info","app_interface_tag":userDefaults.string(forKey: "devId") ?? ""]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// mqtt发布主题 系统更新
    func sendMqttCmdUpdateVerison(){
        let paramDic:[String:Any] = ["device_id":userDefaults.string(forKey: "devId") ?? "","user_id":userDefaults.string(forKey: "phone") ?? "","msg_type":"send_sys_update","app_interface_tag":"ok"]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    
    /// 创建mqtt
    func mqttSetting() {
        let clientID = "hoopeu-" + String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: kDefaultMQTTHost, port: kDefaultMQTTPort)
        mqtt!.username = kDefaultMQTTUserName
        mqtt!.password = kDefaultMQTTUserPwd
        //        mqtt!.willMessage = CocoaMQTTWill(topic: "hoopeu_app", message: "dieout")
        mqtt!.keepAlive = 150
        mqtt?.autoReconnect = true
        mqtt!.delegate = self
        mqtt!.connect()
    }
    /// 配网提示
    func showNetWorkAlert(){
        
        let alert = UIAlertView.init(title: "提示", message: "当前设备网络异常，是否重新配网？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "去配网")
        alert.tag = 102
        alert.show()
    }
    /// 倒计时
    ///
    /// - Parameter duration: 倒计时时间
    func startSMSWithDuration(duration:Int){
        var times = duration
        
        let timer:DispatchSourceTimer = DispatchSource.makeTimerSource(flags: [], queue:DispatchQueue.global())
        
        timer.setEventHandler {
            if times > 0{
                DispatchQueue.main.async(execute: {
                    times -= 1
                })
            } else{
                DispatchQueue.main.async(execute: {
                    if !self.isNetWorkMqtt{// 没有网络，去配网
                        self.showNetWorkAlert()
                        self.isNetWorkMqtt = false
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
            mqtt.subscribe("hoopeu_app", qos: CocoaMQTTQOS.qos1)
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        GYZLog("new state: \(state)")
        if state == .connected {
            sendMqttCheckOnlineCmd()
            if !isFirstCheckVersion {
                sendMqttCmdVerison()
            }
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        GYZLog("message: \(message.string!.description), id: \(id)")
        startSMSWithDuration(duration: 5)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        GYZLog("id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        GYZLog("message: \(message.string!.description), id: \(id)")
        
        if let data = message.string {
            let result = JSON.init(parseJSON: data)
            let type = result["msg_type"].stringValue
            if type == "query_online_re" && result["device_id"].stringValue == userDefaults.string(forKey: "devId"){
                isNetWorkMqtt = true
            }else if type == "get_dev_info_re" && result["app_interface_tag"].stringValue == userDefaults.string(forKey: "devId"){
                currSystemVersion = result["msg"]["sys_version"].stringValue
                isFirstCheckVersion = true
                requestDeviceVersion()
            }else if type == "send_sys_update_re"{
                if result["ret"].intValue == 1{
                    MBProgressHUD.showAutoDismissHUD(message: "发送成功")
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: "发送失败")
                }
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
