//
//  HOOPRepairVC.swift
//  hoopeu
//  注册保修
//  Created by gouyz on 2019/9/24.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD

class HOOPRepairVC: GYZBaseVC {
    
    var ageList: [HOOPParamModel] = [HOOPParamModel]()
    var workList: [HOOPParamModel] = [HOOPParamModel]()
    var areaList: [HOOPParamModel] = [HOOPParamModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBarBgAlpha = 0
        automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = kWhiteColor
        
        setUpUI()
    }
    
    /// 创建UI
    func setUpUI(){
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(desLab)
        contentView.addSubview(ageView)
        contentView.addSubview(sexView)
        contentView.addSubview(workView)
        contentView.addSubview(areaView)
        contentView.addSubview(okBtn)
        contentView.addSubview(tipsLabel)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        contentView.snp.makeConstraints { (make) in
            make.left.width.equalTo(scrollView)
            make.top.equalTo(scrollView)
            make.bottom.equalTo(scrollView)
            // 这个很重要！！！！！！
            // 必须要比scroll的高度大一，这样才能在scroll没有填充满的时候，保持可以拖动
            make.height.greaterThanOrEqualTo(scrollView).offset(1)
        }
        desLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.top.equalTo(kTitleAndStateHeight + 30)
            make.height.equalTo(kTitleHeight)
        }
        ageView.snp.makeConstraints { (make) in
            make.top.equalTo(desLab.snp.bottom).offset(kTitleHeight)
            make.left.right.equalTo(contentView)
            make.height.equalTo(50)
        }
        sexView.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(ageView)
            make.top.equalTo(ageView.snp.bottom)
        }
        workView.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(ageView)
            make.top.equalTo(sexView.snp.bottom)
        }
        areaView.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(ageView)
            make.top.equalTo(workView.snp.bottom)
        }
        okBtn.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(kTitleHeight)
            make.top.equalTo(areaView.snp.bottom).offset(kTitleAndStateHeight)
        }
        
        tipsLabel.snp.makeConstraints { (make) in
            make.right.equalTo(okBtn)
            make.top.equalTo(okBtn.snp.bottom)
            make.width.equalTo(60)
            make.height.equalTo(30)
            // 这个很重要，viewContainer中的最后一个控件一定要约束到bottom，并且要小于等于viewContainer的bottom
            // 否则的话，上面的控件会被强制拉伸变形
            // 最后的-10是边距，这个可以随意设置
            make.bottom.lessThanOrEqualTo(contentView).offset(-kMargin)
        }
        
    }
    /// scrollView
    var scrollView: UIScrollView = UIScrollView()
    /// 内容View
    var contentView: UIView = UIView()
    ///
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.textColor = kBlackFontColor
        lab.font = k18Font
        lab.textAlignment = .center
        lab.text = "”注册保修“"
        
        return lab
    }()
    
    /// 选择年龄
    lazy var ageView: GYZCommonInfoView = {
        let selectView = GYZCommonInfoView()
        selectView.desLab.text = "使用者年龄"
        selectView.tag = 101
        selectView.addOnClickListener(target: self, action: #selector(onClickedOperator(sender:)))
        
        return selectView
    }()
    /// 选择性别
    lazy var sexView: GYZCommonInfoView = {
        let selectView = GYZCommonInfoView()
        selectView.desLab.text = "性别"
        selectView.tag = 102
        selectView.addOnClickListener(target: self, action: #selector(onClickedOperator(sender:)))
        
        return selectView
    }()
    /// 选择行业
    lazy var workView: GYZCommonInfoView = {
        let selectView = GYZCommonInfoView()
        selectView.desLab.text = "行业"
        selectView.tag = 103
        selectView.addOnClickListener(target: self, action: #selector(onClickedOperator(sender:)))
        
        return selectView
    }()
    /// 选择区域
    lazy var areaView: GYZCommonInfoView = {
        let selectView = GYZCommonInfoView()
        selectView.desLab.text = "区域"
        selectView.tag = 104
        selectView.addOnClickListener(target: self, action: #selector(onClickedOperator(sender:)))
        
        return selectView
    }()
    /// 确定
    lazy var okBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBlueFontColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("确定", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = 8
        
        btn.addTarget(self, action: #selector(clickedOkBtn), for: .touchUpInside)
        
        return btn
    }()
    lazy var tipsLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = kHeightGaryFontColor
        lab.font = k13Font
        lab.textAlignment = .right
        lab.text = "跳过"
        lab.addOnClickListener(target: self, action: #selector(onClickedTips))
        
        return lab
    }()
    ///获取年龄数据
    func requestDataList(method: String){
        if !GYZTool.checkNetWork() {
            return
        }
        
        weak var weakSelf = self
        
        GYZNetWork.requestNetwork(method,parameters: nil,  success: { (response) in
            
            GYZLog(response)
            
            if response["code"].intValue == kQuestSuccessTag{//请求成功
                
                guard let data = response["data"].array else { return }
                
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
    
    /// 确定
    @objc func clickedOkBtn(){
        
    }
    /// 跳过
    @objc func onClickedTips(){

    }
    
    @objc func onClickedOperator(sender:UITapGestureRecognizer){
        
    }
}
