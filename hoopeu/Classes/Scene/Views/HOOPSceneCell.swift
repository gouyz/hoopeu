//
//  HOOPSceneCell.swift
//  hoopeu
//  智能场景  cell
//  Created by gouyz on 2019/2/22.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPSceneCell: UICollectionViewCell {
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(iconView)
        contentView.addSubview(nameLab)
        
        iconView.snp.makeConstraints { (make) in
            make.top.equalTo(kMargin)
            make.height.equalTo(kSceneCellWidthDefault - kMargin * 2)
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
    lazy var iconView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_scene_default"))
    /// cell title
    lazy var nameLab : UILabel = {
        let lab = UILabel()
        lab.font = k13Font
        lab.textColor = kBlackFontColor
        lab.textAlignment = .center
        
        return lab
    }()
}
