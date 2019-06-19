//
//  HOOPSeePlayerVC.swift
//  hoopeu
//  视频播放
//  Created by gouyz on 2019/3/27.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import CocoaMQTT
import MBProgressHUD
import SwiftyJSON
import CallKit
import CoreTelephony

class HOOPSeePlayerVC: GYZBaseVC {

    var iPlayer:PLPlayer?
    var callCenter : Any?//声明属性
    //(注意：这里必须是全局属性，不能定义局部变量，由于iOS10.0以后版本和之前的版本方法不同，所以我这里声明了一个任意类型的全局变量）
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "爱心看护"
        self.view.backgroundColor = kBlackColor
        
        requestDevicePlus()
        mqttSetting()
    
    }
    
    /// 添加在线人数
    func requestDevicePlus(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        GYZNetWork.requestNetwork("device/plus", parameters: ["deviceId": userDefaults.string(forKey: "devId") ?? ""],  success: { (response) in
            
            GYZLog(response)
            
        }, failture: { (error) in
            GYZLog(error)
        })
    }
    /// 监听电话
    func checkPhoneState(){
        if #available(iOS 10.0, *) {//ios10.0之后调用此方法
            self.callCenter = CXCallObserver()
            //设置电话代理
            if let cObserver = self.callCenter as? CXCallObserver
            {
                cObserver.setDelegate(self, queue: DispatchQueue.main)
                
            }
            
        } else {//ios10.0之前
            self.callCenter = CTCallCenter()
            if let caCenter = self.callCenter as? CTCallCenter {
                caCenter.callEventHandler = { (call: CTCall) -> Void in
                    if call.callState == CTCallStateDisconnected {
                        print("电话挂断")
                        self.iPlayer?.resume()
                        
                    }else if call.callState == CTCallStateConnected {
                        print("电话接通")
                        self.iPlayer?.pause()
                        
                    }else if call.callState == CTCallStateIncoming {
                        print("电话被叫")
                        self.iPlayer?.pause()
                    }else if call.callState == CTCallStateDialing {
                        print("主动拨打电话")
                        
                    }
                    
                }
                
            }
            
        }
           
    }
    // 摄像头开始推流或停止推流
    func startOrEndPlayer(order: String){
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["device_id":userDefaults.string(forKey: "devId") ?? "","msg_type":"camera_order","user_id":userDefaults.string(forKey: "phone") ?? "","msg":["order":order],"app_interface_tag":""]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    func showVideo(){
        
        let options:PLPlayerOption = PLPlayerOption.default()
        let url:URL = URL.init(string: "rtmp://pili-live-rtmp.hoopeurobot.com/hoopeu-video-camera/" + userDefaults.string(forKey: "devId")!)!
        
        //初始化播放器，播放在线视频或直播（RTMP）
        self.iPlayer = PLPlayer.init(url: url, option: options)
        //播放页面视图宽高自适应
//        let autoresize = UIView.AutoresizingMask.flexibleWidth.rawValue |
//            UIView.AutoresizingMask.flexibleHeight.rawValue
//        self.iPlayer?.playerView!.autoresizingMask = UIView.AutoresizingMask(rawValue: autoresize)
        
        self.iPlayer?.playerView!.frame = CGRect.init(x: 0, y: kTitleAndStateHeight, width: kScreenWidth, height: kScreenWidth * 9 / 16)
        self.iPlayer?.playerView!.center = self.view.center
        self.iPlayer?.delegate = self
//        self.view.autoresizesSubviews = true
        self.view.addSubview((self.iPlayer?.playerView)!)
        
        self.iPlayer?.play() //播放
        
    }
    
    /// 检测是否需要关闭推流
    func requestDeviceClosed(){
        if !GYZTool.checkNetWork() {
            return
        }
        weak var weakSelf = self
        GYZNetWork.requestNetwork("device/reduce", parameters: ["deviceId": userDefaults.string(forKey: "devId") ?? ""],  success: { (response) in
            
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                ///1需要关闭推流  0不需要关闭推流
                if response["data"].intValue == 1{
                    ///停止推流
                    weakSelf?.startOrEndPlayer(order: "camera_stop_push")
                }
                
                if weakSelf?.mqtt != nil {
                    weakSelf?.isUserDisConnect = true
                    /// 关闭mqtt
                    weakSelf?.mqtt?.disconnect()
                    weakSelf?.mqtt = nil
                }
                
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
        }, failture: { (error) in
            GYZLog(error)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        ///检测是否需要关闭推流
        requestDeviceClosed()
        
//        super.viewWillDisappear(animated)
        
        self.iPlayer?.stop() //关闭播放器
    
    }
    
    /// 重载CocoaMQTTDelegate
    override func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        super.mqtt(mqtt, didStateChangeTo: state)
        if state == .connected {
            startOrEndPlayer(order: "camera_start_push")
        }
    }
    override func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        
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
            
            if type == "camera_order_re" && phone == userDefaults.string(forKey: "phone"){
                if result["ret"].intValue == 1 && result["order"].stringValue == "camera_start_push"{
                
                    showVideo()
                }else if result["ret"].intValue == 0 && result["order"].stringValue == "camera_start_push"{
                    weak var weakSelf = self
                    showEmptyView(content: "加载失败，请点击重新加载", reload: {
                        weakSelf?.startOrEndPlayer(order: "camera_start_push")
                    })
                }
            }
            
        }
    }
}

