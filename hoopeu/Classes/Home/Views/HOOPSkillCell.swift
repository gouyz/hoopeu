//
//  HOOPSkillCell.swift
//  hoopeu
//  技能设置cell
//  Created by gouyz on 2019/2/21.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPSkillCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = kBackgroundColor
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        contentView.addSubview(bgView)
        bgView.addSubview(iconView)
        bgView.addSubview(nameLab)
        
        iconView.backgroundColor = kBackgroundColor
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.bottom.equalTo(contentView)
            make.top.equalTo(kMargin)
        }
        iconView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.centerY.equalTo(bgView)
            make.size.equalTo(CGSize.init(width: 24, height: 24))
        }
        nameLab.snp.makeConstraints { (make) in
            make.left.equalTo(iconView.snp.right).offset(kMargin)
            make.right.equalTo(-kMargin)
            make.top.bottom.equalTo(bgView)
        }
    }
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = kWhiteColor
        view.cornerRadius = 10
        
        return view
    }()
    lazy var iconView: UIImageView = UIImageView.init(image: UIImage.init(named: ""))
    /// cell title
    lazy var nameLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        lab.text = "QQ音乐"
        
        return lab
    }()
}
