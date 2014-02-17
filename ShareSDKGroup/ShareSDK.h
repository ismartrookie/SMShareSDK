//
//  ShareSDK.h
//  CordovaLib
//
//  Created by administrator on 14-1-9.
//
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import "AppShareObject.h"
#import "NSURL+ParamDic.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentApiInterface.h>

typedef enum {
    S_SINA,          //新浪微博
    S_WX_FRIENDS,    //微信好友圈
    S_WX_CHAT,       //微信
    S_MESS,          //短信
    S_QQ,            //QQ
    S_QZone,         //QZone
}ShareType;

typedef enum {
    SCON_APP,
    SCON_NEWS,
}ShareConType;

@interface ShareSDK : NSObject<WeiboSDKDelegate,WBHttpRequestDelegate,WXApiDelegate,MFMessageComposeViewControllerDelegate,QQApiInterfaceDelegate>

//设置分享类别
@property (assign, nonatomic) ShareType shareType;

@property (strong, nonatomic) AppShareObject *appShareObject;
@property (strong, nonatomic) NSURL *newsShareUrl;

@property (assign, nonatomic) UIViewController *rootViewController;

@property (copy,nonatomic) NSString *appId;

+ (ShareSDK *)shareInstance;

/**
    调用分享接口，传入分享模式（新浪，微信） 及 分享的类型（应用分享，消息分享）
 */
+ (void)shareInSDKType:(ShareType)sharetype andShareConType:(ShareConType)conType withVctrl:(UIViewController *)vctrl;






@end
