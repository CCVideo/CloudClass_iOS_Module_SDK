//
//  CCDocAnimationView.m
//  AnimationTest
//
//  Created by cc on 17/12/7.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCDocAnimationView.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIImageView+WebCache.h>
#import "CCDocManager.h"
#import "CCDocDrawView.h"
#import <WebKit/WebKit.h>

@interface CCDocAnimationView()<UIWebViewDelegate, WKNavigationDelegate, WKScriptMessageHandler>
@property (strong, nonatomic) WKWebView *webView;
@property (copy,   nonatomic) AnimationBlock block;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) CCDocDrawView *drawView;
@property (assign, nonatomic) CGFloat imageWidth;
@property (assign, nonatomic) CGFloat imageHeight;
@property (assign, nonatomic) CGFloat scale;
@property (strong, nonatomic) NSString *docID;
@property (assign, nonatomic) NSInteger page;
@property (assign, nonatomic) CGRect initFrame;
@property (assign, nonatomic) NSInteger lastAnimationStep;
@property (assign, nonatomic) BOOL useSDK;
@property (strong, nonatomic) NSString *path;
@end

@implementation CCDocAnimationView
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.initFrame = frame;
    }
    self.backgroundColor = [UIColor whiteColor];
    return self;
}

- (void)loadImageView:(NSString *)path
{
    if (_imageView)
    {
        [_imageView removeFromSuperview];
        _imageView = nil;
    }
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.backgroundColor = [UIColor clearColor];
    [CCDocManager sharedManager].docParent.backgroundColor = [[UIColor alloc] initWithRed:1.f green:1.f blue:1.f alpha:0.2];
    __weak typeof(self) weakSelf = self;
    [_imageView sd_setImageWithURL:[NSURL URLWithString:path] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image)
        {
            CGFloat width = image.size.width;
            CGFloat height = image.size.height;
            CGFloat widthScale = weakSelf.initFrame.size.width/width;
            CGFloat heightScale = weakSelf.initFrame.size.height/height;
            CGFloat scale = widthScale < heightScale ? widthScale : heightScale;
            CGRect frame = CGRectMake(weakSelf.initFrame.origin.x + weakSelf.initFrame.size.width / 2 - width * scale / 2,
                                      weakSelf.initFrame.origin.y + weakSelf.initFrame.size.height / 2 - height * scale / 2,
                                      width * scale,
                                      height * scale);
            weakSelf.frame = frame;
            weakSelf.imageWidth = width;
            weakSelf.imageHeight = height;
            weakSelf.scale = scale;   
        }
//        if (weakSelf.useSDK)
//        {
//            NSString *path = [weakSelf.path stringByReplacingOccurrencesOfString:@".jpg" withString:@"/index.html"];
//            path = [path stringByReplacingOccurrencesOfString:@"https" withString:@"http"];
//            [self loadWebView:path];
//        }
        if (weakSelf.block)
        {
            weakSelf.block(nil);
        }
    }];
    [self addSubview:self.imageView];
    WS(ws);
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws);
    }];
}

- (void)loadDrawView:(NSArray *)drawData
{
    if (_drawView)
    {
        [_drawView removeFromSuperview];
        _drawView = nil;
    }
    _drawView = [[CCDocDrawView alloc] initWithFrame:self.frame DrawData:drawData];
    [self addSubview:self.drawView];
    WS(ws);
    [self.drawView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws);
    }];
}

