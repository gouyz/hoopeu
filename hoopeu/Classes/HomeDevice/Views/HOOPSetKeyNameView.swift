//
//  HOOPSetKeyNameView.swift
//  hoopeu
//  设置按键名称
//  Created by gouyz on 2019/3/8.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD

class HOOPSetKeyNameView: UIView {

    ///点击事件闭包
    var action:((_ name: String) -> Void)?
    
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
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    fileprivate func setupUI(){
        
        addSubview(bgView)
        bgView.addSubview(titleLab)
        bgView.addSubview(desLab)
        bgView.addSubview(nameTxtFiled)
        bgView.addSubview(lineView)
        bgView.addSubview(finishedBtn)
        
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.centerY.equalTo(self)
            make.height.equalTo(200)
        }
        
        titleLab.snp.makeConstraints { (make) in
            make.top.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.left.equalTo(kMargin)
            make.height.equalTo(kTitleHeight)
        }
        desLab.snp.makeConstraints { (make) in
            make.left.right.equalTo(titleLab)
            make.top.equalTo(titleLab.snp.bottom)
            make.height.equalTo(30)
        }
        nameTxtFiled.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.bottom.equalTo(lineView.snp.top).offset(-20)
            make.height.equalTo(kTitleHeight)
        }
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalTo(bgView)
            make.bottom.equalTo(finishedBtn.snp.top)
            make.height.equalTo(klineWidth)
        }
        finishedBtn.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(bgView)
            make.height.equalTo(kTitleHeight)
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
        lab.numberOfLines = 0
        lab.text = "按键的新功能已学习成功\n请重新给按键命名"
        
        return lab
    }()
    ///
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.font = k13Font
        lab.textColor = kGaryFontColor
        lab.textAlignment = .center
        lab.text = "说明：命名不能超过6个汉字"
        
        return lab
    }()
    /// 按键名称
    lazy var nameTxtFiled : UITextField = {
        
        let textFiled = UITextField()
        textFiled.font = k15Font
        textFiled.textColor = kBlackFontColor
        textFiled.clearButtonMode = .whileEditing
        textFiled.textAlignment = .center
        textFiled.placeholder = "如：音量+"
        
        return textFiled
    }()
    /// 分割线
    var lineView : UIView = {
        let line = UIView()
        line.backgroundColor = kGrayLineColor
        return line
    }()
    /// 完成按钮
    lazy var finishedBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kWhiteColor
        btn.setTitleColor(kBlueFontColor, for: .normal)
        btn.setTitle("完成", for: .normal)
        btn.titleLabel?.font = k15Font
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 操作
    @objc func clickedOperatorBtn(btn: UIButton){
        
        if (nameTxtFiled.text?.isEmpty)! {
            MBProgressHUD.showAutoDismissHUD(message: "请输入按键名称")
            return
        }else if nameTxtFiled.text!.count > 6{
            MBProgressHUD.showAutoDismissHUD(message: "命名不能超过6个汉字")
            return
        }
        if action != nil {
            action!(nameTxtFiled.text!)
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
    
    
}
