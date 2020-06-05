//
//  CCDocViewController.m
//  CCClassRoom
//
//  Created by cc on 17/3/30.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCDocViewController.h"
#import <Masonry.h>
#import <CCClassRoomBasic/CCClassRoomBasic.h>
#import "CCDrawMenuView.h"
#import "LoadingView.h"
#import "CCStreamModeTeach_Teacher.h"
//#import "CCDoc.h"
#import "HDSDocManager.h"
#import "HDSTool.h"
#import "CCChangeScrollBtn.h"

#define infomationViewClassRoomIconLeft 3
#define infomationViewErrorwRight 9.f
#define infomationViewHandupImageViewRight 16.f
#define infomationViewHostNamelabelLeft  13.f
#define infomationViewHostNamelabelRight 0.f

@interface CCDocViewController ()<CCDrawMenuViewDelegate>
@property (strong, nonatomic) UIButton *fullBtn;
@property(nonatomic,strong)CCDrawMenuView *drawMenuView;
@property(nonatomic,strong)LoadingView *loadingView;

#pragma mark -- 计时器
@property(nonatomic,strong)UIView *timerView;
@property(nonatomic,strong)UILabel *timerLabel;
@property(nonatomic,strong)NSTimer *timerTimer;
@property(nonatomic,strong)HDSTool *hdsTool;
@property(nonatomic,strong)CCChangeScrollBtn *changeScrollBtn;

@end

@implementation CCDocViewController
- (HDSTool *)hdsTool
{
    if (!_hdsTool) {
        _hdsTool = [[HDSTool  alloc]init];
    }
    return _hdsTool;
}

- (id)initWithDocView:(UIView *)view streamView:(CCStreamerView *)streamView
{
    if (self = [super init])
    {
        self.modalPresentationStyle = 0;
        self.docView = view;
        self.streamView = streamView;
    }
    return self;
}

-(void)initUI {
    WS(ws);
    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    
    __weak typeof(self) weakSelf = self;
    [self.view addSubview:self.docView];
    [self.docView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.view).offset(0.f);
    }];
    
    [self.view addSubview:self.timerView];
    [self.timerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(10.f);
        make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(60) + [CCTool tool_MainWindowSafeArea_Top]);
        make.height.mas_equalTo(1);
        make.width.mas_equalTo(1);
    }];
    [self.view addSubview:self.changeScrollBtn];
    [self resetDocPPTFrame];
    
    self.fullBtn = [UIButton new];
    [self.fullBtn setTitle:@"" forState:UIControlStateNormal];
    [self.fullBtn setImage:[UIImage imageNamed:@"exitfullscreen"] forState:UIControlStateNormal];
    [self.fullBtn setImage:[UIImage imageNamed:@"exitfullscreen_touch"] forState:UIControlStateSelected];
    [self.fullBtn addTarget:self action:@selector(clickFull) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.fullBtn];
    [self.fullBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
        make.bottom.mas_equalTo(weakSelf.docView.mas_bottom).offset(-10.f);
    }];
    NSString *userID = [CCStreamerBasic sharedStreamer].getRoomInfo.user_id;
    NSLog(@"%s__%@", __func__, userID);
    for (CCUser *user in [CCStreamerBasic sharedStreamer].getRoomInfo.room_userList)
    {
        if ([user.user_id isEqualToString:userID])
        {
            [self dragAction];
            self.changeScrollBtn.hidden = YES;
            if (user.user_AssistantState || user.user_drawState || user.user_role == CCRole_Teacher || user.user_role == CCRole_Assistant)
            {
                [self drawMenuView1];
                
                [[HDSDocManager sharedDoc]beEditable];
                self.changeScrollBtn.hidden = NO;
                [[HDSDocManager sharedDoc]beEditableCancel];
            }
        }
    }
    [[HDSDocManager sharedDoc]setDpListen:^(CCDocLoadType type, CGFloat w, CGFloat h, id error) {
        NSLog(@"dpLosten-------------------------------------");
        if (type == CCDocLoadTypeComplete)
        {
            [self refreshMenuPageUI];
        }
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

//重制ppt的Frame
- (void)resetDocPPTFrame
{
    CGFloat width = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    CGFloat height = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    CGFloat h_r = height;
    CGFloat w_r = (16/9.0)*h_r;
    CGFloat x_r = (width - w_r)/2.0;
    CGRect fm = CGRectMake(x_r, 0, width, height);
    [[HDSDocManager sharedDoc]setDocFrame:fm displayMode:2];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    
    NSString *userID = [CCStreamerBasic sharedStreamer].getRoomInfo.user_id;
    for (CCUser *user in [CCStreamerBasic sharedStreamer].getRoomInfo.room_userList)
    {
        if ([user.user_id isEqualToString:userID])
        {
            if (user.user_AssistantState || user.user_drawState || user.user_role == CCRole_Teacher || user.user_role == CCRole_Assistant)
            {

            }
        }
    }
    [self stopTimeTimer];
}

- (void)clickFull
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiDocViewControllerClickSamll object:nil userInfo:@{}];
}

