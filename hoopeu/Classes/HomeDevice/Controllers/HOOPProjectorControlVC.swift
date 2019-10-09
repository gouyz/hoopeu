//
//  HOOPProjectorControlVC.swift
//  hoopeu
//  投影仪遥控器
//  Created by gouyz on 2019/3/1.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON
import AudioToolbox

class HOOPProjectorControlVC: HOOPBaseControlVC {

    /// 按钮位置
    var keyNumList: [String:Int] = ["pjt_on":1001,"pjt_off":1003,"pjt_cpu":1005,"pjt_video":1007,"pjt_xinhao":1009,"pjt_bj_plus":1011,"pjt_bj_minus":1013,"pjt_img_plus":1015,"pjt_img_minus":1017,"pjt_menu":1019,"pjt_ok":1021,"pjt_up":1023,"pjt_left":1025,"pjt_right":1027,"pjt_down":1029,"pjt_voice_plus":1033,"pjt_voice_minus":1035,"pjt_out":1031,"pjt_mute":1037,"pjt_auto":1039,"pjt_pause":1041,"pjt_light":1043]
    /// 当前操作按键tag
    var currTag:Int = 1001
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "投影仪遥控器"
        
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
        bgView.addSubview(outBtn)
        bgView.addSubview(cpuBtn)
        bgView.addSubview(menuBtn)
        bgView.addSubview(xinhaoBtn)
        bgView.addSubview(bianJiaoPlusBtn)
        bgView.addSubview(imgPlusBtn)
        bgView.addSubview(voicePlusBtn)
        bgView.addSubview(bianJiaoMinusBtn)
        bgView.addSubview(imgMinusBtn)
        bgView.addSubview(voiceMinusBtn)
        bgView.addSubview(lightBtn)
        bgView.addSubview(pauseBtn)
        bgView.addSubview(videoBtn)
        bgView.addSubview(onBtn)
        bgView.addSubview(offBtn)
        bgView.addSubview(muteBtn)
        bgView.addSubview(autoBtn)
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
        outBtn.snp.makeConstraints { (make) in
            make.top.equalTo(desLab.snp.bottom).offset(kMargin)
            make.left.equalTo(kMargin)
            make.height.equalTo(kTitleHeight)
            make.width.equalTo(cpuBtn)
        }
        cpuBtn.snp.makeConstraints { (make) in
            make.top.height.equalTo(outBtn)
            make.left.equalTo(outBtn.snp.right).offset(20)
            make.width.equalTo(menuBtn)
        }
        menuBtn.snp.makeConstraints { (make) in
            make.top.height.equalTo(outBtn)
            make.left.equalTo(cpuBtn.snp.right).offset(20)
            make.width.equalTo(xinhaoBtn)
        }
        xinhaoBtn.snp.makeConstraints { (make) in
            make.top.width.height.equalTo(outBtn)
            make.left.equalTo(menuBtn.snp.right).offset(20)
            make.right.equalTo(-kMargin)
        }
        bianJiaoPlusBtn.snp.makeConstraints { (make) in
            make.top.equalTo(outBtn.snp.bottom).offset(20)
            make.left.equalTo(20)
            make.height.equalTo(outBtn)
            make.width.equalTo(imgPlusBtn)
        }
        imgPlusBtn.snp.makeConstraints { (make) in
            make.left.equalTo(bianJiaoPlusBtn.snp.right).offset(20)
            make.top.height.equalTo(bianJiaoPlusBtn)
            make.width.equalTo(voicePlusBtn)
        }
        voicePlusBtn.snp.makeConstraints { (make) in
            make.left.equalTo(imgPlusBtn.snp.right).offset(20)
            make.top.height.width.equalTo(bianJiaoPlusBtn)
            make.right.equalTo(-20)
        }
        bianJiaoMinusBtn.snp.makeConstraints { (make) in
            make.top.equalTo(bianJiaoPlusBtn.snp.bottom).offset(20)
            make.left.height.equalTo(bianJiaoPlusBtn)
            make.width.equalTo(imgMinusBtn)
        }
        imgMinusBtn.snp.makeConstraints { (make) in
            make.left.equalTo(bianJiaoMinusBtn.snp.right).offset(20)
            make.top.height.equalTo(bianJiaoMinusBtn)
            make.width.equalTo(voiceMinusBtn)
        }
        voiceMinusBtn.snp.makeConstraints { (make) in
            make.left.equalTo(imgMinusBtn.snp.right).offset(20)
            make.top.height.width.equalTo(bianJiaoMinusBtn)
            make.right.equalTo(-20)
        }
        lightBtn.snp.makeConstraints { (make) in
            make.top.equalTo(bianJiaoMinusBtn.snp.bottom).offset(20)
            make.left.height.equalTo(bianJiaoPlusBtn)
            make.width.equalTo(pauseBtn)
        }
        pauseBtn.snp.makeConstraints { (make) in
            make.left.equalTo(lightBtn.snp.right).offset(20)
            make.top.height.equalTo(lightBtn)
            make.width.equalTo(videoBtn)
        }
        videoBtn.snp.makeConstraints { (make) in
            make.left.equalTo(pauseBtn.snp.right).offset(20)
            make.top.height.width.equalTo(lightBtn)
            make.right.equalTo(-20)
        }
        onBtn.snp.makeConstraints { (make) in
            make.top.equalTo(lightBtn.snp.bottom).offset(20)
            make.right.equalTo(pauseBtn.snp.left).offset(-kMargin)
            make.size.equalTo(CGSize.init(width: 60, height: 50))
        }
        
