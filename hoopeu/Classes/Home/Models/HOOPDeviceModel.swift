//
//  HOOPDeviceModel.swift
//  hoopeu
//  叮当宝贝设备model
//  Created by gouyz on 2019/3/21.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

@objcMembers
class HOOPDeviceModel: LHSBaseModel {
    /// 用户id
    var userId : String?
    /// 设备名称
    var deviceName : String? = ""
    /// 房间id
    var roomId : String? = ""
    /// 房间名称
    var roomName : String? = ""
    /// 0未使用 1正在使用
    var status : String? = ""
    /// 设备id
    var deviceId : String? = ""
    /// 设备是否在线
    var onLine : String? = ""
}

/// 叮当宝贝信息model
@objcMembers
class HOOPDeviceInfoModel: LHSBaseModel {
    /// 产品序列号
    var serialno : String? = ""
    /// 设备名称
    var device_name : String? = ""
    /// ip地址
    var ip : String? = ""
    /// 系统版本
    var sys_version : String? = ""
    /// mac地址
    var mac : String? = ""
    /// 局域网IP
    var local_ip : String? = ""
}
