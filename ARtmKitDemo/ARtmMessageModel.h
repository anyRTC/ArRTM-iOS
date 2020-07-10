//
//  ARtmMessageModel.h
//  ARtmKitDemo
//
//  Created by 余生丶 on 2020/6/19.
//  Copyright © 2020 AR. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ARtmMessageModel : NSObject

@property (nonatomic, copy) NSString * uid;
@property (nonatomic, copy) NSString * content;
@property (nonatomic, copy) NSString * userName;
@property (nonatomic, assign) BOOL direction;

@end

NS_ASSUME_NONNULL_END
