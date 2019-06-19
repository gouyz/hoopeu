//
//  HOOPRegisterSuccessVC.swift
//  hoopeu
//  注册成功
//  Created by gouyz on 2019/2/19.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPRegisterSuccessVC: GYZBaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = kWhiteColor
        
        view.addSubview(desLab)
        view.addSubview(desLab1)
        
        desLab.snp.makeConstraints { (make) in
            make.top.equalTo(kTitleAndStateHeight * 3)
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.height.equalTo(kTitleHeight)
        }
        desLab1.snp.makeConstraints { (make) in
            make.left.right.equalTo(desLab)
            make.top.equalTo(desLab.snp.bottom)
            make.height.equalTo(30)
        }
        
        /// 隐藏返回键
        self.navigationItem.leftBarButtonItem = nil
        startSMSWithDuration(duration: 3)
    }
    
    ///
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.textColor = kBlackFontColor
        lab.font = k18Font
        lab.textAlignment = .center
        lab.text = "注册成功！"
        
        return lab
    }()
    lazy var desLab1 : UILabel = {
        let lab = UILabel()
        lab.textColor = kBlueFontColor
        lab.font = k15Font
        lab.textAlignment = .center
        
        return lab
    }()
    
    /// 倒计时
    ///
    /// - Parameter duration: 倒计时时间
    func startSMSWithDuration(duration:Int){
        var times = duration
        
        let timer:DispatchSourceTimer = DispatchSource.makeTimerSource(flags: [], queue:DispatchQueue.global())
        
        timer.setEventHandler {
            if times > 0{
                DispatchQueue.main.async(execute: {
                    self.desLab1.text = "\(times)S"
                    times -= 1
                })
            } else{
                DispatchQueue.main.async(execute: {
                    self.goLinkPower()
                    timer.cancel()
                })
            }
        }
        
        // timer.scheduleOneshot(deadline: .now())
        timer.schedule(deadline: .now(), repeating: .seconds(1), leeway: .milliseconds(100))
        
        timer.resume()
        
        // 在调用DispatchSourceTimer时, 无论设置timer.scheduleOneshot, 还是timer.scheduleRepeating代码 不调用cancel(), 系统会自动调用
        // 另外需要设置全局变量引用, 否则不会调用事件
    }
    /// 连接电源
    func goLinkPower(){
        let vc = HOOPLinkPowerVC()
        navigationController?.pushViewController(vc, animated: true)
    }
}
