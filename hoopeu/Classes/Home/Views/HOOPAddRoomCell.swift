//
//  HOOPAddRoomCell.swift
//  hoopeu
//  选择房间cell
//  Created by gouyz on 2019/2/22.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

class HOOPAddRoomCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(roomBtn)
        roomBtn.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// 房间
    lazy var roomBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setBackgroundImage(UIImage.init(named: "icon_room_bg_normal"), for: .normal)
        btn.setBackgroundImage(UIImage.init(named: "icon_room_bg_normal"), for: .disabled)
        btn.setBackgroundImage(UIImage.init(named: "icon_room_bg_selected"), for: .selected)
        btn.setTitleColor(kBlackFontColor, for: .normal)
        btn.setTitleColor(kWhiteColor, for: .selected)
        btn.setTitleColor(kHeightGaryFontColor, for: .disabled)
        btn.titleLabel?.font = k15Font
        
        return btn
    }()
}
