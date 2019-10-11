//
//  HOOPLinkPowerVC.swift
//  hoopeu
//  连接电源
//  Created by gouyz on 2019/2/20.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPLinkPowerVC: GYZBaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "轻按电源键"
        self.view.backgroundColor = kWhiteColor
        
        setupUI()
    }
    
    /// 创建UI
    func setupUI(){
        view.addSubview(desLab)
        view.addSubview(desLab1)
        view.addSubview(iconView)
        view.addSubview(blueBtn)
        view.addSubview(noBlueLabel)
        
        desLab.snp.makeConstraints { (make) in
            make.top.equalTo(kTitleAndStateHeight + kTitleHeight)
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.height.equalTo(kTitleHeight)
        }
        desLab1.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(desLab)
            make.top.equalTo(desLab.snp.bottom)
        }
        iconView.snp.makeConstraints { (make) in
            make.top.equalTo(desLab1.snp.bottom).offset(30)
            make.centerX.equalTo(view)
            make.size.equalTo(CGSize.init(width: 200, height: 280))
        }
        blueBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-30)
            make.left.equalTo(30)
            make.top.equalTo(iconView.snp.bottom).offset(30)
            make.height.equalTo(kUIButtonHeight)
        }
        noBlueLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(blueBtn)
            make.top.equalTo(blueBtn.snp.bottom).offset(kMargin)
            make.size.equalTo(CGSize.init(width: 150, height: 30))
        }
    }
    ///
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.textColor = kBlackFontColor
        lab.font = k18Font
        lab.textAlignment = .center
        lab.text = "请轻按一下电源键"
        
        return lab
    }()
    lazy var desLab1 : UILabel = {
        let lab = UILabel()
        lab.textColor = kBlackFontColor
        lab.font = k13Font
        lab.textAlignment = .center
        lab.text = "出现蓝光闪烁"
        
        return lab
    }()
    lazy var iconView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_link_baby"))
    
    /// 出现蓝光闪烁
    lazy var blueBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kBlueFontColor
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.setTitle("出现蓝光闪烁", for: .normal)
        btn.titleLabel?.font = k15Font
        btn.cornerRadius = 8
        
        btn.addTarget(self, action: #selector(clickedBlueBtn), for: .touchUpInside)
        
        return btn
    }()
    lazy var noBlueLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = kBlueFontColor
        lab.font = k13Font
        lab.textAlignment = .center
        lab.text = "未出现蓝色灯光？"
        lab.addOnClickListener(target: self, action: #selector(onClickedNoBlue))
        
        return lab
    }()
    /// 出现蓝光闪烁
    @objc func clickedBlueBtn(){
        let vc = HOOPReadyNetWorkVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 未出现蓝色灯光
    @objc func onClickedNoBlue(){
        goWebVC()
    }
    
    /// 未出现蓝色灯光
    func goWebVC(){
        let vc = JSMWebViewVC()
        vc.webTitle = "未出现蓝色灯光"
        vc.url = "http://www.hoopeurobot.com/page/protocol.html?id=3"
        navigationController?.pushViewController(vc, animated: true)
    }
}
