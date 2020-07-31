//
//  ARtmMessageModel.m
//  AR_RTM_SDK_for_iOS
//
//  Created by 余生丶 on 2020/6/19.
//  Copyright © 2020 AR. All rights reserved.
//

#import "ARtmMessageModel.h"

@implementation ARtmMessageModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.peerId = [aDecoder decodeObjectForKey:@"peerId"];
        self.uid = [aDecoder decodeObjectForKey:@"uid"];
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.direction = [aDecoder decodeBoolForKey:@"direction"];
        self.num = [aDecoder decodeIntegerForKey:@"num"];
        self.isOfflineMessage = [aDecoder decodeBoolForKey:@"isOfflineMessage"];
        self.state = [aDecoder decodeIntegerForKey:@"state"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.peerId forKey:@"peerId"];
    [aCoder encodeObject:self.uid forKey:@"uid"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeBool:self.direction forKey:@"direction"];
    [aCoder encodeInteger:self.num forKey:@"num"];
    [aCoder encodeBool:self.isOfflineMessage forKey:@"isOfflineMessage"];
    [aCoder encodeInteger:self.state forKey:@"state"];
}

@end
