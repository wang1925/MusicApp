//
//  AppDelegate.m
//  MusicApp
//
//  Created by 王浩田 on 2018/7/21.
//  Copyright © 2018年 MusicApp. All rights reserved.
//

#import "AppDelegate.h"
#import "HTListViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    HTListViewController *rootVC = [[HTListViewController alloc]init];
    UINavigationController *rootNav = [[UINavigationController alloc]initWithRootViewController:rootVC];
    self.window.rootViewController = rootNav;
    
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    // 监听通话状态
    [self monitorTelephoneCall];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // 监听通话状态
    [self monitorTelephoneCall];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark- 监听通话状态
- (void)monitorTelephoneCall{
    self.callCenter = [[CTCallCenter alloc] init];
    self.callCenter.callEventHandler = ^(CTCall* call) {
        if ([call.callState isEqualToString:CTCallStateDisconnected]){
            NSLog(@"挂断了电话咯Call has been disconnected");
        }else if ([call.callState isEqualToString:CTCallStateConnected]){
            NSLog(@"电话通了Call has just been connected");
        }else if([call.callState isEqualToString:CTCallStateIncoming] ||[call.callState isEqualToString:CTCallStateDialing]){
            NSLog(@"来电话了Call is incoming | 正在播出电话call is dialing");
        }else{
            NSLog(@"嘛都没做Nothing is done");
        }
    };
}

@end
