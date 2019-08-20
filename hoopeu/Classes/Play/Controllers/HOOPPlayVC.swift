//
//  HOOPPlayVC.swift
//  hoopeu
//  玩转叮当
//  Created by gouyz on 2019/1/3.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

private let playCell = "playCell"

class HOOPPlayVC: GYZBaseVC {
    
    var dataList: [HOOPChatModel] = [HOOPChatModel]()
    var rightBtn: UIButton?
    
    var currPage : Int = 1
    /// 说false或做true
    var isSpeakOrDo: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "玩转叮当"
        
        rightBtn = UIButton(type: .custom)
        rightBtn?.setImage(UIImage(named: "icon_message")?.withRenderingMode(.alwaysOriginal), for: .normal)
        rightBtn?.frame = CGRect.init(x: 0, y: 0, width: kTitleHeight, height: kTitleHeight)
        rightBtn?.addTarget(self, action: #selector(clickedMessageBtn), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBtn!)
//        rightBtn?.badgeView.style = .normal
//        rightBtn?.showBadge(animated: false)
        
        view.addSubview(tableView)
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.bottom.equalTo(view)
            make.height.equalTo(kBottomTabbarHeight)
        }
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.bottom.equalTo(bottomView.snp.top)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view)
            }else{
                make.top.equalTo(kTitleAndStateHeight)
            }
        }
        /// 切换说或做
        bottomView.onClickedChangeBlock = {[weak self](isSpeak) in
            self?.isSpeakOrDo = isSpeak
        }
        /// 发送
        bottomView.onClickedSendBlock = {[weak self](message) in
            self?.sendMessage(message: message)
        }
        
//        requestChatDatas()
//        mqttSetting()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currPage = 1
        dataList.removeAll()
        tableView.reloadData()
        requestChatDatas()
        mqttSetting()
    }
    /// 留言
    @objc func clickedMessageBtn(){
        let vc = HOOPLeaveMessageVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    lazy var tableView : UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = kBackgroundColor
        
        // 设置大概高度
        table.estimatedRowHeight = 180
        // 设置行高为自动适配
        table.rowHeight = UITableView.automaticDimension
        
        table.register(HOOPChatTextCell.self, forCellReuseIdentifier: playCell)
        
        weak var weakSelf = self
        ///添加下拉刷新
        GYZTool.addPullRefresh(scorllView: table, pullRefreshCallBack: {
            weakSelf?.refresh()
        })
        
        return table
    }()
    
    lazy var bottomView: HOOPChatBottomView = HOOPChatBottomView()
    
    ///获取聊天记录数据
    func requestChatDatas(){
        
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        showLoadingView()
        
        GYZNetWork.requestNetwork("sayLog",parameters: ["page": currPage,"num": kPageSize],  success: { (response) in
            
            weakSelf?.hiddenLoadingView()
            weakSelf?.closeRefresh()
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let data = response["data"].array else { return }
                
                for item in data{
                    guard let itemInfo = item.dictionaryObject else { return }
                    let model = HOOPChatModel.init(dict: itemInfo)
                    
                    weakSelf?.dataList.append(model)
                }
                if weakSelf?.dataList.count > 0{
                    weakSelf?.hiddenEmptyView()
                    weakSelf?.tableView.reloadData()
                    weakSelf?.scrollToBottom(animated: false)
                }else{
                    ///显示空页面
                    weakSelf?.showEmptyView(content: "暂无聊天信息")
                    weakSelf?.view.bringSubviewToFront((weakSelf?.bottomView)!)
                }
                
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            
            weakSelf?.hiddenLoadingView()
            weakSelf?.closeRefresh()
            GYZLog(error)
            
            if weakSelf?.currPage == 1{//第一次加载失败，显示加载错误页面
                weakSelf?.showEmptyView(content: "加载失败，请点击重新加载", reload: {
                    weakSelf?.requestChatDatas()
                    weakSelf?.hiddenEmptyView()
                })
                weakSelf?.view.bringSubviewToFront((weakSelf?.bottomView)!)
            }
        })
    }
    
    // MARK: - 上拉加载更多/下拉刷新
    /// 下拉刷新
    func refresh(){
        currPage += 1
        requestChatDatas()
    }
    
    /// 关闭上拉/下拉刷新
    func closeRefresh(){
        if tableView.mj_header.isRefreshing{//下拉刷新
            GYZTool.endRefresh(scorllView: tableView)
        }
    }
    
    // MARK: 滚到底部
    func scrollToBottom(animated: Bool = false) {
        if dataList.count > 0 {
            if currPage == 1{
                tableView.scrollToRow(at: IndexPath(row: dataList.count - 1, section: 0), at: .bottom, animated: animated)
            }
        }
    }
    
    func sendMessage(message: String){
        
        let msgType: String = isSpeakOrDo ? "app_send_order" : "app_send_tts"
        let order: String = isSpeakOrDo ? "order" : "tts"
        let paramDic:[String:String] = ["token":userDefaults.string(forKey: "token") ?? "","msg_type":msgType,"phone":userDefaults.string(forKey: "phone") ?? "",order:message,"app_interface_tag":""]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// 重载CocoaMQTTDelegate
    override func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        super.mqtt(mqtt, didConnectAck: ack)
        if ack == .accept {
            mqtt.subscribe("api_receive", qos: CocoaMQTTQOS.qos1)
            mqtt.subscribe("hoopeu_app", qos: CocoaMQTTQOS.qos1)
        }
    }
    override func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        super.mqtt(mqtt, didReceiveMessage: message, id: id)
        if let data = message.string {
            let result = JSON.init(parseJSON: data)
            let type = result["msg_type"].stringValue
//            if let tag = result["app_interface_tag"].string{
//                if tag.hasPrefix("system_"){
//                    return
//                }
//            }
            
            if (type == "app_send_order_re" || type == "app_send_tts_re") && result["phone"].stringValue == userDefaults.string(forKey: "phone"){
                if result["code"].intValue == kQuestSuccessTag {
                    bottomView.conmentField.text = ""
//                    currPage = 1
//                    dataList.removeAll()
//                    tableView.reloadData()
//                    requestChatDatas()
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                }
            }else if type == "update_chat" && result["device_id"].stringValue == userDefaults.string(forKey: "devId"){
                
                bottomView.conmentField.text = ""
                let chatData = result["msg"]
                if !chatData["user_content"].stringValue.isEmpty{
                    let meChatModel = HOOPChatModel.init(dict: ["role":"1","content":chatData["user_content"].stringValue,"time": "\(Date().timeIntervalSince1970)"])
                    dataList.append(meChatModel)
                }
                if !chatData["device_content"].stringValue.isEmpty{
                    let chatModel = HOOPChatModel.init(dict: ["role":"0","content":chatData["device_content"].stringValue,"time": "\(Date().timeIntervalSince1970)"])
                    dataList.append(chatModel)
                }
                tableView.reloadData()
                tableView.scrollToRow(at: IndexPath(row: dataList.count - 1, section: 0), at: .bottom, animated: false)
            }
            
        }
    }
}
extension HOOPPlayVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: playCell) as! HOOPChatTextCell
        cell.dataModel = dataList[indexPath.row]
        
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
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    ///启用长按复制上下文菜单必须调用3个方法
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.copy(_:))   {
            return true
        }
        return false
    }
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        let cell = tableView.cellForRow(at: indexPath) as! HOOPChatTextCell
        UIPasteboard.general.string = cell.nameLab.text
    }
}
