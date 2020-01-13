//
//  HOOPSceneModel.swift
//  hoopeu
//  智能场景
//  Created by gouyz on 2019/3/22.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

@objcMembers
class HOOPSceneModel: LHSBaseModel {
    /// id
    var id : String?
    /// 1条件场景  2语音场景 3定时场景
    var type : String? = ""
    /// 场景名称
    var name : String? = ""
    /// 设备序列号
    var deviceId : String? = ""
    
    /// 2019-01-01
    var dayOfYear : String? = ""
    /// 17:00
    var dayTime : String? = ""
    /// USER_DEFINE
    var weekTime : String? = ""
}
