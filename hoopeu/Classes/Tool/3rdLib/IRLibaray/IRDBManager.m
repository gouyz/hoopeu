//
//  IRDBManager.m
//  IRDemo
//
//  Created by wsz on 16/5/12.
//  Copyright © 2016年 wsz. All rights reserved.
//

#import "IRDBManager.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMDatabaseAdditions.h"

NSString * const kPJTTableName  = @"PJT_TABLE";
NSString * const kFanTableName  = @"FAN_TABLE";
NSString * const kTVBoxTableName    = @"TVBOX_TABLE";
NSString * const kTVTableName   = @"TV_TABLE";
NSString * const kIPTVTableName = @"IPTV_TABLE";
NSString * const kDVDTableName  = @"DVD_TABLE";
NSString * const kARCTableName  = @"ARC_TABLE";
NSString * const kHWaterTableName   = @"WATER_TABLE";
NSString * const kAirTableName  = @"AIR_TABLE";
NSString * const kSLRTableName  = @"SLR_TABLE";
NSString * const kArcMatchTableName = @"ARC_MATCH_TABLE";
NSString * const kArcLibraryTableName = @"ARC_LIBRARY_TABLE_NAME";

NSString * const fSerialFeild = @"SERIAL";
NSString * const fBrandCNFeild = @"BRAND_CN";
NSString * const fBrandENFeild = @"BRAND_EN";
NSString * const fModelFeild = @"MODEL";
NSString * const fPinYinFeild = @"PINYIN";
NSString * const fCodeFeild = @"CODE";

@interface IRDBManager ()

@property(nonatomic,retain) FMDatabaseQueue * dbQueue;

@end

@implementation IRDBManager

+ (IRDBManager *)shareInstance
{
    static dispatch_once_t once;
    static IRDBManager *instance;
    dispatch_once(&once, ^ {
        instance = [[self alloc] init];
        
        instance.dbQueue = [FMDatabaseQueue databaseQueueWithPath:[[NSBundle mainBundle] pathForResource:@"IRLibaray.db" ofType:nil]];
    });
    return instance;
}

- (NSString *)deviceTypeConvert2TableName:(DeviceType)type
{
    if(type==DeviceTypePJT)return kPJTTableName;
    else if(type==DeviceTypeFan)return kFanTableName;
    else if(type==DeviceTypeTVBox)return kTVBoxTableName;
    else if(type==DeviceTypeTV)return kTVTableName;
    else if(type==DeviceTypeIPTV)return kIPTVTableName;
    else if(type==DeviceTypeDVD)return kDVDTableName;
    else if(type==DeviceTypeARC)return kARCTableName;
    else if(type==DeviceTypeWheater)return kHWaterTableName;
    else if(type==DeviceTypeAir)return kAirTableName;
    else if(type==DeviceTypeSLR)return kSLRTableName;
    else return nil;
}

- (NSMutableArray *)getAllBrandByDeviceType:(DeviceType)type
{
    __block NSMutableArray * array = [NSMutableArray new];
    
    NSString *tableName = [self deviceTypeConvert2TableName:type];
    if(![tableName length])return nil;
    
//    NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ GROUP BY %@;",fBrandCNFeild,tableName,fPinYinFeild];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ GROUP BY %@;",tableName,fPinYinFeild];
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         if (![db open])
         {
             [db close];
             return;
         }
         FMResultSet * rs= [db executeQuery:sql];
         while ([rs next])
         {
//             [array addObject:[rs stringForColumn:fBrandCNFeild]];
             [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:[rs stringForColumn:fBrandCNFeild],@"brand",[rs stringForColumn:fPinYinFeild], @"pinyin", nil]];
         }
         [rs close];
     }];
    return array;
}

- (NSMutableArray *)getAllBrandContainModelByDeviceType:(DeviceType)type
{
    __block NSMutableArray * array = [NSMutableArray new];
    
    NSString *tableName = [self deviceTypeConvert2TableName:type];
    if(![tableName length])return nil;
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ GROUP BY %@;",tableName,fPinYinFeild];
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         if (![db open])
         {
             [db close];
             return;
         }
         FMResultSet * rs= [db executeQuery:sql];
         while ([rs next])
         {
             if([[rs stringForColumn:fModelFeild] isEqualToString:@"no_model"])
                 continue;
             else
                 [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:[rs stringForColumn:fBrandCNFeild],@"brand",[rs stringForColumn:fPinYinFeild], @"pinyin", nil]];
         }
         [rs close];
     }];
    return array;
}

