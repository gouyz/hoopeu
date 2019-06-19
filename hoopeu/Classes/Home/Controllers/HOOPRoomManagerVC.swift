//
//  HOOPRoomManagerVC.swift
//  hoopeu
//  房间管理
//  Created by gouyz on 2019/2/21.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

private let roomManagerCell = "roomManagerCell"

class HOOPRoomManagerVC: GYZBaseVC {
    
    var dataList: [HOOPRoomModel] = [HOOPRoomModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "房间管理"
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
        requestRoomList()
        mqttSetting()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var tableView : UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.separatorColor = kGrayLineColor
        table.backgroundColor = kBackgroundColor
        
        table.register(HOOPDeviceManagerCell.self, forCellReuseIdentifier: roomManagerCell)
        
        return table
    }()
    
    /// 添加按钮
    lazy var addBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kWhiteColor
        btn.setTitle("添加房间", for: .normal)
        btn.setTitleColor(kBlueFontColor, for: .normal)
        btn.titleLabel?.font = k15Font
        
        btn.addTarget(self, action: #selector(clickedAddBtn), for: .touchUpInside)
        
        return btn
    }()
    
    /// 添加房间
    @objc func clickedAddBtn(){
        let vc = HOOPAddRoomVC()
        vc.resultBlock = {[weak self] () in
            userDefaults.set(true, forKey: "isAddRoom")
            self?.requestRoomList()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///获取房间数据
    func requestRoomList(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        showLoadingView()
        
        GYZNetWork.requestNetwork("room/deviceRoomList",parameters: nil,method :.get,  success: { (response) in
            
            weakSelf?.hiddenLoadingView()
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let data = response["data"].array else { return }
                
                weakSelf?.dataList.removeAll()
                for item in data{
                    guard let itemInfo = item.dictionaryObject else { return }
                    let model = HOOPRoomModel.init(dict: itemInfo)
                    
                    weakSelf?.dataList.append(model)
                }
                
                weakSelf?.tableView.reloadData()
                if weakSelf?.dataList.count > 0{
                    weakSelf?.hiddenEmptyView()
                }else{
                    ///显示空页面
                    weakSelf?.showEmptyView(content:"暂无房间")
                    weakSelf?.view.bringSubviewToFront((weakSelf?.addBtn)!)
                }
                
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            
            weakSelf?.hiddenLoadingView()
            GYZLog(error)
            
            //第一次加载失败，显示加载错误页面
            weakSelf?.showEmptyView(content: "加载失败，请点击重新加载", reload: {
                weakSelf?.hiddenEmptyView()
                weakSelf?.requestRoomList()
            })
            weakSelf?.view.bringSubviewToFront((weakSelf?.addBtn)!)
        })
    }
    /// 删除
    func deleteDevice(indexRow: Int){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "是否删除该房间及其设备?", cancleTitle: "取消", viewController: self, buttonTitles: "确定") { (index) in
            
            if index != cancelIndex{
                weakSelf?.sendSDelRoomMqttCmd(row: indexRow)
            }
        }
    }
    /// mqtt发布主题 删除房间
    func sendSDelRoomMqttCmd(row: Int){
        createHUD(message: "加载中...")
        let model = dataList[row]
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","phone":userDefaults.string(forKey: "phone") ?? "","room_id":Int.init(model.roomId!)!,"msg_type":"app_room_del","app_interface_tag":""]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// 重载CocoaMQTTDelegate
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
            
            if type == "app_room_del_re" && phone == userDefaults.string(forKey: "phone"){
                self.hud?.hide(animated: true)
                if result["code"].intValue == kQuestSuccessTag{
                    requestRoomList()
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                }
            }
            
        }
    }
}

extension HOOPRoomManagerVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: roomManagerCell) as! HOOPDeviceManagerCell
        let model = dataList[indexPath.row]
        cell.nameLab.text = model.roomName
        
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
        let model = dataList[indexPath.row]
        if model.roomId == "1" || model.roomId == "2" || model.roomId == "3" || model.roomId == "4" {//不能左滑
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "删除") { [weak self] (action, index) in
            self?.deleteDevice(indexRow: index.row)
        }
        deleteAction.backgroundColor = kRedFontColor
        
        return [deleteAction]
    }
}