extension HOOPSeePlayerVC: PLPlayerDelegate{
    // 实现 <PLPlayerDelegate> 来控制流状态的变更
    func player(_ player: PLPlayer, stoppedWithError error: Error?) {
        // 当发生错误时，会回调这个方法
        GYZLog(error)
        weak var weakSelf = self
        showEmptyView(content: "加载失败，请点击重新加载", reload: {
            weakSelf?.startOrEndPlayer(order: "camera_start_push")
        })
    }
    
    func player(_ player: PLPlayer, statusDidChange state: PLPlayerStatus) {
        
        GYZLog(state)
        // 这里会返回流的各种状态，你可以根据状态做 UI 定制及各类其他业务操作
        // 除了 Error 状态，其他状态都会回调这个方法
        // 开始播放，当连接成功后，将收到第一个 PLPlayerStatusCaching 状态
        // 第一帧渲染后，将收到第一个 PLPlayerStatusPlaying 状态
        // 播放过程中出现卡顿时，将收到 PLPlayerStatusCaching 状态
        // 卡顿结束后，将收到 PLPlayerStatusPlaying 状态
        if state == PLPlayerStatus.statusPlaying {
            hud?.hide(animated: true)
            hiddenEmptyView()
        }
    }
}
extension HOOPSeePlayerVC: CXCallObserverDelegate{
    //iOS10.0以后版本下的电话监听代理
    @available(iOS 10.0, *)
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        /** 以下为我手动测试 如有错误欢迎指出
         拨通:  outgoing :1  onHold :0   hasConnected :0   hasEnded :0
         拒绝:  outgoing :1  onHold :0   hasConnected :0   hasEnded :1
         链接:  outgoing :1  onHold :0   hasConnected :1   hasEnded :0
         挂断:  outgoing :1  onHold :0   hasConnected :1   hasEnded :1
         
         新来电话:    outgoing :0  onHold :0   hasConnected :0   hasEnded :0
         保留并接听:  outgoing :1  onHold :1   hasConnected :1   hasEnded :0
         另一个挂掉:  outgoing :0  onHold :0   hasConnected :1   hasEnded :0
         保持链接:    outgoing :1  onHold :0   hasConnected :1   hasEnded :1
         对方挂掉:    outgoing :0  onHold :0   hasConnected :1   hasEnded :1
         */
        //接通
        if (call.isOutgoing && call.hasConnected && !call.hasEnded) {
            
            self.iPlayer?.pause()
        }
        //挂断
        if (call.isOutgoing && call.hasConnected && call.hasEnded) {
            
            self.iPlayer?.resume()
        }
    }
}
