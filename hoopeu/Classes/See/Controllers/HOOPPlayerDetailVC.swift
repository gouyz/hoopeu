//
//  HOOPPlayerDetailVC.swift
//  hoopeu
//
//  Created by gouyz on 2019/6/18.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON
import CallKit
import CoreTelephony

class HOOPPlayerDetailVC: GYZBaseVC {
    
    var wnPlayer:WNPlayer?
    var callCenter : Any?//声明属性
    //(注意：这里必须是全局属性，不能定义局部变量，由于iOS10.0以后版本和之前的版本方法不同，所以我这里声明了一个任意类型的全局变量）

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.navigationItem.title = "爱心看护"
        self.view.backgroundColor = kBlackColor
        
       ////获取设备旋转方向的通知,即使关闭了自动旋转,一样可以监测到设备的旋转方向
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientationChange(noti:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        
//        self.wnPlayer = WNPlayer.init()
//        self.wnPlayer?.autoplay = true
//        self.wnPlayer?.title = "爱心看护"
//        self.wnPlayer?.delegate = self
//        self.view.addSubview(self.wnPlayer!)
//        self.wnPlayer?.snp.makeConstraints { (make) in
//            make.left.right.equalTo(self.view)
//            make.top.equalTo(self.view)
//            make.height.equalTo(self.view.snp.width).multipliedBy(9.0/16.0)
//        }
        showVideo()
        
        requestDevicePlus()
        mqttSetting()
    }
    override var shouldAutorotate: Bool{
        if wnPlayer?.playerManager.displayView.contentSize.width < wnPlayer?.playerManager.displayView.contentSize.height {
            return false
        }
        return true
    }
    func showVideo(){
        
        self.wnPlayer = WNPlayer.init()
        self.wnPlayer?.autoplay = true
        self.wnPlayer?.title = "爱心看护"
        self.wnPlayer?.delegate = self
        self.view.addSubview(self.wnPlayer!)
        
        self.view.addSubview(shotBtn)
        self.view.addSubview(shotListBtn)
        
        self.wnPlayer?.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            if #available(iOS 11.0, *) {
                make.top.equalTo(kStateHeight)
                
            }else{
                make.top.equalTo(self.view)
            }
            make.height.equalTo(self.view.snp.width).multipliedBy(9.0/16.0)
        }
        shotBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.view.snp.centerX).offset(-20)
            make.bottom.equalTo(-kTitleAndStateHeight)
            make.height.equalTo(90)
            make.width.equalTo(90)
        }
        shotListBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.snp.centerX).offset(20)
            make.bottom.height.width.equalTo(shotBtn)
        }
        
        shotBtn.set(image: UIImage.init(named: "icon_snapshot"), title: "截图", titlePosition: .bottom, additionalSpacing: 5, state: .normal)
        shotListBtn.set(image: UIImage.init(named: "icon_snapshot_list"), title: "图库", titlePosition: .bottom, additionalSpacing: 5, state: .normal)
        
        self.wnPlayer?.urlString = "rtmp://pili-live-rtmp.hoopeurobot.com/hoopeu-video-camera/" + userDefaults.string(forKey: "devId")!
