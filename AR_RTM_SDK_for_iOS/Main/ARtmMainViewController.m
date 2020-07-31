//
//  ARtmMainViewController.m
//  AR_RTM_SDK_for_iOS
//
//  Created by 余生丶 on 2020/7/16.
//  Copyright © 2020 AR. All rights reserved.
//

#import "ARtmMainViewController.h"
#import "ARtmAttributesController.h"
#import "ARtmInfoCell.h"
#import "ARtmMessageModel.h"

@interface ARtmMainViewController ()<ARtmDelegate>

@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *placeholderView;

@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, assign) BOOL isLogin;

@end

@implementation ARtmMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = [ARtmManager getLocalUid];
    self.dataArr = [NSMutableArray array];
    self.tableView.tableFooterView = [UIView new];
    //登出
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 24, 24);
    [leftButton setImage:[UIImage imageNamed:@"icon_out"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(didClickLogoutButton:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    //个人属性配置
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 24, 24);
    [rightButton setImage:[UIImage imageNamed:@"icon_set"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(didClickConfigButton:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
}

- (void)didClickLogoutButton:(UIButton *)sender {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"确定退出登录？" message:@"退出登录历史消息将会清空" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        WEAKSELF;
        [ARtmManager setLocalUid:@""];
        [ARtmInfoManager removeAllObject];
        //登出
        [ARtmManager.rtmKit logoutWithCompletion:^(ARtmLogoutErrorCode errorCode) {
            if (errorCode == ARtmLogoutErrorOk) {
                if (weakSelf.index) {
                    UIApplication.sharedApplication.keyWindow.rootViewController =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ARtm_Login"];;
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVc addAction:action];
    [alertVc addAction:cancleAction];
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (void)didClickConfigButton:(UIButton *)sender {
    //属性配置
    ARtmAttributesController *attributeVc = [[ARtmAttributesController alloc] init];
    attributeVc.attributeType = ARtmAttributesTypeLocalUser;
    attributeVc.account = ARtmManager.getLocalUid;
    [self.navigationController pushViewController:attributeVc animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    ARtmManager.rtmKit.aRtmDelegate = self;
    if (self.index) {
        if (!self.isLogin) {
            WEAKSELF;
            [ARtmManager.rtmKit loginByToken:@"" user:ARtmManager.getLocalUid completion:^(ARtmLoginErrorCode errorCode) {
                if (errorCode == ARtmLoginErrorOk) {
                    weakSelf.isLogin = YES;
                    [weakSelf getHistoryData];
                    [SVProgressHUD showSuccessWithStatus:@"登录成功"];
                    [SVProgressHUD dismissWithDelay:0.5];
                }
            }];
        } else {
            [self getHistoryData];
        }
    }
}

- (IBAction)didClickChatButton:(UIButton *)sender {
    NSString *accountText = self.accountTextField.text;
    if (accountText.length != 0) {
        ARtmViewController *rtmVc = [[self storyboard] instantiateViewControllerWithIdentifier:@"ARtm_Identity"];
        rtmVc.modalPresentationStyle = UIModalPresentationFullScreen;
        rtmVc.rtmType = sender.tag;
        rtmVc.account = accountText;
        [self presentViewController:rtmVc animated:YES completion:nil];
    } else {
        [SVProgressHUD showInfoWithStatus:@"请输入uid或频道id"];
        [SVProgressHUD dismissWithDelay:0.8];
    }
}

- (void)getHistoryData {
    [self.dataArr removeAllObjects];
    [self.dataArr addObjectsFromArray:[ARtmHistoryManager getAllHistoryList]];
    self.placeholderView.hidden = self.dataArr.count;
    NSMutableArray *peeridArr = [NSMutableArray arrayWithCapacity:self.dataArr.count];
    for (ARtmMessageModel *model in self.dataArr) {
        [peeridArr addObject:model.peerId];
    }
    
    //查询
    WEAKSELF;
    [ARtmManager.rtmKit queryPeersOnlineStatus:peeridArr completion:^(NSArray<ARtmPeerOnlineStatus *> * _Nullable peerOnlineStatus, ARtmQueryPeersOnlineErrorCode errorCode) {
        for (ARtmPeerOnlineStatus *status in peerOnlineStatus) {
            for (ARtmMessageModel *model in weakSelf.dataArr) {
                if ([model.peerId isEqualToString:status.peerId]) {
                    model.state = status.state;
                    break;
                }
            }
        }
        [weakSelf.tableView reloadData];
    }];
    
    //订阅
    [ARtmManager.rtmKit subscribePeersOnlineStatus:peeridArr completion:^(ARtmPeerSubscriptionStatusErrorCode errorCode) {
        NSLog(@"subscribePeersOnlineStatus == %ld",(long)errorCode);
    }];
}

//MARK: - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ARtmInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RtmInfoCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ARtmMessageModel *model = self.dataArr[indexPath.row];
    cell.messageModel = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ARtmMessageModel *model = self.dataArr[indexPath.row];
    model.num = 0;
    [ARtmHistoryManager updateHistoyModel:model];
    
    ARtmViewController *rtmVc = [[self storyboard] instantiateViewControllerWithIdentifier:@"ARtm_Identity"];
    rtmVc.modalPresentationStyle = UIModalPresentationFullScreen;
    rtmVc.rtmType = ARtmTypePeer;
    rtmVc.account = model.peerId;
    [self presentViewController:rtmVc animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED{
    UITableViewRowAction *action0 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        ARtmMessageModel *model = self.dataArr[indexPath.row];
        [ARtmManager.rtmKit unsubscribePeersOnlineStatus:@[model.peerId] completion:^(ARtmPeerSubscriptionStatusErrorCode errorCode) {
            NSLog(@"unsubscribePeersOnlineStatus == %ld",errorCode);
        }];
        
        [self.dataArr removeObject:model];
        self.placeholderView.hidden = self.dataArr.count;
        [ARtmInfoManager removeMessageData:model.peerId];
        [tableView reloadData];
    }];
    return @[action0];
}

//MARK: - ARtmDelegate

- (void)rtmKit:(ARtmKit * _Nonnull)kit connectionStateChanged:(ARtmConnectionState)state reason:(ARtmConnectionChangeReason)reason {
    //连接状态改变回调
}

- (void)rtmKit:(ARtmKit * _Nonnull)kit messageReceived:(ARtmMessage * _Nonnull)message fromPeer:(NSString * _Nonnull)peerId {
    //收到点对点消息回调
    //[ARtmManager addOfflineMessage:message fromUser:peerId];
    ARtmMessageModel *model = [[ARtmMessageModel alloc] init];
    model.peerId = peerId;
    model.content = message.text;
    model.uid = peerId;
    model.direction = 0;
    model.isOfflineMessage = YES;
    [ARtmInfoManager saveMessageWithInfoModel:model];
    [self getHistoryData];
}

- (void)rtmKit:(ARtmKit * _Nonnull)kit peersOnlineStatusChanged:(NSArray< ARtmPeerOnlineStatus *> * _Nonnull)onlineStatus {
    //被订阅用户在线状态改变回调
    for (ARtmPeerOnlineStatus *status in onlineStatus) {
        for (ARtmMessageModel *model in self.dataArr) {
            if ([model.peerId isEqualToString:status.peerId]) {
                model.state = status.state;
                [self.tableView reloadData];
                break;
            }
        }
    }
}

@end
