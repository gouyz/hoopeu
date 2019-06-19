//
//  HOOPSelectedSwitchNameView.swift
//  hoopeu
//  选择开关名称
//  Created by gouyz on 2019/3/18.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPSelectedSwitchNameView: UIView {

    // MARK: 生命周期方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        
        addSubview(bgView)
        bgView.addSubview(tagImgView)
        bgView.addSubview(nameLab)
        bgView.addSubview(contentLab)
        bgView.addSubview(rightIconView)
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        tagImgView.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.centerY.equalTo(bgView)
            make.size.equalTo(CGSize.init(width: 15, height: 22))
        }
        
        nameLab.snp.makeConstraints { (make) in
            make.left.equalTo(tagImgView.snp.right).offset(5)
            make.top.bottom.equalTo(bgView)
            make.width.equalTo(80)
        }
        contentLab.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(nameLab)
            make.right.equalTo(rightIconView.snp.left).offset(-5)
            make.left.equalTo(nameLab.snp.right).offset(kMargin)
        }
        rightIconView.snp.makeConstraints { (make) in
            make.centerY.equalTo(bgView)
            make.right.equalTo(-kMargin)
            make.size.equalTo(rightArrowSize)
        }
        
    }
    ///
    lazy var bgView: UIView = {
        let bgview = UIView()
        bgview.borderColor = kBlueFontColor
        bgview.borderWidth = klineWidth
        bgview.cornerRadius = 15
        
        return bgview
    }()
    /// 图片tag
    lazy var tagImgView : UIImageView = UIImageView.init(image: UIImage.init(named: "icon_light_tag"))
    /// 名称
    lazy var nameLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        
        return lab
    }()
    /// 内容
    var contentLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        lab.textAlignment = .right
        
        return lab
    }()
    /// 右侧箭头图标
    lazy var rightIconView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_right_arrow"))
}
