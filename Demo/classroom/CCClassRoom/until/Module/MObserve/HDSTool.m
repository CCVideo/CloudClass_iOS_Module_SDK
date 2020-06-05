//
//  HDSObserve.m
//  CCClassRoom
//
//  Created by Chenfy on 2019/12/24.
//  Copyright © 2019 cc. All rights reserved.
//

#import "HDSTool.h"
#import <AFNetworking.h>
#import "AppDelegate.h"
#import <Photos/Photos.h>

/** 分辨率选择 */
#define HDS_KEY_PICKVIEW_RESOLUTION @"pickerViewSelectedIndex"

@interface HDSTool()
//加载loadingview
@property(nonatomic,strong)LoadingView *loadingView;

@end

@implementation HDSTool

static HDSTool *_tool = nil;

+ (instancetype)sharedTool
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tool = [[HDSTool alloc]init];
        _tool.isCameraFront = YES;
    });
    return _tool;
}

- (NSString *)mirrorText
{
    return self.mirrorTypeArray[self.mirrorType];
}

- (NSArray *)mirrorTypeArray
{
    return @[@"本地镜像，远程不镜像",
             @"本地镜像，远程镜像",
             @"本地不镜像，远程不镜像",
             @"本地不镜像，远程镜像"];
}

- (void)updateMirrorType
{
    [[self client]setVideoMirrorMode:self.mirrorType];
}

- (CCStreamerBasic *)client
{
    return [CCStreamerBasic sharedStreamer];
}
- (CCRoom *)roomInfo
{
    return [[self client]getRoomInfo];
}

- (void)updateAVAudiosession
{
    dispatch_async(dispatch_get_main_queue(), ^{
        AVAudioSession *session = [AVAudioSession sharedInstance];
        AVAudioSessionCategory category = AVAudioSessionCategoryPlayAndRecord;
        category = AVAudioSessionCategoryPlayAndRecord;
        
        [session setCategory:category withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionAllowBluetooth error:nil];
        [session setActive:YES error:nil];
    });
}
//获取最大值
- (int)defaultResolutionEnumeOrHeight:(BOOL)isEnum
{
    CCRoom *room = [self roomInfo];
    int default_height = (int)room.room_default_resolution;
    int index = 0;
    if (default_height == 0 || default_height == 240) {
        index = 0;
        default_height = 240;
    }
    else if (default_height == 480) {
        index = 1;
    }
    else if(default_height == 720) {
        index = 2;
    }
    if (isEnum) {
        return index;
    }
    return default_height;
}

- (void)updateLocalPushResolution
{
    NSString *userSeted = [self userdefaultSelectedResolutionHeight];
    if (userSeted == nil) {
        NSString *roomResolution = [NSString stringWithFormat:@"%ld",(long)[self roomInfo].room_default_resolution];
        [self userdefaultSetSelectedResolution:roomResolution];
        return;
    }
    //选好的string
    NSInteger setedHeight = [userSeted integerValue];
    NSInteger room_max_Height = [[self roomInfo]room_max_resolution];
    
    if (setedHeight > room_max_Height) {
        NSString *stringResolution = [NSString stringWithFormat:@"%ld",(long)room_max_Height];
        [self userdefaultSetSelectedResolution:stringResolution];
        return;
    }
    [self userdefaultSetSelectedResolution:userSeted];
}

- (void)resetSDKPushResolution
{
    NSString *userSeted = [self userdefaultSelectedResolutionHeight];
    if (userSeted == nil) {
        return;
    }
    CCResolution resolution = [self resolutionEnumFromHeightString:userSeted];
    [[self client] setResolution:resolution];;
}


- (NSString *)defaultResolutionString
{
    NSString *default_height = [self userdefaultSelectedResolutionHeight];
    NSString *resolutionString = [NSString stringWithFormat:@"%@P",default_height];
    return resolutionString;
}
 
/** 分辨率选择 */
- (NSString *)userdefaultSelectedResolutionHeight
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:HDS_KEY_PICKVIEW_RESOLUTION];
}
- (void)userdefaultSetSelectedResolution:(NSString *)index
{
    [[NSUserDefaults standardUserDefaults]setObject:index forKey:HDS_KEY_PICKVIEW_RESOLUTION];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)removeUserdefaultSelectedResolution
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:HDS_KEY_PICKVIEW_RESOLUTION];
}

- (CCResolution)resolutionEnumFromInt:(int)type
{
    CCResolution resolution = type;
    return resolution;
}

- (CCResolution)resolutionEnumFromHeightString:(NSString *)heightString
{
    int enumeIndex = [self resolutionIntFromHeightString:heightString];
    CCResolution resolution = [self resolutionEnumFromInt:enumeIndex];
    return resolution;
}

- (int)resolutionIntFromHeightString:(NSString *)resolution
{
    if ([resolution isEqualToString:@"240"]) {
        return 0;
    } else if ([resolution isEqualToString:@"480"]) {
        return 1;
    } else if ([resolution isEqualToString:@"720"]) {
        return 2;
    }
    return 0;
}
- (int)resolutionIntFromEnumValue:(CCResolution)resolution
{
    return (int)resolution;
}

