//
//  HOOPSaveARCControlVC.swift
//  hoopeu
//  保存空调遥控器
//  Created by gouyz on 2019/2/28.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

class HOOPSaveARCControlVC: GYZBaseVC {
    
    /// 房间
    var dataList: [HOOPRoomModel] = [HOOPRoomModel]()
    /// 房间名称
    var roomNameList: [String] = [String]()
    var selectRoomIndex: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "遥控器命名"
        
        setUpUI()
        requestRoomList()
    }
    
    func setUpUI(){
        view.addSubview(bgView)
        bgView.addSubview(desLab)
        bgView.addSubview(desLab1)
        bgView.addSubview(iconView)
        bgView.addSubview(bgNameView)
        bgNameView.addSubview(arcNameTxtFiled)
        bgView.addSubview(bgRoomView)
        bgRoomView.addSubview(roomTxtFiled)
        bgRoomView.addSubview(roomLab)
        bgView.addSubview(sendBtn)
        
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(kTitleAndStateHeight + 20)
            make.bottom.equalTo(-20)
        }
        desLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.top.equalTo(20)
            make.height.equalTo(kTitleHeight)
        }
        desLab1.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(desLab)
            make.top.equalTo(desLab.snp.bottom)
        }
        iconView.snp.makeConstraints { (make) in
            make.top.equalTo(desLab1.snp.bottom).offset(kMargin)
            make.centerX.equalTo(bgView)
            make.size.equalTo(CGSize.init(width: 180, height: 180))
        }
        bgNameView.snp.makeConstraints { (make) in
            make.top.equalTo(iconView.snp.bottom).offset(20)
            make.left.right.equalTo(desLab)
            make.height.equalTo(50)
        }
        arcNameTxtFiled.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.top.bottom.equalTo(bgNameView)
        }
        bgRoomView.snp.makeConstraints { (make) in
            make.top.equalTo(bgNameView.snp.bottom).offset(20)
            make.left.right.height.equalTo(bgNameView)
        }
        roomTxtFiled.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(roomLab.snp.left).offset(-kMargin)
            make.top.bottom.equalTo(bgRoomView)
        }
        roomLab.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.top.bottom.equalTo(roomTxtFiled)
            make.width.equalTo(80)
        }
        
        sendBtn.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(bgRoomView.snp.bottom).offset(30)
            make.height.equalTo(kUIButtonHeight)
        }
    }
    
    lazy var bgView: UIView = {
        let bgview = UIView()
        bgview.backgroundColor = kWhiteColor
        bgview.cornerRadius = 10
        
        return bgview
    }()
    ///
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.font = k18Font
        lab.textColor = kBlackFontColor
        lab.textAlignment = .center
        lab.text = "遥控器命名"
        
        return lab
    }()
    ///
    lazy var desLab1 : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kHeightGaryFontColor
        lab.textAlignment = .center
        lab.text = "请选择遥控器所属的房间"
        
        return lab
    }()
    lazy var iconView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_arc_control"))
    
    lazy var bgNameView: UIView = {
        let bgview = UIView()
        bgview.backgroundColor = kWhiteColor
        bgview.cornerRadius = 8
        bgview.borderColor = kGrayLineColor
        bgview.borderWidth = klineWidth
        
        return bgview
    }()
    /// 遥控器名称
    lazy var arcNameTxtFiled : UITextField = {
        
        let textFiled = UITextField()
        textFiled.font = k15Font
        textFiled.textColor = kBlackFontColor
        textFiled.clearButtonMode = .whileEditing
        textFiled.placeholder = "如：客厅空调"
        
        return textFiled
    }()
    lazy var bgRoomView: UIView = {
        let bgview = UIView()
        bgview.backgroundColor = kWhiteColor
        bgview.cornerRadius = 8
        bgview.borderColor = kGrayLineColor
        bgview.borderWidth = klineWidth
        
        return bgview
    }()
    ///房间
    lazy var roomTxtFiled : UITextField = {
        
        let textFiled = UITextField()
        textFiled.font = k15Font
        textFiled.textColor = kBlackFontColor
        textFiled.clearButtonMode = .whileEditing
        textFiled.placeholder = "房间"
        textFiled.isEnabled = false
        
        return textFiled
    }()
    ///房间
    lazy var roomLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlueFontColor
        lab.text = "选择房间"
        
        lab.addOnClickListener(target: self, action: #selector(onClickedSelectRoom))
        
        return lab
    }()
    
    /// 保存
    lazy var sendBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("保存", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = 8
        
        btn.addTarget(self, action: #selector(clickedSendBtn), for: .touchUpInside)
        
        return btn
    }()
    
    ///获取房间数据
    func requestRoomList(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("room/deviceRoomList",parameters: nil,method :.get,  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let data = response["data"].array else { return }
                
                weakSelf?.dataList.removeAll()
                for item in data{
                    guard let itemInfo = item.dictionaryObject else { return }
                    let model = HOOPRoomModel.init(dict: itemInfo)
                    
                    weakSelf?.dataList.append(model)
                    weakSelf?.roomNameList.append(model.roomName!)
                }
                if weakSelf?.dataList.count > 0{
                    weakSelf?.selectRoomIndex = 0
                    weakSelf?.roomTxtFiled.text = weakSelf?.roomNameList[(weakSelf?.selectRoomIndex)!]
                }
                
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
            
        })
    }
    
    /// 保存
    @objc func clickedSendBtn(){
        
        
    }
    /// 选择房间
    @objc func onClickedSelectRoom(){
        showRoomView()
    }
    
    
    /// 自定义
    func showRoomView(){
        if roomNameList.count > 0 {
            UsefulPickerView.showSingleColPicker("选择房间", data: roomNameList, defaultSelectedIndex: selectRoomIndex) {[weak self] (index, value) in
                self?.roomTxtFiled.text = value
                self?.selectRoomIndex = index
            }
        }
    }
}
