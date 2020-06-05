//
//  CCStreamView.m
//  CCClassRoom
//
//  Created by cc on 17/2/22.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCStreamerView.h"
#import <BlocksKit+UIKit.h>
#import "CCStreamModeTeach.h"
#import "CCStreamModeSingle.h"
#import "CCStreamerModeTile.h"
#import "CCPlayViewController.h"
#import "CCStreamModeTeach_Teacher.h"
#import "CCStreamModeSpeak.h"
#import "SelVideoPlayer.h"
#import "CCPlayerConfig.h"
#import "HDSDocManager.h"

@interface CCStreamerView()
@property (assign, nonatomic) CCRoomTemplate mode;
@property (assign, nonatomic) CCRole role;
@property (strong, nonatomic) UIView *backView;//未上课的时候显示的
@property (assign, nonatomic) BOOL backViewIsShow;//未上课图是否显示
@property (strong, nonatomic) NSTimer *autoHiddenTimer;
//暖场动画
@property (strong, nonatomic) SelVideoPlayer *ccPlayerView;
@property (copy, nonatomic) NSString *playUrlString;
@end

@implementation CCStreamerView
- (void)configWithMode:(CCRoomTemplate)mode role:(CCRole)role
{
    [self stopTimer];
    _mode = mode;
    _role = role;
    __weak typeof(self) weakSelf = self;
    if (self.steamSpeak)
    {
        [self.steamSpeak addBack];
//        [self.steamSpeak removeFromSuperview];
//        self.steamSpeak = nil;
    }
    if (self.streamSingle)
    {
        [self.streamSingle addBack];
        [self.streamSingle removeFromSuperview];
        self.streamSingle = nil;
    }
    if (self.streamTile)
    {
        [self.streamTile addBack];
        [self.streamTile removeFromSuperview];
        self.streamTile = nil;
    }
    
    NSArray *local = [NSArray arrayWithArray:self.showViews];
    if(mode ==CCRoomTemplateSpeak)
    {
        if (!self.steamSpeak)
        {
            self.steamSpeak = [[CCStreamModeSpeak alloc] initWithLandspace:self.isLandSpace];
        }
        self.steamSpeak.showVC = self.showVC;
        [self addSubview:self.steamSpeak];
        
        UIView *newView = self.steamSpeak.docView;
        HDSDocManager *hdsM = [HDSDocManager sharedDoc];
        CCDocVideoView *videoV = [hdsM hdsDocView];
        [newView addSubview:videoV];
        [hdsM setDocParentView:self.steamSpeak.docView];
        
        [self.steamSpeak.docView sendSubviewToBack:videoV];
        [self.steamSpeak mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf).mas_offset(0);
        }];
        for (CCStreamView *view in local)
        {
            [self.steamSpeak showStreamView:view];
        }
        if (self.role == CCRole_Teacher || self.role == CCRole_Assistant)
        {
            if (self.isLandSpace)
            {
//                                [[CCDocManager sharedManager] showOrHideDrawView:NO];
            }
            [[HDSDocManager sharedDoc]beAuthTeacher];
            [self.steamSpeak setRole:CCStreamModeSpeakRole_Teacher];
        }
        else if(self.role == CCRole_Student)
        {
            [self.steamSpeak setRole:CCStreamModeSpeakRole_Student];
            //添加绘图层
            NSString *userID = [CCStreamerBasic sharedStreamer].getRoomInfo.user_id;
            for (CCUser *user in [CCStreamerBasic sharedStreamer].getRoomInfo.room_userList)
            {
                if ([user.user_id isEqualToString:userID])
                {
                    if ((user.user_AssistantState || user.user_drawState) && self.isLandSpace)
                    {
                        [[HDSDocManager sharedDoc]beEditable];
                        //                        [[CCDocManager sharedManager] showOrHideDrawView:NO];
                    }
                    if (user.user_AssistantState)
                    {
                        [[HDSDocManager sharedDoc]beAuthTeacher];
                        [self.steamSpeak setRole:CCStreamModeSpeakRole_Assistant];
                    }
                    else
                    {
                        [self.steamSpeak setRole:CCStreamModeSpeakRole_Student];
                    }
                    break;
                }
            }
        }
        else if(self.role == CCRole_Inspector)
        {
            [self.steamSpeak setRole:CCStreamModeSpeakRole_Inspector];
        }
    }
    else if (mode == CCRoomTemplateSingle )
    {
        self.streamSingle = [[CCStreamModeSingle alloc] initWithLandspace:self.isLandSpace];
        self.streamSingle.showVC = self.showVC;
        [self addSubview:self.streamSingle];
        [self.streamSingle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(weakSelf).offset(0.f);
        }];
        for (CCStreamView *view in local)
        {
            [self.streamSingle showStreamView:view];
        }
    }
    else if (mode == CCRoomTemplateTile)
    {
        self.streamTile = [[CCStreamerModeTile alloc] init];
        self.streamTile.showVC = self.showVC;
        [self addSubview:self.streamTile];
        [self.streamTile mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.edges.mas_equalTo(weakSelf).offset(0.f);
            make.edges.mas_equalTo(weakSelf);
        }];
        for (CCStreamView *view in local)
        {
            [self.streamTile showStreamView:view.stream];
        }
    }
    else if (mode == CCRoomTemplateDoubleTeacher)
    {
        if (role == CCRole_Teacher)
        {
            self.streamTile = [[CCStreamerModeTile alloc] init];
                   self.streamTile.showVC = self.showVC;
                   [self addSubview:self.streamTile];
                   [self.streamTile mas_remakeConstraints:^(MASConstraintMaker *make) {
                       make.edges.mas_equalTo(weakSelf).offset(0.f);
                   }];
                   for (CCStreamView *view in local)
                   {
                       [self.streamTile showStreamView:view.stream];
                   }
        }
        else
        {
            self.streamSingle = [[CCStreamModeSingle alloc] initWithLandspace:self.isLandSpace];
            self.streamSingle.showVC = self.showVC;
            [self addSubview:self.streamSingle];
            [self.streamSingle mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(weakSelf).offset(0.f);
            }];
            for (CCStreamView *view in local)
            {
                [self.streamSingle showStreamView:view];
            }
        }
    }
    if (self.backViewIsShow)
    {
        [self showBackView];
    }
}

