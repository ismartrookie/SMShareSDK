//
//  AppDelegate.m
//  JH_SMShareSDK
//
//  Created by administrator on 14-2-13.
//  Copyright (c) 2014年 SM. All rights reserved.
//

#import "AppDelegate.h"
#import "SMViewController.h"
#import "WXApi.h"
#import "ShareSDK.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    SMViewController *smvctrl = [[SMViewController alloc] init];
    [self.window setRootViewController:smvctrl];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    /**
     *  微信SDK要求在此添加一处理方法
     */
    NSString *urlString = url.absoluteString;
    NSLog(@"_%s url = %@",__func__,url);
    NSString *headPreTag = [urlString substringToIndex:2];
    if ([headPreTag isEqualToString:@"wx"]) {        //由微信接收处理
        return [WXApi handleOpenURL:url delegate:[ShareSDK shareInstance]];
    } else if ([headPreTag isEqualToString:@"te"]) {
        [QQApiInterface handleOpenURL:url delegate:[ShareSDK shareInstance]];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    /**
     *  微信 && 微博 均要求在此添加回调处理方法
     */
    NSLog(@"_%s url = %@",__func__,url);
    NSString *urlString = url.absoluteString;
    NSString *headPreTag = [urlString substringToIndex:2];
    if ([headPreTag isEqualToString:@"wb"]) {               //由微博接收处理
        return [WeiboSDK handleOpenURL:url delegate:[ShareSDK shareInstance]];
    } else if ([headPreTag isEqualToString:@"wx"]) {        //由微信接收处理
        return [WXApi handleOpenURL:url delegate:[ShareSDK shareInstance]];
    } else if ([headPreTag isEqualToString:@"te"]) {
        [QQApiInterface handleOpenURL:url delegate:[ShareSDK shareInstance]];
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
