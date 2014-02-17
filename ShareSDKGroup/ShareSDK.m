//
//  ShareSDK.m
//  CordovaLib
//
//  Created by administrator on 14-1-9.
//
//

#import "ShareSDK.h"
#import "ShareSinaViewController.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "NewsShareObject.h"
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/TencentOAuth.h>

@interface ShareSDK()<TencentSessionDelegate> {
    TencentOAuth *tencentOAuth;
}

@end

@implementation ShareSDK

- (id)init
{
    self = [super init];
    if (self) {
        // sina 微博sdk注册
        [WeiboSDK enableDebugMode:YES];
        [WeiboSDK registerApp:@"3572743774"];
        
        // weixin 向微信注册
        [WXApi registerApp:@"wxea70dcfdd74dbcf4" withDescription:@"wxea70dcfdd74dbcf4"];
        
        //QQ 向QQSDK 注册
        tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"101019558" andDelegate:self];
        
    }
    return self;
}


+ (ShareSDK *)shareInstance
{
    static ShareSDK *shareSDK = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareSDK = [[ShareSDK alloc] init];
    });
    return shareSDK;
}
/**
 *检测设备是否支持当前功能。
 ***/
- (BOOL)isSurportWithType:(ShareType)sharetype
{
    switch (sharetype) {
        case S_SINA: {
            if (![WeiboSDK isWeiboAppInstalled]) {
                [self shareBySinaSDKWith:nil];
                return NO;
            }
        }
            break;
        case S_WX_CHAT:{
            if (![WXApi isWXAppInstalled]) {
                [self shareByWeiXinChatWith:nil andScene:WXSceneSession];
                return NO;
            }
        }
            break;
        case S_WX_FRIENDS:{
            if (![WXApi isWXAppInstalled]) {
                [self shareByWeiXinChatWith:nil andScene:WXSceneTimeline];
                return NO;
            }
        }
            break;
        case S_MESS: {
            if (![MFMessageComposeViewController canSendText]) {
                [[ShareSDK shareInstance] shareSMSPickerWith:nil];
                return NO;
            }
        }
            break;
        case S_QQ: {
            if (![TencentOAuth iphoneQQInstalled]) {
                return NO;
            }
        }
            break;
        case S_QZone: {
            if (![TencentOAuth iphoneQQInstalled]) {
                [QQApi isQQInstalled];
                return NO;
            }
        }
            break;
        default:
            return YES;
            break;
    }
    
    return YES;
}

- (void)shareInSDKType:(ShareType)sharetype andShareConType:(ShareConType)conType withNewsCon:(NewsShareObject *)newShare
{
    id shareContentObject = nil;
    switch (conType) {
        case SCON_APP:
            shareContentObject = [self appShareObject];
            break;
        case SCON_NEWS:
            shareContentObject = newShare;
        default:
            break;
    }
    //数据请求成功，开始准备分享
    switch (sharetype) {
        case S_SINA:                        //新浪微博分享
        {
            [self shareBySinaSDKWith:shareContentObject];
        }   break;
            
        case S_WX_CHAT:                     //微信分享
        {
            [self shareByWeiXinChatWith:shareContentObject andScene:WXSceneSession];
        }   break;
            
        case S_WX_FRIENDS:                  //微信朋友圈分享
        {
            [self shareByWeiXinChatWith:shareContentObject andScene:WXSceneTimeline];
        }   break;
            
        case S_MESS:                        //短信分享
        {
            [self shareSMSPickerWith:shareContentObject];
        }   break;
        case S_QQ:
        {
            [self shareByQQWith:shareContentObject andScene:S_QQ];
        }   break;
        case S_QZone:
        {
            [self shareByQQWith:shareContentObject andScene:S_QZone];
        }   break;
        default:
            break;
    }
}

