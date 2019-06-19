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
                
                nameLab.text = model.content
                let size = model.content!.sizeThatFits(fontSize: 15, width: 220)
                let cellSize = CGSize.init(width: size.width + 50, height: size.height + kMargin * 2 + 5)
                if model.role == "1" {//我发的
                    bgView.backgroundColor = kBlueFontColor
                    nameLab.textColor = kWhiteColor
                    bgView.snp.remakeConstraints { (make) in
                        make.right.equalTo(-20)
                        make.top.equalTo(kMargin)
                        make.bottom.equalTo(-kMargin)
                        make.size.equalTo(cellSize)
                    }
                }else{
                    bgView.backgroundColor = kWhiteColor
                    nameLab.textColor = kBlackFontColor
                    bgView.snp.remakeConstraints { (make) in
                        make.left.equalTo(20)
                        make.top.equalTo(kMargin)
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
        contentView.addSubview(bgView)
        bgView.addSubview(nameLab)
        
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(kMargin)
            make.size.equalTo(CGSize.zero)
        }
        nameLab.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.bottom.equalTo(-kMargin)
            make.top.equalTo(kMargin)
        }
    }
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
