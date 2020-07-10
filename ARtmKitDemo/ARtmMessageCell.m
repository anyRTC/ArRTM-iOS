//
//  ARtmMessageCell.m
//  ARtmKitDemo
//
//  Created by 余生丶 on 2020/6/19.
//  Copyright © 2020 AR. All rights reserved.
//

#import "ARtmMessageCell.h"

@implementation ARtmMessageCell{
    UIImageView *_iconImageView; //头像
    UILabel *_infoLabel;       //消息
    UIView *_containerView;   //消息容器
    UILabel *_nameLabel;      //名字
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = RGBA(242,244,246, 1);
        [self initializeMessage];
    }
    return self;
}

- (void)initializeMessage{
    _iconImageView = [[UIImageView alloc]init];
    _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    _iconImageView.image = [UIImage imageNamed:@"icon_head"];
    _iconImageView.layer.masksToBounds = YES;
    _iconImageView.layer.cornerRadius = 20;
    [self.contentView addSubview:_iconImageView];
    
    _nameLabel = [[UILabel alloc]init];
    _nameLabel.font = [UIFont systemFontOfSize:8];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_nameLabel];
    
    _containerView = [[UIView alloc]init];
    _containerView.backgroundColor = [UIColor whiteColor];
    _containerView.layer.cornerRadius = 5;
    _containerView.clipsToBounds = YES;
    [self.contentView addSubview:_containerView];
    
    _infoLabel = [[UILabel alloc]init];
    _infoLabel.numberOfLines = 0;
    _infoLabel.font = [UIFont systemFontOfSize:14];
    [_containerView addSubview:_infoLabel];
}

- (void)setMessageModel:(ARtmMessageModel *)messageModel {
    _messageModel = messageModel;
    CGFloat messageX = CGRectGetWidth(UIScreen.mainScreen.bounds)/2.0;
    _nameLabel.text = messageModel.userName;
    //富文本
    CGFloat lineSpace = 3.0;
    NSNumber *textLengthSpace  = @0.25;
    NSDictionary *attribute = [self setTextLineSpaceWithString:messageModel.content withFont:[UIFont systemFontOfSize:14] withLineSpace:lineSpace  withTextlengthSpace:textLengthSpace paragraphSpacing:0];
    _infoLabel.attributedText = [[NSAttributedString alloc] initWithString:messageModel.content attributes:attribute];
    
    if (!messageModel.direction) {
        _infoLabel.textColor = [UIColor blackColor];
        _containerView.backgroundColor = [UIColor whiteColor];
        [_iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.contentView).offset(20);
            make.width.height.equalTo(@40);
        }];
        
        [_containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self->_iconImageView.mas_right).offset(10);
            make.top.equalTo(self->_iconImageView .mas_top);
            make.bottom.equalTo(self.contentView).offset(-10);
            make.width.lessThanOrEqualTo(@(messageX));
        }];
        
    } else {
        _infoLabel.textColor = [UIColor whiteColor];
        _containerView.backgroundColor = RGBA(39,151,255, 1);
        [_iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(20);
            make.right.equalTo(self.contentView).offset(-20);
            make.width.height.equalTo(@(40));
        }];
        
        [_containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self->_iconImageView.mas_left).offset(-10);
            make.top.equalTo(self->_iconImageView.mas_top);
            make.bottom.equalTo(self.contentView).offset(-10);
            make.width.lessThanOrEqualTo(@(messageX));
        }];
    }
    
    [_nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(self->_iconImageView);
        make.top.equalTo(self->_iconImageView.mas_bottom);
        make.height.equalTo(@(15));
        //less
        //make.bottom.mas_lessThanOrEqualTo(self->_containerView.mas_bottom);
    }];
    
    [_infoLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->_containerView).insets(UIEdgeInsetsMake(10, 15, 10, 15));
    }];
}

- (NSDictionary *)setTextLineSpaceWithString:(NSString*)str withFont:(UIFont*)font withLineSpace:(CGFloat)lineSpace withTextlengthSpace:(NSNumber *)textlengthSpace paragraphSpacing:(CGFloat)paragraphSpacing{
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = lineSpace;
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    NSDictionary *dic = @{NSFontAttributeName:font,
                          NSParagraphStyleAttributeName:paraStyle,NSKernAttributeName:textlengthSpace};
    return dic;
    
}

@end