- (void)showBackView
{
    self.backViewIsShow = YES;
    if (!self.backView)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
        UIImageView *bokeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"book"]];
        UILabel *label = [[UILabel alloc] init];
        label.text = @"还没上课，先休息一会儿";
        label.textColor = [UIColor whiteColor];
        [label sizeToFit];
        
        [imageView addSubview:bokeView];
        [imageView addSubview:label];
        imageView.userInteractionEnabled = YES;
        
        [bokeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(imageView);
            make.centerY.mas_equalTo(imageView);
        }];
        
        [label mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(imageView);
            make.top.mas_equalTo(bokeView.mas_bottom).offset(10.f);
        }];
        
        [imageView addSubview:self.ccPlayerView];
        
        [self.ccPlayerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(imageView);
        }];
        self.backView = imageView;
        [self addSubview:self.backView];
        __weak typeof(self) weakSelf = self;
        [self.backView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(weakSelf);
        }];
    }
    [self bringSubviewToFront:self.backView];
    self.backView.hidden = NO;
    //call操作栏取消定时隐藏
    if (self.streamTile)
    {
        [self.streamTile addBack];
    }
    if (self.streamSingle)
    {
        [self.streamSingle addBack];
    }
    if (self.steamSpeak)
    {
        [self.steamSpeak addBack];
    }
}

- (void)removeBackView
{
    //直播开始，停止暖场视频
    //如果想在不直播的时候一直播放，只要把下面这行代码注释掉就OK了
    [self stopWarmPlayVideo];
    [self stop_warm_play_delay];

    self.backViewIsShow = NO;
    [self sendSubviewToBack:self.backView];
    self.backView.hidden = YES;
    
    //开启自动隐藏
    if (self.streamTile)
    {
        [self.streamTile removeBack];
    }
    if (self.streamSingle)
    {
        [self.streamSingle removeBack];
    }
    if (self.steamSpeak)
    {
        [self.steamSpeak removeBack];
    }
}

