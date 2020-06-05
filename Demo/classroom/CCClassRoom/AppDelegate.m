//
//  AppDelegate.m
//  CCClassRoom
//
//  Created by cc on 17/1/18.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "AppDelegate.h"
#import <SDImageCache.h>
#import "SULogger.h"
#import "CCExceptionHandler.h"
#import <OpenGLES/ES2/gl.h>
#import "CCTool.h"
#import "AFNetworking.h"
#import "GCPrePermissions.h"
#import <UIAlertView+BlocksKit.h>
#import "HDSDocManager.h"
#import <HDSSup/HDSSup.h>
#import <SDWebImageDownloader.h>

@interface AppDelegate ()

@property (nonatomic,retain) NSTimer *timer;

@end

@implementation AppDelegate
- (NSString *)objcetToJsonStr:(id)object
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:0 error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UIApplication sharedApplication].statusBarHidden = NO;
    [SDImageCache sharedImageCache].shouldDecompressImages = NO;
    [self testHttp];
    
#ifdef DEBUG
    [HDSSupManager setBuglyListen:@"f077e8b1d0"];
#else
    [HDSSupManager setBuglyListen:@"ab8bb5272c"];
#endif
    [CCStreamerBasic setLogInfoListen:YES];
    [CCStreamerBasic setLogState:NO];
    [CCCommonTool setNetTimeoutInterval:30];
    [self networkingState];
    ///检查隐私权限
    [self checkPrivacyPermissions];
    setenv("JSC_useJIT", "false", 0);
    [self chooseFillModel];
    [self choosePreviewGravityFollow];
    
    [self testCrash];
    SDImageCache *canche = [SDImageCache sharedImageCache];
    canche.shouldDecompressImages = NO;
    canche.maxMemoryCountLimit = 5;
    SDWebImageDownloader *downloder = [SDWebImageDownloader sharedDownloader];
    downloder.shouldDecompressImages = NO;
    return YES;
}

- (void)testCrash
{
    return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *arr = @[];
        [arr removeObjectAtIndex:5];
    });
}

///选择填充比例
-(void)chooseFillModel
{
    [HDSDocManager sharedDoc].voidModel = HDSRenderMode_AspactFit;
    return;
    [UIAlertView bk_showAlertViewWithTitle:@"渲染流模式" message:@"选择填充模式" cancelButtonTitle:@"自适应" otherButtonTitles:@[@"等比例填充"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [HDSDocManager sharedDoc].voidModel = HDSRenderMode_AspactFit;
            
        }else {
            [HDSDocManager sharedDoc].voidModel = HDSRenderMode_AspactFill;
        }
    }];
}
///选择填充比例
-(void)choosePreviewGravityFollow
{
    [HDSDocManager sharedDoc].isPreviewGravityFollow = NO;
    return;
    [UIAlertView bk_showAlertViewWithTitle:@"本地流预览" message:@"选择预览方式" cancelButtonTitle:@"设备方向跟随" otherButtonTitles:@[@"重力跟随"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [HDSDocManager sharedDoc].isPreviewGravityFollow = NO;
        }else {
            [HDSDocManager sharedDoc].isPreviewGravityFollow = YES;
        }
    }];
}

///模拟网络请求,访问网络权限
-(void)testHttp
{
    NSURL *url = [NSURL URLWithString:@"https://ccapi.csslcloud.net"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"%@",dict);
        }
    }];
    
    [dataTask resume];
}

-(void)checkPrivacyPermissions {
    
    [self checkCameraAuthorizationGrand];
    
    [self checkAudioAuthorizationGrand];
}


