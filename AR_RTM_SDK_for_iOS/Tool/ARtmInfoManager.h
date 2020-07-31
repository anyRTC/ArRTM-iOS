//
//  ARtmInfoManager.h
//  AR_RTM_SDK_for_iOS
//
//  Created by 余生丶 on 2020/7/16.
//  Copyright © 2020 AR. All rights reserved.
// 单个聊天消息记录

#import <Foundation/Foundation.h>
#import "ARtmMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ARtmInfoManager : NSObject

/** 保存消息 */
+(void)saveMessageWithInfoModel:(ARtmMessageModel *)model;

/** 获取单个peerid 消息 */
+(NSMutableArray *)getMessageUidList:(NSString *)peerId;

/** 删除单个peerid消息 */
+ (void)removeMessageData:(NSString *)peerId;

/** 删除表中所有数据 */
+(void)removeAllObject;

@end

NS_ASSUME_NONNULL_END
