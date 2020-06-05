//
//  PushViewController.h
//  NewCCDemo
//
//  Created by cc on 2016/12/2.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCBaseViewController.h"
#import "CCDrawMenuView.h"
#import "CCStreamerView.h"
#import "HDSChatView.h"
#import "HDSTool.h"

@interface CCPlayViewController : CCBaseViewController

- (id)initWithLandspace:(BOOL)landspace;
@property(nonatomic,strong)NSDictionary *loginInfo;
//控制学生是否订阅其它人员的音频
@property(nonatomic,assign)NSInteger  talker_audio;
@property(nonatomic,copy)  NSString             *viewerId;
@property(nonatomic,copy)  NSString             *sessionId;
@property(nonatomic,strong)UIImageView          *contentBtnView;
@property(nonatomic,strong)HDSChatView          *chatView;
@property(nonatomic,strong)UIImageView          *topContentBtnView;
@property(nonatomic,strong)UIView *timerView;
@property(nonatomic,assign)BOOL                  isLandSpace;
@property(nonatomic,strong)CCDrawMenuView *drawMenuView;
@property (strong, nonatomic) NSMutableArray *videoAndAudioNoti;
#pragma mark strong
@property(nonatomic,assign)CCRole roleType;
@property(nonatomic,assign)BOOL   isNeedPWD;

- (void)docPageChange;
//调整鲜花奖杯，聊天视图层次
- (void)changeKeyboardViewUp;
-(void)removeObserver;
- (void)loginOutWithBack:(BOOL)willBack;

#pragma mark -- 聊天视图
- (void)hiddenChatView:(BOOL)hidden;
@end
