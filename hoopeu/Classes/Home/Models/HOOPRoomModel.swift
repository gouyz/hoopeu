//
//  HOOPRoomModel.swift
//  hoopeu
//  房间model
//  Created by gouyz on 2019/3/21.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

@objcMembers
class HOOPRoomModel: LHSBaseModel {

    /// id
    var id : String?
    /// 房间id
    var roomId : String? = ""
    /// 房间名称
    var roomName : String? = ""
    /// 房间状态（0未添加 1已添加）
    var status : String? = ""
    /// 设备id
    var deviceId : String? = ""
    ///
    var isDefault : String? = ""
    ///
    var isDel : String? = ""
}
