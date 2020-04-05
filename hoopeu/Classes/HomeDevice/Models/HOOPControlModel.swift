//
//  HOOPControlModel.swift
//  hoopeu
//  遥控器model
//  Created by gouyz on 2019/6/27.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

@objcMembers
class HOOPControlModel: LHSBaseModel {
    /// 按键list
    var funcList: [HOOPCustomKeyModel] = [HOOPCustomKeyModel]()
    /// 按钮位置Namelist
    var funcNameList: [String] = [String]()
    /// 遥控器品牌下标
    var brand: String? = ""
    /// 品牌方案组下标
    var code_bark: String? = ""
    /// id
    var id: String? = ""
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "custom"{
            guard let datas = value as? [[String : Any]] else { return }
            for dict in datas {
                let model = HOOPCustomKeyModel(dict: dict)
                funcList.append(model)
                funcNameList.append(model.customNum!)
            }
        }else {
            super.setValue(value, forKey: key)
        }
    }
}
/// 遥控器自定义按键model
@objcMembers
class HOOPCustomKeyModel: LHSBaseModel {
    
    /// 自定义按钮id
    var sensorId : String? = "0"
    /// 按键名称
    var customNum : String? = ""
    /// 按钮位置
    var ctrlName : String? = ""
}
