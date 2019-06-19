//
//  DeviceM.h
//  IRDemo
//
//  Created by wsz on 16/5/12.
//  Copyright © 2016年 wsz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,DeviceType)
{
    DeviceTypePJT = 0,      //投影仪
    DeviceTypeFan,          //风扇
    DeviceTypeTVBox,        //机顶盒
    DeviceTypeTV,           //电视
    DeviceTypeIPTV,         //网络电视
    DeviceTypeDVD,          //DVD
    DeviceTypeARC,          //空调
    DeviceTypeWheater,      //热水器
    DeviceTypeAir,          //空气净化器
    DeviceTypeSLR,          //单反
};

@interface DeviceM : NSObject

@property (nonatomic,assign) DeviceType type;   //设备类型
@property (nonatomic,assign) NSInteger serial;  //对应db序号
@property (nonatomic,copy)   NSString *brandCN; //中文品牌
@property (nonatomic,copy)   NSString *brandEN; //英文品牌
@property (nonatomic,copy)   NSString *model;   //型号（如果没有具体型号则均为 no_model）
@property (nonatomic,strong) NSData *code;      //红外码值

@end
