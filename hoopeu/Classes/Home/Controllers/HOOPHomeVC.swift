//
//  HOOPHomeVC.swift
//  hoopeu
//  智慧家居
//  Created by gouyz on 2019/1/3.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

class HOOPHomeVC: GYZBaseVC,ContentViewDelegate {
    
    var titleArr : [String] = [String]()
    var dataList: [HOOPHomeModel] = [HOOPHomeModel]()
    // 房间id
    var roomIdValue : [String] = [String]()
    var scrollPageView: ScrollSegmentView?
    var contentView: ContentView?
    
    var selectTopImage: UIImage?
    var currIndex: Int = 0
    var rightBtn: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "智慧家居"
        self.view.backgroundColor = kWhiteColor
        //        self.navigationController?.delegate = self
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_home_menu")?.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(onClickedMenuImg))
        rightBtn = UIButton(type: .custom)
        rightBtn?.frame = CGRect.init(x: 0, y: 0, width: 64, height: kTitleHeight)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBtn!)
        //        userDefaults.set("eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMzMqKioqMjE0NiIsInVzZXJJZCI6NTQsImlhdCI6MTU2NDU4MzcxNSwiZXhwIjoxNTY1MTg4NTE1fQ.VLhChXpc3k4rMau4zKLyah-URk2SzVrQZI5ZmNaZbp0", forKey: "token")
        //        var y: CGFloat = kStateHeight
        //        if #available(iOS 11.0, *) {
        //            y = kTitleAndStateHeight + kStateHeight
        //        }
        topImgView.frame = CGRect.init(x: kMargin, y: kTitleAndStateHeight + kMargin, width: kScreenWidth - kMargin * 2, height: kScreenWidth * 0.34)
        
        view.addSubview(topImgView)
        
        rightBtn?.addSubview(powerLab)
        rightBtn?.addSubview(powerImgView)
        powerLab.snp.makeConstraints { (make) in
            make.top.right.height.equalTo(rightBtn!)
            make.width.equalTo(40)
        }
        powerImgView.snp.makeConstraints { (make) in
            make.centerY.equalTo(rightBtn!)
            make.right.equalTo(powerLab.snp.left)
            make.size.equalTo(CGSize.init(width: 18, height: 18))
        }
        
        requestRoomInfo()
        
        /// 极光推送跳转指定页面
        NotificationCenter.default.addObserver(self, selector: #selector(refreshJPushView(noti:)), name: NSNotification.Name(rawValue: kJPushRefreshData), object: nil)
        
        /// 电量通知
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPowerView(noti:)), name: NSNotification.Name(rawValue: kPowerRefreshData), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //        settingMqtt()
        // 本页面开启支持打开侧滑菜单
        self.menuContainerViewController.sideMenuPanMode = .defaults
        if userDefaults.bool(forKey: "isAddRoom") {
            userDefaults.set(false, forKey: "isAddRoom")
            scrollPageView?.removeFromSuperview()
            contentView?.removeFromSuperview()
            requestRoomInfo()
        }else{
            moveToRoom()
        }
        
    }
    func moveToRoom(){
        
        if dataList.count > 0 {
            
            var oldIndex: Int = currIndex
            segmentView.reloadTitlesWithNewTitles(titleArr)
            contentView?.reloadAllViewsWithNewChildVcs(setChildVcs())
            
            if let roomId = userDefaults.string(forKey: "roomId"){
                for (index,item) in roomIdValue.enumerated() {
                    if item == roomId{
                        currIndex = index
                        oldIndex = index
                        break
                    }
                }
                //                scrollPageView?.selectedIndex(currIndex, animated: true)
                //                userDefaults.removeObject(forKey: "roomId")
            }
            if currIndex != oldIndex {
                currIndex = oldIndex
            }
            scrollPageView?.selectedIndex(currIndex, animated: true)
        }
    }
    //    func settingMqtt(){
    //        if mqtt == nil {
    //            mqttSetting()
    //        }else {
    //            if self.mqtt?.connState == CocoaMQTTConnState.disconnected{
    //                self.mqtt?.connect()
    //            }else{
    //                sendMqttCmd()
    //            }
    //        }
    //    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 本页面开启支持关闭侧滑菜单
        self.menuContainerViewController.sideMenuPanMode = .none
    }
    
    ///设置控制器
    func setChildVcs() -> [UIViewController] {
        
        var childVC : [HOOPRoomDeviceVC] = []
        for index in 0 ..< titleArr.count{
            
            let vc = HOOPRoomDeviceVC()
            vc.roomId = roomIdValue[index]
            childVC.append(vc)
        }
        
        return childVC
    }
    
    /// 设置scrollView
    func setScrollView(){
        // 这个是必要的设置
        automaticallyAdjustsScrollViewInsets = false
        
        var style = SegmentStyle()
        // 滚动条
        style.showLine = true
        //        style.scrollTitle = false
        style.titleFont = k15Font
        style.titleMargin = 30
        // 颜色渐变
        style.gradualChangeTitleColor = true
        // 滚动条颜色
        style.scrollLineColor = kBlueFontColor
        style.normalTitleColor = kBlueFontColor
        style.selectedTitleColor = kBlueFontColor
        /// 显示角标
        style.showBadge = false
        /// 滑动控制器不可以切换
        style.vcIsScroll = false
        
        scrollPageView = ScrollSegmentView.init(frame: CGRect.init(x: 0, y: topImgView.bottomY, width: kScreenWidth, height: kTitleHeight), segmentStyle: style, titles: titleArr)
        
        scrollPageView?.backgroundColor = kBackgroundColor
        view.addSubview(scrollPageView!)
        
        contentView = ContentView.init(frame: CGRect.init(x: 0, y: scrollPageView!.bottomY, width: kScreenWidth, height: kScreenHeight - scrollPageView!.bottomY), childVcs: setChildVcs(), parentViewController: self,isScroll:false)
        contentView?.delegate = self // 必须实现代理方法
        
        scrollPageView?.titleBtnOnClick = {[unowned self] (label: UILabel, index: Int) in
            
            self.currIndex = index
            if let _ = userDefaults.string(forKey: "roomId"){
                (self.contentView?.childVcs[self.currIndex] as! HOOPRoomDeviceVC).settingMqtt()
                userDefaults.removeObject(forKey: "roomId")
            }
            
            //            if self.currIndex != index {
            //                if (self.contentView?.childVcs[self.currIndex] as! HOOPRoomDeviceVC).mqtt != nil {//类似viewWillDisappear
            //                    self.isUserDisConnect = true
            //                    /// 关闭mqtt
            //                    (self.contentView?.childVcs[self.currIndex] as! HOOPRoomDeviceVC).mqtt?.disconnect()
            //                    (self.contentView?.childVcs[self.currIndex] as! HOOPRoomDeviceVC).mqtt = nil
            //                }
            //                self.currIndex = index
            //                if (self.contentView?.childVcs[self.currIndex] as! HOOPRoomDeviceVC).mqtt == nil {//类似viewWillAppear
            //                    self.isUserDisConnect = false
            //                    (self.contentView?.childVcs[self.currIndex] as! HOOPRoomDeviceVC).roomId = self.roomIdValue[self.currIndex]
            //                    (self.contentView?.childVcs[self.currIndex] as! HOOPRoomDeviceVC).mqttSetting()
            //                }
            //            }
            self.setScrollIndex()
        }
        
        view.addSubview(contentView!)
        
    }
    
    func setScrollIndex(){
        self.contentView?.setContentOffSet(CGPoint(x: (self.contentView?.bounds.size.width)! * CGFloat(currIndex), y: 0), animated: false)
        
        self.topImgView.kf.setImage(with: URL.init(string: self.dataList[currIndex].image ?? ""), placeholder: UIImage.init(named: "icon_home_top_default"), options: nil, progressBlock: nil, completionHandler: nil)
    }
    
    /// MARK: ContentViewDelegate
    var segmentView: ScrollSegmentView{
        return scrollPageView!
    }
    
    lazy var topImgView: UIImageView = {
        let imgView = UIImageView.init(image: UIImage.init(named: "icon_home_top_default"))
        imgView.cornerRadius = 10
        imgView.contentMode = .scaleAspectFill
        
        imgView.addOnClickListener(target: self, action: #selector(onClickedTopImg))
        
        return imgView
    }()
    
    lazy var powerImgView: UIImageView = {
        let imgView = UIImageView.init()
        return imgView
    }()
    /// 电量按钮
    lazy var powerLab : UILabel = {
        let btn = UILabel()
        btn.font = k13Font
        btn.textColor = kBlueFontColor
        
        return btn
    }()
    /// 更换top图片
    @objc func onClickedTopImg(){
        if dataList[currIndex].roomId == "0" {
            MBProgressHUD.showAutoDismissHUD(message: "默认房间不能更换图片")
            return
        }
        GYZOpenCameraPhotosTool.shareTool.choosePicture(self, editor: true, finished: { [weak self] (image) in
            
            self?.selectTopImage = image
            self?.requestUpdateHeaderImg()
        })
    }
    
    /// 房间信息
    func requestRoomInfo(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("room/home", parameters: nil,  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                guard let data = response["data"].array else { return }
                weakSelf?.dataList.removeAll()
                for item in data{
                    guard let itemInfo = item.dictionaryObject else { return }
                    let model = HOOPHomeModel.init(dict: itemInfo)
                    
                    weakSelf?.dataList.append(model)
                }
                weakSelf?.setRoomInfo()
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    func setRoomInfo(){
        titleArr.removeAll()
        roomIdValue.removeAll()
        if dataList.count > 0 {
            topImgView.kf.setImage(with: URL.init(string: dataList[0].image ?? ""), placeholder: UIImage.init(named: "icon_home_top_default"), options: nil, progressBlock: nil, completionHandler: nil)
            for (index,model) in dataList.enumerated(){
                titleArr.append(model.roomName!)
                roomIdValue.append(model.roomId!)
                //                if model.roomId == "0"{
                //                    currIndex = 0
                //                }else
                if model.isDefault == "1"{
                    currIndex = index
                }
            }
            
            setScrollView()
            
            if currIndex != 0{
                scrollPageView?.selectedIndex(currIndex, animated: true)
            }
        }
    }
    /// 上传图片
    func requestUpdateHeaderImg(){
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        let imgParam: ImageFileUploadParam = ImageFileUploadParam()
        imgParam.name = "file"
        imgParam.fileName = "header.jpg"
        imgParam.mimeType = "image/jpg"
        imgParam.data = UIImage.jpegData(selectTopImage!)(compressionQuality: 0.5)!
        
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
        
        GYZNetWork.requestNetwork("user/updateIndexImage", parameters: ["indexImage": url,"roomId": dataList[currIndex].roomId!],  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                weakSelf?.topImgView.image = weakSelf?.selectTopImage
                weakSelf?.dataList[(weakSelf?.currIndex)!].image = url
                
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    
    /// 左侧菜单栏
    @objc func onClickedMenuImg(){
        self.menuContainerViewController.toggleLeftSideMenu(completeBolck: nil)
    }
    
    /// 极光推送，跳转指定页面
    ///
    /// - Parameter noti:
    @objc func refreshJPushView(noti:NSNotification){
        
        GYZLog(noti.userInfo)
        let userInfo = noti.userInfo!
        if userInfo.keys.contains("type") {
            let type = userInfo["type"] as! String
            if type == "leavemsg" {
                goLeaveMsgVC()
            }else{
                //            let deviceName = userInfo["deviceName"] as! String
                let deviceId = userInfo["deviceId"] as! String
                if deviceId == userDefaults.string(forKey: "devId") {
                    goWarnLogVC()
                }else{// 提示切换设备
                    weak var weakSelf = self
                    GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "是否切换设备以查看报警信息？", cancleTitle: "取消", viewController: self, buttonTitles: "确定") { (index) in
                        
                        if index != cancelIndex{
                            userDefaults.set(deviceId, forKey: "devId")
                            weakSelf?.requestUserDevice(devId: deviceId)
                        }
                    }
                }
            }
        }
        
    }
    /// 电量通知
    ///
    /// - Parameter noti:
    @objc func refreshPowerView(noti:NSNotification){
        
        GYZLog(noti.userInfo)
        let userInfo = noti.userInfo!
        
        let power = userInfo["power"] as! Int
        var name: String = "battery_100"
        switch power {
        case 0..<10:
            name = "battery_10"
        case 10..<20:
            name = "battery_20"
        case 20..<30:
            name = "battery_30"
        case 30..<40:
            name = "battery_40"
        case 40..<50:
            name = "battery_50"
        case 50..<60:
            name = "battery_60"
        case 60..<70:
            name = "battery_70"
        case 70..<80:
            name = "battery_80"
        case 80..<90:
            name = "battery_90"
        default:
            name = "battery_100"
        }
        powerImgView.image = UIImage.init(named: name)
        powerLab.text = "\(power)%"
        if power > 30 {
            powerLab.textColor = kBlueFontColor
        }else{
            powerLab.textColor = kRedFontColor
        }
    }
    /// 切换小叮当
    func requestUserDevice(devId: String){
        if !GYZTool.checkNetWork() {
            return
        }
        weak var weakSelf = self
        GYZNetWork.requestNetwork("userDevice", parameters: ["devId":devId],  success: { (response) in
            
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                weakSelf?.goWarnLogVC()
            }
            
        }, failture: { (error) in
            GYZLog(error)
        })
    }
    /// 显示是否处理报警
    //    func showWarnAlert(){
    //        weak var weakSelf = self
    //        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "有新的报警信息，请先去处理!", cancleTitle: nil, viewController: self, buttonTitles: "去处理") { (index) in
    //
    //            if index != cancelIndex{
    //                weakSelf?.goWarnLogVC()
    //            }
    //        }
    //    }
    func goWarnLogVC(){
        let vc = HOOPWarnLogVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    func goLeaveMsgVC(){
        let vc = HOOPMessageRecordManagerVC()
        vc.currIndex = 2
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// mqtt发布主题 查询设备当前电量
    //    func sendMqttCmd(){
    //        let paramDic:[String:Any] = ["device_id":userDefaults.string(forKey: "devId") ?? "","user_id":userDefaults.string(forKey: "phone") ?? "","msg_type":"query_power","app_interface_tag":"ok"]
    //
    //        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    //    }
    //
    //    /// 重载CocoaMQTTDelegate
    //    override func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
    //        GYZLog("new state: \(state)")
    //        if state == .connected {
    //            sendMqttCmd()
    //
    //        }
    //    }
    //    override func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
    //        super.mqtt(mqtt, didConnectAck: ack)
    //        GYZLog("new ack: \(ack)")
    //        if ack == .accept {
    //            mqtt.subscribe("hoopeu_app", qos: CocoaMQTTQOS.qos1)
    //        }
    //    }
    //    override func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
    //        super.mqtt(mqtt, didReceiveMessage: message, id: id)
    //
    //        if let data = message.string {
    //            let result = JSON.init(parseJSON: data)
    //            //            let phone = result["phone"].stringValue
    //            let type = result["msg_type"].stringValue
    //            if let tag = result["app_interface_tag"].string{
    //                if tag.hasPrefix("system_"){
    //                    return
    //                }
    //            }
    //
    //            if type == "query_power_re" && result["user_id"].stringValue == userDefaults.string(forKey: "phone"){
    //
    //                let power = result["msg"]["power"].intValue
    //                powerBtn.set(image: UIImage.init(named: "battery_\(power)"), title: "\(power)%", titlePosition: .right, additionalSpacing: 5, state: .normal)
    //                if power > 30 {
    //                    powerBtn.isSelected = false
    //                }else{
    //                    powerBtn.isSelected = true
    //                }
    //            }
    //        }
    //    }
}

/// mark - UINavigationControllerDelegate
//extension HOOPHomeVC : UINavigationControllerDelegate{
//    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//
//        /// 首页隐藏导航栏
//        let isShow = viewController.isKind(of: HOOPHomeVC.self)
//        self.navigationController?.setNavigationBarHidden(isShow, animated: true)
//    }
//}
