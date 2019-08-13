//
//  ARCStateCtr.m
//  IRBT
//
//  Created by wsz on 16/10/8.
//  Copyright © 2016年 wsz. All rights reserved.
//

#import "ARCStateCtr.h"

@implementation ARCStateCtr

+ (ARCStateCtr *)shareInstance
{
    static dispatch_once_t once;
    static ARCStateCtr *instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)resetStateWithControlId:(NSString *)controlId
{
    [[NSUserDefaults standardUserDefaults] setInteger:0x19 forKey:[NSString stringWithFormat:@"ctr_temp_%@",controlId]];
    [[NSUserDefaults standardUserDefaults] setInteger:0x01 forKey:[NSString stringWithFormat:@"ctr_volu_%@",controlId]];
    [[NSUserDefaults standardUserDefaults] setInteger:0x02 forKey:[NSString stringWithFormat:@"ctr_manu_%@",controlId]];
    [[NSUserDefaults standardUserDefaults] setInteger:0x01 forKey:[NSString stringWithFormat:@"ctr_auto_%@",controlId]];
    [[NSUserDefaults standardUserDefaults] setInteger:0x02 forKey:[NSString stringWithFormat:@"ctr_mode_%@",controlId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setTemp:(NSInteger)temp withControlId:(NSString *)controlId
{
    [[NSUserDefaults standardUserDefaults] setInteger:temp forKey:[NSString stringWithFormat:@"ctr_temp_%@",controlId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)getTempWithControlId:(NSString *)controlId
{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"ctr_temp_%@",controlId]];
    
    NSInteger k = [number integerValue];
    
    return k==0?0x19:k;
}

- (void)setVolu:(NSInteger)volu withControlId:(NSString *)controlId
{
    [[NSUserDefaults standardUserDefaults] setInteger:volu forKey:[NSString stringWithFormat:@"ctr_volu_%@",controlId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)getVoluWithControlId:(NSString *)controlId
{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"ctr_volu_%@",controlId]];
    NSInteger k = [number integerValue];
    
    return k==0?0x01:k;
}

- (void)setManu:(NSInteger)manu withControlId:(NSString *)controlId
{
    [[NSUserDefaults standardUserDefaults] setInteger:manu forKey:[NSString stringWithFormat:@"ctr_manu_%@",controlId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)getManuWithControlId:(NSString *)controlId
{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"ctr_manu_%@",controlId]];
    NSInteger k = [number integerValue];
    
    return k==0?0x02:k;
}

- (void)setAuto:(NSInteger)autos withControlId:(NSString *)controlId
{
    [[NSUserDefaults standardUserDefaults] setInteger:autos forKey:[NSString stringWithFormat:@"ctr_autos_%@",controlId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)getAutoWithControlId:(NSString *)controlId
{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"ctr_autos_%@",controlId]];
    NSInteger k = [number integerValue];
    
    return k==0?0x01:k;
}

- (void)setMode:(NSInteger)mode withControlId:(NSString *)controlId
{
    [[NSUserDefaults standardUserDefaults] setInteger:mode forKey:[NSString stringWithFormat:@"ctr_mode_%@",controlId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)getModeWithControlId:(NSString *)controlId
{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"ctr_mode_%@",controlId]];
    NSInteger k = [number integerValue];
    
    return k==0?0x02:k;
}

- (void)chageStateByType:(ARCStateType)type withControlId:(NSString *)controlId
{
    if(type==ARCStateTypeTmpAdd)
    {
        NSInteger tem = [self getTempWithControlId:controlId];
        tem++;
        if(tem<=0x1E&&tem>=0x13)
        {
            [self setTemp:tem withControlId:controlId];
        }

    }
    else if(type==ARCStateTypeTmpRdu)
    {
        NSInteger tem = [self getTempWithControlId:controlId];
        tem--;
        if(tem<=0x1E&&tem>=0x13)
        {
            [self setTemp:tem withControlId:controlId];
        }
    }
    else if(type==ARCStateTypeVle)
    {
        NSInteger vol = [self getVoluWithControlId:controlId];
        vol++;
        if(vol>0x04)
        {
            vol = 0x01;
        }
        [self setVolu:vol withControlId:controlId];
    }
    else if(type==ARCStateTypeMnl)
    {
        NSInteger man = [self getManuWithControlId:controlId];
        man++;
        if(man>0x03)
        {
            man = 0x01;
        }
        [self setManu:man withControlId:controlId];
    }
    else if(type==ARCStateTypeAto)
    {
        NSInteger aot = [self getAutoWithControlId:controlId];
        aot++;
        if(aot>0x01)
        {
            aot=0x00;
        }
        [self setAuto:aot withControlId:controlId];
    }
    else if(type==ARCStateTypeMod)
    {
        NSInteger mod = [self getModeWithControlId:controlId];
        mod++;
        if(mod>0x05)
        {
            mod = 0x01;
        }
        [self setMode:mod withControlId:controlId];
    }
}

/* 7B0: 其中第0个字节：数据为对应空调的温度：19－30度(0x14-0x1F),默认：25度;十六进制,与显示对应,通过温度加减键调节 */
/* 7B1:其中第1个字节：风量数据：自动：01,低：02,中：03,高：04,与显示对应：默认：01,相关显示符号参考样机） */
/* 7B2:其中第2个字节：手动风向：向下：03,中：02,向上：01,默认02,与显示对应; */
/* 7B3:其中第3个字节：自动风向：01,打开,00,关,默认开:01,与显示对应 */
/* 7B4:其中第4个字节：开关数据：开机时：0x01,关机时：0x00,通过按开关机（电源）键实现,开机后,其它键才有效,相关符号才显示) */
/* 7B5:其中第5个字节：键名对应数据,电源：0x01,模式：0x02,风量：0x03,手动风向：0x04, */
/*       自动风向：0x05,温度加：0x06,  温度减：0x07, // 表示当前按下的是哪个键 */
/* 7B6:其中第6个字节：模式对应数据和显示：自动（默认）：0x01,制冷：0X02,抽湿：0X03,送风：0x04;制热：0x05,这些值按模式键实现 */

- (NSData *)get7B_DataWithTag:(NSInteger)tag withControlId:(NSString *)controlId
{
    NSInteger keyValue = 0x0;
    if(tag==0x77||tag==0x88)//开、关
    {
        keyValue = 0x01;
    }
    else
    {
        keyValue = tag;
        if(tag==0x02)
        {
            [self chageStateByType:ARCStateTypeMod withControlId:controlId];
        }
        else if(tag==0x03)
        {
            [self chageStateByType:ARCStateTypeVle withControlId:controlId];
        }
        else if(tag==0x04)
        {
            [self chageStateByType:ARCStateTypeMnl withControlId:controlId];
        }
        else if(tag==0x05)
        {
            [self chageStateByType:ARCStateTypeAto withControlId:controlId];
        }
        else if(tag==0x06)
        {
            [self chageStateByType:ARCStateTypeTmpAdd withControlId:controlId];
        }
        else if(tag==0x07)
        {
            [self chageStateByType:ARCStateTypeTmpRdu withControlId:controlId];
        }
    }
    
    NSMutableData *data = [NSMutableData new];
    
    NSInteger _temperature = [self getTempWithControlId:controlId];
    [data appendData:[NSData dataWithBytes:&_temperature length:1]]; //7B0
    
    NSInteger _volume = [self getVoluWithControlId:controlId];
    [data appendData:[NSData dataWithBytes:&_volume length:1]];      //7B1
    
    NSInteger _manual = [self getManuWithControlId:controlId];
    [data appendData:[NSData dataWithBytes:&_manual length:1]];      //7B2
    
    NSInteger _autos = [self getAutoWithControlId:controlId];
    [data appendData:[NSData dataWithBytes:&_autos length:1]];       //7B3
    
    int switchState = 0x01;
    if(tag==0x88)
    {
        switchState = 0x00;
    }
    [data appendData:[NSData dataWithBytes:&switchState length:1]];       //7B4
    [data appendData:[NSData dataWithBytes:&keyValue length:1]];          //7B5
    
    NSInteger _mode = [self getModeWithControlId:controlId];
    [data appendData:[NSData dataWithBytes:&_mode length:1]];             //7B6
    
    return data;
}

//空调按键红外码数据组装 base64加密为字符串
/**
 空调按键红外码数据组装 base64加密为字符串

 @param data 遥控器红外码
 @param tag 按键tag
 @return base64加密为字符串
 */
- (NSString *)getARCKeyCode:(NSData *)data withTag:(NSInteger)tag withControlId:(NSString *)controlId
{
    //head
    NSMutableData *muti = [NSMutableData new];
    uint8_t h[] = {0x30,0x01};
    [muti appendBytes:h length:2];
    
    //2B
    [muti appendData:[data subdataWithRange:NSMakeRange(0, 2)]];
    
    //7B
    [muti appendData:[self get7B_DataWithTag:tag withControlId:controlId]];
    
    //1B
    [muti appendData:[data subdataWithRange:NSMakeRange(9, 1)]];
    
    //arc_table+0xFF
    [muti appendData:[data subdataWithRange:NSMakeRange(10, data.length-10)]];
    
    //校验位
    
    uint8_t j = 0;
    for(int i=0;i<muti.length;i++)
    {
        uint8_t tmp = 0;
        [muti getBytes:&tmp range:NSMakeRange(i, 1)];
        j+=tmp;
    }
    [muti appendBytes:&j length:1];
    
    //tail
    uint8_t a[] = {0x56,0x78};
    [muti appendBytes:a length:2];
    NSLog(@"print ARC %@ !",muti);
    return [muti base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

// NSData转16进制 第一种
//- (NSString *)convertDataToHexStr:(NSData *)data
//{
//    if (!data || [data length] == 0) {
//        return @"";
//    }
//    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
//
//    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
//        unsigned char *dataBytes = (unsigned char*)bytes;
//        for (NSInteger i = 0; i < byteRange.length; i++) {
//            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
//            if ([hexStr length] == 2) {
//                [string appendString:hexStr];
//            } else {
//                [string appendFormat:@"0%@", hexStr];
//            }
//        }
//    }];
//    return string;
//}
@end
