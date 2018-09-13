//
//  PushViewController.m
//  NewCCDemo
//
//  Created by cc on 2016/12/2.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "CCPlayViewController.h"
#import "CustomTextField.h"
#import <BlocksKit+UIKit.h>
#import "LoadingView.h"
#import <CCClassRoomBasic/CCClassRoomBasic.h>
#import "CCStreamShowView.h"
#import "GCPrePermissions.h"
#import "CCLoginScanViewController.h"
#import "CCSignView.h"
#import <Photos/Photos.h>
#import "CCPhotoNotPermissionVC.h"
#import <AFNetworking.h>
#import "AppDelegate.h"
#import "TZImagePickerController.h"
#import "CCLoginViewController.h"
#import "CCPlayViewController+ActiveAndUnActive.h"

//组件化测试
#import "DocSimpleViewController.h"
#import "ChatSimpleViewController.h"

#pragma mark -- 组件化
//排麦
#import <CCBarleyLibrary/CCBarleyLibrary.h>
//#import <CCBarleyLibrary/CCBarleyManager.h>

#define infomationViewClassRoomIconLeft 3
#define infomationViewErrorwRight 9.f
#define infomationViewHandupImageViewRight 16.f
#define infomationViewHostNamelabelLeft  13.f
#define infomationViewHostNamelabelRight 0.f

#define TeacherNamedDelTime 0

@interface CCPlayViewController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate, CCStreamerBasicDelegate, UITableViewDelegate, UITableViewDataSource>
@property(nonatomic,strong)CCStreamShowView     *streamView;

@property(nonatomic,strong)NSString *localStreamID;
@property(nonatomic,strong)CCStream *mixedStream;
@property(nonatomic,strong)CCStream *localStream;
@property(nonatomic,strong)NSString *regionID;
@property(nonatomic,strong)LoadingView          *loadingView;

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSArray *pickerViewData;
@property(nonatomic,assign)BOOL cameraIsBack;
@property(nonatomic,assign)BOOL audioClose;
@property(nonatomic,assign)BOOL videoCLose;

//---new
#pragma mark strong
@property(nonatomic,strong)CCRoom   *room;
@property(nonatomic,strong)CCBarleyManager  *ccBarelyManager;

@property(nonatomic,strong)UITableView *tableViewSDK;
@property(nonatomic,strong)NSArray *arraySDK;

@property(nonatomic,copy)NSString *gapUserId;
@property(nonatomic,assign)NSInteger       micStatus;//0:默认状态  1:排麦中   2:连麦中

@end

//SDK测试范畴
typedef NS_ENUM(NSInteger, SDK_Function) {
    SDK_Function_DOC,//默认从0开始
    SDK_Function_ChatSDK,
  
    SDK_Function_PM_CCClassType_Named,//举手连麦
    SDK_Function_PM_CCClassType_Auto, //自由连麦
    SDK_Function_PM_CCClassType_Rotate, //自动连麦
    SDK_Function_PM_Get_CCClassType, //房间连麦类型
    SDK_Function_PM_XiaMai,  //下麦
    SDK_Function_Publish_Message //发送公聊消息
};

@implementation CCPlayViewController
#pragma mark -- initUI
- (UITableView *)tableViewSDK
{
    if (!_tableViewSDK) {
        _tableViewSDK = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableViewSDK.backgroundColor = [UIColor clearColor];
        _tableViewSDK.delegate = self;
        _tableViewSDK.dataSource = self;
    }
    return _tableViewSDK;
}

- (NSArray *)arraySDK
{
    if (!_arraySDK) {
        _arraySDK = @[@"白板DOC",
                      @"聊天组件",
                      @"Room_举手连麦",
                      @"Room_自由连麦",
                      @"Room_自动连麦",
                      @"获取直播间连麦类型",
                      @"下麦",
                      @"send publish"];
    }
    return _arraySDK;
}

#pragma mark -- 组件化
- (CCStreamerBasic *)stremer
{
    if (!_stremer) {
        _stremer = [CCStreamerBasic sharedStreamer];
    }
    return _stremer;
}
- (CCRoom *)room
{
    return [self.stremer getRoomInfo];
}
#pragma mark -- 组件化 | 排麦
- (CCBarleyManager *)ccBarelyManager
{
    if (!_ccBarelyManager) {
        _ccBarelyManager = [CCBarleyManager sharedBarley];
    }
    return _ccBarelyManager;
}

