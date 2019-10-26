//
//  HOOPAboutUsVC.swift
//  hoopeu
//  联系我们
//  Created by gouyz on 2019/2/22.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD

private let aboutUsCell = "aboutUsCell"

class HOOPAboutUsVC: GYZBaseVC {
    
    let titleArray = ["公众号", "网站", "QQ交流群", "服务热线"]
    var infoArray = ["", "", "", ""]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "联系我们"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        requestAboutUs()
    }
    
    lazy var tableView : UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.separatorColor = kGrayLineColor
        table.backgroundColor = kWhiteColor
        
        table.register(GYZMyProfileCell.self, forCellReuseIdentifier: aboutUsCell)
        
        return table
    }()
    
    /// 修改密码
    func goPwdVC(){
        let vc = HOOPModifyOldPwdVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///获取关于我们信息
    func requestAboutUs(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("file/aboutWe",parameters: nil,method:.get,  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                let data = response["data"]
                weakSelf?.infoArray[0] = data["subscription"].stringValue
                weakSelf?.infoArray[1] = data["website"].stringValue
                weakSelf?.infoArray[2] = data["qq"].stringValue
                weakSelf?.infoArray[3] = data["phone"].stringValue
                weakSelf?.tableView.reloadData()
                
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
}

extension HOOPAboutUsVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: aboutUsCell) as! GYZMyProfileCell
        
        cell.desLab.textColor = kGaryFontColor
        cell.userImgView.isHidden = true
        cell.desLab.isHidden = false
        cell.rightIconView.isHidden = true
        cell.nameLab.text = titleArray[indexPath.row]
        
        if indexPath.row == 0{
            cell.desLab.isHidden = true
            cell.userImgView.isHidden = false
            cell.userImgView.cornerRadius = 1
            cell.userImgView.kf.setImage(with: URL.init(string: infoArray[0]), placeholder: UIImage.init(named: "icon_qrcode_default"), options: nil, progressBlock: nil
            , completionHandler: nil)
        }else if indexPath.row == 1{
            cell.rightIconView.isHidden = false
            cell.desLab.text = infoArray[indexPath.row]
        }else if indexPath.row == 2{
            cell.desLab.text = infoArray[indexPath.row]
        }else if indexPath.row == 3{
            cell.desLab.text = infoArray[indexPath.row]
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
