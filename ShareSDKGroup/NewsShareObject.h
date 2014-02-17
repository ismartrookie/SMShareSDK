//
//  NewsShareObject.h
//  CordovaLib
//
//  Created by administrator on 14-1-16.
//
//

#import <Foundation/Foundation.h>

@interface NewsShareObject : NSObject

@property (copy, nonatomic) NSString *shareContent; //分享内容，非空
@property (copy, nonatomic) NSString *shareTopic;   //分享标题，可空
@property (copy, nonatomic) NSString *shareDesc;    //分享描述，可空
@property (copy, nonatomic) NSString *shareMessSrc; //消息出处，可空
@property (copy, nonatomic) NSString *shareGotoUrl; //跳转地址，可空
@property (copy, nonatomic) NSString *shareIcon;    //分享Logo，可空
@property (copy, nonatomic) NSData   *shareIconData;//分享LogoData，可空

@end
