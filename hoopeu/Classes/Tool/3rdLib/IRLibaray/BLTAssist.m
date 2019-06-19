//
//  BLTAssist.m
//  IRBT
//
//  Created by wsz on 16/9/29.
//  Copyright © 2016年 wsz. All rights reserved.
//

#import "BLTAssist.h"

@implementation BLTAssist

#pragma mark -
#pragma mark -

+ (void)setCode:(NSData *)data device:(DeviceType)device
{
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:[NSString stringWithFormat:@"device_%ld",(long)device]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSData *)codeForDevice:(DeviceType)device
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"device_%ld",(long)device]];
}

#pragma mark -
#pragma mark -

+ (void)saveFromClass:(Class)cls tag:(NSInteger)tag code:(NSData *)data
{
    NSString *rootPath = [BLTAssist storageRootPath];
    NSString *abPath = [rootPath stringByAppendingPathComponent:NSStringFromClass(cls)];

    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:abPath];
    if(!dic)
    {
        dic = [NSMutableDictionary new];
    }
    NSString *key = [NSString stringWithFormat:@"%ld",(long)tag];
    [dic setValue:data forKey:key];
    [dic writeToFile:abPath atomically:YES];    
}

+ (NSData *)readFromClass:(Class)cls tag:(NSInteger)tag
{
    NSString *rootPath = [BLTAssist storageRootPath];
    NSString *abPath = [rootPath stringByAppendingPathComponent:NSStringFromClass(cls)];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:abPath];
    
    NSString *key = [NSString stringWithFormat:@"%ld",(long)tag];
    if([[dic allKeys] containsObject:key])
    {
        return dic[key];
    }
    return nil;
}

+ (void)clearIRStorage:(Class)cls
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *rootPath = [BLTAssist storageRootPath];
    NSString *abPath = [rootPath stringByAppendingPathComponent:NSStringFromClass(cls)];
    BOOL bRet = [fileMgr fileExistsAtPath:abPath];
    if (bRet)
    {
        [fileMgr removeItemAtPath:abPath error:NULL];
    }
}

+ (NSString *)storageRootPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                NSUserDomainMask, YES) objectAtIndex:0];
}

#pragma mark -
#pragma mark -

+ (NSData *)nomarlCode:(NSData *)data key:(NSInteger)tag
{
    NSMutableData *muti = [NSMutableData new];
    NSData *head = [data subdataWithRange:NSMakeRange(0, 1)];
    NSData *body = [data subdataWithRange:NSMakeRange(tag, 2)];
    NSData *tail = [data subdataWithRange:NSMakeRange(data.length-4, 4)];
    [muti appendData:head];
    [muti appendData:body];
    [muti appendData:tail];
    return muti;
}

+ (NSData *)processLearnCode:(NSData *)data
{
    if(![data length])return nil;;
    uint8_t ir_buf[230];
    
    [data getBytes:ir_buf length:230];
    
    unsigned char ck = 0x0;
    unsigned char buf_232[232];
    memset(buf_232, 0, 232);
    
    int i;
    buf_232[0] = 0x30;
    ck += buf_232[0];
    buf_232[1] = 0x03;
    ck += buf_232[1];
    for (i = 1; i < 230; i++){
        buf_232[i + 1] = ir_buf[i];
        ck += ir_buf[i];
    }
    buf_232[231] = ck;
    NSData *dataTmp = [NSData dataWithBytes:buf_232 length:232];
    NSMutableData *mData = [NSMutableData dataWithData:dataTmp];
    return mData;
}

#pragma mark -
#pragma mark -

//均以接收数据为准
int compareMatch(const uint8_t *rev,int revLenth,const uint8_t *loc,int locLenth)
{
//    if(revLenth!=230||locLenth!=230)
//    {
//        printf("数据长度不对\n");
//        return 0;
//    }
//    
//    int rffhead,rfHead;
//    int lffhead,lfHead;
//    
//    if(!locateCompareFlag(rev,revLenth,&rffhead,&rfHead))
//    {
//        printf("收到数据定位flag错误\n");
//        return 0;
//    }
//    
//    if(!locateCompareFlag(loc,locLenth,&lffhead,&lfHead))
//    {
//        printf("本地数据定位flag错误\n");
//        return 0;
//    }
//    
//    if(rffhead!=lffhead)
//    {
//        printf("ffhead位置不同\n");
//        return 0;
//    }
//    
//    if(rfHead!=lfHead)
//    {
//        printf("fhead位置不同\n");
//        return 0;
//    }
//    
//    //1、首先前4字节必须全部相同
//    for(int i=0;i<4;i++)
//    {
//        if(*(rev+i)!=*(loc+i))
//        {
//            printf("前4字节不相同\n");
//            return 0;
//        }
//    }
//    
//    int sameSum = 0;
//    //2、第5字节到rffhead之前 相差10%以内算相同
//    for(int i=4;i<rffhead;i++)
//    {
//        uint8_t revValue = *(rev+i);
//        uint8_t locValue = *(loc+i);
//        if(revValue==0x0)
//        {
//            if(locValue==0x0)sameSum++;
//        }
//        else
//        {
//            float k = abs(revValue-locValue)/(float)revValue;
//            if(k<=0.1)
//            {
//                sameSum++;
//            }
//        }
//    }
//    
//    //3、首个0xff（包括）到0x?f／0xf? 之间完全相同才算相同
//    
//    uint8_t *rp = (uint8_t *)(rev+rffhead);
//    uint8_t *lp = (uint8_t *)(loc+lffhead);
//    
//    for(int i=0;i<rfHead-rffhead;i++)
//    {
//        if(*(rp+i)==*(lp+i))sameSum++;
//    }
//    return sameSum;
    
    BOOL isWanQuan = NO;
    BOOL isJump = NO;
    int m = 0;
    for (int i = 0; i < 230; i++)
    {
        if (i < 4)
        {
            if(*(rev+i)==*(loc+i))
            {
                m++;
                continue;
            }
            else
            {
                m = 0;
                break;
            }
        }
        if (m < 4)
        {
            break;
        }
        if (*(loc+i) == 0xFF)
        {
            isWanQuan = true;
        }
        
        if ((*(loc+i) & 0x0F) == 0x0F || (*(loc+i) & 0xF0) == 0xF0)
        {
            if (isJump && isWanQuan)
            {
                break;
            }
        }
        if (isWanQuan)
        {
            if (*(rev+i) == *(loc+i))
            {
                m++;
            }
            
            if (*(loc+i) < 240 && (*(loc+i) % 16) != 0x0F)
            {
                isJump = true;
            }
        }
        else
        {
            int dif = (int)(*(rev+i) * 0.1f);
            int min = *(rev+i) - dif;
            int max = *(rev+i) + dif;
            if (min <= *(loc+i) && max >= *(loc+i))
            {
                m++;
            }
        }
    }
    return m;
}

//bool locateCompareFlag(const uint8_t *dat,int datLenth,int *ffHead,int *fHead)
//{
//    for(int i=4;i<datLenth;i++)
//    {
//        if(*(dat+i)==0xff)
//        {
//            for(int j=i;j<datLenth;j++)
//            {
//                if((*(dat+j)&0xf0)!=0xf0)
//                {
//                    if(j>i)
//                    {
//                        for(int k=j+1;k<datLenth;k++)
//                        {
//                            if((*(dat+k)&0x0f)==0x0f||(*(dat+k)&0xf0)==0xf0)
//                            {
//                                if(k>=j)
//                                {
//                                    *ffHead = i;
//                                    *fHead = k;
//                                    return true;
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//    return false;
//}

@end
