//
//  HOOPRoomDeviceCell.swift
//  hoopeu
//  首页 设备cell
//  Created by gouyz on 2019/2/26.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPRoomDeviceCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = kWhiteColor
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        contentView.addSubview(iconView)
        contentView.addSubview(nameLab)
        contentView.addSubview(switchView)
        
        iconView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.centerY.equalTo(contentView)
            make.size.equalTo(CGSize.init(width: 26, height: 30))
        }
        nameLab.snp.makeConstraints { (make) in
            make.left.equalTo(iconView.snp.right).offset(kMargin)
            make.right.equalTo(switchView.snp.left).offset(-kMargin)
            make.top.bottom.equalTo(contentView)
        }
        switchView.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.centerY.equalTo(contentView)
        }
    }
    lazy var iconView: UIImageView = UIImageView.init()
    /// cell title
    lazy var nameLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        lab.textAlignment = .center
        
        return lab
    }()
    /// 开关
    lazy var switchView: UISwitch = {
        let sw = UISwitch()
        return sw
    }()
}
