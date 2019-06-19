//
//  HOOPSwitchVC.swift
//  hoopeu
//  智能开关
//  Created by gouyz on 2019/3/18.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import CocoaMQTT
import MBProgressHUD
import SwiftyJSON

class HOOPSwitchVC: GYZBaseVC {
    /// 房间
    var dataList: [HOOPRoomModel] = [HOOPRoomModel]()
    /// 房间名称
    var roomNameList: [String] = [String]()
    /// 灯名称
    var lightNameList: [String] = [String]()
    var selectRoomIndex: Int = -1
    /// 开关路数 默认单路
    var switchType:String = "single"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "智能开关"
        
        setUpUI()
        
        singleCheckView.tagImgView.isHighlighted = true
        requestRoomList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mqttSetting()
    }
    
    func setUpUI(){
        view.addSubview(bgView)
        bgView.addSubview(roomDesLab)
        bgView.addSubview(bgRoomView)
        bgRoomView.addSubview(roomNameLab)
        bgRoomView.addSubview(rightIconView)
        bgView.addSubview(desLab)
        bgView.addSubview(bgNumView)
        bgNumView.addSubview(singleCheckView)
        bgNumView.addSubview(twinsCheckView)
        bgNumView.addSubview(threeCheckView)
        bgView.addSubview(desLab1)
        bgView.addSubview(singleNameView)
        bgView.addSubview(twinsNameView)
        bgView.addSubview(threeNameView)
        bgView.addSubview(saveBtn)
        
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(kTitleAndStateHeight + 20)
            make.bottom.equalTo(-20)
        }
        roomDesLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.top.equalTo(20)
            make.height.equalTo(30)
        }
        bgRoomView.snp.makeConstraints { (make) in
            make.left.right.equalTo(roomDesLab)
            make.top.equalTo(roomDesLab.snp.bottom).offset(20)
            make.height.equalTo(60)
        }
        roomNameLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.top.bottom.equalTo(bgRoomView)
            make.right.equalTo(rightIconView.snp.left)
        }
        rightIconView.snp.makeConstraints { (make) in
            make.centerY.equalTo(bgRoomView)
            make.right.equalTo(-kMargin)
            make.size.equalTo(rightArrowSize)
        }
        desLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.top.equalTo(bgRoomView.snp.bottom).offset(20)
            make.height.equalTo(30)
        }
        bgNumView.snp.makeConstraints { (make) in
            make.left.right.equalTo(desLab)
            make.top.equalTo(desLab.snp.bottom).offset(20)
            make.height.equalTo(60)
        }
        singleCheckView.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.centerY.equalTo(bgNumView)
            make.height.equalTo(50)
            make.width.equalTo(twinsCheckView)
        }
        twinsCheckView.snp.makeConstraints { (make) in
            make.left.equalTo(singleCheckView.snp.right).offset(kMargin)
            make.centerY.height.equalTo(singleCheckView)
            make.width.equalTo(threeCheckView)
        }
        threeCheckView.snp.makeConstraints { (make) in
            make.left.equalTo(twinsCheckView.snp.right).offset(kMargin)
            make.right.equalTo(-kMargin)
            make.centerY.height.width.equalTo(singleCheckView)
        }
        
        desLab1.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(desLab)
            make.top.equalTo(bgNumView.snp.bottom).offset(20)
        }
        singleNameView.snp.makeConstraints { (make) in
            make.left.right.equalTo(desLab)
            make.top.equalTo(desLab1.snp.bottom).offset(20)
            make.height.equalTo(60)
        }
        twinsNameView.snp.makeConstraints { (make) in
            make.left.right.equalTo(singleNameView)
            make.top.equalTo(singleNameView.snp.bottom).offset(kMargin)
            make.height.equalTo(0)
        }
        threeNameView.snp.makeConstraints { (make) in
            make.left.right.equalTo(singleNameView)
            make.top.equalTo(twinsNameView.snp.bottom).offset(kMargin)
            make.height.equalTo(0)
        }
        
        saveBtn.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.bottom.equalTo(-20)
            make.height.equalTo(kUIButtonHeight)
        }
    }
    
    lazy var bgView: UIView = {
        let bgview = UIView()
        bgview.backgroundColor = kWhiteColor
        bgview.cornerRadius = 10
        bgview.isUserInteractionEnabled = true
        
        return bgview
    }()
    ///
    lazy var roomDesLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        lab.text = "请选择开关面板所在的房间"
        lab.textAlignment = .center
        
        return lab
    }()
    ///
    lazy var bgRoomView: UIView = {
        let bgview = UIView()
        bgview.borderColor = kBlueFontColor
        bgview.borderWidth = klineWidth
        bgview.cornerRadius = 15
        bgview.addOnClickListener(target: self, action: #selector(onClickedSelectRoom))
        
        return bgview
    }()
    /// 名称
    lazy var roomNameLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        lab.textAlignment = .center
        lab.text = "客厅"
        
        return lab
    }()
    /// 右侧箭头图标
    lazy var rightIconView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_right_arrow"))
    
    ///
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        lab.text = "请选择面板控制的灯光数"
        lab.textAlignment = .center
        
        return lab
    }()
    ///
    lazy var bgNumView: UIView = {
        let bgview = UIView()
        bgview.borderColor = kBlueFontColor
        bgview.borderWidth = klineWidth
        bgview.cornerRadius = 15
        bgview.isUserInteractionEnabled = true
        
        return bgview
    }()
    /// 1路
    lazy var singleCheckView : LHSCheckView = {
        let checkView = LHSCheckView()
        checkView.nameLab.text = "1路"
        checkView.tagImgView.image = UIImage.init(named: "icon_check_normal")
        checkView.tagImgView.highlightedImage = UIImage.init(named: "icon_check_selected")
        checkView.tag = 101
        checkView.addOnClickListener(target: self, action: #selector(onClickedSelectNum(sender:)))
        
        return checkView
    }()
    /// 2路
    lazy var twinsCheckView : LHSCheckView = {
        let checkView = LHSCheckView()
        checkView.nameLab.text = "2路"
        checkView.tagImgView.image = UIImage.init(named: "icon_check_normal")
        checkView.tagImgView.highlightedImage = UIImage.init(named: "icon_check_selected")
        checkView.tag = 102
        checkView.addOnClickListener(target: self, action: #selector(onClickedSelectNum(sender:)))
        
        return checkView
    }()
    /// 3路
    lazy var threeCheckView : LHSCheckView = {
        let checkView = LHSCheckView()
        checkView.nameLab.text = "3路"
        checkView.tagImgView.image = UIImage.init(named: "icon_check_normal")
        checkView.tagImgView.highlightedImage = UIImage.init(named: "icon_check_selected")
        checkView.tag = 103
        checkView.addOnClickListener(target: self, action: #selector(onClickedSelectNum(sender:)))
        
        return checkView
    }()
    ///
    lazy var desLab1 : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        lab.text = "请选择对应的开关设备"
        lab.textAlignment = .center
        
        return lab
    }()
    /// 1路名称
    lazy var singleNameView : HOOPSelectedSwitchNameView = {
        let nameView = HOOPSelectedSwitchNameView()
        nameView.nameLab.text = "第一路"
        nameView.tag = 101
        nameView.addOnClickListener(target: self, action: #selector(onClickedSelectName(sender:)))
        
        return nameView
    }()
    /// 2路名称
    lazy var twinsNameView : HOOPSelectedSwitchNameView = {
        let nameView = HOOPSelectedSwitchNameView()
        nameView.nameLab.text = "第二路"
        nameView.tag = 102
        nameView.addOnClickListener(target: self, action: #selector(onClickedSelectName(sender:)))
        
        return nameView
    }()
    /// 3路名称
    lazy var threeNameView : HOOPSelectedSwitchNameView = {
        let nameView = HOOPSelectedSwitchNameView()
        nameView.nameLab.text = "第三路"
        nameView.tag = 103
        nameView.addOnClickListener(target: self, action: #selector(onClickedSelectName(sender:)))
        
        return nameView
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
        sendSaveMqttCmd()
    }
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
                    weakSelf?.roomNameLab.text = weakSelf?.roomNameList[(weakSelf?.selectRoomIndex)!]
                    weakSelf?.requestLightList()
                }
                
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
            
        })
    }
    ///获取灯数据
    func requestLightList(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        
        GYZNetWork.requestNetwork("homeCtrl/lightType",parameters: ["roomName":roomNameList[selectRoomIndex]],  success: { (response) in
            
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let data = response["data"].array else { return }
                
                weakSelf?.lightNameList.removeAll()
                for item in data{
                     weakSelf?.lightNameList.append(item.stringValue)
                   
                }
                
            }
            
        }, failture: { (error) in
            
            GYZLog(error)
        })
    }
    
    /// 选择开关路数
    @objc func onClickedSelectNum(sender: UITapGestureRecognizer){
        
        let tag = sender.view?.tag
        if tag == 101 {//1路
            singleCheckView.tagImgView.isHighlighted = true
            twinsCheckView.tagImgView.isHighlighted = false
            threeCheckView.tagImgView.isHighlighted = false
            
            twinsNameView.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
            threeNameView.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
            switchType = "single"
        }else if tag == 102 {//2路
            singleCheckView.tagImgView.isHighlighted = false
            twinsCheckView.tagImgView.isHighlighted = true
            threeCheckView.tagImgView.isHighlighted = false
            twinsNameView.snp.updateConstraints { (make) in
                make.height.equalTo(60)
            }
            threeNameView.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
            switchType = "twins"
        }else if tag == 103 {//3路
            singleCheckView.tagImgView.isHighlighted = false
            twinsCheckView.tagImgView.isHighlighted = false
            threeCheckView.tagImgView.isHighlighted = true
            twinsNameView.snp.updateConstraints { (make) in
                make.height.equalTo(60)
            }
            threeNameView.snp.updateConstraints { (make) in
                make.height.equalTo(60)
            }
            switchType = "triplets"
        }
    }
    /// 选择开关名称
    @objc func onClickedSelectName(sender: UITapGestureRecognizer){
        let tag = sender.view?.tag
        if lightNameList.count > 0 {
            UsefulPickerView.showSingleColPicker("选择灯", data: lightNameList, defaultSelectedIndex: nil) {[weak self] (index, value) in
                if tag == 101{
                    self?.singleNameView.contentLab.text = value
                }else if tag == 102{
                    self?.twinsNameView.contentLab.text = value
                }else if tag == 103{
                    self?.threeNameView.contentLab.text = value
                }
            }
        }
    }
    /// 选择开关所在房间
    @objc func onClickedSelectRoom(){
        if roomNameList.count > 0 {
            UsefulPickerView.showSingleColPicker("选择房间", data: roomNameList, defaultSelectedIndex: selectRoomIndex) {[weak self] (index, value) in
                self?.roomNameLab.text = value
                self?.selectRoomIndex = index
                self?.requestLightList()
            }
        }
    }
    
    /// 学习
    func goStudyVC(switchId: String){
        let vc = HOOPSwitchStudyVC()
        vc.switchId = switchId
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// mqtt发布主题 新增
    func sendSaveMqttCmd(){
        var names:[String] = [String]()
        let firstName = singleNameView.contentLab.text
        if (firstName?.isEmpty)!{
            MBProgressHUD.showAutoDismissHUD(message: "请选择第一路灯名称")
            return
        }
        names.append(roomNameList[selectRoomIndex] + firstName!)
        if switchType == "twins" {
            let twoName = twinsNameView.contentLab.text
            if (twoName?.isEmpty)!{
                MBProgressHUD.showAutoDismissHUD(message: "请选择第二路灯名称")
                return
            }
            names.append(roomNameList[selectRoomIndex] + twoName!)
        }else if switchType == "triplets" {
            let twoName = twinsNameView.contentLab.text
            if (twoName?.isEmpty)!{
                MBProgressHUD.showAutoDismissHUD(message: "请选择第二路灯名称")
                return
            }
            names.append(roomNameList[selectRoomIndex] + twoName!)
            let threeName = threeNameView.contentLab.text
            if (threeName?.isEmpty)!{
                MBProgressHUD.showAutoDismissHUD(message: "请选择第三路灯名称")
                return
            }
            names.append(roomNameList[selectRoomIndex] + threeName!)
        }
        
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","room_id":dataList[selectRoomIndex].roomId!,"switch_type":switchType,"switchs":names,"phone":userDefaults.string(forKey: "phone") ?? "","msg_type":"app_switch_add","app_interface_tag":""]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    
    /// 重载CocoaMQTTDelegate
    override func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
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
            if type == "app_switch_add_re" && phone == userDefaults.string(forKey: "phone"){
                //                hud?.hide(animated: true)
                MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                if result["code"].intValue == kQuestSuccessTag{
                    /// 开关id
                    let switchId: String = result["data"].stringValue
                    goStudyVC(switchId: switchId)
                }
            }
            
        }
    }
}
