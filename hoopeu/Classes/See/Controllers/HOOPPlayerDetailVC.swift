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
import ZFPlayer

class HOOPPlayerDetailVC: GYZBaseVC {
    
    var player:ZFPlayerController?
    var callCenter : Any?//声明属性
    //(注意：这里必须是全局属性，不能定义局部变量，由于iOS10.0以后版本和之前的版本方法不同，所以我这里声明了一个任意类型的全局变量）

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "爱心看护"
        self.view.backgroundColor = kBlackColor
        
        showVideo()
        
        requestDevicePlus()
        mqttSetting()
    }
    override var shouldAutorotate: Bool{
        
        return (self.player?.shouldAutorotate)!
    }
    func showVideo(){
        
       
        self.view.addSubview(self.containerView)
        self.containerView.addSubview(self.playBtn)
        
        self.view.addSubview(shotBtn)
        self.view.addSubview(shotListBtn)
        
        let playerManager = ZFIJKPlayerManager.init()
        self.player = ZFPlayerController.init(playerManager: playerManager, containerView: self.containerView)
        self.player?.controlView = self.controlView
        /// 设置退到后台继续播放
        self.player?.pauseWhenAppResignActive = false
        self.player?.orientationDidChanged = {[weak self] (player,isFullScreen) in
            self?.setNeedsStatusBarAppearanceUpdate()
        }
        self.player?.assetURL = URL.init(string: "rtmp://pili-live-rtmp.hoopeurobot.com/hoopeu-video-camera/" + userDefaults.string(forKey: "devId")!)!
        self.controlView.showTitle("爱心看护", coverURLString: "", fullScreenMode: .automatic)
        
        self.containerView.snp.makeConstraints({ (make) in
            make.left.right.equalTo(self.view)
            make.top.equalTo(kTitleAndStateHeight)
            make.height.equalTo(self.view.snp.width).multipliedBy(9.0/16.0)
        })
        self.playBtn.snp.makeConstraints { (make) in
            make.center.equalTo(self.containerView)
            make.size.equalTo(CGSize.init(width: kTitleHeight, height: kTitleHeight))
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
        
    }
    lazy var controlView: ZFPlayerControlView = {
        let playerView = ZFPlayerControlView.init()
        playerView.fastViewAnimated = true
        playerView.autoHiddenTimeInterval = 5
        playerView.autoFadeTimeInterval = 0.5
        playerView.prepareShowLoading = true
        playerView.prepareShowControlView = true
        
        return playerView
    }()
    lazy var containerView: UIImageView = {
        let imgView = UIImageView.init()
        imgView.setImageWithURLString("", placeholder: ZFUtilities.image(with: UIColor.init(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1), size: CGSize.init(width: 1, height: 1)))
        
        return imgView
    }()
    /// 开始
    lazy var playBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "new_allPlay_44x44_"), for: .normal)
        btn.tag = 103
        btn.addTarget(self, action: #selector(clickedOperateBtn(btn:)), for: .touchUpInside)
        return btn
    }()
    /// 截图
    lazy var shotBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = k13Font
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.tag = 101
        btn.addTarget(self, action: #selector(clickedOperateBtn(btn:)), for: .touchUpInside)
        return btn
    }()
    /// 图库
    lazy var shotListBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = k13Font
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.tag = 102
        btn.addTarget(self, action: #selector(clickedOperateBtn(btn:)), for: .touchUpInside)
        return btn
    }()
    ///操作
    @objc func clickedOperateBtn(btn : UIButton){
        let tag = btn.tag
        if tag == 101  {// 截图
            if (self.player?.currentPlayerManager.isPlaying)!{
                requestUpdateHeaderImg(img: (self.player?.currentPlayerManager.thumbnailImageAtCurrentTime!())!)
            }else{
                MBProgressHUD.showAutoDismissHUD(message: "当前视频未播放，不能截图操作！")
            }
        }else if tag == 102{// 图库
            let vc = HOOPShotPhotosVC()
            navigationController?.pushViewController(vc, animated: true)
        }else if tag == 103{// 开始播放
            
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
        if (self.player?.isFullScreen)! {
            return .landscape
        }
        return .portrait
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.player?.isViewControllerDisappear = false
        
    }
    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
        
        ///检测是否需要关闭推流
        requestDeviceClosed()
        self.player?.isViewControllerDisappear = true
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        if (self.player?.isFullScreen)! {
            return .lightContent
        }
        return .default
    }
    override var prefersStatusBarHidden: Bool{
        /// 如果只是支持iOS9+ 那直接return NO即可，这里为了适配iOS8
        return (self.player?.isStatusBarHidden)!
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .slide
    }    /// 添加在线人数
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
                        self.player?.currentPlayerManager.play!()
                        
                    }else if call.callState == CTCallStateConnected {
                        print("电话接通")
                        self.player?.currentPlayerManager.pause!()
                        
                    }else if call.callState == CTCallStateIncoming {
                        print("电话被叫")
                        self.player?.currentPlayerManager.pause!()
                    }else if call.callState == CTCallStateDialing {
                        print("主动拨打电话")
                        self.player?.currentPlayerManager.pause!()
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
            
            self.player?.currentPlayerManager.pause!()
        }
        //挂断
        if (call.isOutgoing && call.hasConnected && call.hasEnded) {
            
            self.player?.currentPlayerManager.play!()
        }
    }
}
