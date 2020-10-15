//
//  AppSysDefineMacro.h
//  GoodDoctor
//
//  Created by ongfei on 2020/6/8.
//  Copyright © 2020 ongfei. All rights reserved.
//

#ifndef AppSysDefineMacro_h
#define AppSysDefineMacro_h

#define DLog(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#define kSafeAreaInsets [UIApplication sharedApplication].keyWindow.safeAreaInsets
#define kStateFrame  [UIApplication sharedApplication].statusBarFrame
#define kNavHeight  kStateFrame.size.height > 20 ?  88 : 64
#define kTabbarHeight  kStateFrame.size.height > 20 ?  83 : 49



#pragma mark -------------------------------------instance--------------------------------------
#define kShareInstance  + (instancetype)shareInstance;

#define kShareInstanceImplement(class) \
\
static class *_shareInstance; \
\
+ (instancetype)shareInstance { \
\
if(_shareInstance == nil) {\
_shareInstance = [[class alloc] init]; \
} \
return _shareInstance; \
} \
\
+(instancetype)allocWithZone:(struct _NSZone *)zone { \
\
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_shareInstance = [super allocWithZone:zone]; \
}); \
\
return _shareInstance; \
\
}


#pragma mark -------------------------------------<##>Adapt---------------------------------------------------------------
#define  adjustsScrollViewInsets_NO(scrollView,vc)\
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
if ([UIScrollView instancesRespondToSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:")]) {\
[scrollView performSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:") withObject:@(2)];\
} else {\
vc.automaticallyAdjustsScrollViewInsets = NO;\
}\
_Pragma("clang diagnostic pop") \
} while (0)


#endif /* AppSysDefineMacro_h */
