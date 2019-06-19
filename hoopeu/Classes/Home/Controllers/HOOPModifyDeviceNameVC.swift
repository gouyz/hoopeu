//
//  HOOPModifyDeviceNameVC.swift
//  hoopeu
//  修改设备名称
//  Created by gouyz on 2019/2/21.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD

class HOOPModifyDeviceNameVC: GYZBaseVC {
    /// 选择结果回调
    var resultBlock:((_ name: String) -> Void)?
    /// 设备model
    var deviceModel: HOOPDeviceModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "修改设备名称"
        
        setUpUI()
        nameTxtFiled.text = deviceModel != nil ? deviceModel?.deviceName : ""
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
    /// 设备名称
    lazy var nameTxtFiled : UITextField = {
        
        let textFiled = UITextField()
        textFiled.font = k15Font
        textFiled.textColor = kBlackFontColor
        textFiled.clearButtonMode = .whileEditing
        textFiled.textAlignment = .center
        textFiled.placeholder = "请输入设备名称"
        
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
        lab.text = "1.命名支持1-8个汉字或1-16个英文字母及其组合。\n2.更改后的名称为APP中设备的显示名称，并非唤醒词。"
        
        return lab
    }()
    
    /// 保存
    lazy var saveBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBlueFontColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("保存", for: .normal)
        btn.titleLabel?.font = k15Font
        
        btn.addTarget(self, action: #selector(clickedSaveBtn), for: .touchUpInside)
        
        return btn
    }()
    /// 保存
    @objc func clickedSaveBtn(){
        if nameTxtFiled.text!.isEmpty {
            MBProgressHUD.showAutoDismissHUD(message: "请输入设备名称")
            return
        }else if nameTxtFiled.text!.count > 8 {
            MBProgressHUD.showAutoDismissHUD(message: "命名长度不能超过8个汉字或16个英文字母")
            return
        }
        
        requestModifyDeviceName()
    }
    
    /// 保存
    func requestModifyDeviceName(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("device/rename", parameters: ["deviceId":deviceModel?.deviceId ?? "","name":nameTxtFiled.text!],  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                if weakSelf?.resultBlock != nil{
                    weakSelf?.resultBlock!((weakSelf?.nameTxtFiled.text)!)
                }
                weakSelf?.clickedBackBtn()
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
}
