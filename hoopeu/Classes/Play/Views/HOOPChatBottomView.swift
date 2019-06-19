//
//  HOOPChatBottomView.swift
//  hoopeu
//  聊天bottomview
//  Created by gouyz on 2019/3/26.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPChatBottomView: UIView {

    /// 点击发送
    var onClickedSendBlock: ((_ message: String) -> Void)?
    /// 点击切换说或做
    var onClickedChangeBlock: ((_ isSpeak: Bool) -> Void)?
    
    // MARK: 生命周期方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = kWhiteColor
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupUI(){
        
        addSubview(conmentField)
        addSubview(sendBtn)
        addSubview(iconBtn)
        addSubview(lineView)
        
        iconBtn.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.centerY.equalTo(conmentField)
            make.size.equalTo(CGSize.init(width: 30, height: 30))
        }
        conmentField.snp.makeConstraints { (make) in
            make.left.equalTo(iconBtn.snp.right).offset(kMargin)
            make.top.equalTo(kMargin)
            make.bottom.equalTo(lineView.snp.top)
            make.right.equalTo(sendBtn.snp.left).offset(-kMargin)
        }
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalTo(conmentField)
            make.bottom.equalTo(-kMargin)
            make.height.equalTo(klineWidth)
        }
        sendBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-kMargin)
            make.top.height.equalTo(conmentField)
            make.width.equalTo(60)
        }
    }
    lazy var conmentField: UITextField = {
        let txtField = UITextField()
        txtField.textColor = kBlackFontColor
        txtField.font = k15Font
        txtField.placeholder = "输入您想发送的内容"
        txtField.backgroundColor = kWhiteColor
        
        return txtField
    }()
    /// 分割线
    var lineView : UIView = {
        let line = UIView()
        line.backgroundColor = kGrayLineColor
        return line
    }()
    /// 发送
    lazy var sendBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.titleLabel?.font = k15Font
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("发送", for: .normal)
        btn.cornerRadius = 5
        btn.tag = 102
        btn.addTarget(self, action: #selector(onClickedOperator(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 图标
    lazy var iconBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "icon_play_speak"), for: .normal)
        btn.setImage(UIImage.init(named: "icon_play_do"), for: .selected)
        btn.tag = 101
        btn.addTarget(self, action: #selector(onClickedOperator(btn:)), for: .touchUpInside)
        
        return btn
    }()
    
    
    @objc func onClickedOperator(btn: UIButton){
        let tag = btn.tag
        if tag == 101 {
            btn.isSelected = !btn.isSelected
            if onClickedChangeBlock != nil {
                onClickedChangeBlock!(btn.isSelected)
            }
        }else{
            if onClickedSendBlock != nil {
                if !(conmentField.text?.isEmpty)!{
                    onClickedSendBlock!(conmentField.text!)
                }
            }
        }
    }
}
