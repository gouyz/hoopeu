//
//  HOOPConnectWiFiVC.swift
//  hoopeu
//  连接WiFi
//  Created by gouyz on 2019/3/24.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork
import CoreBluetooth
import MBProgressHUD
import SwiftyJSON
import CoreLocation

class HOOPConnectWiFiVC: GYZBaseVC {
    
    let UUID_SERVICE: String = "0000ffe7-0000-1000-8000-00805f9b34fb"
    let UUID_CHAR_READ_NOTIFY: String = "00002a05-0000-1000-8000-00805f9b34fb"
    let UUID_CHAR_WRITE: String = "0000ffe3-0000-1000-8000-00805f9b34fb"
    let UUID_DESC_NOTITY: String = "0000ffe2-0000-1000-8000-00805f9b34fb"
    //中心对象
//    var manager: CBCentralManager?
    // 当前连接的设备
    var peripheral: CBPeripheral?
    //发送数据特征(连接到设备之后可以把需要用到的特征保存起来，方便使用)
    var writeCharacteristic: CBCharacteristic?
    //读取数据特征(连接到设备之后可以把需要用到的特征保存起来，方便使用)
    var readCharacteristic: CBCharacteristic?
    /// 蓝牙会返回2次
    var isRecevice:Bool = false
    
    var dataModel: HOOPParamDetailModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "连接WiFi"
        self.view.backgroundColor = kWhiteColor
        
        setUpUI()
        