+ (void)shareInSDKType:(ShareType)sharetype andShareConType:(ShareConType)conType withVctrl:(UIViewController *)vctrl
{
    [[ShareSDK shareInstance] setRootViewController:vctrl];
    //进行设备支持检测，如果设备不支持，则不再进行网络请求。
    if (![[ShareSDK shareInstance] isSurportWithType:sharetype]) {
        return;
    }
    
    switch (conType) {
            //应用分享
        case SCON_APP: {
            
            //哪果检测到分享数据已被下载，则直接分享
            AppShareObject *shareObjectInfo =[[ShareSDK shareInstance] appShareObject];
            if (shareObjectInfo) {
                [[ShareSDK shareInstance] shareInSDKType:sharetype andShareConType:SCON_APP withNewsCon:nil];
                return;
            }
            //异步请求时开始锁定界面交互
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://preapp.iuoooo.com/Jinher.AMP.App.BP.AppManagerBP.svc/GetAppShareContentInfos"]];
            
            
            [request setHTTPMethod:@"POST"];
            [request setTimeoutInterval:10];
            NSString *bodyReq = [NSString stringWithFormat:@"{\"appId\":\"%@\"}",[ShareSDK shareInstance].appId];
            [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[bodyReq dataUsingEncoding:NSUTF8StringEncoding]];
            AFJSONRequestOperation *jsonReq = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                NSLog(@"AppShare Requeset Success and JSON = %@",JSON);
                AppShareObject *appShare = [[AppShareObject alloc] init];
                [appShare setShareIcon:[JSON objectForKey:@"Icon"]];
//                [appShare setShareIconData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon" ofType:@"png"]]];
                [appShare setShareIconData:UIImagePNGRepresentation([UIImage imageNamed:@"icon@2x.png"])];
                [appShare setShareContent:[JSON objectForKey:@"ShareContent"]];
                [appShare setShareDesc:[JSON objectForKey:@"ShareDesc"]];
                [appShare setShareGotoUrl:[JSON objectForKey:@"ShareGotoUrl"]];
                [appShare setShareTopic:[JSON objectForKey:@"ShareTopic"]];
                [appShare setShareMessSrc:[JSON objectForKey:@"ShareMessSrc"]];
                
                NSLog(@"ShareGotoUrl = %@", [JSON objectForKey:@"ShareGotoUrl"]);
                NSLog(@"message = %@",[JSON objectForKey:@"Message"]);
                //检测请求结果 是否 正确 --> 打开用户交互
                if ([[JSON valueForKey:@"IsSuccess"] intValue] == 1) {
                    [[ShareSDK shareInstance] setAppShareObject:appShare];
                    [SVProgressHUD dismiss];
                } else {
                    [[ShareSDK shareInstance] setAppShareObject:nil];
                    NSString *message = [JSON objectForKey:@"Message"];
                    if (!message) {
                        [SVProgressHUD dismissWithError:message];
                    } else {
                        [SVProgressHUD dismissWithError:@"服务器数据异常!"];
                    }
                    return ;
                }
                //数据请求成功，开始准备分享
                [[ShareSDK shareInstance] shareInSDKType:sharetype andShareConType:SCON_APP withNewsCon:nil];
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                NSLog(@"Hello Requeset failure with Err = %@",error.description);
                [SVProgressHUD dismissWithError:@"网络请求异常!"];
            }];
            [jsonReq start];
            
        }
            break;
            //新闻分享
        case SCON_NEWS: {
            //异步请求时开始锁定界面交互
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://preurl.iuoooo.com/Jinher.JAP.ShortUrl.SV.ShortUrlManageSV.svc/GenShortUrl"]];
            
            [request setHTTPMethod:@"POST"];
            [request setTimeoutInterval:10];
            NSDictionary *newsDic = [[ShareSDK shareInstance] newsShareUrl].paramDic;
            NSLog(@"newsDic = %@", newsDic);
            NSString *bodyReq = [NSString stringWithFormat:@"{\"longUrl\":\"%@\"}",[newsDic objectForKey:@"shareurl"]];
            [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[bodyReq dataUsingEncoding:NSUTF8StringEncoding]];
            AFHTTPRequestOperation *jsonReq = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [jsonReq setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                if (operation.responseString.length <= 2) {
                    [SVProgressHUD dismissWithError:@"服务器数据异常!"];
                    return ;
                } else {
                    [SVProgressHUD dismiss];
                }
                NewsShareObject *newsShare = [[NewsShareObject alloc] init];
                [newsShare setShareContent:[[newsDic objectForKey:@"sharesummary"]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                
                NSRange range = {1,operation.responseString.length-2};
                NSString *shortUrlStr = [[operation.responseString substringWithRange:range]stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                NSLog(@"shortUrlStr = %@", shortUrlStr);
                [newsShare setShareGotoUrl:shortUrlStr];
                
                NSString*title = [[newsDic objectForKey:@"sharecont"]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [newsShare setShareTopic:title];
                //数据请求成功，开始准备分享
                [[ShareSDK shareInstance] shareInSDKType:sharetype andShareConType:SCON_NEWS withNewsCon:newsShare];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Hello Requeset failure with Err = %@",error.description);
                [SVProgressHUD dismissWithError:@"网络请求异常!"];
            }];
            [jsonReq start];
            
        }
            break;
        default:
            break;
    }
}
/**
 新浪微博分享
 */
- (void)shareBySinaSDKWith:(id)content
{
    if ([WeiboSDK isWeiboAppInstalled]) {
        WBMessageObject *message = [WBMessageObject message];
        WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
        //request.userInfo = @{@"ShareMessageFrom": @"SendMessageToWeiboViewController",
        //                     @"Other_Info_1": [NSNumber numberWithInt:123],
        //                     @"Other_Info_2": @[@"obj1", @"obj2"],
        //                     @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
        //request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
        
        /*
         WBWebpageObject *weburl = [WBWebpageObject object];
         [weburl setObjectID:@"JinHerAppInfo"];
         [weburl setTitle:content.shareTopic];
         [weburl setDescription:[NSString stringWithFormat:@"%@%@",content.shareContent,content.shareGotoUrl]];
         [weburl setWebpageUrl:content.shareGotoUrl];
         [weburl setThumbnailData:content.shareIconData];
         message.mediaObject = weburl;
         */
        if ([content isKindOfClass:[AppShareObject class]]) {
            WBImageObject *image = [WBImageObject object];
            AppShareObject *appShareContent = content;
            image.imageData = appShareContent.shareIconData;
            //[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_1" ofType:@"jpg"]];
            message.imageObject = image;
            message.text = [NSString stringWithFormat:@"%@%@ ",appShareContent.shareContent,appShareContent.shareGotoUrl];
        } else {
            
            NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
            NSLog(@"infoDict = %@", infoDict);
            NSString*appName =[infoDict objectForKey:@"CFBundleDisplayName"];
            
            
            NewsShareObject *newShareContent = content;
            WBImageObject *image = [WBImageObject object];
            image.imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon" ofType:@"png"]];
            message.imageObject = image;
            //            #应用名称#+【新闻名称】+新闻概要+新闻详情链接
            //            message.text = [NSString stringWithFormat:@"%@%@ ",newShareContent.shareContent,newShareContent.shareGotoUrl];
            message.text = [NSString stringWithFormat:@"#%@#【%@】%@ %@ ", appName, newShareContent.shareTopic, newShareContent.shareContent,newShareContent.shareGotoUrl];
        }
        [WeiboSDK sendRequest:request];
    } else {
        //在没有安装新浪微博客户端的情况下提示用户没有安装。
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该手机没有安装微博,请您进行确认" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertview show];
    }
}

- (void)shareByQQWith:(id)content andScene:(NSInteger)scene
{
    if ([QQApi isQQInstalled]) {
        QQApiNewsObject *newsObj;
        
        if ([content isKindOfClass:[AppShareObject class]]) {
            AppShareObject *appShareContent = content;
            newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:appShareContent.shareGotoUrl ? : @""]
                                               title:appShareContent.shareTopic ? : @""
                                         description:[NSString stringWithFormat:@"%@%@",appShareContent.shareContent,appShareContent.shareGotoUrl] ? : @""
                                    previewImageData:appShareContent.shareIconData];
        }
        
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        QQApiSendResultCode sent = 0;
        if (scene == S_QZone)
        {
            //分享到QZone
            sent = [QQApiInterface SendReqToQZone:req];
        }
        else
        {
            //分享到QQ
            sent = [QQApiInterface sendReq:req];
        }
        [self handleSendResult:sent];
    }
}

