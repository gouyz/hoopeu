//
//  HOOPSelectConditionVC.swift
//  hoopeu
//  新建条件场景 选择条件
//  Created by gouyz on 2019/2/25.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

private let selectConditionCell = "selectConditionCell"

class HOOPSelectConditionVC: GYZBaseVC {
    
    /// 选择结果回调
    var resultBlock:((_ doDic: [[String: Any]],_ ctrlIds: [String]) -> Void)?
    var dataList: [HOOPCtrlModel] = [HOOPCtrlModel]()
    var isSelectedList: [Bool] = [Bool]()
    var selectedIdList: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "添加条件"
        view.addSubview(finishedBtn)
        view.addSubview(tableView)
        finishedBtn.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(view)
            make.height.equalTo(kBottomTabbarHeight)
        }
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.bottom.equalTo(finishedBtn.snp.top)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view)
            }else{
                make.top.equalTo(kTitleAndStateHeight)
            }
        }
        
//        requestCtrlList()
        mqttSetting()
    }
    
    
    lazy var tableView : UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = kBackgroundColor
        
        table.register(HOOPSelectConditionCell.self, forCellReuseIdentifier: selectConditionCell)
        
        return table
    }()
    
    /// 完成按钮
    lazy var finishedBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("完成", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        
        btn.addTarget(self, action: #selector(clickedFinishedBtn), for: .touchUpInside)
        
        return btn
    }()
    
    /// 完成
    @objc func clickedFinishedBtn(){
        
        selectedIdList.removeAll()
        var selectArr: [[String: Any]] = [[String: Any]]()
        for (index,item) in isSelectedList.enumerated(){
            if item{
                let model = dataList[index]
                selectedIdList.append(model.sensorId!)
                let dic:[String: Any] = ["sensor_id":model.sensorId!,"sensor_name":model.sensorName!,"room_id":model.roomId!,"room_name":model.roomName!]
                selectArr.append(dic)
            }
        }
        if selectedIdList.count == 0 {
            MBProgressHUD.showAutoDismissHUD(message: "请选择传感器")
            return
        }
        
        if resultBlock != nil {
            resultBlock!(selectArr,selectedIdList)
        }
        clickedBackBtn()
    }
    
    func sendMqttCmd(){
        showLoadingView()
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","phone":userDefaults.string(forKey: "phone") ?? "","msg_type":"app_sensor_query","app_interface_tag":""]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    
    /// 重载CocoaMQTTDelegate
    override func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        GYZLog("new state: \(state)")
        if state == .connected {
            sendMqttCmd()
        }else if state == .disconnected && self.mqtt != nil{//   断线重连
            self.mqtt?.connect()
        }
    }
    override func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        super.mqtt(mqtt, didConnectAck: ack)
        if ack == .accept {
            mqtt.subscribe("api_receive", qos: CocoaMQTTQOS.qos1)
        }
    }
    override func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        super.mqtt(mqtt, didReceiveMessage: message, id: id)
        
        if let data = message.string {
            let result = JSON.init(parseJSON: data)
            let phone = result["phone"].stringValue
            let type = result["msg_type"].stringValue
            if let tag = result["app_interface_tag"].string{
                if tag.hasPrefix("system_"){
                    return
                }
            }
            self.hiddenLoadingView()
            if type == "app_sensor_query_re" && phone == userDefaults.string(forKey: "phone"){
                
                if result["code"].intValue == kQuestSuccessTag{//请求成功
                    
                    guard let data = result["data"].array else { return }
                    
                    self.dataList.removeAll()
                    for item in data{
                        guard let itemInfo = item.dictionaryObject else { return }
                        let model = HOOPCtrlModel.init(dict: itemInfo)
                        
                        self.dataList.append(model)
                        var isSelect: Bool = false
                        for strId in self.selectedIdList{
                            if strId == model.sensorId{
                                isSelect = true
                                break
                            }
                        }
                        self.isSelectedList.append(isSelect)
                    }
                    
                    self.tableView.reloadData()
                    if self.dataList.count > 0{
                        self.hiddenEmptyView()
                    }else{
                        ///显示空页面
                        self.showEmptyView(content:"暂无传感器")
                        self.view.bringSubviewToFront(self.finishedBtn)
                    }
                    
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                }
            }
        }
    }
}

extension HOOPSelectConditionVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: selectConditionCell) as! HOOPSelectConditionCell
        
        let model = dataList[indexPath.row]
        cell.nameLab.text = "*\(model.roomName!)*   " + model.sensorName!
        cell.nameLab.isHighlighted = isSelectedList[indexPath.row]
        
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
        
        isSelectedList[indexPath.row] = !isSelectedList[indexPath.row]
        self.tableView.reloadData()
    }
    ///MARK : UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
}