#pragma mark
#pragma mark -- 组件化关联
- (void)initBaseSDKComponent
{
    self.stremer = [CCStreamerBasic sharedStreamer];
    self.stremer.videoMode = CCVideoPortrait;
    [self.stremer addObserver:self];
    
    //排麦
    self.stremer.isUsePaiMai = YES;
    [self.stremer addObserver:self.ccBarelyManager];
    [self.ccBarelyManager addBasicClient:self.stremer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    [self initUI];
    self.isLandSpace = YES;
    self.cameraPosition = AVCaptureDevicePositionFront;
    [self addObserver_push];

    [self initBaseSDKComponent];
    [self loginAction];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];

    [self addObserver];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self removeObserver];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.navigationController.interactivePopGestureRecognizer)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

-(void)initUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    self.streamView = [[CCStreamShowView alloc] init];
    [self.streamView configWithMode:@""];
    [self.view addSubview:self.streamView];
    WS(ws)
    [_streamView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    
    self.pickerViewData = @[@"开启预览",
                            @"开启直播",
                            @"开始推流",
                            @"停止推流",
                            @"停止直播",
                            @"停止预览",
                            @"退出",
                            @"添加第三方推流地址",
                            @"变更第三方推流地址",
                            @"移除第三方推流地址",
                            @"合屏",
                            @"取消合屏",
                            @"获取链接状态",
                            @"get region",
                            @"set region",
                            @"切换摄像头",
                            @"开启或者关闭麦克风",
                            @"开启或者关闭摄像头"];
    self.tableView = [UITableView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(ws.view).offset(0.f);
        make.left.mas_equalTo(ws.view).offset(0.f);
        make.width.height.mas_equalTo(180.f);
    }];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.hidden = YES;
    
#pragma mark--组件化
    [self.view addSubview:self.tableViewSDK];
    [self.tableViewSDK mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(ws.view);
        make.width.mas_equalTo(160.0f);
        make.height.mas_equalTo(200.0f);
    }];
}

#pragma mark - pickerview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableViewSDK) {
        return [self.arraySDK count];
    }
    return self.pickerViewData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellReuseIndertifer = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIndertifer];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIndertifer];
    }
    cell.backgroundColor = [UIColor clearColor];
    
    if (tableView == self.tableViewSDK)
    {
        //组件化SDK
        cell.textLabel.text = self.arraySDK[indexPath.row];
    }
    else
    {
        //Base SDK
        cell.textLabel.text = self.pickerViewData[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
    {
        [self tableView_BASE:tableView didSelectRowAtIndexPath:indexPath];
        return;
    }
    [self tableView_COM:tableView didSelectRowAtIndexPath:indexPath];
}
#pragma mark - tableview didSelect
#pragma mark - BASE_SDK
- (void)tableView_BASE:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row == 0)
    {
        [self startPreView];
    }
    else if (row == 1)
    {
        [self startLive];
    }
    else if (row == 2)
    {
        [self publish];
    }
    else if (row == 3)
    {
        [self unpublish];
    }
    else if (row == 4)
    {
        [self stopLive];
    }
    else if (row == 5)
    {
        [self stopPreView];
    }
    else if (row == 6)
    {
        [self leave];
    }
    else if (row == 7)
    {
        [self addRtmpUrl];
    }
    else if (row == 8)
    {
        [self updateRtmpUrl];
    }
    else if (row == 9)
    {
        [self removeRtmpUrl];
    }
    else if (row == 10)
    {
        [self mix];
    }
    else if (row == 11)
    {
        [self unMix];
    }
    else if (row == 12)
    {
        [self getconnectionStatus];
    }
    else if (row == 13)
    {
        [self getRegion];
    }
    else if (row == 14)
    {
        [self setRegion];
    }
    else if (row == 15)
    {
        [self changeCamera];
    }
    else if (row == 16)
    {
        [self changeAudio];
    }
    else if (row == 17)
    {
        [self changeVideo];
    }
}

- (void)changeCamera
{
    self.cameraIsBack = !self.cameraIsBack;
    [self.stremer setCameraType:self.cameraIsBack ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront];
}