/**
 微信聊天分享
 ***/
- (void)shareByWeiXinChatWith:(id)content andScene:(NSInteger)scene
{
    if ([WXApi isWXAppInstalled]) {
        
        WXMediaMessage *message = [WXMediaMessage message];
        //[message setThumbImage:[UIImage imageNamed:@"image_1.jpg"]];
        
        /*
         WXImageObject *ext = [WXImageObject object];
         NSString *filePath = [[NSBundle mainBundle] pathForResource:@"image_1" ofType:@"jpg"];
         ext.imageData = [NSData dataWithContentsOfFile:filePath];
         //UIImage* image = [UIImage imageWithContentsOfFile:filePath];
         UIImage* image = [UIImage imageWithData:ext.imageData];
         ext.imageData = UIImagePNGRepresentation(image);
         
         message.mediaObject = ext;
         */
        
        WXWebpageObject *ext = [WXWebpageObject object];
        
        if ([content isKindOfClass:[AppShareObject class]]) {
            AppShareObject *appShareContent = content;
            ext.webpageUrl = appShareContent.shareGotoUrl;
            message.mediaTagName = @"JinHerAppInfo";
            [message setTitle:appShareContent.shareTopic];
            [message setDescription:[NSString stringWithFormat:@"%@%@",appShareContent.shareContent,appShareContent.shareGotoUrl]];
            [message setThumbImage:[UIImage imageNamed:@"icon.png"]];
            message.mediaObject = ext;
        } else {
            AppShareObject *newShareContent = content;
            ext.webpageUrl = newShareContent.shareGotoUrl;
            message.mediaTagName = @"JinHerAppInfo";
            [message setTitle:newShareContent.shareTopic];
            //            [message setDescription:[NSString stringWithFormat:@"%@%@",newShareContent.shareContent,newShareContent.shareGotoUrl]];
            //            [message setDescription:[NSString stringWithFormat:@"%@",newShareContent.shareContent]];
            //            [message setDescription:@"news"];
            [message setDescription:newShareContent.shareContent];
            [message setThumbImage:[UIImage imageNamed:@"icon.png"]];
            message.mediaObject = ext;
        }
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = scene;
        [WXApi sendReq:req];
    } else {
        //没有安装微信客户端的情况下， 进行弹窗提示
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该手机没有安装微信,请您进行确认" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertview show];
    }
}