- (void)showStreamView:(CCStreamView *)view
{
    if ([[CCStreamerBasic sharedStreamer] getRoomInfo].live_status == CCLiveStatus_Start) {
        [self removeBackView];
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!view)
        {
            SLog(@"%s___show nil view", __func__);
            return;
        }
        [weakSelf addVideoAndAudioImageView:view];
        //判断是否添加音视频的贴图
        for (CCUser *user in [[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList)
        {
           NSLog(@"==view.stream.role==%d",view.stream.role); NSLog(@"~~~~~~~~~~~~判断是否添加音视频的贴图user.user_uid:%@~~~view.stream.userID:%@",user.user_uid,view.stream.userID);
            if ([user.user_id isEqualToString:view.stream.userID])
            {
                [weakSelf stream:view videoOpened:user.user_videoState];
            }
            //视图角色身份
            if (view.stream.role == CCRole_Student)
            {
                CCVideoMode micType = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_video_mode;
                UIImageView *imageView = [view viewWithTag:NOVideoImageViewTag];
                NSLog(@"==micType==%d",micType);
                imageView.hidden = (micType == CCVideoMode_Audio ? NO : YES);
            }
        }
        
        if ([view.stream.userID isEqualToString:ShareScreenViewUserID])
        {
            //共享桌面
            UIImageView *imageView = [view viewWithTag:NOVideoImageViewTag];
            imageView.hidden = YES;
            
            UIImageView *imageView1 = [view viewWithTag:NOCameraImageViewTag];
            imageView1.hidden = YES;
        }
        if (!weakSelf.showViews)
        {
            weakSelf.showViews = [NSMutableArray array];
        }
        
        [weakSelf.showViews addObject:view];
        if (weakSelf.mode ==CCRoomTemplateSpeak)
        {
            [weakSelf.steamSpeak showStreamView:view];
        }
        else if (weakSelf.mode == CCRoomTemplateTile)
        {
            [weakSelf.streamTile showStreamView:view];
        }
        else if(weakSelf.mode == CCRoomTemplateSingle )
        {
            [weakSelf.streamSingle showStreamView:view];
        }
        else if(weakSelf.mode == CCRoomTemplateDoubleTeacher)
        {
            if (weakSelf.role == CCRole_Teacher)
            {
                [weakSelf.streamTile showStreamView:view];
            }
            else
            {
              [weakSelf.streamSingle showStreamView:view];
            }
        }
    });
}

- (void)removeStreamView:(CCStreamView *)view
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        SLog(@"%s__%d__%@", __func__, __LINE__, view.stream.streamID);
        NSArray *localShowViews = [NSArray arrayWithArray:weakSelf.showViews];
        NSInteger oldCount = localShowViews.count;
        for (CCStreamView *localView in localShowViews)
        {
            SLog(@"%@__%@", localView.stream.streamID, view.stream.streamID);

            if ([localView.stream.streamID isEqualToString:view.stream.streamID])
            {
                SLog(@"%s__%d__%@移除成功", __func__, __LINE__, view.stream.streamID);
                [weakSelf.showViews removeObject:localView];
                break;
            }
        }
        [weakSelf.showViews removeObject:view];
        NSInteger newcount = weakSelf.showViews.count;
        if (oldCount == newcount)
        {
            SLog(@"removeStreamView移除视图错误:%@", view.stream.streamID);
        }
        if (weakSelf.mode == CCRoomTemplateSpeak)
        {
            [weakSelf.steamSpeak removeStreamView:view];
        }
        else if (weakSelf.mode == CCRoomTemplateTile)
        {
            [weakSelf.streamTile removeStreamView:view.stream];
        }
        else if(weakSelf.mode == CCRoomTemplateSingle )
        {
            [weakSelf.streamSingle removeStreamView:view];
        }
        else if(weakSelf.mode == CCRoomTemplateDoubleTeacher)
        {
            if(weakSelf.role == CCRole_Teacher)
            {
                [weakSelf.streamTile removeStreamView:view.stream];
            }
            else
            {
                [weakSelf.streamSingle removeStreamView:view];
            }
        }
    });
}
- (void)removeStreamViewAll
{
    WeakSelf(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.mode == CCRoomTemplateSpeak)
        {
            [weakSelf.steamSpeak removeStreamViewAll];
        }
        else if (weakSelf.mode == CCRoomTemplateTile)
        {
            [weakSelf.streamTile removeStreamViewAll];
        }
        else if(weakSelf.mode == CCRoomTemplateSingle )
        {
            [weakSelf.streamSingle removeStreamViewAll];
        }
        else if(weakSelf.mode == CCRoomTemplateDoubleTeacher)
        {
            if(weakSelf.role == CCRole_Teacher)
            {
                [weakSelf.streamTile removeStreamViewAll];
            }
            else
            {
                [weakSelf.streamSingle removeStreamViewAll];
            }
        }
        [self.showViews removeAllObjects];
    });

}


