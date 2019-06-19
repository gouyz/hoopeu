//
//  ARCStateCtr.h
//  IRBT
//
//  Created by wsz on 16/10/8.
//  Copyright © 2016年 wsz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,ARCStateType) {
    ARCStateTypeTmpAdd, //温度＋
    ARCStateTypeTmpRdu, //温度－
    ARCStateTypeVle,    //风量
    ARCStateTypeMnl,    //手动
    ARCStateTypeAto,    //自动
    ARCStateTypeMod     //模式
};

@interface ARCStateCtr : NSObject

@property (nonatomic,assign)BOOL powerOn;

+ (instancetype)shareInstance;

//重置状态
- (void)resetState;

- (NSInteger)getTemp;
- (NSInteger)getVolu;
- (NSInteger)getManu;
- (NSInteger)getAuto;
- (NSInteger)getMode;


//空调7B数据组装
- (NSData *)get7B_DataWithTag:(NSInteger)tag;
//空调按键红外码数据组装 base64加密为字符串
- (NSString *)getARCKeyCode:(NSData *)data withTag:(NSInteger)tag;

@end
