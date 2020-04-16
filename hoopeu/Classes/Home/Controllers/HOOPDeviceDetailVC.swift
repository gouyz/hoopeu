//
//  HOOPDeviceDetailVC.swift
//  hoopeu
//  叮当宝贝详情
//  Created by gouyz on 2019/2/21.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

private let deviceDetailCell = "deviceDetailCell"

class HOOPDeviceDetailVC: GYZBaseVC {
    
    /// 选择结果回调
    var resultBlock:(() -> Void)?
    /// 设备model
    var deviceModel: HOOPDeviceModel?
    let titleArray = ["设备名称", "房间选择", "设备信息", "重新配网", "解绑设备", "恢复出厂设置", "系统升级"]
    var roomList: [HOOPRoomModel] = [HOOPRoomModel]()
    var roomNameList: [String] = [String]()
    var deviceStatus: String = "不在线"
    /// 当前系统版本
    var currSystemVersion: String = ""
    /// 最新系统版本model
    var newSystemVersionModel: HOOPVersionModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = deviceModel != nil ? deviceModel?.deviceName : ""
        
        view.addSubview(addBtn)
        view.addSubview(tableView)
        addBtn.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(view)
            make.height.equalTo(kBottomTabbarHeight)
        }
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.bottom.equalTo(addBtn.snp.top)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view)
            }else{
                make.top.equalTo(kTitleAndStateHeight)
            }
        }
        if deviceModel?.deviceId == userDefaults.string(forKey: "devId") {
            addBtn.setTitle("使用中", for: .normal)
        }
        requestRoomList()
        mqttSetting()
    }
    lazy var tableView : UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = kWhiteColor
        
        table.register(GYZCommonArrowCell.self, forCellReuseIdentifier: deviceDetailCell)
        
        return table
    }()
    /// 添加按钮
    lazy var addBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("切换并使用", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        
        btn.addTarget(self, action: #selector(clickedAddBtn), for: .touchUpInside)
        
        return btn
    }()
    override func clickedBackBtn() {
        if resultBlock != nil {
            resultBlock!()
        }
        super.clickedBackBtn()
    }
    /// 添加叮当宝贝
    @objc func clickedAddBtn(){
        if deviceModel?.deviceId == userDefaults.string(forKey: "devId") {
            MBProgressHUD.showAutoDismissHUD(message: "正在使用中...")
            return
        }
        if deviceModel?.onLine == "1" {
            weak var weakSelf = self
            GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "确定要切换小叮当吗", cancleTitle: "取消", viewController: self, buttonTitles: "确定") { (index) in
                
                if index != cancelIndex{
                    weakSelf?.requestUserDevice()
//                    weakSelf?.goHomeVC()
                }
            }
            
        }else{
            goResetNetWorkVC()
        }
    }
    /// 配网成功调用
    func requestUserDevice(){
        if !GYZTool.checkNetWork() {
            return
        }
        weak var weakSelf = self
        GYZNetWork.requestNetwork("userDevice", parameters: ["devId":(deviceModel?.deviceId)!],  success: { (response) in
            
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                userDefaults.set((weakSelf?.deviceModel?.deviceId)!, forKey: "devId")
                weakSelf?.goHomeVC()
            }
            
        }, failture: { (error) in
            GYZLog(error)
        })
    }
    func goHomeVC(){
        let menuContrainer = FWSideMenuContainerViewController.container(centerViewController: GYZMainTabBarVC(), centerLeftPanViewWidth: 20, centerRightPanViewWidth: 20, leftMenuViewController: HOOPLeftMenuVC(), rightMenuViewController: nil)
        menuContrainer.leftMenuWidth = kLeftMenuWidth
        
        KeyWindow.rootViewController = menuContrainer
    }
    /// 设备名称
    func goDeviceNameVC(){
        let vc = HOOPModifyDeviceNameVC()
        vc.deviceModel = deviceModel
        vc.resultBlock = {[weak self] (name) in
            self?.deviceModel?.deviceName = name
            self?.navigationItem.title = name
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 选择房间
    func selectRoom(){
        if roomList.count == 0 {
            return
        }
        UsefulPickerView.showSingleColPicker("选择房间", data: roomNameList, defaultSelectedIndex: nil) {[weak self] (index, value) in
            let model = self?.roomList[index]
            self?.deviceModel?.roomName = model?.roomName
            self?.deviceModel?.roomId = model?.roomId
            
            self?.requestSaveRoom()
            self?.tableView.reloadData()
        }
    }
    /// 设备信息
    func goDeviceInfoVC(){
        let vc = HOOPDeviceInfoVC()
        vc.deviceId = (deviceModel?.deviceId)!
        vc.deviceName = (deviceModel?.deviceName)!
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 解绑设备
    func goUnbindVC(){
        let vc = HOOPUnBindDeviceVC()
        vc.deviceId = (deviceModel?.deviceId)!
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 重新配网
    func goResetNetWorkVC(){
//        let vc = HOOPLinkPowerVC()
        let vc = HOOPBlueToothContentVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    // 恢复出厂设置
    func showResetting(){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "即将恢复出厂设置", cancleTitle: "取消", viewController: self, buttonTitles: "确认") { (index) in
            
            if index != cancelIndex{
                weakSelf?.sendMqttCmd()
            }
        }
        
    }
    // 系统升级
    func showSystemVersion(){
        if newSystemVersionModel != nil && newSystemVersionModel?.versionName != currSystemVersion {
            weak var weakSelf = self
            GYZAlertViewTools.alertViewTools.showAlert(title: "系统升级", message: newSystemVersionModel?.updateMessage, cancleTitle: "取消", viewController: self, buttonTitles: "确认") { (index) in
                
                if index != cancelIndex{
                    weakSelf?.sendMqttCmdUpdateVerison()
                }
            }
        }else{
            GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "当前已是最新版本", cancleTitle: nil, viewController: self, buttonTitles: "我知道了") { (index) in
                
            }
        }
        
    }
    ///获取设备版本信息
    func requestDeviceVersion(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("appVersion",parameters: nil,method:.get,  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let data = response["data"].dictionaryObject else { return }
                
                weakSelf?.newSystemVersionModel = HOOPVersionModel.init(dict: data)
                weakSelf?.tableView.reloadData()
                
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    
    ///获取房间数据
    func requestRoomList(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("room/drList",parameters: ["deviceId": (deviceModel?.deviceId)!],  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let data = response["data"].array else { return }
                
                weakSelf?.roomList.removeAll()
                weakSelf?.roomNameList.removeAll()
                for item in data{
                    guard let itemInfo = item.dictionaryObject else { return }
                    let model = HOOPRoomModel.init(dict: itemInfo)
                    
                    weakSelf?.roomList.append(model)
                    weakSelf?.roomNameList.append(model.roomName!)
                }
                
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    
    ///保存房间数据
    func requestSaveRoom(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("room/insertDeviceRoom",parameters: ["deviceId": (deviceModel?.deviceId)!,"roomId":(deviceModel?.roomId)!],  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                userDefaults.set((weakSelf?.deviceModel?.roomId)!, forKey: "roomId")
                MBProgressHUD.showAutoDismissHUD(message: "保存成功")
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    
    /// mqtt发布主题 恢复出厂设置
    func sendMqttCmd(){
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["device_id":(deviceModel?.deviceId)!,"phone":userDefaults.string(forKey: "phone") ?? "","token":userDefaults.string(forKey: "token") ?? "","msg_type":"app_factory_reset","app_interface_tag":""]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// mqtt发布主题 系统更新检测
    func sendMqttCmdVerison(){
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["device_id":(deviceModel?.deviceId)!,"user_id":userDefaults.string(forKey: "phone") ?? "","msg_type":"get_dev_info","app_interface_tag":(deviceModel?.deviceId)!]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// mqtt发布主题 系统更新
    func sendMqttCmdUpdateVerison(){
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["device_id":(deviceModel?.deviceId)!,"user_id":userDefaults.string(forKey: "phone") ?? "","msg_type":"send_sys_update","app_interface_tag":"ok"]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// mqtt发布主题 打开设备蓝牙
    func sendMqttCmdBle(){
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["device_id":(deviceModel?.deviceId)!,"user_id":userDefaults.string(forKey: "phone") ?? "","msg_type":"bt_open","app_interface_tag":""]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// 重载CocoaMQTTDelegate
    override func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        super.mqtt(mqtt, didStateChangeTo: state)
        if state == .connected {
            sendMqttCmdVerison()
        }
    }
    override func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        super.mqtt(mqtt, didConnectAck: ack)
        if ack == .accept {
            mqtt.subscribe("hoopeu_app", qos: CocoaMQTTQOS.qos1)
            mqtt.subscribe("api_receive", qos: CocoaMQTTQOS.qos1)
        }
    }
    override func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        super.mqtt(mqtt, didReceiveMessage: message, id: id)
        
        if let data = message.string {
            let result = JSON.init(parseJSON: data)
            let type = result["msg_type"].stringValue
            if let tag = result["app_interface_tag"].string{
                if tag.hasPrefix("system_"){
                    return
                }
            }
            
            if type == "app_factory_reset_re" && result["phone"].stringValue == userDefaults.string(forKey: "phone"){
                hud?.hide(animated: true)
                MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                
            }else if type == "get_dev_info_re" && result["app_interface_tag"].stringValue == deviceModel?.deviceId{
                hud?.hide(animated: true)
                currSystemVersion = result["msg"]["sys_version"].stringValue
                requestDeviceVersion()
            }else if type == "send_sys_update_re"{
                hud?.hide(animated: true)
                if result["ret"].intValue == 1{
                    MBProgressHUD.showAutoDismissHUD(message: "发送成功")
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: "发送失败")
                }
            }else if type == "bt_open_re" && result["user_id"].stringValue == userDefaults.string(forKey: "phone"){
                hud?.hide(animated: true)
                
                if result["ret"].intValue == 1{
                    goResetNetWorkVC()
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: "请先打开设备蓝牙，然后进行重新配网")
                }
                
            }
            
        }
    }
}

extension HOOPDeviceDetailVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: deviceDetailCell) as! GYZCommonArrowCell
        
        cell.nameLab.text = titleArray[indexPath.row]
        
        cell.contentLab.isHidden = true
        cell.nameLab.snp.updateConstraints { (make) in
            make.width.equalTo(120)
            make.height.equalTo(kTitleHeight)
        }
        
        if indexPath.row == 0 {
            cell.contentLab.isHidden = false
            cell.contentLab.text = deviceModel != nil ? deviceModel?.deviceName : ""
        }else if indexPath.row == 1{
            cell.contentLab.isHidden = false
            cell.contentLab.text = deviceModel != nil ? deviceModel?.roomName : ""
        }else if indexPath.row == titleArray.count - 1 {
            if newSystemVersionModel != nil && newSystemVersionModel?.versionName != currSystemVersion{
                cell.nameLab.badgeView.style = .normal
                cell.nameLab.showBadge(animated: false)
            }
            cell.nameLab.snp.updateConstraints { (make) in
                make.width.equalTo(70)
                make.height.equalTo(30)
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        return UIView()
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:/// 设备名称
            goDeviceNameVC()
        case 1:/// 房间选择
            selectRoom()
        case 2:/// 设备信息
            goDeviceInfoVC()
        case 3:/// 重新配网
            sendMqttCmdBle()
        case 4:/// 解绑设备
            goUnbindVC()
        case 5:/// 恢复出厂设置
            showResetting()
        case 6:/// 系统升级
            showSystemVersion()
        default:
            break
        }
    }
    ///MARK : UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
}
