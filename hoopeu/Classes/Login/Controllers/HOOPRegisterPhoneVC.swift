//
//  HOOPRegisterPhoneVC.swift
//  hoopeu
//  注册填写手机号
//  Created by gouyz on 2019/2/19.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD

class HOOPRegisterPhoneVC: GYZBaseVC {
    /// 是否忘记密码
    var isModifyPwd: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = isModifyPwd ? "忘记密码" : "注 册"
        self.view.backgroundColor = kWhiteColor
        
        setupUI()
    }
    
    /// 创建UI
    func setupUI(){
        view.addSubview(desLab)
        view.addSubview(codeLab)
        view.addSubview(phoneTxtFiled)
        view.addSubview(lineView)
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
        lab.text = "\"请输入手机号码\""
        
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
    
    /// 下一步
    lazy var nextBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "icon_next_btn"), for: .normal)
        
        btn.addTarget(self, action: #selector(clickedNextBtn), for: .touchUpInside)
        
        return btn
    }()
    /// 下一步
    @objc func clickedNextBtn(){
        hiddenKeyBoard()
        if !validPhoneNO(){
            return
        }
        if self.isModifyPwd {
            goNext()
        }else{
            requestCheckPhone()
        }
    }
    
    /// 选择地区代码
    @objc func onClickedSelectCode(){
        UsefulPickerView.showSingleColPicker("选择地区代码", data: PHONECODE, defaultSelectedIndex: nil) {[weak self] (index, value) in
            
            self?.codeLab.text = value
        }
    }
    /// 下一步
    func goNext(){
        let vc = HOOPRegisterCodeVC()
        vc.isModifyPwd = self.isModifyPwd
        vc.phoneNum = phoneTxtFiled.text!
        vc.areaCode = codeLab.text!
        navigationController?.pushViewController(vc, animated: true)
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
    }
    
    /// 检测手机号
    func requestCheckPhone(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("login/exist",isToken:false, parameters: ["phone":phoneTxtFiled.text!],  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                if response["data"].boolValue{
                    MBProgressHUD.showAutoDismissHUD(message: "该手机号已经注册")
                }else{
                    weakSelf?.goNext()
                }
            
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
}
