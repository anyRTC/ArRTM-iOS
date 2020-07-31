//
//  ARtmInfoCell.m
//  AR_RTM_SDK_for_iOS
//
//  Created by 余生丶 on 2020/7/16.
//  Copyright © 2020 AR. All rights reserved.
//

#import "ARtmInfoCell.h"

@implementation ARtmInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessageModel:(ARtmMessageModel *)messageModel {
    _messageModel = messageModel;
    self.uidLabel.text = messageModel.peerId;
    self.infoLabel.text = messageModel.content;
    if (messageModel.state == ARtmPeerOnlineStateOnline) {
        self.stateLabel.backgroundColor = [UIColor greenColor];
    } else {
        self.stateLabel.backgroundColor = [UIColor lightGrayColor];
    }
    
    self.numLabel.hidden = !messageModel.num;
    if (messageModel.num != 0) {
        self.numLabel.text = [NSString stringWithFormat:@"%ld",(long)messageModel.num];
    }
}

@end
