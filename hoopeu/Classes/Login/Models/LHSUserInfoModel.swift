//
//  LHSUserInfoModel.swift
//  LazyHuiService
//  用户信息model
//  Created by gouyz on 2017/6/21.
//  Copyright © 2017年 gouyz. All rights reserved.
//

import UIKit

@objcMembers
class LHSUserInfoModel: LHSBaseModel {
    /// 用户id
    var id : String? = ""
    /// 用户手机号
    var phone : String? = ""
    /// 用户的姓名（昵称）
    var nickname : String? = ""
    /// 用户邮箱
    var email : String? = ""
    /// 头像
    var head : String? = ""
    
}
