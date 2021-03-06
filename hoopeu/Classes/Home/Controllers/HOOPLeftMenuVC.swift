//
//  HOOPLeftMenuVC.swift
//  hoopeu
//  侧边栏
//  Created by gouyz on 2019/2/20.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD

private let leftMenuCell = "leftMenuCell"

class HOOPLeftMenuVC: GYZBaseVC {
    
    let titleArray = ["设备管理", "技能设置", "智能场景", "房间管理", "使用帮助", "联系我们", "软件版本", "注册保修"]
    
    var dataModel: HOOPParamDetailModel?
    // APP更新
    var updateType: UpdateVersionType = .noUpdate
    ///更新内容
    var updateMessage: String = ""
    ///新版本名称
    var newVersionName: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = kWhiteColor
        
        view.addSubview(headerView)
        view.addSubview(tableView)
        
        headerView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(view)
            make.height.equalTo(kLeftMenuWidth * 0.44 + kStateHeight)
        }
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(headerView.snp.bottom)
        }
//        headerView.nameLab.text = userDefaults.string(forKey: "phone")
        /// 个人信息
        headerView.onClickedOperatorBlock = {[weak self] () in
            self?.goProfileVC()
        }
        
        //注册通知
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView(noti:)), name: NSNotification.Name(rawValue: "FWSideMenuStateNotificationEvent"), object: nil)
        
        requestUserInfo()
        requestVersion()
    }
    
    @objc func refreshView(noti: NSNotification){
        let userInfo = noti.userInfo!
        if userInfo["eventType"] as! NSNumber == NSNumber(value: Int8(FWSideMenuStateEvent.willOpen.rawValue)) {
            
            dataModel = nil
            requestIsPerfect()
        }
    }

    lazy var headerView: HOOPMenuHeaderView = HOOPMenuHeaderView()
    lazy var tableView : UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.separatorColor = kGrayLineColor
        table.backgroundColor = kWhiteColor
        
        table.register(HOOPLeftMenuCell.self, forCellReuseIdentifier: leftMenuCell)
        
        return table
    }()
    /// 个人信息
    func goProfileVC(){
        let vc = HOOPMyProfileVC()
        goChildController(vc: vc)
    }
    
    /// 请求服务器版本
    func requestVersion(){
        weak var weakSelf = self
        GYZNetWork.requestNetwork("appVersion/app/ios",isToken:false, parameters: nil,method:.get, success:{ (response) in
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                let data = response["data"]
                weakSelf?.updateMessage = data["updateMessage"].stringValue
                weakSelf?.newVersionName = data["versionName"].stringValue
                weakSelf?.updateType = GYZUpdateVersionTool.compareVersion(newVersion: data["versionName"].stringValue)
                
                weakSelf?.tableView.reloadData()
            }
        }, failture: { (error) in
            GYZLog(error)
        })
    }
   
    /**
     * //不强制更新
     * @param version 版本名称
     * @param content 更新内容
     */
    func updateVersion(version: String,content: String){
        let alert = UIAlertView.init(title: "发现新版本\(version)", message: content, delegate: self, cancelButtonTitle: "残忍拒绝", otherButtonTitles: "立即更新")
        alert.tag = 103
        alert.show()
    }
    /**
     * 强制更新
     * @param version 版本名称
     * @param content 更新内容
     */
    func updateNeedVersion(version: String,content: String){
        
        let alert = UIAlertView.init(title: "发现新版本\(version)", message: content, delegate: self, cancelButtonTitle: "立即更新")
        alert.tag = 104
        alert.show()
    }
    
    // 系统升级
    func showSystemVersion(){
        switch updateType {
        case .update:
            updateVersion(version: newVersionName, content: updateMessage)
        case .updateNeed:
            updateNeedVersion(version: newVersionName, content: updateMessage)
        default:
            GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "当前已是最新版本", cancleTitle: nil, viewController: self, buttonTitles: "我知道了") { (index) in
                
            }
        }
    }
    /// 用户信息
    func requestUserInfo(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("user/current", parameters: nil,  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                let data = response["data"]
                weakSelf?.headerView.nameLab.text = data["name"].string
                
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    /// 用户资料是否完善
    func requestIsPerfect(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("user/isPerfect", parameters: nil,  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let itemInfo = response["data"].dictionaryObject else { return }
                weakSelf?.dataModel = HOOPParamDetailModel.init(dict: itemInfo)
                weakSelf?.tableView.reloadData()
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    
    /// 跳转到子控制器
    func goChildController(vc: GYZBaseVC){
        var navigationController: UINavigationController?
        
        if self.menuContainerViewController.centerViewController!.isKind(of: UITabBarController.self) {
            let tmpVC = self.menuContainerViewController.centerViewController!.children[0]
            if tmpVC.isKind(of: UINavigationController.self) {
                navigationController = tmpVC as? UINavigationController
            }
        } else if self.menuContainerViewController.centerViewController!.isKind(of: UINavigationController.self) {
            navigationController = self.menuContainerViewController.centerViewController as? UINavigationController
        }
        
        if navigationController != nil {
            navigationController!.pushViewController(vc, animated: true)
        }
        
        self.menuContainerViewController.setSideMenuState(state: .closed, completeBlock: nil)
    }
}
extension HOOPLeftMenuVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: leftMenuCell) as! HOOPLeftMenuCell
        
        cell.nameLab.text = titleArray[indexPath.row]
        cell.contentLab.text = ""
       
        if indexPath.row == titleArray.count - 1 {//保修
            if let model = dataModel {
                if model.isPerfect == "1" {
                    cell.nameLab.clearBadge(animated: false)
                }else{
                    cell.nameLab.badgeView.style = .normal
                    cell.nameLab.showBadge(animated: false)
                }
            }else{
               cell.nameLab.clearBadge(animated: false)
            }
        }else if indexPath.row == titleArray.count - 2{//软件版本
            if updateType != .noUpdate {
                cell.nameLab.badgeView.style = .normal
                cell.nameLab.showBadge(animated: false)
            }else{
                cell.nameLab.clearBadge(animated: false)
            }
            cell.contentLab.text = "V" + GYZUpdateVersionTool.getCurrVersion()
        }else{
            cell.nameLab.clearBadge(animated: false)
        }
        
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        return UIView()
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0: /// 设备管理
            goChildController(vc: HOOPDeviceManagerVC())
        case 1: /// 技能设置
            let vc = JSMWebViewVC()
            vc.url = "http://www.hoopeurobot.com/skill_details/index.html"
            vc.webTitle = "技能设置"
            goChildController(vc: vc)
//            goChildController(vc: HOOPSkillVC())
        case 2: /// 智能场景
            goChildController(vc: HOOPSceneVC())
        case 3: /// 房间管理
            goChildController(vc: HOOPRoomManagerVC())
        case 4: /// 使用帮助
            goChildController(vc: HOOPUseHelpVC())
        case 5: /// 联系我们
            goChildController(vc: HOOPAboutUsVC())
        case 6: /// 软件版本
            showSystemVersion()
        case 7: /// 注册保修
            let vc = HOOPRepairVC()
            vc.isGoHome = false
            vc.dataModel = self.dataModel
            goChildController(vc: vc)
        default:
            break
        }
    }
    ///MARK : UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
}
extension HOOPLeftMenuVC : UIAlertViewDelegate{
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        let tag = alertView.tag
        if tag == 103{
            if buttonIndex == 1{//立即更新
                GYZUpdateVersionTool.goAppStore()
            }
        }else if tag == 104{
            if buttonIndex == 0{//立即更新
                GYZUpdateVersionTool.goAppStore()
            }
        }
        
    }
}
