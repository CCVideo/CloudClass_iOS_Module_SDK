//
//  DocSimpleViewController.m
//  CCClassRoom
//
//  Created by cc on 18/7/13.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "DocSimpleViewController.h"
#import <CCClassRoomBasic/CCClassRoomBasic.h>
#import <CCDocLibrary/CCDocLibrary.h>
#import <CCDocLibrary/CCDocVideoView.h>
#import "AppDelegate.h"

#define V_TAG   1000

@interface DocSimpleViewController ()<CCStreamerBasicDelegate>
@property(nonatomic,strong)UIView *showView;
@property(nonatomic,strong)CCStreamerBasic *stremer;
@property(nonatomic,strong)CCDocVideoView   *ccVideoView;
@property(nonatomic,strong)UIButton   *drawButton;
@property(nonatomic,strong)UIButton   *eraserButton;
@property(nonatomic,strong)UIButton   *gestureButton;
@property(nonatomic,strong)UIButton   *revokeDrawButton;

@property(nonatomic,strong)UIView   *controlView;//功能视图
@property (nonatomic, strong) UIButton *fullScreenDocViewButton;//文档全屏

@property(nonatomic,assign)BOOL isDocBig;

@end

@implementation DocSimpleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    //组件关联
    [self initBaseSDKComponent];
    [self initUI];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //    开启编辑
    [self.ccVideoView setDocEditable:YES];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
- (UIView *)showView
{
    if (!_showView)
    {
        _showView = [UIView new];
        CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH, (9/16.0)*(SCREEN_WIDTH));
        _showView.frame = frame;
        _showView.clipsToBounds = YES;
        _showView.backgroundColor = [UIColor whiteColor];
    }
    return _showView;
}

- (void)initUI
{
    UIView *v = [self.view viewWithTag:V_TAG];
    if (v)
    {
        [v removeFromSuperview];
    }
    //view 添加展示
    [self.view addSubview:self.showView];
    [self.showView addSubview:self.ccVideoView];
    //加载展示数据
    [self.ccVideoView startDocView];
    
    [self.view addSubview:self.controlView];
    [self.controlView addSubview:self.drawButton];
    [self.controlView addSubview:self.eraserButton];
    [self.controlView addSubview:self.gestureButton];
    [self.controlView addSubview:self.revokeDrawButton];
    [self.view addSubview:self.fullScreenDocViewButton];
    
    WS(weakSelf);
    [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).offset(10);
        make.size.mas_equalTo(CGSizeMake(50 * 4, 50));
        make.centerX.equalTo(weakSelf.view);
    }];
    [self.drawButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.controlView);
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.left.equalTo(weakSelf.controlView);
    }];
    [self.eraserButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.controlView);
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.left.equalTo(weakSelf.drawButton.mas_right);
    }];
    [self.gestureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.controlView);
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.left.mas_equalTo(weakSelf.eraserButton.mas_right);
    }];
    [self.revokeDrawButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.controlView);
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.left.mas_equalTo(weakSelf.gestureButton.mas_right);
        make.right.equalTo(weakSelf.controlView);
    }];
    [self.fullScreenDocViewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.and.right.equalTo(weakSelf.showView).offset(-10);
    }];
}

- (CCStreamerBasic *)stremer
{
    if (!_stremer) {
        _stremer = [CCStreamerBasic sharedStreamer];
    }
    return _stremer;
}

#pragma mark -- 组件化 | 白板
- (CCDocVideoView *)ccVideoView
{
    if (!_ccVideoView) {
        CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH * 5, (9/16.0)*(SCREEN_WIDTH * 5));
        _ccVideoView = [[CCDocVideoView alloc]initWithFrame:frame];
        _ccVideoView.tag = 1000;
        [_ccVideoView addObserverNotify];
    }
    return _ccVideoView;
}

#pragma mark
#pragma mark -- 组件化关联
- (void)initBaseSDKComponent
{
    self.stremer.videoMode = CCVideoPortrait;
    //白板
    [self.stremer addObserver:self.ccVideoView];
    [self.ccVideoView addBasicClient:self.stremer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addObserver];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeObserver];
}

#pragma mark -- 接收
-(void)addObserver
{
    [self.stremer addObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveSocketEvent object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];

}
-(void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];

    [self.stremer removeObserver:self];
}

- (void)receiveSocketEvent:(NSNotification *)noti
{
    NSLog(@"___%s___%@___",__func__,noti);
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    NSLog(@"___%s___%d___",__func__,event);
    if(event == CCSocketEvent_PublishStart)
    {
        [self initBaseSDKComponent];
        [self.ccVideoView startDocView];
    }
    else if(event == CCSocketEvent_PublishEnd)
    {
        
    }
}

