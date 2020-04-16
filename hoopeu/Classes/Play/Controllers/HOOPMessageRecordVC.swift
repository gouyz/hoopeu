//
//  HOOPMessageRecordVC.swift
//  hoopeu
//  留言记录
//  Created by gouyz on 2019/3/27.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

private let messageRecordCell = "messageRecordCell"

class HOOPMessageRecordVC: GYZBaseVC {
    
    var dataList: [HOOPLeaveMessageModel] = [HOOPLeaveMessageModel]()
    /// 留言类型 1：app留言 2：设备留言 3: 收到的留言
    var messageType: String = "1"
    let recorderManager = RecordManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view)
            }else{
                make.top.equalTo(kTitleAndStateHeight)
            }
        }
        mqttSetting()
        requestDataList()
    }
    lazy var tableView : UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = kWhiteColor
        
        // 设置大概高度
        table.estimatedRowHeight = 60
        // 设置行高为自动适配
        table.rowHeight = UITableView.automaticDimension
        
        table.register(HOOPLeaveMessageRecordCell.self, forCellReuseIdentifier: messageRecordCell)
        
        return table
    }()
    ///获取数据
    func requestDataList(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        showLoadingView()
        
        let url = messageType == "3" ? "leavemsg/listoff" : "leavemsg/liston"
        var paramDic:[String : Any] = ["deviceId":userDefaults.string(forKey: "devId") ?? ""]
        if messageType != "3" {
            paramDic["type"] = messageType
        }
        GYZNetWork.requestNetwork(url,parameters: paramDic,method :.get,  success: { (response) in
            
            weakSelf?.hiddenLoadingView()
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let data = response["data"].array else { return }
                
                weakSelf?.dataList.removeAll()
                for item in data{
                    guard let itemInfo = item.dictionaryObject else { return }
                    let model = HOOPLeaveMessageModel.init(dict: itemInfo)
                    
                    weakSelf?.dataList.append(model)
                }
                
                weakSelf?.tableView.reloadData()
                if weakSelf?.dataList.count > 0{
                    weakSelf?.hiddenEmptyView()
                }else{
                    ///显示空页面
                    weakSelf?.showEmptyView(content:"暂无留言")
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
                weakSelf?.requestDataList()
            })
        })
    }
    
    /// 详情
    func goDetailVC(model: HOOPLeaveMessageModel){
        if messageType != "3" {
            let vc = HOOPLeaveMessageVC()
            vc.isEdit = true
            vc.messageId = model.id!
            vc.resultBlock = {[unowned self] (isRefresh) in
                if isRefresh{
                    self.requestDataList()
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = HOOPReceivedMessageDetailVC()
            vc.dataModel = model
            vc.resultBlock = {[unowned self] (isRefresh) in
                if isRefresh{
                    self.requestDataList()
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    /// 播放语音留言
    @objc func onClickedPlay(sender: UIButton){
        let tag = sender.tag
        let model = dataList[tag]
        downLoadVoice(name: model.msgName!)
    }
    func downLoadVoice(name:String){
        weak var weakSelf = self
        createHUD(message: "加载中...")
        GYZNetWork.downLoadRequest("http://119.29.107.14:8080/robot_filter-web/voiceMessage/download.html", parameters: ["boardId":userDefaults.string(forKey: "devId") ?? "","fileName":name], method: .post, success: { (response) in
            //            sleep(1)
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            weakSelf?.playDownLoadVoice(name:name)
        }) { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        }
    }
    
    func playDownLoadVoice(name:String){
        
        recorderManager.recordName = name
        recorderManager.convertAmrToWav()
        recorderManager.playWav()
    }
    /// 删除我的提醒
    func deleteMsg2(indexRow:Int){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "是否删除该提醒?", cancleTitle: "取消", viewController: self, buttonTitles: "确定") { (index) in
            
            if index != cancelIndex{
                weakSelf?.sendSaveDeleteMqttCmd(indexRow: indexRow)
            }
        }
    }
    
    /// mqtt发布主题 删除留言
    func sendSaveDeleteMqttCmd(indexRow: Int){
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","leavemsg_id":dataList[indexRow].id!,"phone":userDefaults.string(forKey: "phone") ?? "","msg_type":"app_leavemsg_del","app_interface_tag":"\(indexRow)","type": "2"]
        
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
            if type == "app_leavemsg_del_re" && phone == userDefaults.string(forKey: "phone"){
                hud?.hide(animated: true)
                MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                if result["code"].intValue == kQuestSuccessTag{
                    
                    let index: Int = result["app_interface_tag"].intValue
                    dataList.remove(at: index)
                    tableView.reloadData()
                }
            }
            
        }
    }
}

extension HOOPMessageRecordVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: messageRecordCell) as! HOOPLeaveMessageRecordCell
        
        cell.rightIconView.isHidden = false
        cell.playBtn.tag = indexPath.row
        cell.playBtn.addTarget(self, action: #selector(onClickedPlay(sender:)), for: .touchUpInside)
        let model = dataList[indexPath.row]
        if messageType == "3" {// 收到的留言
            if model.msgName!.isEmpty {
                cell.playBtn.isHidden = true
                cell.nameLab.text = model.tts
            }else{
                cell.nameLab.text = "语音留言"
                cell.playBtn.isHidden = false
            }
            cell.dateLab.text = model.createTime
        }else{
            if model.weak_time == "USER_DEFINE" {// 自定义
                let timeArr: [String] = (model.userDefineTimes?.components(separatedBy: ";"))!
                var days: String = ""
                for item in timeArr{
                    days += GUARDBUFANGTIMEBYWEEKDAY[item]! + ","
                }
                if days.count > 0{
                    days = days.subString(start: 0, length: days.count - 1)
                }
                cell.dateLab.text = days + " " + model.day_time!
            }else if model.weak_time == "ONCE"{
                cell.dateLab.text = GUARDBUFANGTIME[model.weak_time!]! + " " + model.yml! + " " + model.day_time!
            }else{
                cell.dateLab.text = GUARDBUFANGTIME[model.weak_time!]! + " " + model.day_time!
            }
            if model.msgName!.isEmpty {
                cell.playBtn.isHidden = true
                cell.nameLab.text = model.msg
            }else{
                cell.nameLab.text = "语音留言"
                cell.playBtn.isHidden = false
            }
            
            if messageType == "2" {//我的提醒
                cell.rightIconView.isHidden = true
                if model.state == "1" {
                    cell.nameLab.textColor = kBlueFontColor
                    cell.dateLab.textColor = kBlueFontColor
                }else{
                    cell.nameLab.textColor = kGaryFontColor
                    cell.dateLab.textColor = kGaryFontColor
                }
            }else{
                cell.nameLab.textColor = kBlackFontColor
                cell.dateLab.textColor = kGaryFontColor
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
        goDetailVC(model: dataList[indexPath.row])
    }
    ///MARK : UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    /// 实现左滑
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if messageType == "2" {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "删除") { [weak self] (action, index) in
            self?.deleteMsg2(indexRow: index.row)
        }
        deleteAction.backgroundColor = kRedFontColor
        
        return [deleteAction]
    }
}