- (void)docPageChange
{
    if (self.drawMenuView)
    {
        [self refreshMenuPageUI];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//- (BOOL)shouldAutorotate{
//    return NO;
//}
//
//- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//    bool bRet = ((toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft));
//    return bRet;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskLandscapeRight|UIInterfaceOrientationMaskLandscapeLeft;
//}

- (CCDrawMenuView *)drawMenuView1
{
    if (_drawMenuView)
    {
        _drawMenuView.delegate = nil;
        [_drawMenuView removeFromSuperview];
        _drawMenuView = nil;
    }
    if (!_drawMenuView)
    {
        CCRole role = [CCStreamerBasic sharedStreamer].getRoomInfo.user_role;
        NSString *userID = [CCStreamerBasic sharedStreamer].getRoomInfo.user_id;
        
        CCUser *user = [self.hdsTool toolGetUserFromUserID:userID];
        if (role == CCRole_Teacher || role == CCRole_Assistant)
        {
            BOOL isWhite = NO;
            NSString *imageUrl = @"http://www.baidu.com";
            if ([imageUrl hasPrefix:@"#"] || [imageUrl hasSuffix:@"#"])
            {
                isWhite = YES;
            }
            else
            {
                isWhite = NO;
            }
            if (isWhite)
            {
                //TODO..Modify...20190404..增加 CCDragStyle_Page
                //之前白板不显示前后翻页页码，为了修改bug-2902 添加了页码显示
                _drawMenuView = [[CCDrawMenuView alloc] initWithStyle:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Page];
            }
            else
            {
                _drawMenuView = [[CCDrawMenuView alloc] initWithStyle:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Page];
            }
        }
        else
        {
            //            _drawMenuView = [[CCDrawMenuView alloc] initWithStyle:CCDragStyle_DrawAndBack];
            if ((user.user_AssistantState || user.user_drawState))
            {
                if (user.user_AssistantState)
                {
                    NSString *imageUrl = @"http://www.baidu.com";
                    //添加了WhiteBoard字段的判断
//                    if (([imageUrl hasPrefix:@"#"] || [imageUrl hasSuffix:@"#"])&&[docManager.docId isEqualToString:@"WhiteBoard"])
                    if (([imageUrl hasPrefix:@"#"] || [imageUrl hasSuffix:@"#"]))
                    {
                        _drawMenuView = [[CCDrawMenuView alloc] initWithStyle:CCDragStyle_DrawAndBack|CCDragStyle_Clean];
                    }
                    else
                    {
                        _drawMenuView = [[CCDrawMenuView alloc] initWithStyle:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Page];
                    }
                }
                else if(user.user_drawState)
                {
                    _drawMenuView = [[CCDrawMenuView alloc] initWithStyle:CCDragStyle_DrawAndBack];
                }
            }
        }
        _drawMenuView.delegate = self;
        [self refreshMenuPageUI];
        
        [self.view addSubview:_drawMenuView];
        __weak typeof(self) weakSelf = self;
        [_drawMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.view).offset(20.f);
            make.centerX.mas_equalTo(weakSelf.view);
        }];
    }
    return _drawMenuView;
}

- (BOOL)isWhiteBoard
{
    BOOL isWhite = YES;
    NSString *imageUrl = @"www";
    if ([imageUrl hasPrefix:@"#"] || [imageUrl hasSuffix:@"#"])
    {
        isWhite = YES;
    }
    else
    {
        isWhite = NO;
    }
    return isWhite;
}

- (void)drawBtnClicked:(UIButton *)btn
{
    
}

- (void)frontBtnClicked:(UIButton *)btn
{
    //撤销
    [[HDSDocManager  sharedDoc]revokeDrawLast];
//    [[CCDocManager sharedManager] revokeDrawData];
}

- (void)menuBtnClicked:(UIButton *)btn
{
    //显示操作栏
        [self.streamView hideOrShowView:YES];
}

- (void)cleanBtnClicked:(UIButton *)btn
{
    [[HDSDocManager  sharedDoc]revokeDrawAll];
//    [[CCDocManager sharedManager] cleanDrawData];
}

- (void)pageFrontBtnClicked:(UIButton *)btn
{
    if ([self isWhiteBoard])
    {
        return;
    }
    BOOL res = [self.streamView clickFront:nil];
    if (res)
    {
        [self refreshMenuPageUI];
    }
}

