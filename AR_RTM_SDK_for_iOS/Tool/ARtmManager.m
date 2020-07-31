//
//  ARtmManager.m
//  AR_RTM_SDK_for_iOS
//
//  Created by 余生丶 on 2020/6/19.
//  Copyright © 2020 AR. All rights reserved.
//

#import "ARtmManager.h"

static ARtmKit *rtmKit_ = nil;
static NSString *localUid = nil;
static NSMutableDictionary *offlineDic = nil;

@implementation ARtmManager

+ (void)load {
    rtmKit_ = [[ARtmKit alloc] initWithAppId:appId delegate:nil];
    offlineDic = [NSMutableDictionary dictionary];
}

+ (ARtmKit * _Nullable)rtmKit {
    return rtmKit_;
}

+ (void)setLocalUid:(NSString *)uid {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    localUid = uid;
    if (uid.length != 0) {
        [userDefault setObject:uid forKey:@"localUid"];
    } else {
        [userDefault removeObjectForKey:@"localUid"];
    }
    [userDefault synchronize];
}

+ (NSString *)getLocalUid {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    localUid = [userDefault objectForKey:@"localUid"];
    return localUid;
}

+ (void)addOfflineMessage:(ARtmMessage * _Nonnull)message fromUser:(NSString * _Nonnull)uid {
    if (message.isOfflineMessage) {
        NSMutableArray *infoArr = nil;
        if (offlineDic[uid]) {
            infoArr = offlineDic[uid];
        } else {
            infoArr = [NSMutableArray array];
        }
        
        [infoArr addObject:message];
        
        if (!offlineDic[uid]) {
            offlineDic[uid] = infoArr;
        }
    }
}

@end