- (void)loadWithUrl:(NSString *)path docID:(NSString *)docID useSDK:(BOOL)useSDK drawData:(NSArray *)drawData completion:(AnimationBlock)block
{
    self.currentStep  = -1;
    self.step = -1;
    self.docID = docID;
    self.lastAnimationStep = 0;
    self.useSDK = useSDK;
    self.path = path;
    self.imageWidth = 0.f;
    self.imageHeight = 0.f;
    
    [self cleanWebViewCache];
    if ([path hasPrefix:@"#"] || [path hasSuffix:@"#"])
    {
        self.frame = self.initFrame;
        [self.webView removeFromSuperview];
        [self.imageView removeFromSuperview];
        //白板
        if (block)
        {
            block(nil);
        }
    }
    else
    {
        self.block = block;
        [self loadImageView:path];
        if (useSDK)
        {
            path = [path stringByReplacingOccurrencesOfString:@".jpg" withString:@"/index.html"];
//            path = [path stringByReplacingOccurrencesOfString:@"https" withString:@"http"];
            [self loadWebView:path];
        }
    }
    [self loadDrawView:drawData];
}

- (void)cleanWebViewCache
{
    //清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    [self.webView loadRequest:nil];
    [self.webView stopLoading];
    [self.webView removeFromSuperview];
    self.webView = nil;
    self.webView.navigationDelegate = nil;
}

- (void)getAnimationStep
{
    __weak typeof(self) weakSelf = self;
    NSString *param = @"window.ANIMATIONSTEPSCOUNT";
    [self commitWithJSText:param completion:^(NSString *value) {
        if (value && [value integerValue] != -1)
        {
            weakSelf.step = [value integerValue] - 1;
        }
        else
        {
            [weakSelf getAnimationStep];
        }
    }];
    [self getCurrentStep];
}

- (void)getCurrentStep
{
    __weak typeof(self) weakSelf = self;
    NSString *param = @"window.TRIGGERED_ANIMATION_STEP";
    [self commitWithJSText:param completion:^(NSString *value) {
        if (value && [value integerValue] != -1)
        {
            weakSelf.currentStep = [value integerValue];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiGetAnimationStep object:nil userInfo:@{@"step":@(weakSelf.step)}];
        }
        else
        {
            [weakSelf getCurrentStep];
        }
    }];
}

- (void)gotoStep:(NSInteger)step
{
    if (self.docID.length > 0)
    {
        SaveToUserDefaults(DOC_ANIMATIONSTEP, @(step));
        self.lastAnimationStep = step;
        NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  self.docID,@"docid",
                                  @(self.page), @"page",
                                  @(step), @"step",
                                  nil];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        __block NSString *param = [NSString stringWithFormat:@"on_cc_live_dw_animation_change('%@')",jsonStr];
        [self commitWithJSText:param completion:^(NSString *value){}];
        self.currentStep = step;
    }
}

#pragma mark method
- (void)setDrawFrame:(CGRect)drawFrame
{
    self.frame = drawFrame;
    if (self.imageWidth == 0 || self.imageHeight == 0)
    {
        self.imageWidth = drawFrame.size.width;
        self.imageHeight = drawFrame.size.height;
    }
    CGFloat width = self.imageWidth;
    CGFloat height = self.imageHeight;
    CGFloat widthScale = self.frame.size.width/width;
    CGFloat heightScale = self.frame.size.height/height;
    CGFloat scale = widthScale < heightScale ? widthScale : heightScale;
    CGRect frame = CGRectMake(self.frame.origin.x + self.frame.size.width / 2 - width * scale / 2,
                              self.frame.origin.y + self.frame.size.height / 2 - height * scale / 2,
                              width * scale,
                              height * scale);
    self.frame = frame;
    self.initFrame = drawFrame;
    [self setNeedsDisplay];
    [self.webView reload];
}

- (void)gotoLastStep
{
    return [self.drawView gotoLastStep];
}

- (void)gotoNextStep
{
    return [self.drawView gotoNextStep];
}

- (void)clearAllDrawViews
{
    return [self.drawView clearAllDrawViews];
}

- (void)drawOneImageWithData:(NSDictionary*)drawDic
{
    return [self.drawView drawOneImageWithData:drawDic];
}

- (void)reloadData:(NSArray *)drawArr
{
    [self gotoStep:0];
    return [self.drawView reloadData:drawArr];
}

- (NSArray*)getCurrentDrawData
{
    return [self.drawView getCurrentDrawData];
}

