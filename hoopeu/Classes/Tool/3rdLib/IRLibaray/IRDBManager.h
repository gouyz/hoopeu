//
//  IRDBManager.h
//  IRDemo
//
//  Created by wsz on 16/5/12.
//  Copyright © 2016年 wsz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceM.h"

//表名
extern NSString * const kPJTTableName;     //投影仪表名
extern NSString * const kFanTableName;     //风扇表名
extern NSString * const kTVBoxTableName;   //机顶盒表名
extern NSString * const kTVTableName;      //电视表名
extern NSString * const kIPTVTableName;    //iptv表名
extern NSString * const kDVDTableName;     //dvd表名
extern NSString * const kARCTableName;     //空调表名
extern NSString * const kHWaterTableName;  //热水器表名
extern NSString * const kAirTableName;     //空气净化器表名
extern NSString * const kSLRTableName;     //单反表名
extern NSString * const kADOTableName;     //音响表名
extern NSString * const kSWEEPERTableName; //扫地机表名
extern NSString * const kLAMPTableName;    //灯表名

extern NSString * const kArcMatchTableName;//一键匹配表
extern NSString * const kArcLibraryTableName;//一键匹配对应的配合表

extern NSString * const kAdoMatchTableName;
extern NSString * const kAdoLibraryTableName;
extern NSString * const kAirLibraryTableName;
extern NSString * const kDvdMatchTableName;
extern NSString * const kDvdLibraryTableName;
extern NSString * const kFanMatchTableName;
extern NSString * const kFanLibraryTableName;
extern NSString * const kIptvMatchTableName;
extern NSString * const kIptvLibraryTableName;
extern NSString * const kLampMatchTableName;
extern NSString * const kLampLibraryTableName;
extern NSString * const kPjtMatchTableName;
extern NSString * const kPjtLibraryTableName;
extern NSString * const kSlrMatchTableName;
extern NSString * const kSlrLibraryTableName;
extern NSString * const kSweeperMatchTableName;
extern NSString * const kSweeperLibraryTableName;
extern NSString * const kTvboxMatchTableName;
extern NSString * const kTvboxLibraryTableName;
extern NSString * const kTvMatchTableName;
extern NSString * const kTvLibraryTableName;
extern NSString * const kWaterMatchTableName;
extern NSString * const kWaterLibraryTableName;

//字段名
extern NSString * const fSerialFeild;      //索引序号字段（0开始）
extern NSString * const fBrandCNFeild;     //中文品牌字段
extern NSString * const fBrandENFeild;     //英文品牌字段
extern NSString * const fModelFeild;       //型号字段
extern NSString * const fPinYinFeild;      //中文名拼音字段
extern NSString * const fCodeFeild;        //码值字段

@interface IRDBManager : NSObject

+ (IRDBManager *)shareInstance;

//品牌列表
- (NSMutableArray *)getAllBrandByDeviceType:(DeviceType)type;

//型号匹配，获取某个家电中包含具体型号（不为no_model）的所有品牌，并且合并输出
- (NSMutableArray *)getAllBrandContainModelByDeviceType:(DeviceType)type;

//智能匹配
- (NSMutableArray *)getAllNoModelByBrand:(NSString *)brand DeviceType:(DeviceType)type;

//某品牌下所有型号(码库不一定有此品牌的具体型号)
- (NSMutableArray *)getAllModelByBrand:(NSString *)brand DeviceType:(DeviceType)type;

//获取空调的匹配库
- (NSMutableArray *)getAllARCMatchCode;

//从ARC_LIBRARY_TABLE_NAME表中获取一键匹配结果
- (NSData *)getARCCodeByPointedIndex:(NSInteger)index;




//获取非空调的匹配库
- (NSMutableArray *)getAllADOMatchCode;

- (NSData *)getADOCodeByPointedIndex:(NSInteger)index;

- (NSMutableArray *)getAllAIRMatchCode;

- (NSData *)getAIRCodeByPointedIndex:(NSInteger)index;

- (NSMutableArray *)getAllDVDMatchCode;

- (NSData *)getDVDCodeByPointedIndex:(NSInteger)index;

- (NSMutableArray *)getAllFANMatchCode;

- (NSData *)getFANCodeByPointedIndex:(NSInteger)index;

- (NSMutableArray *)getAllIPTVMatchCode;

- (NSData *)getIPTVCodeByPointedIndex:(NSInteger)index;

- (NSMutableArray *)getAllLAMPMatchCode;

- (NSData *)getLAMPCodeByPointedIndex:(NSInteger)index;

- (NSMutableArray *)getAllPJTMatchCode;

- (NSData *)getPJTCodeByPointedIndex:(NSInteger)index;

- (NSMutableArray *)getAllSLRMatchCode;

- (NSData *)getSLRCodeByPointedIndex:(NSInteger)index;

- (NSMutableArray *)getAllSWEEPERMatchCode;

- (NSData *)getSWEEPERCodeByPointedIndex:(NSInteger)index;

- (NSMutableArray *)getAllTVBOXMatchCode;

- (NSData *)getTVBOXCodeByPointedIndex:(NSInteger)index;

- (NSMutableArray *)getAllTVMatchCode;

- (NSData *)getTVCodeByPointedIndex:(NSInteger)index;

- (NSMutableArray *)getAllWATERMatchCode;

- (NSData *)getWATERCodeByPointedIndex:(NSInteger)index;


@end
