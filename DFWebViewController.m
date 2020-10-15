//
//  DFWebViewController.m
//  GoodDoctor
//
//  Created by wanglai on 2020/5/22.
//  Copyright © 2020 ongfei. All rights reserved.
//

#import "DFWebViewController.h"
#import "masonry.h"
//#import "YYAnimatedImageView.h"
//#import "YYImage.h"


@interface DFWebViewController ()<WKNavigationDelegate,WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;
//@property (nonatomic,strong) YYAnimatedImageView * loadingImgView;
//设置加载进度条
@property (nonatomic,strong) UIProgressView *progressView;

@property (nonatomic, strong) DFWebViewNavigation *customNav;
//返回按钮
@property (nonatomic, strong) UIBarButtonItem *backBarItem;
//关闭按钮
@property (nonatomic, strong) UIBarButtonItem *closeBarItem;
@end

@implementation DFWebViewController

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[DFScriptMessageHandlerManager shareInstance] removeAllScriptMessageHandlers:self.webView.configuration.userContentController];
    [self.webView setNavigationDelegate:nil];
    [self.webView setUIDelegate:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    // h5控制导航
    if ([self.url containsString:@"hiddleNav=yes"]) {
        self.navigationController.navigationBar.hidden = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.titleStr;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"placeHH"] style:(UIBarButtonItemStyleDone) target:self action:nil];
    self.navigationItem.leftBarButtonItems = @[self.backBarItem];

    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
         self.automaticallyAdjustsScrollViewInsets = NO;
    }

    if (self.url) {
        [self loadRequestWithUrl:[self dealUrl]];
    }
    
//    self.loadingImgView.hidden = self.isHiddenLoading;
    //添加进度条
    [self.view addSubview:self.progressView];
}

#pragma mark -------------------------------------wkwebview代理---------------------------------------------------------------

//开始加载
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    //开始加载的时候，让加载进度条显示
//    self.loadingImgView.hidden = NO;
        //开始加载的时候，让加载进度条显示
    self.progressView.hidden = NO;
}
//结束加载
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
//    self.loadingImgView.hidden = YES;
    [self updateNavigationLeftItems];
}
//跳转方法
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    DLog(@"%@",webView.URL.absoluteString);
}

//服务器开始请求的时候调用
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    [self updateNavigationLeftItems];
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark ---------------------------------------------alert拦截-------------------------------------------------------
//在JS端调用alert函数时，会触发此代理方法。
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
//JS端调用confirm函数时，会触发此代理方法。
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
//JS端调用prompt函数时，会触发此代理方法
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -------------------------------------url处理---------------------------------------------------------------

- (WKNavigation *)loadRequest:(NSString *)url params:(NSDictionary *)params {
    self.url = url;
    self.params = [self dealDic:params];
    return [self loadRequestWithUrl:[self dealUrl]];
}

- (WKNavigation *)loadRequestWithUrl:(NSURL *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    return [self.webView loadRequest:request];
}

- (NSString *)dealDic:(NSDictionary *)dic {
    NSMutableString *str = [NSMutableString string];
    for (NSString *key in dic.allKeys) {
        [str appendFormat:@"%@=%@&",key,[dic valueForKey:key]];
    }
    return [str substringToIndex:str.length - 1];
}

- (NSURL *)dealUrl {
    //处理url
#warning 处理url
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@",self.url]];
}

#pragma mark ---------------------lazy webview-----------------------------------
static void *WkwebBrowserContext = &WkwebBrowserContext;
- (WKWebView *)webView {
    if (!_webView) {
        //设置网页的配置文件
        WKWebViewConfiguration * Configuration = [[WKWebViewConfiguration alloc]init];
        //允许视频播放
        Configuration.allowsAirPlayForMediaPlayback = YES;
        // 允许在线播放
        Configuration.allowsInlineMediaPlayback = YES;
        Configuration.mediaTypesRequiringUserActionForPlayback = NO;

        // 允许可以与网页交互，选择视图
        Configuration.selectionGranularity = YES;
        //自定义配置,一般用于 js调用oc方法(OC拦截URL中的数据做自定义操作)
        WKUserContentController *userContentController = [[WKUserContentController alloc]init];
        //js注入cookie
        NSString *cookieJS = [self updateCookieString];
        WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:cookieJS injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [userContentController addUserScript:cookieScript];
        //注册js调用原生的方法名
        [[DFScriptMessageHandlerManager shareInstance] registJSMessageHandler:userContentController];
        // 是否支持记忆读取
        Configuration.suppressesIncrementalRendering = YES;
        Configuration.processPool = [[WKProcessPool alloc] init];

        // 允许用户更改网页的设置
        Configuration.userContentController = userContentController;
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:Configuration];
        [self.view addSubview:_webView];

        // 设置代理
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        //kvo 添加进度监控
        [_webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:WkwebBrowserContext];
        [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
        //开启手势触摸
        _webView.allowsBackForwardNavigationGestures = YES;
        //设置UA
        [self setWebViewUA:_webView];
    }
    return _webView;
}

#pragma mark -------------------------------------设置UA---------------------------------------------------------------

