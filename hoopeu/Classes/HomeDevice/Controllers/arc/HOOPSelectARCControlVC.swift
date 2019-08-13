//
//  HOOPSelectARCControlVC.swift
//  hoopeu
//  选择空调遥控器
//  Created by gouyz on 2019/2/28.
//  Copyright © 2019 gyz. All rights reserved.
//  https://www.cnblogs.com/mafeng/p/5777819.html

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

class HOOPSelectARCControlVC: GYZBaseVC {

    /// 当前匹配组的步骤
    var stepIndex: Int = 1
    /// 当前匹配组
    var curMatchIndex: Int = 0
    /// 当前匹配组的品牌下标
    var curMatchBrandIndex: Int = 0
    var deviceType: DeviceType = .ARC
    var ir_type: String = "ir_air"
    /// 品牌名称
    var brandName: String = ""
    var dataList: [DeviceM] = [DeviceM]()
    /// 学习按键的code
    var mKeyCodeTag: NSInteger = 0
    /// 学习按键的名称
    var mKeyName: String = ""
    /// 学习按键设备类型名称
    var mDeviceTypeName: String = ""
    /// 临时id
    var deviceId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "选择遥控器"
        
        
        setUpUI()
        numLab.text = "第\(curMatchIndex + 1)/\(dataList.count)套方案"
        initStepKey()
        requestDeviceId()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if mqtt == nil {
            mqttSetting()
        }
    }
    
    func setUpUI(){
        view.addSubview(bgView)
        bgView.addSubview(desLab)
        bgView.addSubview(iconView)
        bgView.addSubview(stepLab)
        bgView.addSubview(numLab)
        bgView.addSubview(sendBtn)
        bgView.addSubview(noResponseBtn)
        bgView.addSubview(responseBtn)
        
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(kTitleAndStateHeight + 20)
            make.bottom.equalTo(-20)
        }
        desLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.top.equalTo(20)
        }
        iconView.snp.makeConstraints { (make) in
            make.top.equalTo(desLab.snp.bottom).offset(kTitleHeight)
            make.centerX.equalTo(bgView)
            make.size.equalTo(CGSize.init(width: 120, height: 70))
        }
        stepLab.snp.makeConstraints { (make) in
            make.top.equalTo(iconView.snp.bottom).offset(kTitleHeight)
            make.left.right.equalTo(desLab)
            make.height.equalTo(30)
        }
        numLab.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(stepLab)
            make.top.equalTo(stepLab.snp.bottom)
        }
        
        sendBtn.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(numLab.snp.bottom).offset(30)
            make.height.equalTo(kUIButtonHeight)
        }
        noResponseBtn.snp.makeConstraints { (make) in
            make.left.height.equalTo(sendBtn)
            make.top.equalTo(sendBtn.snp.bottom).offset(20)
            make.width.equalTo(80)
        }
        responseBtn.snp.makeConstraints { (make) in
            make.top.height.width.equalTo(noResponseBtn)
            make.right.equalTo(sendBtn)
        }
    }
    
    lazy var bgView: UIView = {
        let bgview = UIView()
        bgview.backgroundColor = kWhiteColor
        bgview.cornerRadius = 10
        
        return bgview
    }()
    ///
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kGaryFontColor
        lab.numberOfLines = 0
        lab.textAlignment = .center
        lab.text = "请把叮当宝贝对准您的家电设备，\n点击发射按钮发射红外指令，\n然后选择家电设备的响应结果。"
        
        return lab
    }()
    lazy var iconView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_arc_default"))
    ///步骤
    lazy var stepLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        lab.textAlignment = .center
        
        return lab
    }()
    ///方案数量
    lazy var numLab : UILabel = {
        let lab = UILabel()
        lab.font = k13Font
        lab.textColor = kBlackFontColor
        lab.textAlignment = .center
        
        return lab
    }()
    
    /// 发射
    lazy var sendBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("点击发射", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = 8
        
        btn.addTarget(self, action: #selector(clickedSendBtn), for: .touchUpInside)
        
        return btn
    }()
    /// 有响应
    lazy var responseBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnNoClickBGColor
        btn.setTitleColor(kHeightGaryFontColor, for: .normal)
        btn.setTitle("有响应", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.borderColor = kBtnNoClickBGColor
        btn.borderWidth = klineWidth
        btn.cornerRadius = 8
        btn.isEnabled = false
        
        btn.addTarget(self, action: #selector(clickedResponseBtn), for: .touchUpInside)
        
        return btn
    }()
    /// 没响应
    lazy var noResponseBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnNoClickBGColor
        btn.setTitleColor(kHeightGaryFontColor, for: .normal)
        btn.setTitle("没响应", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.borderColor = kBtnNoClickBGColor
        btn.borderWidth = klineWidth
        btn.cornerRadius = 8
        btn.isEnabled = false
        
        btn.addTarget(self, action: #selector(clickedNoResponseBtn), for: .touchUpInside)
        
        return btn
    }()
    /// 发射
    @objc func clickedSendBtn(){
        var code: String = ""
        if deviceType == .ARC {
            code = (ARCStateCtr.shareInstance()?.getARCKeyCode(dataList[curMatchIndex].code, withTag: mKeyCodeTag,withControlId: deviceId))!
        }else{
            code = BLTAssist.nomarlCode(dataList[curMatchIndex].code, key: mKeyCodeTag)
        }
        sendCmdMqtt(code: code)
        
        noResponseBtn.backgroundColor = kWhiteColor
        noResponseBtn.borderColor = kBtnClickBGColor
        noResponseBtn.setTitleColor(kBlueFontColor, for: .normal)
        noResponseBtn.isEnabled = true
        
        responseBtn.backgroundColor = kWhiteColor
        responseBtn.borderColor = kBtnClickBGColor
        responseBtn.setTitleColor(kBlueFontColor, for: .normal)
        responseBtn.isEnabled = true
    }
    /// 有响应
    @objc func clickedResponseBtn(){
        noEnableBtn()
        if stepIndex == 3 {//第3步时跳转保存页面
            goSaveArcControl()
        }else{
            stepIndex += 1
            initStepKey()
        }
    }
    /// 没响应
    @objc func clickedNoResponseBtn(){
        
        if curMatchIndex == dataList.count - 1 {
            MBProgressHUD.showAutoDismissHUD(message: "品牌\(brandName) 没有适配的遥控器，请选择其他品牌或自定义遥控器")
            return
        }
        noEnableBtn()
        curMatchIndex += 1
        numLab.text = "第\(curMatchIndex + 1)/\(dataList.count)套方案"
        stepIndex = 1
        initStepKey()
    }
    
    /// 设置按钮不可点击
    func noEnableBtn(){
        noResponseBtn.backgroundColor = kBtnNoClickBGColor
        noResponseBtn.borderColor = kBtnNoClickBGColor
        noResponseBtn.setTitleColor(kHeightGaryFontColor, for: .normal)
        noResponseBtn.isEnabled = false
        
        responseBtn.backgroundColor = kBtnNoClickBGColor
        responseBtn.borderColor = kBtnNoClickBGColor
        responseBtn.setTitleColor(kHeightGaryFontColor, for: .normal)
        responseBtn.isEnabled = false
    }
    /// 保存遥控器
    func goSaveArcControl(){
        let vc = HOOPSaveARCControlVC()
        vc.curMatchIndex = self.curMatchIndex
        vc.curMatchBrandIndex = self.curMatchBrandIndex
        vc.ir_type = self.ir_type
        vc.deviceId = self.deviceId
        vc.deviceType = self.deviceType
        if deviceType == .ARC {
            vc.onKeyCode = (ARCStateCtr.shareInstance()?.getARCKeyCode(dataList[curMatchIndex].code, withTag: 0x77,withControlId: deviceId))!
            vc.offKeyCode = (ARCStateCtr.shareInstance()?.getARCKeyCode(dataList[curMatchIndex].code, withTag: 0x88,withControlId: deviceId))!
        }else if deviceType == .TV || deviceType == .ADO {// 除空调外,开和关的code一样
            let code:String = BLTAssist.nomarlCode(dataList[curMatchIndex].code, key: 11)
            vc.onKeyCode = code
            vc.offKeyCode = code
        }else{
            let code:String = BLTAssist.nomarlCode(dataList[curMatchIndex].code, key: 1)
            vc.onKeyCode = code
            vc.offKeyCode = code
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func initStepKey(){
        /// 设备子类型 ”ir_air”:空调；”ir_tv”：电视 ；”ir_stb”:机顶盒；”ir_iptv”:IPTV遥控器；”ir_sound”:音响；”ir_proj”:投影仪；”ir_fan:”风扇;”ir_other”:自定义遥控
        switch deviceType {
        case .ARC: //空调
            ir_type = "ir_air"
            mDeviceTypeName = "空调"
            if stepIndex == 1{
                mKeyName = "开"
                mKeyCodeTag = 0x77
            }else if stepIndex == 2{
                mKeyName = "温度+"
                mKeyCodeTag = 0x06
            }else if stepIndex == 3{
                mKeyName = "温度-"
                mKeyCodeTag = 0x07
            }
        case .TV: //电视机
            ir_type = "ir_tv"
            mDeviceTypeName = "电视机"
            if stepIndex == 1{
                mKeyName = "电源"
                mKeyCodeTag = 11
            }else if stepIndex == 2{
                mKeyName = "菜单"
                mKeyCodeTag = 5
            }else if stepIndex == 3{
                mKeyName = "频道+"
                mKeyCodeTag = 3
            }
        case .tvBox: //机顶盒
            ir_type = "ir_stb"
            mDeviceTypeName = "机顶盒"
            if stepIndex == 1{
                mKeyName = "待机"
                mKeyCodeTag = 1
            }else if stepIndex == 2{
                mKeyName = "菜单"
                mKeyCodeTag = 41
            }else if stepIndex == 3{
                mKeyName = "频道+"
                mKeyCodeTag = 45
            }
        case .IPTV: //IPTV 网络电视
            ir_type = "ir_iptv"
            mDeviceTypeName = "网络电视"
            if stepIndex == 1{
                mKeyName = "电源"
                mKeyCodeTag = 1
            }else if stepIndex == 2{
                mKeyName = "频道+"
                mKeyCodeTag = 9
            }else if stepIndex == 3{
                mKeyName = "音量+"
                mKeyCodeTag = 5
            }
        case .ADO: //音响
            ir_type = "ir_sound"
            mDeviceTypeName = "音响"
            if stepIndex == 1{
                mKeyName = "电源"
                mKeyCodeTag = 11
            }else if stepIndex == 2{
                mKeyName = "菜单"
                mKeyCodeTag = 33
            }else if stepIndex == 3{
                mKeyName = "静音"
                mKeyCodeTag = 15
            }
        case .PJT: //投影仪
            ir_type = "ir_proj"
            mDeviceTypeName = "投影仪"
            if stepIndex == 1{
                mKeyName = "开机"
                mKeyCodeTag = 1
            }else if stepIndex == 2{
                mKeyName = "菜单"
                mKeyCodeTag = 19
            }else if stepIndex == 3{
                mKeyName = "音量+"
                mKeyCodeTag = 33
            }
        case .fan: //风扇
            ir_type = "ir_fan"
            mDeviceTypeName = "风扇"
            if stepIndex == 1{
                mKeyName = "开关"
                mKeyCodeTag = 1
            }else if stepIndex == 2{
                mKeyName = "风量"
                mKeyCodeTag = 37
            }else if stepIndex == 3{
                mKeyName = "摇头"
                mKeyCodeTag = 5
            }
        default:
            break
        }
        
        stepLab.text = "步骤\(stepIndex)/3：发射 \(mDeviceTypeName) \(mKeyName)键"
    }
    /// 获取临时id
    func requestDeviceId(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("homeCtrl", parameters: nil,  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                weakSelf?.deviceId = response["data"].stringValue
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    /// 按键学习
    func sendCmdMqtt(code: String){
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","msg_type":"app_ir_study","phone":userDefaults.string(forKey: "phone") ?? "","ir_id":deviceId,"ir_type":ir_type,"study_code":code,"app_interface_tag":""]

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
            
            if type == "app_ir_study_re" && phone == userDefaults.string(forKey: "phone"){
                self.hud?.hide(animated: true)
                if result["code"].intValue == kQuestSuccessTag{
                    
//                    MBProgressHUD.showAutoDismissHUD(message: "学习成功")
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                }
            }
            
        }
    }
}
