//
//  HOOPAddLinkPersonVC.swift
//  hoopeu
//  添加联系人
//  Created by gouyz on 2019/6/5.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD

class HOOPAddLinkPersonVC: UIView {

    ///点击事件闭包
    var action:((_ name: String,_ phone: String) -> Void)?
    
    // MARK: 生命周期方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    convenience init(){
        let rect = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        self.init(frame: rect)
        
        self.backgroundColor = UIColor.clear
        
        backgroundView.frame = rect
        backgroundView.backgroundColor = kBlackColor
        addSubview(backgroundView)
        backgroundView.addOnClickListener(target: self, action: #selector(onTapCancle(sender:)))
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    fileprivate func setupUI(){
        
        addSubview(bgView)
        bgView.addOnClickListener(target: self, action: #selector(onBlankClicked))
        
        bgView.addSubview(titleLab)
        bgView.addSubview(nameBgView)
        nameBgView.addSubview(nameTxtFiled)
        bgView.addSubview(phoneBgView)
        phoneBgView.addSubview(phoneTxtFiled)
        bgView.addSubview(finishedBtn)
        
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.centerY.equalTo(self)
            make.height.equalTo(300)
        }
        
        titleLab.snp.makeConstraints { (make) in
            make.top.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.left.equalTo(kMargin)
            make.height.equalTo(60)
        }
        nameBgView.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.top.equalTo(titleLab.snp.bottom).offset(20)
            make.height.equalTo(kTitleHeight)
        }
        nameTxtFiled.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.top.bottom.equalTo(nameBgView)
        }
        phoneBgView.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(nameBgView)
            make.top.equalTo(nameBgView.snp.bottom).offset(20)
        }
        phoneTxtFiled.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.top.bottom.equalTo(phoneBgView)
        }
        finishedBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(nameBgView)
            make.height.equalTo(kTitleHeight)
            make.bottom.equalTo(-30)
        }
    }
    ///整体背景
    lazy var backgroundView: UIView = UIView()
    
    lazy var bgView: UIView = {
        let bgview = UIView()
        bgview.backgroundColor = kWhiteColor
        bgview.cornerRadius = 10
        
        return bgview
    }()
    /// 标题
    lazy var titleLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        lab.textAlignment = .center
        lab.text = "添加新的联系人"
        
        return lab
    }()
    ///
    lazy var nameBgView : UIView = {
        let nameView = UIView()
        nameView.borderColor = kGrayLineColor
        nameView.borderWidth = klineWidth
        nameView.cornerRadius = kCornerRadius
        
        return nameView
    }()
    /// 姓名
    lazy var nameTxtFiled : UITextField = {
        
        let textFiled = UITextField()
        textFiled.font = k15Font
        textFiled.textColor = kBlackFontColor
        textFiled.clearButtonMode = .whileEditing
        textFiled.placeholder = "请输入联系人姓名"
        
        return textFiled
    }()
    ///
    lazy var phoneBgView : UIView = {
        let nameView = UIView()
        nameView.borderColor = kGrayLineColor
        nameView.borderWidth = klineWidth
        nameView.cornerRadius = kCornerRadius
        
        return nameView
    }()
    /// 手机号
    lazy var phoneTxtFiled : UITextField = {
        
        let textFiled = UITextField()
        textFiled.font = k15Font
        textFiled.textColor = kBlackFontColor
        textFiled.clearButtonMode = .whileEditing
        textFiled.keyboardType = .numberPad
        textFiled.placeholder = "请输入联系人手机号"
        
        return textFiled
    }()
    /// 保存按钮
    lazy var finishedBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("保存", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 操作
    @objc func clickedOperatorBtn(btn: UIButton){
        
        if (nameTxtFiled.text?.isEmpty)! {
            MBProgressHUD.showAutoDismissHUD(message: "请输入联系人姓名")
            return
        }
        if (phoneTxtFiled.text?.isEmpty)! {
            MBProgressHUD.showAutoDismissHUD(message: "请输入联系人手机号")
            return
        }else if !(phoneTxtFiled.text?.isMobileNumber())!{
            MBProgressHUD.showAutoDismissHUD(message: "请输入正确的手机号")
            return
        }
        if action != nil {
            action!(nameTxtFiled.text!,phoneTxtFiled.text!)
        }
        hide()
    }
    
    func show(){
        UIApplication.shared.keyWindow?.addSubview(self)
        
        showBackground()
        showAlertAnimation()
    }
    func hide(){
        bgView.isHidden = true
        hideAlertAnimation()
        self.removeFromSuperview()
    }
    
    fileprivate func showBackground(){
        backgroundView.alpha = 0.0
        UIView.beginAnimations("fadeIn", context: nil)
        UIView.setAnimationDuration(0.35)
        backgroundView.alpha = 0.6
        UIView.commitAnimations()
    }
    
    fileprivate func showAlertAnimation(){
        let popAnimation = CAKeyframeAnimation(keyPath: "transform")
        popAnimation.duration = 0.3
        popAnimation.values   = [
            NSValue.init(caTransform3D: CATransform3DMakeScale(0.9, 0.9, 1.0)),
            NSValue.init(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1.0)),
            NSValue.init(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0)),
            NSValue.init(caTransform3D: CATransform3DIdentity)
        ]
        
        popAnimation.isRemovedOnCompletion = true
        popAnimation.fillMode = CAMediaTimingFillMode.forwards
        bgView.layer.add(popAnimation, forKey: nil)
    }
    
    fileprivate func hideAlertAnimation(){
        UIView.beginAnimations("fadeIn", context: nil)
        UIView.setAnimationDuration(0.35)
        backgroundView.alpha = 0.0
        UIView.commitAnimations()
    }
    /// 点击bgView不消失
    @objc func onBlankClicked(){
        
    }
    /// 点击空白取消
    @objc func onTapCancle(sender:UITapGestureRecognizer){
        
        hide()
    }
}
