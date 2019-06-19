//
//  HOOPSceneNameVC.swift
//  hoopeu
//  场景名称
//  Created by gouyz on 2019/2/22.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD

class HOOPSceneNameVC: GYZBaseVC {
    
    var isEdit: Bool = false
    /// 场景名称
    var sceneName: String = ""
    /// 选择结果回调
    var resultBlock:((_ name: String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = isEdit ? "更改场景名称" : "场景名称"
        
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
    /// 场景名称
    lazy var nameTxtFiled : UITextField = {
        
        let textFiled = UITextField()
        textFiled.font = k15Font
        textFiled.textColor = kBlackFontColor
        textFiled.clearButtonMode = .whileEditing
        textFiled.textAlignment = .center
        textFiled.placeholder = "请输入场景名称"
        textFiled.text = sceneName
        
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
        lab.text = "1.场景名称不能超过6个汉字"
        
        return lab
    }()
    
    /// 保存
    lazy var saveBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("保存", for: .normal)
        btn.titleLabel?.font = k15Font
        
        btn.addTarget(self, action: #selector(clickedSaveBtn), for: .touchUpInside)
        
        return btn
    }()
    /// 保存
    @objc func clickedSaveBtn(){
        sceneName = nameTxtFiled.text!
        if sceneName.isEmpty {
            MBProgressHUD.showAutoDismissHUD(message: "请输入场景名称")
            return
        }else if sceneName.count > 6 {
            MBProgressHUD.showAutoDismissHUD(message: "场景名称不能超过6个汉字")
            return
        }
        
        if resultBlock != nil {
            resultBlock!(sceneName)
        }
        clickedBackBtn()
    }
}