- (NSMutableArray *)getAllModelByBrand:(NSString *)brand DeviceType:(DeviceType)type
{
    NSString *tableName = [self deviceTypeConvert2TableName:type];
    if(!brand.length||!tableName.length)return nil;
    
    __block NSMutableArray * array = [NSMutableArray new];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE BRAND_CN = ? AND MODEL != ? ",tableName];
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         if (![db open])
         {
             [db close];
             return;
         }
         FMResultSet * rs= [db executeQuery:sql,brand,@"no_model"];
         while ([rs next])
         {
             DeviceM * device = [[DeviceM alloc] init];
             device.type = type;
             device.serial = [rs intForColumn:fSerialFeild];
             device.brandCN = [rs stringForColumn:fBrandCNFeild];
             device.brandEN = [rs stringForColumn:fBrandENFeild];
             device.model = [rs stringForColumn:fModelFeild];
             device.code = [rs dataForColumn:fCodeFeild];
             [array addObject:device];
         }
         [rs close];
     }];
    return array;
}

//智能匹配
- (NSMutableArray *)getAllNoModelByBrand:(NSString *)brand DeviceType:(DeviceType)type;
{
    NSString *tableName = [self deviceTypeConvert2TableName:type];
    if(!brand.length||!tableName.length)return nil;
    
    __block NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE BRAND_CN = ? AND MODEL = ?",tableName];
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         if (![db open])
         {
             [db close];
             return;
         }
         FMResultSet * rs= [db executeQuery:sql,brand,@"no_model"];
         while ([rs next])
         {
             DeviceM * device = [[DeviceM alloc] init];
             device.type = type;
             device.serial = [rs intForColumn:fSerialFeild];
             device.brandCN = [rs stringForColumn:fBrandCNFeild];
             device.brandEN = [rs stringForColumn:fBrandENFeild];
             device.model = [rs stringForColumn:fModelFeild];
             device.code = [rs dataForColumn:fCodeFeild];
             [array addObject:device];
         }
         [rs close];
     }];
    return array;
}


- (NSMutableArray *)getAllARCMatchCode
{
    __block NSMutableArray * array = [NSMutableArray new];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@;",kArcMatchTableName];
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         if (![db open])
         {
             [db close];
             return;
         }
         FMResultSet * rs= [db executeQuery:sql];
         while ([rs next])
         {
             [array addObject:[rs dataForColumn:fCodeFeild]];
         }
         [rs close];
     }];
    return array;
}

/*/----------------------------wjs----------------------------后加
- (NSMutableArray *)getAllARCMatchindex
{
    __block NSMutableArray * wjsarray = [NSMutableArray new];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@;",kArcMatchTableName];
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         if (![db open])
         {
             [db close];
             return;
         }
         FMResultSet * rs= [db executeQuery:sql];
         while ([rs next])
         {
             [wjsarray addObject:[rs dataForColumn:fSerialFeild]];
         }
         [rs close];
     }];
    return wjsarray;
}


- (NSData *)getARCCodeBywjsIndex:(NSInteger)index
{
    __block NSData *wjsdata;
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE SERIAL = ?",kArcMatchTableName];
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         if (![db open])
         {
             [db close];
             return;
         }
         FMResultSet * rs= [db executeQuery:sql,[NSNumber numberWithInteger:index]];
         while ([rs next])
         {
             wjsdata = [rs dataForColumn:fSerialFeild];
         }
         [rs close];
     }];
    return wjsdata;
}


//----------------------------wjs---------------------------


*/







- (NSData *)getARCCodeByPointedIndex:(NSInteger)index
{
    __block NSData *data;
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE SERIAL = ?",kArcLibraryTableName];
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         if (![db open])
         {
             [db close];
             return;
         }
         FMResultSet * rs= [db executeQuery:sql,[NSNumber numberWithInteger:index]];
         while ([rs next])
         {
             data = [rs dataForColumn:fCodeFeild];
         }
         [rs close];
     }];
    return data;
}






@end
