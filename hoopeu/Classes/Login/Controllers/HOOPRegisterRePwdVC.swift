//
//  HOOPRegisterRePwdVC.swift
//  hoopeu
//  注册 再次输入密码
//  Created by gouyz on 2019/2/19.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD

class HOOPRegisterRePwdVC: GYZBaseVC {

    /// 是否忘记密码
    var isModifyPwd: Bool = false
    var phoneNum: String = ""
    var passWord: String = ""
    var areaCode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = isModifyPwd ? "忘记密码" : "注 册"
        self.view.backgroundColor = kWhiteColor
        
        setupUI()
    }
    
    /// 创建UI
    func setupUI(){
        view.addSubview(desLab)
        view.addSubview(desLab1)
        view.addSubview(pwdTxtFiled)
        view.addSubview(seePwdBtn)
        view.addSubview(lineView)
        view.addSubview(nextBtn)
        
        desLab.snp.makeConstraints { (make) in
            make.top.equalTo(kTitleAndStateHeight * 2)
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.height.equalTo(kTitleHeight)
        }
        desLab1.snp.makeConstraints { (make) in
            make.left.right.equalTo(desLab)
            make.top.equalTo(desLab.snp.bottom)
            make.height.equalTo(30)
        }
        pwdTxtFiled.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.top.equalTo(desLab1.snp.bottom).offset(kTitleHeight)
            make.right.equalTo(seePwdBtn.snp.left).offset(-kMargin)
            make.height.equalTo(50)
        }
        seePwdBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(pwdTxtFiled)
            make.right.equalTo(-kMargin)
            make.size.equalTo(CGSize.init(width: 20, height: 20))
        }
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalTo(desLab)
            make.top.equalTo(pwdTxtFiled.snp.bottom)
            make.height.equalTo(klineWidth)
        }
        nextBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.bottom.equalTo(-kTitleHeight)
            make.size.equalTo(CGSize.init(width: kTitleHeight, height: kTitleHeight))
        }
    }
    ///
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.textColor = kBlackFontColor
        lab.font = k18Font
        lab.textAlignment = .center
        lab.text = "\"请再次输入密码\""
        
        return lab
    }()
    lazy var desLab1 : UILabel = {
        let lab = UILabel()
        lab.textColor = kHeightGaryFontColor
        lab.font = k13Font
        lab.textAlignment = .center
        lab.text = "6-16位数字，英文字母或下划线组成"
        
        return lab
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
    /// 下一步
    lazy var nextBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "icon_next_btn"), for: .normal)
        
        btn.addTarget(self, action: #selector(clickedNextBtn), for: .touchUpInside)
        
        return btn
    }()
    /// 显示密码
    @objc func clickedSeePwdBtn(){
        seePwdBtn.isSelected = !seePwdBtn.isSelected
        pwdTxtFiled.isSecureTextEntry = !seePwdBtn.isSelected
    }
    /// 下一步
    @objc func clickedNextBtn(){
        if pwdTxtFiled.text!.isEmpty {
            MBProgressHUD.showAutoDismissHUD(message: "请再次输入密码")
            return
        }else if passWord != pwdTxtFiled.text {
            MBProgressHUD.showAutoDismissHUD(message: "两次输入密码不一致")
            return
        }
        if isModifyPwd {// 修改密码
            requestReSetPwd()
        }else{// 注册
            requestRegister()
        }
        
    }
    /// 注册
    func requestRegister(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("login/register", parameters: ["phone":phoneNum,"password":passWord,"areaCode": areaCode],  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                userDefaults.set(true, forKey: kIsLoginTagKey)//是否登录标识
                let data = response["data"]
                userDefaults.set(weakSelf?.phoneNum, forKey: "phone")//账号
                userDefaults.set(data["token"].stringValue, forKey: "token")
//                if !(data["devId"].string?.isEmpty)!{/// 设备不为空
//                    userDefaults.set(data["devId"].stringValue, forKey: "devId")
//                }
                JPUSHService.setAlias(data["alias"].stringValue, completion: { (iResCode, iAlias, seq) in
                    
                }, seq: 0)
                weakSelf?.goSuccess()
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    
    func goSuccess(){
        let vc = HOOPRegisterSuccessVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 重置密码
    func requestReSetPwd(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("login/resetPassword", parameters: ["phone":phoneNum,"password":passWord],  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                MBProgressHUD.showAutoDismissHUD(message: "请重新登录")
                userDefaults.removeObject(forKey: "token")
                weakSelf?.goLoginVC()
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    func goLoginVC(){
        for i in 0..<(navigationController?.viewControllers.count)!{
            
            if navigationController?.viewControllers[i].isKind(of: HOOPLoginVC.self) == true {
                
                let vc = navigationController?.viewControllers[i] as! HOOPLoginVC
                _ = navigationController?.popToViewController(vc, animated: true)
                
                break
            }
        }
    }
}
