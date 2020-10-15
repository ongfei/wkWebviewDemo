//
//  DFScriptMessageHandlerManager.h
//  GoodDoctor
//
//  Created by ongfei on 2020/10/15.
//  Copyright © 2020 ongfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppSysDefineMacro.h"
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DFScriptMessageHandlerManager : NSObject <WKScriptMessageHandler>

kShareInstance;
//注册js
- (void)registJSMessageHandler:(WKUserContentController *)contentC;
//移除js 防止内存泄漏
- (void)removeAllScriptMessageHandlers:(WKUserContentController *)contentC;

@end

NS_ASSUME_NONNULL_END
