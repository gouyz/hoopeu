//
//  HOOPRoomDeviceVC.swift
//  hoopeu
//  房间设备
//  Created by gouyz on 2019/2/26.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON
import AudioToolbox

private let roomDeviceCell = "roomDeviceCell"

class HOOPRoomDeviceVC: GYZBaseVC {
    /// 是否有网络
    var isNetWork: Bool = false
    var roomId: String = ""
    var dataModel: HOOPRoomDeviceModel?

    var titleArray = ["小夜灯", "防盗报警", "爱心看护"]
    var iconArray = ["icon_home_xiaoyedeng", "icon_home_warn", "icon_home_aixinkanhu"]
    /// 小夜灯开关状态
    var lightState: String = "on"
    /// 安防开关状态
    var guardState: String = "on"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(addBtn)
        view.addSubview(tableView)
        addBtn.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.bottom.equalTo(-(kScreenWidth * 0.34 - kStateHeight))
            make.height.equalTo(kBottomTabbarHeight)
        }
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.bottom.equalTo(addBtn.snp.top).offset(-kMargin)
            make.top.equalTo(view)
//            if #available(iOS 11.0, *) {
//                make.top.equalTo(view)
//            }else{
//                make.top.equalTo(kTitleAndStateHeight)
//            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if mqtt == nil {
            mqttSetting()
        }else {
            if self.mqtt?.connState == CocoaMQTTConnState.disconnected{
                self.mqtt?.connect()
            }else{
                sendMqttCmd()
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if mqtt == nil {
            mqttSetting()
        }else {
            if self.mqtt?.connState == CocoaMQTTConnState.disconnected{
                self.mqtt?.connect()
            }
        }
    }
    lazy var tableView : UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.separatorColor = kGrayLineColor
        table.backgroundColor = kBackgroundColor
        
        table.register(HOOPRoomDeviceCell.self, forCellReuseIdentifier: roomDeviceCell)
        weak var weakSelf = self
        ///添加下拉刷新
        GYZTool.addPullRefresh(scorllView: table, pullRefreshCallBack: {
            weakSelf?.refresh()
        })
        
        return table
    }()
    
    /// 添加按钮
    lazy var addBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("添加智能设备", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = 10
        
        btn.addTarget(self, action: #selector(clickedAddBtn), for: .touchUpInside)
        
        return btn
    }()
    
    /// 添加智能设备
    @objc func clickedAddBtn(){
        GYZAlertViewTools.alertViewTools.showSheet(title: nil, message: nil, cancleTitle: "取消", titleArray: ["家电遥控","智能开关","射频遥控","传感设备"], viewController: self) { [weak self](index) in
            
            if index == 0{//家电遥控
                self?.goJiaDianVC()
            }else if index == 1{//智能开关
                self?.goSwitchVC()
            }else if index == 2{//射频遥控
                self?.goShePinVC()
            }else if index == 3{//传感设备
                self?.goChuanGanVC()
            }
        }
    }
    
    /// 家电遥控
    func goJiaDianVC(){
        let vc = HOOPSelectControlVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 射频遥控
    func goShePinVC(){
        let vc = HOOPShePinControlVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 传感设备
    func goChuanGanVC(){
        let vc = HOOPChuanGanListVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 智能开关
    func goSwitchVC(){
        let vc = HOOPSwitchVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 设置
    func settingVC(indexRow: Int ){
        if indexRow == 0 {/// 小夜灯设置
            let vc = HOOPNightLightVC()
            navigationController?.pushViewController(vc, animated: true)
        }else if indexRow == 1{
            let vc = HOOPWarnSettingVC()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    /// 报警日志
    func goWarnLogVC(){
        let vc = HOOPWarnLogVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 删除
    func deleteDevice(indexRow: Int,section: Int){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "确定要删除此设备吗?", cancleTitle: "取消", viewController: self, buttonTitles: "确定") { (index) in
            
            if index != cancelIndex{
                if weakSelf?.dataModel?.exist == "1" {
                    if section == 1{// 开关
                        weakSelf?.sendSDelOnOffMqttCmd(row: indexRow)
                    }else if section == 2{
                        let model = weakSelf?.dataModel?.intelligentDeviceList[indexRow]
                        
                        if model?.type == "pt2262"{/// 射频遥控删除
                            weakSelf?.sendSDelShePinMqttCmd(sId: (model?.id)!)
                        }
                    }else if section == 3{
                        let model = weakSelf?.dataModel?.sensorList[indexRow]
                        
                        /// 传感器删除
                        weakSelf?.sendSDelSensorMqttCmd(sId: (model?.sensor_id)!)
                    }
                }else{
                    if section == 0{// 开关
                        weakSelf?.sendSDelOnOffMqttCmd(row: indexRow)
                    }else if section == 1{
                        let model = weakSelf?.dataModel?.intelligentDeviceList[indexRow]
                        if model?.type == "pt2262"{/// 射频遥控删除
                            weakSelf?.sendSDelShePinMqttCmd(sId: (model?.id)!)
                        }
                    }else if section == 2{
                        let model = weakSelf?.dataModel?.sensorList[indexRow]
                        
                        /// 传感器删除
                        weakSelf?.sendSDelSensorMqttCmd(sId: (model?.sensor_id)!)
                    }
                }
            }
        }
    }
    
    /// 遥控器跳转
    func goIRControlVC(model:HOOPRoomIntelligentDeviceModel ){
        switch model.type_lower! {
        case "ir_air":// 空调
            goArcControllVC(arcId: model.id!)
        default:
            break
        }
    }
    
    /// 空调遥控
    func goArcControllVC(arcId: String){
        let vc = HOOPARCControlVC()
        vc.controlId = arcId
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 爱心看护
    func goSeeVC(){
        if userDefaults.bool(forKey: "wifiStatus") {
            if !(networkManager?.isReachableOnEthernetOrWiFi)!{
                MBProgressHUD.showAutoDismissHUD(message: "您设置了只在WiFi下观看，请连接WiFi")
                return
            }
        }
        let vc = HOOPPlayerDetailVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 自定义遥控器
    func goControlVC(deviceControlId: String, type: String){
        let vc = HOOPCustomControlVC()
        vc.controlId = deviceControlId
        vc.controlType = type
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 开关状态
    @objc func onSwitchViewChange(sender: UISwitch){
        let row = sender.tag
        let section = Int(sender.accessibilityIdentifier!)
        //默认震动效果
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)

        if dataModel?.exist == "1" {
            if section == 0{
                if row == 0{//小夜灯
                    lightState = sender.isOn ? "on" : "off"
                    sendLightMqttCmd()
                }else if row == 1{//安防
                    guardState = sender.isOn ? "on" : "off"
//                    if guardState == "off"{
//                        guardState = "on"
//                    }else{
//                        sendGuardMqttCmd()
//                    }
                    sendGuardMqttCmd()
                }
            }else if section == 1{// 开关
                sendOnOffMqttCmd(row: row, state: sender.isOn ? "on" : "off")
            }else if section == 3{
                let model = dataModel?.sensorList[row]
                /// 传感器控制开关
                sendOnOffSensorMqttCmd(sId: (model?.sensor_id)!,state: sender.isOn)
            }
        }else{
            if section == 0{// 开关
                sendOnOffMqttCmd(row: row, state: sender.isOn ? "on" : "off")
            }else if section == 2{
                let model = dataModel?.sensorList[row]
                
                /// 传感器控制开关
                sendOnOffSensorMqttCmd(sId: (model?.sensor_id)!,state: sender.isOn)
            }
        }
    }
    // MARK: - 上拉加载更多/下拉刷新
    /// 下拉刷新
    func refresh(){
        if self.mqtt?.connState == CocoaMQTTConnState.disconnected{
            self.mqtt?.connect()
        }else{
            sendMqttCmd()
        }
    }
    /// 关闭上拉/下拉刷新
    func closeRefresh(){
        if tableView.mj_header.isRefreshing{//下拉刷新
            GYZTool.endRefresh(scorllView: tableView)
        }
    }
    /// mqtt发布主题
    func sendMqttCmd(){
//        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","phone":userDefaults.string(forKey: "phone") ?? "","room_id":roomId,"msg_type":"app_room_devices","app_interface_tag":roomId]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// mqtt发布主题 小夜灯开闭夜灯
    func sendLightMqttCmd(){
        //        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["device_id":userDefaults.string(forKey: "devId") ?? "","user_id":userDefaults.string(forKey: "phone") ?? "","msg":["light_state":lightState],"msg_type":"ni_light_ctrl","app_interface_tag":""]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// mqtt发布主题 安防控制-开闭安防状态
    func sendGuardMqttCmd(){
        //        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["device_id":userDefaults.string(forKey: "devId") ?? "","user_id":userDefaults.string(forKey: "phone") ?? "","msg":["guard_state":guardState],"msg_type":"guard_ctrl","app_interface_tag":""]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    
    /// mqtt发布主题 开闭灯
    func sendOnOffMqttCmd(row: Int,state: String){
        //        createHUD(message: "加载中...")
        let model = dataModel?.switchList[row]
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","phone":userDefaults.string(forKey: "phone") ?? "","ctrl_dev_id":(model?.switch_id)!,"serial_id":(model?.serial_id)!,"status":state,"msg_type":"app_switch_ctrl","app_interface_tag":""]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// mqtt发布主题 删除灯
    func sendSDelOnOffMqttCmd(row: Int){
        //        createHUD(message: "加载中...")
        let model = dataModel?.switchList[row]
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","phone":userDefaults.string(forKey: "phone") ?? "","ctrl_dev_id":(model?.switch_id)!,"func_id":(model?.serial_id)!,"msg_type":"app_switch_del","app_interface_tag":""]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// mqtt发布主题 删除传感器
    func sendSDelSensorMqttCmd(sId: String){
        //        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","phone":userDefaults.string(forKey: "phone") ?? "","ctrl_dev_id":sId,"msg_type":"app_sensor_del","app_interface_tag":""]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// mqtt发布主题 开关传感器
    func sendOnOffSensorMqttCmd(sId: String,state:Bool){
        //        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","phone":userDefaults.string(forKey: "phone") ?? "","ctrl_dev_id":sId,"msg_type":"app_sensor_ctrl","ctrl_state":state,"app_interface_tag":""]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    
    /// mqtt发布主题 删除射频遥控器
    func sendSDelShePinMqttCmd(sId: String){
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","ctrl_dev_id":sId,"phone":userDefaults.string(forKey: "phone") ?? "","msg_type":"app_pt2262_del","app_interface_tag":""]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    
    /// 检测网络信息查询
    func sendMqttCheckOnlineCmd(){
        let paramDic:[String:Any] = ["device_id":userDefaults.string(forKey: "devId") ?? "","user_id":userDefaults.string(forKey: "phone") ?? "","msg_type":"query_online","app_interface_tag":"ok"]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// 连接电源
    func goLinkPower(){
        let vc = HOOPLinkPowerVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 配网提示
    func showNetWorkAlert(){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "当前设备网络异常，是否重新配网？", cancleTitle: "取消", viewController: self, buttonTitles: "去配网") { (index) in
            
            if index != cancelIndex{
                weakSelf?.goLinkPower()
            }
        }
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
                    if !self.isNetWork{// 没有网络，去配网
                        self.showNetWorkAlert()
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
    
    /// 重载CocoaMQTTDelegate
    override func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        GYZLog("new state: \(state)")
        if state == .connected {
            if !isNetWork{
                sendMqttCheckOnlineCmd()
                startSMSWithDuration(duration: 5)
            }
            sendMqttCmd()
            
        }
        else if state == .disconnected && self.mqtt != nil && !self.isUserDisConnect{//   断线重连
            self.mqtt = nil
            mqttSetting()
        }
    }
    override func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        super.mqtt(mqtt, didConnectAck: ack)
        GYZLog("new ack: \(ack)")
        if ack == .accept {
            mqtt.subscribe("api_receive", qos: CocoaMQTTQOS.qos1)
            mqtt.subscribe("hoopeu_app", qos: CocoaMQTTQOS.qos1)
        }
    }
    override func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        super.mqtt(mqtt, didReceiveMessage: message, id: id)
        
        if let data = message.string {
            let result = JSON.init(parseJSON: data)
//            let phone = result["phone"].stringValue
            let type = result["msg_type"].stringValue
            if let tag = result["app_interface_tag"].string{
                if tag.hasPrefix("system_"){
                    return
                }
            }
            
            if type == "app_room_devices_re" && result["phone"].stringValue == userDefaults.string(forKey: "phone") && result["app_interface_tag"].stringValue == roomId{
//                hud?.hide(animated: true)
                closeRefresh()
                if result["code"].intValue == kQuestSuccessTag{
                    self.isNetWork = true
                    guard let itemInfo = result["data"].dictionaryObject else { return }
                    
                    self.dataModel = HOOPRoomDeviceModel.init(dict: itemInfo)
                    self.tableView.reloadData()
                    if self.dataModel?.exist == "0" && self.dataModel?.switchList.count == 0 && self.dataModel?.intelligentDeviceList.count == 0 && self.dataModel?.sensorList.count == 0{
                        self.showEmptyView(content: "暂无设备信息,请点击刷新", reload: {
                            self.hiddenEmptyView()
                            self.refresh()
                        })
                        self.view.bringSubviewToFront(self.addBtn)
                    }else{
                        self.hiddenEmptyView()
                    }
                }else{
//                    MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                }
            }else if type == "ni_light_ctrl_re" && result["user_id"].stringValue == userDefaults.string(forKey: "phone"){
                //                hud?.hide(animated: true)
                if result["ret"].intValue == 1{
                    dataModel?.light = result["light_state"].stringValue == "on" ? "1":"0"
                    lightState = result["light_state"].stringValue
                    MBProgressHUD.showAutoDismissHUD(message: "设置成功")
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: "设置失败")
                }
                tableView.reloadData()
            }else if type == "guard_ctrl_re" && result["user_id"].stringValue == userDefaults.string(forKey: "phone"){
                //                hud?.hide(animated: true)
                if result["ret"].intValue == 1{
                    dataModel?.guard = result["guard_state"].stringValue == "on" ? "1":"0"
                    guardState = result["guard_state"].stringValue
                    MBProgressHUD.showAutoDismissHUD(message: "设置成功")
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: "请先处理警报")
                
                }
                self.tableView.reloadData()
            }else if type == "app_switch_ctrl_re" && result["phone"].stringValue == userDefaults.string(forKey: "phone"){
                //                hud?.hide(animated: true)
                if result["code"].intValue == kQuestSuccessTag{
                    MBProgressHUD.showAutoDismissHUD(message: "设置成功")
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: "设置失败")
                }
            }else if type == "app_switch_del_re" && result["phone"].stringValue == userDefaults.string(forKey: "phone"){// 删除开关
                //                hud?.hide(animated: true)
                if result["code"].intValue == kQuestSuccessTag{
                    MBProgressHUD.showAutoDismissHUD(message: "删除成功")
                    sendMqttCmd()
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: "删除失败")
                }
            }else if type == "app_sensor_ctrl_re" && result["phone"].stringValue == userDefaults.string(forKey: "phone"){
                //                hud?.hide(animated: true)
                if result["code"].intValue == kQuestSuccessTag{
                    MBProgressHUD.showAutoDismissHUD(message: "设置成功")
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: "设置失败")
                }
            }else if type == "app_sensor_del_re" && result["phone"].stringValue == userDefaults.string(forKey: "phone"){// 删除传感器
                //                hud?.hide(animated: true)
                if result["code"].intValue == kQuestSuccessTag{
                    MBProgressHUD.showAutoDismissHUD(message: "删除成功")
                    sendMqttCmd()
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: "删除失败")
                }
            }else if type == "app_pt2262_del_re" && result["phone"].stringValue == userDefaults.string(forKey: "phone"){
                if result["code"].intValue == kQuestSuccessTag{
                    MBProgressHUD.showAutoDismissHUD(message: "删除成功")
                    sendMqttCmd()
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: "删除失败")
                }
            }else if type == "device_state_report" && result["device_id"].stringValue == userDefaults.string(forKey: "devId") && result["user_id"].stringValue == userDefaults.string(forKey: "phone"){
                let msg = result["msg"]
                let devType = msg["dev_type"].stringValue
                if dataModel?.exist == "1"{
                    if devType == "light"{// 夜灯
                        dataModel?.light = msg["dev_state"].boolValue ? "1" : "0"
                    }else if devType == "guard"{// 安防
                        dataModel?.guard = msg["dev_state"].boolValue ? "1" : "0"
                    }
                }
            
                if devType == "switch"{// 开关
                    let switchGroupId = msg["dev_id"].stringValue
                    let switchId = msg["func_id"].stringValue
                    for item in (dataModel?.switchList)!{
                        if item.switch_id == switchGroupId && item.serial_id == switchId{
                            item.state = msg["dev_state"].boolValue ? "on" : "off"
                            break
                        }
                    }
                }
                
                self.tableView.reloadData()
            }else if type == "query_online_re" && result["user_id"].stringValue == userDefaults.string(forKey: "phone"){
                self.isNetWork = true
            }
            
        }
    }
}

extension HOOPRoomDeviceVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if dataModel != nil {
            if dataModel?.exist == "1"{
                return 4
            }else{
                return 3
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if dataModel != nil {
            if dataModel?.exist == "1"{
                if section == 0{
                    return titleArray.count
                }else if section == 1{// 开关
                    return (dataModel?.switchList.count)!
                }else if section == 2{// 设备
                    return (dataModel?.intelligentDeviceList.count)!
                }else if section == 3{// 传感器设备
                    return (dataModel?.sensorList.count)!
                }
            }else {
                if section == 0{// 开关
                    return (dataModel?.switchList.count)!
                }else if section == 1{// 设备
                    return (dataModel?.intelligentDeviceList.count)!
                }else if section == 2{// 传感器设备
                    return (dataModel?.sensorList.count)!
                }
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: roomDeviceCell) as! HOOPRoomDeviceCell
        
        cell.switchView.isHidden = false
        
        if dataModel != nil {
            cell.switchView.tag = indexPath.row
            cell.switchView.accessibilityIdentifier = "\(indexPath.section)"
            cell.switchView.addTarget(self, action: #selector(onSwitchViewChange(sender:)), for: .valueChanged)
            if dataModel?.exist == "1"{
                if indexPath.section == 0{
                    cell.nameLab.text = titleArray[indexPath.row]
                    cell.iconView.image = UIImage.init(named: iconArray[indexPath.row])
                    if indexPath.row == 2{
                        cell.switchView.isHidden = true
                    }else if indexPath.row == 0{//小夜灯
                        cell.switchView.isOn = dataModel?.light == "1"
                    }else if indexPath.row == 1{//报警
                        cell.switchView.isOn = dataModel?.guard == "1"
                    }
                }else if indexPath.section == 1{// 开关
                    cell.nameLab.text = dataModel?.switchList[indexPath.row].switch_name
                    cell.switchView.isOn = dataModel?.switchList[indexPath.row].state == "on"
                    cell.iconView.image = UIImage.init(named: "icon_home_kaiguan")
                }else if indexPath.section == 2{// 设备
                    let model = dataModel?.intelligentDeviceList[indexPath.row]
                    cell.nameLab.text = model?.ctrl_name
                    var type = model?.type
                    if type == "ir"{
                        type = model?.type_lower
                    }
                    var name = HOMEDEVICEIMGNAME[type!]
                    if name == nil || (name?.isEmpty)!{
                        name = "icon_home_custom"
                    }
                    cell.iconView.image = UIImage.init(named: name!)
                    cell.switchView.isHidden = true
                }else if indexPath.section == 3{// 传感器设备
                    let model = dataModel?.sensorList[indexPath.row]
                    cell.nameLab.text = model?.sensor_name
                    
                    cell.iconView.image = UIImage.init(named: "icon_home_chuangan")
                    cell.switchView.isOn = model?.state == "1"
                }
            }else {
                if indexPath.section == 0{// 开关
                    cell.nameLab.text = dataModel?.switchList[indexPath.row].switch_name
                    cell.switchView.isOn = dataModel?.switchList[indexPath.row].state == "on"
                    cell.iconView.image = UIImage.init(named: "icon_home_kaiguan")
                }else if indexPath.section == 1{// 设备
                    let model = dataModel?.intelligentDeviceList[indexPath.row]
                    cell.nameLab.text = model?.ctrl_name
                    var type = model?.type
                    if type == "ir"{
                        type = model?.type_lower
                    }
                    var name = HOMEDEVICEIMGNAME[type!]
                    if name == nil || (name?.isEmpty)!{
                        name = "icon_home_custom"
                    }
                    cell.iconView.image = UIImage.init(named: name!)
                    cell.switchView.isHidden = true
                }else if indexPath.section == 2{// 传感器设备
                    let model = dataModel?.sensorList[indexPath.row]
                    cell.nameLab.text = model?.sensor_name
                    
                    cell.iconView.image = UIImage.init(named: "icon_home_chuangan")
                    cell.switchView.isOn = model?.state == "1"
                }
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
        if dataModel?.exist == "1"{
            if indexPath.section == 2{
                let model = dataModel?.intelligentDeviceList[indexPath.row]
                if model?.type == "pt2262" || model?.type == "other"{// 自定义遥控
                    goControlVC(deviceControlId: (model?.id)!,type: (model?.type)!)
                }else if model?.type == "ir"{// 家电遥控
                    
                    goIRControlVC(model: model!)
                }
            }else if indexPath.section == 0{
                if indexPath.row == 2{// 爱心看护
                    goSeeVC()
                }
            }
        }else{
            if indexPath.section == 1{
                let model = dataModel?.intelligentDeviceList[indexPath.row]
                if model?.type == "pt2262" || model?.type == "other"{// 自定义遥控
                    goControlVC(deviceControlId: (model?.id)!,type: (model?.type)!)
                }else if model?.type == "ir"{// 家电遥控
                    goIRControlVC(model: model!)
                }
            }
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
    /// 实现左滑
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if dataModel?.exist == "1" && indexPath.section == 0 && indexPath.row == 2 {//爱心看护不能左滑
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let settingAction = UITableViewRowAction(style: .normal, title: "设置") {[weak self] (action, index) in
            
            self?.settingVC(indexRow: index.row)
        }
        settingAction.backgroundColor = kBtnClickBGColor
        
        let logAction = UITableViewRowAction(style: .normal, title: "日志") { [weak self] (action, index) in
            self?.goWarnLogVC()
        }
        logAction.backgroundColor = kYellowFontColor
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "删除") { [weak self] (action, index) in
            self?.deleteDevice(indexRow: index.row,section: index.section)
        }
        deleteAction.backgroundColor = kRedFontColor
        
        if dataModel?.exist == "1"{
            if indexPath.section == 0{
                if indexPath.row == 0 {
                    return [settingAction]
                }else if indexPath.row == 1 {
                    return [logAction,settingAction]
                }
            }else if indexPath.section == 1{// 开关
                return [deleteAction]
            }else if indexPath.section == 2{// 设备
                let model = dataModel?.intelligentDeviceList[indexPath.row]
                
                if model?.type == "pt2262"{
                    return [deleteAction]
                }else {
                    return nil
                }
            }else if indexPath.section == 3{// 传感器
                return [deleteAction]
            }
        }else {
            if indexPath.section == 0{// 开关
                return [deleteAction]
            }else if indexPath.section == 1{// 设备
                let model = dataModel?.intelligentDeviceList[indexPath.row]
                
                if model?.type == "pt2262"{
                    return [deleteAction]
                }else {
                    return nil
                }
            }else if indexPath.section == 2{// 传感器
                return [deleteAction]
            }
        }
        return nil
    }
}

