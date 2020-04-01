//
//  HOOPLeaveMessageModel.swift
//  hoopeu
//  留言 model
//  Created by gouyz on 2019/3/27.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit

@objcMembers
class HOOPLeaveMessageModel: LHSBaseModel {

    /// 1：app 2语音留言id
    var id : String?
    /// 用户想要播报的语句的时间
    var day_time : String? = ""
    /// 日期
    var yml : String? = ""
    /// 1：app 2语音留言内容
    var msg : String? = ""
    /// 文件名称
//    var leavemsgName : String? = ""
    /// 每周循环时间 ,ONCE:仅此一次,EVERYDAY :每天,WEEKDAY:工作日,WEEKEND:每周末,USER_DEFINE:自定义
    var weak_time : String? = ""
    /// 用户自定义时间选择（以“;”间隔），可多选。EVERY_MONDAY:每周一,EVERY_TUESDAY:每周二,EVERY_WEDNESDAY:每周三,EVERY_THURSDAY:每周四,EVERY_FRIDAY:每周五,EVERY_SATURDAY:每周六,EVERY_SUNDAY:每周日
    var user_define_times : [String] = [String]()
    /// 是否轮播消息,0:不轮播；1：轮播 ，默认为轮播
    var loop : String? = ""
    /// 1:app端  2:设备端
    var type : String? = ""
    
    /// 留言消息类型，”TEXT”:文本留言，”AUDIO”：音频留言
    var leavemsgType : String? = ""
    
    /// 收到的留言id
    var leavemsgId : String?
    /// 收到的留言内容
    var tts : String? = ""
    /// 收到的留言 文件名称
    var msgName : String? = ""
    /// 
    var createTime : String? = ""
    /// 用户自定义时间选择（以“;”间隔），可多选。EVERY_MONDAY:每周一,EVERY_TUESDAY:每周二,EVERY_WEDNESDAY:每周三,EVERY_THURSDAY:每周四,EVERY_FRIDAY:每周五,EVERY_SATURDAY:每周六,EVERY_SUNDAY:每周日
    var userDefineTimes : String? = ""
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "user_define_times"{
            guard let datas = value as? [String] else { return }
            for item in datas {
                user_define_times.append(item)
            }
        }else {
            if key == "dayTime"{
                super.setValue(value, forKey: "day_time")
            }else if key == "weakTime"{
                super.setValue(value, forKey: "weak_time")
            }else if key == "leavemsgName"{
                super.setValue(value, forKey: "msgName")
            }else{
                super.setValue(value, forKey: key)
            }
        }
    }
}
