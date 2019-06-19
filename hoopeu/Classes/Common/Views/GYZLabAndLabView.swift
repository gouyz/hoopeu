//
//  GYZLabAndLabView.swift
//  JSMachine
//  label 和 label View
//  Created by gouyz on 2018/11/29.
//  Copyright © 2018 gouyz. All rights reserved.
//

import UIKit

class GYZLabAndLabView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI(){
        // 添加子控件
        addSubview(desLab)
        addSubview(contentLab)
        
        // 布局子控件
        desLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.top.bottom.equalTo(self)
            make.width.equalTo(100)
        }
        
        contentLab.snp.makeConstraints { (make) in
            make.left.equalTo(desLab.snp.right).offset(kMargin)
            make.top.bottom.equalTo(self)
            make.right.equalTo(-kMargin)
        }
    }
    
    /// 描述
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.textColor = kBlackFontColor
        lab.font = k15Font
        
        return lab
    }()
    /// 内容
    lazy var contentLab : UILabel = {
        let lab = UILabel()
        lab.textColor = kBlackFontColor
        lab.font = k15Font
        
        return lab
    }()
}
