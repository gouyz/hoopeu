//
//  HOOPChuanGanListVC.swift
//  hoopeu
//  选择传感设备类型
//  Created by gouyz on 2019/6/8.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

private let selectChuanGanCell = "selectChuanGanCell"

class HOOPChuanGanListVC: GYZBaseVC {
    
    let titleArray = ["求助设备", "门磁设备", "防盗设备", "烟雾报警设备", "煤气报警设备","通用传感器"]
    let typeArray = [1, 2, 3, 4, 5,6]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "选择传感设备类型"
        
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
        table.backgroundColor = kWhiteColor
        
        table.register(GYZLabArrowCell.self, forCellReuseIdentifier: selectChuanGanCell)
        
        return table
    }()

    func goSensorVC(type: Int){
        let vc = HOOPChuanGanDeviceVC()
        vc.ctrlDevType = type
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension HOOPChuanGanListVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: selectChuanGanCell) as! GYZLabArrowCell
        
        cell.nameLab.text = titleArray[indexPath.row]
        
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
        
        return 60
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goSensorVC(type: typeArray[indexPath.row])
    }
}
