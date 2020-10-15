//
//  DFScriptMessageHandlerManager.m
//  GoodDoctor
//
//  Created by ongfei on 2020/10/15.
//  Copyright © 2020 ongfei. All rights reserved.
//

#import "DFScriptMessageHandlerManager.h"

@interface DFScriptMessageHandlerManager()

@property (nonatomic, strong) NSArray *jsMessageArr;

@end

@implementation DFScriptMessageHandlerManager

kShareInstanceImplement(DFScriptMessageHandlerManager);

- (NSArray *)jsMessageArr {
    if (!_jsMessageArr) {
        _jsMessageArr = [NSArray arrayWithObjects:
                         @"jsNative_copy",
                         @"jsNative_stateBarHeight",
                         nil];
    }
    return _jsMessageArr;
}

//注册js调用原生的方法名
- (void)registJSMessageHandler:(WKUserContentController *)contentC {
    for (NSString *jsMessage in self.jsMessageArr) {
        [contentC addScriptMessageHandler:self name:jsMessage];
    }

}

- (void)removeAllScriptMessageHandlers:(WKUserContentController *)contentC {
    for (NSString *jsMessage in self.jsMessageArr) {
        [contentC removeScriptMessageHandlerForName:jsMessage];
    }
}

- (void)runJS:(WKWebView *)web function:(NSString *)functionName para:(id)para {
    [web evaluateJavaScript:[NSString stringWithFormat:@"%@('%@')",functionName,para] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
            //当js里面的方法有返回值时候，response就会有值，没有为null
        NSLog(@"response: %@ error: %@", response, error);
    }];
}

#pragma mark ================ WKScriptMessageHandler ================
//拦截执行网页中的JS方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    //服务器固定格式写法 window.webkit.messageHandlers.名字.postMessage(内容);
    //客户端写法 message.name isEqualToString:@"名字"]
    
    if ([self respondsToSelector:NSSelectorFromString([NSString stringWithFormat:@"%@::", message.name])]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@::", message.name]) withObject:message.webView withObject:message.body];
#pragma clang diagnostic pop
    }
}

- (void)jsNative_copy:(WKWebView *)webview para:(id)para {
    if (para) {
        [[UIPasteboard generalPasteboard] setString:para[@"copyStr"]];
    }
}

- (void)jsNative_stateBarHeight:(WKWebView *)webview para:(id)para {
    [self runJS:webview function:@"jsNative_stateBarHeight" para:@(kStateFrame.size.height)];
}

@end
