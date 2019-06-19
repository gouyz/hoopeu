//
//  HOOPLinkPersonModel.swift
//  hoopeu
//  联系人model
//  Created by gouyz on 2019/6/10.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

@objcMembers
class HOOPLinkPersonModel: LHSBaseModel {
    /// 联系人id
    var id : String?
    /// 用户id
    var userId : String? = ""
    /// 联系人姓名
    var name : String? = ""
    /// 联系人电话
    var phone : String? = ""
}
