//
//  ARtmViewController.h
//  ARtmKitDemo
//
//  Created by 余生丶 on 2020/6/19.
//  Copyright © 2020 AR. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ARtmType) {
    ARtmTypePeer = 0,
    ARtmTypeGroup = 1,
};

@interface ARtmViewController : UIViewController

@property (nonatomic, assign) ARtmType rtmType;
@property (nonatomic, copy) NSString *acount;

@end

NS_ASSUME_NONNULL_END