        requestIsPerfect()
        nameTxtFiled.text = getCurrentWifiName()
        self.peripheral?.delegate = self
        self.peripheral?.discoverServices(nil)
        
    }
    
    func setUpUI(){
        view.addSubview(desLab)
        view.addSubview(desLab1)
        view.addSubview(bgNameView)
        bgNameView.addSubview(nameTxtFiled)
        bgNameView.addSubview(nameLab)
        view.addSubview(bgPwdView)
        bgPwdView.addSubview(pwdTxtFiled)
        view.addSubview(connectBtn)
        view.addSubview(questionBtn)
        
        desLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.top.equalTo(kTitleAndStateHeight + kTitleHeight)
            make.height.equalTo(50)
        }
        desLab1.snp.makeConstraints { (make) in
            make.left.right.equalTo(desLab)
            make.top.equalTo(desLab.snp.bottom)
            make.height.equalTo(kTitleHeight)
        }
        bgNameView.snp.makeConstraints { (make) in
            make.top.equalTo(desLab1.snp.bottom).offset(20)
            make.left.right.equalTo(desLab)
            make.height.equalTo(50)
        }
        nameTxtFiled.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(nameLab.snp.left).offset(-kMargin)
            make.top.bottom.equalTo(bgNameView)
        }
        nameLab.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.top.bottom.equalTo(nameTxtFiled)
            make.width.equalTo(80)
        }
        
        bgPwdView.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(bgNameView)
            make.top.equalTo(bgNameView.snp.bottom).offset(20)
        }
        pwdTxtFiled.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.top.bottom.equalTo(bgPwdView)
        }
        
        connectBtn.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.bottom.equalTo(questionBtn.snp.top).offset(-20)
            make.height.equalTo(kUIButtonHeight)
        }
        questionBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(connectBtn)
            make.bottom.equalTo(-kTitleHeight)
            make.height.equalTo(kUIButtonHeight)
        }
    }
    
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.font = k18Font
        lab.textColor = kBlackFontColor
        lab.textAlignment = .center
        lab.text = "连接WiFi"
        
        return lab
    }()
    lazy var desLab1 : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        lab.textAlignment = .center
        lab.text = "请填写正确信息"
        
        return lab
    }()
    
    lazy var bgNameView: UIView = {
        let bgview = UIView()
        bgview.backgroundColor = kWhiteColor
        bgview.cornerRadius = 8
        bgview.borderColor = kGrayLineColor
        bgview.borderWidth = klineWidth
        
        return bgview
    }()
    ///WiFi名称
    lazy var nameTxtFiled : UITextField = {
        
        let textFiled = UITextField()
        textFiled.font = k15Font
        textFiled.textColor = kBlackFontColor
        textFiled.clearButtonMode = .whileEditing
        textFiled.placeholder = "WiFi名称"
        
        return textFiled
    }()
    ///选择网络
    lazy var nameLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlueFontColor
        lab.text = "选择网络"
        lab.isHidden = true
        
        lab.addOnClickListener(target: self, action: #selector(onClickedSelectWiFi))
        
        return lab
    }()
    lazy var bgPwdView: UIView = {
        let bgview = UIView()
        bgview.backgroundColor = kWhiteColor
        bgview.cornerRadius = 8
        bgview.borderColor = kGrayLineColor
        bgview.borderWidth = klineWidth
        
        return bgview
    }()
    /// wifi密码
    lazy var pwdTxtFiled : UITextField = {
        
        let textFiled = UITextField()
        textFiled.font = k15Font
        textFiled.textColor = kBlackFontColor
        textFiled.clearButtonMode = .whileEditing
        textFiled.isSecureTextEntry = true
        textFiled.placeholder = "密码"
        
        return textFiled
    }()
    /// 连接
    lazy var connectBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("连接", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = 8
        
        btn.addTarget(self, action: #selector(clickedConnectBtn), for: .touchUpInside)
        
        return btn
    }()
    /// 按钮
    lazy var questionBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kWhiteColor
        btn.setTitle("连接出现问题？", for: .normal)
        btn.setTitleColor(kBlueFontColor, for: .normal)
        btn.titleLabel?.font = k15Font
        
        btn.addTarget(self, action: #selector(clickedQuestionBtn), for: .touchUpInside)
        
        return btn
    }()
    /// 用户资料是否完善
    func requestIsPerfect(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("user/isPerfect", parameters: nil,  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let itemInfo = response["data"].dictionaryObject else { return }
                weakSelf?.dataModel = HOOPParamDetailModel.init(dict: itemInfo)
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    /// 连接出现问题
    @objc func clickedQuestionBtn(){
        goWebVC()
    }
    /// 连接出现问题
    func goWebVC(){
        let vc = JSMWebViewVC()
        vc.webTitle = "连接出现问题"
        vc.url = "http://www.hoopeurobot.com/page/protocol.html?id=6"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 连接
    @objc func clickedConnectBtn(){
        if writeCharacteristic == nil {
            MBProgressHUD.showAutoDismissHUD(message: "未发现写特征")
            return
        }
        createHUD(message: "数据写入中...")
        writeDeviceData()
    }
    /// 选择网络
    @objc func onClickedSelectWiFi(){
        let vc = HOOPWiFiListVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func getCurrentWifiName() -> String? {
        var wifiName : String = ""
        
        if #available(iOS 13.0, *){
            //用户明确拒绝，可以弹窗提示用户到设置中手动打开权限
            if CLLocationManager.authorizationStatus() == .denied {
                
                return wifiName
            }
            let cllocation = CLLocationManager.init()
            if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == .notDetermined {
                
                //弹框提示用户是否开启位置权限
                cllocation.requestWhenInUseAuthorization()
            }
        }
        let wifiInterfaces = CNCopySupportedInterfaces()
        if wifiInterfaces == nil {
            return nil
        }
        
        let interfaceArr = CFBridgingRetain(wifiInterfaces!) as! Array<String>
        if interfaceArr.count > 0 {
            for interfaceName in interfaceArr {
                let ussafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName as CFString)
                
                if (ussafeInterfaceData != nil) {
                    let interfaceData = ussafeInterfaceData as! Dictionary<String, Any>
                    wifiName = interfaceData["SSID"]! as! String
                }
            }
//            let interfaceName = interfaceArr[0] as CFString
//            let ussafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName)
//
//            if (ussafeInterfaceData != nil) {
//                let interfaceData = ussafeInterfaceData as! Dictionary<String, Any>
//                wifiName = interfaceData["SSID"]! as! String
//            }
        }
        if !wifiName.isEmpty {
            requestGetWifiPwd(ssid: wifiName)
        }
        return wifiName
    }
    ///获取wifi密码
    func requestGetWifiPwd(ssid: String){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        
        GYZNetWork.requestNetwork("appWifi",parameters: ["mac": ssid,"phone":userDefaults.string(forKey: "phone") ?? ""],method :.get,  success: { (response) in
            
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                weakSelf?.pwdTxtFiled.text = response["data"]["password"].stringValue
                
            }
            
        }, failture: { (error) in
            
            GYZLog(error)
        })
    }
    ///保存wifi密码
    func requestSaveWifiPwd(){
        if !GYZTool.checkNetWork() {
            return
        }
//        weak var weakSelf = self
        
        GYZNetWork.requestNetwork("appWifi",parameters: ["mac": nameTxtFiled.text!,"password":pwdTxtFiled.text!,"phone":userDefaults.string(forKey: "phone") ?? ""], success: { (response) in
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
            
            }
            
        }, failture: { (error) in
            
            GYZLog(error)
        })
    }
    //写入数据
    func writeDeviceData(){
        let paramDic:[String:Any] = ["msg":["ssid":nameTxtFiled.text!,"password":pwdTxtFiled.text!],"user_id":userDefaults.string(forKey: "phone") ?? "","msg_type":"bt_pair"]
        let heartRate: String = GYZTool.getJSONStringFromDictionary(dictionary: paramDic)
        let dataValue: Data = heartRate.data(using: .utf8)!
        //写入数据
        self.peripheral!.writeValue(dataValue, for: self.writeCharacteristic!, type: .withResponse)
        
        self.peripheral!.setNotifyValue(true, for: self.readCharacteristic!)
        self.peripheral!.readValue(for: self.readCharacteristic!)
    }
    /// 配网成功调用
    func requestUserDevice(){
        if !GYZTool.checkNetWork() {
            return
        }
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("userDevice", parameters: ["devId":userDefaults.string(forKey: "devId") ?? ""],  success: { (response) in
            
            GYZLog(response)
            weakSelf?.hud?.hide(animated: true)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                weakSelf?.dealGoVC()
                
            }
            
        }, failture: { (error) in
            GYZLog(error)
        })
    }
    func dealGoVC(){
        if let model = dataModel {
            if model.isPerfect == "0" {
                goFinishedData()
            }else{
                goHomeVC()
            }
        }else{
            goHomeVC()
        }
    }
    ///完善资料
    func goFinishedData(){
        let vc = HOOPRepairVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func goHomeVC(){
        let menuContrainer = FWSideMenuContainerViewController.container(centerViewController: GYZMainTabBarVC(), centerLeftPanViewWidth: 20, centerRightPanViewWidth: 20, leftMenuViewController: HOOPLeftMenuVC(), rightMenuViewController: nil)
        menuContrainer.leftMenuWidth = kLeftMenuWidth
        
        KeyWindow.rootViewController = menuContrainer
    }
}
extension HOOPConnectWiFiVC :CBPeripheralDelegate{
    //// CBPeripheralDelegate
    //5.请求周边去寻找它的服务所列出的特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            GYZLog("错误的服务特征:\(error!.localizedDescription)")
            return
        }
        for service in peripheral.services! {
            GYZLog("服务的UUID:\(service.uuid)")
            //发现给定格式的服务的特性
            if (service.uuid == CBUUID(string:UUID_SERVICE)) {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            
        }
    }
    //6.已搜索到Characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
        //println("发现特征的服务:\(service.UUID.data)   ==  服务UUID:\(service.UUID)")
        if (error != nil){
            GYZLog("服务的回调error \(error.debugDescription)")
            return
        }
        guard let serviceCharacters = service.characteristics else {
            GYZLog("service.characteristics 为空")
            return
        }
        for  characteristic in serviceCharacters  {
            //罗列出所有特性，看哪些是notify方式的，哪些是read方式的，哪些是可写入的。
            GYZLog("服务UUID:\(service.uuid)         特征UUID:\(characteristic.uuid)")
            
            if characteristic.uuid == CBUUID(string:UUID_CHAR_WRITE){
                
                self.writeCharacteristic = characteristic
            }else if characteristic.uuid == CBUUID(string:UUID_CHAR_READ_NOTIFY){
                
                self.readCharacteristic = characteristic
//                self.peripheral!.setNotifyValue(true, for: self.readCharacteristic!)
//                self.peripheral!.readValue(for: self.readCharacteristic!)
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error == nil {
            GYZLog("写入成功")
            self.hud?.hide(animated: true)
            createHUD(message: "等待接收数据...")
        }
    }
    //8.获取外设发来的数据，不论是read和notify,获取数据都是从这个方法中读取。
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?){
        GYZLog("接到服务端发送的数据")
        
        if (characteristic.value != nil) {
            let data = String.init(data: characteristic.value!, encoding: .utf8)
            
            GYZLog("接到服务端发送的数据：\(data!)")
            let result = JSON.init(parseJSON: data!)
            if result["msg_type"].stringValue == "bt_pair_re" && result["user_id"].stringValue == userDefaults.string(forKey: "phone") && !isRecevice{
                self.hud?.hide(animated: true)
                if result["ret"].intValue == 1{
                    isRecevice = true
                    userDefaults.set(result["device_id"].stringValue, forKey: "devId")
                    requestSaveWifiPwd()
                    requestUserDevice()
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: "蓝牙配网失败")
                }
            }
        }
    }
    
    //7.这个是接收蓝牙通知，很少用。读取外设数据主要用上面那个方法didUpdateValueForCharacteristic。
    //接收characteristic信息
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        GYZLog("接收characteristic信息")
    }
    //写入成功协议
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        if error == nil {
            GYZLog("写入成功")
            self.hud?.hide(animated: true)
            createHUD(message: "等待接收数据...")
        }
    }
}
