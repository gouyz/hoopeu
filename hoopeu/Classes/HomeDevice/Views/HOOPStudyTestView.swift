//
//  HOOPStudyTestView.swift
//  hoopeu
//  学习成功 测试view
//  Created by gouyz on 2019/3/7.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPStudyTestView: UIView {
    
    ///点击事件闭包
    var action:((_ index: Int) -> Void)?
    
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
        bgView.addSubview(sendBtn)
        bgView.addSubview(lineView)
        bgView.addSubview(noResponseBtn)
        bgView.addSubview(lineView1)
        bgView.addSubview(responseBtn)
        
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.centerY.equalTo(self)
            make.height.equalTo(180)
        }
        
        titleLab.snp.makeConstraints { (make) in
            make.top.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.left.equalTo(kMargin)
            make.height.equalTo(kTitleHeight)
        }
        sendBtn.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.bottom.equalTo(lineView.snp.top).offset(-20)
            make.height.equalTo(kTitleHeight)
        }
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalTo(bgView)
            make.bottom.equalTo(noResponseBtn.snp.top)
            make.height.equalTo(klineWidth)
        }
        lineView1.snp.makeConstraints { (make) in
            make.centerX.bottom.equalTo(bgView)
            make.height.equalTo(kTitleHeight)
            make.width.equalTo(klineWidth)
        }
        noResponseBtn.snp.makeConstraints { (make) in
            make.left.equalTo(bgView)
            make.right.equalTo(lineView1.snp.left)
            make.bottom.height.equalTo(lineView1)
        }
        responseBtn.snp.makeConstraints { (make) in
            make.right.equalTo(bgView)
            make.left.equalTo(lineView1.snp.right)
            make.bottom.height.equalTo(lineView1)
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
        
        return lab
    }()
    /// 发射按钮
    lazy var sendBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("发射指令", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = 8
        btn.tag = 101
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 分割线
    var lineView : UIView = {
        let line = UIView()
        line.backgroundColor = kGrayLineColor
        return line
    }()
    /// 没响应按钮
    lazy var noResponseBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBackgroundColor
        btn.setTitleColor(kGaryFontColor, for: .disabled)
        btn.setTitleColor(kBlackFontColor, for: .normal)
        btn.setTitle("没响应", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.isEnabled = false
        btn.tag = 102
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 分割线
    var lineView1 : UIView = {
        let line = UIView()
        line.backgroundColor = kGrayLineColor
        return line
    }()
    /// 响应按钮
    lazy var responseBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBackgroundColor
        btn.setTitleColor(kGaryFontColor, for: .disabled)
        btn.setTitleColor(kBlueFontColor, for: .normal)
        btn.setTitle("有响应", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.isEnabled = false
        btn.tag = 103
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 操作
    @objc func clickedOperatorBtn(btn: UIButton){
        
        let tag = btn.tag
        if action != nil {
            action!(tag)
        }
        if tag == 101 {
            noResponseBtn.isEnabled = true
            noResponseBtn.backgroundColor = kWhiteColor
            responseBtn.isEnabled = true
            responseBtn.backgroundColor = kWhiteColor
        }else{
            hide()
        }

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
