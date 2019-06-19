//
//  HOOPCustomControlKeyCell.swift
//  hoopeu
//  自定义遥控 按键cell
//  Created by gouyz on 2019/3/8.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPCustomControlKeyCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = kWhiteColor
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        
        contentView.addSubview(nameLab)
    
        nameLab.snp.makeConstraints { (make) in
            make.top.equalTo(kMargin)
            make.left.right.bottom.equalTo(contentView)
        }
    }
    
    /// 标题
    lazy var nameLab : UILabel = {
        let lab = UILabel()
        lab.backgroundColor = kBtnClickBGColor
        lab.textColor = kWhiteColor
        lab.font = k15Font
        lab.textAlignment = .center
        lab.cornerRadius = (kScreenWidth - 5 * kMargin) * 0.125
        lab.text = "音量+"
        
        return lab
    }()
}
