//
//  ARtmAttributesController.m
//  AR_RTM_SDK_for_iOS
//
//  Created by 余生丶 on 2020/7/16.
//  Copyright © 2020 AR. All rights reserved.
//

#import "ARtmAttributesController.h"

@interface ARtmAttributesController ()

@property (nonatomic, strong) NSMutableArray *arr;

@end

@implementation ARtmAttributesController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.arr = [NSMutableArray array];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [UIView new];
    if (self.attributeType == ARtmAttributesTypeLocalUser) {
        self.navigationItem.title = @"设置";
        UILabel *headLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44)];
        headLabel.backgroundColor = [UIColor whiteColor];
        headLabel.textColor = [UIColor lightGrayColor];
        headLabel.text = @"  个人信息";
        headLabel.font = [UIFont boldSystemFontOfSize:14];
        self.tableView.tableHeaderView = headLabel;
    } else {
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(0, 0, 30, 30);
        [rightButton setImage:[UIImage imageNamed:@"icon_refresh"] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(didClickRefreshButton:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        
        if (self.attributeType == ARtmAttributesTypeRemoteUser) {
            self.navigationItem.title = [NSString stringWithFormat:@"用户%@详情",self.account];
        } else {
            self.navigationItem.title = [NSString stringWithFormat:@"频道%@详情",self.account];
        }
    }
    
    if (self.attributeType != ARtmAttributesTypeRemoteUser) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 100)];
        footerView.backgroundColor = [UIColor whiteColor];
        
        UIButton *addAttButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addAttButton.frame = CGRectMake(CGRectGetWidth(self.tableView.frame) * 0.1, 28, CGRectGetWidth(self.tableView.frame) * 0.8, 44);
        [addAttButton setBackgroundColor:RGBA(37, 144, 255, 1)];
        [addAttButton setTitle:@"添加属性" forState:UIControlStateNormal];
        [addAttButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addAttButton addTarget:self action:@selector(didClickAddAttributesButton:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:addAttButton];
        self.tableView.tableFooterView = footerView;
    }
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 30, 30);
    [leftButton setImage:[UIImage imageNamed:@"icon_return"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(didClickExitButton:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getAttributes];
}

- (void)getAttributes {
    WEAKSELF;
    if (self.attributeType != ARtmAttributesTypeChannel) {
        [ARtmManager.rtmKit getUserAllAttributes:self.account completion:^(NSArray<ARtmAttribute *> * _Nullable attributes, NSString * _Nonnull uid, ARtmProcessAttributeErrorCode errorCode) {
            if (errorCode == ARtmAttributeOperationErrorOk) {
                [weakSelf reloadAttribute:attributes];
            }
        }];
    } else {
        [ARtmManager.rtmKit getChannelAllAttributes:self.account completion:^(NSArray<ARtmChannelAttribute *> * _Nullable attributes, ARtmProcessAttributeErrorCode errorCode) {
            if (errorCode == ARtmAttributeOperationErrorOk) {
                [weakSelf reloadAttribute:attributes];
            }
        }];
    }
}

- (void)reloadAttribute:(NSArray *)attributes{
    [self.arr removeAllObjects];
    [self.arr addObjectsFromArray:attributes];
    [self.tableView reloadData];
    
    if (self.arr.count != 0) {
        [SVProgressHUD showSuccessWithStatus:@"刷新成功"];
    } else {
        [SVProgressHUD showSuccessWithStatus:@"暂无属性"];
    }
    [SVProgressHUD dismissWithDelay:0.5];
}

- (void)didClickExitButton:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didClickRefreshButton:(UIButton *)sender {
    [self getAttributes];
}
- (void) updateAttribute: (ARtmAttribute *)attribute {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"修改属性" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertVc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"value";
    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSString *value = [[alertVc textFields] objectAtIndex:0].text;
        
        if ((value.length != 0)) {
            if (self.attributeType != ARtmAttributesTypeChannel) {
                //个人属性
                ARtmAttribute *newAttribute = [[ARtmAttribute alloc] init];
                newAttribute.key = attribute.key;
                newAttribute.value = value;
                [ARtmManager.rtmKit addOrUpdateLocalUserAttributes:@[newAttribute] completion:^(ARtmProcessAttributeErrorCode errorCode) {
                    if (errorCode == ARtmAttributeOperationErrorOk) {
                        [self getAttributes];
                        
                    }
                }];
            } else {
                //频道属性
                ARtmChannelAttribute *channelAttribute = [[ARtmChannelAttribute alloc] init];
                channelAttribute.key = attribute.key;
                channelAttribute.value = value;
                ARtmChannelAttributeOptions * options = [[ARtmChannelAttributeOptions alloc] init];
                options.enableNotificationToChannelMembers = YES;
                
                [ARtmManager.rtmKit addOrUpdateChannel:self.account Attributes:@[channelAttribute] Options:options completion:^(ARtmProcessAttributeErrorCode errorCode) {
                    if (errorCode == ARtmAttributeOperationErrorOk) {
                        [self getAttributes];
                        
                    }
                }];
            }
        } else {
            [SVProgressHUD showInfoWithStatus:@" Value 不能为空"];
            [SVProgressHUD dismissWithDelay:0.8];
            
        }
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
     [alertVc addAction:action2];
     [alertVc addAction:action1];
     [self presentViewController:alertVc animated:YES completion:nil];
}
- (void)didClickAddAttributesButton:(UIButton *)sender {
    WEAKSELF;
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"添加属性" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertVc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"key";
    }];
    
    [alertVc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"value";
    }];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSString *key = [[alertVc textFields] objectAtIndex:0].text;
        NSString *value = [[alertVc textFields] objectAtIndex:1].text;
        
        if ((key.length != 0) && (value.length != 0)) {
            if (self.attributeType != ARtmAttributesTypeChannel) {
                //个人属性
                ARtmAttribute *attribute = [[ARtmAttribute alloc] init];
                attribute.key = key;
                attribute.value = value;
                [ARtmManager.rtmKit addOrUpdateLocalUserAttributes:@[attribute] completion:^(ARtmProcessAttributeErrorCode errorCode) {
                    if (errorCode == ARtmAttributeOperationErrorOk) {
                        [weakSelf getAttributes];
                    }
                }];
            } else {
                //频道属性
                ARtmChannelAttribute *channelAttribute = [[ARtmChannelAttribute alloc] init];
                channelAttribute.key = key;
                channelAttribute.value = value;
                ARtmChannelAttributeOptions * options = [[ARtmChannelAttributeOptions alloc] init];
                options.enableNotificationToChannelMembers = YES;
                
                [ARtmManager.rtmKit addOrUpdateChannel:self.account Attributes:@[channelAttribute] Options:options completion:^(ARtmProcessAttributeErrorCode errorCode) {
                    if (errorCode == ARtmAttributeOperationErrorOk) {
                        [weakSelf getAttributes];
                    }
                }];
            }
        } else {
            [SVProgressHUD showInfoWithStatus:@"Key 和 Value 不能为空"];
            [SVProgressHUD dismissWithDelay:0.8];
        }
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVc addAction:action2];
    [alertVc addAction:action1];
    [self presentViewController:alertVc animated:YES completion:nil];
}