- (void)pageBackBtnClicked:(UIButton *)btn
{
    if ([self isWhiteBoard])
    {
        return;
    }
    BOOL res = [self.streamView clickBack:nil];
    if (res)
    {
        [self  refreshMenuPageUI];
    }
}

- (void)refreshMenuPageUI
{
    if (!self.drawMenuView)
    {
        return;
    }
    HDSDocManager *hdsM = [HDSDocManager sharedDoc];
    CCDoc *doc =  [hdsM hdsCurrentDoc];
    NSUInteger pageNow = [hdsM hdsCurrentDocPage];
    NSString *textPN = [NSString stringWithFormat:@"%@ / %@", @(pageNow+1), @(doc.pageSize)];
    if ([doc.docID isEqualToString:@"WhiteBorad"])
    {
        textPN = @"1 / 1";
    }
    NSLog(@"refreshMenuPageUI_copy------:%@",textPN);
    self.drawMenuView.pageLabel.text = textPN;
}

- (void)showOrHideDrawView:(BOOL)show calledByDraw:(BOOL)calledByDraw
{
    self.changeScrollBtn.hidden = !show;
    [[HDSDocManager sharedDoc] setHiddenSlider:show];
    if (show == NO) {
        [_changeScrollBtn removeFromSuperview];
        _changeScrollBtn = nil;
        [self.view addSubview:self.changeScrollBtn];
        [[HDSDocManager sharedDoc] setHiddenSlider:YES];
    }
    if (show)
    {
        NSString *title = calledByDraw ? @"您已被老师开启授权标注" : @"您已被老师开启设为讲师";
        [self showAutoHiddenAlert:title];
        [self drawMenuView1];
        if (calledByDraw)
        {
            [[HDSDocManager sharedDoc]beAuthDraw];
        }
        else
        {
            [[HDSDocManager sharedDoc]beAuthTeacher];
        }
    }
    else
    {
        NSString *title = calledByDraw ? @"您已被老师关闭授权标注" : @"您已被老师关闭设为讲师";

        NSString *userID = [[CCStreamerBasic sharedStreamer] getRoomInfo].user_id;
        CCUser *user = [self.hdsTool toolGetUserFromUserID:userID];
        if (calledByDraw && !user.user_AssistantState)
        {
            [[HDSDocManager sharedDoc]beAuthDrawCancel];
        }
        else if (!calledByDraw && !user.user_drawState)
        {
            [[HDSDocManager sharedDoc]beAuthTeacherCancel];
        }
        if (user.user_drawState || user.user_AssistantState)
        {
            [self drawMenuView1];
        }
        else
        {
            [self showAutoHiddenAlert:title];
            [self.drawMenuView removeFromSuperview];
            self.drawMenuView = nil;
        }
    }
    [[HDSDocManager sharedDoc] beEditableCancel];
}

- (void)showAutoHiddenAlert:(NSString *)title
{
    if (_loadingView) {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
    _loadingView = [[LoadingView alloc] initWithLabel:title showActivity:NO];
    [self.view addSubview:_loadingView];
    [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self performSelector:@selector(alertViewAutoHide:) withObject:_loadingView afterDelay:2];
}

- (void)alertViewAutoHide:(LoadingView *)alertView
{
    [alertView removeFromSuperview];
}

- (void)videoSuspendShowOrHideDrawView:(BOOL)show
{
    if (self.drawMenuView)
    {
        self.drawMenuView.hidden = show;
    }
}

#pragma mark -- 计时器添加
- (UIView *)timerView
{
    if (!_timerView)
    {
        _timerView = [UIView new];
        _timerView.backgroundColor = CCRGBAColor(0, 0, 0, 0.3);
        _timerView.layer.cornerRadius = CCGetRealFromPt(70) / 2;
        _timerView.layer.masksToBounds = YES;
        
        UIImageView *backImageView = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"setting"];
        image = [image stretchableImageWithLeftCapWidth:image.size.width/2.f topCapHeight:image.size.height/2.f];
        backImageView.image = image;
        [_timerView addSubview:backImageView];
        WS(ws);
        [backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws.timerView);
        }];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock2"]];
        [_timerView addSubview:imageView];
        [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.timerView).offset(infomationViewClassRoomIconLeft);
            make.centerY.mas_equalTo(ws.timerView);
            make.height.mas_equalTo(ws.timerView).offset(-6.f);
            make.width.mas_equalTo(imageView.mas_height);
        }];
        
        [_timerView addSubview:self.timerLabel];
        [_timerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(imageView.mas_right).offset(infomationViewHostNamelabelLeft);
            make.centerY.mas_equalTo(ws.timerView).offset(0.f);
            //            make.size.mas_equalTo(ws.timerLabel.frame.size);
        }];
    }
    return _timerView;
}

