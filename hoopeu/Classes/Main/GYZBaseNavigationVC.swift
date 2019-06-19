//
//  GYZBaseNavigationVC.swift
//  flowers
//  导航控制器
//  Created by gouyz on 2016/11/5.
//  Copyright © 2016年 gouyz. All rights reserved.
//

import UIKit

class GYZBaseNavigationVC: UINavigationController ,UIGestureRecognizerDelegate {
    
    //MARK: - life cycle
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        _init()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        _init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - private func
    private func _init() {
        /// 设置导航栏标题
        let navBar = UINavigationBar.appearance()
        navBar.tintColor = kBlackColor
        navBar.barTintColor = kNavBarColor
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: kBlackColor, NSAttributedString.Key.font: k18Font]

        // 右滑返回代理
        self.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count > 0 {
            // push的时候, 隐藏tabbar
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: true)
    }
    
    
    // MARK: 代理：UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.children.count > 1
    }
    override var shouldAutorotate: Bool{
        return self.topViewController?.shouldAutorotate ?? false
    }
}
