//
//  HOOPShePinControlVC.swift
//  hoopeu
//  射频遥控
//  Created by gouyz on 2019/3/6.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import CocoaMQTT
import MBProgressHUD
import SwiftyJSON

private let shePinControlCell = "shePinControlCell"
private let shePinControlAddCell = "shePinControlAddCell"

class HOOPShePinControlVC: GYZBaseVC {
    
    var waitAlert: GYZCustomWaitAlert?
    var totalCount: Int = 1
    /// 遥控器临时id
    var deviceControlId: String = ""
    /// 记录功能按键
    var funcArr: [[String: String]] = [[String: String]]()
    /// 重新配置时传过来的数据
    var dataModel: HOOPCustomControlModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        if dataModel == nil {
            self.navigationItem.title = "射频遥控"
            requestDeviceId(param: nil,row: -1)
        }else{
            settingData()
        }
        
    }
    
    func setUpUI(){
        view.addSubview(collectionView)
        view.addSubview(saveBtn)
        
        collectionView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(view)
            make.bottom.equalTo(saveBtn.snp.top)
            //            if #available(iOS 11.0, *) {
            //                make.top.equalTo(view)
            //            }else{
            //                make.top.equalTo(kTitleAndStateHeight)
            //            }
        }
        saveBtn.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(kBottomTabbarHeight)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mqttSetting()
    }
    ///
    func settingData(){
        self.navigationItem.title = (dataModel?.ctrl_name)!
        deviceControlId = (dataModel?.id)!
        for item in (dataModel?.funcList)! {
            let name: String = item.ctrl_name!
            var keyDic: [String: String] = ["func_id":item.func_id!,"func_name":name]
            
            if name.contains("开") {
                keyDic["func_type"] = "switch_open"
            }else if name.contains("关") {
                keyDic["func_type"] = "switch_close"
            }else{
                keyDic["func_type"] = ""
            }
            funcArr.append(keyDic)
        }
        totalCount = (dataModel?.funcList.count)! + 1
        collectionView.reloadData()
    }
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        
        let itemW: CGFloat = (kScreenWidth - 3 * kMargin) * 0.5
        ///设置cell的大小
        layout.itemSize = CGSize(width: itemW, height: itemW * 0.61)
        
        //每个Item之间最小的间距
        layout.minimumInteritemSpacing = kMargin
        //每行之间最小的间距
        layout.minimumLineSpacing = kMargin
        layout.sectionInset = UIEdgeInsets.init(top: kMargin, left: kMargin, bottom: kMargin, right: kMargin)
        
        let collView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collView.dataSource = self
        collView.delegate = self
        collView.backgroundColor = kWhiteColor
        
        collView.register(HOOPCustomControlCell.self, forCellWithReuseIdentifier: shePinControlCell)
        collView.register(HOOPCustomControlAddCell.self, forCellWithReuseIdentifier: shePinControlAddCell)
        
        return collView
    }()
    
    /// 保存按钮
    lazy var saveBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("保存", for: .normal)
        btn.titleLabel?.font = k15Font
        
        btn.addTarget(self, action: #selector(clickedSaveBtn), for: .touchUpInside)
        
        return btn
    }()
    /// 保存
    @objc func clickedSaveBtn(){
        saveControlVC()
    }
    
    /// 获取临时id
    func requestDeviceId(param: [String:Any]?,row:Int){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("homeCtrl", parameters: param,  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                if param == nil{
                    weakSelf?.deviceControlId = response["data"].stringValue
                }else{// 获取按键id
                    weakSelf?.funcArr[row]["func_id"] = response["data"].stringValue
                    weakSelf?.showStudyAlert(index: row,studyState: "0")
                }
                
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    /// 保存
    func saveControlVC(){
        var studyFuncArr: [[String:String]] = [[String:String]]()
        for item in funcArr {// 筛选有效的按键
            if dataModel == nil {
                if item.count == 4{// 修改是不传code
                    studyFuncArr.append(item)
                }
            }else{
                if item.count == 3{// 修改是不传code
                    studyFuncArr.append(item)
                }
            }
        }
        if studyFuncArr.count == 0 {
            MBProgressHUD.showAutoDismissHUD(message: "请先设置遥控器按键")
            return
        }
        let vc = HOOPSaveShePinControlVC()
        vc.deviceControlId = deviceControlId
        vc.funcArr = studyFuncArr
        if dataModel != nil {
            vc.controlName = (dataModel?.ctrl_name)!
            vc.isEdit = true
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 删除
    @objc func onClickDel(sender: UITapGestureRecognizer){
        let tag: Int = (sender.view?.tag)!
        
        showDeleteAlert(index: tag)
    }
    
    /// 学习
    @objc func onClickStudy(sender: UITapGestureRecognizer){
        let tag: Int = (sender.view?.tag)!
        if funcArr[tag].count > 0 {// 不是第一次学习
            showStudyAlert(index: tag,studyState: "1")
        }else {
            requestDeviceId(param: ["id":deviceControlId],row: tag)
        }
    }
    /// 删除
    func showDeleteAlert(index: Int){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "确定要删除此按键吗?", cancleTitle: "取消", viewController: self, buttonTitles: "确定") { (tag) in
            
            if tag != cancelIndex{
                weakSelf?.funcArr.remove(at: index)
                weakSelf?.totalCount -= 1
                weakSelf?.collectionView.reloadData()
            }
        }
    }
    
    /// 开始学习
    func showStudyAlert(index: Int,studyState:String){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "将遥控器对准叮当宝贝\n点击“开始学习”", cancleTitle: "取消", viewController: self, buttonTitles: "开始学习") { (tag) in
            
            if tag != cancelIndex{
                weakSelf?.sendStudyMqttCmd(studyState: studyState, index: index)
                weakSelf?.showWaitAlert(index: index)
            }
        }
    }
    
    /// 正在等待
    func showWaitAlert(index: Int){
        waitAlert = GYZCustomWaitAlert.init()
        waitAlert?.titleLab.text = "单机遥控器按键\n请勿长按"
        waitAlert?.action = {[weak self]() in
            self?.showStudyFailedAlert(index: index)
            
        }
        waitAlert?.show()
    }
    /// 学习失败
    func showStudyFailedAlert(index: Int){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "学习失败，请重新尝试", cancleTitle: "取消", viewController: self, buttonTitles: "重新配置") { (tag) in
            
            if tag != cancelIndex{
                weakSelf?.showStudyAlert(index: index,studyState: "1")
            }
        }
    }
    
    /// 学习成功 测试
    func showStudySuccessAlert(index: Int,code:String){
        let alert = HOOPStudyTestView.init()
        alert.titleLab.text = "学到新功能，测试一下是否可用吧"
        alert.action = {[weak self](tag) in
            if tag == 101 {// 发射指令
                self?.sendZhiLingMqttCmd(code: code, index: index)
            }else if tag == 102 {// 没响应
//                alert.hide()
            }else if tag == 103 {// 有响应
                self?.showSetKeyNameAlert(index: index)
            }
        }
        alert.show()
    }
    
    /// 按键命名
    func showSetKeyNameAlert(index: Int){
        let alert = HOOPSetKeyNameView.init()
        alert.action = {[weak self](name) in
            self?.funcArr[index]["func_name"] = name
            if name.contains("开") {
                self?.funcArr[index]["func_type"] = "switch_open"
            }else if name.contains("关") {
                self?.funcArr[index]["func_type"] = "switch_close"
            }else{
                self?.funcArr[index]["func_type"] = ""
            }
            self?.collectionView.reloadData()
        }
        alert.show()
    }
    
    /// mqtt发布主题 学习
    func sendStudyMqttCmd(studyState: String,index: Int){
        
//        var count: Int = 0
//        for item in funcArr {
//            if item.count > 0{
//                count += 1
//            }
//        }
        
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","ctrl_dev_id":deviceControlId,"phone":userDefaults.string(forKey: "phone") ?? "","func_id":funcArr[index]["func_id"]!,"study_state":studyState,"msg_type":"app_pt2262_study","app_interface_tag":index]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// mqtt发布主题 发射指令
    func sendZhiLingMqttCmd(code: String,index: Int){
        
        var count: Int = 0
        for item in funcArr {
            if item.count > 0{
                count += 1
            }
        }
        
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","ctrl_dev_id":deviceControlId,"phone":userDefaults.string(forKey: "phone") ?? "","func_num":count,"func_id":funcArr[index]["func_id"]!,"code":code,"ctrl_test":true,"msg_type":"app_pt2262_ctrl","app_interface_tag":""]
        
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
            if type == "app_pt2262_study_re" && phone == userDefaults.string(forKey: "phone"){
                //                hud?.hide(animated: true)
                MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                
                if result["code"].intValue == kQuestSuccessTag{
                    waitAlert?.hide()
                    if self.dataModel == nil {
                        self.funcArr[result["app_interface_tag"].intValue]["func_code"] = result["data"].stringValue
                    }
                    showStudySuccessAlert(index: result["app_interface_tag"].intValue, code: result["data"].stringValue)
                }else{// 学习失败
                    showStudyFailedAlert(index: result["app_interface_tag"].intValue)
                }
            }else if type == "app_pt2262_ctrl_re" && phone == userDefaults.string(forKey: "phone"){
                
                if result["code"].intValue == kQuestSuccessTag{
                    MBProgressHUD.showAutoDismissHUD(message: "发射指令成功")
                }else{//
                    
                    MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                }
            }
            
        }
    }
}
extension HOOPShePinControlVC : UICollectionViewDataSource,UICollectionViewDelegate{
    // MARK: UICollectionViewDataSource 代理方法
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalCount
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == totalCount - 1 {// 创建
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: shePinControlAddCell, for: indexPath) as! HOOPCustomControlAddCell
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: shePinControlCell, for: indexPath) as! HOOPCustomControlCell
            
            cell.delImgView.tag = indexPath.row
            cell.delImgView.addOnClickListener(target: self, action: #selector(onClickDel(sender:)))
            
            cell.nameLab.tag = indexPath.row
            cell.nameLab.addOnClickListener(target: self, action: #selector(onClickStudy(sender:)))
            
            let model = funcArr[indexPath.row]
            if model.keys.contains("func_name"){
                cell.nameLab.text = model["func_name"]
            }
            
            return cell
        }
        
    }
    // MARK: UICollectionViewDelegate的代理方法
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == totalCount - 1 { //创建
            totalCount += 1
            funcArr.append([String:String]())
            self.collectionView.reloadData()
        }
    }
}
