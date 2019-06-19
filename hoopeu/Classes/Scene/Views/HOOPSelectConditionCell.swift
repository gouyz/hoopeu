//
//  HOOPSelectConditionCell.swift
//  hoopeu
//  添加添加cell
//  Created by gouyz on 2019/2/25.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPSelectConditionCell: UITableViewCell {

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
        bgView.addSubview(switchView)
        
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
            make.size.equalTo(CGSize.init(width: 13, height: 30))
        }
        nameLab.snp.makeConstraints { (make) in
            make.left.equalTo(iconView.snp.right).offset(kMargin)
            make.right.equalTo(switchView.snp.left).offset(-kMargin)
            make.top.bottom.equalTo(bgView)
        }
        switchView.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.centerY.equalTo(bgView)
        }
    }
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = kWhiteColor
        view.cornerRadius = 10
        
        return view
    }()
    lazy var iconView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_condition"))
    /// cell title
    lazy var nameLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        lab.highlightedTextColor = kBlueFontColor
        
        return lab
    }()
    /// 开关
    lazy var switchView: UISwitch = {
        let sw = UISwitch()
        sw.isHidden = true
        return sw
    }()
}
