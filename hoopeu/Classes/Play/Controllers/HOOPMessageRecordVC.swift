//
//  HOOPMessageRecordVC.swift
//  hoopeu
//  留言记录
//  Created by gouyz on 2019/3/27.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD

private let messageRecordCell = "messageRecordCell"

class HOOPMessageRecordVC: GYZBaseVC {
    
    var dataList: [HOOPLeaveMessageModel] = [HOOPLeaveMessageModel]()
    /// 留言类型 1我的留言2收到留言
    var messageType: String = "1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view)
            }else{
                make.top.equalTo(kTitleAndStateHeight)
            }
        }
        requestDataList()
    }
    lazy var tableView : UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = kWhiteColor
        
        table.register(GYZLabArrowCell.self, forCellReuseIdentifier: messageRecordCell)
        
        return table
    }()
    ///获取数据
    func requestDataList(){
        if !GYZTool.checkNetWork() {
            return
        }

        weak var weakSelf = self
        showLoadingView()

        let url = messageType == "1" ? "leavemsg/liston" : "leavemsg/listoff"
        GYZNetWork.requestNetwork(url,parameters: ["deviceId":userDefaults.string(forKey: "devId") ?? ""],method :.get,  success: { (response) in

            weakSelf?.hiddenLoadingView()
            GYZLog(response)

            if response["code"].intValue == kQuestSuccessTag{//请求成功

                guard let data = response["data"].array else { return }

                weakSelf?.dataList.removeAll()
                for item in data{
                    guard let itemInfo = item.dictionaryObject else { return }
                    let model = HOOPLeaveMessageModel.init(dict: itemInfo)

                    weakSelf?.dataList.append(model)
                }

                weakSelf?.tableView.reloadData()
                if weakSelf?.dataList.count > 0{
                    weakSelf?.hiddenEmptyView()
                }else{
                    ///显示空页面
                    weakSelf?.showEmptyView(content:"暂无留言")
                }

            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }

        }, failture: { (error) in

            weakSelf?.hiddenLoadingView()
            GYZLog(error)

            //第一次加载失败，显示加载错误页面
            weakSelf?.showEmptyView(content: "加载失败，请点击重新加载", reload: {
                weakSelf?.hiddenEmptyView()
                weakSelf?.requestDataList()
            })
        })
    }
    
    /// 详情
    func goDetailVC(msgId: String){
        if messageType == "1" {
            let vc = HOOPLeaveMessageVC()
            vc.isEdit = true
            vc.messageId = msgId
            vc.resultBlock = {[unowned self] (isRefresh) in
                if isRefresh{
                    self.requestDataList()
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = HOOPReceivedMessageDetailVC()
            vc.messageId = msgId
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension HOOPMessageRecordVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: messageRecordCell) as! GYZLabArrowCell
        
        cell.nameLab.text = dataList[indexPath.row].msg
        
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

        goDetailVC(msgId: dataList[indexPath.row].id!)
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
