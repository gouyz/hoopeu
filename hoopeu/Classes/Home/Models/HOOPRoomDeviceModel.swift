//
//  HOOPRoomDeviceModel.swift
//  hoopeu
//  房间设备model
//  Created by gouyz on 2019/3/29.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

@objcMembers
class HOOPRoomDeviceModel: LHSBaseModel {
    /// 0代表没有小夜灯、报警、爱心看护 1代表有
    var exist : String?
    /// 小夜灯开关状态 exist为0时不存在该项 false true
    var light : String? = ""
    /// 安防报警开关状态 exist为0时不存在该项 false true
    var `guard` : String? = ""
    
    /// 开关list
    var switchList: [HOOPRoomDeviceSwitchModel] = [HOOPRoomDeviceSwitchModel]()
    /// 设备list
    var intelligentDeviceList: [HOOPRoomIntelligentDeviceModel] = [HOOPRoomIntelligentDeviceModel]()
    /// 传感器list
    var sensorList: [HOOPRoomDeviceSensorModel] = [HOOPRoomDeviceSensorModel]()
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "device"{
            guard let datas = value as? [[String : Any]] else { return }
            for dict in datas {
                let model = HOOPRoomIntelligentDeviceModel(dict: dict)
                intelligentDeviceList.append(model)
            }
        }else if key == "switchs"{
            guard let datas = value as? [[String : Any]] else { return }
            for dict in datas {
                let model = HOOPRoomDeviceSwitchModel(dict: dict)
                switchList.append(model)
            }
        }else if key == "sensors"{
            guard let datas = value as? [[String : Any]] else { return }
            for dict in datas {
                let model = HOOPRoomDeviceSensorModel(dict: dict)
                sensorList.append(model)
            }
        }else {
            super.setValue(value, forKey: key)
        }
    }

}

/// 开关model
@objcMembers
class HOOPRoomDeviceSwitchModel: LHSBaseModel {
    /// 开关id
    var serial_id : String?
    /// 开关名称
    var switch_name : String? = ""
    /// 房间id
    var room_id : String? = ""
    /// 开关组id
    var switch_id : String? = ""
    /// off on
    var state : String? = ""
}
/// 传感器model
@objcMembers
class HOOPRoomDeviceSensorModel: LHSBaseModel {
    /// 传感器id
    var sensor_id : String?
    /// 传感器名称
    var sensor_name : String? = ""
    /// 状态 true
    var state : String? = ""
}

/// 智能设备model
@objcMembers
class HOOPRoomIntelligentDeviceModel: LHSBaseModel {
    /// id
    var id : String?
    /// 设备名称
    var ctrl_name : String? = ""
    /// 设备类型    ”switch”:智能开关；”ir”：红外设备 ；”pt2262”:无线射频设备；”sensor”:传感器设备；”other”:自定义设备
    var type : String? = ""
    /// 设备子类型 ”ir_air”:空调；”ir_tv”：电视 ；”ir_stb”:机顶盒；”ir_iptv”:IPTV遥控器；”ir_sound”:音响；”ir_proj”:投影仪；”ir_fan:”风扇;”ir_other”:自定义遥控
    var type_lower : String? = ""
}
