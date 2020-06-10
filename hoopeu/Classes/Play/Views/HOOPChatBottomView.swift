//
//  HOOPChatBottomView.swift
//  hoopeu
//  聊天bottomview
//  Created by gouyz on 2019/3/26.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import TTGTagCollectionView

class HOOPChatBottomView: UIView {

    /// 点击发送
    var onClickedSendBlock: ((_ message: String) -> Void)?
    /// 点击切换说或做
    var onClickedChangeBlock: ((_ isSpeak: Bool) -> Void)?
    /// 是否展开
    var onClickedIsExpandBlock: ((_ isExpand: Bool) -> Void)?
    /// 填充数据
    var tagsList : [String] = [String]()
    var isExpand: Bool = false
    
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
        addSubview(addBtn)
        addSubview(lineView)
        
        addSubview(bgView)
        bgView.addSubview(desLab)
        bgView.addSubview(tagsView)
        
        iconBtn.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.centerY.equalTo(conmentField)
            make.size.equalTo(CGSize.init(width: 30, height: 30))
        }
        conmentField.snp.makeConstraints { (make) in
            make.left.equalTo(iconBtn.snp.right).offset(kMargin)
            make.top.equalTo(kMargin)
            make.height.equalTo(30)
            make.right.equalTo(sendBtn.snp.left).offset(-kMargin)
        }
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalTo(conmentField)
            make.top.equalTo(conmentField.snp.bottom)
            make.height.equalTo(klineWidth)
        }
        sendBtn.snp.makeConstraints { (make) in
            make.right.equalTo(addBtn.snp.left).offset(-kMargin)
            make.top.height.equalTo(conmentField)
            make.width.equalTo(60)
        }
        addBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.centerY.equalTo(conmentField)
            make.size.equalTo(CGSize.init(width: 30, height: 30))
        }
        bgView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(self)
            make.height.equalTo(0)
            make.top.equalTo(lineView.snp.bottom).offset(kMargin)
        }
        desLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.top.equalTo(bgView)
            make.height.equalTo(30)
        }
        tagsView.snp.makeConstraints { (make) in
            make.top.equalTo(desLab.snp.bottom)
            make.left.right.equalTo(desLab)
            make.bottom.equalTo(bgView)
        }
    }
    lazy var conmentField: UITextField = {
        let txtField = UITextField()
        txtField.textColor = kBlackFontColor
        txtField.font = k15Font
        txtField.placeholder = "输入您想发送的内容"
        txtField.backgroundColor = kWhiteColor
        txtField.delegate = self
        
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
    /// add图标
    lazy var addBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "icon_play_add"), for: .normal)
        btn.tag = 103
        btn.addTarget(self, action: #selector(onClickedOperator(btn:)), for: .touchUpInside)
        
        return btn
    }()
    ///
    var bgView : UIView = {
        let view = UIView()
        view.backgroundColor = kBackgroundColor
        view.isUserInteractionEnabled = true
        return view
    }()
    ///
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.font = k13Font
        lab.textColor = kHeightGaryFontColor
        lab.text = "大家都在用的"
        
        return lab
    }()
    /// 指令tags
    lazy var tagsView: TTGTextTagCollectionView = {
        
        let view = TTGTextTagCollectionView()
        let config = view.defaultConfig
        config?.textFont = UIFont.boldSystemFont(ofSize: 15)
        config?.textColor = kBlackFontColor
        config?.selectedTextColor = kWhiteColor
        config?.borderColor = UIColor.UIColorFromRGB(valueRGB: 0xe9e9e9)
        config?.selectedBorderColor = kBlueFontColor
        config?.backgroundColor = kWhiteColor
        config?.selectedBackgroundColor = kBlueFontColor
        config?.cornerRadius = kCornerRadius
        config?.shadowOffset = CGSize.init(width: 0, height: 0)
        config?.shadowOpacity = 0
        config?.shadowRadius = 0
        view.scrollDirection = .vertical
        view.contentInset = UIEdgeInsets.init(top: kMargin, left: kMargin, bottom: kMargin, right: kMargin)
        view.showsHorizontalScrollIndicator = false
        view.horizontalSpacing = 15
        view.backgroundColor = kBackgroundColor
        view.delegate = self
        
        return view
    }()
    
    @objc func onClickedOperator(btn: UIButton){
        let tag = btn.tag
        if tag == 101 {
            btn.isSelected = !btn.isSelected
            if onClickedChangeBlock != nil {
                onClickedChangeBlock!(btn.isSelected)
            }
        }else if tag == 102{
            if onClickedSendBlock != nil {
                if !(conmentField.text?.isEmpty)!{
                    onClickedSendBlock!(conmentField.text!)
                }
            }
        }else{
            if !isExpand {
                if tagsList.count > 0 {
                    isExpand = true
                    conmentField.resignFirstResponder()
                    if onClickedIsExpandBlock != nil {
                        onClickedIsExpandBlock!(isExpand)
                    }
                    desLab.isHidden = false
                    bgView.snp.updateConstraints { (make) in
                        make.height.equalTo(230)
                    }
                    tagsView.removeAllTags()
                    tagsView.addTags(tagsList)
                }
            }else{
                hiddenExpand()
            }
        }
    }
    
    func hiddenExpand(){
        isExpand = false
        if onClickedIsExpandBlock != nil {
            onClickedIsExpandBlock!(isExpand)
        }
        desLab.isHidden = true
        bgView.snp.updateConstraints { (make) in
            make.height.equalTo(0)
        }
    }
}
extension HOOPChatBottomView: TTGTextTagCollectionViewDelegate {
    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTapTag tagText: String!, at index: UInt, selected: Bool, tagConfig config: TTGTextTagConfig!) {
        if onClickedChangeBlock != nil {
            onClickedChangeBlock!(true)
        }
        if onClickedSendBlock != nil {
            onClickedSendBlock!(tagsList[Int(index)])
            hiddenExpand()
        }
    }
}
extension HOOPChatBottomView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // 获得焦点
        hiddenExpand()
        return true
    }
}
