//
//  HOOPRegisterFirstVC.swift
//  hoopeu
//  注册第一步
//  Created by gouyz on 2019/2/19.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPRegisterFirstVC: GYZBaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = kWhiteColor
        
        let rightBtn = UIButton(type: .custom)
        rightBtn.setTitle("登录", for: .normal)
        rightBtn.titleLabel?.font = k15Font
        rightBtn.setTitleColor(kBlueFontColor, for: .normal)
        rightBtn.frame = CGRect.init(x: 0, y: 0, width: kTitleHeight, height: kTitleHeight)
        rightBtn.addTarget(self, action: #selector(onClickRightBtn), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBtn)
        
        setupUI()
        
        var ruleLabel : AttributeTextTapLab
        ruleLabel = AttributeTextTapLab.init(frame: CGRect.init(x: kMargin, y: kScreenHeight - kTitleHeight, width: kScreenWidth - kMargin * 2, height: 30))
        let attStr = NSMutableAttributedString.init(string: "注册即同意《用户协议》和《隐私协议》")
        attStr.addAttribute(NSAttributedString.Key.foregroundColor, value: kBlueFontColor, range: NSMakeRange(6, 4))
        attStr.addAttribute(NSAttributedString.Key.foregroundColor, value: kBlueFontColor, range: NSMakeRange(13, 4))
        
        ruleLabel.font = k15Font
        ruleLabel.attributedText = attStr
        ruleLabel.textAlignment = NSTextAlignment.center
        ruleLabel.yb_addAttributeTapAction(["用户协议","隐私协议"]) {[weak self] (string, range, index) in
            print("点击了\(string)标签 - {\(range.location) , \(range.length)} - \(index)")
            if index == 0{//用户协议
                self?.goWebVC(title: "用户协议", id: "1")
            }else{//隐私协议
                self?.goWebVC(title: "隐私协议", id: "2")
            }
        }
        
        // MARK: 关闭点击效果 默认是开启的
        ruleLabel.enabledTapEffect = false
    
        self.view.addSubview(ruleLabel)
    }

    func setupUI(){
        view.addSubview(desLab)
        view.addSubview(iconView)
        view.addSubview(registerBtn)
        
        desLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.top.equalTo(kTitleAndStateHeight * 2)
            make.height.equalTo(kTitleHeight)
        }
        iconView.snp.makeConstraints { (make) in
            make.centerX.equalTo(desLab)
            make.top.equalTo(desLab.snp.bottom).offset(20)
            make.size.equalTo(CGSize.init(width: 80, height: 130))
        }
        registerBtn.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.top.equalTo(iconView.snp.bottom).offset(kTitleHeight)
            make.height.equalTo(kUIButtonHeight)
        }
    }
    ///
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.textColor = kBlackFontColor
        lab.font = k18Font
        lab.textAlignment = .center
        lab.text = "\"您好，我是叮当宝贝\""
        
        return lab
    }()
    lazy var iconView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_hoopeu_register"))
    
    /// 注册
    lazy var registerBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBlueFontColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("注册", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = 8
        
        btn.addTarget(self, action: #selector(clickedRegisterBtn), for: .touchUpInside)
        
        return btn
    }()
    /// 登录
    @objc func onClickRightBtn(){
        let vc = HOOPLoginVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 注册
    @objc func clickedRegisterBtn(){
        let vc = HOOPRegisterPhoneVC()
        vc.isModifyPwd = false
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 用户协议、隐私政策
    func goWebVC(title: String,id: String){
        let vc = JSMWebViewVC()
        vc.webTitle = title
        vc.url = "http://www.hoopeurobot.com/page/protocol.html?id=" + id
        navigationController?.pushViewController(vc, animated: true)
    }
}