- (void)removeStreamViewByStreamID:(NSString *)streamID
{
    SLog(@"%s__%d__%@", __func__, __LINE__, streamID);
    NSArray *localShowViews = [NSArray arrayWithArray:self.showViews];
    NSInteger oldCount = localShowViews.count;
    CCStreamView *view;
    for (CCStreamView *localView in localShowViews)
    {
        SLog(@"%@__%@", localView.stream.streamID, streamID);
        if ([localView.stream.streamID isEqualToString:streamID])
        {
            view = localView;
            [self.showViews removeObject:localView];
            break;
        }
    }
    if (view == nil) {
        return;
    }
    NSInteger newcount = self.showViews.count;
    if (oldCount == newcount)
    {
        SLog(@"removeStreamViewByStreamID移除视图错误:%@", streamID);
    }
    if (self.mode ==CCRoomTemplateSpeak)
    {
        [self.steamSpeak removeStreamView:view];
    }
    else if (self.mode == CCRoomTemplateTile)
    {
        [self.streamTile removeStreamView:view.stream];
    }
    else if(self.mode == CCRoomTemplateSingle)
    {
        [self.streamSingle removeStreamView:view];
    }
    else if(self.mode == CCRoomTemplateDoubleTeacher)
    {
        if (self.role == CCRole_Teacher)
        {
            [self.streamTile removeStreamView:view.stream];
        }
        else
        {
            [self.streamSingle removeStreamView:view];
        }
    }
}

- (NSString *)touchFllow
{
    return [self.streamSingle touchFllow];
}

- (void)viewDidAppear
{
    [self.steamSpeak viewDidAppear:!self.backViewIsShow];
}

#pragma mark - 关闭摄像头或者麦克风贴图
- (void)streamView:(NSString *)viewUserID videoOpened:(BOOL)open
{
    NSArray *localViews = [NSArray arrayWithArray:self.showViews];
    for (CCStreamView *view in localViews)
    {
        if ([view.stream.userID isEqualToString:viewUserID])
        {
            [self stream:view videoOpened:open];
            break;
        }
    }
}

//这里处理不同的模式也要用临时解决办法
- (void)reloadData
{
    if (self.streamTile)
    {
        [self.streamTile reloadData];
    }
    if (self.streamSingle)
    {
        [self.streamSingle reloadData];
    }
    if (self.steamSpeak)
    {
        [self.steamSpeak reloadData];
    }
}

- (void)roomMediaModeUpdate:(CCVideoMode)mode
{
    if (mode == CCVideoMode_Audio)
    {
        //显示图片
        NSArray *localViews = [NSArray arrayWithArray:self.showViews];
        for (CCStreamView *view in localViews)
        {
            if ([view.stream.userID isEqualToString:ShareScreenViewUserID])
            {
                continue;
            }
            if (view.stream.role == CCRole_Student)
            {
                UIImageView *imageView = [view viewWithTag:NOVideoImageViewTag];
                imageView.hidden = NO;
            }
        }
    }
    else
    {
        //隐藏图片
        NSArray *localViews = [NSArray arrayWithArray:self.showViews];
        for (CCStreamView *view in localViews)
        {
            if (view.stream.role == CCRole_Student)
            {
                UIImageView *imageView = [view viewWithTag:NOVideoImageViewTag];
                imageView.hidden = YES;
            }
        }
    }
}

