//
//  ARtmManager.m
//  ARtmKitDemo
//
//  Created by 余生丶 on 2020/6/19.
//  Copyright © 2020 AR. All rights reserved.
//

#import "ARtmManager.h"

static ARtmKit *rtmKit_ = nil;
static NSString *localUid = nil;

@implementation ARtmManager

+ (void)load {
    rtmKit_ = [[ARtmKit alloc] initWithAppId:appId delegate:nil];
}

+ (ARtmKit * _Nullable)rtmKit {
    return rtmKit_;
}

+ (void)setLocalUid:(NSString *)uid {
    localUid = uid;
}

+ (NSString *)getLocalUid {
    return localUid;
}

@end
