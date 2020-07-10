//
//  ARtmMessageCell.h
//  ARtmKitDemo
//
//  Created by 余生丶 on 2020/6/19.
//  Copyright © 2020 AR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARtmMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ARtmMessageCell : UITableViewCell

@property (nonatomic, strong) ARtmMessageModel *messageModel;

@end

NS_ASSUME_NONNULL_END
