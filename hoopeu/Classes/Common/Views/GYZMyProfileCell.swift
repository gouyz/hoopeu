//
//  GYZMyProfileCell.swift
//  JSMachine
//  个人信息cell
//  Created by gouyz on 2018/11/23.
//  Copyright © 2018 gouyz. All rights reserved.
//

import UIKit

class GYZMyProfileCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = kWhiteColor
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        contentView.addSubview(userImgView)
        contentView.addSubview(desLab)
        contentView.addSubview(nameLab)
        contentView.addSubview(rightIconView)
        
        nameLab.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(contentView)
            make.left.equalTo(contentView).offset(kMargin)
            make.right.equalTo(desLab.snp.left).offset(-kMargin)
        }
        userImgView.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.right.equalTo(rightIconView.snp.left).offset(-kMargin)
            make.size.equalTo(CGSize.init(width: 50, height: 50))
        }
        desLab.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(contentView)
            make.right.equalTo(rightIconView.snp.left).offset(-5)
            make.width.equalTo(kScreenWidth * 0.5)
        }
        rightIconView.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.right.equalTo(contentView).offset(-kMargin)
            make.size.equalTo(rightArrowSize)
        }
    }
    
    /// 用户头像
    lazy var userImgView : UIImageView = {
        let img = UIImageView()
        img.cornerRadius = 25
        img.borderColor = kWhiteColor
        img.borderWidth = klineDoubleWidth
        
        return img
    }()
    /// cell title
    lazy var nameLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        
        return lab
    }()
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.font = k13Font
        lab.textColor = kGaryFontColor
        lab.textAlignment = .right
        
        return lab
    }()
    /// 右侧箭头图标
    lazy var rightIconView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_right_arrow"))
    
}
