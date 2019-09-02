//
//  HOOPUnBindDeviceVC.swift
//  hoopeu
//  解绑设备
//  Created by gouyz on 2019/2/21.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

class HOOPUnBindDeviceVC: GYZBaseVC {
    
    var deviceId: String = ""
    var userToken: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "解绑设备"
        self.view.backgroundColor = kWhiteColor
        
        setUpUI()
        mqttSetting()
    }
    
    func setUpUI(){
        view.addSubview(bgView)
        bgView.addSubview(codeLab)
        bgView.addSubview(phoneTxtFiled)
        bgView.addSubview(lineView)
        bgView.addSubview(codeTxtFiled)
        bgView.addSubview(codeBtn)
        bgView.addSubview(lineView1)
        bgView.addSubview(toPhoneTxtFiled)
        bgView.addSubview(lineView2)
        bgView.addSubview(desLab)
        bgView.addSubview(desContentLab)
        bgView.addSubview(saveBtn)
        bgView.addSubview(shouquanBtn)
        
        bgView.snp.makeConstraints { (make) in
            make.top.equalTo(kTitleAndStateHeight + kMargin)
            make.left.right.bottom.equalTo(view)
        }
        phoneTxtFiled.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.left.equalTo(codeLab.snp.right).offset(kMargin)
            make.top.equalTo(bgView)
            make.height.equalTo(50)
        }
        codeLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.centerY.equalTo(phoneTxtFiled)
            make.size.equalTo(CGSize.init(width: 60, height: 30))
        }
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(phoneTxtFiled)
            make.top.equalTo(phoneTxtFiled.snp.bottom)
            make.height.equalTo(klineWidth)
        }
        codeTxtFiled.snp.makeConstraints { (make) in
            make.left.height.equalTo(phoneTxtFiled)
            make.right.equalTo(codeBtn.snp.left).offset(-kMargin)
            make.top.equalTo(lineView.snp.bottom)
        }
        codeBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(codeTxtFiled)
            make.right.equalTo(-kMargin)
            make.size.equalTo(CGSize.init(width: 100, height: 30))
        }
        lineView1.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(lineView)
            make.top.equalTo(codeTxtFiled.snp.bottom)
        }
        
        toPhoneTxtFiled.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(phoneTxtFiled)
            make.top.equalTo(lineView1.snp.bottom)
        }
        lineView2.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(lineView)
            make.top.equalTo(toPhoneTxtFiled.snp.bottom)
        }
        desLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.top.equalTo(lineView2.snp.bottom).offset(kMargin)
            make.height.equalTo(30)
        }
        desContentLab.snp.makeConstraints { (make) in
            make.left.right.equalTo(desLab)
            make.top.equalTo(desLab.snp.bottom).offset(5)
        }
        
        saveBtn.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(shouquanBtn.snp.left).offset(-20)
            make.height.equalTo(kBottomTabbarHeight)
            make.top.equalTo(desContentLab.snp.bottom).offset(kTitleHeight)
            make.width.equalTo(shouquanBtn)
        }
        shouquanBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-20)
            make.top.height.width.equalTo(saveBtn)
            make.left.equalTo(saveBtn.snp.right).offset(20)
        }
    }
    ///
    lazy var bgView : UIView = {
        let bgview = UIView()
        bgview.backgroundColor = kWhiteColor
        
        return bgview
    }()
    /// 区号代码
    lazy var codeLab : UILabel = {
        let lab = UILabel()
        lab.textColor = kWhiteColor
        lab.backgroundColor = kBlueFontColor
        lab.font = k15Font
        lab.cornerRadius = 15
        lab.textAlignment = .center
        lab.text = "+86"
        lab.addOnClickListener(target: self, action: #selector(onClickedSelectCode))
        
        return lab
    }()
    /// 手机号
    lazy var phoneTxtFiled : UITextField = {
        
        let textFiled = UITextField()
        textFiled.font = k15Font
        textFiled.textColor = kBlackFontColor
        textFiled.keyboardType = .numberPad
        textFiled.clearButtonMode = .whileEditing
        textFiled.placeholder = "请输入手机号"
        
        return textFiled
    }()
    /// 分割线
    lazy var lineView : UIView = {
        let line = UIView()
        line.backgroundColor = kGrayLineColor
        return line
    }()
    /// 验证码
    lazy var codeTxtFiled : UITextField = {
        
        let textFiled = UITextField()
        textFiled.font = k15Font
        textFiled.textColor = kBlackFontColor
        textFiled.keyboardType = .numberPad
        textFiled.clearButtonMode = .whileEditing
        textFiled.placeholder = "请输入验证码"
        
        return textFiled
    }()
    /// 获取验证码按钮
    lazy var codeBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitle("获取验证码", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.titleLabel?.textAlignment = .center
        btn.backgroundColor = kBtnClickBGColor
        btn.addTarget(self, action: #selector(clickedCodeBtn), for: .touchUpInside)
        
        btn.cornerRadius = 15
        
        return btn
    }()
    /// 分割线
    lazy var lineView1 : UIView = {
        let line = UIView()
        line.backgroundColor = kGrayLineColor
        return line
    }()
    /// 授权手机号
    lazy var toPhoneTxtFiled : UITextField = {
        
        let textFiled = UITextField()
        textFiled.font = k15Font
        textFiled.textColor = kBlackFontColor
        textFiled.keyboardType = .numberPad
        textFiled.clearButtonMode = .whileEditing
        textFiled.placeholder = "请输入授权手机号"
        
        return textFiled
    }()
    /// 分割线
    lazy var lineView2 : UIView = {
        let line = UIView()
        line.backgroundColor = kGrayLineColor
        return line
    }()
    /// 说明
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlueFontColor
        lab.text = "说明："
        
        return lab
    }()
    ///
    lazy var desContentLab : UILabel = {
        let lab = UILabel()
        lab.font = k13Font
        lab.textColor = kBlackFontColor
        lab.numberOfLines = 0
        lab.text = "1.解绑后本账号无法查看叮当宝贝信息。\n2.解绑并授权其他账号关联此叮当宝贝。\n3.被授权手机号必须已注册。"
        
        return lab
    }()
    
    /// 解绑
    lazy var saveBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kRedFontColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("解绑", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = kCornerRadius
        btn.tag = 101
        
        btn.addTarget(self, action: #selector(clickedSaveBtn(sender:)), for: .touchUpInside)
        
        return btn
    }()
    /// 解绑并授权
    lazy var shouquanBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBlueFontColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("解绑并授权", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = kCornerRadius
        btn.tag = 102
        
        btn.addTarget(self, action: #selector(clickedSaveBtn(sender:)), for: .touchUpInside)
        
        return btn
    }()
    /// 保存
    @objc func clickedSaveBtn(sender: UIButton){
        let tag = sender.tag
        if !validPhoneNO() {
            return
        }
        if codeTxtFiled.text!.isEmpty {
            MBProgressHUD.showAutoDismissHUD(message: "请输入验证码")
            return
        }
        if tag == 102 {
            if toPhoneTxtFiled.text!.isEmpty {
                MBProgressHUD.showAutoDismissHUD(message: "请输入授权手机号")
                return
            }else if !toPhoneTxtFiled.text!.isMobileNumber(){
                MBProgressHUD.showAutoDismissHUD(message: "请输入正确的授权手机号")
                return
            }
        }
        requestCheckCode()
    }
    /// 获取验证码
    @objc func clickedCodeBtn(){
        if !validPhoneNO() {
            return
        }
        requestCode()
    }
    /// 选择地区代码
    @objc func onClickedSelectCode(){
        UsefulPickerView.showSingleColPicker("选择地区代码", data: PHONECODE, defaultSelectedIndex: nil) {[weak self] (index, value) in
            
            self?.codeLab.text = value
        }
    }
    /// 判断手机号是否有效
    ///
    /// - Returns:
    func validPhoneNO() -> Bool{
        
        if phoneTxtFiled.text!.isEmpty {
            MBProgressHUD.showAutoDismissHUD(message: "请输入手机号")
            return false
        }
        if phoneTxtFiled.text!.isMobileNumber(){
            return true
        }else{
            MBProgressHUD.showAutoDismissHUD(message: "请输入正确的手机号")
            return false
        }
        
    }
    ///获取验证码
    func requestCode(){
        
        weak var weakSelf = self
        createHUD(message: "获取中...")
        
        GYZNetWork.requestNetwork("sms/send",isToken:false, parameters: ["phone":phoneTxtFiled.text!,"type":2],  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                weakSelf?.codeBtn.startSMSWithDuration(duration: 60)
                
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    
    /// 检测验证码
    func requestCheckCode(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("sms/validate",isToken:false, parameters: ["phone":phoneTxtFiled.text!,"code":codeTxtFiled.text!],  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
//                weakSelf?.userToken = userDefaults.string(forKey: "token")
                userDefaults.set(response["data"].stringValue, forKey: "token")
//                weakSelf?.requestRemovePhone(token: userToken!)
                weakSelf?.sendMqttCmd()
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    
    /// 解绑
    func requestRemovePhone(token: String){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        
        var paramDic: [String: Any] = ["phone":phoneTxtFiled.text!,"deviceId":deviceId]
        if !toPhoneTxtFiled.text!.isEmpty {
            paramDic["toPhone"] = toPhoneTxtFiled.text!
        }
        
        GYZNetWork.requestNetwork("device/remove", parameters: paramDic,  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                userDefaults.set(token, forKey: "token")
                weakSelf?.clickedBackBtn()
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    
    func goBack(){
        for i in 0..<(navigationController?.viewControllers.count)!{
            
            if navigationController?.viewControllers[i].isKind(of: HOOPDeviceManagerVC.self) == true {
                
                let vc = navigationController?.viewControllers[i] as! HOOPDeviceManagerVC
                vc.isRefresh = true
                _ = navigationController?.popToViewController(vc, animated: true)
                
                break
            }
        }
    }
    
    /// mqtt发布主题 查询设备在线状态
    func sendMqttCmd(){
        var paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","phone":phoneTxtFiled.text!,"msg_type":"app_user_change","app_interface_tag":"ok"]
        if !toPhoneTxtFiled.text!.isEmpty {
            paramDic["toPhone"] = toPhoneTxtFiled.text!
        }
        
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
            
            if type == "app_user_change_re" && phone == phoneTxtFiled.text!{
                userDefaults.set(userToken, forKey: "token")
                goBack()
            }
            
        }
    }
}

