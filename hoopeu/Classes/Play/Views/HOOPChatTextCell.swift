//
//  HOOPChatTextCell.swift
//  hoopeu
//  聊天text cell
//  Created by gouyz on 2019/3/26.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPChatTextCell: UITableViewCell {
    
    /// 填充数据
    var dataModel : HOOPChatModel?{
        didSet{
            if let model = dataModel {
                
                dateLab.text = model.time?.getDateTime(format: "MM月dd日 HH:mm")
                nameLab.text = model.content
                let size = model.content!.sizeThatFits(fontSize: 15, width: 220)
                let cellSize = CGSize.init(width: size.width + 50, height: size.height + kMargin * 2 + 5)
                if model.role == "1" {//我发的
                    bgView.backgroundColor = kBlueFontColor
                    nameLab.textColor = kWhiteColor
                    bgView.snp.remakeConstraints { (make) in
                        make.right.equalTo(-20)
                        make.top.equalTo(dateLab.snp.bottom).offset(kMargin)
                        make.bottom.equalTo(-kMargin)
                        make.size.equalTo(cellSize)
                    }
                }else{
                    bgView.backgroundColor = kWhiteColor
                    nameLab.textColor = kBlackFontColor
                    bgView.snp.remakeConstraints { (make) in
                        make.left.equalTo(20)
                        make.top.equalTo(dateLab.snp.bottom).offset(kMargin)
                        make.bottom.equalTo(-kMargin)
                        make.size.equalTo(cellSize)
                    }
                }
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = kBackgroundColor
        setupUI()
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        contentView.addSubview(dateLab)
        contentView.addSubview(bgView)
        bgView.addSubview(nameLab)
        
        dateLab.snp.makeConstraints { (make) in
            make.top.equalTo(kMargin)
            make.centerX.equalTo(contentView)
            make.size.equalTo(CGSize.init(width: 120, height: 30))
        }
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(dateLab.snp.bottom).offset(kMargin)
            make.size.equalTo(CGSize.zero)
        }
        nameLab.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.bottom.equalTo(-kMargin)
            make.top.equalTo(kMargin)
        }
    }
    /// cell date
    lazy var dateLab : UILabel = {
        let lab = UILabel()
        lab.font = k13Font
        lab.textColor = kWhiteColor
        lab.backgroundColor = kBtnNoClickBGColor
        lab.cornerRadius = kCornerRadius
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = kWhiteColor
        view.cornerRadius = 10
        
        return view
    }()
    /// cell title
    lazy var nameLab : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        lab.numberOfLines = 0
        
        return lab
    }()

}
