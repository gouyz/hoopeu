//
//  HOOPSeeSettingVC.swift
//  hoopeu
//  监控设置
//  Created by gouyz on 2019/5/22.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import CocoaMQTT
import MBProgressHUD
import SwiftyJSON

private let seeSettingCell = "seeSettingCell"
private let seeSettingSwitchCell = "seeSettingSwitchCell"

class HOOPSeeSettingVC: GYZBaseVC {
    
    let titleArr: [String] = ["重新连接","移动侦测录像","24小时录像","格式化SD卡","仅WIFI状态下观看","摄像机开关"]
    /// 移动侦测开关
    var zhenCeStatus: Bool = true
    /// 24小时录像开关
    var luxiangStatus: Bool = false
    /// wifi开关
    var wifiStatus: Bool = false
    /// 摄像机开关
    var carmanStatus: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "监控设置"
        
        zhenCeStatus = userDefaults.bool(forKey: "zhenCeStatus")
        luxiangStatus = userDefaults.bool(forKey: "luxiangStatus")
        wifiStatus = userDefaults.bool(forKey: "wifiStatus")
        carmanStatus = userDefaults.bool(forKey: "carmanStatus")
        
        mqttSetting()
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
    

    lazy var tableView : UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = kWhiteColor
        
        table.register(GYZCommonSwitchCell.self, forCellReuseIdentifier: seeSettingSwitchCell)
        table.register(GYZLabArrowCell.self, forCellReuseIdentifier: seeSettingCell)
        
        return table
    }()
    
    /// 开关状态
    @objc func onSwitchViewChange(sender: UISwitch){
        let row = sender.tag
        switch row {
        case 1: /// 移动侦测开关
            zhenCeStatus = sender.isOn
            sendMqttCmdStatus()
        case 2:/// 24小时录像开关
            luxiangStatus = sender.isOn
            if luxiangStatus{
                startOrEndPlayer(order: "camera_start_record")
            }else{
                startOrEndPlayer(order: "camera_stop_record")
            }
        case 4:/// wifi开关
            wifiStatus = sender.isOn
            userDefaults.set(wifiStatus, forKey: "wifiStatus")
        case 5:/// 摄像机开关
            carmanStatus = sender.isOn
            if carmanStatus{
                startOrEndPlayer(order: "camera_startup")
            }else{
                startOrEndPlayer(order: "camera_close")
            }
        default:
            break
        }
    }
    // 移动侦测开关
    func sendMqttCmdStatus(){
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["device_id":userDefaults.string(forKey: "devId") ?? "","msg_type":"motion_detect_switch","user_id":userDefaults.string(forKey: "phone") ?? "","msg":["state":zhenCeStatus],"app_interface_tag":""]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    // 摄像机开关
    func startOrEndPlayer(order: String){
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["device_id":userDefaults.string(forKey: "devId") ?? "","msg_type":"camera_order","user_id":userDefaults.string(forKey: "phone") ?? "","msg":["order":order],"app_interface_tag":""]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// 格式化
    func clearSDcard(){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "确定要格式化SD卡吗?", cancleTitle: "取消", viewController: self, buttonTitles: "确定") { (index) in
            
            if index != cancelIndex{
                weakSelf?.startOrEndPlayer(order: "camera_format_sdcard")
            }
        }
    }
    
    /// 重载CocoaMQTTDelegate
    override func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        super.mqtt(mqtt, didConnectAck: ack)
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
            
            if type == "motion_detect_switch_re" && phone == userDefaults.string(forKey: "phone"){
                hud?.hide(animated: true)
                if result["ret"].intValue == 1{
                    MBProgressHUD.showAutoDismissHUD(message: "移动侦测修改成功")
                    userDefaults.set(zhenCeStatus, forKey: "zhenCeStatus")
                }else {
                    MBProgressHUD.showAutoDismissHUD(message: "移动侦测修改失败")
                }
            }else if type == "camera_order_re" && phone == userDefaults.string(forKey: "phone"){
                hud?.hide(animated: true)
                if result["ret"].intValue == 1{
                    
                    var msg = ""
                    if result["order"].stringValue == "camera_format_sdcard"{
                        msg = "格式化成功"
                    }else if result["order"].stringValue == "camera_startup"{
                        msg = "摄像机开启成功"
                        userDefaults.set(true, forKey: "carmanStatus")
                    }else if result["order"].stringValue == "camera_close"{
                        msg = "摄像机关闭成功"
                        userDefaults.set(false, forKey: "carmanStatus")
                    }else if result["order"].stringValue == "camera_restart_push"{
                        msg = "重新连接成功"
                    }else if result["order"].stringValue == "camera_start_record"{
                        msg = "24小时录像开启成功"
                        userDefaults.set(true, forKey: "luxiangStatus")
                    }else if result["order"].stringValue == "camera_stop_record"{
                        msg = "24小时录像关闭成功"
                        userDefaults.set(false, forKey: "luxiangStatus")
                    }
                    MBProgressHUD.showAutoDismissHUD(message: msg)
                }else {
                    MBProgressHUD.showAutoDismissHUD(message: "修改失败")
                }
            }
            
        }
    }
}
extension HOOPSeeSettingVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return titleArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 || indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: seeSettingCell) as! GYZLabArrowCell
            cell.nameLab.text = titleArr[indexPath.row]
            
            cell.selectionStyle = .none
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: seeSettingSwitchCell) as! GYZCommonSwitchCell
            cell.nameLab.text = titleArr[indexPath.row]
            cell.switchView.tag = indexPath.row
            cell.switchView.addTarget(self, action: #selector(onSwitchViewChange(sender:)), for: .valueChanged)
            
            switch indexPath.row {
            case 1:
                cell.switchView.isOn = zhenCeStatus
            case 2:
                cell.switchView.isOn = luxiangStatus
            case 4:
                cell.switchView.isOn = wifiStatus
            case 5:
                cell.switchView.isOn = carmanStatus
            default:
                break
            }
            
            cell.selectionStyle = .none
            return cell
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        return UIView()
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {// 重新连接
            startOrEndPlayer(order: "camera_restart_push")
        }else if indexPath.row == 3 {// 格式化
            clearSDcard()
        }
    }
    ///MARK : UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
}
