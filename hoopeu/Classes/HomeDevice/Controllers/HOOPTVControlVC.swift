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
        bgView.addSubview(onOffBtn)
        bgView.addSubview(oneBtn)
        bgView.addSubview(twoBtn)
        bgView.addSubview(threeBtn)
        bgView.addSubview(fourBtn)
        bgView.addSubview(fiveBtn)
        bgView.addSubview(sixBtn)
        bgView.addSubview(sevenBtn)
        bgView.addSubview(eightBtn)
        bgView.addSubview(nineBtn)
        bgView.addSubview(menuBtn)
        bgView.addSubview(zeroBtn)
        bgView.addSubview(backBtn)
        bgView.addSubview(channelPlusBtn)
        bgView.addSubview(channelLab)
        bgView.addSubview(channelMinusBtn)
        bgView.addSubview(muteBtn)
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
            make.centerX.equalTo(bgView)
            make.top.equalTo(20)
            make.size.equalTo(CGSize.init(width: 60, height: 30))
        }
        twoBtn.snp.makeConstraints { (make) in
            make.top.equalTo(onOffBtn.snp.bottom).offset(30)
            make.centerX.equalTo(bgView)
            make.width.equalTo(60)
            make.height.equalTo(35)
        }
        oneBtn.snp.makeConstraints { (make) in
            make.right.equalTo(twoBtn.snp.left).offset(-30)
            make.top.height.width.equalTo(twoBtn)
        }
        threeBtn.snp.makeConstraints { (make) in
            make.left.equalTo(twoBtn.snp.right).offset(30)
            make.top.height.width.equalTo(twoBtn)
        }
        fourBtn.snp.makeConstraints { (make) in
            make.right.equalTo(fiveBtn.snp.left).offset(-30)
            make.top.height.width.equalTo(fiveBtn)
        }
        fiveBtn.snp.makeConstraints { (make) in
            make.centerX.width.height.equalTo(twoBtn)
            make.top.equalTo(twoBtn.snp.bottom).offset(30)
        }
        sixBtn.snp.makeConstraints { (make) in
            make.left.equalTo(fiveBtn.snp.right).offset(30)
            make.top.height.width.equalTo(fiveBtn)
        }
        sevenBtn.snp.makeConstraints { (make) in
            make.right.equalTo(eightBtn.snp.left).offset(-30)
            make.top.height.width.equalTo(eightBtn)
        }
        eightBtn.snp.makeConstraints { (make) in
            make.centerX.width.height.equalTo(twoBtn)
            make.top.equalTo(fiveBtn.snp.bottom).offset(30)
        }
        nineBtn.snp.makeConstraints { (make) in
            make.left.equalTo(eightBtn.snp.right).offset(30)
            make.top.height.width.equalTo(eightBtn)
        }
        menuBtn.snp.makeConstraints { (make) in
            make.right.equalTo(zeroBtn.snp.left).offset(-30)
            make.top.height.width.equalTo(zeroBtn)
        }
        
        zeroBtn.snp.makeConstraints { (make) in
            make.centerX.width.height.equalTo(twoBtn)
            make.top.equalTo(eightBtn.snp.bottom).offset(30)
        }
        backBtn.snp.makeConstraints { (make) in
            make.left.equalTo(zeroBtn.snp.right).offset(30)
            make.top.height.width.equalTo(zeroBtn)
        }
        
        muteBtn.snp.makeConstraints { (make) in
            make.centerX.width.height.equalTo(twoBtn)
            make.top.equalTo(zeroBtn.snp.bottom).offset(40)
        }
        channelPlusBtn.snp.makeConstraints { (make) in
            make.right.equalTo(muteBtn.snp.left).offset(-30)
            make.top.width.equalTo(muteBtn)
            make.height.equalTo(kTitleHeight)
        }
        channelLab.snp.makeConstraints { (make) in
            make.top.equalTo(channelPlusBtn.snp.bottom)
            make.right.width.height.equalTo(channelPlusBtn)
        }
        channelMinusBtn.snp.makeConstraints { (make) in
            make.top.equalTo(channelLab.snp.bottom)
            make.right.width.height.equalTo(channelPlusBtn)
        }
        
        voicePlusBtn.snp.makeConstraints { (make) in
            make.left.equalTo(muteBtn.snp.right).offset(30)
            make.top.width.equalTo(muteBtn)
            make.height.equalTo(channelPlusBtn)
        }
        voiceDesLab.snp.makeConstraints { (make) in
            make.top.equalTo(voicePlusBtn.snp.bottom)
            make.right.width.height.equalTo(voicePlusBtn)
        }
        voiceMinusBtn.snp.makeConstraints { (make) in
            make.top.equalTo(voiceDesLab.snp.bottom)
            make.right.width.height.equalTo(voicePlusBtn)
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
    /// 1
    lazy var oneBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("1", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.tag = 102
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 2
    lazy var twoBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("2", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.tag = 103
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 3
    lazy var threeBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("3", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.tag = 104
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 4
    lazy var fourBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("4", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.tag = 105
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 5
    lazy var fiveBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("5", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.tag = 106
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 6
    lazy var sixBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("6", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.tag = 107
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    ///7
    lazy var sevenBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("7", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.tag = 108
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 8
    lazy var eightBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("8", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.tag = 109
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 9
    lazy var nineBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("9", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.tag = 110
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 菜单
    lazy var menuBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("菜单", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.tag = 111
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 0
    lazy var zeroBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("0", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.tag = 112
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 返回
    lazy var backBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("返回", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.tag = 113
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 频道+
    lazy var channelPlusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setImage(UIImage.init(named: "icon_arc_arrow_up"), for: .normal)
        btn.tag = 114
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    ///频道
    lazy var channelLab : UILabel = {
        let lab = UILabel()
        lab.backgroundColor = kBtnClickBGColor
        lab.font = k15Font
        lab.textColor = kWhiteColor
        lab.textAlignment = .center
        lab.text = "频道"
        
        return lab
    }()
    /// 频道-
    lazy var channelMinusBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setImage(UIImage.init(named: "icon_arc_arrow_down"), for: .normal)
        btn.tag = 115
        
        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 静音
    lazy var muteBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("静音", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        btn.tag = 116
        
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
        btn.tag = 117
        
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
        btn.tag = 118
        
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
