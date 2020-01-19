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
    /// 留言类型 1：app留言 2：设备留言 3: 收到的留言
    var messageType: String = "1"
    let recorderManager = RecordManager()
    
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
        
        table.register(HOOPLeaveMessageRecordCell.self, forCellReuseIdentifier: messageRecordCell)
        
        return table
    }()
    ///获取数据
    func requestDataList(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        showLoadingView()
        
        let url = messageType == "3" ? "leavemsg/listoff" : "leavemsg/liston"
        var paramDic:[String : Any] = ["deviceId":userDefaults.string(forKey: "devId") ?? ""]
        if messageType != "3" {
            paramDic["type"] = messageType
        }
        GYZNetWork.requestNetwork(url,parameters: paramDic,method :.get,  success: { (response) in
            
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
    func goDetailVC(model: HOOPLeaveMessageModel){
        if messageType != "3" {
            let vc = HOOPLeaveMessageVC()
            vc.isEdit = true
            vc.messageId = model.id!
            vc.resultBlock = {[unowned self] (isRefresh) in
                if isRefresh{
                    self.requestDataList()
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = HOOPReceivedMessageDetailVC()
            vc.dataModel = model
            vc.resultBlock = {[unowned self] (isRefresh) in
                if isRefresh{
                    self.requestDataList()
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    /// 播放语音留言
    @objc func onClickedPlay(sender: UIButton){
        let tag = sender.tag
        let model = dataList[tag]
        downLoadVoice(name: model.leavemsgName!)
    }
    func downLoadVoice(name:String){
        weak var weakSelf = self
        createHUD(message: "加载中...")
        GYZNetWork.downLoadRequest("http://119.29.107.14:8080/robot_filter-web/voiceMessage/download.html", parameters: ["boardId":userDefaults.string(forKey: "devId") ?? "","fileName":name], method: .post, success: { (response) in
            //            sleep(1)
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            weakSelf?.playDownLoadVoice(name:name)
        }) { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        }
    }
    
    func playDownLoadVoice(name:String){
        
        recorderManager.recordName = name
        recorderManager.convertAmrToWav()
        recorderManager.playWav()
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: messageRecordCell) as! HOOPLeaveMessageRecordCell
        
        cell.playBtn.tag = indexPath.row
        cell.playBtn.addTarget(self, action: #selector(onClickedPlay(sender:)), for: .touchUpInside)
        let model = dataList[indexPath.row]
        if messageType == "3" {// 收到的留言
            if model.msgName!.isEmpty {
                cell.playBtn.isHidden = true
                cell.nameLab.text = model.tts
            }else{
                cell.nameLab.text = model.createTime
                cell.playBtn.isHidden = false
            }
        }else{
            if model.leavemsgName!.isEmpty {
                cell.playBtn.isHidden = true
                cell.nameLab.text = model.msg
            }else{
                cell.nameLab.text = model.createTime
                cell.playBtn.isHidden = false
            }
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
        goDetailVC(model: dataList[indexPath.row])
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
