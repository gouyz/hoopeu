//
//  HOOPWarnLogVC.swift
//  hoopeu
//  报警日志
//  Created by gouyz on 2019/2/26.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

private let warnLogCell = "warnLogCell"

class HOOPWarnLogVC: GYZBaseVC {
    
    var dataList: [HOOPGuardModel] = [HOOPGuardModel]()
    var currPage: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "报警日志"
        
        let rightBtn = UIButton(type: .custom)
        rightBtn.setImage(UIImage(named: "icon_link_person")?.withRenderingMode(.alwaysOriginal), for: .normal)
        rightBtn.frame = CGRect.init(x: 0, y: 0, width: kTitleHeight, height: kTitleHeight)
        rightBtn.addTarget(self, action: #selector(onClickRightBtn), for: .touchUpInside)
        
        let clearBtn = UIButton(type: .custom)
        clearBtn.setTitle("解除", for: .normal)
        clearBtn.titleLabel?.font = k15Font
        clearBtn.setTitleColor(kBlueFontColor, for: .normal)
        clearBtn.frame = CGRect.init(x: 0, y: 0, width: kTitleHeight, height: kTitleHeight)
        clearBtn.addTarget(self, action: #selector(onClickClearWarnBtn), for: .touchUpInside)
        navigationItem.rightBarButtonItems = [UIBarButtonItem.init(customView: rightBtn),UIBarButtonItem.init(customView: clearBtn)]
//        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBtn)
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        mqttSetting()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestLogsDatas()
    }
    
    lazy var tableView : UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.separatorColor = kGrayLineColor
        table.backgroundColor = kWhiteColor
        
        table.register(GYZMyProfileCell.self, forCellReuseIdentifier: warnLogCell)
        
        weak var weakSelf = self
        ///添加下拉刷新
        GYZTool.addPullRefresh(scorllView: table, pullRefreshCallBack: {
            weakSelf?.refresh()
        })
        ///添加上拉加载更多
        GYZTool.addLoadMore(scorllView: table, loadMoreCallBack: {
            weakSelf?.loadMore()
        })
        
        return table
    }()
    ///获取报警日志数据
    func requestLogsDatas(){
        
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        showLoadingView()
        
        GYZNetWork.requestNetwork("homeCtrl/alarmLog",parameters: nil,method :.get , success: { (response) in
            
            weakSelf?.hiddenLoadingView()
            weakSelf?.closeRefresh()
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let data = response["data"].array else { return }
                weakSelf?.dataList.removeAll()
                for item in data{
                    guard let itemInfo = item.dictionaryObject else { return }
                    let model = HOOPGuardModel.init(dict: itemInfo)
                    
                    weakSelf?.dataList.append(model)
                }
                weakSelf?.tableView.reloadData()
                if weakSelf?.dataList.count > 0{
                    weakSelf?.hiddenEmptyView()
                }else{
                    ///显示空页面
                    weakSelf?.showEmptyView(content: "暂无报警日志信息")
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
                    weakSelf?.refresh()
                    weakSelf?.hiddenEmptyView()
                })
            }
        })
    }
    // MARK: - 上拉加载更多/下拉刷新
    /// 下拉刷新
    func refresh(){
        currPage = 1
        requestLogsDatas()
    }
    
    /// 上拉加载更多
    func loadMore(){
        currPage += 1
        requestLogsDatas()
    }
    
    /// 关闭上拉/下拉刷新
    func closeRefresh(){
        if tableView.mj_header.isRefreshing{//下拉刷新
            dataList.removeAll()
            GYZTool.endRefresh(scorllView: tableView)
        }else if tableView.mj_footer.isRefreshing{//上拉加载更多
            GYZTool.endLoadMore(scorllView: tableView)
        }
    }
    /// 详情
    func goDetailVC(index: Int){
        let vc = HOOPLogDetailVC()
        vc.logId = dataList[index].id!
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc func onClickRightBtn(){//联系人
        let vc = HOOPLinkPersonVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc func onClickClearWarnBtn(){/// 解除报警
        showWarnAlert()
    }
    /// 解除报警
    func showWarnAlert(){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "是否解除报警？", cancleTitle: "已解除", viewController: self, buttonTitles: "解除") { (index) in
            
            if index != cancelIndex{
                weakSelf?.sendMqttCmd()
            }
        }
    }
    /// 处理报警
    func requestDealWarn(rowIndex: Int){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        
        GYZNetWork.requestNetwork("alert/handle", parameters: ["id":dataList[rowIndex].id!],method :.get,  success: { (response) in
            
            GYZLog(response)
            MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                weakSelf?.dataList[rowIndex].handle = "1"
                weakSelf?.tableView.reloadData()
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    
    /// 解除报警
    func sendMqttCmd(){
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["device_id":userDefaults.string(forKey: "devId") ?? "","user_id":userDefaults.string(forKey: "phone") ?? "","msg_type":"cancel_alarm","app_interface_tag":"ok"]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// 删除日志
    func deleteLog(indexRow:Int){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "是否删除该报警日志?", cancleTitle: "取消", viewController: self, buttonTitles: "确定") { (index) in
            
            if index != cancelIndex{
                weakSelf?.requestDeleteLog(indexRow: indexRow)
            }
        }
    }
    ///删除日志
    func requestDeleteLog(indexRow:Int){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        
        GYZNetWork.requestNetwork("homeCtrl/alarmLog/del/log/\(dataList[indexRow].id!)",parameters: nil,method :.get,  success: { (response) in
            
            GYZLog(response)
            MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                weakSelf?.dataList.remove(at: indexRow)
                weakSelf?.tableView.reloadData()
                if weakSelf?.dataList.count > 0{
                    weakSelf?.hiddenEmptyView()
                }else{
                    ///显示空页面
                    weakSelf?.showEmptyView(content: "暂无报警日志信息")
                }
                
            }
            
        }, failture: { (error) in
            
            GYZLog(error)
        })
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
            if type == "cancel_alarm_re" && phone == userDefaults.string(forKey: "phone"){
                hud?.hide(animated: true)
                if result["ret"].intValue == 1{
                    MBProgressHUD.showAutoDismissHUD(message: "解除成功")
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: "解除失败")
                }
            }
            
        }
    }
}

extension HOOPWarnLogVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: warnLogCell) as! GYZMyProfileCell
        
        let model = dataList[indexPath.row]
        cell.nameLab.text = model.time! + "(\(model.typeName!))"
        cell.desLab.textColor = kRedFontColor
        cell.userImgView.isHidden = true
        cell.desLab.isHidden = false
        cell.rightIconView.isHidden = false
        
        if model.handle == "0"{
            cell.desLab.textColor = kRedFontColor
            cell.desLab.text = "●"
        }else{
            cell.desLab.text = ""
        }
        cell.desLab.snp.updateConstraints { (make) in
            make.width.equalTo(80)
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
        let model = dataList[indexPath.row]
        if model.handle == "0" {
            requestDealWarn(rowIndex: indexPath.row)
        }
        if model.type == "guard" {
            goDetailVC(index: indexPath.row)
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
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "删除") { [weak self] (action, index) in
            self?.deleteLog(indexRow: index.row)
        }
        deleteAction.backgroundColor = kRedFontColor
        
        return [deleteAction]
    }
}

