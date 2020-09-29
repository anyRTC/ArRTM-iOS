//
//  ARtmViewController.m
//  AR_RTM_SDK_for_iOS
//
//  Created by 余生丶 on 2020/6/19.
//  Copyright © 2020 AR. All rights reserved.
//

#import "ARtmViewController.h"
#import "ARtmMessageModel.h"
#import "ARtmMessageCell.h"
#import "ARtmAttributesController.h"


@interface ARtmViewController ()<ARtmDelegate,UITextFieldDelegate,ARtmChannelDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *padding;

@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) ARtmChannel *rtmChannel;

@end

@implementation ARtmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (ARBangsScreen) {
        self.padding.constant = 86;
    }
    [UIApplication.sharedApplication setIdleTimerDisabled:YES];
    
    ARtmManager.rtmKit.aRtmDelegate = self;
    self.dataArr = [NSMutableArray arrayWithCapacity:10];
    self.messageTextField.layer.borderColor = RGBA_CG(182,187,196, 1);
    self.messageTextField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 0)];
    self.messageTextField.leftViewMode = UITextFieldViewModeAlways;
    [self.messageTextField addTarget:self action:@selector(messageMaxLimit:) forControlEvents:UIControlEventEditingChanged];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = RGBA(242,244,249,1);
    [self.tableView registerClass:[ARtmMessageCell class] forCellReuseIdentifier:@"InformationCellID"];
    
    if (self.rtmType == ARtmTypeGroup) {
        self.textLabel.text = [NSString stringWithFormat:@"ChannelId：%@",self.account];
        self.rtmChannel = [ARtmManager.rtmKit createChannelWithId:self.account delegate:self];
        [self.rtmChannel joinWithCompletion:^(ARtmJoinChannelErrorCode errorCode) {
            NSLog(@"joinWithCompletion == %ld",(long)errorCode);
        }];
    } else {
        self.textLabel.text = [NSString stringWithFormat:@"Peer：%@",self.account];
        [self.dataArr addObjectsFromArray:[ARtmInfoManager getMessageUidList:self.account]];
        [self scrollToEnd];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (IBAction)doSomethingEvent:(UIButton *)sender {
    switch (sender.tag) {
        case 50:
            if (self.rtmType == ARtmTypeGroup) {
                [ARtmManager.rtmKit destroyChannelWithId:self.account];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case 51:
            [self sendRtmMessage];
            break;
        case 52:
        {
            ARtmAttributesController *attributeVc = [[ARtmAttributesController alloc] init];
            attributeVc.attributeType = (ARtmAttributesType)self.rtmType;
            attributeVc.account = self.account;
            UINavigationController *navVc = [[UINavigationController alloc] initWithRootViewController:attributeVc];
            navVc.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:navVc animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

- (void)keyboardFrameWillChange:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSValue *endKeyboardFrameValue = (NSValue *)userInfo[UIKeyboardFrameEndUserInfoKey];
    NSNumber *durationValue = (NSNumber *)userInfo[UIKeyboardAnimationDurationUserInfoKey];
    
    CGRect endKeyboardFrame = endKeyboardFrameValue.CGRectValue;
    float duration = durationValue.floatValue;
    
    BOOL keyBoard = (endKeyboardFrame.size.height + endKeyboardFrame.origin.y) > [UIScreen mainScreen].bounds.size.height ? NO : YES;
    
    WEAKSELF;
    [UIView animateWithDuration:duration animations:^{
        if (keyBoard) {
            float offsetY = (weakSelf.bottomView.frame.origin.y + weakSelf.bottomView.frame.size.height) - endKeyboardFrame.origin.y;
            if (offsetY <= 0) {
                return;
            }
            weakSelf.bottomViewConstraint.constant = - offsetY;
        } else {
            weakSelf.bottomViewConstraint.constant = 0;
        }
        [weakSelf.view layoutIfNeeded];
    }];
}

- (void)messageMaxLimit:(UITextField *)textField{
    if (textField.text.length > 256) {
        textField.text = [textField.text substringWithRange:NSMakeRange(0, 256)];
    }
}

//MARK: - ARtmDelegate

- (void)rtmKit:(ARtmKit * _Nonnull)kit connectionStateChanged:(ARtmConnectionState)state reason:(ARtmConnectionChangeReason)reason {
    //连接状态改变回调
}

- (void)rtmKit:(ARtmKit * _Nonnull)kit messageReceived:(ARtmMessage * _Nonnull)message fromPeer:(NSString * _Nonnull)peerId {
    //收到点对点消息回调
    ARtmMessageModel *model = [[ARtmMessageModel alloc] init];
    model.peerId = peerId;
    model.content = message.text;
    model.uid = peerId;
    model.direction = 0;
    model.isOfflineMessage = true;
    if ([peerId isEqualToString:self.account] && self.rtmType != ARtmTypeGroup) {
        [self.dataArr addObject:model];
        [self.tableView reloadData];
        [self scrollToEnd];
    }
    [ARtmInfoManager saveMessageWithInfoModel:model];
}

- (void)rtmKit:(ARtmKit * _Nonnull)kit peersOnlineStatusChanged:(NSArray< ARtmPeerOnlineStatus *> * _Nonnull)onlineStatus {
    //被订阅用户在线状态改变回调
}

- (void)rtmKitTokenDidExpire:(ARtmKit * _Nonnull)kit {
    //当前使用的 RTM Token 已超过 24 小时的签发有效期
}

//MARK: - ARtmChannelDelegate

- (void)channel:(ARtmChannel * _Nonnull)channel memberJoined:(ARtmMember * _Nonnull)member {
    //远端用户加入频道回调
}

- (void)channel:(ARtmChannel * _Nonnull)channel memberLeft:(ARtmMember * _Nonnull)member {
    //频道成员离开频道回调
    
}

- (void)channel:(ARtmChannel * _Nonnull)channel messageReceived:(ARtmMessage * _Nonnull)message fromMember:(ARtmMember * _Nonnull)member {
    //收到频道消息回调
    ARtmMessageModel *model = [[ARtmMessageModel alloc] init];
    model.content = message.text;
    model.direction = 0;
    model.uid = member.uid;
    [self.dataArr addObject:model];
    [self.tableView reloadData];
    [self scrollToEnd];
}

- (void)channel:(ARtmChannel * _Nonnull)channel attributeUpdate:(NSArray< ARtmChannelAttribute *> * _Nonnull)attributes {
    //频道属性更新回调。返回所在频道的所有属性
}

- (void)channel:(ARtmChannel * _Nonnull)channel memberCount:(int)count {
    //频道成员人数更新回调。返回最新频道成员人数
}


//MARK: - UITableViewDataSource,UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ARtmMessageCell *cell = (ARtmMessageCell *) [tableView dequeueReusableCellWithIdentifier:@"InformationCellID"];
    ARtmMessageModel *rtmModel = self.dataArr[indexPath.row];
    cell.messageModel = rtmModel;
    return cell;
}

//MARK: - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.text.length != 0) {
        [self sendRtmMessage];
        return YES;
    }
    return NO;
}

- (void)sendRtmMessage {
    if (self.messageTextField.text.length != 0) {
        ARtmMessage *message = [[ARtmMessage alloc] initWithText:self.messageTextField.text];
        NSMutableArray *peeridArr = [NSMutableArray arrayWithCapacity:1];
        [peeridArr addObject:self.account];
        ARtmSendMessageOptions *options = [[ARtmSendMessageOptions alloc] init];
        [ARtmManager.rtmKit queryPeersOnlineStatus: peeridArr completion:^(NSArray<ARtmPeerOnlineStatus *> * _Nullable peerOnlineStatus, ARtmQueryPeersOnlineErrorCode errorCode) {
            if (errorCode == ARtmQueryPeersOnlineErrorOk) {
                for (ARtmPeerOnlineStatus *status in peerOnlineStatus) {
                    if ([self.account isEqualToString:status.peerId])
                        if (status.state == 0) {
                            options.enableOfflineMessaging = false;
                        } else {
                            options.enableOfflineMessaging = YES;
                            NSLog(@"offline");
                        }
                    options.enableHistoricalMessaging = YES;

                    __block NSString *text= self.messageTextField.text;
                        WEAKSELF;
                        if (self.rtmType == ARtmTypeGroup) {
                            //频道消息
                            [self.rtmChannel sendMessage:message sendMessageOptions:options completion:^(ARtmSendChannelMessageErrorCode errorCode) {
                                [weakSelf sendMessageResult:text];
                                NSLog(@"Channel sendMessage Sucess");
                                
                            }];
                        } else {
                            //点对点消息
                            [self sendMessageResult:text];
                            
                            [ARtmManager.rtmKit sendMessage:message toPeer:self.account sendMessageOptions:options completion:^(ARtmSendPeerMessageErrorCode errorCode) {
                                NSLog(@"Peer sendMessage Sucess");
                            }];
                        }
                    self.messageTextField.text = @"";
                    [self.messageTextField resignFirstResponder];
                }
            }
        }];   
    }
}

- (void)sendMessageResult:(NSString *)text {
    ARtmMessageModel *model = [[ARtmMessageModel alloc] init];
    model.peerId = self.account;
    model.content = text;
    model.uid = ARtmManager.getLocalUid;
    model.direction = 1;
    [self.dataArr addObject:model];
    [self.tableView reloadData];
    [self scrollToEnd];
    if (self.rtmType == ARtmTypePeer) {
        [ARtmInfoManager saveMessageWithInfoModel:model];
    }
}

- (void)scrollToEnd{
    if (self.dataArr.count != 0 ) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.dataArr.count > 0) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
        });
    }
}

- (void)dealloc {
    NSLog(@"dealloc");
}

@end
