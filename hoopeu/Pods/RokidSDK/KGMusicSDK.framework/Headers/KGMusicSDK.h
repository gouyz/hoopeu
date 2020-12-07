//
//  KGMusicSDK.h
//  KGMusicSDK
//
//  Created by fox on 2018/7/17.
//  Copyright © 2018年 fox. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>
#import "KGMusicSDKCommon.h"

//! Project version number for KGMusicSDK.
FOUNDATION_EXPORT double KGMusicSDKVersionNumber;

//! Project version string for KGMusicSDK.
FOUNDATION_EXPORT const unsigned char KGMusicSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <KGMusicSDK/PublicHeader.h>


@interface KGMusicSDK : NSObject

+ (KGMusicSDK *)sharedInstance;

- (NSString *)version;

/**
 *  app注册
 *
 *  @param appID       申请到的appid
 *  @param appKey      appKey
 *  @param uuid        uuid(用户自己生成/维护)
 *  @param userid      用户id(登录后获取)
 *  @param token       token(登录后获取)
 */
- (void)registerWithAppID:(NSString *)appID
                   appKey:(NSString *)appKey
                     uuid:(NSString *)uuid
                   userid:(NSString *)userid
                    token:(NSString *)token;

//- (void)loginByWx ??

/**
 *  获取图形验证码
 *
 *  @param success       成功的回调，直接返回json字典
 *  @param fail          失败的回调
 */
- (void)requestImgExCode:(successBlock)success
                    fail:(failBlock)fail;


/**
 *  获取手机验证码
 *
 *  @param phoneNum      手机号
 *  @param success       成功的回调，直接返回json字典
 *  @param fail          失败的回调
 */
- (void)requestVerifyCodeWithPhoneNum:(NSString *)phoneNum
                              success:(successBlock)success
                                 fail:(failBlock)fail;

/**
 *  通过账号密码登录
 *
 *  *** 接口暂不开放 ***
 *
 *  @param userName      账号
 *  @param password      密码
 *  @param verifyCode    手机验证码
 *  @param success       成功的回调，直接返回json字典
 *  @param fail          失败的回调
 */
//- (void)loginByUserName:(NSString *)userName
//              password:(NSInteger)password
//            verifyCode:(NSString *)verifyCode
//               success:(successBlock)success
//                  fail:(failBlock)fail;

/**
 *  通过手机号登录
 *
 *  @param moblie        手机号
 *  @param verifyCode    验证码
 *  @param success       成功的回调，直接返回json字典
 *  @param fail          失败的回调
 */
- (void)loginByMobile:(NSString *)moblie
           verifyCode:(NSString *)verifyCode
              success:(successBlock)success
                 fail:(failBlock)fail;

/**
 *  通过token号登录
 *
 *  @param token         token
 *  @param userID        用户ID
 *  @param success       成功的回调，直接返回json字典
 *  @param fail          失败的回调
 */
- (void)loginByToken:(NSString *)token
              userID:(NSString *)userID
             success:(successBlock)success
                fail:(failBlock)fail;

/**
 *  通过手机号注册
 *
 *  @param moblie        手机号
 *  @param verifyCode    验证码
 *  @param success       成功的回调，直接返回json字典
 *  @param fail          失败的回调
 */
- (void)registerUserByMobile:(NSString *)moblie
                  verifyCode:(NSString *)verifyCode
                     success:(successBlock)success
                        fail:(failBlock)fail;

/**
 *  是否音乐包VIP
 *
 *  @param token         token
 *  @param userID        用户ID
 *  @param success       成功的回调，直接返回json字典
 *  @param fail          失败的回调
 */
- (void)checkIsVipWithToken:(NSString *)token
                     userID:(NSString *)userID
                    success:(successBlock)success
                       fail:(failBlock)fail;

/**
 *  获取媒体资源
 *
 *  @param type       要获取的媒体类型 KGMusicMediaType
 *  @param success    成功的回调，直接返回json字典
 *  @param fail       失败的回调
 */
- (void)requestMedia:(KGMusicMediaType)type
             success:(successBlock)success
                fail:(failBlock)fail;

/**
 *  获取热门歌单 - 分页
 *
 *  @param page            页码
 *  @param pageSize        单页记录条数
 *  @param success         成功的回调，直接返回json字典
 *  @param fail            失败的回调
 */
- (void)requestMediaHotSpecialWithPage:(NSInteger)page
                              pageSize:(NSInteger)pageSize
                               success:(successBlock)success
                                  fail:(failBlock)fail;

/**
 *  获取歌单明细
 *
 *  @param specialID       歌单id
 *  @param page            页码
 *  @param pageSize        单页记录条数
 *  @param success         成功的回调，直接返回json字典
 *  @param fail            失败的回调
 */
- (void)requestSpecialDetailWithSpecialID:(NSInteger)specialID
                        page:(NSInteger)page
                    pageSize:(NSInteger)pageSize
                     success:(successBlock)success
                        fail:(failBlock)fail;

/**
 *  获取排行榜明细
 *
 *  @param rankID         排行榜id
 *  @param rankType       排行榜类型
 *  @param page           页码
 *  @param pageSize       单页记录条数
 *  @param success        成功的回调，直接返回json字典
 *  @param fail           失败的回调
 */