//        self.wnPlayer?.urlString = "http://mov.bn.netease.com/open-movie/nos/flv/2017/01/03/SC8U8K7BC_hd.flv"
//        self.wnPlayer?.urlString = "rtmp://58.200.131.2:1935/livetv/hunantv"
//        self.wnPlayer?.open(withTCP: true, optionDic: ["headers":"Cookie:FTN5K=f44da28b"])
        self.wnPlayer?.play()
    }
    /// 截图
    lazy var shotBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = k13Font
        btn.setTitleColor(kBlackFontColor, for: .normal)
        btn.tag = 101
        btn.addTarget(self, action: #selector(clickedOperateBtn(btn:)), for: .touchUpInside)
        return btn
    }()
    /// 图库
    lazy var shotListBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = k13Font
        btn.setTitleColor(kBlackFontColor, for: .normal)
        btn.tag = 102
        btn.addTarget(self, action: #selector(clickedOperateBtn(btn:)), for: .touchUpInside)
        return btn
    }()
    ///操作
    @objc func clickedOperateBtn(btn : UIButton){
        let tag = btn.tag
        if tag == 101  {// 截图
            if (self.wnPlayer?.playerManager.playing)!{
                requestUpdateHeaderImg(img: (self.wnPlayer?.snapshot((self.wnPlayer?.frame.size)!))!)
            }else{
                MBProgressHUD.showAutoDismissHUD(message: "当前视频未播放，不能截图操作！")
            }
        }else{
            
        }
    }
    /// 上传图片
    func requestUpdateHeaderImg(img: UIImage){
        weak var weakSelf = self
        createHUD(message: "上传中...")
        
        let imgParam: ImageFileUploadParam = ImageFileUploadParam()
        imgParam.name = "file"
        imgParam.fileName = "videoShot.jpg"
        imgParam.mimeType = "image/jpg"
        imgParam.data = UIImage.jpegData(img)(compressionQuality: 0.5)!
        
        GYZNetWork.uploadImageRequest("qiniu/upload",baseUrl:"http://www.hoopeurobot.com/", parameters: nil, uploadParam: [imgParam], success: { (response) in
            
            //            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                weakSelf?.requestModifyTopImg(url: response["data"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    ///
    func requestModifyTopImg(url: String){
        
        
        weak var weakSelf = self
        
        GYZNetWork.requestNetwork("gallery", parameters: ["url": url,"deviceId": userDefaults.string(forKey: "devId") ?? ""],  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                MBProgressHUD.showAutoDismissHUD(message: "截图上传成功")
                
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    //viewController所支持的全部旋转方向
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.allButUpsideDown
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        ///检测是否需要关闭推流
        requestDeviceClosed()
        self.wnPlayer?.close()
    }
    /**
     *  旋转屏幕通知
     */
    @objc func onDeviceOrientationChange(noti:NSNotification){
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        switch orientation {
        case .portraitUpsideDown://第3个旋转方向---电池栏在下
            break
        case .portrait://第0个旋转方向---电池栏在上
            toOrientation(orientation: .portrait)
        case .landscapeLeft://第2个旋转方向---电池栏在左
            toOrientation(orientation: .landscapeLeft)
        case .landscapeRight://第1个旋转方向---电池栏在右
            toOrientation(orientation: .landscapeRight)
        default:
            break
        }
    }
    //点击进入,退出全屏,或者监测到屏幕旋转去调用的方法
    func toOrientation(orientation: UIDeviceOrientation){
        if orientation == .portrait {
            wnPlayer?.snp.remakeConstraints({ (make) in
                make.left.right.equalTo(self.view)
                make.top.equalTo(self.view)
                make.height.equalTo(self.view.snp.width).multipliedBy(9.0/16.0)
            })
            self.wnPlayer?.isFullscreen = false
        }else{
            wnPlayer?.snp.remakeConstraints({ (make) in
                if WNPlayer.isiPhoneX(){
                    if self.wnPlayer?.playerManager.displayView.contentSize.width < wnPlayer?.playerManager.displayView.contentSize.height {
                        make.edges.equalTo(UIEdgeInsets.init(top: 14, left: 0, bottom: 0, right: 0))
                    }else{
                        make.edges.equalTo(0)
                    }
                }else{
                    make.edges.equalTo(0)
                }
            })
            self.wnPlayer?.isFullscreen = true
        }
        if #available(iOS 11.0, *) {
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
        }
    }
    
    deinit {
        self.wnPlayer?.close()
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
                        self.wnPlayer?.play()
                        
                    }else if call.callState == CTCallStateConnected {
                        print("电话接通")
                        self.wnPlayer?.pause()
                        
                    }else if call.callState == CTCallStateIncoming {
                        print("电话被叫")
                        self.wnPlayer?.pause()
                    }else if call.callState == CTCallStateDialing {
                        print("主动拨打电话")
                        self.wnPlayer?.pause()
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
    
    /// 重载CocoaMQTTDelegate
    override func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        super.mqtt(mqtt, didStateChangeTo: state)
        if state == .connected {
//            startOrEndPlayer(order: "camera_start_push")
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
                    hud?.hide(animated: true)
                    hiddenEmptyView()
//                    self.showVideo()
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

extension HOOPPlayerDetailVC: WNPlayerDelegate{
    //点击关闭按钮代理方法
    func wnplayer(_ wnplayer: WNPlayer!, clickedClose backBtn: UIButton!) {
        if (self.wnPlayer?.isFullscreen)! {//全屏
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }else{
            clickedBackBtn()
        }
    }
    func wnplayer(_ wnplayer: WNPlayer!, clickedFullScreenButton fullScreenBtn: UIButton!) {
        if (self.wnPlayer?.isFullscreen)! {//全屏
           //强制翻转屏幕，Home键在下边。
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }else{
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
        UIViewController.attemptRotationToDeviceOrientation()
    }
    func wnplayerFailedPlay(_ wnplayer: WNPlayer!, wnPlayerStatus state: WNPlayerStatus) {
//        if state == WNPlayerStatusPlaying {
//            hud?.hide(animated: true)
//            hiddenEmptyView()
//        }
    }
}
extension HOOPPlayerDetailVC: CXCallObserverDelegate{
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
            
            self.wnPlayer?.pause()
        }
        //挂断
        if (call.isOutgoing && call.hasConnected && call.hasEnded) {
            
            self.wnPlayer?.play()
        }
    }
}
