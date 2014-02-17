//
//  DLog.h
//  HPOdemo
//
//  Created by administrator on 14-2-11.
//  Copyright (c) 2014年 Gueie. All rights reserved.
//

#ifndef HPOdemo_DLog_h
#define HPOdemo_DLog_h

#ifndef __OPTIMIZE__

#define NSLog(...) NSLog(__VA_ARGS__)

#else

#define NSLog(...) {}

#endif


#ifndef __OPTIMIZE__

#define DLog(...) NSLog(__VA_ARGS__)

#else

#define DLog(...) /* */

#endif


#define ALog(...) NSLog(__VA_ARGS__)



#endif
