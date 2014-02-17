//
//  NSURL+ParamDic.h
//  CordovaLib
//
//  Created by administrator on 14-1-16.
//
//

#import <Foundation/Foundation.h>

@interface NSURL (ParamDic)

/**
 * 解析URL以GET形式传递的参数
 */
- (NSDictionary *)paramDic;


@end
