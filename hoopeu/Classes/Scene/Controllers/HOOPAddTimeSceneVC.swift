//
//  HOOPAddTimeSceneVC.swift
//  hoopeu
//  定时场景
//  Created by gouyz on 2020/1/13.
//  Copyright © 2020 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

private let addTimeSceneCell = "addTimeSceneCell"
private let addTimeSceneHeader = "addTimeSceneHeader"

class HOOPAddTimeSceneVC: GYZBaseVC {
    
    var isEdit: Bool = false
    
    var sayArr: [String] = ["添加条件"]
    var doArr: [String] = ["添加让叮当宝贝做的事"]
    var doDicArr: [[String:Any]] = [[String:Any]]()
    var sceneName: String = "请设置场景名称"
    
    /// 用户想要播报的语句的日期
    var day: String = ""
    /// 用户想要播报的语句的时间
    var day_time: String = ""
    /// 每周循环时间 ,ONCE:仅此一次,EVERYDAY :每天,WEEKDAY:工作日,WEEKEND:每周末,USER_DEFINE:自定义
    var week_time: String = ""
    /// 用户自定义时间选择，可多选。EVERY_MONDAY:每周一,EVERY_TUESDAY:每周二,EVERY_WEDNESDAY:每周三,EVERY_THURSDAY:每周四,EVERY_FRIDAY:每周五,EVERY_SATURDAY:每周六,EVERY_SUNDAY:每周日
    var user_define_times: [String] = [String]()
    /// 时间显示
    var timeTxt: String = ""
    /// 选择结果回调
    var resultBlock:(() -> Void)?
    var sceneId: String = ""
    var sceneDetailModel: HOOPSceneDetailModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "新建场景"
        
