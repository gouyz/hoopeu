//
//  HOOPLogDetailVC.swift
//  hoopeu
//  报警日志详情
//  Created by gouyz on 2019/2/26.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import SKPhotoBrowser

private let warnLogDetailCell = "warnLogDetailCell"

class HOOPLogDetailVC: GYZBaseVC {
    var logId: String = ""
    var dataModel: HOOPGuardModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "报警日志详情"
        
        setUpUI()
        requestGuardList()
    }
    
    func setUpUI(){
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        
        /// cell 的width要小于屏幕宽度的一半，才能一行显示2个以上的Item
        let itemH = (kScreenWidth - klineWidth)/2.0
        //设置cell的大小
        layout.itemSize = CGSize(width: itemH, height: (kScreenWidth * 0.5 - kMargin * 2) * 0.5 + kTitleHeight)
        //每个Item之间最小的间距
        layout.minimumInteritemSpacing = klineWidth
        //每行之间最小的间距
        layout.minimumLineSpacing = klineWidth
        
        let collView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collView.dataSource = self
        collView.delegate = self
        collView.backgroundColor = kBackgroundColor
        
        collView.register(HOOPLogDetailCell.self, forCellWithReuseIdentifier: warnLogDetailCell)
        
        
        return collView
    }()
    
    ///获取报警日志详情数据
    func requestGuardList(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        showLoadingView()
        
        GYZNetWork.requestNetwork("homeCtrl/alarm",parameters: ["id": logId],  success: { (response) in
            
            weakSelf?.hiddenLoadingView()
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let data = response["data"].dictionaryObject else { return }
                
                weakSelf?.dataModel = HOOPGuardModel.init(dict: data)
                
                weakSelf?.collectionView.reloadData()
                if weakSelf?.dataModel?.urlList.count > 0{
                    weakSelf?.hiddenEmptyView()
                }else{
                    ///显示空页面
                    weakSelf?.showEmptyView(content:"暂无日志")
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
                weakSelf?.requestGuardList()
            })
        })
    }
    /// 查看图片
    ///
    /// - Parameters:
    ///   - index: 索引
    ///   - urls: 图片路径
    func goBigPhotos(index: Int, urls: [String]){
        let browser = SKPhotoBrowser(photos: GYZTool.createWebPhotos(urls: urls))
        browser.initializePageIndex(index)
        //        browser.delegate = self
        
        present(browser, animated: true, completion: nil)
    }
}
extension HOOPLogDetailVC: UICollectionViewDataSource,UICollectionViewDelegate{
    // MARK: UICollectionViewDataSource 代理方法
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if dataModel != nil {
            return (dataModel?.urlList.count)!
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: warnLogDetailCell, for: indexPath) as! HOOPLogDetailCell
        
        cell.nameLab.text = dataModel?.time
        cell.iconView.kf.setImage(with: URL.init(string: (dataModel?.urlList[indexPath.row])!), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        goBigPhotos(index: indexPath.row, urls: (dataModel?.urlList)!)
    }
}
