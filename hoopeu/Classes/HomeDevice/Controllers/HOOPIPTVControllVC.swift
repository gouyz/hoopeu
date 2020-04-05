//
//  HOOPIPTVControllVC.swift
//  hoopeu
//  IPTV遥控器
//  Created by gouyz on 2019/3/1.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON
import AudioToolbox

class HOOPIPTVControllVC: HOOPBaseControlVC {
    /// 按钮位置
    var keyNumList: [String:Int] = ["iptv_power":1001,"iptv_mute":1003,"iptv_play":1023,"iptv_back":1045,"iptv_1":1025,"iptv_2":1027,"iptv_3":1029,"iptv_4":1031,"iptv_5":1033,"iptv_6":1035,"iptv_7":1037,"iptv_8":1039,"iptv_9":1041,"iptv_0":1043,"iptv_voice_plus":1005,"iptv_voice_minus":1007,"iptv_up":1013,"iptv_ok":1017,"iptv_left":1015,"iptv_right":1019,"iptv_down":1021,"iptv_channel_plus":1009,"iptv_channel_minus":1011]
    /// 当前操作按键tag
    var currTag:Int = 1001
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "IPTV遥控器"
        
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
        bgView.addSubview(onOffBtn)
        bgView.addSubview(muteBtn)
        bgView.addSubview(playBtn)
        bgView.addSubview(oneBtn)
        bgView.addSubview(twoBtn)
        bgView.addSubview(threeBtn)
        bgView.addSubview(fourBtn)
        bgView.addSubview(fiveBtn)
        bgView.addSubview(sixBtn)
        bgView.addSubview(sevenBtn)
        bgView.addSubview(eightBtn)
        bgView.addSubview(nineBtn)
        bgView.addSubview(backBtn)
        bgView.addSubview(zeroBtn)
        bgView.addSubview(voicePlusBtn)
        bgView.addSubview(voiceMinusBtn)
        bgView.addSubview(channelPlusBtn)
        bgView.addSubview(channelMinusBtn)
        bgView.addSubview(upBtn)
        bgView.addSubview(leftBtn)
        bgView.addSubview(okBtn)
        bgView.addSubview(rightBtn)
        bgView.addSubview(downBtn)
        
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
        onOffBtn.snp.makeConstraints { (make) in
            make.top.equalTo(desLab.snp.bottom).offset(kMargin)
            make.left.equalTo(20)
            make.height.equalTo(kTitleHeight)
            make.width.equalTo(muteBtn)
        }
        muteBtn.snp.makeConstraints { (make) in
            make.top.height.equalTo(onOffBtn)
            make.left.equalTo(onOffBtn.snp.right).offset(20)
            make.width.equalTo(playBtn)
        }
        playBtn.snp.makeConstraints { (make) in
            make.top.height.equalTo(onOffBtn)
            make.left.equalTo(muteBtn.snp.right).offset(20)
            make.width.equalTo(onOffBtn)
            make.right.equalTo(-20)
        }
        oneBtn.snp.makeConstraints { (make) in
            make.top.equalTo(onOffBtn.snp.bottom).offset(20)
            make.left.equalTo(20)
            make.height.equalTo(onOffBtn)
            make.width.equalTo(twoBtn)
        }
        twoBtn.snp.makeConstraints { (make) in
            make.left.equalTo(oneBtn.snp.right).offset(20)
            make.top.height.equalTo(oneBtn)
            make.width.equalTo(threeBtn)
        }
        threeBtn.snp.makeConstraints { (make) in
            make.left.equalTo(twoBtn.snp.right).offset(20)
            make.top.height.width.equalTo(oneBtn)
            make.right.equalTo(-20)
        }
        fourBtn.snp.makeConstraints { (make) in
            make.top.equalTo(oneBtn.snp.bottom).offset(20)
            make.left.height.equalTo(oneBtn)
            make.width.equalTo(fiveBtn)
        }
        fiveBtn.snp.makeConstraints { (make) in
            make.left.equalTo(fourBtn.snp.right).offset(20)
            make.top.height.equalTo(fourBtn)
            make.width.equalTo(sixBtn)
        }
        sixBtn.snp.makeConstraints { (make) in
            make.left.equalTo(fiveBtn.snp.right).offset(20)
            make.top.height.width.equalTo(fourBtn)
            make.right.equalTo(-20)
        }
        sevenBtn.snp.makeConstraints { (make) in
            make.top.equalTo(fourBtn.snp.bottom).offset(20)
            make.left.height.equalTo(oneBtn)
            make.width.equalTo(eightBtn)
        }
        eightBtn.snp.makeConstraints { (make) in
            make.left.equalTo(sevenBtn.snp.right).offset(20)
            make.top.height.equalTo(sevenBtn)
            make.width.equalTo(nineBtn)
        }
        nineBtn.snp.makeConstraints { (make) in
            make.left.equalTo(eightBtn.snp.right).offset(20)
            make.top.height.width.equalTo(sevenBtn)
            make.right.equalTo(-20)
        }
        backBtn.snp.makeConstraints { (make) in
            make.top.equalTo(sevenBtn.snp.bottom).offset(20)
            make.left.height.equalTo(oneBtn)
            make.width.equalTo(zeroBtn)
        }
        
