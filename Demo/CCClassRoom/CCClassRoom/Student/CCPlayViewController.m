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
#import "VoiceController/VoiceViewController.h"
#pragma mark -- 组件化
//排麦
#import <CCBarleyLibrary/CCBarleyLibrary.h>
#define infomationViewClassRoomIconLeft 3
#define infomationViewErrorwRight 9.f
#define infomationViewHandupImageViewRight 16.f
#define infomationViewHostNamelabelLeft  13.f
#define infomationViewHostNamelabelRight 0.f

/*********************************************/
/** 功能测试 */
//推流重试
#define PUBLISH_RETRY    0
/*********************************************/
static BOOL gl_preview_can_click = YES;

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
#pragma mark strong - 排麦
@property(nonatomic,strong)CCRoom   *room;
@property(nonatomic,strong)CCBarleyManager  *ccBarelyManager;
#pragma mark strong - 排麦
@property(nonatomic,strong)CCDocVideoView  *ccVideoView;

@property(nonatomic,strong)UITableView *tableViewSDK;
@property(nonatomic,strong)NSArray *arraySDK;

@property(nonatomic,copy)NSString *gapUserId;
@property(nonatomic,assign)NSInteger       micStatus;//0:默认状态  1:排麦中   2:连麦中

@property(nonatomic,copy)NSString *token;
@property(nonatomic,copy)NSString *accountId;
@property(nonatomic,copy)NSString *roomId;

@property(nonatomic,strong)CCStream *tempStream;

@end

//SDK测试范畴
typedef NS_ENUM(NSInteger, SDK_Function) {
    SDK_Function_DOC_wipeSelf = -1,//默认从-1开始
    SDK_Function_DOC_wipeAll,//默认从0开始
    SDK_Function_ChatSDK,
  
    SDK_Function_PM_CCClassType_Named,//举手连麦
    SDK_Function_PM_CCClassType_Auto, //自由连麦
    SDK_Function_PM_CCClassType_Rotate, //自动连麦
    SDK_Function_PM_Get_CCClassType, //房间连麦类型
    SDK_Function_PM_XiaMai,  //下麦
    SDK_Function_Publish_Message, //发送公聊消息
    SDK_Function_ReportLog,  //信息上报
    SDK_Function_VoiceShow
};
//基础功能枚举
typedef NS_ENUM(NSInteger,CCBaseFunType) {
    CCBaseFunType_exit,
    CCBaseFunType_previewStart,
    CCBaseFunType_liveStart,
    CCBaseFunType_publishStart,
    CCBaseFunType_publishStop,
    CCBaseFunType_liveStop,
    CCBaseFunType_previewStop,
    CCBaseFunType_getStatus,
    CCBaseFunType_cameraChangeFrontBack,
    CCBaseFunType_micChange,
    CCBaseFunType_cameraChange,
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
        _arraySDK = @[@"文档-擦除自己笔记",
                      @"文档-擦除所有笔记",
                      @"聊天组件",
                      @"Room_举手连麦",
                      @"Room_自由连麦",
                      @"Room_自动连麦",
                      @"获取直播间连麦类型",
                      @"下麦",
                      @"send publish",
                      @"日志上报",
                      @"音量展示"];
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
#pragma mark --
#pragma mark -- 组件化 | 排麦
- (CCBarleyManager *)ccBarelyManager
{
    if (!_ccBarelyManager) {
        _ccBarelyManager = [CCBarleyManager sharedBarley];
    }
    return _ccBarelyManager;
}
#pragma mark --
#pragma mark -- 组件化 | 白板
#pragma mark-屏幕尺寸
#define SCREEN_HEIGHT   ([[UIScreen mainScreen]bounds].size.height)
/*******************************/
/** 用户自定义 */
#define Func_DOC_Normal     1
//画板竖屏
#define DOC_FRAME_POR_BIG    (CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT))
/*******************************/

- (CCDocVideoView *)ccVideoView
{
    if (!_ccVideoView) {
        CGRect frame = CGRectZero;
        if (Func_DOC_Normal)
        {
            /** 画板尺寸标准：9/16 */
            frame = CGRectMake(0, 0, SCREEN_WIDTH, (9/16.0)*(SCREEN_WIDTH));
        }
        else
        {
            /** 画板尺寸自己调整 */
            frame = DOC_FRAME_POR_BIG;
        }
        _ccVideoView = [[CCDocVideoView alloc]initWithFrame:frame];
        _ccVideoView.tag = 1000;
        [_ccVideoView addObserverNotify];
    }
    
    [_ccVideoView setVideoPlayerContainer:self.view];
    [_ccVideoView setVideoPlayerFrame:CGRectMake(20, 20, 200, 200)];

    return _ccVideoView;
}

- (void)showVideoCut:(NSDictionary *)info
{
    float now = [info[@"now"]floatValue];
    float need = [info[@"need"] floatValue];
    float fabs = [info[@"fabs"] floatValue];
    
    NSString *mesg = [NSString stringWithFormat:@"now:<%f>-need:<%f>-fabs:<%f>",now,need,fabs];
    UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:@"video_sync" message:mesg cancelButtonTitle:@"取消" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
    }];
    [alert show];
}