#pragma mark 视图上移
- (void)stream:(CCStreamView *)view videoOpened:(BOOL)open
{
    float timeDelay = 0.0;
    //在教师端，需要添加学生的判断
    if (view.stream.role == CCRole_Student)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CCVideoMode micType = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_video_mode;
            UIImageView *videoImageView = [view viewWithTag:NOVideoImageViewTag];
            if (micType == CCVideoMode_Audio) {
                [view bringSubviewToFront:videoImageView];
            }else{
                UIImageView *imageView = [view viewWithTag:VideoImageViewTag];
                if (open)
                {
                    imageView.hidden = YES;
                }
                else
                {
                    imageView.hidden = NO;
                }
                [view bringSubviewToFront:imageView];
            }
        });
        return;
    }
    CCVideoMode micType = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_video_mode;
    if (micType != CCVideoMode_Audio) {
        ///视频模式
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIImageView *imageView = [view viewWithTag:VideoImageViewTag];
            if (open)
            {
                imageView.hidden = YES;
            }
            else
            {
                imageView.hidden = NO;
            }
            [view bringSubviewToFront:imageView];
        });
    }else {
        ///音频模式
        if (view.stream.role == CCRole_Teacher) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIImageView *imageView = [view viewWithTag:VideoImageViewTag];
                if (open)
                {
                    imageView.hidden = YES;
                }
                else
                {
                    imageView.hidden = NO;
                }
                [view bringSubviewToFront:imageView];
            });
        }
        
    }
      
}

- (void)changeVideoImageView:(BOOL)isLandspace inView:(CCStreamView *)view
{
    if (view)
    {
        UIImageView *imageView = [view viewWithTag:VideoImageViewTag];
        if (imageView)
        {
            if (isLandspace)
            {
                imageView.image = [UIImage imageNamed:@"Camera_off2"];
            }
            else
            {
                imageView.image = [UIImage imageNamed:@"Camera_off-1"];
            }
        }
    }
}

- (void)addVideoAndAudioImageView:(CCStreamView *)view
{
    SLog(@"%s___view:%@", __func__, view);
    {
        UIImageView *imageView = [view viewWithTag:VideoImageViewTag];
        
        if (!imageView)
        {
            if (self.isLandSpace)
            {
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Camera_off2"]];
            }
            else
            {
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Camera_off-1"]];
            }
            imageView.tag = VideoImageViewTag;
            [view addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(view);
            }];
        }
        imageView.hidden = YES;
    }
    {
        UIImageView *imageView = [view viewWithTag:NOCameraImageViewTag];
        if (!imageView)
        {
            if (self.isLandSpace)
            {
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noCamera2"]];
            }
            else
            {
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noCamera"]];
            }
            
            imageView.tag = NOCameraImageViewTag;
            [view addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(view);
            }];
        }
        imageView.hidden = YES;
    }
    {
        //音频连麦模式
        UIImageView *imageView = [view viewWithTag:NOVideoImageViewTag];
        if (!imageView)
        {
            if (self.isLandSpace)
            {
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mai2"]];
            }
            else
            {
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mai-1"]];
            }
            imageView.tag = NOVideoImageViewTag;
            [view addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(view);
            }];
        }
        imageView.hidden = YES;
    }

}

- (void)showMenuBtn
{
    if (self.streamTile)
    {
        [self.streamTile addBack];
    }
    if (self.streamSingle)
    {
        [self.streamSingle addBack];
    }
    if (self.steamSpeak)
    {
        [self.steamSpeak addBack];
    }
}

#pragma mark - auto hidden
- (void)startTimer
{
    if (self.autoHiddenTimer)
    {
        [self.autoHiddenTimer invalidate];
        self.autoHiddenTimer = nil;
    }
    CCWeakProxy *weakProxy = [CCWeakProxy proxyWithTarget:self];
    self.autoHiddenTimer = [NSTimer scheduledTimerWithTimeInterval:3.f target:weakProxy selector:@selector(fire) userInfo:nil repeats:NO];
}

