//
//  HOOPDeviceInfoVC.swift
//  hoopeu
//  设备信息
//  Created by gouyz on 2019/2/21.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

private let deviceInfoCell = "deviceInfoCell"

class HOOPDeviceInfoVC: GYZBaseVC {


    let titleArray = ["设备名称", "产品序列号", "Mac地址", "IP地址", "局域网IP", "系统版本"]
    var deviceId: String = ""
    var deviceName: String = ""
    var deviceInfoModel: HOOPDeviceInfoModel?
    var infoArray: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "设备信息"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        mqttSetting()
    }
    lazy var tableView : UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = kWhiteColor
        
        table.register(GYZCommonArrowCell.self, forCellReuseIdentifier: deviceInfoCell)
        
        return table
    }()
    func dealData(){
        infoArray.append(deviceName)
        infoArray.append((deviceInfoModel?.serialno)!)
        infoArray.append((deviceInfoModel?.mac)!)
        infoArray.append((deviceInfoModel?.ip)!)
        infoArray.append((deviceInfoModel?.local_ip)!)
        infoArray.append((deviceInfoModel?.sys_version)!)
        tableView.reloadData()
    }
    /// mqtt发布主题 查询设备在线状态
    func sendMqttCmd(){
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["device_id":deviceId,"user_id":userDefaults.string(forKey: "phone") ?? "","msg_type":"get_dev_info","app_interface_tag":"ok"]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// 重载CocoaMQTTDelegate
    override func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        super.mqtt(mqtt, didStateChangeTo: state)
        if state == .connected {
            sendMqttCmd()
        }
    }
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
            let type = result["msg_type"].stringValue
            if let tag = result["app_interface_tag"].string{
                if tag.hasPrefix("system_"){
                    return
                }
            }
            
            if type == "get_dev_info_re"{
                hud?.hide(animated: true)
                guard let data = result["msg"].dictionaryObject else { return }
                deviceInfoModel = HOOPDeviceInfoModel.init(dict: data)
                dealData()
            }
            
        }
    }
}

extension HOOPDeviceInfoVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: deviceInfoCell) as! GYZCommonArrowCell
        
        cell.nameLab.text = titleArray[indexPath.row]
        if infoArray.count > 0 {
            cell.contentLab.text = infoArray[indexPath.row]
        }
        
        cell.rightIconView.isHidden = true
        
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        return UIView()
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView()
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
