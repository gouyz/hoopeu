//
//  HOOPShotsModel.swift
//  hoopeu
//  图库model
//  Created by gouyz on 2019/6/20.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

@objcMembers
class HOOPShotsModel: LHSBaseModel {
    /// id
    var id : String?
    /// 用户id
    var userId : String? = ""
    /// 图片URL
    var url : String? = ""
    /// 添加时间
    var createTime : String? = ""
    /// 设备id
    var deviceId : String? = ""
    ///
    var isDel : String? = ""
}
