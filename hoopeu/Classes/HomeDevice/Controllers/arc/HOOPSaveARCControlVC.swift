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
    /// 当前匹配组
    var curMatchIndex: Int = 0
    /// 当前匹配组的品牌下标
    var curMatchBrandIndex: Int = 0
    var deviceType: DeviceType = .ARC
    var ir_type: String = "ir_air"
    /// 临时id
    var deviceId: String = ""
    /// 临时开按键id
    var onId: String = ""
    /// 临时关按键id
    var offId: String = ""
    /// 开按键code
    var onKeyCode: String = ""
    /// 关按键code
    var offKeyCode: String = ""
    
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if mqtt == nil {
            mqttSetting()
        }
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
        if (arcNameTxtFiled.text?.isEmpty)! {
            MBProgressHUD.showAutoDismissHUD(message: "请输入遥控器名称")
            return
        }
        if selectRoomIndex == -1 {
            MBProgressHUD.showAutoDismissHUD(message: "请选择遥控器所属房间")
            return
        }
        createHUD(message: "加载中...")
        requestDeviceId(isOn: true)
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
    
    /// 获取临时id
    func requestDeviceId(isOn: Bool){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        
        GYZNetWork.requestNetwork("homeCtrl", parameters: ["id":deviceId],  success: { (response) in
            
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                if isOn{
                    weakSelf?.onId = response["data"].stringValue
                    weakSelf?.requestDeviceId(isOn: false)
                }else{
                    weakSelf?.offId = response["data"].stringValue
                    weakSelf?.sendCmdMqtt()
                }
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            GYZLog(error)
        })
    }
    /// 添加遥控器
    func sendCmdMqtt(){

        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","msg_type":"app_ir_add","phone":userDefaults.string(forKey: "phone") ?? "","ir_id":deviceId,"ir_type":ir_type,"ir_name":arcNameTxtFiled.text!,"room_id": dataList[selectRoomIndex].roomId!,"brand":curMatchBrandIndex,"code_bark": curMatchIndex,"mobile_type":"ios","functions":[["func_id":onId,"func_type":"switch_open","func_name":"开","func_code":onKeyCode],["func_id":offId,"func_type":"switch_close","func_name":"关","func_code":offKeyCode]],"app_interface_tag":""]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
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
            
            if type == "app_ir_add_re" && phone == userDefaults.string(forKey: "phone"){
                self.hud?.hide(animated: true)
                if result["code"].intValue == kQuestSuccessTag{
                    
                    MBProgressHUD.showAutoDismissHUD(message: "添加成功")
                    if deviceType == .ARC{
                        ARCStateCtr.shareInstance()?.resetState(withControlId: deviceId)
                    }
                    _ = navigationController?.popToRootViewController(animated: true)
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                }
            }
            
        }
    }
}
