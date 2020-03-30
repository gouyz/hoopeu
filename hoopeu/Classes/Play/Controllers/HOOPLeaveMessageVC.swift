//
//  HOOPLeaveMessageVC.swift
//  hoopeu
//  留言
//  Created by gouyz on 2019/3/27.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import CocoaMQTT
import MBProgressHUD
import SwiftyJSON

class HOOPLeaveMessageVC: GYZBaseVC {

    /// 选择结果回调
    var resultBlock:((_ isRefresh: Bool) -> Void)?
    ///txtView 提示文字
    let placeHolder = "请输入您想让叮当宝贝说的话"
    //// 最大字数
    let contentMaxCount: Int = 200
    var isEdit: Bool = false
    /// 留言id
    var messageId: String = ""
    /// 留言类型
    var msgType: String = ""
    /// 用户想要播报的语句的日期
    var day: String = ""
    /// 用户想要播报的语句的时间
    var day_time: String = ""
    /// 每周循环时间 ,ONCE:仅此一次,EVERYDAY :每天,WEEKDAY:工作日,WEEKEND:每周末,USER_DEFINE:自定义
    var week_time: String = ""
    /// 用户自定义时间选择，可多选。EVERY_MONDAY:每周一,EVERY_TUESDAY:每周二,EVERY_WEDNESDAY:每周三,EVERY_THURSDAY:每周四,EVERY_FRIDAY:每周五,EVERY_SATURDAY:每周六,EVERY_SUNDAY:每周日
    var user_define_times: [String] = [String]()
    /// 轮询播报 默认true
    var isLoop: Bool = true
    /// 语音留言 默认false
    var isVoice: Bool = false
    /// 语音留言 是否上传语音
    var isVoiceUpload: Bool = false
    let recorderManager = RecordManager()
    
    /// 1:app端留言 2:设备端语音
    var sourceType: String = "1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "留言"
        self.view.backgroundColor = kWhiteColor
        
