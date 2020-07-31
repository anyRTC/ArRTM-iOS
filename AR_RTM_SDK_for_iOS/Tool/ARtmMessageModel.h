//
//  ARtmMessageModel.h
//  AR_RTM_SDK_for_iOS
//
//  Created by 余生丶 on 2020/6/19.
//  Copyright © 2020 AR. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ARtmMessageModel : NSObject<NSCoding>

@property (nonatomic, copy) NSString * peerId;
@property (nonatomic, copy) NSString * uid;
@property (nonatomic, copy) NSString * content;
@property (nonatomic, assign) BOOL direction;
@property (nonatomic, assign) NSInteger num;
@property (nonatomic, assign) BOOL isOfflineMessage;
@property (nonatomic, assign) ARtmPeerOnlineState state;

@end

NS_ASSUME_NONNULL_END
