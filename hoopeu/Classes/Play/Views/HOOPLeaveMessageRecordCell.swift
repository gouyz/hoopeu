//
//  HOOPLeaveMessageRecordCell.swift
//  hoopeu
//  留言记录cell
//  Created by gouyz on 2020/1/18.
//  Copyright © 2020 gyz. All rights reserved.
//

import UIKit

class HOOPLeaveMessageRecordCell: UITableViewCell {

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
        contentView.addSubview(playBtn)
        contentView.addSubview(rightIconView)
        contentView.addSubview(lineView)
        
        nameLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.top.equalTo(contentView)
            make.bottom.equalTo(lineView.snp.top)
            make.height.greaterThanOrEqualTo(kTitleHeight)
            make.right.equalTo(playBtn.snp.left).offset(-kMargin)
        }
        playBtn.snp.makeConstraints { (make) in
            make.right.equalTo(rightIconView.snp.left).offset(-kMargin)
            make.centerY.equalTo(contentView)
            make.size.equalTo(CGSize.init(width: 30, height: 30))
        }
        rightIconView.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.right.equalTo(-kMargin)
            make.size.equalTo(rightArrowSize)
        }
        lineView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(contentView)
            make.height.equalTo(klineWidth)
        }
    }
    
    /// cell title
    lazy var nameLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        
        return lab
    }()
    /// 播放图标
    lazy var playBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "icon_play_speak"), for: .normal)
//        btn.setImage(UIImage.init(named: "icon_play_do"), for: .selected)
        
        return btn
    }()
    /// 右侧箭头图标
    lazy var rightIconView: UIImageView = UIImageView.init(image: UIImage.init(named: "icon_right_arrow"))
    
    /// 分割线
    var lineView : UIView = {
        let line = UIView()
        line.backgroundColor = kGrayLineColor
        return line
    }()

}
