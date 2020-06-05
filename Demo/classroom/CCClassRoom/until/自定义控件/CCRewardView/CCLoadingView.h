//
//  CCLoadingView.h
//  CCClassRoom
//
//  Created by cc on 2018/8/23.
//  Copyright © 2018年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

//流状态变更
#define KKEY_Loading_changed   @"ccstreamChanged"
//流切换 result":@"Tip" 长按提示 @“all” 恢复视频，@“audio” 转换音频
#define KKEY_Audio_changed   @"ccaudioChanged"

@interface CCLoadingView : UIView
#pragma mark copy
// 流id
@property(nonatomic,copy)NSString *sid;
@property (assign, nonatomic) BOOL isAnimating;

//用于提示文字
@property(nonatomic,copy)NSString *tipString;

+ (instancetype)createLoadingView;
+ (instancetype)createLoadingView:(NSString *)sid;

//开始加载
- (void)startLoading;
//停止加载
- (void)stopLoading;
@end
