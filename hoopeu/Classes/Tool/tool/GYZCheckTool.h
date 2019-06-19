//
//  GYZCheckTool.h
//  pureworks
// OC 验证银行卡等
//  Created by gouyz on 2018/6/28.
//  Copyright © 2018年 gyz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GYZCheckTool : NSObject

+ (BOOL) IsBankCard:(NSString *)cardNumber;
@end
