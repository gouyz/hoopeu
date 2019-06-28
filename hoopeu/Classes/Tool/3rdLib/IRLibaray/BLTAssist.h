//
//  BLTAssist.h
//  IRBT
//
//  Created by wsz on 16/9/29.
//  Copyright © 2016年 wsz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceM.h"

@interface BLTAssist : NSObject

//码值存取
+ (void)setCode:(NSData *)data device:(DeviceType)device;
+ (NSData *)codeForDevice:(DeviceType)device;

//学习按键存取、清除
+ (void)saveFromClass:(Class)cls tag:(NSInteger)tag code:(NSData *)data;
+ (NSData *)readFromClass:(Class)cls tag:(NSInteger)tag;
+ (void)clearIRStorage:(Class)cls;

//空调一键匹配
int compareMatch(const uint8_t *rev,int revLenth,const uint8_t *loc,int locLenth);

//一般code处理
+ (NSString *)nomarlCode:(NSData *)data key:(NSInteger)tag;

//学习到的数据处理
+ (NSData *)processLearnCode:(NSData *)data;

@end