- (void)requestRankDetailWithRankID:(NSInteger)rankID
                           rankType:(NSInteger)rankType
                               page:(NSInteger)page
                           pageSize:(NSInteger)pageSize
                            success:(successBlock)success
                               fail:(failBlock)fail;

/**
 *  搜索
 *
 *  @param keyword          搜索关键字
 *  @param searchType       要要搜索的类型 KGMusicSearchType
 *  @param success          成功的回调，直接返回json字典
 *  @param fail             失败的回调
 */
- (void)searchWithKeyword:(NSString *)keyword
               searchType:(KGMusicSearchType)searchType
                  success:(successBlock)success
                     fail:(failBlock)fail;

/**
 *  激活音箱会员
 *
 *  @param devType    支持类型见文档说明
 *  @param success    成功的回调，直接返回json字典
 *  @param fail       失败的回调
 */
- (void)activateprivilegeWithDevType:(NSString *)devType
                             success:(successBlock)success
                                fail:(failBlock)fail;

/**
 *  会员有效期查询
 *
 *  @param success    成功的回调，直接返回json字典
 *  @param fail       失败的回调
 */
- (void)privilegeQueryWithSuccess:(successBlock)success
                             fail:(failBlock)fail;

/**
 *  获取收藏列表
 *  @param listid            列表id
 *  @param type              列表类型
 *  @param page              页码
 *  @param pageSize          单页记录条数
 *  @param success    成功的回调，直接返回json字典
 *  @param fail       失败的回调
 */
- (void)fetchCloudListDetailWithListID:(int)listid
                                  type:(int)type
                                  page:(int)page
                              pageSize:(int)pageSize
                               success:(successBlock)success
                                  fail:(failBlock)fail;

/**
 *  收藏一首歌
 *
 *  @param songName          歌曲名称
 *  @param hash              歌曲hash
 *  @param success    成功的回调，直接返回json字典
 *  @param fail       失败的回调
 */
- (void)collectSongWithSongName:(NSString *)songName
                           hash:(NSString *)hash
                        success:(successBlock)success
                           fail:(failBlock)fail;

/**
 *  取消收藏一首歌
 *
 *  @param hash              歌曲hash
 *  @param success    成功的回调，直接返回json字典
 *  @param fail       失败的回调
 */
- (void)cancelCollectSongWithSongHash:(NSString *)hash
                          success:(successBlock)success
                             fail:(failBlock)fail;

/**
 *  获取排行榜列表明细
 *  @param rankid            列表id
 *  @param rankType          列表类型
 *  @param page              页码
 *  @param pageSize          单页记录条数
 *  @param success    成功的回调，直接返回json字典
 *  @param fail       失败的回调
 */
- (void)fetchRankListDetail:(NSInteger)rankid
                   rankType:(NSInteger)rankType
                       page:(NSInteger)page
                   pageSize:(NSInteger)pageSize
                    success:(successBlock)success
                       fail:(failBlock)fail;

/**
 *  获取歌曲信息
 *
 *  @param hash             歌曲hash
 *  @param success          成功的回调，直接返回json字典
 *  @param fail             失败的回调
 */
- (void)fetchSongInfoWithHash:(NSString *)hash
                      success:(successBlock)success
                         fail:(failBlock)fail;

/**
 *  获取专辑信息
 *
 *  @param albumid          专辑id
 *  @param success          成功的回调，直接返回json字典
 *  @param fail             失败的回调
 */
- (void)fetchAlbumInfoWithAlbumId:(NSInteger)albumid
                          success:(successBlock)success
                             fail:(failBlock)fail;

/**
 仅检测能否单点登录，不会唤起
 
 @param schemes 应用的schemes
 @param appName 应用名称
 @return 返回为 false，即本机未安装 酷狗app，或当前版本 不支持单点登录
 */
- (BOOL)canQuickLogin: (NSString *)schemes
              appName: (NSString *)appName;

/**
 单点登录
 
 @param schemes 应用的schemes
 @param appName 应用名称
 @return 返回为 false，即本机未安装 酷狗app，或当前版本 不支持单点登录
 */
- (BOOL)quickLogin:(NSString *)schemes
           appName:(NSString *)appName;

/**
 通过单点登录返回的token登录

 @param ssoToken ssoToken
 @param success 成功的回调，直接返回json字典
 @param fail 失败的回调
 */
- (void)loginWithSSOToken:(NSString *)ssoToken
                  success:(successBlock)success
                     fail:(failBlock)fail;

/**
 *  获取专辑明细
 *
 *  @param albumid          专辑id
 *  @param page             页码
 *  @param pageSize         单页记录条数
 *  @param success          成功的回调，直接返回json字典
 *  @param fail             失败的回调
 */
- (void)fetchAlbumDetailWithAlbumId:(NSInteger)albumid
                               page:(NSInteger)page
                           pageSize:(NSInteger)pageSize
                            success:(successBlock)success
                               fail:(failBlock)fail;

/**
 *  获取歌词
 *
 *  @param keyword          关键字，如歌曲名称
 *  @param duration         歌曲长度
 *  @param hash             hash
 *  @param success          成功的回调，直接返回json字典
 *  @param fail             失败的回调
 */
- (void)fetchLyricWidthKeyWord:(NSString *)keyword
                      duration:(NSInteger)duration
                          hash:(NSString *)hash
                       success:(successBlock)success
                          fail:(failBlock)fail;

@end
