//
//  GYZCustomWaitAlert.swift
//  hoopeu
//  自定义等待接收 alert
//  Created by gouyz on 2019/3/5.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class GYZCustomWaitAlert: UIView {

    weak var delegate: CustomWaitAlertDelegate?
    
    ///点击事件闭包
    var action:(() -> Void)?
    var timer: DispatchSourceTimer?
    
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
        startSMSWithDuration(duration: 12)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    fileprivate func setupUI(){
        
        addSubview(bgView)
        bgView.addSubview(titleLab)
        bgView.addSubview(lineProgress)
        
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.centerY.equalTo(self)
            make.height.equalTo(140)
        }
        
        titleLab.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(bgView)
            make.bottom.equalTo(lineProgress.snp.top)
        }
        lineProgress.initializeProgress()
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
    
    lazy var lineProgress: SYLineProgressView = {
        let progress = SYLineProgressView.init(frame: CGRect.init(x: 0, y: 140 - 50, width: kScreenWidth - 60, height: 50))
        progress.lineColor = UIColor.clear
        progress.progressColor = kGrayLineColor
        progress.defaultColor = kBtnClickBGColor
        progress.label.textColor = kWhiteColor
        progress.label.isHidden = false
        progress.showSpace = false
        progress.progress = 0
        
        return progress
    }()
    
    /// 倒计时
    ///
    /// - Parameter duration: 倒计时时间
    func startSMSWithDuration(duration:Int){
        var times = duration
        
        timer = DispatchSource.makeTimerSource(flags: [], queue:DispatchQueue.global())
        
        timer?.setEventHandler {
            if times > 0{
                DispatchQueue.main.async(execute: {
                    self.lineProgress.progress += 1.0 / CGFloat.init(duration)
                    times -= 1
                })
            } else{
                DispatchQueue.main.async(execute: {
                    self.timer?.cancel()
                    self.clickedBtn()
                })
            }
        }
        
        // timer.scheduleOneshot(deadline: .now())
        timer?.schedule(deadline: .now(), repeating: .seconds(1), leeway: .milliseconds(100))
        
        timer?.resume()
        
        // 在调用DispatchSourceTimer时, 无论设置timer.scheduleOneshot, 还是timer.scheduleRepeating代码 不调用cancel(), 系统会自动调用
        // 另外需要设置全局变量引用, 否则不会调用事件
    }
    /// 点击事件
    func clickedBtn(){
    
        
        delegate?.alertViewDidClickedBtnAtIndex()
        if action != nil {
            action!()
        }
        
        hide()
        
    }
    
    func show(){
        UIApplication.shared.keyWindow?.addSubview(self)
        
        showBackground()
        showAlertAnimation()
    }
    func hide(){
        timer?.cancel()
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

protocol CustomWaitAlertDelegate: NSObjectProtocol {
    /// 点击事件
    ///
    /// - Parameters:
    ///   - alertView: alertView
    ///   - index: 按钮索引
    func alertViewDidClickedBtnAtIndex()
}
