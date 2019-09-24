//
//  HOOPSelectARCBrandVC.swift
//  hoopeu
//  选择空调品牌
//  Created by gouyz on 2019/2/28.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD

private let selectARCBrandCell = "selectARCBrandCell"
private let selectARCBrandHeader = "selectARCBrandHeader"

class HOOPSelectARCBrandVC: GYZBaseVC {
    /// 所选品牌的方案
    var deviceModelList: [DeviceM] = [DeviceM]()

    var indexList: [String] = [String]()
    var brandList: [[String:String]] = [[String:String]]()
    var brandTitleList: [[String]] = [[String]]()
    var deviceType: DeviceType = .ARC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "选择品牌"
        
        dealData()
        
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
        
        table.register(GYZLabArrowCell.self, forCellReuseIdentifier: selectARCBrandCell)
        table.register(LHSGeneralHeaderView.self, forHeaderFooterViewReuseIdentifier: selectARCBrandHeader)
        
        return table
    }()
    ///选择遥控器
    func goSelectARCControl(name: String){
        getDeviceModel(name: name)
        var curIndex: Int = 0
        if deviceModelList.count > 0 {
            for (index,brandItem) in brandList.enumerated() {
                if name == brandItem["brand"]{
                    curIndex = index
                    break
                }
            }
            let vc = HOOPSelectARCControlVC()
            vc.brandName = name
            vc.deviceType = self.deviceType
            vc.dataList = deviceModelList
            vc.curMatchBrandIndex = curIndex
            navigationController?.pushViewController(vc, animated: true)
        }else{
           MBProgressHUD.showAutoDismissHUD(message: "该品牌暂无遥控器方案")
        }
    }
    /// 获取所选品牌的遥控器方案数据
    func getDeviceModel(name: String){
        deviceModelList = IRDBManager.shareInstance()?.getAllNoModel(byBrand: name, deviceType: self.deviceType) as! [DeviceM]
    }
    
    func dealData(){
        brandList = IRDBManager.shareInstance()?.getAllBrand(by: deviceType) as! [[String:String]]
        if brandList.count > 0 {
            var pinYin: String = brandList[0]["pinyin"]!.subString(start: 0, length: 1)
            indexList.append(pinYin)
            var titleArr: [String] = [String]()
            for (index,brandItem) in brandList.enumerated() {
                if pinYin != brandItem["pinyin"]!.subString(start: 0, length: 1){
                    brandTitleList.append(titleArr)
                    titleArr = [String]()
                    titleArr.append(brandItem["brand"]!)
                    pinYin = brandItem["pinyin"]!.subString(start: 0, length: 1)
                    indexList.append(pinYin)
                }else{
                    titleArr.append(brandItem["brand"]!)
                    if index == brandList.count - 1{
                        brandTitleList.append(titleArr)
                    }
                }
            }
        }
        
    }
}

extension HOOPSelectARCBrandVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return indexList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return brandTitleList[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: selectARCBrandCell) as! GYZLabArrowCell
        
        cell.nameLab.text = brandTitleList[indexPath.section][indexPath.row]
        cell.rightIconView.isHidden = true
        
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: selectARCBrandHeader) as! LHSGeneralHeaderView
        
        headerView.nameLab.text = indexList[section]
        headerView.contentView.backgroundColor = kBackgroundColor
        headerView.nameLab.textColor = kBlueFontColor
        headerView.lineView.isHidden = true
        
        return headerView
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView()
    }
    ///MARK : UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        goSelectARCControl(name: brandTitleList[indexPath.section][indexPath.row])
    }
    
    //实现索引数据源代理方法
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indexList
    }
    
    //点击索引，移动TableView的组位置
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        var tpIndex:Int = 0
        //遍历索引值
        for character in indexList{
            //判断索引值和组名称相等，返回组坐标
            if character == title{
                return tpIndex
            }
            tpIndex += 1
        }
        return 0
    }
}