- (void)changeAudio
{
    self.audioClose = !self.audioClose;
    if (self.audioClose)
    {
        [self.preView.stream disableAudio];
    }
    else
    {
        [self.preView.stream enableAudio];
    }
}

- (void)changeVideo
{
    self.videoCLose = !self.videoCLose;
    if (self.videoCLose)
    {
        [self.preView.stream disableVideo];
    }
    else
    {
        [self.preView.stream enableVideo];
    }
}

- (void)startPreView
{
    
    __weak typeof(self) weakSelf = self;
    [self.stremer startPreview:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            weakSelf.preView = info;
            [weakSelf.streamView showStreamView:info];
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)startLive
{
    __weak typeof(self) weakSelf = self;
    [self.stremer startLive:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)stopLive
{
    __weak typeof(self) weakSelf = self;
    [self.stremer stopLive:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)publish
{
    __weak typeof(self) weakSelf = self;
    [self.stremer publish:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            weakSelf.localStreamID = weakSelf.stremer.localStreamID;
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)unpublish
{
    __weak typeof(self) weakSelf = self;
    [self.stremer unPublish:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)stopPreView
{
    __weak typeof(self) weakSelf = self;
    [self.stremer stopPreview:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            [weakSelf.streamView removeStreamView:info];
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)leave
{
    __weak typeof(self) weakSelf = self;
    [self.stremer leave:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)updateRtmpUrl
{
    __weak typeof(self) weakSelf = self;
    NSString *url = [NSString stringWithFormat:@"rtmp://push-cc1.csslcloud.net/origin/%@", self.stremer.roomID];
    CCLog(@"%@", url);
    [self.stremer updateExternalOutput:url completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)addRtmpUrl
{
    __weak typeof(self) weakSelf = self;
    NSString *url = [NSString stringWithFormat:@"rtmp://push-cc1.csslcloud.net/origin/%@", self.stremer.roomID];
    CCLog(@"%@", url);
    [self.stremer addExternalOutput:url completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)removeRtmpUrl
{
    __weak typeof(self) weakSelf = self;
    NSString *url = [NSString stringWithFormat:@"rtmp://push-cc1.csslcloud.net/origin/%@", self.stremer.roomID];
    CCLog(@"%@", url);
    [self.stremer removeExternalOutput:url completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)mix
{
    __weak typeof(self) weakSelf = self;
    [self.stremer mix:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)unMix
{
    __weak typeof(self) weakSelf = self;
    [self.stremer unmix:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)getconnectionStatus
{
    __weak typeof(self) weakSelf = self;
    [self.stremer getConnectionStats:self.mixedStream completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCConnectionStatus *connectionStatus = (CCConnectionStatus *)info;
            
            CCLog(@"%s__%d__%@", __func__, __LINE__, connectionStatus);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)getRegion
{
    __weak typeof(self) weakSelf = self;
    [self.stremer getRegion:self.localStream mixedStream:self.mixedStream completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d__%@", __func__, __LINE__, info);
            self.regionID = info;
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)setRegion
{
    __weak typeof(self) weakSelf = self;
    [self.stremer setRegion:self.localStream region:self.regionID mixedStream:self.mixedStream completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

#pragma mark - 流
- (void)onServerDisconnected
{
    CCLog(@"%s__%d", __func__, __LINE__);
    WS(ws);
    dispatch_async(dispatch_get_main_queue(), ^{
        [ws.navigationController popViewControllerAnimated:NO];
    });
}

- (void)onStreamAdded:(CCStream*)stream
{
    CCLog(@"%s__%d__%@", __func__, __LINE__, stream.streamID);
    if ([stream.userID isEqualToString:self.stremer.userID])
    {
        //自己的流不订阅
        self.localStream = stream;
        return;
    }
    if (stream.type == CCStreamType_Mixed)
    {
        self.mixedStream = stream;
        return;
    }
    sleep(1.f);
    [self autoSub:stream];
}

- (void)onStreamRemoved:(CCStream*)stream
{
    CCLog(@"%s__%d", __func__, __LINE__);
    if ([stream.userID isEqualToString:self.stremer.userID])
    {
        //自己的流没有订阅
        return;
    }
//    sleep(1.f);
    [self autoUnSub:stream];
}

- (void)onStreamError:(NSError *)error forStream:(CCStream *)stream
{
    CCLog(@"%s__%d__%@__%@", __func__, __LINE__, error, stream.streamID);
}

- (void)autoSub:(CCStream *)stream
{
    CCLog(@"%s__%d__%@", __func__, __LINE__, stream.streamID);
    __weak typeof(self) weakSelf = self;
    [self.stremer subcribeWithStream:stream qualityLevel:0 completion:^(BOOL result, NSError *error, id info) {
        CCLog(@"sub success %s__%d__%@__%@", __func__, __LINE__, stream.streamID, @(result));
        if (result)
        {
            [weakSelf.streamView showStreamView:info];
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)autoUnSub:(CCStream *)stream
{
    CCLog(@"%s__%d__%@", __func__, __LINE__, stream.streamID);
    __weak typeof(self) weakSelf = self;
    [self.stremer unsubscribeWithStream:stream completion:^(BOOL result, NSError *error, id info) {
        CCLog(@"%s__%d__%@__%@", __func__, __LINE__, stream.streamID, @(result));
        if (result)
        {
            [weakSelf.streamView removeStreamView:info];
        }
        else
        {
            [weakSelf showError:error];
            if (error.code == 6003)
            {
                //正在订阅中
                CCLog(@"取消订阅失败，重新取消订阅");
                [weakSelf performSelector:@selector(autoUnSub:) withObject:stream afterDelay:1.f];
            }
        }
    }];
}

#pragma mark - 加载等待view
- (void)pri_addLoadingView
{
    _loadingView = [[LoadingView alloc] initWithLabel:@"正在登录..."];
    [self.view addSubview:_loadingView];
    
    [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

#pragma mark - login
-(void)loginAction
{
    [self.view endEditing:YES];
    
    _loadingView = [[LoadingView alloc] initWithLabel:@"正在登录..."];
    [self.view addSubview:_loadingView];
    
    [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    __weak typeof(self) weakSelf = self;
    CCEncodeConfig *config = [[CCEncodeConfig alloc] init];
    config.reslution = CCResolution_HIGH;
    
    NSString *authSessionID = self.info[@"data"][@"sessionid"];
    NSString *user_id = self.info[@"data"][@"userid"];
    [self.stremer joinWithAccountID:self.viewerId sessionID:authSessionID config:config areaCode:nil events:@[] completion:^(BOOL result, NSError *error, id info) {
        [weakSelf.loadingView removeFromSuperview];
        if (result)
        {
            //自动连麦
            [self com_pm_rotate:NO];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:NO];
            NSLog(@"__%s__%d__%@", __func__, __LINE__, error);
        }
    }];
}

//===================================
#pragma mark
#pragma mark - 组件
- (void)tableView_COM:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row == SDK_Function_DOC) {
        [self com_DOC];
    }
    if (row == SDK_Function_ChatSDK) {
        [self com_chat];
    }
  
    if (row == SDK_Function_PM_CCClassType_Named) {
        [self com_pm_named];
    }
    if (row == SDK_Function_PM_CCClassType_Auto) {
        [self com_pm_auto];
    }
    if (row == SDK_Function_PM_CCClassType_Rotate) {
        [self com_pm_rotate:YES];
    }
    if (row == SDK_Function_PM_Get_CCClassType) {
        [self com_pm_classType];
    }
    if (row == SDK_Function_PM_XiaMai) {
        [self com_pm_xiamai];
    }
    if (row == SDK_Function_Publish_Message) {
        [self publishMessage];
    }
}
#pragma mark - 发送公共消息
- (void)publishMessage
{
    float num = arc4random() + 10.0;
    NSString *str = [NSString stringWithFormat:@"随机数：%f",num];
    NSDictionary *message = @{@"value":str};
    [self.stremer sendPublishMessage:message];
}

#pragma mark -- 发起事件
#pragma mark - 白板
//白板
- (void)com_DOC
{
    DocSimpleViewController *docController = [DocSimpleViewController new];
    [self.navigationController pushViewController:docController animated:YES];
}
#pragma mark - 聊天
//聊天
- (void)com_chat
{
    ChatSimpleViewController *chatController = [ChatSimpleViewController new];
    [self.navigationController pushViewController:chatController animated:YES];
}

#pragma mark
#pragma mark - 排麦
//处理房间状态
- (BOOL)pri_room_status_isOk:(CCClassType)typeIn showError:(BOOL)isShow
{
    CCClassType classType = self.room.room_class_type;
    CCLiveStatus liveStatus= self.room.live_status;
    if (liveStatus != CCLiveStatus_Start)
    {
        if (isShow)
        {
            [self showMessage:@"房间没有开启直播！"];
        }
        return NO;
    }
    else if (classType != typeIn)
    {
        if (isShow)
        {
            [self showMessage:@"房间连麦模式不匹配！"];
        }
        return NO;
    }
    return YES;
}
//举手连麦
- (void)com_pm_named
{
    if (![self pri_room_status_isOk:CCClassType_Named showError:YES])
    {
        return;
    }
    [self pri_requestLM];
}
//自由连麦
- (void)com_pm_auto
{
    //自动连麦的模式下，进入房间假如是直播状态，这里要申请连麦
    if (![self pri_room_status_isOk:CCClassType_Auto showError:YES])
    {
        return;
    }
    [self pri_requestLM];
}
//自动连麦
- (void)com_pm_rotate:(BOOL)showError
{
    //自动连麦的模式下，进入房间假如是直播状态，这里要连麦
    if (![self pri_room_status_isOk:CCClassType_Rotate showError:showError])
    {
        return;
    }
    [self pri_requestLM];
}

- (void)com_pm_classType
{
    CCClassType classType = self.room.room_class_type;
    if (classType == CCClassType_Named) {
        [self showMessage:@"举手连麦"];
    }
    if (classType == CCClassType_Auto) {
        [self showMessage:@"自由连麦"];
    }
    if (classType == CCClassType_Rotate) {
        [self showMessage:@"自动连麦"];
    }
}

#pragma mark
#pragma mark -- 请求上麦
- (void)pri_requestLM
{
    WS(weakSelf);
    //申请连麦
    [self.ccBarelyManager handsUp:^(BOOL result, NSError *error, id info) {
        if(!result)
        {
            [weakSelf showError:error];
        }
    }];
}

#pragma mark -- 接收
-(void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveSocketEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startPublish) name:CCNotiNeedStartPublish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPublish) name:CCNotiNeedStopPublish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needLogout) name:CCNotiNeedLoginOut object:nil];
}
-(void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startPublish
{
    WS(weakSelf);
    //申请连麦成功，开始推流
    [self com_startPreview:^(BOOL result, NSError *error, id info) {
        if (!result) {
            [weakSelf showError:error];
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.streamView showStreamView:info];
        });
        [weakSelf.stremer publish:^(BOOL result, NSError *error, id info) {
            if (result)
            {
                weakSelf.localStreamID = weakSelf.stremer.localStreamID;
                CCLog(@"%s__%d", __func__, __LINE__);
                //推流成功，更新用户排麦状态
                [self.ccBarelyManager updateUserState:weakSelf.room.user_id roomID:nil publishResult:YES streamID:weakSelf.localStreamID completion:^(BOOL result, NSError *error, id info) {

                }];
            }
            else
            {
                [weakSelf showError:error];
            }
        }];

        
    }];
}

- (void)com_startPreview:(CCComletionBlock)completion
{
    //只开启一次预览，知道退出房间时再关闭预览
    if (self.preView)
    {
        if (completion)
        {
            completion(YES, nil, self.preView);
        }
        return;
    }
    else
    {
        __weak typeof(self) weakSelf = self;
        [self.stremer startPreview:^(BOOL result, NSError *error, id info) {
            CCStreamView *view = info;
            weakSelf.preView = view;
            if (completion)
            {
                completion(YES, nil, weakSelf.preView);
            }
        }];
    }
}

- (void)stopPublish
{
    WS(weakSelf);
    [self.stremer unPublish:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            weakSelf.localStreamID = weakSelf.stremer.localStreamID;
            CCLog(@"%s__%d", __func__, __LINE__);
            //推流成功，更新用户排麦状态
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.streamView removeStreamView:info];
                });
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

- (void)needLogout
{
    [self.stremer realsesAllStream];
}
//用户下麦
- (void)com_pm_xiamai
{
    if (!self.stremer.localStreamID || self.stremer.localStreamID.length == 0)
    {
        [self showMessage:@"目前没有上麦！"];
        return;
    }
    WS(weakSelf);
    [self.ccBarelyManager handsDown:^(BOOL result, NSError *error, id info) {
        [weakSelf.streamView removeStreamView:info];
    }];
}

- (void)receiveSocketEvent:(NSNotification *)noti
{
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    id value = noti.userInfo[@"value"];
    NSLog(@"%s__%@__%@", __func__, noti.name, @(event));
  
   if (event == CCSocketEvent_LianmaiStateUpdate)
    {
        NSLog(@"%d", __LINE__);
    }
    else if (event == CCSocketEvent_KickFromRoom)
    {
      
    }
    else if (event == CCSocketEvent_LianmaiModeChanged)
    {
        NSLog(@"%d", __LINE__);
    }
    else if (event == CCSocketEvent_ReciveLianmaiInvite)
    {
        NSLog(@"%d", __LINE__);
        WS(weakSelf);
        [UIAlertView bk_showAlertViewWithTitle:@"消息" message:@"收到老师上麦邀请" cancelButtonTitle:@"拒绝" otherButtonTitles:@[@"接受"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            CCLog(@"chenfy--%d",buttonIndex);
            if (buttonIndex == 1)
            {
                [weakSelf com_accept_invite];
            }
        }];
    }
    else if (event == CCSocketEvent_ReciveCancleLianmaiInvite)
    {
        NSLog(@"%d", __LINE__);
      
    }
    else if (event == CCSocketEvent_HandupStateChanged)
    {
        NSLog(@"%d", __LINE__);
    }
    else if(event == CCSocketEvent_UserListUpdate)
    {
        NSLog(@"%d", __LINE__);
    }
    else if(event == CCSocketEvent_PublishStart)
    {
        //自动连麦
        [self com_pm_rotate:NO];
    }
    else if(event == CCSocketEvent_PublishEnd)
    {
        
    }
    else if(event == CCSocketEvent_UserHandUp)
    {
        NSString *name = value[@"name"];
        NSString *str = [NSString stringWithFormat:@"<%@> 举手了！",name];
        [self showMessage:str];
    }
    else if(event == CCSocketEvent_PublishMessage)
    {
        NSString *val = value[@"value"];
        NSString *smessage = [NSString stringWithFormat:@"收到消息:%@",val];
        [self showMessage:smessage];
    }
    else if(event == CCSocketEvent_UserJoin)
    {
        NSString *uname = value[@"name"];
        NSString *msg = [NSString stringWithFormat:@"<%@> 加入房间!",uname];
        [self showMessage:msg];
    }
    else if(event == CCSocketEvent_UserExit)
    {
        NSString *uname = value[@"name"];
        NSString *msg = [NSString stringWithFormat:@"<%@> 离开房间!",uname];
        [self showMessage:msg];
    }
}

- (void)com_accept_invite
{
    [self.ccBarelyManager acceptTeacherInvite:^(BOOL result, NSError *error, id info) {
        
    }];
}

#pragma mark - 聊天消息
#pragma mark - CCStreamer noti
//talker
- (void)chat_message:(NSDictionary *)dic
{
    CCLog(@"chat_message_received:%@",dic);
    __unused NSString *role = dic[@"userrole"];
    /* 
     role : 
     "talker" :发送者
     "presenter" :接收者
    */
    
    id msg = dic[@"msg"];
    if ([msg isKindOfClass:[NSString class]] || [msg isKindOfClass:[NSMutableString class]])
    {
        NSString *socketMsg = [NSString stringWithFormat:@"收到聊天message-:%@",msg];
        [self showMessage:socketMsg];
    }
    else
    {
        NSString *imageUrl = msg[@"content"];
        NSString *imageMessage = [NSString stringWithFormat:@"收到聊天Pic-:%@",imageUrl];
        [self showMessage:imageMessage];
    }
}

#pragma mark - show message
- (void)showMessage:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"消息" message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
    [alert show];
}

#pragma mark - show error
- (void)showError:(NSError *)error
{
    NSString *mes = [NSString stringWithFormat:@"%@\n%@", @(error.code), error.domain];
    [UIAlertView bk_showAlertViewWithTitle:@"" message:mes cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
    }];
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [self removeObserver];
}

- (void)popToScanVC
{
    for (UIViewController *vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[CCLoginViewController class]])
        {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

@end
