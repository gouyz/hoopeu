//
//  HOOPRegisterCodeVC.swift
//  hoopeu
//  注册 获取验证码
//  Created by gouyz on 2019/2/19.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD

class HOOPRegisterCodeVC: GYZBaseVC {

    /// 是否忘记密码
    var isModifyPwd: Bool = false
    var phoneNum: String = ""
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
        view.addSubview(codeTxtFiled)
        view.addSubview(codeBtn)
        view.addSubview(lineView)
        view.addSubview(nextBtn)
        
        desLab.snp.makeConstraints { (make) in
            make.top.equalTo(kTitleAndStateHeight * 2)
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.height.equalTo(kTitleAndStateHeight)
        }
        codeTxtFiled.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(codeBtn.snp.left).offset(-kMargin)
            make.top.equalTo(desLab.snp.bottom).offset(kTitleAndStateHeight)
            make.height.equalTo(50)
        }
        codeBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(codeTxtFiled)
            make.right.equalTo(-kMargin)
            make.size.equalTo(CGSize.init(width: 100, height: 30))
        }
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.top.equalTo(codeTxtFiled.snp.bottom)
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
        lab.text = "\"请输入4位验证码\""
        
        return lab
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
    lazy var lineView : UIView = {
        let line = UIView()
        line.backgroundColor = kGrayLineColor
        return line
    }()
    
    /// 下一步
    lazy var nextBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "icon_next_btn"), for: .normal)
        
        btn.addTarget(self, action: #selector(clickedNextBtn), for: .touchUpInside)
        
        return btn
    }()
    /// 下一步
    @objc func clickedNextBtn(){
        if codeTxtFiled.text!.isEmpty {
            MBProgressHUD.showAutoDismissHUD(message: "请输入验证码")
            return
        }
        requestCheckCode()
    }
    
    func goNext(){
        let vc = HOOPRegisterPwdVC()
        vc.isModifyPwd = self.isModifyPwd
        vc.phoneNum = self.phoneNum
        vc.areaCode = areaCode
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 获取验证码
    @objc func clickedCodeBtn(){
        requestCode()
    }

    ///获取验证码
    func requestCode(){
        
        weak var weakSelf = self
        createHUD(message: "获取中...")
        
        GYZNetWork.requestNetwork("sms/send",isToken:false, parameters: ["phone":phoneNum,"type":isModifyPwd ? 1 : 0],  success: { (response) in
            
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
        
        GYZNetWork.requestNetwork("sms/validate",isToken:false, parameters: ["phone":phoneNum,"code":codeTxtFiled.text!],  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                userDefaults.set(response["data"].stringValue, forKey: "token")
                weakSelf?.goNext()
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
}
