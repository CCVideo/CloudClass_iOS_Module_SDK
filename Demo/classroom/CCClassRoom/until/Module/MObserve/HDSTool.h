//
//  HDSObserve.h
//  CCClassRoom
//
//  Created by Chenfy on 2019/12/24.
//  Copyright © 2019 cc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoadingView.h"
#import <Masonry.h>

#ifndef main_async_safe
#define main_async_safe(block)\
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }
#endif

NS_ASSUME_NONNULL_BEGIN
//回调Block
typedef void(^HDSToolResponse)(BOOL result ,id __nullable info ,NSError * __nullable error);

@interface HDSTool : NSObject
@property(nonatomic,assign)BOOL isCameraFront;

+ (instancetype)sharedTool;

#pragma mark -- 镜像相关
@property(nonatomic,assign)HSMirrorType mirrorType;

- (NSString *)mirrorText;
- (NSArray *)mirrorTypeArray;
- (void)updateMirrorType;

//更新AVAudiiosession配置
- (void)updateAVAudiosession;
//推流分辨率相关
- (void)updateLocalPushResolution;
- (void)resetSDKPushResolution;
- (NSString *)defaultResolutionString;

/** 分辨率选择 */
- (NSString *)userdefaultSelectedResolutionHeight;
- (void)userdefaultSetSelectedResolution:(NSString *)index;
- (void)removeUserdefaultSelectedResolution;

- (CCResolution)resolutionEnumFromInt:(int)type;
- (CCResolution)resolutionEnumFromHeightString:(NSString *)heightString;
- (int)resolutionIntFromHeightString:(NSString *)resolution;
- (int)resolutionIntFromEnumValue:(CCResolution)resolution;

#pragma mark -- loadingview
- (void)loadingViewShow:(NSString *)message view:(UIView *)view;
- (void)loadingViewDismiss;

#pragma mark -- UI部分
+ (UIImageView *)createImageViewName:(NSString *)name;
+ (UIButton *)createBtnCustom:(NSString *)normal hightLighted:(NSString *)lighted target:(id)tg action:(SEL)action;
+ (UIButton *)createBtnCustom:(NSString *)normal selected:(NSString *)selected target:(id)tg action:(SEL)action;

#pragma mark -- Function部分
+ (void)popToController:(Class)class navigation:(UINavigationController *)nav landscape:(BOOL)isLandscape;
//房间直播状态
+ (BOOL)roomLiveStatusOn;
//暖场视频数据处理
+ (void)roomWarmPlayInfo:(HDSToolResponse)block;
//申请相册访问权限
+ (void)photoLibraryAuth:(HDSToolResponse)block;

#pragma mark -- 音频状态修改
+ (BOOL)mediaSwitchUserid:(NSString *)uid state:(BOOL)open role:(CCRole)role response:(HDSToolResponse)block;

#pragma mark -- user info
- (CCUser *)toolGetUserFromStreamID:(NSString *)sid;
- (CCUser *)toolGetUserFromUserID:(NSString *)userid;

@end

NS_ASSUME_NONNULL_END
