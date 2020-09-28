//
//  ViewController.m
//  AR_RTM_SDK_for_iOS
//
//  Created by 余生丶 on 2020/6/16.
//  Copyright © 2020 AR. All rights reserved.
//

#import "ViewController.h"
#import "ARtmMainViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)didClickLoginButton:(id)sender {
    NSString *localUid = self.textField.text;
    if (localUid.length != 0) {
        WEAKSELF;
        [ARtmManager.rtmKit loginByToken:@"" user:localUid completion:^(ARtmLoginErrorCode errorCode) {
            if (errorCode == ARtmLoginErrorOk) {
                [ARtmManager setLocalUid:localUid];
                ARtmMainViewController *mainVc = [[self storyboard] instantiateViewControllerWithIdentifier:@"ARtm_Main"];
                mainVc.isLogin = YES;
                [weakSelf.navigationController pushViewController:mainVc animated:YES];
            }
        }];
    } else {
        [self alert:@"请输入用户uid"];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textField resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)alert:(NSString *)text{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:text message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertVc addAction:action];
    [self presentViewController:alertVc animated:YES completion:nil];
}

@end
