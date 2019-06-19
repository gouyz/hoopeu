//
//  HOOPSceneDetailModel.swift
//  hoopeu
//  场景详情model
//  Created by gouyz on 2019/3/28.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

@objcMembers
class HOOPSceneDetailModel: LHSBaseModel {
    /// 对小叮当说
    var sceneSayList: [HOOPSceneSayModel] = [HOOPSceneSayModel]()
    /// 小叮当执行
    var sceneDoList: [HOOPSceneDoModel] = [HOOPSceneDoModel]()
    /// 场景条件
    var sceneConditionList: [HOOPSceneConditionModel] = [HOOPSceneConditionModel]()
    /// 场景info
    var sceneModel: HOOPSceneModel?
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "scene_do"{
            guard let datas = value as? [[String : Any]] else { return }
            for dict in datas {
                let model = HOOPSceneDoModel(dict: dict)
                sceneDoList.append(model)
            }
        }else if key == "scene_condition"{
            guard let datas = value as? [[String : Any]] else { return }
            for dict in datas {
                let model = HOOPSceneConditionModel(dict: dict)
                sceneConditionList.append(model)
            }
        }else if key == "scene_say"{
            guard let datas = value as? [[String : Any]] else { return }
            for dict in datas {
                let model = HOOPSceneSayModel(dict: dict)
                sceneSayList.append(model)
            }
        }else if key == "scene"{
            guard let datas = value as? [String : Any] else { return }
            sceneModel = HOOPSceneModel(dict: datas)
        }else {
            super.setValue(value, forKey: key)
        }
    }
}

/// 对小叮当说
@objcMembers
class HOOPSceneSayModel: LHSBaseModel {
    /// id
    var id : String?
    /// 场景id
    var sceneId : String? = ""
    /// 说的内容
    var content : String? = ""
}
/// 小叮当执行
@objcMembers
class HOOPSceneDoModel: LHSBaseModel {
    /// id
    var id : String?
    /// 场景id
    var sceneId : String? = ""
    /// 动作类型
    var type : String? = ""
    /// 指令
    var cmd : String? = ""
    /// 时长
    var time : String? = "0"
}
/// 场景条件
@objcMembers
class HOOPSceneConditionModel: LHSBaseModel {
    /// id
    var id : String?
    /// 场景id
    var sceneId : String? = ""
    /// 传感器名称
    var name : String? = ""
    /// /所选传感器id
    var ctrlId : String? = ""
    /// 房间id
    var room_id : String? = ""
    /// 房间名称
    var room_name : String? = ""
}
