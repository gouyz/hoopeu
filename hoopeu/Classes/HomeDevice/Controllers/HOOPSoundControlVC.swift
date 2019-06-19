//
//  HOOPSoundControlVC.swift
//  hoopeu
//  音响遥控器
//  Created by gouyz on 2019/3/1.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPSoundControlVC: GYZBaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "音响遥控器"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_device_setting")?.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(clickedSettingBtn))
        
        setUpUI()
    }
    
    func setUpUI(){
        view.addSubview(bgView)
        bgView.addSubview(onOffBtn)
        bgView.addSubview(menuBtn)
        bgView.addSubview(circleBgView)
        circleBgView.addSubview(upBtn)
        circleBgView.addSubview(downBtn)
        circleBgView.addSubview(minusBtn)
        circleBgView.addSubview(plusBtn)
        circleBgView.addSubview(okBtn)
        bgView.addSubview(usbBtn)
        bgView.addSubview(repeateBtn)
        bgView.addSubview(voicePlusBtn)
        bgView.addSubview(voiceDesLab)
        bgView.addSubview(voiceMinusBtn)
        
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(kTitleAndStateHeight + 20)
            make.bottom.equalTo(-20)
        }
        onOffBtn.snp.makeConstraints { (make) in
            make.left.equalTo(circleBgView.snp.left).offset(-kMargin)
            make.top.equalTo(30)
            make.size.equalTo(CGSize.init(width: 70, height: 34))
        }
        menuBtn.snp.makeConstraints { (make) in
            make.top.height.width.equalTo(onOffBtn)
            make.right.equalTo(circleBgView).offset(kMargin)
        }
        circleBgView.snp.makeConstraints { (make) in
            make.centerX.equalTo(bgView)
            make.top.equalTo(onOffBtn.snp.bottom).offset(20)
            make.size.equalTo(CGSize.init(width: 200, height: 200))
        }
        okBtn.snp.makeConstraints { (make) in
            make.center.equalTo(circleBgView)
            make.size.equalTo(CGSize.init(width: 100, height: 100))
        }
        upBtn.snp.makeConstraints { (make) in
            make.top.equalTo(kMargin)
            make.bottom.equalTo(okBtn.snp.top).offset(-kMargin)
            make.centerX.equalTo(circleBgView)
            make.width.equalTo(60)
        }
        downBtn.snp.makeConstraints { (make) in
            make.centerX.width.equalTo(upBtn)
            make.top.equalTo(okBtn.snp.bottom).offset(kMargin)
            make.bottom.equalTo(-kMargin)
        }
        minusBtn.snp.makeConstraints { (make) in
            make.left.equalTo(5)
            make.right.equalTo(okBtn.snp.left).offset(-5)
            make.centerY.equalTo(circleBgView)
            make.height.equalTo(kTitleHeight)
        }
        plusBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-5)
            make.centerY.height.equalTo(minusBtn)
            make.left.equalTo(okBtn.snp.right).offset(5)
        }
        usbBtn.snp.makeConstraints { (make) in
            make.left.width.height.equalTo(onOffBtn)
            make.top.equalTo(circleBgView.snp.bottom).offset(20)
        }
        repeateBtn.snp.makeConstraints { (make) in
            make.right.equalTo(menuBtn)
            make.top.height.width.equalTo(usbBtn)
        }
        
        voicePlusBtn.snp.makeConstraints { (make) in
            make.left.width.equalTo(onOffBtn)
            make.top.equalTo(usbBtn.snp.bottom).offset(kTitleHeight)
            make.height.equalTo(kTitleHeight)
        }
        voiceDesLab.snp.makeConstraints { (make) in
            make.top.height.equalTo(voicePlusBtn)
            make.left.equalTo(voicePlusBtn.snp.right)
            make.right.equalTo(voiceMinusBtn.snp.left)
        }
        voiceMinusBtn.snp.makeConstraints { (make) in
            make.top.width.height.equalTo(voicePlusBtn)
            make.right.equalTo(menuBtn)
        }
    }
    
    lazy var bgView: UIView = {
        let bgview = UIView()
        bgview.backgroundColor = kWhiteColor
        bgview.cornerRadius = 10
        bgview.isUserInteractionEnabled = true
        
        return bgview
    }()
    
    /// 开关
    lazy var onOffBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kRedFontColor
        btn.setImage(UIImage.init(named: "icon_arc_on_off"), for: .normal)
        btn.tag = 101
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 菜单
    lazy var menuBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setImage(UIImage.init(named: "icon_sound_menu"), for: .normal)
        btn.tag = 102
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var circleBgView: UIView = {
        let bgview = UIView()
        bgview.backgroundColor = kBtnClickBGColor
        bgview.cornerRadius = 100
        bgview.isUserInteractionEnabled = true
        
        return bgview
    }()
    /// ok
    lazy var okBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kWhiteColor
        btn.setTitle("OK", for: .normal)
        btn.setTitleColor(kBlackFontColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.tag = 103
        btn.cornerRadius = 50
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// +
    lazy var plusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("+", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k18Font
        btn.tag = 104
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// -
    lazy var minusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("-", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k18Font
        btn.tag = 105
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    ///
    lazy var upBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setImage(UIImage.init(named: "icon_arc_arrow_up"), for: .normal)
        btn.tag = 106
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    ///
    lazy var downBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setImage(UIImage.init(named: "icon_arc_arrow_down"), for: .normal)
        btn.tag = 107
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// usb
    lazy var usbBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("USB/SD", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.tag = 108
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 重复
    lazy var repeateBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("重复", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.tag = 109
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    
    /// 音量+
    lazy var voicePlusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("+", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k18Font
        btn.tag = 110
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    ///音量
    lazy var voiceDesLab : UILabel = {
        let lab = UILabel()
        lab.backgroundColor = kBtnClickBGColor
        lab.font = k15Font
        lab.textColor = kWhiteColor
        lab.textAlignment = .center
        lab.text = "音量"
        
        return lab
    }()
    /// 音量-
    lazy var voiceMinusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("-", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k18Font
        btn.tag = 111
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    
    /// 操作
    @objc func clickedOperatorBtn(btn: UIButton){
        
    }
    /// 设置
    @objc func clickedSettingBtn(){
        GYZAlertViewTools.alertViewTools.showSheet(title: nil, message: nil, cancleTitle: "取消", titleArray: ["自定义","删除"], viewController: self) { [weak self](index) in
            
            if index == 0{//自定义
            }else if index == 1{//删除
                self?.showDeleteAlert()
            }
        }
    }
    
    /// 删除
    func showDeleteAlert(){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "确定要删除此遥控器吗?", cancleTitle: "取消", viewController: self, buttonTitles: "确定") { (index) in
            
            if index != cancelIndex{
            }
        }
    }
}