        zeroBtn.snp.makeConstraints { (make) in
            make.left.equalTo(backBtn.snp.right).offset(20)
            make.top.height.equalTo(backBtn)
            make.width.equalTo(eightBtn)
        }
        upBtn.snp.makeConstraints { (make) in
            make.top.equalTo(backBtn.snp.bottom).offset(20)
            make.centerX.equalTo(bgView)
            make.size.equalTo(CGSize.init(width: kTitleHeight, height: kTitleHeight))
        }
        okBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(upBtn)
            make.top.equalTo(upBtn.snp.bottom).offset(kMargin)
            make.size.equalTo(CGSize.init(width: 50, height: 50))
        }
        downBtn.snp.makeConstraints { (make) in
            make.centerX.size.equalTo(upBtn)
            make.top.equalTo(okBtn.snp.bottom).offset(kMargin)
        }
        leftBtn.snp.makeConstraints { (make) in
            make.right.equalTo(okBtn.snp.left).offset(-kMargin)
            make.centerY.equalTo(okBtn)
            make.size.equalTo(upBtn)
        }
        rightBtn.snp.makeConstraints { (make) in
            make.left.equalTo(okBtn.snp.right).offset(kMargin)
            make.centerY.size.equalTo(leftBtn)
        }
        voicePlusBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(okBtn.snp.top)
            make.right.equalTo(leftBtn.snp.left).offset(-kMargin)
            make.height.equalTo(onOffBtn)
            make.left.equalTo(kMargin)
        }
        voiceMinusBtn.snp.makeConstraints { (make) in
            make.top.equalTo(okBtn.snp.bottom)
            make.left.right.height.equalTo(voicePlusBtn)
        }
        channelPlusBtn.snp.makeConstraints { (make) in
            make.bottom.height.equalTo(voicePlusBtn)
            make.left.equalTo(rightBtn.snp.right).offset(kMargin)
            make.right.equalTo(-kMargin)
        }
        channelMinusBtn.snp.makeConstraints { (make) in
            make.top.height.equalTo(voiceMinusBtn)
            make.left.right.equalTo(channelPlusBtn)
        }
    }
    
    lazy var bgView: UIView = {
        let bgview = UIView()
        bgview.backgroundColor = kWhiteColor
        bgview.cornerRadius = 10
        bgview.isUserInteractionEnabled = true
        
        return bgview
    }()
    /// 开关
    lazy var onOffBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("电源", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.cornerRadius = kCornerRadius
        btn.tag = 1001
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 静音
    lazy var muteBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("静音", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1003
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 播放/暂停
    lazy var playBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("播放/暂停", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1023
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 返回
    lazy var backBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("返回", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1045
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 1
    lazy var oneBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("1", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1025
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 2
    lazy var twoBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("2", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1027
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 3
    lazy var threeBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("3", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1029
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 4
    lazy var fourBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("4", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1031
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 5
    lazy var fiveBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("5", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1033
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 6
    lazy var sixBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("6", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1035
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    ///7
    lazy var sevenBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("7", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1037
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 8
    lazy var eightBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("8", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1039
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 9
    lazy var nineBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("9", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1041
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    
    /// 0
    lazy var zeroBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("0", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1043
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 音量+
    lazy var voicePlusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("音量+", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1005
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 音量-
    lazy var voiceMinusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("音量-", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1007
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    
    /// 上
    lazy var upBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("上", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1013
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 左
    lazy var leftBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("左", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1015
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 确定
    lazy var okBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("确定", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1017
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 右
    lazy var rightBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("右", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1019
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 下
    lazy var downBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("下", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1021
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 频道+
    lazy var channelPlusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("频道+", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1009
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 频道-
    lazy var channelMinusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("频道-", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1011
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    
    /// 获取所有品牌
    func dealData(){
        brandList = IRDBManager.shareInstance()?.getAllBrand(by: .IPTV) as! [[String:String]]
        if brandList.count > 0 {
            if dataModel != nil{
                let brandName: String = brandList[Int.init((dataModel?.brand)!)!]["brand"]!
                /// 获取所选品牌的遥控器方案数据
                deviceModelList = IRDBManager.shareInstance()?.getAllNoModel(byBrand: brandName, deviceType: .IPTV) as! [DeviceM]
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
//                requestDeviceId()
                keyMaxId += 1
                showStudyAlert(funcId: keyMaxId)
            }
        }else{
            if btn.accessibilityIdentifier != nil{// 自定义按键
                sendCmdCustomMqtt(isTest: false, funcId: Int.init(btn.accessibilityIdentifier!)!,code: "")
            }else{
                if controlCode == nil{
                    MBProgressHUD.showAutoDismissHUD(message: "未找到该遥控器")
                    return
                }
                sendCmdMqtt(studyCode: BLTAssist.nomarlCode(controlCode, key: currTag - 1000))
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
        let paramDic:[String:Any] = ["msg_type":"app_ir_extra_study","id":controlId,"custom_id":funcId,"custom_num":customNum,"custom_name":name]
        
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
                    
                }
            }else if type == "app_ir_extra_study_re" && phone == userDefaults.string(forKey: "phone"){
                self.hud?.hide(animated: true)
                
                if result["code"].intValue == kQuestSuccessTag{
                    
                    //1：成功；0：失败 2：学习开始（为区分学习返回时的第二次携码返回）
                    if result["data"]["ret"].intValue == 1{
                        MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                        waitAlert?.hide()
                        
                        showStudySuccessAlert(funcId: result["data"]["func_id"].intValue, code: result["data"]["code"].stringValue)
                    }else if result["data"]["ret"].intValue == 0{// 学习失败
                        MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                        showStudyFailedAlert(funcId: result["app_interface_tag"].intValue)
                    }
                }else{// 学习失败
                    MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                    showStudyFailedAlert(funcId: result["app_interface_tag"].intValue)
                }
            }
            
        }
    }
}
