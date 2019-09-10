//
//  HOOPCustomControlModel.swift
//  hoopeu
//  自定义遥控model
//  Created by gouyz on 2019/4/17.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

@objcMembers
class HOOPCustomControlModel: LHSBaseModel {

    /// 按键list
    var funcList: [HOOPCustomFuncModel] = [HOOPCustomFuncModel]()
    /// 遥控器名称
    var ctrl_name: String? = ""
    /// 房间id
    var room_id: String? = ""
    /// id
    var id: String? = ""
    /// 遥控器类型
    var type: String? = ""
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "child"{
            guard let datas = value as? [[String : Any]] else { return }
            for dict in datas {
                let model = HOOPCustomFuncModel(dict: dict)
                funcList.append(model)
            }
        }else {
            super.setValue(value, forKey: key)
        }
    }
}
/// 自定义按键model
@objcMembers
class HOOPCustomFuncModel: LHSBaseModel {
    
    /// id
    var func_id : String?
    /// 按键名称
    var ctrl_name : String? = ""
    /// 学习码
    var study_code : String? = ""
}
