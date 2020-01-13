//
//  HOOPAddVoiceSceneCell.swift
//  hoopeu
//  新建语音场景 cell
//  Created by gouyz on 2019/2/22.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPAddVoiceSceneCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = kWhiteColor
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        contentView.addSubview(nameLab)
        
        nameLab.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.bottom.equalTo(-kMargin)
            make.top.equalTo(kMargin)
        }
    }
    /// cell title
    lazy var nameLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kWhiteColor
        lab.backgroundColor = kBtnClickBGColor
        lab.textAlignment = .center
        lab.numberOfLines = 0
        lab.cornerRadius = 8
        lab.borderColor = kBtnClickBGColor
        lab.borderWidth = klineWidth
        
        return lab
    }()
}

