//
//  HOOPMyProfileVC.swift
//  hoopeu
//  个人信息
//  Created by gouyz on 2019/2/21.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

private let profileCell = "profileCell"

class HOOPMyProfileVC: GYZBaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "个人信息"
        
        view.addSubview(loginOutBtn)
        view.addSubview(tableView)
        loginOutBtn.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(view)
            make.height.equalTo(kBottomTabbarHeight)
        }
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.bottom.equalTo(loginOutBtn.snp.top)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view)
            }else{
                make.top.equalTo(kTitleAndStateHeight)
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var tableView : UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.separatorColor = kGrayLineColor
        table.backgroundColor = kWhiteColor
        
        table.register(GYZMyProfileCell.self, forCellReuseIdentifier: profileCell)
        
        return table
    }()
    
    /// 退出登录按钮
    lazy var loginOutBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kRedFontColor
        btn.setTitle("退出登录", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k15Font
        
        btn.addTarget(self, action: #selector(clickedLoginOutBtn), for: .touchUpInside)
        
        return btn
    }()
    
    /// 退出登录
    @objc func clickedLoginOutBtn(){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: "提示", message: "确定要退出登录吗?", cancleTitle: "取消", viewController: self, buttonTitles: "确定") { (index) in
            
            if index != cancelIndex{
                weakSelf?.loginOut()
            }
        }
        
    }
    func loginOut(){
        GYZTool.removeUserInfo()
        JPUSHService.deleteAlias({ (iResCode, iAlias, seq) in
            
        }, seq: 0)
        let vc = HOOPLoginVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 修改密码
    func goPwdVC(){
        let vc = HOOPModifyOldPwdVC()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HOOPMyProfileVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: profileCell) as! GYZMyProfileCell
        
        cell.desLab.textColor = kGaryFontColor
        cell.userImgView.isHidden = true
        cell.desLab.isHidden = true
        cell.rightIconView.isHidden = false
        
        if indexPath.row == 0{
            cell.nameLab.text = "注册账号"
            cell.desLab.isHidden = false
            cell.rightIconView.isHidden = true
            cell.desLab.text = userDefaults.string(forKey: "phone")
        }else if indexPath.row == 1{
            cell.nameLab.text = "修改密码"
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
        
        if indexPath.row == 1{/// 修改密码
            goPwdVC()
        }
    }
    ///MARK : UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
}