        let rightBtn = UIButton(type: .custom)
        if isEdit {
            rightBtn.setTitle("删除", for: .normal)
            rightBtn.setTitleColor(kRedFontColor, for: .normal)
        }else{
            rightBtn.setTitle("记录", for: .normal)
            rightBtn.setTitleColor(kBlueFontColor, for: .normal)
        }
        rightBtn.titleLabel?.font = k15Font
        rightBtn.frame = CGRect.init(x: 0, y: 0, width: kTitleHeight, height: kTitleHeight)
        rightBtn.addTarget(self, action: #selector(onClickRightBtn), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBtn)
        
        setUpUI()
        voiceBtn.isHidden = !isVoice
        delImg.isHidden = !isVoice
        playBtn.isHidden = !isVoice
        contentTxtView.delegate = self
        contentTxtView.text = placeHolder
        
        iconTimeView.addOnClickListener(target: self, action: #selector(onClickedEditTime))
        delImg.addOnClickListener(target: self, action: #selector(onClickedDelVoice))
        
        if isEdit {
            requestMessageInfo()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mqttSetting()
    }
    
    func setUpUI(){
        view.addSubview(desLab)
        view.addSubview(voiceCheckView)
        view.addSubview(playBtn)
        view.addSubview(delImg)
        view.addSubview(voiceBtn)
        view.addSubview(bgView)
        bgView.addSubview(contentTxtView)
        bgView.addSubview(fontCountLab)
        view.addSubview(desTimeLab)
        view.addSubview(timeLab)
        view.addSubview(iconTimeView)
        view.addSubview(lineView)
        view.addSubview(desContentLab)
        view.addSubview(singleCheckView)
        view.addSubview(saveBtn)
        
        desLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.top.equalTo(kTitleAndStateHeight + kMargin)
            make.size.equalTo(CGSize.init(width: kTitleHeight, height: 20))
        }
        voiceCheckView.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.top.equalTo(desLab.snp.bottom).offset(kMargin)
            make.height.equalTo(34)
            make.width.equalTo(160)
        }
        
        voiceBtn.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(bgView)
            make.height.equalTo(kUIButtonHeight)
        }
        playBtn.snp.makeConstraints { (make) in
            make.left.top.height.equalTo(voiceBtn)
            make.right.equalTo(delImg.snp.left).offset(-kMargin)
        }
        delImg.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.centerY.equalTo(playBtn)
            make.size.equalTo(CGSize.init(width: 24, height: 24))
        }
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.top.equalTo(voiceCheckView.snp.bottom).offset(kMargin)
            make.height.equalTo(100)
        }
        contentTxtView.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.bottom.equalTo(fontCountLab.snp.top)
        }
        fontCountLab.snp.makeConstraints { (make) in
            make.left.right.equalTo(contentTxtView)
            make.bottom.equalTo(-5)
            make.height.equalTo(20)
        }
        desTimeLab.snp.makeConstraints { (make) in
            make.left.size.equalTo(desLab)
            make.top.equalTo(bgView.snp.bottom).offset(100)
        }
        timeLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(iconTimeView.snp.left).offset(-kMargin)
            make.top.equalTo(desTimeLab.snp.bottom)
            make.height.equalTo(kTitleHeight)
        }
        iconTimeView.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.centerY.equalTo(timeLab)
            make.size.equalTo(CGSize.init(width: 24, height: 26))
        }
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.height.equalTo(klineWidth)
            make.top.equalTo(timeLab.snp.bottom)
        }
        desContentLab.snp.makeConstraints { (make) in
            make.left.right.equalTo(lineView)
            make.top.equalTo(lineView.snp.bottom).offset(5)
        }
        singleCheckView.snp.makeConstraints { (make) in
            make.left.equalTo(desContentLab)
            make.top.equalTo(desContentLab.snp.bottom).offset(kMargin)
            make.height.equalTo(34)
            make.width.equalTo(160)
        }
        
        saveBtn.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(kBottomTabbarHeight)
        }
    }
    
    /// 说明
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlueFontColor
        lab.text = "留言"
        lab.textAlignment = .center
        lab.borderColor = kBlueFontColor
        lab.borderWidth = klineWidth
        lab.cornerRadius = kCornerRadius
        
        return lab
    }()
    /// 是否语音留言
    lazy var voiceCheckView : LHSCheckView = {
        let checkView = LHSCheckView()
        checkView.nameLab.text = "是否语音留言"
        checkView.tagImgView.image = UIImage.init(named: "icon_check_normal")
        checkView.tagImgView.highlightedImage = UIImage.init(named: "icon_check_selected")
        checkView.tagImgView.isHighlighted = isVoice
        checkView.addOnClickListener(target: self, action: #selector(onClickedVoiceSelect))
        
        return checkView
    }()
    lazy var delImg: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_cancel"))
    /// 播放
    lazy var playBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("点击播放", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(playRecordVoice) , for: .touchUpInside)
        
        
        return btn
    }()
    /// 录音
    lazy var voiceBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("按住录音", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(startRecordVoice), for: .touchDown)
        btn.addTarget(self, action: #selector(cancelRecordVoice) , for: .touchUpInside)
        
        
        return btn
    }()
    /// 背景View
    lazy var bgView: UIView = {
        let v = UIView()
        v.borderColor = kGrayLineColor
        v.borderWidth = klineWidth
        
        return v
    }()
    
    /// 留言
    lazy var contentTxtView: UITextView = {
        
        let txtView = UITextView()
        txtView.font = k15Font
        txtView.textColor = kGaryFontColor
        
        return txtView
    }()
    /// 限制字数
    lazy var fontCountLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kGaryFontColor
        lab.textAlignment = .right
        lab.text = "0/\(contentMaxCount)"
        
        return lab
    }()
    
    
    /// 时间
    lazy var desTimeLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlueFontColor
        lab.text = "时间"
        lab.textAlignment = .center
        lab.borderColor = kBlueFontColor
        lab.borderWidth = klineWidth
        lab.cornerRadius = kCornerRadius
        
        return lab
    }()
    ///
    lazy var timeLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        lab.text = "如：单次 09：25"
        
        return lab
    }()
    /// icon
    lazy var iconTimeView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_naozhong"))
    /// 分割线
    var lineView : UIView = {
        let line = UIView()
        line.backgroundColor = kGrayLineColor
        return line
    }()
    ///
    lazy var desContentLab : UILabel = {
        let lab = UILabel()
        lab.font = k13Font
        lab.textColor = kBlackFontColor
        lab.numberOfLines = 0
        lab.text = "你想让叮当宝贝什么时间发送留言"
        
        return lab
    }()
    
    /// 轮询播报
    lazy var singleCheckView : LHSCheckView = {
        let checkView = LHSCheckView()
        checkView.nameLab.text = "是否要轮询播报"
        checkView.tagImgView.image = UIImage.init(named: "icon_check_normal")
        checkView.tagImgView.highlightedImage = UIImage.init(named: "icon_check_selected")
        checkView.tagImgView.isHighlighted = isLoop
        checkView.addOnClickListener(target: self, action: #selector(onClickedSelect))
        
        return checkView
    }()
    
    /// 保存
    lazy var saveBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("发送", for: .normal)
        btn.titleLabel?.font = k15Font
        
        btn.addTarget(self, action: #selector(clickedSaveBtn), for: .touchUpInside)
        
        return btn
    }()
    
    /// 是否语音留言
    @objc func onClickedVoiceSelect(){
        isVoice = !isVoice
        voiceCheckView.tagImgView.isHighlighted = isVoice
        bgView.isHidden = isVoice
        voiceBtn.isHidden = !isVoice
        if isVoice && recorderManager.recordName != nil {
            delImg.isHidden = false
            voiceBtn.isHidden = true
            playBtn.isHidden = false
        }else{
            delImg.isHidden = true
            voiceBtn.isHidden = !isVoice
            playBtn.isHidden = true
        }
    }
    
    /// 是否要轮询播报
    @objc func onClickedSelect(){
    
        isLoop = !isLoop
        singleCheckView.tagImgView.isHighlighted = isLoop
    }
    
    /// 开始录音
    @objc func startRecordVoice(){
        isVoiceUpload = true
        voiceBtn.setTitle("录音中...", for: .normal)
        recorderManager.beginRcord(recordType: .Wav)
    }
    /// 停止录音
    @objc func cancelRecordVoice(){
        recorderManager.stopRecord()
        voiceBtn.isHidden = true
        voiceBtn.setTitle("按住录音", for: .normal)
        playBtn.isHidden = false
        playBtn.setTitle("点击播放 \(recorderManager.recordSeconds)s", for: .normal)
        delImg.isHidden = false
    }
    /// 播放录音
    @objc func playRecordVoice(){
//        recorderManager.convertWavToAmr()
//        recorderManager.convertAmrToWav()
//        recorderManager.playWav()
        if isVoiceUpload {
            recorderManager.play(recordType: .Wav)
        }else{
            downLoadVoice()
        }
    }
    
    /// 删除本地录音
    @objc func onClickedDelVoice(){
        if isEdit {
            voiceBtn.isHidden = false
            playBtn.isHidden = true
            delImg.isHidden = true
            return
        }
        if recorderManager.recordName == nil {
            return
        }
        
        let fileManager = FileManager.default
        do{
            try fileManager.removeItem(atPath: NSHomeDirectory() + "/Documents/voiceMsg/\(recorderManager.recordName!).wav")
            voiceBtn.isHidden = false
            playBtn.isHidden = true
            delImg.isHidden = true
            recorderManager.recordName = nil
        }catch{
            print("Failed to remove file.")
        }
    }
    
    /// 留言信息
    func requestMessageInfo(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("leavemsg/listInfo", parameters: ["id":messageId,"deviceId":userDefaults.string(forKey: "devId") ?? ""],method : .get,  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let data = response["data"].dictionaryObject else { return }
                let model = HOOPLeaveMessageModel.init(dict: data)
                weakSelf?.setMessageInfo(dataModel: model)
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    func setMessageInfo(dataModel: HOOPLeaveMessageModel){
        if dataModel.leavemsgType == "AUDIO" {// 语音留言
            isVoice = true
            voiceCheckView.tagImgView.isHighlighted = true
            bgView.isHidden = isVoice
            delImg.isHidden = false
            voiceBtn.isHidden = true
            playBtn.isHidden = false
            recorderManager.recordName = dataModel.leavemsgName
        }else{
            isVoice = false
            bgView.isHidden = false
            voiceCheckView.tagImgView.isHighlighted = false
            delImg.isHidden = true
            voiceBtn.isHidden = !isVoice
            playBtn.isHidden = true
            
            contentTxtView.text = dataModel.msg
            contentTxtView.textColor = kBlackFontColor
            fontCountLab.text =  "\(contentTxtView.text.count)/\(contentMaxCount)"
        }
        sourceType = dataModel.type!
        self.week_time = dataModel.weak_time!
        self.day_time = dataModel.day_time!
        self.day = dataModel.yml!
        self.user_define_times = dataModel.user_define_times
        self.singleCheckView.tagImgView.isHighlighted = dataModel.loop == "1"
        self.setGuardTime()
    }
    /// 保存
    @objc func clickedSaveBtn(){
        if isVoiceUpload {
            if recorderManager.recordSeconds < 2 {
                MBProgressHUD.showAutoDismissHUD(message: "语音留言要大于2秒，请删除后重新录制")
                return
            }
        }else if !isVoice{
            if contentTxtView.text == placeHolder {
                MBProgressHUD.showAutoDismissHUD(message: placeHolder)
                return
            }
        }
        
        if day_time.isEmpty {
            MBProgressHUD.showAutoDismissHUD(message: "请选择留言时间")
            return
        }
        if week_time.isEmpty {
            MBProgressHUD.showAutoDismissHUD(message: "请选择留言执行周期")
            return
        }
        if isEdit {
            sendSaveEditMqttCmd()
        }else{// 记录
            sendSaveMqttCmd()
        }
        if isVoiceUpload {
            uploadVoice()
        }
    }
    
    /// 记录
    @objc func onClickRightBtn(){
        if isEdit {
            showDelete()
        }else{// 记录
            let vc = HOOPMessageRecordManagerVC()
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    /// 删除
    func showDelete(){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "确定要删除此留言吗?", cancleTitle: "取消", viewController: self, buttonTitles: "确定") { (index) in
            
            if index != cancelIndex{
                weakSelf?.sendSaveDeleteMqttCmd()
            }
        }
    }
    /// 编辑时间
    @objc func onClickedEditTime(){
        let vc = HOOPWarnEditTimeVC()
        vc.isShowDate = true
        vc.resultBlock = {[weak self] (dayTime, weekTime,customWeek,day) in
            
            self?.week_time = weekTime
            self?.day_time = dayTime
            self?.user_define_times = customWeek
            self?.day = day
            self?.setGuardTime()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// mqtt发布主题 新增
    func sendSaveMqttCmd(){
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","day_time":day_time,"loop":isLoop ? 1 : 0,"week_time":week_time,"user_define_times":user_define_times,"phone":userDefaults.string(forKey: "phone") ?? "","tts":(isVoice ? "":contentTxtView.text!),"day_of_year":day,"msg_type":"app_leavemsg_add","app_interface_tag":"","leavemsg_type":(isVoice ? "AUDIO":"TEXT"),"leavemsg_name":(isVoice ? recorderManager.recordName!:"")]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// mqtt发布主题 修改留言
    func sendSaveEditMqttCmd(){
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","leavemsg_id":messageId,"day_time":day_time,"week_time":week_time,"user_define_times":user_define_times,"phone":userDefaults.string(forKey: "phone") ?? "","tts":(isVoice ? "":contentTxtView.text!),"loop":isLoop ? 1 : 0,"day_of_year":day,"msg_type":"app_leavemsg_edit","app_interface_tag":"","leavemsg_type":(isVoice ? "AUDIO":"TEXT"),"leavemsg_name":(isVoice ? recorderManager.recordName!:""),"type":sourceType]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    /// mqtt发布主题 删除留言
    func sendSaveDeleteMqttCmd(){
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","leavemsg_id":messageId,"phone":userDefaults.string(forKey: "phone") ?? "","msg_type":"app_leavemsg_del","app_interface_tag":"","type": sourceType]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    
    func uploadVoice(){
        weak var weakSelf = self
        createHUD(message: "加载中...")
        recorderManager.convertWavToAmr()
        GYZNetWork.uploadVideoRequest("voiceMessage/upload.html",baseUrl:"http://119.29.107.14:8080/robot_filter-web/", parameters: ["boardId":userDefaults.string(forKey: "devId") ?? ""], fileUrl: URL.init(fileURLWithPath: NSHomeDirectory() + "/Documents/voiceMsg/\(recorderManager.recordName!).amr"), keyName: "uploadFiles", fileName: recorderManager.recordName! + ".amr", success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["successful"].boolValue{//请求成功
                
                
            }
        }) { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        }
        
    }
    func downLoadVoice(){
        weak var weakSelf = self
        createHUD(message: "加载中...")
        GYZNetWork.downLoadRequest("http://119.29.107.14:8080/robot_filter-web/voiceMessage/download.html", parameters: ["boardId":userDefaults.string(forKey: "devId") ?? "","fileName":recorderManager.recordName!], method: .post, success: { (response) in
//            sleep(1)
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            weakSelf?.playDownLoadVoice()
        }) { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        }
    }
    
    func playDownLoadVoice(){
        recorderManager.convertAmrToWav()
        recorderManager.playWav()
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
            if (type == "app_leavemsg_add_re" || type == "app_leavemsg_edit_re" || type == "app_leavemsg_del_re") && phone == userDefaults.string(forKey: "phone"){
                hud?.hide(animated: true)
                MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                if result["code"].intValue == kQuestSuccessTag{
                    
                    if resultBlock != nil{
                        resultBlock!(true)
                    }
                    clickedBackBtn()
                }
            }
            
        }
    }
    /// 解析时间
    func setGuardTime(){
        
        if week_time == "USER_DEFINE" {// 自定义
            var days: String = ""
            for item in user_define_times{
                days += GUARDBUFANGTIMEBYWEEKDAY[item]! + ","
            }
            if days.count > 0{
                days = days.subString(start: 0, length: days.count - 1)
            }
            timeLab.text = day_time + " " + days
        }else if week_time == "ONCE"{
            timeLab.text = day + " " + day_time + " " + GUARDBUFANGTIME[week_time]!
        }else{
            timeLab.text = day_time + " " + GUARDBUFANGTIME[week_time]!
        }
    }
}


extension HOOPLeaveMessageVC : UITextViewDelegate{
    ///MARK UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        let text = textView.text
        if text == placeHolder {
            textView.text = ""
            textView.textColor = kBlackFontColor
        }
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            textView.text = placeHolder
            textView.textColor = kGaryFontColor
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.count > contentMaxCount - 20 {
            
            //获得已输出字数与正输入字母数
            let selectRange = textView.markedTextRange
            
            //获取高亮部分 － 如果有联想词则解包成功
            if let selectRange =   selectRange {
                let position =  textView.position(from: (selectRange.start), offset: 0)
                if (position != nil) {
                    return
                }
            }
            
            let textContent = textView.text
            let textNum = textContent?.count
            
            //截取20个字
            if textNum! > contentMaxCount {
                let index = textContent?.index((textContent?.startIndex)!, offsetBy: contentMaxCount)
                let str = textContent?.substring(to: index!)
                textView.text = str
            }
        }
        
        self.fontCountLab.text =  "\(textView.text.count)/\(contentMaxCount)"
    }
}