#pragma mark
#pragma mark -- 组件化关联
- (void)initBaseSDKComponent
{
    //基础sdk
    self.stremer = [CCStreamerBasic sharedStreamer];
    self.stremer.videoMode = CCVideoChangeByInterface;
    self.stremer.videoMode = CCVideoPortrait;
    [self.stremer addObserver:self];
    
    //排麦
    self.stremer.isUsePaiMai = YES;
    [self.stremer addObserver:self.ccBarelyManager];
    [self.ccBarelyManager addBasicClient:self.stremer];
    //白板
    [self.stremer addObserver:self.ccVideoView];
    [self.ccVideoView addBasicClient:self.stremer];
}

- (void)cc_updateAudioSession
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self cc_updateAudioSession];
    
    [self initUI];
    self.isLandSpace = YES;
    self.cameraPosition = AVCaptureDevicePositionFront;
    [self addObserver_push];
    [self addObserver];
    [self initBaseSDKComponent];
    WeakSelf(weakSelf);
    [self.stremer setListenOnStreamStatus:^(BOOL result, NSError *error, id info) {
        NSDictionary *dicInfo = (NSDictionary *)info;
        NSMutableDictionary *dic = [dicInfo mutableCopy];
        [dic setObject:@"sid" forKey:@"stream"];
        
        NSLog(@"\n -------");
        NSLog(@"\n Blacklisten-:%d er:%@ info:%@",result,error,[weakSelf objToString:dic]);
    }];
    
    [self loginAction];
}


- (NSString *)objToString:(id)obj
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
//    [self removeObserver];
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
    
    self.pickerViewData = @[@"退出",
                            @"开启预览",
                            @"开启直播",
                            @"开始推流",
                            @"停止推流",
                            @"停止直播",
                            @"停止预览",
                            @"获取链接状态",
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
        make.width.mas_equalTo(180.0f);
        make.height.mas_equalTo(200.0f);
    }];
}

#pragma mark - pickerview
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}
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
    cell.textLabel.textColor = [UIColor cyanColor];
    return cell;
}

#if 0

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
    {
        if(indexPath.row == 0)
        {
            [self leave];
            return;
        }
        [self.stremer playVideo:self.tempStream completion:^(BOOL result, NSError *error, id info) {
            NSLog(@"BLACK__play___res<%d> error:(%@) info:(%@)",result,error,info);
        }];
        return;
    }
    [self.stremer pauseVideo:self.tempStream completion:^(BOOL result, NSError *error, id info) {
        NSLog(@"BLACK__pause___res<%d> error:(%@) info:(%@)",result,error,info);
    }];
}

#else

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
    {
        [self tableView_BASE:tableView didSelectRowAtIndexPath:indexPath];
        return;
    }
    [self tableView_COM:tableView didSelectRowAtIndexPath:indexPath];
}

#endif

#pragma mark - tableview didSelect
#pragma mark - BASE_SDK
- (void)tableView_BASE:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row == CCBaseFunType_previewStart)
    {
        [self startPreView];
    }
    else if (row == CCBaseFunType_liveStart)
    {
        [self startLive];
    }
    else if (row == CCBaseFunType_publishStart)
    {
        [self publish];
    }
    else if (row == CCBaseFunType_publishStop)
    {
        [self unpublish];
    }
    else if (row == CCBaseFunType_liveStop)
    {
        [self stopLive];
    }
    else if (row == CCBaseFunType_previewStop)
    {
        [self stopPreView];
    }
    else if (row == CCBaseFunType_exit)
    {
        [self leave];
    }
    else if (row == CCBaseFunType_getStatus)
    {
        [self getconnectionStatus];
    }
    else if (row == CCBaseFunType_cameraChangeFrontBack)
    {
        [self changeCamera];
    }
    else if (row == CCBaseFunType_micChange)
    {
        [self changeAudio];
    }
    else if (row == CCBaseFunType_cameraChange)
    {
        [self changeVideo];
    }
}

