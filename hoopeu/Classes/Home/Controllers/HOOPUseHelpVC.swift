//
//  HOOPUseHelpVC.swift
//  hoopeu
//  使用帮助
//  Created by gouyz on 2019/2/22.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

private let useHelpCell = "useHelpCell"
private let useHelpHeader = "useHelpHeader"

class HOOPUseHelpVC: GYZBaseVC {
    
    let titleArray = [["使用说明", "常见问题", "客户服务"],["使用说明", "常见问题", "客户服务"]]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "使用帮助"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
    lazy var tableView : UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = kBackgroundColor
        
        table.register(GYZLabArrowCell.self, forCellReuseIdentifier: useHelpCell)
        table.register(LHSGeneralHeaderView.self, forHeaderFooterViewReuseIdentifier: useHelpHeader)
        
        return table
    }()
    
    /// 机器人使用说明
    func robotInstruction(){
        let vc = HOOPRobotInstructionVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 机器人常见问题
    func robotProblem(){
        let vc = HOOPRobotProblemVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 智能产品使用说明
    func onOffInstruction(){
        let vc = HOOPOnOffInstructionVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 智能产品常见问题
    func onOffProblem(){
        let vc = HOOPOnOffProblemVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 智能机器人/智能产品-客户服务
    func goWebVC(id: String){
        let vc = JSMWebViewVC()
        vc.webTitle = "客户服务"
        vc.url = "http://www.hoopeurobot.com/page/protocol.html?id=" + id
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HOOPUseHelpVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return titleArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return titleArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: useHelpCell) as! GYZLabArrowCell
        
        cell.nameLab.text = titleArray[indexPath.section][indexPath.row]
        
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: useHelpHeader) as! LHSGeneralHeaderView
        
        headerView.nameLab.textColor = kBlueFontColor
        headerView.nameLab.font = UIFont.boldSystemFont(ofSize: 15)
        if section == 0 {
            headerView.nameLab.text = "智能机器人"
        }else{
            headerView.nameLab.text = "智能产品"
        }
        
        return headerView
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {// 机器人
            if indexPath.row == 0{// 使用说明
                robotInstruction()
            }else if indexPath.row == 1{// 常见问题
                robotProblem()
            }else{
                goWebVC(id: "7")
            }
        }else{//智能产品
            if indexPath.row == 0{// 使用说明
                onOffInstruction()
            }else if indexPath.row == 1{// 常见问题
                onOffProblem()
            }else{
                goWebVC(id: "8")
            }
        }
    }
    ///MARK : UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return kMargin
    }
}
