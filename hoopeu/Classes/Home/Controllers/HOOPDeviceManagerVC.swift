//
//  HOOPDeviceManagerVC.swift
//  hoopeu
//  叮当宝贝设备管理
//  Created by gouyz on 2019/2/21.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

private let deviceManagerCell = "deviceManagerCell"

class HOOPDeviceManagerVC: GYZBaseVC {
    
    var dataList: [HOOPDeviceModel] = [HOOPDeviceModel]()
    /// 是否需要刷新
    var isRefresh: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "设备管理"
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
        
        requestDeviceList()
        mqttSetting()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isRefresh {
            isRefresh = false
            requestDeviceList()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var tableView : UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = kBackgroundColor
        
        table.register(HOOPDeviceManagerCell.self, forCellReuseIdentifier: deviceManagerCell)
        
        return table
    }()
    
    /// 添加按钮
    lazy var addBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kWhiteColor
        btn.setTitle("添加叮当宝贝", for: .normal)
        btn.setTitleColor(kBlueFontColor, for: .normal)
        btn.titleLabel?.font = k15Font
        
        btn.addTarget(self, action: #selector(clickedAddBtn), for: .touchUpInside)
        
        return btn
    }()
    
    ///获取叮当宝贝数据
    func requestDeviceList(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        showLoadingView()
        
        GYZNetWork.requestNetwork("device/userlist",parameters: nil,method :.get,  success: { (response) in
            
            weakSelf?.hiddenLoadingView()
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let data = response["data"].array else { return }
                
                weakSelf?.dataList.removeAll()
                for item in data{
                    guard let itemInfo = item.dictionaryObject else { return }
                    let model = HOOPDeviceModel.init(dict: itemInfo)
                    
                    weakSelf?.dataList.append(model)
                    weakSelf?.sendMqttCmd(devId: model.deviceId!)
                }
                if weakSelf?.dataList.count > 0{
                    weakSelf?.hiddenEmptyView()
                    weakSelf?.tableView.reloadData()
                }else{
                    ///显示空页面
                    weakSelf?.showEmptyView(content:"暂无叮当宝贝")
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
                weakSelf?.requestDeviceList()
            })
            weakSelf?.view.bringSubviewToFront((weakSelf?.addBtn)!)
        })
    }
    
    /// 添加叮当宝贝
    @objc func clickedAddBtn(){
        goLinkPower()
    }
    /// 连接电源
    func goLinkPower(){
        let vc = HOOPLinkPowerVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 设备详情
    func goDeviceDetailVC(index: Int){
        let vc = HOOPDeviceDetailVC()
        vc.deviceModel = dataList[index]
        vc.resultBlock = {[weak self] () in
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// mqtt发布主题 查询设备在线状态
    func sendMqttCmd(devId: String){
        let paramDic:[String:Any] = ["device_id":devId,"user_id":userDefaults.string(forKey: "phone") ?? "","msg_type":"query_online","app_interface_tag":"ok"]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
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
            
            if type == "query_online_re" && phone == userDefaults.string(forKey: "phone"){
                for item in dataList{
                    if item.deviceId == result["device_id"].stringValue{
                        item.onLine = "1"
                        break
                    }
                }
                tableView.reloadData()
            }
            
        }
    }
}

extension HOOPDeviceManagerVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: deviceManagerCell) as! HOOPDeviceManagerCell
        let model = dataList[indexPath.row]
        var name = model.deviceName
        if model.onLine == "1" {/// 正在使用
            name = model.deviceName! + "(使用中)"
            
            cell.nameLab.textColor = kBlueFontColor
        }else{
            cell.nameLab.textColor = kGaryFontColor
        }
        cell.nameLab.text = name
        
        
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
        
        goDeviceDetailVC(index: indexPath.row)
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
