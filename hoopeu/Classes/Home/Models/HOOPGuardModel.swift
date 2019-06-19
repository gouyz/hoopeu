//
//  HOOPGuardModel.swift
//  hoopeu
//  报警日志model
//  Created by gouyz on 2019/3/31.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

@objcMembers
class HOOPGuardModel: LHSBaseModel {

    /// id
    var id : String?
    /// 时间
    var time : String? = ""
    /// 用户id
    var userId : String? = ""
    /// 图片URL
    var urlList : [String] = [String]()
    /// 日期
    var dayTime : String? = ""
    /// 设备id
    var deviceId : String? = ""
    /// 0未处理1已处理
    var handle : String? = ""
    /// 报警类型
    var type : String? = ""
    /// 报警类型名称
    var typeName : String? = ""
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "url"{
            guard let datas = value as? [String] else { return }
            for item in datas {
                urlList.append(item)
            }
        }else {
            super.setValue(value, forKey: key)
        }
    }
}
