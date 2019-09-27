//
//  HOOPParamModel.swift
//  hoopeu
//  保修参数model
//  Created by gouyz on 2019/9/25.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

@objcMembers
class HOOPParamModel: LHSBaseModel {
    /// id
    var id : String? = ""
    /// 名称
    var name : String? = ""
}


@objcMembers
class HOOPParamDetailModel: LHSBaseModel {
    //true已完善  false未完善
    var isPerfect : String? = ""
    /// //1男 2女
    var sex : String? = ""
    /// age id
    var age : String? = ""
    /// 名称
    var ageName : String? = ""
    /// area id
    var area : String? = ""
    /// 名称
    var areaName : String? = ""
    /// industry id
    var industry : String? = ""
    /// 名称
    var industryName : String? = ""
}
