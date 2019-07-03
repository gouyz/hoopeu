//
//  HOOPSaveCustomIRVC.swift
//  hoopeu
//  保存自定义红外遥控器
//  Created by gouyz on 2019/7/3.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

class HOOPSaveCustomIRVC: GYZBaseVC {

    /// 房间
    var dataList: [HOOPRoomModel] = [HOOPRoomModel]()
    /// 房间名称
    var roomNameList: [String] = [String]()
    var selectRoomIndex: Int = -1
    
    /// 遥控器临时id
    var deviceControlId: String = ""
    /// 记录功能按键
    var funcArr: [[String: String]] = [[String: String]]()
    /// 编辑显示原有的控制器名称和房间id
    var controlName: String = ""
    var controlRoomId: String = ""
    var isEdit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "自定义遥控器命名"
        
        setUpUI()
        requestRoomList()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mqttSetting()
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
            make.size.equalTo(CGSize.init(width: 60, height: 110))
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
        lab.text = "自定义遥控器命名"
        
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
    lazy var iconView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_shepin_control"))
    
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
        textFiled.placeholder = "如：红外遥控器"
        textFiled.text = controlName
        
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
                for (index,item) in data.enumerated(){
                    guard let itemInfo = item.dictionaryObject else { return }
                    let model = HOOPRoomModel.init(dict: itemInfo)
                    if model.roomId == weakSelf?.controlRoomId{
                        weakSelf?.selectRoomIndex = index
                    }
                    
                    weakSelf?.dataList.append(model)
                    weakSelf?.roomNameList.append(model.roomName!)
                }
                if weakSelf?.dataList.count > 0{
                    if weakSelf?.selectRoomIndex == -1{
                        weakSelf?.selectRoomIndex = 0
                    }
                    
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
        
        if (arcNameTxtFiled.text?.isEmpty)! {
            MBProgressHUD.showAutoDismissHUD(message: "请输入遥控器名称")
            return
        }
        if selectRoomIndex == -1 {
            MBProgressHUD.showAutoDismissHUD(message: "请选择房间")
            return
        }
        
        
        var paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","room_id":dataList[selectRoomIndex].roomId!,"ctrl_dev_id":deviceControlId,"ctrl_dev_name":arcNameTxtFiled.text!,"func_num":funcArr.count,"functions":funcArr,"room_name":dataList[selectRoomIndex].roomName!,"phone":userDefaults.string(forKey: "phone") ?? "","study_state":"1","app_interface_tag":""]
        
        if isEdit {
            paramDic["msg_type"] = "app_other_edit"
        }else{
            paramDic["msg_type"] = "app_other_add"
        }
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
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
    
    /// 重载CocoaMQTTDelegate
    override func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        super.mqtt(mqtt, didConnectAck: ack)
        if ack == .accept {
            mqtt.subscribe("api_receive", qos: CocoaMQTTQOS.qos1)
        }
    }
    override func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        super.mqtt(mqtt, didReceiveMessage: message, id: id)
        
        if let data = message.string {
            let result = JSON.init(parseJSON: data)
            let phone = result["phone"].stringValue
            let type = result["msg_type"].stringValue
            if let tag = result["app_interface_tag"].string{
                if tag.hasPrefix("system_"){
                    return
                }
            }
            if type == "app_other_add_re" && phone == userDefaults.string(forKey: "phone"){
                //                hud?.hide(animated: true)
                MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                if result["code"].intValue == kQuestSuccessTag{
                    let _ = navigationController?.popToRootViewController(animated: true)
                }
            }else if type == "app_other_edit_re" && phone == userDefaults.string(forKey: "phone"){
                //                hud?.hide(animated: true)
                MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                if result["code"].intValue == kQuestSuccessTag{
                    let _ = navigationController?.popToRootViewController(animated: true)
                }
            }
            
        }
    }
}
