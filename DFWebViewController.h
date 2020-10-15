//
//  DFWebViewController.h
//  GoodDoctor
//
//  Created by wanglai on 2020/5/22.
//  Copyright © 2020 ongfei. All rights reserved.
//
/// wkwebview

#import <UIKit/UIKit.h>
#import "AppSysDefineMacro.h"
#import "DFScriptMessageHandlerManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface DFWebViewController : UIViewController

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *params;
@property (nonatomic, strong) NSString *titleStr;
@property (nonatomic, assign) BOOL isHiddenLoading;
@property (nonatomic, assign) BOOL showNavForPresent;

@property (nonatomic, copy) void(^goBackBlock)(void);


- (WKNavigation *)loadRequest:(NSString *)url params:(NSDictionary *)params;

@end

@interface DFWebViewNavigation : UIView

@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UILabel *titleL;

@end

NS_ASSUME_NONNULL_END
