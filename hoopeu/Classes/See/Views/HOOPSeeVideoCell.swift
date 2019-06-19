//
//  HOOPSeeVideoCell.swift
//  hoopeu
//  爱心看护 cell
//  Created by gouyz on 2019/3/18.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPSeeVideoCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        contentView.addSubview(nameLab)
        contentView.addSubview(settingBtn)
        contentView.addSubview(iconBgView)
        iconBgView.addSubview(iconPlayView)
        contentView.addSubview(lineView)
        
        nameLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(settingBtn.snp.left).offset(-kMargin)
            make.height.equalTo(50)
            make.top.equalTo(contentView)
        }
        settingBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-kMargin)
            make.top.bottom.equalTo(nameLab)
            make.width.equalTo(60)
        }
        iconBgView.snp.makeConstraints { (make) in
            make.top.equalTo(nameLab.snp.bottom)
            make.left.equalTo(nameLab)
            make.right.equalTo(-kMargin)
            make.bottom.equalTo(lineView.snp.top).offset(-kMargin)
        }
        iconPlayView.snp.makeConstraints { (make) in
            make.center.equalTo(iconBgView)
            make.size.equalTo(CGSize.init(width: 50, height: 50))
        }
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalTo(iconBgView)
            make.bottom.equalTo(contentView)
            make.height.equalTo(klineWidth)
        }
    }
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = kWhiteColor
        view.cornerRadius = 10
        
        return view
    }()
    lazy var iconBgView: UIImageView = {
        let imgView = UIImageView.init()
        imgView.backgroundColor = kBackgroundColor
        imgView.cornerRadius = 10
        imgView.image = UIImage.init(named: "icon_see_default")
        
        return imgView
    }()
    lazy var iconPlayView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_video_play"))
    /// cell title
    lazy var nameLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        lab.text = "客厅叮当看看"
        
        return lab
    }()
    /// 设置
    lazy var settingBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kWhiteColor
        btn.setImage(UIImage.init(named: "icon_device_setting"), for: .normal)
        
//        btn.addTarget(self, action: #selector(clickedOperatorBtn(btn:)), for: .touchUpInside)
        
        return btn
    }()
    /// 分割线
    var lineView : UIView = {
        let line = UIView()
        line.backgroundColor = kGrayLineColor
        return line
    }()
}
