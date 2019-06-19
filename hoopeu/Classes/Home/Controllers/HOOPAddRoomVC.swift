//
//  HOOPAddRoomVC.swift
//  hoopeu
//  添加房间
//  Created by gouyz on 2019/2/22.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CocoaMQTT
import SwiftyJSON

private let addRoomCell = "addRoomCell"

class HOOPAddRoomVC: GYZBaseVC {
    
    var dataList: [HOOPRoomModel] = [HOOPRoomModel]()
    
    var selectedIndex: Int = -1
    /// 选择结果回调
    var resultBlock:(() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "添加房间"
        
        setUpUI()
        requestRoomList()
        mqttSetting()
    }
    
    func setUpUI(){
        view.addSubview(roomTxtFiled)
        view.addSubview(collectionView)
        view.addSubview(saveBtn)
        
        roomTxtFiled.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(kTitleAndStateHeight + kMargin)
            make.height.equalTo(60)
        }
        collectionView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(roomTxtFiled.snp.bottom).offset(kMargin)
            make.bottom.equalTo(saveBtn.snp.top).offset(-kMargin)
        }
        saveBtn.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(kBottomTabbarHeight)
        }
    }
    
    /// 选择房间
    lazy var roomTxtFiled : UITextField = {
        
        let textFiled = UITextField()
        textFiled.backgroundColor = kWhiteColor
        textFiled.font = k15Font
        textFiled.textColor = kBlackFontColor
        textFiled.textAlignment = .center
        textFiled.placeholder = "请选择房间"
        textFiled.isEnabled = false
        
        return textFiled
    }()
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        
        /// cell 的width要小于屏幕宽度的一半，才能一行显示2个以上的Item
        let itemH = (kScreenWidth - klineWidth * 2)/3.0
        //设置cell的大小
        layout.itemSize = CGSize(width: itemH, height: itemH)
        
        //每个Item之间最小的间距
        layout.minimumInteritemSpacing = klineWidth
        //每行之间最小的间距
        layout.minimumLineSpacing = klineWidth
        
        let collView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collView.dataSource = self
        collView.delegate = self
        collView.backgroundColor = kBackgroundColor
        
        collView.register(HOOPAddRoomCell.self, forCellWithReuseIdentifier: addRoomCell)
        
        
        return collView
    }()
    
    /// 保存按钮
    lazy var saveBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBlueFontColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("保存", for: .normal)
        btn.titleLabel?.font = k15Font
        
        btn.addTarget(self, action: #selector(clickedSaveBtn), for: .touchUpInside)
        
        return btn
    }()
    
    /// 保存
    @objc func clickedSaveBtn(){
        if selectedIndex == -1 {
            MBProgressHUD.showAutoDismissHUD(message: "请选择房间")
            return
        }
        
        createHUD(message: "加载中...")
        let paramDic:[String:Any] = ["token":userDefaults.string(forKey: "token") ?? "","msg_type":"app_room_add","phone":userDefaults.string(forKey: "phone") ?? "","room_id":Int.init(dataList[selectedIndex].id!)!,"room_name":dataList[selectedIndex].roomName!,"app_interface_tag":""]
        
        mqtt?.publish("api_send", withString: GYZTool.getJSONStringFromDictionary(dictionary: paramDic), qos: .qos1)
    }
    
    /// 选择房间
    @objc func onClickedSelectRoom(sender:UIButton){
        let tag = sender.tag
        selectedIndex = tag
        roomTxtFiled.text = dataList[selectedIndex].roomName
        self.collectionView.reloadData()
    }
    
    ///获取房间数据
    func requestRoomList(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        showLoadingView()
        
        GYZNetWork.requestNetwork("room/list",parameters: nil,method :.get,  success: { (response) in
            
            weakSelf?.hiddenLoadingView()
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let data = response["data"].array else { return }
                
                weakSelf?.dataList.removeAll()
                for item in data{
                    guard let itemInfo = item.dictionaryObject else { return }
                    let model = HOOPRoomModel.init(dict: itemInfo)
                    
                    weakSelf?.dataList.append(model)
                }
                if weakSelf?.dataList.count > 0{
                    weakSelf?.hiddenEmptyView()
                    weakSelf?.collectionView.reloadData()
                }else{
                    ///显示空页面
                    weakSelf?.showEmptyView(content:"暂无房间")
                    weakSelf?.view.bringSubviewToFront((weakSelf?.saveBtn)!)
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
                weakSelf?.requestRoomList()
            })
            weakSelf?.view.bringSubviewToFront((weakSelf?.saveBtn)!)
        })
    }
    /// 重载CocoaMQTTDelegate
    override func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        super.mqtt(mqtt, didConnectAck: ack)
        if ack == .accept {
            mqtt.subscribe("api_receive", qos: CocoaMQTTQOS.qos1)
            
        }
    }
    override func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        super.mqtt(mqtt, didReceiveMessage: message, id: id)
        
        if let data = message.string {
            let result = JSON.init(parseJSON: data)
            let phone = result["phone"].stringValue
            let type = result["msg_type"].stringValue
            if let tag = result["app_interface_tag"].string{
                if tag.hasPrefix("system_"){
                    return
                }
            }
            
            if type == "app_room_add_re" && phone == userDefaults.string(forKey: "phone"){
                self.hud?.hide(animated: true)
                if result["code"].intValue == kQuestSuccessTag{
                    if resultBlock != nil {
                        resultBlock!()
                    }
                    clickedBackBtn()
                }else{
                    MBProgressHUD.showAutoDismissHUD(message: result["msg"].stringValue)
                }
            }
            
        }
    }
}
extension HOOPAddRoomVC: UICollectionViewDataSource,UICollectionViewDelegate{
    // MARK: UICollectionViewDataSource 代理方法
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: addRoomCell, for: indexPath) as! HOOPAddRoomCell
        
        let model = dataList[indexPath.row]
        cell.roomBtn.setTitle(model.roomName, for: .normal)
        
        if model.status == "0" {// 未添加
            cell.roomBtn.isEnabled = true
            if indexPath.row == selectedIndex{
                cell.roomBtn.isSelected = true
            }else{
                cell.roomBtn.isSelected = false
            }
            
        }else{
            cell.roomBtn.isEnabled = false
        }
        
        cell.roomBtn.tag = indexPath.row
        cell.roomBtn.addTarget(self, action: #selector(onClickedSelectRoom(sender:)), for: .touchUpInside)
        
        return cell
    }
}