        view.addSubview(saveBtn)
        view.addSubview(tableView)
        saveBtn.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(view)
            make.height.equalTo(kBottomTabbarHeight)
        }
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.bottom.equalTo(saveBtn.snp.top)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view)
            }else{
                make.top.equalTo(kTitleAndStateHeight)
            }
        }
        if isEdit {
            let rightBtn = UIButton(type: .custom)
            rightBtn.setTitle("删除", for: .normal)
            rightBtn.titleLabel?.font = k15Font
            rightBtn.setTitleColor(kRedFontColor, for: .normal)
            rightBtn.frame = CGRect.init(x: 0, y: 0, width: kTitleHeight, height: kTitleHeight)
            rightBtn.addTarget(self, action: #selector(onClickRightBtn), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBtn)
            
            requestSceneInfo()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mqttSetting()
    }
    
    lazy var tableView : UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        
        table.register(HOOPAddVoiceSceneCell.self, forCellReuseIdentifier: addTimeSceneCell)
        table.register(LHSGeneralHeaderView.self, forHeaderFooterViewReuseIdentifier: addTimeSceneHeader)
        
        return table
    }()
    
    /// 保存按钮
    lazy var saveBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitle("保存", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        
        btn.addTarget(self, action: #selector(clickedSaveBtn), for: .touchUpInside)
        
        return btn
    }()
    /// 场景信息
    func requestSceneInfo(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("scene/timer", parameters: ["id":sceneId],method : .get,  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let data = response["data"].dictionaryObject else { return }
                weakSelf?.sceneDetailModel = HOOPSceneDetailModel.init(dict: data)
                weakSelf?.setSceneInfo()
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    func setSceneInfo(){
        if sceneDetailModel != nil {
            sceneName = (sceneDetailModel?.sceneModel?.name)!
            self.navigationItem.title = sceneName
            
            self.week_time = (sceneDetailModel?.sceneModel?.weekTime)!
            self.day_time = (sceneDetailModel?.sceneModel?.dayTime)!
            self.day = (sceneDetailModel?.sceneModel?.dayOfYear)!
            self.user_define_times = sceneDetailModel!.userDefineTimesArray
            self.setGuardTime()
            
            for item in (sceneDetailModel?.sceneDoList)!{
                doArr.insert(item.cmd!, at: 0)
                let dic:[String: Any] = ["cmd_type":item.type!,"cmd":item.cmd!,"time_len":item.time!]
                doDicArr.insert(dic, at: 0)
            }
            tableView.reloadData()
        }
    }
    
    /// 删除
    @objc func onClickRightBtn(){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "确定要删除吗?", cancleTitle: "取消", viewController: self, buttonTitles: "确定") { (index) in
            
            if index != cancelIndex{
                weakSelf?.deleteScene()
            }
        }
    }
    /// 删除
    func deleteScene(){
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","phone":userDefaults.string(forKey: "phone") ?? "","scene_id":Int.init(sceneId)!,"msg_type":"app_timer_scene_del","app_interface_tag":""]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    
    /// 保存
    @objc func clickedSaveBtn(){
        if sceneName.isEmpty || sceneName == "请设置场景名称" {
            MBProgressHUD.showAutoDismissHUD(message: "请设置场景名称")
            return
        }
        if day_time.isEmpty {
            MBProgressHUD.showAutoDismissHUD(message: "请选择定时时间")
            return
        }
        if week_time.isEmpty {
            MBProgressHUD.showAutoDismissHUD(message: "请选择定时执行周期")
            return
        }
        if doDicArr.count == 0 {
            MBProgressHUD.showAutoDismissHUD(message: "请添加让叮当宝贝做的事")
            return
        }
        
        createHUD(message: "加载中...")
        var paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","phone":userDefaults.string(forKey: "phone") ?? "","timer_scene_name":sceneName,"day_of_year":day,"day_time":day_time,"week_time":week_time,"user_define_times":user_define_times,"cmds":doDicArr,"app_interface_tag":""]
        if isEdit {
            paramDic["timer_scene_id"] = Int.init(sceneId)!
            paramDic["msg_type"] = "app_timer_scene_edit"
        }else{
            paramDic["msg_type"] = "app_timer_scene_add"
        }
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    
    /// 编辑场景名称
    func goSceneNameVC(){
        let vc = HOOPSceneNameVC()
        vc.isEdit = isEdit
        if sceneName != "请设置场景名称" {
            vc.sceneName = sceneName
        }
        vc.resultBlock = {[weak self](name) in
            self?.sceneName = name
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 编辑定时时间
    func goSceneConditionVC(){
        let vc = HOOPWarnEditTimeVC()
        vc.isShowDate = true
        vc.resultBlock = {[weak self] (dayTime, weekTime,customWeek,day) in
            
            self?.week_time = weekTime
            self?.day_time = dayTime
            self?.user_define_times = customWeek
            self?.day = day
            self?.setGuardTime()
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
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
            timeTxt = day_time + " " + days
        }else if week_time == "ONCE"{
            timeTxt = day + " " + day_time + " " + GUARDBUFANGTIME[week_time]!
        }else{
            timeTxt = day_time + " " + GUARDBUFANGTIME[week_time]!
        }
    }
    /// 做
    func goSceneDo(index: Int){
        
        if index == doArr.count - 1 {//添加叮当宝贝会做
            let mmShareSheet = MMShareSheet.init(title: nil, cards: kSceneDoCards, duration: nil, cancelBtn: nil)
            mmShareSheet.callBack = { [weak self](handler) ->() in
                
                if handler != "cancel" {// 取消
                    if handler == "alarm"{// 报警
                        let dic:[String: Any] = ["cmd_type":"alarm","cmd":"报警","time_len":0]
                        self?.doArr.insert(dic["cmd"] as! String, at: index)
                        self?.doDicArr.append(dic)
                        
                        self?.tableView.reloadData()
                    }else{
                        self?.goSceneDoVC(index: index,type: handler,title: SCENETYPE[handler]!)
                    }
                }
            }
            mmShareSheet.present()
        }else{
            
            let type = doDicArr[index]["cmd_type"] as! String
            if type == "alarm"{/// 报警
                self.doDicArr.remove(at: index)
                self.doArr.remove(at: index)
                self.tableView.reloadData()
                return
            }
            let vc = HOOPEditSceneDoVC()
            vc.isEdit = true
            vc.doType = type
            vc.doTitle = SCENETYPE[type]!
            vc.doContent = doDicArr[index]["cmd"] as! String
            vc.selectSecond = doDicArr[index]["time_len"] as! Int
            vc.resultBlock = {[weak self](dic) in
                if dic.count == 0{// 删除时
                    self?.doDicArr.remove(at: index)
                    self?.doArr.remove(at: index)
                }else{
                    self?.doArr[index] = dic["cmd"] as! String
                    self?.doDicArr[index] = dic
                }
                
                self?.tableView.reloadData()
            }
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    /// 叮当宝贝会做
    func goSceneDoVC(index: Int,type:String,title: String){
        let vc = HOOPEditSceneDoVC()
        vc.doType = type
        vc.doTitle = title
        vc.resultBlock = {[weak self](dic) in
            self?.doArr.insert(dic["cmd"] as! String, at: index)
            self?.doDicArr.append(dic)
            
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
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
            
            if ((type == "app_timer_scene_add_re" && !isEdit) || (type == "app_timer_scene_edit_re" && isEdit) || type == "app_timer_scene_del_re") && phone == userDefaults.string(forKey: "phone"){
                self.hud?.hide(animated: true)
                if result["code"].intValue == kQuestSuccessTag{
                    if resultBlock != nil {
                        resultBlock!()
                    }
                    clickedBackBtn()
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                }
            }
            
        }
    }
}

extension HOOPAddTimeSceneVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 2 {
            return doArr.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: addTimeSceneCell) as! HOOPAddVoiceSceneCell
        
        cell.nameLab.backgroundColor = kBtnClickBGColor
        cell.nameLab.textColor = kWhiteColor
        if indexPath.section == 0 {
            cell.nameLab.text = sceneName
        }else if indexPath.section == 1 {
            cell.nameLab.text = timeTxt
        }else if indexPath.section == 2 {
            cell.nameLab.text = doArr[indexPath.row]
            if indexPath.row == doArr.count - 1{
                cell.nameLab.backgroundColor = kWhiteColor
                cell.nameLab.textColor = kBlueFontColor
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: addTimeSceneHeader) as! LHSGeneralHeaderView
        
        if section == 0 {
            headerView.nameLab.text = "场景名称"
        }else if section == 1{
            headerView.nameLab.text = "时间"
        }else{
            headerView.nameLab.text = "叮当宝贝会"
        }
        
        return headerView
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {// 编辑场景名称
            goSceneNameVC()
        }else if indexPath.section == 1{//时间
            goSceneConditionVC()
        }else{//叮当宝贝会做
            goSceneDo(index: indexPath.row)
        }
    }
    ///MARK : UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kTitleHeight
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return klineWidth
    }
}