        offBtn.snp.makeConstraints { (make) in
            make.left.equalTo(pauseBtn.snp.right).offset(kMargin)
            make.top.size.equalTo(onBtn)
        }
        upBtn.snp.makeConstraints { (make) in
            make.top.equalTo(onBtn.snp.bottom).offset(20)
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
        muteBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(okBtn.snp.top)
            make.right.equalTo(leftBtn.snp.left).offset(-kMargin)
            make.height.equalTo(outBtn)
            make.left.equalTo(kMargin)
        }
        autoBtn.snp.makeConstraints { (make) in
            make.bottom.height.equalTo(muteBtn)
            make.left.equalTo(rightBtn.snp.right).offset(kMargin)
            make.right.equalTo(-kMargin)
        }
    }
    
    lazy var bgView: UIView = {
        let bgview = UIView()
        bgview.backgroundColor = kWhiteColor
        bgview.cornerRadius = 10
        bgview.isUserInteractionEnabled = true
        
        return bgview
    }()
    /// 退出
    lazy var outBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("退出", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.cornerRadius = kCornerRadius
        btn.tag = 1031
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 电脑
    lazy var cpuBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("电脑", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.cornerRadius = kCornerRadius
        btn.tag = 1005
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 菜单
    lazy var menuBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("菜单", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.cornerRadius = kCornerRadius
        btn.tag = 1019
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 信号源
    lazy var xinhaoBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("信号源", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.cornerRadius = kCornerRadius
        btn.tag = 1009
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 开
    lazy var onBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("开机", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.cornerRadius = kCornerRadius
        btn.tag = 1001
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 关
    lazy var offBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("关机", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.cornerRadius = kCornerRadius
        btn.tag = 1003
        
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
        btn.tag = 1037
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 变焦+
    lazy var bianJiaoPlusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("变焦+", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1011
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 变焦-
    lazy var bianJiaoMinusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("变焦-", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1013
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 画面+
    lazy var imgPlusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("画面+", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1015
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 画面-
    lazy var imgMinusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("画面-", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1017
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
        btn.tag = 1033
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
        btn.tag = 1035
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 亮度
    lazy var lightBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("亮度", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1043
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 暂停
    lazy var pauseBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("暂停", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1041
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 视频
    lazy var videoBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("视频", for: .normal)
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
        btn.tag = 1023
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
        btn.tag = 1025
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
        btn.tag = 1021
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
        btn.tag = 1027
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
        btn.tag = 1029
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 自动
    lazy var autoBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("自动", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1039
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    
    /// 获取所有品牌
    func dealData(){
        brandList = IRDBManager.shareInstance()?.getAllBrand(by: .PJT) as! [[String:String]]
        if brandList.count > 0 {
            if dataModel != nil{
                let brandName: String = brandList[Int.init((dataModel?.brand)!)!]["brand"]!
                /// 获取所选品牌的遥控器方案数据
                deviceModelList = IRDBManager.shareInstance()?.getAllNoModel(byBrand: brandName, deviceType: .PJT) as! [DeviceM]
                controlCode = deviceModelList[Int.init((dataModel?.code_bark)!)!].code
                
                if dataModel?.funcList.count > 0{// 有自定义按键
                    for item in (dataModel?.funcList)!{
                        for key in keyNumList.keys{
                            if key == item.custom_num{
                                let tag = keyNumList[key]
                                let btn: UIButton = self.view.viewWithTag(tag!) as! UIButton
                                btn.setTitle(item.ctrl_name, for: .normal)
                                /// 记录自定义按键id
                                btn.accessibilityIdentifier = item.sensor_id
                                let keyId: Int = Int.init(item.sensor_id!)!
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
                MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                
                if result["code"].intValue == kQuestSuccessTag{
                    waitAlert?.hide()
                    
                    showStudySuccessAlert(funcId: result["data"]["func_id"].intValue, code: result["data"]["code"].stringValue)
                }else{// 学习失败
                    showStudyFailedAlert(funcId: result["app_interface_tag"].intValue)
                }
            }
            
        }
    }
}