- (NSInteger)changeToBack
{
    if (!self.useSDK)
    {
        return -1;
    }
    if (self.currentStep == -1 || self.step == -1)
    {
        return -200;
    }
    if (self.currentStep <= 0)
    {
        NSInteger step = 0;
        [self gotoStep:step];
        return -1;
    }
    else
    {
//        NSInteger step = self.currentStep - 1;
        NSInteger step = 0;
        [self gotoStep:step];
        return step;
    }
}

- (NSInteger)changeToFront
{
    if (!self.useSDK)
    {
        return -1;
    }
    if (self.currentStep == -1 || self.step == -1)
    {
        return -200;
    }
    if (self.currentStep >= self.step)
    {
        return -1;
    }
    else
    {
        NSInteger step = self.currentStep + 1;
        [self gotoStep:step];
        return step;
    }
}

#pragma mark - webview
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    if(webView == self.webView) {
//        self.webView.opaque = NO;
//        self.webView.backgroundColor = [UIColor whiteColor];
//        NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                  @"B83D400F3DE1A17E9C33DC5901307461",@"docid",
//                                  @1, @"page",
//                                  @(self.lastAnimationStep), @"step",
//                                  nil];
//        
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
//        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        __block NSString *param = [NSString stringWithFormat:@"on_cc_live_dw_animation_change('%@')",jsonStr];
//        __weak typeof(self) weakSelf = self;
//        [self commitWithJSText:param completion:^(NSString *value) {
//            
//            [weakSelf getAnimationStep];
//            
//        }];
//    }
//}
//
//-(UIWebView *)loadWebView:(NSString *)path
//{
//    if (_webView)
//    {
//        [_webView stopLoading];
//        [_webView removeFromSuperview];
//        _webView = nil;
//    }
//    if(!_webView)
//    {
//        _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
//        _webView.scalesPageToFit = YES;
//        [self addSubview:self.webView];
//        WS(ws);
//        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.edges.mas_equalTo(ws);
//                }];
//        NSURL *url = [NSURL URLWithString:path];
//        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
//        [_webView loadRequest:request];
//        _webView.delegate = self;
//    }
//    return _webView;
//}
//-(void)commitWithJSText:(NSString *)JSText completion:(void (^)(NSString *value))block
//{
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//       NSString *value = [_webView stringByEvaluatingJavaScriptFromString:JSText];
//        if (block)
//        {
//            block(value);
//        }
//    });
//}

#pragma mark - wkwebview
- (void)loadWebView:(NSString *)path
{
    if (_webView)
    {
        [_webView removeFromSuperview];
        _webView = nil;
    }
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [config.userContentController addScriptMessageHandler:self name:@"js_funcname"];

    _webView = [[WKWebView alloc] initWithFrame:self.frame];
    NSURL *url = [NSURL URLWithString:path];
    NSLog(@"---111   imageUrl = %@",url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [_webView loadRequest:request];
    _webView.navigationDelegate = self;
    [self addSubview:self.webView];
    WS(ws);
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws);
    }];
}

-(void)commitWithJSText:(NSString *)JSText completion:(void (^)(NSString *value))block
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.webView evaluateJavaScript:JSText completionHandler:^(id value, NSError * _Nullable error) {
            if (block)
            {
                block(value);
            }
        }];
    });
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"webView 加载失败:%@", error);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    if(webView == self.webView) {
        self.webView.opaque = NO;
        self.webView.backgroundColor = [UIColor whiteColor];
        NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"B83D400F3DE1A17E9C33DC5901307461",@"docid",
                                  @1, @"page",
                                  @(self.lastAnimationStep), @"step",
                                  nil];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        __block NSString *param = [NSString stringWithFormat:@"on_cc_live_dw_animation_change('%@')",jsonStr];
        __weak typeof(self) weakSelf = self;
        [self commitWithJSText:param completion:^(NSString *value) {
            
            [weakSelf getAnimationStep];
            
        }];
    }
}
#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    
}
@end
