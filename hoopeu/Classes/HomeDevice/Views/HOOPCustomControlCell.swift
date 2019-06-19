//
//  HOOPCustomControlCell.swift
//  hoopeu
//  自定义遥控 cell
//  Created by gouyz on 2019/3/6.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPCustomControlCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = kWhiteColor
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        
        bgImgView.isUserInteractionEnabled = true
        contentView.addSubview(bgImgView)
        bgImgView.addSubview(nameLab)
        bgImgView.addSubview(delImgView)
        
        bgImgView.snp.makeConstraints { (make) in
            
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.bottom.equalTo(self)
        }
        nameLab.snp.makeConstraints { (make) in
            make.center.equalTo(bgImgView)
            make.size.equalTo(CGSize.init(width: 70, height: 70))
        }
        delImgView.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.top.equalTo(kMargin)
            make.size.equalTo(CGSize.init(width: 18, height: 24))
        }
    }
    
    /// 背景图片
    lazy var bgImgView : UIImageView = UIImageView.init(image: UIImage.init(named: "icon_board_blue"))
    /// 标题
    lazy var nameLab : UILabel = {
        let lab = UILabel()
        lab.backgroundColor = kBtnClickBGColor
        lab.textColor = kWhiteColor
        lab.font = k15Font
        lab.textAlignment = .center
        lab.cornerRadius = 35
        lab.text = ""
        
        return lab
    }()
    /// 删除图片
    lazy var delImgView : UIImageView = UIImageView.init(image: UIImage.init(named: "icon_delete"))
}
