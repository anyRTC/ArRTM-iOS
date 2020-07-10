//
//  ViewController.m
//  ARtmKitDemo
//
//  Created by 余生丶 on 2020/6/16.
//  Copyright © 2020 AR. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()<ARtmDelegate,ARtmChannelDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *uidLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self doSomethingEvent:self.loginButton];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textField resignFirstResponder];
}

- (IBAction)doSomethingEvent:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
        case 1:
        {
            if (ARtmManager.getLocalUid.length != 0) {
                if (self.textField.text.length != 0) {
                    ARtmViewController *rtmVc = [[self storyboard] instantiateViewControllerWithIdentifier:@"ARtm_Identity"];
                    rtmVc.modalPresentationStyle = UIModalPresentationFullScreen;
                    rtmVc.rtmType = sender.tag;
                    rtmVc.acount = self.textField.text;
                    [self presentViewController:rtmVc animated:YES completion:nil];
                } else {
                    [self alert:@"uid 或 channelId不能为空"];
                }
            } else {
                [self alert:@"请先登录"];
            }
        }
            break;
        case 50:
            sender.selected = !sender.selected;
            if (sender.selected) {
                WEAKSELF;
                __block NSString *localUid = [NSString stringWithFormat:@"%d",arc4random()%100000];
                [ARtmManager.rtmKit loginByToken:@"" user:localUid completion:^(ARtmLoginErrorCode errorCode) {
                    if (errorCode == ARtmLoginErrorOk) {
                        [ARtmManager setLocalUid:localUid];
                        weakSelf.uidLabel.text = [NSString stringWithFormat:@"localUid：%@",localUid];
                        NSLog(@"loginSucess");
                    }
                }];
            } else {
                [ARtmManager setLocalUid:@""];
                self.uidLabel.text = @"";
                [ARtmManager.rtmKit logoutWithCompletion:^(ARtmLogoutErrorCode errorCode) {
                    NSLog(@"logout === %ld",(long)errorCode);
                }];
            }
            break;
        default:
            break;
    }
}

- (void)alert:(NSString *)text{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:text message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertVc addAction:action];
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ARtmManager.rtmKit.aRtmDelegate = self;
}

//MARK: - ARtmDelegate

- (void)rtmKit:(ARtmKit * _Nonnull)kit connectionStateChanged:(ARtmConnectionState)state reason:(ARtmConnectionChangeReason)reason {
    
}

- (void)rtmKit:(ARtmKit * _Nonnull)kit messageReceived:(ARtmMessage * _Nonnull)message fromPeer:(NSString * _Nonnull)peerId {
    
}

@end
