//
//  HOOPCtrlModel.swift
//  hoopeu
//  条件场景 传感器model
//  Created by gouyz on 2019/3/28.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

@objcMembers
class HOOPCtrlModel: LHSBaseModel {
    /// id
    var sensorId : String?
    /// 传感器名称
    var sensorName : String? = ""
    /// 房间id
    var roomId : String? = ""
    /// 房间名称
    var roomName : String? = ""
    /// 状态 true false
    var status : String? = ""
}