/**
 SMS分享
 ***/
- (void)shareSMSPickerWith:(id)content
{
    //判断设备是否支持发送短信
    if ([MFMessageComposeViewController canSendText]) {
        
        MFMessageComposeViewController *smsPicker = [[MFMessageComposeViewController alloc] init];
        [smsPicker setMessageComposeDelegate:self];
        if ([content isKindOfClass:[AppShareObject class]]) {
            AppShareObject *appShareContent = content;
            [smsPicker setBody:[NSString stringWithFormat:@"%@%@",appShareContent.shareContent,appShareContent.shareGotoUrl]];
        } else {
            AppShareObject *newShareContent = content;
            
            //        #应用名称#+【新闻名称】+新闻详情链接 事例：#笨笨工作室#【男子银行卡被误存240万 担心被洗黑钱一夜不眠】http://url.iuoooo.com/s/R/S?url=Iryaya
            NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
            NSLog(@"infoDict = %@", infoDict);
            NSString*appName =[infoDict objectForKey:@"CFBundleDisplayName"];
            NSString *bodyStr = [NSString stringWithFormat:@"#%@#【%@】%@ ", appName, newShareContent.shareTopic, newShareContent.shareGotoUrl];
            [smsPicker setBody:bodyStr];
            //            [smsPicker setBody:[NSString stringWithFormat:@"%@%@",newShareContent.shareContent,newShareContent.shareGotoUrl]];
        }
        [_rootViewController presentViewController:smsPicker animated:YES completion:NULL];
        
    } else {
        //该设备不支持发送短信
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该设备不支持发送短信" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertview show];
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"用户取消了发送短信");
            break;
            
        case MessageComposeResultSent:{
            NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
            NSString*appName =[infoDict objectForKey:@"CFBundleDisplayName"];
            NSString *message = [NSString stringWithFormat:@"分享成功,感谢您对%@的支持,谢谢!",appName];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
            
        case MessageComposeResultFailed:{
            
            //分享失败
            NSString *message = @"非常抱歉,分享失败,谢谢!";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
            
        }
            break;
            
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQZONENOTSUPPORTTEXT:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"空间分享不支持纯文本分享，请使用图文分享" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQZONENOTSUPPORTIMAGE:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"空间分享不支持纯图片分享，请使用图文分享" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        default:
        {
            break;
        }
    }
}

#pragma mark - end

