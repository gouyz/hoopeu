//
//  HOOPSeeVC.swift
//  hoopeu
//  爱心看护
//  Created by gouyz on 2019/1/3.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD

private let seeVideoCell = "seeVideoCell"

class HOOPSeeVC: GYZBaseVC {
    
    let cellH = 50 + (kScreenWidth - kMargin * 2) * 0.47 + kMargin + klineWidth

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "爱心看护"
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_home_menu")?.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(clickedMenuBtn))
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // 本页面开启支持打开侧滑菜单
//        self.menuContainerViewController.sideMenuPanMode = .defaults
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        // 本页面开启支持关闭侧滑菜单
//        self.menuContainerViewController.sideMenuPanMode = .none
//    }
//    /// 左侧菜单
//    @objc func clickedMenuBtn(){
//        self.menuContainerViewController.toggleLeftSideMenu(completeBolck: nil)
//    }
    
    lazy var tableView : UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = kWhiteColor
        
        table.register(HOOPSeeVideoCell.self, forCellReuseIdentifier: seeVideoCell)
        
        return table
    }()
    /// 设置
    @objc func onClickedSetting(btn: UIButton){
        let vc = HOOPSeeSettingVC()
        navigationController?.pushViewController(vc, animated: true)
        
    }
    /// 播放
    @objc func onClickedPlay(sender: UITapGestureRecognizer){
        if userDefaults.bool(forKey: "wifiStatus") {
            if !(networkManager?.isReachableOnEthernetOrWiFi)!{
                MBProgressHUD.showAutoDismissHUD(message: "您设置了只在WiFi下观看，请连接WiFi")
                return
            }
        }
        
        let vc = HOOPPlayerDetailVC()
//        let vc = HOOPSeePlayerVC()
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension HOOPSeeVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: seeVideoCell) as! HOOPSeeVideoCell
        cell.settingBtn.tag = indexPath.row
        cell.settingBtn.isEnabled = false
        cell.settingBtn.addTarget(self, action: #selector(onClickedSetting(btn:)), for: .touchUpInside)
        cell.iconBgView.isUserInteractionEnabled = true
        cell.iconPlayView.tag = indexPath.row
        cell.iconPlayView.addOnClickListener(target: self, action: #selector(onClickedPlay(sender:)))
        
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        return UIView()
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView()
    }
    ///MARK : UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return cellH
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
}
