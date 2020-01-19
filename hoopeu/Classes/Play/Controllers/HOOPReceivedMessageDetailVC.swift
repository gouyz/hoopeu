//
//  HOOPReceivedMessageDetailVC.swift
//  hoopeu
//  收到留言 详情
//  Created by gouyz on 2019/3/27.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import CocoaMQTT
import MBProgressHUD
import SwiftyJSON

class HOOPReceivedMessageDetailVC: GYZBaseVC {
    /// 选择结果回调
    var resultBlock:((_ isRefresh: Bool) -> Void)?
    /// 留言id
    var messageId: String = ""
    
    var dataModel: HOOPLeaveMessageModel?
    let recorderManager = RecordManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "收到留言"
        self.view.backgroundColor = kWhiteColor
        
        let rightBtn = UIButton(type: .custom)
        rightBtn.setTitle("删除", for: .normal)
        rightBtn.titleLabel?.font = k15Font
        rightBtn.setTitleColor(kRedFontColor, for: .normal)
        rightBtn.frame = CGRect.init(x: 0, y: 0, width: kTitleHeight, height: kTitleHeight)
        rightBtn.addTarget(self, action: #selector(onClickRightBtn), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBtn)
        
        setUpUI()
    }
    
    func setUpUI(){
        view.addSubview(desLab)
        view.addSubview(playBtn)
        
        desLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.top.equalTo(kTitleAndStateHeight + 20)
            make.size.equalTo(CGSize.init(width: kTitleHeight, height: 20))
        }
        playBtn.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.top.equalTo(desLab.snp.bottom).offset(kMargin)
            make.height.equalTo(kUIButtonHeight)
        }
    }
    
    /// 说明
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlueFontColor
        lab.text = "留言"
        lab.textAlignment = .center
        lab.borderColor = kBlueFontColor
        lab.borderWidth = klineWidth
        lab.cornerRadius = kCornerRadius
        
        return lab
    }()
    
    /// 播放
    lazy var playBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBtnClickBGColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("点击播放", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = kCornerRadius
        
        btn.addTarget(self, action: #selector(playRecordVoice) , for: .touchUpInside)
        
        
        return btn
    }()
    /// 删除留言信息
    func requestDelMessageInfo(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        createHUD(message: "加载中...")
        
        GYZNetWork.requestNetwork("leavemsg/delLeavemsgReceiveId", parameters: ["id":messageId],method : .get,  success: { (response) in
            
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                if weakSelf?.resultBlock != nil{
                    weakSelf?.resultBlock!(true)
                }
                weakSelf?.clickedBackBtn()
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        })
    }
    /// 播放录音
    @objc func playRecordVoice(){
        recorderManager.recordName = dataModel?.msgName
        downLoadVoice()
    }
    func downLoadVoice(){
        weak var weakSelf = self
        createHUD(message: "加载中...")
        GYZNetWork.downLoadRequest("http://119.29.107.14:8080/robot_filter-web/voiceMessage/download.html", parameters: ["boardId":userDefaults.string(forKey: "devId") ?? "","fileName":recorderManager.recordName!], method: .post, success: { (response) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(response)
            weakSelf?.playDownLoadVoice()
        }) { (error) in
            weakSelf?.hud?.hide(animated: true)
            GYZLog(error)
        }
    }
    
    func playDownLoadVoice(){
        recorderManager.convertAmrToWav()
        recorderManager.playWav()
    }
    /// 删除
    @objc func onClickRightBtn(){
        weak var weakSelf = self
        GYZAlertViewTools.alertViewTools.showAlert(title: nil, message: "确定要删除此留言吗?", cancleTitle: "取消", viewController: self, buttonTitles: "确定") { (index) in
            
            if index != cancelIndex{
                weakSelf?.requestDelMessageInfo()
            }
        }
    }
    
}
