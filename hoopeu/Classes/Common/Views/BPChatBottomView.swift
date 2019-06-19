//
//  BPChatBottomView.swift
//  BenefitPet
//  聊天bottom
//  Created by gouyz on 2018/10/10.
//  Copyright © 2018年 gyz. All rights reserved.
//

import UIKit

class BPChatBottomView: UIView {
    
    /// 点击操作
    var onClickedOperatorBlock: ((_ index: Int) -> Void)?
    
    
    // MARK: 生命周期方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = kBackgroundColor
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupUI(){
        
        addSubview(conmentField)
        addSubview(sendBtn)
        addSubview(tieShiBtn)
        addSubview(wenZhenBtn)
        addSubview(planBtn)
        addSubview(riChengBtn)
        addSubview(IconBtn)
        
        conmentField.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(20)
            make.height.equalTo(kTitleHeight)
            make.right.equalTo(sendBtn.snp.left).offset(-20)
        }
        sendBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-20)
            make.top.height.equalTo(conmentField)
            make.width.equalTo(60)
        }
        
        tieShiBtn.snp.makeConstraints { (make) in
            make.left.equalTo(conmentField)
            make.top.equalTo(conmentField.snp.bottom).offset(kMargin)
            make.width.equalTo(50)
            make.height.equalTo(70)
        }
        
        wenZhenBtn.snp.makeConstraints { (make) in
            make.left.equalTo(tieShiBtn.snp.right).offset(kMargin)
            make.top.width.height.equalTo(tieShiBtn)
        }
        planBtn.snp.makeConstraints { (make) in
            make.left.equalTo(wenZhenBtn.snp.right).offset(kMargin)
            make.top.width.height.equalTo(tieShiBtn)
        }
        riChengBtn.snp.makeConstraints { (make) in
            make.left.equalTo(planBtn.snp.right).offset(kMargin)
            make.top.width.height.equalTo(tieShiBtn)
        }
        IconBtn.snp.makeConstraints { (make) in
            make.left.equalTo(riChengBtn.snp.right).offset(kMargin)
            make.top.width.height.equalTo(tieShiBtn)
        }
        
        tieShiBtn.set(image: UIImage.init(named: "icon_chat_tieshi"), title: "小贴士", titlePosition: .bottom, additionalSpacing: 5, state: .normal)
        wenZhenBtn.set(image: UIImage.init(named: "icon_chat_wenzhen"), title: "问诊表", titlePosition: .bottom, additionalSpacing: 5, state: .normal)
        planBtn.set(image: UIImage.init(named: "icon_chat_plan"), title: "随访计划", titlePosition: .bottom, additionalSpacing: 5, state: .normal)
        
        riChengBtn.set(image: UIImage.init(named: "icon_chat_richeng"), title: "日程提醒", titlePosition: .bottom, additionalSpacing: 5, state: .normal)
        IconBtn.set(image: UIImage.init(named: "icon_chat_tupian"), title: "图片", titlePosition: .bottom, additionalSpacing: 5, state: .normal)
    }
    lazy var conmentField: UITextField = {
        let txtField = UITextField()
        txtField.textColor = kBlackFontColor
        txtField.font = k15Font
        txtField.placeholder = "输入您想发送的内容"
        txtField.backgroundColor = kWhiteColor
        txtField.cornerRadius = kCornerRadius
        
        return txtField
    }()
    /// 发送
    lazy var sendBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnNoClickBGColor
        btn.titleLabel?.font = k15Font
        btn.setTitleColor(kBlackFontColor, for: .normal)
        btn.setTitle("发送", for: .normal)
        
        return btn
    }()
    /// 小贴士
    lazy var tieShiBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = k10Font
        btn.setTitleColor(kBlackFontColor, for: .normal)
        btn.tag = 101
        btn.addTarget(self, action: #selector(onClickedOperator(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 问诊表
    lazy var wenZhenBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = k10Font
        btn.setTitleColor(kBlackFontColor, for: .normal)
        btn.tag = 102
        btn.addTarget(self, action: #selector(onClickedOperator(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 随访计划
    lazy var planBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = k10Font
        btn.setTitleColor(kBlackFontColor, for: .normal)
        btn.tag = 103
        btn.addTarget(self, action: #selector(onClickedOperator(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 日程提醒
    lazy var riChengBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = k10Font
        btn.setTitleColor(kBlackFontColor, for: .normal)
        btn.tag = 104
        btn.addTarget(self, action: #selector(onClickedOperator(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 图片
    lazy var IconBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = k10Font
        btn.setTitleColor(kBlackFontColor, for: .normal)
        btn.tag = 105
        btn.addTarget(self, action: #selector(onClickedOperator(btn:)), for: .touchUpInside)
        
        return btn
    }()
    
    @objc func onClickedOperator(btn: UIButton){
        if onClickedOperatorBlock != nil {
            onClickedOperatorBlock!(btn.tag)
        }
    }
}
