//
//  KGMusicSDKCommon.h
//  KGMusicSDK
//
//  Created by fox on 2018/7/17.
//  Copyright © 2018年 fox. All rights reserved.
//

#ifndef KGMusicSDKCommon_h
#define KGMusicSDKCommon_h

typedef enum {
    KGMusicMediaTypeRecommendFM = 1         //精选电台
    ,KGMusicMediaTypeHotSpecial             //热门歌单
    ,KGMusicMediaTypeSpecialDetail          //歌单明细
    ,KGMusicMediaTypeRank                   //排行榜
    ,KGMusicMediaTypeDailyRecommend         //每日推荐
    ,KGMusicMediaTypeCloudList              //收藏列表
} KGMusicMediaType;

typedef enum {
    KGMusicSearchTypeSingleSong = 1         //单曲
    ,KGMusicSearchTypeAlbum                 //专辑
    ,KGMusicSearchTypeSpecial               //歌单
    ,KGMusicSearchTypeLyrics                //歌词
} KGMusicSearchType;

typedef void (^successBlock) (NSDictionary *respDict);
typedef void (^failBlock)(NSError *error);

#endif /* KGMusicSDKCommon_h */
