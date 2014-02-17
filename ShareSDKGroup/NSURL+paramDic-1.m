//
//  NSURL+ParamDic.m
//  CordovaLib
//
//  Created by administrator on 14-1-16.
//
//

#import "NSURL+ParamDic.h"

@implementation NSURL (ParamDic)

- (NSDictionary *)paramDic
{
    NSMutableDictionary *paramdic = [NSMutableDictionary dictionary];
    NSArray *paramComArr = [self.query componentsSeparatedByString:@"&"];
    for (NSString *subCom in paramComArr) {
        NSArray *k_v = [subCom componentsSeparatedByString:@"="];
        if ([k_v count] == 3) {
            [paramdic setObject:[NSString stringWithFormat:@"%@=%@",[k_v objectAtIndex:1],[k_v objectAtIndex:2] ]forKey:[k_v objectAtIndex:0]];
        } else {
            [paramdic setObject:[k_v objectAtIndex:1]forKey:[k_v objectAtIndex:0]];
        }
    }
    return paramdic;
}


@end
