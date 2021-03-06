//
//  HOOPARCControlVC.swift
//  hoopeu
//  空调遥控器
//  Created by gouyz on 2019/2/28.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON
import AudioToolbox

class HOOPARCControlVC: HOOPBaseControlVC {
    
    /// 按钮位置
    var keyNumList: [String:Int] = ["arc_open":0x77,"arc_close":0x88,"arc_temp_add":0x06,"arc_temp_minus":0x07,"arc_model":0x02,"arc_wind_speed":0x03,"arc_shou_auto":0x04,"arc_auto":0x05]
    /// 当前操作按键tag
    var currTag:Int = 0x77

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "空调遥控器"
        setUpUI()
    
        requestControlData()
    }
    
    /// 获取家电遥控
    func requestControlData(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("homeCtrl/ir", parameters: ["id":controlId],method:.get,  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let itemInfo = response["data"].dictionaryObject else { return }
                weakSelf?.dataModel = HOOPControlModel.init(dict: itemInfo)
                weakSelf?.dealData()
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    
    func setUpUI(){
        view.addSubview(bgView)
        bgView.addSubview(desLab)
        bgView.addSubview(iconView)
        iconView.addSubview(tempLab)
        iconView.addSubview(windDesLab)
        iconView.addSubview(windSpeedDesLab)
        iconView.addSubview(modelDesLab)
        bgView.addSubview(onBtn)
        bgView.addSubview(offBtn)
        bgView.addSubview(modelBtn)
        bgView.addSubview(tempPlusBtn)
        bgView.addSubview(tempMinusBtn)
        bgView.addSubview(shouAutoBtn)
        bgView.addSubview(autoBtn)
        bgView.addSubview(windSpeedBtn)
        
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(kTitleAndStateHeight + 20)
            make.bottom.equalTo(-20)
        }
        desLab.snp.makeConstraints { (make) in
            make.top.equalTo(kMargin)
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.height.equalTo(20)
        }
        iconView.snp.makeConstraints { (make) in
            make.top.equalTo(desLab.snp.bottom).offset(kMargin)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(160)
        }
        tempLab.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(iconView)
            make.bottom.equalTo(windDesLab.snp.top)
        }
        windDesLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.bottom.equalTo(iconView)
            make.height.equalTo(kTitleHeight)
            make.width.equalTo(windSpeedDesLab)
        }
        windSpeedDesLab.snp.makeConstraints { (make) in
            make.left.equalTo(windDesLab.snp.right).offset(5)
            make.height.bottom.equalTo(windDesLab)
            make.width.equalTo(modelDesLab)
        }
        modelDesLab.snp.makeConstraints { (make) in
            make.left.equalTo(windSpeedDesLab.snp.right).offset(5)
            make.right.equalTo(-kMargin)
            make.height.bottom.width.equalTo(windDesLab)
        }
        onBtn.snp.makeConstraints { (make) in
            make.right.equalTo(bgView.snp.centerX).offset(-kMargin)
            make.width.equalTo(60)
            make.height.equalTo(50)
            make.top.equalTo(iconView.snp.bottom).offset(kTitleHeight)
        }
        offBtn.snp.makeConstraints { (make) in
            make.left.equalTo(bgView.snp.centerX).offset(kMargin)
            make.top.width.height.equalTo(onBtn)
        }
        modelBtn.snp.makeConstraints { (make) in
            make.left.equalTo(iconView)
            make.top.equalTo(onBtn.snp.bottom).offset(20)
            make.height.equalTo(50)
            make.width.equalTo(tempMinusBtn)
        }
        tempMinusBtn.snp.makeConstraints { (make) in
            make.left.equalTo(modelBtn.snp.right).offset(15)
            make.top.height.equalTo(modelBtn)
            make.width.equalTo(tempPlusBtn)
        }
        tempPlusBtn.snp.makeConstraints { (make) in
            make.left.equalTo(tempMinusBtn.snp.right).offset(15)
            make.right.equalTo(iconView)
            make.height.top.width.equalTo(modelBtn)
        }
        windSpeedBtn.snp.makeConstraints { (make) in
            make.left.height.equalTo(modelBtn)
            make.top.equalTo(modelBtn.snp.bottom).offset(20)
            make.width.equalTo(shouAutoBtn)
        }
        shouAutoBtn.snp.makeConstraints { (make) in
            make.left.equalTo(windSpeedBtn.snp.right).offset(15)
            make.top.height.equalTo(windSpeedBtn)
            make.width.equalTo(autoBtn)
        }
        autoBtn.snp.makeConstraints { (make) in
            make.left.equalTo(shouAutoBtn.snp.right).offset(15)
            make.right.equalTo(iconView)
            make.height.top.width.equalTo(windSpeedBtn)
        }
    }
    
    lazy var bgView: UIView = {
        let bgview = UIView()
        bgview.backgroundColor = kWhiteColor
        bgview.cornerRadius = 10
        bgview.isUserInteractionEnabled = true
        
        return bgview
    }()
    lazy var iconView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_arc_temp_bg"))
    
    ///温度
    lazy var tempLab : UILabel = {
        let lab = UILabel()
        lab.font = UIFont.boldSystemFont(ofSize: 32)
        lab.textColor = kHeightGaryFontColor
        lab.text = "28℃"
        lab.textAlignment = .center
        
        return lab
    }()
    ///风向
    lazy var windDesLab : UILabel = {
        let lab = UILabel()
        lab.font = k13Font
        lab.textColor = kHeightGaryFontColor
        lab.text = "风向：向上"
        
        return lab
    }()
    ///风速
    lazy var windSpeedDesLab : UILabel = {
        let lab = UILabel()
        lab.font = k13Font
        lab.textColor = kHeightGaryFontColor
        lab.text = "风速：中"
        lab.textAlignment = .center
        
        return lab
    }()
    ///模式
    lazy var modelDesLab : UILabel = {
        let lab = UILabel()
        lab.font = k13Font
        lab.textColor = kHeightGaryFontColor
        lab.text = "模式：制冷"
        lab.textAlignment = .right
        
        return lab
    }()
    /// 温度+
    lazy var tempPlusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("温度+", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = kCornerRadius
        btn.tag = 0x06
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 温度-
    lazy var tempMinusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("温度-", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.tag = 0x07
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    
    /// 模式
    lazy var modelBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("模式", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = kCornerRadius
        btn.tag = 0x02
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 开
    lazy var onBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kRedFontColor
        btn.setTitle("开", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = kCornerRadius
        btn.tag = 0x77
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 关
    lazy var offBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kRedFontColor
        btn.setTitle("关", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = kCornerRadius
        btn.tag = 0x88
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 风速
    lazy var windSpeedBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("风速", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = kCornerRadius
        btn.tag = 0x03
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 手动风向
    lazy var shouAutoBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("手动风向", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = kCornerRadius
        btn.tag = 0x04
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 自动风向
    lazy var autoBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("自动风向", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = kCornerRadius
        btn.tag = 0x05
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 获取所有品牌
    func dealData(){
        brandList = IRDBManager.shareInstance()?.getAllBrand(by: .ARC) as! [[String:String]]
        if brandList.count > 0 {
            if dataModel != nil{
                let brandName: String = brandList[Int.init((dataModel?.brand)!)!]["brand"]!
                /// 获取所选品牌的遥控器方案数据
                deviceModelList = IRDBManager.shareInstance()?.getAllNoModel(byBrand: brandName, deviceType: .ARC) as! [DeviceM]
                controlCode = deviceModelList[Int.init((dataModel?.code_bark)!)!].code
                
                if dataModel?.funcList.count > 0{// 有自定义按键
                    for item in (dataModel?.funcList)!{
                        for key in keyNumList.keys{
                            if key == item.customNum{
                                let tag = keyNumList[key]
                                let btn: UIButton = self.view.viewWithTag(tag!) as! UIButton
                                btn.setTitle(item.ctrlName, for: .normal)
                                /// 记录自定义按键id
                                btn.accessibilityIdentifier = item.sensorId
                                let keyId: Int = Int.init(item.sensorId!)!
                                if keyMaxId < keyId {
                                    keyMaxId = keyId
                                }
                                break
                            }
                        }
                    }
                }
            }
            
        }
        
    }
    /// 操作
    @objc func clickedOperatorBtn(btn: UIButton){
        //默认震动效果
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        currTag = btn.tag
        
        if isEdit {// 编辑
            if btn.accessibilityIdentifier != nil{// 自定义按键
                showStudyAlert(funcId: Int.init(btn.accessibilityIdentifier!)!)
            }else{
                keyMaxId += 1
                showStudyAlert(funcId: keyMaxId)
//                requestDeviceId()
            }
        }else{
            if btn.accessibilityIdentifier != nil{// 自定义按键
                sendCmdCustomMqtt(isTest: false, funcId: Int.init(btn.accessibilityIdentifier!)!,code: "")
            }else{
                if controlCode == nil{
                    MBProgressHUD.showAutoDismissHUD(message: "未找到该遥控器")
                    return
                }
                if !(ARCStateCtr.shareInstance()?.powerOn)!{
                    //关机状态下 除开机键外，都无响应
                    if currTag != 0x77{
                        MBProgressHUD.showAutoDismissHUD(message: "关机状态下只能操作开机键")
                        return
                    }
                }
                sendCmdMqtt(studyCode: (ARCStateCtr.shareInstance()?.getARCKeyCode(controlCode, withTag: currTag,withControlId: controlId))!)
            }
        }
    }
    
    /// 开始学习
    func showStudyAlert(funcId: Int){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "将遥控器对准叮当宝贝\n点击“开始学习”", cancleTitle: "取消", viewController: self, buttonTitles: "开始学习") { (tag) in
            
            if tag != cancelIndex{
                weakSelf?.sendStudyMqttCmd(funcId: funcId)
                weakSelf?.showWaitAlert(funcId: funcId)
            }
        }
    }
    
    /// 正在等待
    func showWaitAlert(funcId: Int){
        waitAlert = GYZCustomWaitAlert.init()
        waitAlert?.titleLab.text = "单击遥控器按键\n请勿长按"
        waitAlert?.action = {[weak self]() in
            self?.showStudyFailedAlert(funcId: funcId)
            
        }
        waitAlert?.show()
    }
    /// 学习失败
    func showStudyFailedAlert(funcId: Int){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "学习失败，请重新尝试", cancleTitle: "取消", viewController: self, buttonTitles: "重新配置") { (tag) in
            
            if tag != cancelIndex{
                weakSelf?.showStudyAlert(funcId: funcId)
            }
        }
    }
    
    /// 学习成功 测试
    func showStudySuccessAlert(funcId: Int,code:String){
        let alert = HOOPStudyTestView.init()
        alert.titleLab.text = "学到新功能，测试一下是否可用吧"
        alert.action = {[weak self](tag) in
            if tag == 101 {// 发射指令
                self?.sendCmdCustomMqtt(isTest: true, funcId: funcId, code: code)
            }else if tag == 102 {// 没响应
                //                alert.hide()
            }else if tag == 103 {// 有响应
                self?.showSetKeyNameAlert(funcId: funcId)
            }
        }
        alert.show()
    }
    
    /// 按键命名
    func showSetKeyNameAlert(funcId: Int){
        let alert = HOOPSetKeyNameView.init()
        alert.action = {[weak self](name) in
            self?.sendSaveMqttCmd(funcId: funcId, name: name)
        }
        alert.show()
    }
    /// 获取临时id
    func requestDeviceId(){
        if !GYZTool.checkNetWork() {
            return
        }
        createHUD(message: "加载中...")
        weak var weakSelf = self
        
        GYZNetWork.requestNetwork("homeCtrl", parameters: ["id":controlId],  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                weakSelf?.showStudyAlert(funcId: response["data"].intValue)
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
            MBProgressHUD.showAutoDismissHUD(message: "获取临时id失败")
        })
    }
    /// 遥控器自定义保存
    func sendSaveMqttCmd(funcId:Int,name: String){
        weak var weakSelf = self
        createHUD(message: "加载中...")
    
        var customNum: String = ""
        for item in keyNumList {
            if item.value == currTag{
                customNum = item.key
                break
            }
        }
        let paramDic:[String:Any] = ["id":controlId,"custom_id":funcId,"custom_num":customNum,"custom_name":name]
        
        GYZNetWork.requestNetwork("homeCtrl/ir/addCustom", parameters: paramDic,  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                weakSelf?.setBtnData(funcId: funcId, name: name)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    
    func setBtnData(funcId:Int,name: String){
        let btn: UIButton = self.view.viewWithTag(currTag) as! UIButton
        btn.setTitle(name, for: .normal)
        btn.accessibilityIdentifier = "\(funcId)"
        
    }
    /// 重载CocoaMQTTDelegate
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
            
            if type == "app_ir_ctrl_re" && phone == userDefaults.string(forKey: "phone"){
                self.hud?.hide(animated: true)
                MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                if result["code"].intValue == kQuestSuccessTag{
                    if currTag == 0x77{
                        windDesLab.isHidden = false
                        windSpeedDesLab.isHidden = false
                        modelDesLab.isHidden = false
                        ARCStateCtr.shareInstance()?.powerOn = true
                    }else if currTag == 0x88{
                        tempLab.text = "--"
                        windDesLab.isHidden = true
                        windSpeedDesLab.isHidden = true
                        modelDesLab.isHidden = true
                        ARCStateCtr.shareInstance()?.powerOn = false
                    }
                    setState()
                }
            }else if type == "app_ir_extra_study_re" && phone == userDefaults.string(forKey: "phone"){
                self.hud?.hide(animated: true)
                
                if result["code"].intValue == kQuestSuccessTag{
                    
                    //1：成功；0：失败 2：学习开始（为区分学习返回时的第二次携码返回）
                    if result["data"]["ret"].intValue == 1{
                        waitAlert?.hide()
                        MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                        
                        showStudySuccessAlert(funcId: result["data"]["func_id"].intValue, code: result["data"]["code"].stringValue)
                    }else if result["data"]["ret"].intValue == 0{// 学习失败
                        showStudyFailedAlert(funcId: result["app_interface_tag"].intValue)
                    }
                }else {// 学习失败
                    MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                    showStudyFailedAlert(funcId: result["app_interface_tag"].intValue)
                }
            }
            
        }
    }
    
    func setState(){
        var modelState:String = ""
        switch ARCStateCtr.shareInstance()?.getModeWithControlId(controlId) {
        case 0x01:
            modelState = "模式：自动"
        case 0x02:
            modelState = "模式：制冷"
        case 0x03:
            modelState = "模式：抽湿"
        case 0x04:
            modelState = "模式：送风"
        case 0x05:
            modelState = "模式：制热"
        default:
            break
        }
        modelDesLab.text = modelState
        
        var windSpeedState:String = ""
        switch ARCStateCtr.shareInstance()?.getVoluWithControlId(controlId) {
        case 0x01:
            windSpeedState = "风速：自动"
        case 0x02:
            windSpeedState = "风速：低"
        case 0x03:
            windSpeedState = "风速：中"
        case 0x04:
            windSpeedState = "风速：高"
        default:
            break
        }
        windSpeedDesLab.text = windSpeedState
        var windState:String = ""
        switch ARCStateCtr.shareInstance()?.getManuWithControlId(controlId) {
        case 0x01:
            windState = "风向：向上"
        case 0x02:
            windState = "风向：中"
        case 0x03:
            windState = "风向：向下"
        default:
            break
        }
        windDesLab.text = windState
        
        if (ARCStateCtr.shareInstance()?.powerOn)! {
            tempLab.text = String.init(format: "%ld℃", ARCStateCtr.shareInstance()?.getTempWithControlId(controlId) ?? 0)
        }
    }
}
