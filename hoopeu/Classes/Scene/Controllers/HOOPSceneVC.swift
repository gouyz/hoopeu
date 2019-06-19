//
//  HOOPSceneVC.swift
//  hoopeu
//  智能场景
//  Created by gouyz on 2019/2/22.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD

private let sceneCell = "sceneCell"

class HOOPSceneVC: GYZBaseVC {
    
    var dataList: [HOOPSceneModel] = [HOOPSceneModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "智能场景"
        
        setUpUI()
    
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestSceneList()
    }
    
    func setUpUI(){
        view.addSubview(collectionView)
        view.addSubview(addBtn)
        
        collectionView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(view)
            make.bottom.equalTo(addBtn.snp.top)
//            if #available(iOS 11.0, *) {
//                make.top.equalTo(view)
//            }else{
//                make.top.equalTo(kTitleAndStateHeight)
//            }
        }
        addBtn.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(kBottomTabbarHeight)
        }
    }
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        
        /// cell 的width要小于屏幕宽度的一半，才能一行显示2个以上的Item
        let itemH = kSceneCellWidthDefault - kMargin + 30
        //设置cell的大小
        layout.itemSize = CGSize(width: kSceneCellWidthDefault, height: itemH)
        
        //每个Item之间最小的间距
        layout.minimumInteritemSpacing = klineWidth
        //每行之间最小的间距
        layout.minimumLineSpacing = klineWidth
        
        let collView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collView.dataSource = self
        collView.delegate = self
        collView.backgroundColor = kBackgroundColor
        
        collView.register(HOOPSceneCell.self, forCellWithReuseIdentifier: sceneCell)
        
        
        return collView
    }()
    
    /// 新增按钮
    lazy var addBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kWhiteColor
        btn.setTitleColor(kBlueFontColor, for: .normal)
        btn.setTitle("新建场景", for: .normal)
        btn.titleLabel?.font = k15Font
        
        btn.addTarget(self, action: #selector(clickedAddBtn), for: .touchUpInside)
        
        return btn
    }()
    
    /// 新建场景
    @objc func clickedAddBtn(){
        
        GYZAlertViewTools.alertViewTools.showSheet(title: nil, message: nil, cancleTitle: "取消", titleArray: ["条件场景","语音场景"], viewController: self) { [weak self](index) in
            
            if index == 0{//条件场景
                self?.goConditionSceneVC(sceneId:"")
            }else if index == 1{//语音场景
                self?.goVoiceSceneVC(sceneId:"")
            }
        }
    }
    ///获取场景数据
    func requestSceneList(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        showLoadingView()
        
        GYZNetWork.requestNetwork("scene/list",parameters: nil,method :.get,  success: { (response) in
            
            weakSelf?.hiddenLoadingView()
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let data = response["data"].array else { return }
                
                weakSelf?.dataList.removeAll()
                for item in data{
                    guard let itemInfo = item.dictionaryObject else { return }
                    let model = HOOPSceneModel.init(dict: itemInfo)
                    
                    weakSelf?.dataList.append(model)
                }
                weakSelf?.collectionView.reloadData()
                if weakSelf?.dataList.count > 0{
                    weakSelf?.hiddenEmptyView()
                }else{
                    ///显示空页面
                    weakSelf?.showEmptyView(content:"暂无场景")
                    weakSelf?.view.bringSubviewToFront((weakSelf?.addBtn)!)
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
                weakSelf?.requestSceneList()
            })
            weakSelf?.view.bringSubviewToFront((weakSelf?.addBtn)!)
        })
    }
    /// 语音场景
    func goVoiceSceneVC(sceneId: String){
        let vc = HOOPAddVoiceSceneVC()
        if sceneId != "" {// 编辑
            vc.resultBlock = {[weak self]() in
                self?.requestSceneList()
            }
            vc.isEdit = true
            vc.sceneId = sceneId
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 条件场景
    func goConditionSceneVC(sceneId: String){
        let vc = HOOPAddConditionSceneVC()
        if sceneId != "" {// 编辑
            vc.resultBlock = {[weak self]() in
                self?.requestSceneList()
            }
            vc.isEdit = true
            vc.sceneId = sceneId
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension HOOPSceneVC: UICollectionViewDataSource,UICollectionViewDelegate{
    // MARK: UICollectionViewDataSource 代理方法
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sceneCell, for: indexPath) as! HOOPSceneCell
        
        cell.nameLab.text = dataList[indexPath.row].name
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let model = dataList[indexPath.row]
        if model.type == "2" {//语音场景
            goVoiceSceneVC(sceneId: model.id!)
        }else{//条件场景
            goConditionSceneVC(sceneId: model.id!)
        }
    }
}