- (void)changeCamera
{
    self.cameraIsBack = !self.cameraIsBack;
    //该功能暂未开放
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
    //防止重复加载
    __weak typeof(self) weakSelf = self;
    [self.stremer startPreview:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            if (weakSelf.preView)
            {
                [weakSelf.streamView removeStreamView:nil];
            }
            weakSelf.preView = nil;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.preView = info;
                [weakSelf.streamView showStreamView:info];
            });
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
            NSLog(@"%s__%d", __func__, __LINE__);
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
            NSLog(@"%s__%d", __func__, __LINE__);
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
            NSLog(@"%s__%d", __func__, __LINE__);
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
            NSLog(@"%s__%d", __func__, __LINE__);
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
//    [self loading_Add:@"正在退出....!"];
    __weak typeof(self) weakSelf = self;
    [self.ccVideoView removeObserverNotify];
    self.ccVideoView = nil;
    [self.stremer userLogout:self.token response:^(BOOL result, NSError *error, id info) {
        [self.stremer leave:^(BOOL result, NSError *error, id info) {
            NSLog(@"%s__%d", __func__, __LINE__);
            [weakSelf.stremer realsesAllStream];
            [weakSelf.stremer clearData];
//            [weakSelf loading_Remove];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

- (void)getconnectionStatus
{
    //该功能暂未开放
}

#pragma mark - 流
- (void)onServerDisconnected
{
    NSLog(@"%s__%d", __func__, __LINE__);
    WS(ws);
    dispatch_async(dispatch_get_main_queue(), ^{
//        [ws.navigationController popViewControllerAnimated:NO];
    });
}

- (void)onStreamAdded:(CCStream*)stream
{
    //TODO..REMOVE
    return;
    NSLog(@"onStreamAdded --%s__%d__%@", __func__, __LINE__, stream.streamID);
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
    self.tempStream = stream;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self autoSub:stream];
    });
}

- (void)onStreamRemoved:(CCStream*)stream
{
    NSLog(@"%s__%d", __func__, __LINE__);
    NSLog(@"onStreamRemoved --%s__%d__%@", __func__, __LINE__, stream.streamID);
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
    NSLog(@"%s__%d__%@__%@", __func__, __LINE__, error, stream.streamID);
}

- (void)autoSub:(CCStream *)stream
{
    NSLog(@"%s__%d__%@", __func__, __LINE__, stream.streamID);
    __weak typeof(self) weakSelf = self;
    [self.stremer subcribeWithStream:stream qualityLevel:0 completion:^(BOOL result, NSError *error, id info) {
        [self cc_updateAudioSession];
        if (result)
        {
            NSLog(@"PLAY___sub success %s__%d__%@__%@___%@", __func__, __LINE__, stream.streamID, @(result),info);
            [weakSelf.streamView showStreamView:info];
            
        }
        else
        {
            NSLog(@"PLAY___sub fail %s__%d__%@__%@__%@", __func__, __LINE__, stream.streamID, @(result),info);
            [weakSelf showError:error];
        }
    }];
}

- (void)autoUnSub:(CCStream *)stream
{
    NSLog(@"%s__%d__%@", __func__, __LINE__, stream.streamID);
    __weak typeof(self) weakSelf = self;
    [self.stremer unsubscribeWithStream:stream completion:^(BOOL result, NSError *error, id info) {
        NSLog(@"%s__%d__%@__%@", __func__, __LINE__, stream.streamID, @(result));
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
                NSLog(@"取消订阅失败，重新取消订阅");
                [weakSelf performSelector:@selector(autoUnSub:) withObject:stream afterDelay:1.f];
            }
        }
    }];
}