- (UILabel *)timerLabel
{
    if (!_timerLabel)
    {
        _timerLabel = [UILabel new];
        _timerLabel.font = [UIFont systemFontOfSize:FontSizeClass_12];
        _timerLabel.textAlignment = NSTextAlignmentLeft;
        _timerLabel.textColor = CCRGBColor(249, 57, 48);
        _timerLabel.text = @"00:00";
        [_timerLabel sizeToFit];
    }
    return _timerLabel;
}

- (void)updateTime
{
    NSTimeInterval end = [[CCStreamerBasic sharedStreamer] getRoomInfo].timerStart + [[CCStreamerBasic sharedStreamer] getRoomInfo].timerDuration;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval left = end - now*1000;
    if (left > 0)
    {
        self.timerLabel.text = [CCTool timerStringForTime:left];
    }
    else
    {
        //开始动画
        if (self.timerTimer)
        {
            [self.timerTimer invalidate];
            self.timerTimer = nil;
        }
        self.timerLabel.textColor = CCRGBColor(249, 57, 48);
        CCWeakProxy *weakProxy = [CCWeakProxy proxyWithTarget:self];
        self.timerTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:weakProxy selector:@selector(animation) userInfo:nil repeats:YES];
    }
}

- (void)animation
{
    WS(ws);
    [UIView animateWithDuration:0.99f animations:^{
        ws.timerLabel.alpha = 0.0;
        //        ws.timerLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL finished) {
        ws.timerLabel.alpha = 1.f;
        ws.timerLabel.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark -- timer start
- (void)timerStart
{
    NSLog(@"%d", __LINE__);
    //计时器开始
    self.timerView.hidden = NO;
    WS(ws);
    CGSize userNameSize = [CCTool getTitleSizeByFont:self.timerLabel.text font:[UIFont systemFontOfSize:FontSizeClass_12]];
    [self.timerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        //            make.centerX.mas_equalTo(ws.view).offset(0.f);
        make.left.mas_equalTo(ws.view).offset(10.f);
        make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(60));
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(60+userNameSize.width);
    }];
    
    //        self.timerLabel.textColor = CCRGBColor(249, 57, 48);
    self.timerLabel.textColor = [UIColor whiteColor];
    NSTimeInterval end = [[CCStreamerBasic sharedStreamer] getRoomInfo].timerStart + [[CCStreamerBasic sharedStreamer] getRoomInfo].timerDuration;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval left = end - now*1000;
    self.timerLabel.text = [CCTool timerStringForTime:left];
    if (self.timerTimer)
    {
        [self.timerTimer invalidate];
        self.timerTimer = nil;
    }
    CCWeakProxy *weakProxy = [CCWeakProxy proxyWithTarget:self];
    self.timerTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:weakProxy selector:@selector(updateTime) userInfo:nil repeats:YES];
}

- (void)timerEnd
{
    NSLog(@"%d", __LINE__);
    //计时器结束
    self.timerView.hidden = YES;
    WS(ws);
    [self.timerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(0.f);
        make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(60));
        make.height.mas_equalTo(1);
        make.width.mas_equalTo(1);
    }];
    
    if (self.timerTimer)
    {
        [self.timerTimer invalidate];
        self.timerTimer = nil;
    }
}

/** 计时器 */
- (void)startTimeTimer
{
    [self timerStart];
}
- (void)stopTimeTimer
{
    [self timerEnd];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self initUI];

//    BOOL open = [[CCDocManager sharedManager]isTimerStart];
    BOOL open = NO;
    if (open)
    {
        [self startTimeTimer];
    }
    else
    {
        [self stopTimeTimer];
    }
}
-(CCChangeScrollBtn *)changeScrollBtn {
    if (!_changeScrollBtn) {
        _changeScrollBtn = [[CCChangeScrollBtn alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, 60, 100, 50)];
        _changeScrollBtn.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.3];
        _changeScrollBtn.hidden = YES;
    }
    return _changeScrollBtn;
}
-(void)dragAction {
    self.changeScrollBtn.hidden = NO;
    [[HDSDocManager sharedDoc] setHiddenSlider:YES];
    [[HDSDocManager sharedDoc] setDocEditable:NO];
}

-(void)paintingAction {
    self.changeScrollBtn.hidden = YES;
    [[HDSDocManager sharedDoc] setHiddenSlider:NO];
    [[HDSDocManager sharedDoc] setDocEditable:NO];
}
@end
