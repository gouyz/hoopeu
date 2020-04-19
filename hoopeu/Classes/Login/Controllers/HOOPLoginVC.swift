//
//  HOOPLoginVC.swift
//  hoopeu
//  登录
//  Created by gouyz on 2019/2/18.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

class HOOPLoginVC: GYZBaseVC {
    /// 是否有网络
    var isNetWork: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "登  录"
        self.view.backgroundColor = kWhiteColor
        
        let rightBtn = UIButton(type: .custom)
        rightBtn.setTitle("忘记密码", for: .normal)
        rightBtn.titleLabel?.font = k15Font
        rightBtn.setTitleColor(kBlueFontColor, for: .normal)
        rightBtn.frame = CGRect.init(x: 0, y: 0, width: kTitleHeight, height: kTitleHeight)
        rightBtn.addTarget(self, action: #selector(onClickRightBtn), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBtn)
        
        setupUI()
        phoneTxtFiled.text = userDefaults.string(forKey: "phone")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if mqtt == nil {
            mqttSetting()
        }
    }
    
    /// 创建UI
    func setupUI(){
        view.addSubview(desLab)
        view.addSubview(codeLab)
        view.addSubview(phoneTxtFiled)
        view.addSubview(lineView)
        view.addSubview(pwdTxtFiled)
        view.addSubview(seePwdBtn)
        view.addSubview(lineView1)
        view.addSubview(registerBtn)
        view.addSubview(nextBtn)
        
        desLab.snp.makeConstraints { (make) in
            make.top.equalTo(kTitleAndStateHeight * 2)
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.height.equalTo(kTitleAndStateHeight)
        }
        phoneTxtFiled.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.left.equalTo(codeLab.snp.right).offset(kMargin)
            make.top.equalTo(desLab.snp.bottom).offset(kTitleAndStateHeight)
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
        pwdTxtFiled.snp.makeConstraints { (make) in
            make.left.height.equalTo(phoneTxtFiled)
            make.top.equalTo(lineView.snp.bottom)
            make.right.equalTo(seePwdBtn.snp.left).offset(-kMargin)
        }
        seePwdBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(pwdTxtFiled)
            make.right.equalTo(-kMargin)
            make.size.equalTo(CGSize.init(width: 20, height: 20))
        }
        lineView1.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(lineView)
            make.top.equalTo(pwdTxtFiled.snp.bottom)
        }
        
        registerBtn.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.bottom.equalTo(-kTitleHeight)
            make.size.equalTo(CGSize.init(width: kTitleHeight, height: kTitleHeight))
        }
        nextBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.bottom.size.equalTo(registerBtn)
        }
    }
    ///
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.textColor = kBlackFontColor
        lab.font = k18Font
        lab.textAlignment = .center
        lab.text = "\"欢迎回来\""
        
        return lab
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
    /// 密码
    lazy var pwdTxtFiled : UITextField = {
        
        let textFiled = UITextField()
        textFiled.font = k15Font
        textFiled.textColor = kBlackFontColor
        textFiled.isSecureTextEntry = true
        textFiled.clearButtonMode = .whileEditing
        textFiled.placeholder = "请输入密码"
        
        return textFiled
    }()
    /// 查看密码
    lazy var seePwdBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "icon_no_see_pwd"), for: .normal)
        btn.setImage(UIImage.init(named: "icon_see_pwd"), for: .selected)
        
        btn.addTarget(self, action: #selector(clickedSeePwdBtn), for: .touchUpInside)
        
        return btn
    }()
    /// 分割线
    lazy var lineView1 : UIView = {
        let line = UIView()
        line.backgroundColor = kGrayLineColor
        return line
    }()
    /// 注册
    lazy var registerBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitleColor(kBlueFontColor, for: .normal)
        btn.setTitle("注册", for: .normal)
        btn.titleLabel?.font = k18Font
        
        btn.addTarget(self, action: #selector(clickedRegisterBtn), for: .touchUpInside)
        
        return btn
    }()
    /// 下一步
    lazy var nextBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "icon_next_btn"), for: .normal)
        
        btn.addTarget(self, action: #selector(clickedNextBtn), for: .touchUpInside)
        
        return btn
    }()
    /// 忘记密码
    @objc func onClickRightBtn(){
        let vc = HOOPRegisterPhoneVC()
        vc.isModifyPwd = true
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 显示密码
    @objc func clickedSeePwdBtn(){
        seePwdBtn.isSelected = !seePwdBtn.isSelected
        pwdTxtFiled.isSecureTextEntry = !seePwdBtn.isSelected
    }
    /// 注册
    @objc func clickedRegisterBtn(){
        let vc = HOOPRegisterPhoneVC()
        vc.isModifyPwd = false
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 下一步
    @objc func clickedNextBtn(){
//        goLinkPower()
        hiddenKeyBoard()

        if !validPhoneNO() {
            return
        }

        if pwdTxtFiled.text!.isEmpty {
            MBProgressHUD.showAutoDismissHUD(message: "请输入密码")
            return
        }
        requestLogin()
    }
    /// 连接电源
    func goLinkPower(){
//        let vc = HOOPLinkPowerVC()
        let vc = HOOPPhoneNetWorkVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    func goHomeVC(){
        let menuContrainer = FWSideMenuContainerViewController.container(centerViewController: GYZMainTabBarVC(), centerLeftPanViewWidth: 20, centerRightPanViewWidth: 20, leftMenuViewController: HOOPLeftMenuVC(), rightMenuViewController: nil)
        menuContrainer.leftMenuWidth = kLeftMenuWidth
        
        KeyWindow.rootViewController = menuContrainer
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
    /// 隐藏键盘
    func hiddenKeyBoard(){
        phoneTxtFiled.resignFirstResponder()
        pwdTxtFiled.resignFirstResponder()
    }
    
    /// 登录
    func requestLogin(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("login/login", parameters: ["phone":phoneTxtFiled.text!,"password":pwdTxtFiled.text!],  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                userDefaults.set(true, forKey: kIsLoginTagKey)//是否登录标识
               let data = response["data"]
                userDefaults.set((weakSelf?.phoneTxtFiled.text)!, forKey: "phone")//账号
                userDefaults.set(data["token"].stringValue, forKey: "token")
                JPUSHService.setAlias(data["alias"].stringValue, completion: { (iResCode, iAlias, seq) in
                    
                }, seq: 0)
                if !(data["devId"].string?.isEmpty)!{/// 设备不为空,检测网络
                    userDefaults.set(data["devId"].stringValue, forKey: "devId")
//                    weakSelf?.sendMqttCmd()
//                    weakSelf?.startSMSWithDuration(duration: 3)
                    weakSelf?.goHomeVC()
                }else{
                    weakSelf?.goLinkPower()
                }
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    
    /// 倒计时
    ///
    /// - Parameter duration: 倒计时时间
    func startSMSWithDuration(duration:Int){
        var times = duration
        
        let timer:DispatchSourceTimer = DispatchSource.makeTimerSource(flags: [], queue:DispatchQueue.global())
        
        timer.setEventHandler {
            if times > 0{
                DispatchQueue.main.async(execute: {
                    times -= 1
                })
            } else{
                DispatchQueue.main.async(execute: {
                    if !self.isNetWork{// 没有网络，去配网
                        self.hud?.hide(animated: true)
                        MBProgressHUD.showAutoDismissHUD(message: "网络未连接，请重新配置网络")
                        self.goLinkPower()
                    }
                    
                    timer.cancel()
                })
            }
        }
        
        // timer.scheduleOneshot(deadline: .now())
        timer.schedule(deadline: .now(), repeating: .seconds(1), leeway: .milliseconds(100))
        
        timer.resume()
        
        // 在调用DispatchSourceTimer时, 无论设置timer.scheduleOneshot, 还是timer.scheduleRepeating代码 不调用cancel(), 系统会自动调用
        // 另外需要设置全局变量引用, 否则不会调用事件
    }
    
    /// 检测网络信息查询
    func sendMqttCmd(){
        createHUD(message: "检测网络中...")
        let paramDic:[String:Any] = ["device_id":userDefaults.string(forKey: "devId") ?? "","user_id":userDefaults.string(forKey: "phone") ?? "","msg_type":"room_list_query","app_interface_tag":""]
        
        mqtt?.publish("hoopeu_device", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    
    /// 重载CocoaMQTTDelegate
    override func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
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
            if type == "room_list_query_re" && phone == userDefaults.string(forKey: "phone"){
                self.isNetWork = true
                self.hud?.hide(animated: true)
                self.goHomeVC()
            }
            
        }
    }
}
