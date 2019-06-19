//
//  HOOPHomeModel.swift
//  hoopeu
//  首页model
//  Created by gouyz on 2019/3/29.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

@objcMembers
class HOOPHomeModel: LHSBaseModel {
    /// id
    var id : String?
    /// 房间id
    var roomId : String? = ""
    /// 房间名称
    var roomName : String? = ""
    /// 设备id
    var deviceId : String? = ""
    ///
    var isDefault : String? = ""
    ///
    var isDel : String? = ""
    /// 房间图片
    var image : String? = ""
}