- (void)loadingViewShow:(NSString *)message view:(UIView *)view
{
    [self loadingViewDismiss];
    if (!message) {
        message = @"加载中";
    }
    _loadingView = [[LoadingView alloc] initWithLabel:message];
    [view addSubview:_loadingView];
    [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}
- (void)loadingViewDismiss
{
    if (_loadingView)
    {
        [_loadingView removeFromSuperview];
    }
}

+ (UIImageView *)createImageViewName:(NSString *)name
{
    UIImageView *imgV = [[UIImageView alloc] init];
    imgV.image = [UIImage imageNamed:name];
    return imgV;
}

+ (UIButton *)createBtnCustom:(NSString *)normal hightLighted:(NSString *)lighted target:(id)tg action:(SEL)action
{
    UIButton *sendPicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendPicButton setBackgroundImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
    [sendPicButton setBackgroundImage:[UIImage imageNamed:lighted] forState:UIControlStateHighlighted];
    [sendPicButton addTarget:tg action:action forControlEvents:UIControlEventTouchUpInside];
    return sendPicButton;
}
+ (UIButton *)createBtnCustom:(NSString *)normal selected:(NSString *)selected target:(id)tg action:(SEL)action
{
    UIButton *sendPicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendPicButton setBackgroundImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
    [sendPicButton setBackgroundImage:[UIImage imageNamed:selected] forState:UIControlStateSelected];
    [sendPicButton addTarget:tg action:action forControlEvents:UIControlEventTouchUpInside];
    return sendPicButton;
}



//判断房间是否已经开始直播
+ (void)popToController:(Class)class navigation:(UINavigationController *)nav landscape:(BOOL)isLandscape
{
    if (!nav) {
        return;
    }
    if (nav.topViewController == nav.visibleViewController)
    {
        //是push的
        for (UIViewController *vc in nav.viewControllers)
        {
            if ([vc isKindOfClass:class])
            {
                if (isLandscape)
                {
                    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    appdelegate.shouldNeedLandscape = NO;
                    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
                    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
                }
                [nav popToViewController:vc animated:YES];
            }
        }
    }
    else
    {
        [nav dismissViewControllerAnimated:NO completion:^{
            for (UIViewController *vc in nav.viewControllers)
            {
                if ([vc isKindOfClass:class])
                {
                    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    appdelegate.shouldNeedLandscape = NO;
                    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
                    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
                    [nav popToViewController:vc animated:YES];
                }
            }
        }];
    }

}

+ (BOOL)roomLiveStatusOn
{
    CCLiveStatus status = [[CCStreamerBasic sharedStreamer]getRoomInfo].live_status;
    return status == CCLiveStatus_Start ? YES:NO;
}

+ (void)roomWarmPlayInfo:(HDSToolResponse)block
{
    if (!block) return;
    
    NSDictionary *warmDic = [[CCStreamerBasic sharedStreamer]getRoomInfo].warmVideoDic;
    //暖场动画 1 开启 | 0 关闭
    NSString *openVideo = warmDic[@"video_id"];
    int playStatus = [warmDic[@"play"] intValue];
    
    if (!openVideo && [openVideo length] == 0 && playStatus != 1)
    {
        return;
    }
    NSString *urlString = @"https://ccapi.csslcloud.net/api/v1/serve/video/playurl";
    /*
     | account_id |字符串  | 账号ID | 必须 |
     | video_id|字符串| 视频ID| 必须 |
     | media_type|整型| 类型 1:视频 2:音频| 可选，默认视频 |
     */
    NSString *userID = GetFromUserDefaults(LIVE_USERID);
    int media_type = [warmDic[@"media_type"] intValue];
    NSString *video_id = warmDic[@"video_id"];
    NSDictionary *par = @{
        @"account_id":userID,
        @"video_id":video_id,
        @"media_type":@(media_type)
    };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:urlString parameters:par success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (!responseObject) {
            block(NO,nil,[HDSTool errorWarmPlay:@"获取数据为空！"]);
            return ;
        }
        NSDictionary *dicRes = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"warplay__%@",dicRes);
        if (!dicRes)
        {
            block(NO,nil,[HDSTool errorWarmPlay:@"获取数据解析异常！"]);
            return;
        }
        if (![dicRes[@"result"] isEqualToString:@"OK"])
        {
            block(NO,nil,[HDSTool errorWarmPlay:@"获取数据result失败！"]);
            return ;
        }
        block(YES,dicRes,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(NO,nil,error);
        NSLog(@"warm_play_error!");
    }];
}

+ (NSError *)errorWarmPlay:(NSString *)message
{
    NSError *error = [NSError errorWithDomain:message code:10 userInfo:nil];
    return error;
}

+ (void)photoLibraryAuth:(HDSToolResponse)block
{
    if (!block) {
        return;
    }
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch(status) {
        case PHAuthorizationStatusNotDetermined: {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if(status == PHAuthorizationStatusAuthorized) {
                    block(YES,nil,nil);
                } else if(status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
                    block(NO,nil,nil);
                }
            }];
        }
            break;
        case PHAuthorizationStatusAuthorized: {
            block(YES,nil,nil);
        }
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied: {
            block(NO,nil,nil);
        }
            break;
        default:
            break;
    }
}

#pragma mark -- 音频状态修改
+ (BOOL)mediaSwitchUserid:(NSString *)uid state:(BOOL)open role:(CCRole)role response:(HDSToolResponse)block
{
    return [[CCStreamerBasic sharedStreamer]mediaSwitchAudioUserid:uid state:open role:role completion:^(BOOL result, NSError *error, id info) {
        block(result,info,error);
    }];
}

#pragma mark -- user info
- (CCUser *)toolGetUserFromStreamID:(NSString *)sid
{
    CCUser  *user = [[self client]getUserInfoWithStreamID:sid];
    return user;
}
- (CCUser *)toolGetUserFromUserID:(NSString *)userid
{
    CCUser *user = [[self client]getUSerInfoWithUserID:userid];
    return user;
}



@end
