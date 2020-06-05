//
//  CCDocViewController.h
//  CCClassRoom
//
//  Created by cc on 17/3/30.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCBaseViewController.h"
//应该是CCStreamerView这个类，用来添加数据。
#import "CCStreamerView.h"

#define CCNotiDocViewControllerClickSamll @"CCNotiDocViewControllerClickSamll"


@interface CCDocViewController : CCBaseViewController
@property (strong, nonatomic) UIView *docView;


@property (strong, nonatomic) CCStreamerView *streamView;
- (id)initWithDocView:(UIView *)view streamView:(CCStreamerView *)streamView;
- (void)showOrHideDrawView:(BOOL)show calledByDraw:(BOOL)calledByDraw;
- (void)docPageChange;
- (void)videoSuspendShowOrHideDrawView:(BOOL)show;//视频暂停标注隐藏或者显示画笔操作栏
/** 计时器 */
- (void)startTimeTimer;
- (void)stopTimeTimer;
@end