#pragma mark - WXApiDelegate
/*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
-(void) onReq:(BaseReq*)req
{
    NSLog(@"__func = %s and ErroCode = %d",__func__,req.type);
}

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
-(void) onResp:(BaseResp*)resp
{
    //此回调方法与微信冲突了，处理共用。
    if ([resp isKindOfClass:[QQBaseResp class]]) {
        
        QQBaseResp *rep = (QQBaseResp *)resp;
        NSInteger result = [rep.result intValue];
        if (result == -4) {
            //分享失败
            NSString *message = @"非常抱歉,分享失败,谢谢!";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        } else if (result == 0) {
            //分享成功
            NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
            NSString*appName =[infoDict objectForKey:@"CFBundleDisplayName"];
            NSString *message = [NSString stringWithFormat:@"分享成功,感谢您对%@的支持,谢谢!",appName];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        
        return;
    }
    
    if (resp.errCode == 0) {
        //分享成功
        
        NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
        NSString*appName =[infoDict objectForKey:@"CFBundleDisplayName"];
        NSString *message = [NSString stringWithFormat:@"分享成功,感谢您对%@的支持,谢谢!",appName];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        //分享失败
        NSString *message = @"非常抱歉,分享失败,谢谢!";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
}


#pragma mark - WeiboSDKDelegate
/**
 收到一个来自微博客户端程序的请求
 收到微博的请求后，第三方应用应该按照请求类型进行处理，处理完后必须通过 [WeiboSDK sendResponse:] 将结果回传给微博
 @param request 具体的请求对象
 */
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    NSLog(@"__%s",__func__);
}

/**
 收到一个来自微博客户端程序的响应
 收到微博的响应后，第三方应用可以通过响应类型、响应的数据和 WBBaseResponse.userInfo 中的数据完成自己的功能
 @param response 具体的响应对象
 */
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    //新浪微博分享
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        NSString *title = @"发送结果";
        /*
         NSString *message = [NSString stringWithFormat:@"响应状态: %d\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",
         response.statusCode, response.userInfo, response.requestUserInfo];
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
         message:message
         delegate:nil
         cancelButtonTitle:@"确定"
         otherButtonTitles:nil];
         [alert show];
         */
        //分享成功
        if (response.statusCode == 0) {
            NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
            NSString*appName =[infoDict objectForKey:@"CFBundleDisplayName"];
            NSString *message = [NSString stringWithFormat:@"分享成功,感谢您对%@的支持,谢谢!",appName];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            //分享失败
            NSString *message = @"非常抱歉,分享失败,谢谢!";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        NSString *title = @"认证结果";
        NSString *message = [NSString stringWithFormat:@"响应状态: %d\nresponse.userId: %@\nresponse.accessToken: %@\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",
                             response.statusCode, [(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken], response.userInfo, response.requestUserInfo];
        NSString *accessToken = [(WBAuthorizeResponse *)response accessToken];
        if (accessToken) {
            
            //发送sina微博消息
            NSString *shareContent  = [response.requestUserInfo objectForKey:@"ShareContent"];
            NSDictionary *paramsDic = [NSDictionary dictionaryWithObjectsAndKeys:shareContent,@"status", nil];
            [WBHttpRequest requestWithAccessToken:accessToken url:@"https://api.weibo.com/2/statuses/update.json" httpMethod:@"POST" params:paramsDic delegate:self withTag:@"smartrookie新浪"];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    
}

#pragma mark - WBHttpRequestDelegate
/**
 收到一个来自微博Http请求的响应
 @param response 具体的响应对象
 */
- (void)request:(WBHttpRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"__%s and request = %@",__func__,response);
}

/**
 收到一个来自微博Http请求失败的响应
 @param error 错误信息
 */
- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"__%s",__func__);
}


/**
 收到一个来自微博Http请求的网络返回
 @param result 请求返回结果
 */
- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    NSLog(@"__%s and result = %@",__func__,result);
    [[ShareSinaViewController shareInstance] dismissViewControllerAnimated:YES completion:NULL];
}


/**
 收到一个来自微博Http请求的网络返回
 @param data 请求返回结果
 */
- (void)request:(WBHttpRequest *)request didFinishLoadingWithDataResult:(NSData *)data
{
    NSLog(@"__%s",__func__);
}

#pragma mark - QQApiInterfaceDelegate

/**
 处理QQ在线状态的回调
 */
- (void)isOnlineResponse:(NSDictionary *)response
{
    
}



@end
