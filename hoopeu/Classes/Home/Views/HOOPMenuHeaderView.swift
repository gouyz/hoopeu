//
//  HOOPMenuHeaderView.swift
//  hoopeu
//  侧边栏header View
//  Created by gouyz on 2019/2/21.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPMenuHeaderView: UIView {
    /// 点击操作
    var onClickedOperatorBlock: (() -> Void)?
    
    
    // MARK: 生命周期方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = kWhiteColor
        setupUI()
        
        self.isUserInteractionEnabled = true
        iconBgView.isUserInteractionEnabled = true
        iconPreView.addOnClickListener(target: self, action: #selector(onClickedProfile))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupUI(){
        
        addSubview(iconBgView)
        iconBgView.addSubview(iconPreView)
        iconPreView.addSubview(iconHeaderView)
        iconPreView.addSubview(nameLab)
        
        iconBgView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.top.equalTo(kStateHeight)
        }
        iconPreView.snp.makeConstraints { (make) in
            make.center.equalTo(iconBgView)
            make.size.equalTo(CGSize.init(width: 213, height: 88))
        }
        
        iconHeaderView.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.centerY.equalTo(iconPreView)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
        nameLab.snp.makeConstraints { (make) in
            make.left.equalTo(iconHeaderView.snp.right).offset(kMargin)
            make.centerY.height.equalTo(iconHeaderView)
            make.right.equalTo(-kMargin)
        }
        
    }
    
    lazy var iconBgView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_menu_header_bg"))
    lazy var iconPreView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_menu_header_pre"))
    lazy var iconHeaderView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_menu_header_default"))
    ///
    lazy var nameLab : UILabel = {
        let lab = UILabel()
        lab.textColor = kWhiteColor
        lab.font = k20Font
        lab.text = "18712345678"
        
        return lab
    }()
    
    @objc func onClickedProfile(){
        if onClickedOperatorBlock != nil {
            onClickedOperatorBlock!()
        }
    }
}
