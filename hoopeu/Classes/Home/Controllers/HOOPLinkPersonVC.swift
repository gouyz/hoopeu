//
//  HOOPLinkPersonVC.swift
//  hoopeu
//  联系人
//  Created by gouyz on 2019/6/5.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD

private let linkPersonCell = "linkPersonCell"

class HOOPLinkPersonVC: GYZBaseVC {

    var dataList: [HOOPLinkPersonModel] = [HOOPLinkPersonModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "联系人"
        
        let rightBtn = UIButton(type: .custom)
        rightBtn.setImage(UIImage(named: "icon_link_person_add")?.withRenderingMode(.alwaysOriginal), for: .normal)
        rightBtn.frame = CGRect.init(x: 0, y: 0, width: kTitleHeight, height: kTitleHeight)
        rightBtn.addTarget(self, action: #selector(onClickRightBtn), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBtn)
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        requestPersonDatas()
    }
    
    lazy var tableView : UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = kWhiteColor
        
        table.register(HOOPLinkPersonCell.self, forCellReuseIdentifier: linkPersonCell)
    
        
        return table
    }()
    ///获取报警日志数据
    func requestPersonDatas(){

        if !GYZTool.checkNetWork() {
            return
        }

        weak var weakSelf = self
        showLoadingView()

        GYZNetWork.requestNetwork("appContact",parameters: nil,method:.get,  success: { (response) in

            weakSelf?.hiddenLoadingView()
            GYZLog(response)

            if response["code"].intValue == kQuestSuccessTag{//请求成功

                weakSelf?.dataList.removeAll()
                guard let data = response["data"].array else { return }

                for item in data{
                    guard let itemInfo = item.dictionaryObject else { return }
                    let model = HOOPLinkPersonModel.init(dict: itemInfo)

                    weakSelf?.dataList.append(model)
                }
                weakSelf?.tableView.reloadData()
                if weakSelf?.dataList.count > 0{
                    weakSelf?.hiddenEmptyView()
                }else{
                    ///显示空页面
                    weakSelf?.showEmptyView(content: "暂无报警联系人信息")
                }

            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }

        }, failture: { (error) in

            weakSelf?.hiddenLoadingView()
            GYZLog(error)

            weakSelf?.showEmptyView(content: "加载失败，请点击重新加载", reload: {
                weakSelf?.requestPersonDatas()
                weakSelf?.hiddenEmptyView()
            })
        })
    }
    @objc func onClickRightBtn(){//添加联系人
        showAddPersonAlert()
    }
    /// 添加联系人
    func showAddPersonAlert(){
        let alert = HOOPAddLinkPersonVC.init()
        alert.action = {[weak self](name,phone) in
            self?.requestAddPerson(name: name, phone: phone)
        }
        alert.show()
    }
    /// 删除
    func deleteDevice(indexRow: Int){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "确定要删除此联系人吗?", cancleTitle: "取消", viewController: self, buttonTitles: "确定") { (index) in
            
            if index != cancelIndex{
                weakSelf?.requestDelPerson(indexRow: indexRow)
            }
        }
    }
    
    ///删除联系人
    func requestDelPerson(indexRow: Int){
        
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("appContact/del",parameters: ["id":dataList[indexRow].id!],method:.get,  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                weakSelf?.dataList.remove(at: indexRow)
                weakSelf?.tableView.reloadData()
                if weakSelf?.dataList.count > 0{
                    weakSelf?.hiddenEmptyView()
                }else{
                    ///显示空页面
                    weakSelf?.showEmptyView(content: "暂无报警联系人信息")
                }
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    ///添加联系人
    func requestAddPerson(name: String,phone: String){
        
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("appContact/add",parameters: ["name":name,"phone":phone],  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                weakSelf?.requestPersonDatas()
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
}

extension HOOPLinkPersonVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: linkPersonCell) as! HOOPLinkPersonCell
        cell.dataModel = dataList[indexPath.row]
        
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
    
    /// 实现左滑
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "删除") { [weak self] (action, index) in
            self?.deleteDevice(indexRow: index.row)
        }
        deleteAction.backgroundColor = kRedFontColor
        
        return [deleteAction]
    }
}
