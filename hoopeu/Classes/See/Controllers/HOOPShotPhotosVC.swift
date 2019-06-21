//
//  HOOPShotPhotosVC.swift
//  hoopeu
//  截图图库
//  Created by gouyz on 2019/6/20.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import SKPhotoBrowser

private let shotPhotosCell = "shotPhotosCell"

class HOOPShotPhotosVC: GYZBaseVC {
    var dataList: [HOOPShotsModel] = [HOOPShotsModel]()
    var urlList: [String] = [String]()
    var currPage: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "图库"
        
        setUpUI()
        requestShotList()
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
        
        collView.register(HOOPLogDetailCell.self, forCellWithReuseIdentifier: shotPhotosCell)
        
        weak var weakSelf = self
        ///添加下拉刷新
        GYZTool.addPullRefresh(scorllView: collView, pullRefreshCallBack: {
            weakSelf?.refresh()
        })
        ///添加上拉加载更多
        GYZTool.addLoadMore(scorllView: collView, loadMoreCallBack: {
            weakSelf?.loadMore()
        })
        
        
        return collView
    }()
    
    ///获取图库数据
    func requestShotList(){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        showLoadingView()
        
        GYZNetWork.requestNetwork("gallery",parameters: ["page":currPage,"limit":20,"deviceId":userDefaults.string(forKey: "devId") ?? ""],method :.get , success: { (response) in
            
            weakSelf?.hiddenLoadingView()
            weakSelf?.closeRefresh()
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let data = response["data"].array else { return }
                for item in data{
                    guard let itemInfo = item.dictionaryObject else { return }
                    let model = HOOPShotsModel.init(dict: itemInfo)
                    
                    weakSelf?.dataList.append(model)
                    weakSelf?.urlList.append(model.url!)
                }
                weakSelf?.collectionView.reloadData()
                if weakSelf?.dataList.count > 0{
                    weakSelf?.hiddenEmptyView()
                }else{
                    ///显示空页面
                    weakSelf?.showEmptyView(content: "暂无截图信息")
                }
                
            }else{
                MBProgressHUD.showAutoDismissHUD(message: response["msg"].stringValue)
            }
            
        }, failture: { (error) in
            
            weakSelf?.hiddenLoadingView()
            weakSelf?.closeRefresh()
            GYZLog(error)
            
            if weakSelf?.currPage == 1{//第一次加载失败，显示加载错误页面
                weakSelf?.showEmptyView(content: "加载失败，请点击重新加载", reload: {
                    weakSelf?.refresh()
                    weakSelf?.hiddenEmptyView()
                })
            }
        })
    }
    // MARK: - 上拉加载更多/下拉刷新
    /// 下拉刷新
    func refresh(){
        currPage = 1
        requestShotList()
    }
    
    /// 上拉加载更多
    func loadMore(){
        currPage += 1
        requestShotList()
    }
    
    /// 关闭上拉/下拉刷新
    func closeRefresh(){
        if collectionView.mj_header.isRefreshing{//下拉刷新
            dataList.removeAll()
            urlList.removeAll()
            GYZTool.endRefresh(scorllView: collectionView)
        }else if collectionView.mj_footer.isRefreshing{//上拉加载更多
            GYZTool.endLoadMore(scorllView: collectionView)
        }
    }
    /// 查看图片
    ///
    /// - Parameters:
    ///   - index: 索引
    ///   - urls: 图片路径
    func goBigPhotos(index: Int){
        let browser = SKPhotoBrowser(photos: GYZTool.createWebPhotos(urls: urlList))
        browser.initializePageIndex(index)
        //        browser.delegate = self
        
        present(browser, animated: true, completion: nil)
    }
}
extension HOOPShotPhotosVC: UICollectionViewDataSource,UICollectionViewDelegate{
    // MARK: UICollectionViewDataSource 代理方法
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return dataList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: shotPhotosCell, for: indexPath) as! HOOPLogDetailCell
        
        let model = dataList[indexPath.row]
        cell.nameLab.text = model.createTime?.subString(start: 0, length: (model.createTime?.count)! - 3).getDateTime(format: "yyyy-MM-dd HH:mm:ss")
        cell.iconView.kf.setImage(with: URL.init(string: model.url!), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        goBigPhotos(index: indexPath.row)
    }
}