- (void)setWebViewUA:(WKWebView *)webview {
    //设置版本号进UA
    NSString *addUserAgent = [NSString stringWithFormat:@"v%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
    if (@available(iOS 12.0, *)){
        //由于iOS12的UA改为异步，所以不管在js还是客户端第一次加载都获取不到，所以此时需要先设置好再去获取（1、如下设置；2、先在AppDelegate中设置到本地）
        NSString *userAgent = [webview valueForKey:@"applicationNameForUserAgent"];
        NSString *newUserAgent = [NSString stringWithFormat:@"%@ %@",userAgent,addUserAgent];
        [webview setValue:newUserAgent forKey:@"applicationNameForUserAgent"];
    }
    [webview evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSString *userAgent = result;
        if ([userAgent rangeOfString:addUserAgent].location != NSNotFound) {
            return ;
        }
        NSString *newUserAgent = [userAgent stringByAppendingString:addUserAgent];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:newUserAgent,@"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
        [[NSUserDefaults standardUserDefaults] synchronize];
         //不添加以下代码则只是在本地更改UA，网页并未同步更改
        [webview setCustomUserAgent:newUserAgent];
    }]; //加载请求必须同步在设置UA的后面
}
#pragma mark -------------------------------------设置cookie---------------------------------------------------------------

- (NSString *)updateCookieString {
    NSMutableString *cookieScript = [[NSMutableString alloc] init];
    [cookieScript appendFormat:@"document.cookie = 'cookie1=%@';", "cookie1"];
    [cookieScript appendFormat:@"document.cookie = 'cookie2=%@';","cookie2"];

    return cookieScript;
}
#pragma mark -------------------------------------模态进来的头---------------------------------------------------------------

- (void)setShowNavForPresent:(BOOL)showNavForPresent {
    _showNavForPresent = showNavForPresent;
    if (showNavForPresent) {
        self.customNav.backgroundColor = [UIColor whiteColor];
        self.customNav.titleL.text = self.titleStr;
    }
}

- (DFWebViewNavigation *)customNav {
    if (!_customNav) {
        _customNav = [[DFWebViewNavigation alloc] initWithFrame:CGRectZero];
        [self.view addSubview:_customNav];
        [_customNav mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.view);
            make.height.mas_equalTo([UIApplication sharedApplication].statusBarFrame.size.height + 44);
        }];
        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(_customNav.mas_bottom);
        }];
        [_customNav.backBtn addTarget:self action:@selector(backBtn) forControlEvents:(UIControlEventTouchUpInside)];
        
    }
    return _customNav;
}

#pragma mark -------------------自定义右侧按钮-----------------------
- (void)updateNavigationRightItems {
    
    [self.navigationItem setRightBarButtonItems:@[self.backBarItem,self.closeBarItem] animated:NO];
  
}

#pragma mark -------------------------------------自定义返回/关闭按钮---------------------------------------
- (void)updateNavigationLeftItems {
    if (self.webView.canGoBack) {
        [self.navigationItem setLeftBarButtonItems:@[self.backBarItem,self.closeBarItem] animated:NO];
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        [self.navigationItem setLeftBarButtonItems:@[self.backBarItem]];
    }
}

- (UIBarButtonItem *)backBarItem {
    if (!_backBarItem) {
        _backBarItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"nav_fanhui"] imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)] style:(UIBarButtonItemStyleDone) target:self action:@selector(backItemClicked)];
    }
    return _backBarItem;
}

- (UIBarButtonItem *)closeBarItem {
    if (!_closeBarItem) {
        _closeBarItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"nav_guanbi"]imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)] style:(UIBarButtonItemStyleDone) target:self action:@selector(closeItemClicked)];
    }
    return _closeBarItem;
}

- (void)backItemClicked {
    if (self.webView.goBack) {
        [self.webView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)closeItemClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backBtn {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -------------------------------------加载动画---------------------------------------------------------------

//-(YYAnimatedImageView *)loadingImgView {
//    if (!_loadingImgView) {
//        YYImage *image = [YYImage imageNamed:@"home_loading.gif"];
//        image.preloadAllAnimatedImageFrames = YES;
//        _loadingImgView= [[YYAnimatedImageView alloc] initWithImage:image];
//        _loadingImgView.autoPlayAnimatedImage = NO;
//        [_loadingImgView startAnimating];
//        _loadingImgView.hidden = YES;
//        [self.view addSubview:_loadingImgView];
//        [_loadingImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.height.mas_equalTo(120);
//            make.center.equalTo(self.view);
//        }];
//
//    }
//    return _loadingImgView;
//}

#pragma mark -------------------------------------KVO监听进度条&title--------------------------------------------------------------

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //设置title 从 web 获取
    if ([keyPath isEqualToString:@"title"]) {
        if (object == self.webView) {
            if (self.webView.title.length > 0) {
                self.title = self.webView.title;
            }
        }
    }
    //进度条
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.webView) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.webView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.webView.estimatedProgress animated:animated];
        
        // Once complete, fade out UIProgressView
        if(self.webView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
    
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame = CGRectMake(0, 0, self.view.frame.size.width, 3);
        // 设置进度条的色彩
        [_progressView setTrackTintColor:[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0]];
        _progressView.progressTintColor = [UIColor greenColor];
    }
    return _progressView;
}

-(void)dealloc{
    [self.webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [self.webView removeObserver:self forKeyPath:@"title"];

}

@end

@implementation DFWebViewNavigation

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [self addSubview:self.backBtn];
        [self.backBtn setBackgroundImage:[[UIImage imageNamed:@"yiji_gerenzhuye_fanhui_hei"] imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)] forState:(UIControlStateNormal)];
        [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom).offset(-5);
            make.left.equalTo(self).offset(10);
            make.width.height.mas_equalTo(18);
        }];
        self.titleL = [UILabel new];
        [self addSubview:self.titleL];
        self.titleL.textAlignment = NSTextAlignmentCenter;
        self.titleL.font = [UIFont systemFontOfSize:18];
        [self.titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backBtn.mas_right).offset(20);
            make.right.equalTo(self.mas_right).offset(-20);
            make.centerY.equalTo(self.backBtn);
        }];
    }
    return self;
}

@end
