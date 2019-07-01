//
//  HOOPTVControlVC.swift
//  hoopeu
//  电视遥控器
//  Created by gouyz on 2019/3/1.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPTVControlVC: GYZBaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "电视遥控器"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_device_setting")?.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(clickedSettingBtn))
        
        setUpUI()
    }
    
    func setUpUI(){
        view.addSubview(bgView)
        bgView.addSubview(desLab)
        bgView.addSubview(onOffBtn)
        bgView.addSubview(muteBtn)
        bgView.addSubview(menuBtn)
        bgView.addSubview(backBtn)
        bgView.addSubview(oneBtn)
        bgView.addSubview(twoBtn)
        bgView.addSubview(threeBtn)
        bgView.addSubview(fourBtn)
        bgView.addSubview(fiveBtn)
        bgView.addSubview(sixBtn)
        bgView.addSubview(sevenBtn)
        bgView.addSubview(eightBtn)
        bgView.addSubview(nineBtn)
        bgView.addSubview(lineBtn)
        bgView.addSubview(zeroBtn)
        bgView.addSubview(tvBtn)
        bgView.addSubview(voicePlusBtn)
        bgView.addSubview(voiceMinusBtn)
        bgView.addSubview(channelPlusBtn)
        bgView.addSubview(channelMinusBtn)
        bgView.addSubview(upBtn)
        bgView.addSubview(leftBtn)
        bgView.addSubview(okBtn)
        bgView.addSubview(rightBtn)
        bgView.addSubview(downBtn)
        
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(kTitleAndStateHeight + 20)
            make.bottom.equalTo(-20)
        }
        desLab.snp.makeConstraints { (make) in
            make.top.equalTo(kMargin)
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.height.equalTo(20)
        }
        onOffBtn.snp.makeConstraints { (make) in
            make.top.equalTo(desLab.snp.bottom).offset(kMargin)
            make.left.equalTo(kMargin)
            make.height.equalTo(50)
            make.width.equalTo(muteBtn)
        }
        muteBtn.snp.makeConstraints { (make) in
            make.top.height.equalTo(onOffBtn)
            make.left.equalTo(onOffBtn.snp.right).offset(kMargin)
            make.width.equalTo(menuBtn)
        }
        menuBtn.snp.makeConstraints { (make) in
            make.top.height.equalTo(onOffBtn)
            make.left.equalTo(muteBtn.snp.right).offset(kMargin)
            make.width.equalTo(backBtn)
        }
        backBtn.snp.makeConstraints { (make) in
            make.top.height.width.equalTo(onOffBtn)
            make.left.equalTo(menuBtn.snp.right).offset(kMargin)
            make.right.equalTo(-kMargin)
        }
        oneBtn.snp.makeConstraints { (make) in
            make.top.equalTo(onOffBtn.snp.bottom).offset(20)
            make.left.equalTo(20)
            make.height.equalTo(onOffBtn)
            make.width.equalTo(twoBtn)
        }
        twoBtn.snp.makeConstraints { (make) in
            make.left.equalTo(oneBtn.snp.right).offset(20)
            make.top.height.equalTo(oneBtn)
            make.width.equalTo(threeBtn)
        }
        threeBtn.snp.makeConstraints { (make) in
            make.left.equalTo(twoBtn.snp.right).offset(20)
            make.top.height.width.equalTo(oneBtn)
            make.right.equalTo(-20)
        }
        fourBtn.snp.makeConstraints { (make) in
            make.top.equalTo(oneBtn.snp.bottom).offset(20)
            make.left.height.equalTo(oneBtn)
            make.width.equalTo(fiveBtn)
        }
        fiveBtn.snp.makeConstraints { (make) in
            make.left.equalTo(fourBtn.snp.right).offset(20)
            make.top.height.equalTo(fourBtn)
            make.width.equalTo(sixBtn)
        }
        sixBtn.snp.makeConstraints { (make) in
            make.left.equalTo(fiveBtn.snp.right).offset(20)
            make.top.height.width.equalTo(fourBtn)
            make.right.equalTo(-20)
        }
        sevenBtn.snp.makeConstraints { (make) in
            make.top.equalTo(fourBtn.snp.bottom).offset(20)
            make.left.height.equalTo(oneBtn)
            make.width.equalTo(eightBtn)
        }
        eightBtn.snp.makeConstraints { (make) in
            make.left.equalTo(sevenBtn.snp.right).offset(20)
            make.top.height.equalTo(sevenBtn)
            make.width.equalTo(nineBtn)
        }
        nineBtn.snp.makeConstraints { (make) in
            make.left.equalTo(eightBtn.snp.right).offset(20)
            make.top.height.width.equalTo(sevenBtn)
            make.right.equalTo(-20)
        }
        lineBtn.snp.makeConstraints { (make) in
            make.top.equalTo(sevenBtn.snp.bottom).offset(20)
            make.left.height.equalTo(oneBtn)
            make.width.equalTo(zeroBtn)
        }
        
        zeroBtn.snp.makeConstraints { (make) in
            make.left.equalTo(lineBtn.snp.right).offset(20)
            make.top.height.equalTo(lineBtn)
            make.width.equalTo(tvBtn)
        }
        tvBtn.snp.makeConstraints { (make) in
            make.left.equalTo(zeroBtn.snp.right).offset(20)
            make.top.height.width.equalTo(lineBtn)
            make.right.equalTo(-20)
        }
        upBtn.snp.makeConstraints { (make) in
            make.top.equalTo(lineBtn.snp.bottom).offset(20)
            make.centerX.equalTo(bgView)
            make.size.equalTo(CGSize.init(width: kTitleHeight, height: kTitleHeight))
        }
        okBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(upBtn)
            make.top.equalTo(upBtn.snp.bottom).offset(kMargin)
            make.size.equalTo(CGSize.init(width: 50, height: 50))
        }
        downBtn.snp.makeConstraints { (make) in
            make.centerX.size.equalTo(upBtn)
            make.top.equalTo(okBtn.snp.bottom).offset(kMargin)
        }
        leftBtn.snp.makeConstraints { (make) in
            make.right.equalTo(okBtn.snp.left).offset(-kMargin)
            make.centerY.equalTo(okBtn)
            make.size.equalTo(upBtn)
        }
        rightBtn.snp.makeConstraints { (make) in
            make.left.equalTo(okBtn.snp.right).offset(kMargin)
            make.centerY.size.equalTo(leftBtn)
        }
        voicePlusBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(okBtn.snp.top)
            make.right.equalTo(leftBtn.snp.left).offset(-kMargin)
            make.left.height.equalTo(onOffBtn)
        }
        voiceMinusBtn.snp.makeConstraints { (make) in
            make.top.equalTo(okBtn.snp.bottom)
            make.left.right.height.equalTo(voicePlusBtn)
        }
        channelPlusBtn.snp.makeConstraints { (make) in
            make.bottom.height.equalTo(voicePlusBtn)
            make.left.equalTo(rightBtn.snp.right).offset(kMargin)
            make.right.equalTo(backBtn)
        }
        channelMinusBtn.snp.makeConstraints { (make) in
            make.top.height.equalTo(voiceMinusBtn)
            make.left.right.equalTo(channelPlusBtn)
        }
    }
    
    lazy var bgView: UIView = {
        let bgview = UIView()
        bgview.backgroundColor = kWhiteColor
        bgview.cornerRadius = 10
        bgview.isUserInteractionEnabled = true
        
        return bgview
    }()
    ///提示
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.font = k13Font
        lab.textColor = kRedFontColor
        lab.text = "您可以点击任意键开始自定义学习啦！"
        lab.textAlignment = .center
        
        return lab
    }()
    /// 开关
    lazy var onOffBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("电源", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.cornerRadius = kCornerRadius
        btn.tag = 1011
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 静音
    lazy var muteBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("静音", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1013
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 菜单
    lazy var menuBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("菜单", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1005
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 返回
    lazy var backBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("返回", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1039
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 1
    lazy var oneBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("1", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1015
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 2
    lazy var twoBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("2", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1017
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 3
    lazy var threeBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("3", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1019
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 4
    lazy var fourBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("4", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1021
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 5
    lazy var fiveBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("5", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1023
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 6
    lazy var sixBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("6", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1025
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    ///7
    lazy var sevenBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("7", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1027
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 8
    lazy var eightBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("8", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1029
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 9
    lazy var nineBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("9", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1031
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// -/--
    lazy var lineBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("-/--", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1033
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()

    /// 0
    lazy var zeroBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("0", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1035
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// AV/TV
    lazy var tvBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("AV/TV", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1037
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 音量+
    lazy var voicePlusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("音量+", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1009
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 音量-
    lazy var voiceMinusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("音量-", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1001
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 上
    lazy var upBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("上", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1043
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 左
    lazy var leftBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("左", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1045
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 确定
    lazy var okBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("确定", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1041
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 右
    lazy var rightBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("右", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1047
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 下
    lazy var downBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("下", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1049
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 频道+
    lazy var channelPlusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("频道+", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1003
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 频道-
    lazy var channelMinusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("频道-", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.tag = 1007
        btn.cornerRadius = kCornerRadius
        
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