//MARK: - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ARtmAttributesCellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ARtmAttributesCellID"];
        cell.textLabel.font = [UIFont fontWithName:@"PingFang SC" size:16];
        cell.detailTextLabel.font = [UIFont fontWithName:@"PingFang SC" size:14];
    }
    ARtmAttribute *attribute = self.arr[indexPath.row];
    cell.textLabel.text = attribute.key;
    cell.detailTextLabel.text = attribute.value;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.attributeType == ARtmAttributesTypeRemoteUser) {
        return NO;
    }
    return YES;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED{
    WEAKSELF;
    UITableViewRowAction *action0 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        if (self.attributeType == ARtmAttributesTypeLocalUser) {
            ARtmAttribute *attribute = self.arr[indexPath.row];
            [ARtmManager.rtmKit deleteLocalUserAttributesByKeys:@[attribute.key] completion:^(ARtmProcessAttributeErrorCode errorCode) {
                if (errorCode == ARtmAttributeOperationErrorOk) {
                    [weakSelf getAttributes];
                }
            }];
        } else {
            ARtmChannelAttributeOptions * options = [[ARtmChannelAttributeOptions alloc] init];
            options.enableNotificationToChannelMembers = YES;
            
            ARtmChannelAttribute *channelAttribute = self.arr[indexPath.row];
            [ARtmManager.rtmKit deleteChannel:self.account AttributesByKeys:@[channelAttribute.key] Options:options completion:^(ARtmProcessAttributeErrorCode errorCode) {
                if (errorCode == ARtmAttributeOperationErrorOk) {
                    
                }
            }];
        }
    }];
    
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"修改" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        ARtmAttribute *attribute = self.arr[indexPath.item];
        [weakSelf updateAttribute:attribute];
        
    }];
    return @[action0,action1];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
