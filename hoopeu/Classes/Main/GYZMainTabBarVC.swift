//
//  GYZMainTabBarVC.swift
//  baking
//  底部导航控制器
//  Created by gouyz on 2017/3/23.
//  Copyright © 2017年 gouyz. All rights reserved.
//

import UIKit

class GYZMainTabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
    }
    
    func setUp(){
        tabBar.tintColor = kBlueFontColor
        /// 解决iOS12.1 子页面返回时底部tabbar出现了错位
        tabBar.isTranslucent = false
        
        addViewController(HOOPHomeVC(), title: "智慧家居", normalImgName: "icon_tabbar_home")
        addViewController(HOOPPlayVC(), title: "玩转叮当", normalImgName: "icon_tabbar_play")
        addViewController(HOOPSeeVC(), title: "爱心看护", normalImgName: "icon_tabbar_see")
        
    }
    override var shouldAutorotate: Bool{
        return self.selectedViewController?.shouldAutorotate ?? false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 添加子控件
    fileprivate func addViewController(_ childController: UIViewController, title: String,normalImgName: String) {
        let nav = GYZBaseNavigationVC.init(rootViewController: childController)
        addChild(nav)
        childController.tabBarItem.title = title

        // 设置 tabbarItem 选中状态的图片(不被系统默认渲染,显示图像原始颜色)
        childController.tabBarItem.image = UIImage(named: normalImgName)?.withRenderingMode(.alwaysOriginal)
        childController.tabBarItem.selectedImage = UIImage(named: normalImgName + "_selected")?.withRenderingMode(.alwaysOriginal)
    }
}

