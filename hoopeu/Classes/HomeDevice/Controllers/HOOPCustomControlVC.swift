//
//  HOOPCustomControlVC.swift
//  hoopeu
//  自定义遥控器
//  Created by gouyz on 2019/3/8.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

private let customControlCell = "customControlCell"

class HOOPCustomControlVC: GYZBaseVC {
    
    /// 遥控器id
    var controlId:String = ""
    /// 遥控器类型
    var controlType:String = ""
    
    var dataModel: HOOPCustomControlModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "自定义遥控"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_device_setting")?.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(clickedSettingBtn))
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        requestControlData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mqttSetting()
    }
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        
        let itemW: CGFloat = (kScreenWidth - 5 * kMargin) * 0.25
        ///设置cell的大小
        layout.itemSize = CGSize(width: itemW, height: itemW + kMargin)
        
        //每个Item之间最小的间距
        layout.minimumInteritemSpacing = kMargin
        //每行之间最小的间距
        layout.minimumLineSpacing = klineWidth
        layout.sectionInset = UIEdgeInsets.init(top: kMargin, left: kMargin, bottom: kMargin, right: kMargin)
        
        let collView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collView.dataSource = self
        collView.delegate = self
        collView.backgroundColor = kWhiteColor
        
        collView.register(HOOPCustomControlKeyCell.self, forCellWithReuseIdentifier: customControlCell)
        
        return collView
    }()
    
    ///获取遥控数据
    func requestControlData(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("homeCtrl/other",parameters: ["id":controlId],  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let data = response["data"].dictionaryObject else { return }
                
                weakSelf?.dataModel = HOOPCustomControlModel.init(dict: data)
                
                weakSelf?.collectionView.reloadData()
                
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
            
        })
    }
    
    /// 设置
    @objc func clickedSettingBtn(){
        if dataModel == nil {
            MBProgressHUD.showAutoDismissHUD(message: "未获取到遥控器数据")
            return
        }
        GYZAlertViewTools.alertViewTools.showSheet(title: nil, message: nil, cancleTitle: "取消", titleArray: ["重新配置","删除"], viewController: self) { [weak self](index) in
            
            if index == 0{//重新配置
                if self?.controlType == "pt2262" {/// 射频遥控
                    self?.goShePinVC()
                }else if self?.controlType == "pt2262" {/// 自定义遥控
                    self?.goShePinVC()
                }
            }else if index == 1{//删除
                self?.showDeleteAlert()
            }
        }
    }
    
    /// 射频遥控 重新配置
    func goShePinVC(){
        let vc = HOOPShePinControlVC()
        vc.dataModel = dataModel
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 删除
    func showDeleteAlert(){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "确定要删除此遥控器吗?", cancleTitle: "取消", viewController: self, buttonTitles: "确定") { (index) in
            
            if index != cancelIndex{
                if weakSelf?.controlType == "pt2262" {/// 射频遥控
                    weakSelf?.sendDeleteMqttCmd()
                }
                
            }
        }
    }
    
    /// mqtt发布主题 删除
    func sendDeleteMqttCmd(){
        
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","ctrl_dev_id":(dataModel?.id)!,"phone":userDefaults.string(forKey: "phone") ?? "","msg_type":"app_pt2262_del","app_interface_tag":""]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// mqtt发布主题 发射指令
    func sendZhiLingMqttCmd(index: Int){
        
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","ctrl_dev_id":(dataModel?.id)!,"phone":userDefaults.string(forKey: "phone") ?? "","func_num":(dataModel?.funcList.count)!,"func_id":dataModel?.funcList[index].func_id ?? "","ctrl_test":false,"code":"","msg_type":"app_pt2262_ctrl","app_interface_tag":""]
        
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
            if type == "app_pt2262_del_re" && phone == userDefaults.string(forKey: "phone"){
                //                hud?.hide(animated: true)
                MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                
                if result["code"].intValue == kQuestSuccessTag{
                    clickedBackBtn()
                }
            }else if type == "app_pt2262_ctrl_re" && phone == userDefaults.string(forKey: "phone"){
                //                hud?.hide(animated: true)
                MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
            }
            
        }
    }
}

extension HOOPCustomControlVC : UICollectionViewDataSource,UICollectionViewDelegate{
    // MARK: UICollectionViewDataSource 代理方法
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataModel == nil ? 0 : (dataModel?.funcList.count)!
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customControlCell, for: indexPath) as! HOOPCustomControlKeyCell
        
        cell.nameLab.text = dataModel?.funcList[indexPath.row].ctrl_name
        
        return cell
    }
    // MARK: UICollectionViewDelegate的代理方法
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if controlType == "pt2262" {/// 射频遥控
            sendZhiLingMqttCmd(index: indexPath.row)
        }
    }
}
