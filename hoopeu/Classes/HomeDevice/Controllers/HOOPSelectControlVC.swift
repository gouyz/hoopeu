//
//  HOOPSelectControlVC.swift
//  hoopeu
//  家电遥控 选择遥控器类型
//  Created by gouyz on 2019/2/27.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

private let selectControlCell = "selectControlCell"

class HOOPSelectControlVC: GYZBaseVC {

    let titleArray = ["空调遥控器", "电视遥控器", "机顶盒遥控器", "IPTV遥控器", "音响遥控器", "投影仪遥控器", "风扇遥控器", "自定义遥控器"]
    var deviceType: DeviceType = .ARC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "选择遥控器类型"
        
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
        
        table.register(GYZLabArrowCell.self, forCellReuseIdentifier: selectControlCell)
        
        return table
    }()
    
    /// 空调遥控器
    func goSelectARC(){
        let vc = HOOPSelectARCBrandVC()
        vc.deviceType = self.deviceType
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 电视遥控器
    func goSelectTV(){
        let vc = HOOPTVControlVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 机顶盒遥控器
    func goSelectSTB(){
        let vc = HOOPSTBControlVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// IPTV遥控器
    func goSelectIPTV(){
        let vc = HOOPIPTVControllVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 音响遥控器
    func goSelectSound(){
        let vc = HOOPSoundControlVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 投影仪遥控器
    func goSelectProjector(){
        let vc = HOOPProjectorControlVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 风扇遥控器
    func goSelectFan(){
        let vc = HOOPFanControlVC()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HOOPSelectControlVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: selectControlCell) as! GYZLabArrowCell
        
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
        
        if indexPath.row == 7 {// 自定义遥控器
            
        }else{
            
            switch indexPath.row {
            case 0://空调遥控器
                deviceType = .ARC
            case 1://电视遥控器
                deviceType = .TV
            case 2://机顶盒遥控器
                deviceType = .tvBox
            case 3://IPTV遥控器
                deviceType = .IPTV
            case 4://音响遥控器
                deviceType = .DVD
            case 5://投影仪遥控器
                deviceType = .PJT
            case 6://风扇遥控器
                deviceType = .fan
            default:
                break
            }
            
            goSelectARC()
        }
        
    }
}
