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

#define V_TAG   1000

@interface DocSimpleViewController ()<CCStreamerBasicDelegate>
@property(nonatomic,strong)CCStreamerBasic *stremer;
@property(nonatomic,strong)CCDocVideoView   *ccVideoView;

@property(nonatomic,assign)BOOL isDocBig;

@end

@implementation DocSimpleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isDocBig = YES;
    self.view.backgroundColor = [UIColor lightGrayColor];
#pragma mark ButtonCreate
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 80, 40);
    [btn setBackgroundColor:[UIColor orangeColor]];
    [btn setTitle:@"切换" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    UIBarButtonItem *rightTtem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightTtem;

    //组件关联
    [self initBaseSDKComponent];
    [self initUI];
    // Do any additional setup after loading the view.
}

- (void)buttonClick
{
    NSLog(@"change clicked");

    if (_isDocBig)
    {
        [self changeDocSmall];
    }
    else
    {
        [self changeDocBig];
    }
    _isDocBig = !_isDocBig;
}

- (void)changeDocSmall
{
    int width = SCREEN_WIDTH * 0.6;
    CGRect frame = CGRectMake(80, 80, width, (9/16.0)*(width));
    [self.ccVideoView setDocFrame:frame];
}
- (void)changeDocBig
{
    CGRect frame = CGRectMake(0, 80, SCREEN_WIDTH, (9/16.0)*(SCREEN_WIDTH));
    [self.ccVideoView setDocFrame:frame];
}

- (void)initUI
{
    UIView *v = [self.view viewWithTag:V_TAG];
    if (v)
    {
        [v removeFromSuperview];
    }
    //view 添加展示
    [self.view addSubview:self.ccVideoView];
    //加载展示数据
    [self.ccVideoView startDocView];
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
        CGRect frame = CGRectMake(0, 80, SCREEN_WIDTH, (9/16.0)*(SCREEN_WIDTH));
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
}
-(void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.stremer removeObserver:self];
}

- (void)receiveSocketEvent:(NSNotification *)noti
{
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    if(event == CCSocketEvent_PublishStart)
    {
        [self initBaseSDKComponent];
        [self.ccVideoView startDocView];
    }
    else if(event == CCSocketEvent_PublishEnd)
    {
        
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
