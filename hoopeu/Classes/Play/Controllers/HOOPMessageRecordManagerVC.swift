//
//  HOOPMessageRecordManagerVC.swift
//  hoopeu
//
//  Created by gouyz on 2019/3/27.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPMessageRecordManagerVC: GYZBaseVC ,ContentViewDelegate {
    var titleArr : [String] = ["我的留言","收到留言"]
    
    var stateValue : [String] = ["1","2"]
    var scrollPageView: ScrollSegmentView?
    var contentView: ContentView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setScrollView()
    }
    ///设置控制器
    func setChildVcs() -> [UIViewController] {
        
        var childVC : [HOOPMessageRecordVC] = []
        for index in 0 ..< titleArr.count{
            
            let vc = HOOPMessageRecordVC()
            vc.messageType = stateValue[index]
            childVC.append(vc)
        }
        
        return childVC
    }
    
    /// 设置scrollView
    func setScrollView(){
        // 这个是必要的设置
        automaticallyAdjustsScrollViewInsets = false
        
        var style = SegmentStyle()
        // 是否显示遮盖
        style.showCover = true
        style.scrollTitle = false
        // 颜色渐变
        style.gradualChangeTitleColor = true
        // 遮盖颜色
        style.coverBackgroundColor = kWhiteColor
        // title选中状态颜色 使用RGB空间值
        style.selectedTitleColor = kBlueFontColor
        // title正常状态颜色 使用RGB空间值
        style.normalTitleColor = kBlackFontColor
        /// 显示角标
        style.showBadge = false
        
        scrollPageView = ScrollSegmentView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth * 0.6, height: 28), segmentStyle: style, titles: titleArr)
        navigationItem.titleView = scrollPageView
        
        contentView = ContentView.init(frame: self.view.bounds, childVcs: setChildVcs(), parentViewController: self)
        contentView?.delegate = self // 必须实现代理方法
        
        scrollPageView?.titleBtnOnClick = {[unowned self] (label: UILabel, index: Int) in
            self.contentView?.setContentOffSet(CGPoint(x: (self.contentView?.bounds.size.width)! * CGFloat(index), y: 0), animated: false)
            
        }
        
        view.addSubview(contentView!)
    }
    
    /// MARK: ContentViewDelegate
    var segmentView: ScrollSegmentView{
        return scrollPageView!
    }
}