/// 检测相机的方法
- (void)checkCameraAuthorizationGrand
{
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (videoAuthStatus) {
        case AVAuthorizationStatusNotDetermined:
        {
            //第一次提示用户授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:
        {
            //通过授权
            
            break;
        }
        case AVAuthorizationStatusRestricted:
            //不能授权
            NSLog(@"不能完成授权，可能开启了访问限制");
        case AVAuthorizationStatusDenied:{
            //提示跳转到相机设置(这里使用了blockits的弹窗方法）
            {
                
                GCPrePermissions *permissions = [GCPrePermissions sharedPermissions];
                [permissions showAVPermissionsWithType:GCAVAuthorizationTypeCamera title:@"相机访问" message:@"云课堂需要在扫描二维码，及拍摄的时候访问相机" denyButtonTitle:@"暂不" grantButtonTitle:@"设置" completionHandler:^(BOOL hasPermission, GCDialogResult userDialogResult, GCDialogResult systemDialogResult) {
                    
                }];
            }
        }
            break;
        default:
            break;
    }
}

/// 检测麦克风的方法
- (void)checkAudioAuthorizationGrand
{
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (videoAuthStatus) {
        case AVAuthorizationStatusNotDetermined:
        {
            //第一次提示用户授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:
        {
            //通过授权
            
            break;
        }
        case AVAuthorizationStatusRestricted:
            //不能授权
            NSLog(@"不能完成授权，可能开启了访问限制");
        case AVAuthorizationStatusDenied:{
            //提示跳转到相机设置(这里使用了blockits的弹窗方法）
            {
                
                GCPrePermissions *permissions = [GCPrePermissions sharedPermissions];
                [permissions showAVPermissionsWithType:GCAVAuthorizationTypeMicrophone title:@"相机访问" message:@"用户拍摄的时候访问麦克风收录声音，及播放的时候访问麦克风" denyButtonTitle:@"暂不" grantButtonTitle:@"设置" completionHandler:^(BOOL hasPermission, GCDialogResult userDialogResult, GCDialogResult systemDialogResult) {
                    
                }];
            }
        }
            break;
        default:
            break;
    }
}

+ (void)requetSettingForAuth{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([ [UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window
{
    if (self.shouldNeedLandscape)
    {
        return UIInterfaceOrientationMaskLandscapeRight;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if (!url) {
        return NO;
    }
    NSString *urlStr = [url absoluteString];
    NSLog(@" schemeApp %@",urlStr);
    
    [self scheme:urlStr];
    
    return YES;
}

- (void)scheme:(NSString *)urlStr {
    NSLog(@"schemeApp  ");
    UINavigationController *_NAV = (UINavigationController *)(self.window.rootViewController);
    
    NSMutableArray * navArray = [_NAV.viewControllers mutableCopy];
    for (UIViewController *vc in navArray) {
        if ([vc isKindOfClass:NSClassFromString(@"CCLoginViewController")]) {
            [_NAV popToRootViewControllerAnimated:YES];
            break;
        }
    }
    
    if ([urlStr containsString:@"csslcloud://minclass?"] || [urlStr containsString:@"csslcloud://"]) {
        NSRange range = [urlStr rangeOfString:@"?"];
        if (range.length == 0) {
            urlStr = [urlStr stringByReplacingOccurrencesOfString:@"csslcloud://miniclass?" withString:@""];
        } else {
            urlStr = [urlStr substringFromIndex:(range.location + 1)];
        }
    }
    NSString *roomid = @"";NSString *userID = @"";NSString *role = @"";NSString *domain = @"";
    NSArray *arr = [urlStr componentsSeparatedByString:@"&"];
    for (NSString *name in arr) {
        if ([name containsString:@"roomid"]) {
            roomid = [name stringByReplacingOccurrencesOfString:@"roomid=" withString:@""];
            
        } else if ([name containsString:@"userid"]) {
            userID = [name stringByReplacingOccurrencesOfString:@"userid=" withString:@""];
            
        } else if ([name containsString:@"role"]) {
            role = [name stringByReplacingOccurrencesOfString:@"role=" withString:@""];
        } else if ([name containsString:@"domain"]) {
            domain = [name stringByReplacingOccurrencesOfString:@"domain=" withString:@""];
        }
    }
    [self appToRoomId:roomid role:role userId:userID domain:domain];
}

- (void)appToRoomId:(NSString *)roomId role:(NSString *)role userId:(NSString *)userId domain:(NSString *)domain {
    
    if (domain.length == 0 ) {
        [[CCStreamerBasic sharedStreamer]setServerDomain:@"class.csslcloud.net" area:nil];
        
    } else {
        [[CCStreamerBasic sharedStreamer]setServerDomain:domain area:nil];
    }
    
    if (roomId.length == 0 || role.length == 0 || userId.length == 0 || domain.length == 0) {
        NSLog(@"数据有问题");
        return;
    }
    
    [[CCStreamerBasic sharedStreamer] getRoomDescWithRoonID:roomId completion:^(BOOL result, NSError *error, id info) {
        NSLog(@"%s__%d__%@__%@__%@", __func__, __LINE__, @(result), error, info);
        if (result)
        {
            NSString *result = info[@"result"];
            if ([result isEqualToString:@"OK"])
            {
                UINavigationController *_NAV = (UINavigationController *)(self.window.rootViewController);
                
                NSString *name = info[@"data"][@"name"];
                NSString *desc = info[@"data"][@"desc"];
                NSString *authKey = [CCTool authTypeKeyForRole:role];
                
                SaveToUserDefaults(LIVE_ROOMNAME, name);
                SaveToUserDefaults(LIVE_ROOMDESC, desc);
                NSDictionary *userInfo = @{@"userID":userId, @"roomID":roomId, @"role":role, @"authtype":info[@"data"][authKey]};
                [_NAV popViewControllerAnimated:NO];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ScanSuccess" object:nil userInfo:userInfo];
                
            }
            else
            {
                UINavigationController *_NAV = (UINavigationController *)(self.window.rootViewController);
                
                [_NAV popViewControllerAnimated:NO];
            }
        }
        else
        {
        }
    }];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    glFinish();
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}
    

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    //    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    ///异常退出
    
    [[CCStreamerBasic sharedStreamer] leave:^(BOOL result, NSError *error, id info) {
        
    }];
    
}

//网络请求的时候传
- (void)networkingState {
//    return;
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case -1:
                NSLog(@"未知网络");
                break;
            case 0:
                NSLog(@"网络不可达");
                break;
            case 1:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GPRS" object:nil];
                NSLog(@"GPRS网络");
                break;
            case 2:
                NSLog(@"wifi网络");
                break;
            default:
                break;
        }
   
        /*
         指标：
         1.断网十秒后必然执行。
         2.在10s内，回复联网，不提示。
         */
        __block int i = 0;
        if(status ==AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi)
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:NONETWORK];
            [self showAlertView:NO];
            i = 0;
        } else {
            
            [[NSUserDefaults standardUserDefaults] setObject:@"noNetwork" forKey:NONETWORK];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            @try {
                _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
                    i++;
                    if (i==10) {
                        [self showAlertView:YES];
                    }
                }];
                [_timer fire];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            
            
        }
    }];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}


- (void)showAlertView:(BOOL)isShow{
    if (isShow) {
        
        [CCTool showMessage:@"网络已断开，请检查网络设置！"];
        [[NSNotificationCenter defaultCenter] postNotificationName:NONETWORK object:nil];
        
//        UIWindow *AW = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
//        
//        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"网络已断开，请检查网络设置！" message:nil preferredStyle:UIAlertControllerStyleAlert];
//        
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            //发送通知的名字
//            [[NSNotificationCenter defaultCenter] postNotificationName:NONETWORK object:nil];
//            
//            
//        }];
//        [alertVC addAction:cancelAction];
//
//        AW.rootViewController = [[UIViewController alloc]init];
//        AW.windowLevel = UIWindowLevelAlert + 1;
//        [AW makeKeyAndVisible];
//        [AW.rootViewController presentViewController:alertVC animated:YES completion:nil];
        
    }
    
    [_timer invalidate];
    _timer = nil;
}

@end
