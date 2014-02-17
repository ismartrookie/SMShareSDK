//
//  SMViewController.m
//  JH_SMShareSDK
//
//  Created by administrator on 14-2-13.
//  Copyright (c) 2014年 SM. All rights reserved.
//

#import "SMViewController.h"
#import "ShareSDK.h"

@interface SMViewController ()<UITableViewDelegate,UITableViewDataSource> {
    NSArray *tableArr;
}

@end

@implementation SMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tableArr = @[@"短信",@"新浪微博",@"微信好友",@"微信朋友圈",@"QQ好友",@"QQ空间"];
    
    UITableView *tableview = ({
        UITableView *tableview = [[UITableView alloc] init];
        [tableview setFrame:self.view.bounds];
        [tableview setDelegate:self];
        [tableview setDataSource:self];
        tableview;
    });
    
    
    [self.view addSubview:tableview];
}


#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSInteger row = indexPath.row;
    [[cell textLabel] setText:[tableArr objectAtIndex:row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ShareType shareType;                                //分享类型
    ShareConType shareConType = SCON_APP;               //分享内容类型
    
    NSInteger row = indexPath.row;
    NSString *conStr = [tableArr objectAtIndex:row];
    NSLog(@"Selected Share Model = %@",conStr);
    /**
     *  @[@"短信",@"新浪微博",@"微信好友",@"微信朋友圈",@"QQ好友",@"QQ空间"]
     */
    if ([conStr isEqualToString:@"短信"]) {
        shareType = S_MESS;
    } else if ([conStr isEqualToString:@"新浪微博"]) {
        shareType = S_SINA;
    } else if ([conStr isEqualToString:@"微信好友"]) {
        shareType = S_WX_CHAT;
    } else if ([conStr isEqualToString:@"微信朋友圈"]) {
        shareType = S_WX_FRIENDS;
    } else if ([conStr isEqualToString:@"QQ好友"]) {
        shareType = S_QQ;
    } else if ([conStr isEqualToString:@"QQ空间"]) {
        shareType = S_QZone;
    } else {
        shareType = S_SINA;
    }
    //获取分享con类型 app为应用分享，new 为新闻内容分享
    shareConType = SCON_APP;
    [[ShareSDK shareInstance] setAppId:@"9d5fa2bd-2317-4bd3-b064-24e73a742799"];
    
//  shareConType = SCON_NEWS;
//  [[ShareSDK shareInstance] setNewsShareUrl:url];
    
    [ShareSDK shareInSDKType:shareType andShareConType:shareConType withVctrl:self];
    return;
}

/**
 *  设置设备转向功能
 *
 *  @return 不允许
 */
- (BOOL)shouldAutorotate
{
    return NO;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
