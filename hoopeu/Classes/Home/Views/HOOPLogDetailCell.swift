//
//  HOOPLogDetailCell.swift
//  hoopeu
//  报警日志详情 cell
//  Created by gouyz on 2019/2/26.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPLogDetailCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(iconView)
        contentView.addSubview(nameLab)
        
        iconView.backgroundColor = kHeightGaryFontColor
        iconView.snp.makeConstraints { (make) in
            make.top.equalTo(kMargin)
            make.height.equalTo((kScreenWidth * 0.5 - kMargin * 2) * 0.5)
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
        }
        nameLab.snp.makeConstraints { (make) in
            make.top.equalTo(iconView.snp.bottom)
            make.bottom.left.right.equalTo(contentView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// icon
    lazy var iconView: UIImageView = UIImageView()
    /// cell title
    lazy var nameLab : UILabel = {
        let lab = UILabel()
        lab.font = k13Font
        lab.textColor = kBlackFontColor
        lab.textAlignment = .center
        
        return lab
    }()
    ///
    lazy var stateLab : UILabel = {
        let lab = UILabel()
        lab.font = k13Font
        lab.textColor = kHeightGaryFontColor
        lab.textAlignment = .center
        
        return lab
    }()
}

