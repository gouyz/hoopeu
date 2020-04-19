//
//  HOOPPhoneNetWorkVC.swift
//  hoopeu
//  手机配网
//  Created by gouyz on 2020/4/19.
//  Copyright © 2020 gyz. All rights reserved.
//

import UIKit

class HOOPPhoneNetWorkVC: GYZBaseVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "手机配网"
        self.view.backgroundColor = kWhiteColor
        
        setupUI()
    }
    
    /// 创建UI
    func setupUI(){
        view.addSubview(linkBtn)
        view.addSubview(noLinkBtn)
        
        noLinkBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-30)
            make.left.equalTo(30)
            make.bottom.equalTo(self.view.snp.centerY).offset(-kTitleHeight)
            make.height.equalTo(kUIButtonHeight)
        }
        linkBtn.snp.makeConstraints { (make) in
            make.height.left.right.equalTo(noLinkBtn)
            make.top.equalTo(self.view.snp.centerY).offset(kTitleHeight)
        }
    }
    
    /// 设备已联网
    lazy var linkBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBlueFontColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("设备已联网", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = 8
        
        btn.addTarget(self, action: #selector(clickedLinkBtn), for: .touchUpInside)
        
        return btn
    }()
    /// 设备未联网
    lazy var noLinkBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBlueFontColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("设备未联网", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = 8
        
        btn.addTarget(self, action: #selector(clickedNoLinkBtn), for: .touchUpInside)
        
        return btn
    }()
    /// 设备已联网
    @objc func clickedLinkBtn(){
        let vc = HOOPBlueToothContentVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 设备未联网
    @objc func clickedNoLinkBtn(){
        let vc = HOOPLinkPowerVC()
        navigationController?.pushViewController(vc, animated: true)
    }
}
