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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var timer: Timer?


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
    
    func setTimer(){
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(requestDeviceNetWork), userInfo: nil, repeats: true)
    }
    /// 报警轮询
    @objc func requestDeviceNetWork(){
        if !userDefaults.bool(forKey: kIsLoginTagKey) {
            return
        }
        if !GYZTool.checkNetWork() {
            return
        }
        
        GYZNetWork.requestNetwork("alert", parameters: nil,method :.get,  success: { (response) in
            
            GYZLog(response)
//            if response["code"].intValue == -203{//未检测到正在使用的设备，请重新配网连接……
//                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
//                KeyWindow.rootViewController = GYZBaseNavigationVC(rootViewController: HOOPLoginVC())
//            }
            
        }, failture: { (error) in
            GYZLog(error)
        })
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
    }
}