- (void)stopTimer
{
    if (self.autoHiddenTimer)
    {
        [self.autoHiddenTimer invalidate];
        self.autoHiddenTimer = nil;
    }
}

- (void)fire
{
    if (self.streamTile)
    {
        [self.streamTile fire];
    }
    if (self.streamSingle)
    {
        [self.streamSingle fire];
    }
    if (self.steamSpeak)
    {
        [self.steamSpeak fire];
    }
}

- (void)hideOrShowView:(BOOL)hidden
{
    if (self.steamSpeak)
    {
        [self.steamSpeak hideOrShowView:hidden];
    }
}

- (void)hideOrShowVideo:(BOOL)hidden
{
    if (self.steamSpeak)
    {
        [self.steamSpeak hideOrShowVideo:hidden];
    }
}

- (void)disableTapGes:(BOOL)enable
{
    if (self.steamSpeak)
    {
        [self.steamSpeak disableTapGes:enable];
    }
}

- (void)changeTogBig:(NSIndexPath *)indexPath
{
    if (self.streamSingle)
    {
        [self.streamSingle changeTogBig:indexPath];
    }
}

- (void)showMovieBig:(NSIndexPath *)indexPath
{
    if (self.steamSpeak)
    {
        [self.steamSpeak showMovieBig:indexPath];
    }
}

- (BOOL)clickBack:(UIButton *)btn
{
    return [self.steamSpeak clickBack:btn];
}

- (BOOL)clickFront:(UIButton *)btn
{
    return [self.steamSpeak clickFront:btn];
}

- (void)showStreamInDoc:(NSDictionary *)data
{
    if (!data)
    {
        return;
    }
    else
    {
        if (self.steamSpeak)
        {
            [self.steamSpeak showStreamInDoc:data];
        }
    }
}

#pragma mark -
- (void)dealloc
{
    [self stopTimer];
    [self.showViews removeAllObjects];
    self.showViews = nil;
    [self stopWarmPlayVideo];
}
//-------chenfy__暖场动画
- (SelVideoPlayer *)ccPlayerView
{
    if (!_ccPlayerView)
    {
        CCPlayerConfig *configuration = [[CCPlayerConfig alloc]init];
        configuration.shouldAutoPlay = NO;
        configuration.supportedDoubleTap = NO;
        configuration.shouldAutorotate = NO;
        configuration.repeatPlay = YES;
        configuration.statusBarHideState = SelStatusBarHideStateNever;
        configuration.videoGravity = SelVideoGravityResizeAspect;
        _ccPlayerView = [[SelVideoPlayer alloc]initWithConfiguration:configuration];
        _ccPlayerView.userInteractionEnabled = NO;
        _ccPlayerView.backgroundColor = [UIColor clearColor];
    }
    return _ccPlayerView;
}
//开始播放
- (void)startWarmPlayVideo:(NSString *)urlString
{
    if (self.playUrlString)
    {
        //已经播放过，接着播放
        [self playWarmPlayVideo];
        return;
    }
    NSString *urlLocal = @"";
    if (urlString)
    {
        urlLocal = urlString;
    }
    else
    {
        urlLocal = self.playUrlString;
    }
    NSURL *playURL =  [NSURL URLWithString:urlLocal];
    if (!playURL)
    {
        return;
    }
    self.playUrlString = urlLocal;
    [self.ccPlayerView setPlayerURL:playURL];
    [self playWarmPlayVideo];
    self.playUrlString = nil;
}
- (void)playWarmPlayVideo
{
    [self.ccPlayerView _playVideo];
}
//暂停播放
- (void)pauseWarmPlayVideo
{
    [self.ccPlayerView _pauseVideo];
}
//停止播放
- (void)stopWarmPlayVideo
{
    [self.ccPlayerView _pauseVideo];
    [self.ccPlayerView _deallocPlayer];
}

- (void)stop_warm_play_delay
{
    WS(weakSelf);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf pauseWarmPlayVideo];
        [weakSelf stopWarmPlayVideo];
        SLog(@"__function__%s",__func__);
    });
}

@end