- (void)changeRotate:(NSNotification*)noti {
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait
        || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown) {
        //竖屏
        NSLog(@"竖屏");
        self.showView.frame = CGRectMake(0, 0, SCREEN_WIDTH, (9/16.0)*(SCREEN_WIDTH));
        [self.ccVideoView setDocFrame:CGRectMake(0, 0, SCREEN_WIDTH, (9/16.0)*(SCREEN_WIDTH))];
//        [self.navigationController setNavigationBarHidden:NO animated:YES];

    } else {
        //横屏
        NSLog(@"横屏");
        NSLog(@"%f , %f",SCREENH_HEIGHT,SCREEN_WIDTH);
        self.showView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT);
        [self.ccVideoView setDocFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT)];
//        [self.navigationController setNavigationBarHidden:YES animated:YES];

    }

    self.fullScreenDocViewButton.selected = !self.fullScreenDocViewButton.selected;
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}


#pragma mark - UIButton click  Method
- (void)ruleBtnClick:(UIButton *)sender
{
    [self.ccVideoView setCurrentIsEraser:YES];
}

- (void)drawBtnClick:(UIButton *)sender
{
    [self.ccVideoView setCurrentIsEraser:NO];
}

//独立全屏按钮
- (void)fullScreenDocViewButton:(UIButton *)sender {
    
    //    默认显示去放大  选中显示去缩小
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (sender.selected) {
        appDelegate.shouldNeedLandscape = NO;
        [appDelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
        
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
        
        [UIApplication sharedApplication].statusBarHidden = NO;
        
    } else {
        appDelegate.shouldNeedLandscape = YES;
        [appDelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
        [UIApplication sharedApplication].statusBarHidden = YES;
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Getter and Setter Method
-  (UIView *)controlView {
    if (!_controlView) {
        _controlView = [[UIView alloc]init];
        _controlView.frame = CGRectMake(100, 100, 100, 50);
        _controlView.layer.cornerRadius = 25;
        _controlView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _controlView;
}

-  (UIButton *)drawButton {
    if (!_drawButton) {
        _drawButton = [UIButton new];
        [_drawButton setBackgroundImage:[UIImage imageNamed:@"pencil"] forState:UIControlStateNormal];
        [_drawButton setBackgroundImage:[UIImage imageNamed:@"pencil_touch"] forState:UIControlStateHighlighted];
        [_drawButton addTarget:self action:@selector(drawBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _drawButton;
}
-  (UIButton *)eraserButton {
    if (!_eraserButton) {
        _eraserButton = [UIButton new];
        [_eraserButton setBackgroundImage:[UIImage imageNamed:@"rule"] forState:UIControlStateNormal];
        [_eraserButton setBackgroundImage:[UIImage imageNamed:@"rule_touch"] forState:UIControlStateHighlighted];
        [_eraserButton addTarget:self action:@selector(ruleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _eraserButton;
}
//手势按钮
-  (UIButton *)gestureButton
{
    if (!_gestureButton) {
        _gestureButton = [UIButton new];
        [_gestureButton setBackgroundImage:[UIImage imageNamed:@"drag"] forState:UIControlStateNormal];
        [_gestureButton setBackgroundImage:[UIImage imageNamed:@"drag"] forState:UIControlStateHighlighted];
        [_gestureButton addTarget:self action:@selector(gestureButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _gestureButton;
}
- (void)gestureButtonClicked:(UIButton *)sender
{
    sender.selected = !sender.selected;
    //保持拖拽与编辑相反状态
    [self.ccVideoView setGestureOpen:sender.selected];
    [self.ccVideoView setDocEditable:!sender.selected];
}

//画笔撤销
- (UIButton *)revokeDrawButton
{
    if (!_revokeDrawButton)
    {
        _revokeDrawButton = [UIButton new];
        [_revokeDrawButton setBackgroundImage:[UIImage imageNamed:@"back1"] forState:UIControlStateNormal];
        [_revokeDrawButton addTarget:self action:@selector(revokeClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _revokeDrawButton;
}
- (void)revokeClicked
{
    [self.ccVideoView revokeLastDraw];
}

- (UIButton *)fullScreenDocViewButton {
    if (!_fullScreenDocViewButton) {
        _fullScreenDocViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenDocViewButton setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
        [_fullScreenDocViewButton setImage:[UIImage imageNamed:@"exitfullscreen"] forState:UIControlStateSelected];
        
        [_fullScreenDocViewButton addTarget:self action:@selector(fullScreenDocViewButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenDocViewButton;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
