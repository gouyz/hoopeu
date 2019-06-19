//
//  HOOPEditSayVC.swift
//  hoopeu
//  添加相似说法
//  Created by gouyz on 2019/2/25.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD

class HOOPEditSayVC: GYZBaseVC {

    /// 选择结果回调
    var resultBlock:((_ content: String) -> Void)?
    var isEdit: Bool = false
    var sayContent: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = isEdit ? "对叮当宝贝说" : "添加相似说法"
        if isEdit {
            let rightBtn = UIButton(type: .custom)
            rightBtn.setTitle("删除", for: .normal)
            rightBtn.titleLabel?.font = k15Font
            rightBtn.setTitleColor(kRedFontColor, for: .normal)
            rightBtn.frame = CGRect.init(x: 0, y: 0, width: kTitleHeight, height: kTitleHeight)
            rightBtn.addTarget(self, action: #selector(onClickRightBtn), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBtn)
        }
        
        setUpUI()
    }
    
    func setUpUI(){
        view.addSubview(bgView)
        bgView.addSubview(nameTxtFiled)
        
        view.addSubview(desLab)
        view.addSubview(desContentLab)
        view.addSubview(saveBtn)
        
        bgView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(kTitleAndStateHeight + kMargin)
            make.height.equalTo(50)
        }
        nameTxtFiled.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.top.bottom.equalTo(bgView)
        }
        desLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.top.equalTo(bgView.snp.bottom).offset(kMargin)
            make.height.equalTo(30)
        }
        desContentLab.snp.makeConstraints { (make) in
            make.left.right.equalTo(desLab)
            make.top.equalTo(desLab.snp.bottom).offset(5)
        }
        
        saveBtn.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(kBottomTabbarHeight)
        }
    }
    
    lazy var bgView: UIView = {
        let bgview = UIView()
        bgview.backgroundColor = kWhiteColor
        
        return bgview
    }()
    /// 对叮当宝贝说
    lazy var nameTxtFiled : UITextField = {
        
        let textFiled = UITextField()
        textFiled.font = k15Font
        textFiled.textColor = kBlackFontColor
        textFiled.clearButtonMode = .whileEditing
        textFiled.textAlignment = .center
        textFiled.placeholder = "请输入您想对叮当宝贝说的话"
        textFiled.text = sayContent
        
        return textFiled
    }()
    
    /// 说明
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlueFontColor
        lab.text = "说明："
        
        return lab
    }()
    ///
    lazy var desContentLab : UILabel = {
        let lab = UILabel()
        lab.font = k13Font
        lab.textColor = kBlackFontColor
        lab.numberOfLines = 0
        lab.text = "1.输入的语句不能有空格，符号，不能超过30个汉字。"
        
        return lab
    }()
    
    /// 保存
    lazy var saveBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("保存", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = 8
        
        btn.addTarget(self, action: #selector(clickedSaveBtn), for: .touchUpInside)
        
        return btn
    }()
    /// 保存
    @objc func clickedSaveBtn(){
        
        sayContent = nameTxtFiled.text!
        if sayContent.isEmpty {
            MBProgressHUD.showAutoDismissHUD(message: "请输入场景名称")
            return
        }else if sayContent.count > 30 {
            MBProgressHUD.showAutoDismissHUD(message: "场景名称不能超过30个汉字")
            return
        }
        
        if resultBlock != nil {
            resultBlock!(sayContent)
        }
        clickedBackBtn()
    }
    /// 删除
    @objc func onClickRightBtn(){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "确定要删除吗?", cancleTitle: "取消", viewController: self, buttonTitles: "确定") { (index) in
            
            if index != cancelIndex{
                
                if weakSelf?.resultBlock != nil {
                    weakSelf?.resultBlock!("")
                }
                weakSelf?.clickedBackBtn()
            }
        }
    }
}
