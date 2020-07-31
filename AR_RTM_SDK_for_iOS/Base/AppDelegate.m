//
//  AppDelegate.m
//  AR_RTM_SDK_for_iOS
//
//  Created by 余生丶 on 2020/6/16.
//  Copyright © 2020 AR. All rights reserved.
//

#import "AppDelegate.h"
#import "ARtmMainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    if (ARtmManager.getLocalUid.length == 0) {
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ARtm_Login"];
    } else {
        ARtmMainViewController *mainVc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ARtm_Main"];
        mainVc.index = YES;
        UINavigationController *navVc = [[UINavigationController alloc] initWithRootViewController:mainVc];
        self.window.rootViewController = navVc;
    }
    return YES;
}


@end
