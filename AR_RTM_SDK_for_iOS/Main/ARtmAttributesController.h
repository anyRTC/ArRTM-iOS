//
//  ARtmAttributesController.h
//  AR_RTM_SDK_for_iOS
//
//  Created by 余生丶 on 2020/7/16.
//  Copyright © 2020 AR. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ARtmAttributesType) {
    /** 个人属性 */
    ARtmAttributesTypeLocalUser = 0,
    /** 其它用户属性 */
    ARtmAttributesTypeRemoteUser = 1,
    /** 频道属性 */
    ARtmAttributesTypeChannel = 2
};

@interface ARtmAttributesController : UITableViewController

@property (nonatomic, copy) NSString * account;
@property (nonatomic, assign) ARtmAttributesType attributeType;

@end

NS_ASSUME_NONNULL_END
