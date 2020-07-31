//
//  ARtmHistoryManager.h
//  AR_RTM_SDK_for_iOS
//
//  Created by 余生丶 on 2020/7/16.
//  Copyright © 2020 AR. All rights reserved.
// 消息记录

#import <Foundation/Foundation.h>
#import "ARtmMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ARtmHistoryManager : NSObject

/** 保存离线消息 */
+(void)saveHistoryWithMainModel:(ARtmMessageModel *)model;

/** 更新历史消息  */
+(void)updateHistoyModel:(ARtmMessageModel *)model;

/** 获取peerId数据 */
+(ARtmMessageModel *)geHistoryList:(NSString *)peerId;

/** 获取数据库数据 */
+(NSMutableArray *)getAllHistoryList;

/** 删除历史消息 */
+ (void)removeHistoryData:(NSString *)peerId;

/** 删除表中所有数据 */
+(void)removeAllObject;

@end

NS_ASSUME_NONNULL_END
