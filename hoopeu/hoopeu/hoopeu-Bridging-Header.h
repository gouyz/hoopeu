//
//  hoopeu-Bridging-Header.h
//  hoopeu
//  桥接文件
//  Created by gouyz on 2019/1/3.
//  Copyright © 2019 gyz. All rights reserved.
//

#import <UIKit/UIKit.h>

/// OC工具类 验证银行卡等
#import "GYZCheckTool.h"
/// 数据库
#import "FMDB/FMDB.h"
/// 红外设备
#import "Device.h"
#import "IRDBManager.h"
#import "BLTAssist.h"
#import "ARCStateCtr.h"

/// 多标签选择
#import "HXTagsView.h"
#import "HXTagAttribute.h"
#import "HXTagCollectionViewFlowLayout.h"

/// 进度条
#import "SYLineProgressView.h"
#import "SYRingProgressView.h"

#import "ZFIJKPlayerManager.h"

/// 极光推送相关头文件
// 引入JPush功能所需头文件
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
