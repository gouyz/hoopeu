//
//  HOOPChatModel.swift
//  hoopeu
//  聊天model
//  Created by gouyz on 2019/3/27.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

@objcMembers
class HOOPChatModel: LHSBaseModel {

    /// //0代表机器人发出  1代表用户发出
    var role : String?
    /// 时间
    var time : String? = "0"
    /// 内容
    var content : String? = ""
}