#pragma mark - login
-(void)loginAction
{
    [self.view endEditing:YES];
   
//    [self loading_Add];
    
    __weak typeof(self) weakSelf = self;
    CCEncodeConfig *config = [[CCEncodeConfig alloc] init];
    config.reslution = CCResolution_HIGH;
    
    NSString *authSessionID = self.info[@"data"][@"sessionid"];
    NSString *user_id = self.info[@"data"][@"userid"];
#pragma unused(user_id)
    
    self.token = authSessionID;
    self.accountId = self.viewerId;
    self.roomId = GetFromUserDefaults(LIVE_ROOMID);
    
    NSString *aid = @"83F203DAC2468694";
    NSString *sid = @"AD9C66E8B9DDBB2B9683D3C5CA6E374CB9EFC0C96892CF0DD3E32CEAE7F57EE869F88A0BAB54A77BD03846F895DAB4B3";
    

    aid = self.viewerId;
    sid = self.token;
    
    [self.stremer joinWithAccountID:aid sessionID:sid config:config areaCode:nil events:@[] completion:^(BOOL result, NSError *error, id info) {
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
    NSInteger row = indexPath.row - 1;
    if (row == SDK_Function_DOC_wipeSelf) {
        [self com_DOC_wipeAll:NO];
    }
    if (row == SDK_Function_DOC_wipeAll) {
        [self com_DOC_wipeAll:YES];
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
    if (row == SDK_Function_ReportLog) {
        [[CCStreamerBasic sharedStreamer]reportLogInfo];
    }
    if (row == SDK_Function_VoiceShow) {
        [self voiceShow];
    }
}
- (void)voiceShow
{
    VoiceViewController *voiceVC = [[VoiceViewController alloc]init];
    [self.navigationController pushViewController:voiceVC animated:YES];
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
- (void)com_DOC_wipeAll:(BOOL)wipeAll
{
    DocSimpleViewController *docController = [DocSimpleViewController new];
    NSString *user_id = self.info[@"data"][@"userid"];
    docController.user_id = user_id;
    docController.wipeAll = wipeAll;
    docController.ccVideoView = self.ccVideoView;
    docController.stremer = self.stremer;
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
                NSLog(@"%s__%d", __func__, __LINE__);
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
            NSLog(@"%s__%d", __func__, __LINE__);
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
        //当前用户被踢出房间
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
            NSLog(@"chenfy--%ld",(long)buttonIndex);
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
    else if(event == CCSocketEvent_PublishMessage)
    {
        NSString *val = value[@"value"];
        NSString *smessage = [NSString stringWithFormat:@"收到消息:%@",val];
        [self showMessage:smessage];
    }
    else if(event == CCSocketEvent_UserJoin)
    {
        CCUser *user = value[@"user"];
        NSString *uname = user.user_name;
        NSString *msg = [NSString stringWithFormat:@"<%@> 加入房间!",uname];
        [self showMessage:msg];
    }
    else if(event == CCSocketEvent_UserExit)
    {
        CCUser *user = value[@"user"];
        NSString *uname = user.user_name;
        NSString *msg = [NSString stringWithFormat:@"<%@> 离开房间!",uname];
        [self showMessage:msg];
    }
    else if(event == CCSocketEvent_UserHandUp)
    {
        CCUser *user = value[@"user"];
        NSString *name = user.user_name;
        NSString *str = [NSString stringWithFormat:@"<%@> 举手了！",name];
        [self showMessage:str];
    }
    else if (event == CCSocketEvent_ReciveDrawStateChanged)
    {
        //授权标注事件
        __unused CCUser *user = noti.userInfo[@"user"];
        if (user.user_drawState)
        {
            //被授权标注..客户开展后续自己的业务
        }
    }
    else if (event == CCSocketEvent_ReciveAnssistantChange)
    {
        //设为讲师事件
        __unused CCUser *user = noti.userInfo[@"user"];
        if (user.user_AssistantState)
        {
            //被设为讲师..客户开展后续自己的业务
        }
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
    NSLog(@"chat_message_received:%@",dic);
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
    NSLog(@"ccplay -- 释放了！");
    [self removeObserver];
}

- (void)loading_Add
{
    [self loading_Add:nil];
}
- (void)loading_Add:(NSString *)message
{
    if (!message || message.length == 0)
    {
        message = @"正在登录...";
    }
    [self loading_Remove];
    dispatch_async(dispatch_get_main_queue(), ^{
        _loadingView = [[LoadingView alloc] initWithLabel:message];
        [self.view addSubview:_loadingView];
        
        [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
    });
}
- (void)loading_Remove
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_loadingView removeFromSuperview];
    });
}



@end
