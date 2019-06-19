//
//  HOOPCustomControlAddCell.swift
//  hoopeu
//  自定义遥控 添加cell
//  Created by gouyz on 2019/3/6.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPCustomControlAddCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = kWhiteColor
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        
        contentView.addSubview(bgImgView)
        
        bgImgView.snp.makeConstraints { (make) in
            
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.bottom.equalTo(self)
        }
    }
    
    /// 背景图片
    lazy var bgImgView : UIImageView = UIImageView.init(image: UIImage.init(named: "icon_add"))
    
}
