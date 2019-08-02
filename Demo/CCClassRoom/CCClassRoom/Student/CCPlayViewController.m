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
static BOOL gl_pub_sub_close = NO;
//判断应用层是否使用排麦组件
static BOOL gl_use_paimai = YES;

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
    CCBaseFunType_createLocalStream,
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
    CCBaseFunType_atlasReconnect,
    CCBaseFunType_setRegion, //设置主视频
    CCBaseFunType_userCustom
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
    
    [_ccVideoView setVideoPlayerContainer:self.view];
    [_ccVideoView setVideoPlayerFrame:CGRectMake(20, 20, 200, 200)];
    }
    return _ccVideoView;
}

- (CCDocVideoView *)createNewVideoView
{
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
    
    [_ccVideoView setVideoPlayerContainer:self.view];
    [_ccVideoView setVideoPlayerFrame:CGRectMake(20, 20, 200, 200)];
    
    return _ccVideoView;
}

- (void)showVideoCut:(NSDictionary *)info
{
    float now = [info[@"now"]floatValue];
    float need = [info[@"need"] floatValue];
    float fabs = [info[@"fabs"] floatValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *mesg = [NSString stringWithFormat:@"now:<%f>-need:<%f>-fabs:<%f>",now,need,fabs];
        UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:@"video_sync" message:mesg cancelButtonTitle:@"取消" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
        [alert show];
    });
}

#pragma mark
#pragma mark -- 组件化关联
- (void)initBaseSDKComponent
{
    //基础sdk
    self.stremer = [CCStreamerBasic sharedStreamer];
    [self.stremer addObserver:self];
    
    //排麦
    self.stremer.isUsePaiMai = gl_use_paimai;
    [self.stremer addObserver:self.ccBarelyManager];
    [self.ccBarelyManager addBasicClient:self.stremer];
    //白板
    [self.stremer addObserver:self.ccVideoView];
    [self.ccVideoView addBasicClient:self.stremer];
}

- (void)cc_updateAudioSession
{
    return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryMultiRoute withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionAllowBluetooth error:nil];
//        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [self initUI];
    self.isLandSpace = YES;
    self.cameraPosition = AVCaptureDevicePositionFront;
    [self addObserver_push];
    [self initBaseSDKComponent];
    WeakSelf(weakSelf);
    [self.stremer setListenOnStreamStatus:^(BOOL result, NSError *error, id info) {
        NSDictionary *dicInfo = (NSDictionary *)info;
        NSString *action = info[@"action"];
        NSLog(@"listen_on_streame_info-------:%@",info);

        if (![action isEqualToString:@"streamInfo"])
        {
            return ;
        }

        NSInteger type = [info[@"type"]integerValue];
        if (type == 1)
        {
            [weakSelf streamCheck_remote:dicInfo];
        }
        else
        {
            [weakSelf streamListenPubRetry:info];
        }
    }];
    
    [self loginAction];
}
//仅订阅音频
- (void)streamListenPubRetry:(NSDictionary *)info
{
    int status = [info[@"status"]intValue];
    if (status == 1003)
    {
        //1、停止推流
        [self.stremer unPublish:^(BOOL result, NSError *error, id info) {
            NSLog(@"00000-unPublish----%d--%@--%@---",result,error,info);
            
            [self stopPreView];
            //2、创建本地音频流
            [self.stremer createLocalStream:NO cameraFront:NO];
            [self startPreView];
            
            //3、重新推流
            [self.stremer publish:^(BOOL result, NSError *error, id info) {
                NSLog(@"00000-pubRetry----%d--%@--%@---",result,error,info);
            }];
        }];
    }
}
- (void)streamListenSubRetry:(NSDictionary *)info
{
    //该处需要取消订阅 ，重新订阅
}

#pragma mark --
- (void)streamCheck_remote:(NSDictionary *)info
{
    NSInteger status = [info[@"status"]integerValue];
    if (status == 1003)
    {
//        [self atlas_ServerReconnect];
    }
}

- (NSString *)objToString:(id)obj
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return str;
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
                            @"创建本地流",
                            @"开启预览",
                            @"开启直播",
                            @"开始推流",
                            @"停止推流",
                            @"停止直播",
                            @"停止预览",
                            @"获取链接状态",
                            @"切换摄像头",
                            @"开启或者关闭麦克风",
                            @"开启或者关闭摄像头",
                            @"ATLAS 重连",
                            @"Set Region",
                            @"User Custom"];
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
    if (row == CCBaseFunType_createLocalStream)
    {
        [self createLocalStream];
    }
    else if (row == CCBaseFunType_previewStart)
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
    else if(row == CCBaseFunType_atlasReconnect)
    {
        [self atlas_ServerReconnect];
    }
    else if(row == CCBaseFunType_setRegion)
    {
        [self streamSetRegion];
    }
    else if(row == CCBaseFunType_userCustom)
    {
        [self.stremer updateUserCustom:666 userId:self.room.user_id completion:^(BOOL result, NSError *error, id info) {
            NSLog(@"user custom update!");
        }];
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
    [self.stremer setAudioOpened:!self.audioClose userID:nil];
}

- (void)changeVideo
{
    self.videoCLose = !self.videoCLose;
    [self.stremer setVideoOpened:!self.videoCLose userID:nil];
}

- (void)createLocalStream
{
    [self.stremer createLocalStream:YES cameraFront:YES];
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
            [CCTool showError:error];
        }
    }];
}

- (void)startLive
{
    [self.stremer startLive:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [CCTool showError:error];
        }
    }];
}

- (void)stopLive
{
    [self.stremer stopLive:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [CCTool showError:error];
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
            [self.ccBarelyManager updateUserState:self.room.user_id roomID:self.room.room_id publishResult:YES streamID:weakSelf.localStreamID completion:^(BOOL result, NSError *error, id info) {

            }];
        }
        else
        {
            [CCTool showError:error];
        }
    }];
}

- (void)unpublish
{
    [self.stremer unPublish:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [CCTool showError:error];
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
            [CCTool showError:error];
        }
    }];
}

- (void)leave_copy
{    
//    [self loading_Add:@"正在退出....!"];
    __weak typeof(self) weakSelf = self;
    [self.ccVideoView removeObserverNotify];
    self.ccVideoView = nil;
    NSLog(@"-------leave---click---");

    [self.stremer userLogout:self.token response:^(BOOL result, NSError *error, id info) {
        NSLog(@"----leave------userLogout---");

    }];
    [self.stremer leave:^(BOOL result, NSError *error, id info) {
        NSLog(@"----leave------leave---");
    }];
    [weakSelf.stremer clearData];
    //            [weakSelf loading_Remove];
    [weakSelf.navigationController popViewControllerAnimated:YES];
}
- (void)leave
{
    //    [self loading_Add:@"正在退出....!"];
    __weak typeof(self) weakSelf = self;
    
    [self.ccVideoView removeObserverNotify];
    if (self.ccVideoView)
    {
        [self.ccVideoView docRelease];
        self.ccVideoView = nil;
    }
    NSLog(@"-------leave---click---");
    
    [self.stremer unPublish:^(BOOL result, NSError *error, id info) {
        
    }];
    [self.stremer userLogout:self.token response:^(BOOL result, NSError *error, id info) {
        NSLog(@"----leave------userLogout---");
        [self.stremer leave:^(BOOL result, NSError *error, id info) {
            NSLog(@"----leave------leave---");
            [weakSelf.stremer clearData];
            [self removeObserver];
            //[weakSelf loading_Remove];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

- (void)getconnectionStatus
{
    //该功能暂未开放
}

//设置主视频流
- (void)streamSetRegion
{
    [[CCStreamerBasic sharedStreamer]setRegion:self.localStreamID completion:^(BOOL result, NSError *error, id info) {
        
    }];
}

#pragma mark - 流
- (void)onServerDisconnected
{
    NSLog(@"%s__%d", __func__, __LINE__);
    [CCTool showMessage:@"流服务连接断开！"];
}

- (void)SDKNeedsubStream:(NSNotification *)notify
{
    if (gl_pub_sub_close) return;

    NSLog(@"-sdk---sub---:%@",notify);
    NSDictionary *dicInfo = notify.userInfo;
    NSString *sid = dicInfo[@"streamID"];
    NSInteger role = [dicInfo[@"role"]integerValue];
    NSString *name = dicInfo[@"name"];
    NSString *ID = dicInfo[@"id"];
#pragma unused(role,name,ID)
    if (!gl_use_paimai)
    {
        return;
    }
    CCStream *stream = [self.stremer getStreamWithStreamID:sid];
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
    [self showRole:stream role:role];
    self.tempStream = stream;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self autoSub:stream];
    });
}

- (void)onStreamAdded:(CCStream*)stream
{
    if (gl_pub_sub_close) return;
    
    NSLog(@"ZZZZZZZ---onStreamAdded --%s__%d__%@--role<%d>", __func__, __LINE__, stream.streamID,stream.role);
    if (gl_use_paimai)
    {
        return;
    }
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
    [self showRole:stream role:0];
    self.tempStream = stream;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self autoSub:stream];
    });
}
#pragma mark --展示
- (void)showRole:(CCStream *)stream role:(NSInteger)roleType
{
    CCRole role;
    if (stream)
    {
        role = stream.role;
    }
    else
    {
        role = roleType;
    }
    NSString *roleString = [CCRoom stringFromRole:role];
    NSString *streamAdd = [NSString stringWithFormat:@"streamadd-role-<%@>",roleString];
    [CCTool  showToast:streamAdd];
}

- (void)SDKNeedUnsubStream:(NSNotification *)notify
{
    if (gl_pub_sub_close) return;

    NSLog(@"-sdk---unsub---:%@",notify);
    NSDictionary *dicInfo = notify.userInfo;
    NSString *sid = dicInfo[@"streamID"];
    NSInteger role = [dicInfo[@"role"]integerValue];
    NSString *name = dicInfo[@"name"];
    NSString *ID = dicInfo[@"id"];
#pragma unused(role,name,ID)
    if (!gl_use_paimai)
    {
        return;
    }
    CCStream *stream = [self.stremer getStreamWithStreamID:sid];
    if ([stream.userID isEqualToString:self.stremer.userID])
    {
        //自己的流没有订阅
        return;
    }
    [self autoUnSub:stream];
}

- (void)onStreamRemoved:(CCStream*)stream
{
    if (gl_pub_sub_close) return;

    NSLog(@"%s__%d", __func__, __LINE__);
    NSLog(@"ZZZZZZZ---onStreamRemoved --%s__%d__%@", __func__, __LINE__, stream.streamID);
    if (gl_use_paimai)
    {
        return;
    }
    if ([stream.userID isEqualToString:self.stremer.userID])
    {
        //自己的流没有订阅
        return;
    }
    [self autoUnSub:stream];
}

- (void)onStreamError:(NSError *)error forStream:(CCStream *)stream
{
    NSLog(@"%s__%d__%@__%@", __func__, __LINE__, error, stream.streamID);
    [CCTool showError:error];
}

- (void)autoSub:(CCStream *)stream
{
    NSLog(@"%s__%d__%@", __func__, __LINE__, stream.streamID);
    __weak typeof(self) weakSelf = self;
    [self.stremer subcribeWithStream:stream completion:^(BOOL result, NSError *error, id info) {
        [self cc_updateAudioSession];
        if (result)
        {
            NSLog(@"PLAY___sub success %s__%d__%@__%@___%@", __func__, __LINE__, stream.streamID, @(result),info);
        }
        else
        {
            NSLog(@"PLAY___sub fail %s__%d__%@__%@__%@", __func__, __LINE__, stream.streamID, @(result),info);
            [CCTool showError:error];
        }
    }];
}

- (void)onStreamFrameDecoded:(CCStream *)stream
{
    [self.streamView showStreamView:stream];
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
            [CCTool showError:error];
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
    
    NSString *aid = @"6634678BEDA5BB7D";
    NSString *sid = @"BC4E4ECD033FCEA3BAB1C353CD452736C965F98D3441215377878C7CD1426D05924D3394E1CBF840DF201C04F92246BF";
    
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
    docController.ccVideoView = [self createNewVideoView];
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
            [CCTool showMessage:@"房间没有开启直播！"];
        }
        return NO;
    }
    else if (classType != typeIn)
    {
        if (isShow)
        {
            [CCTool showMessage:@"房间连麦模式不匹配！"];
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
        [CCTool showMessage:@"举手连麦"];
    }
    if (classType == CCClassType_Auto) {
        [CCTool showMessage:@"自由连麦"];
    }
    if (classType == CCClassType_Rotate) {
        [CCTool showMessage:@"自动连麦"];
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
            [CCTool showError:error];
        }
    }];
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

#pragma mark -- 接收
-(void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveSocketEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startPublish) name:CCNotiNeedStartPublish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPublish) name:CCNotiNeedStopPublish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needLogout) name:CCNotiNeedLoginOut object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SDKNeedsubStream:) name:CCNotiNeedSubscriStream object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SDKNeedUnsubStream:) name:CCNotiNeedUnSubcriStream object:nil];
}
-(void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startPublish
{
    WS(weakSelf);
    //申请连麦成功，开始推流
    [self.stremer createLocalStream:YES cameraFront:YES];
    [self com_startPreview:^(BOOL result, NSError *error, id info) {
        if (!result) {
            [CCTool showError:error];
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
                [CCTool showError:error];
            }
        }];
    }];
}

- (void)com_startPreview:(CCComletionBlock)completion
{
    //只开启一次预览，知道退出房间时再关闭预览
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
            [CCTool showError:error];
        }
    }];
}

- (void)needLogout
{

}
//用户下麦
- (void)com_pm_xiamai
{
    if (!self.stremer.localStreamID || self.stremer.localStreamID.length == 0)
    {
        [CCTool showMessage:@"目前没有上麦！"];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIAlertView bk_showAlertViewWithTitle:@"消息" message:@"收到老师上麦邀请" cancelButtonTitle:@"拒绝" otherButtonTitles:@[@"接受"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                NSLog(@"chenfy--%ld",(long)buttonIndex);
                if (buttonIndex == 1)
                {
                    [weakSelf com_accept_invite];
                }
            }];
        });
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
        [CCTool showMessage:smessage];
    }
    else if(event == CCSocketEvent_UserJoin)
    {
        CCUser *user = value[@"user"];
        NSString *uname = user.user_name;
        NSString *msg = [NSString stringWithFormat:@"<%@> 加入房间!",uname];
        [CCTool showMessage:msg];
    }
    else if(event == CCSocketEvent_UserExit)
    {
        CCUser *user = value[@"user"];
        NSString *uname = user.user_name;
        NSString *msg = [NSString stringWithFormat:@"<%@> 离开房间!",uname];
        [CCTool showMessage:msg];
    }
    else if(event == CCSocketEvent_UserHandUp)
    {
        CCUser *user = value[@"user"];
        NSString *name = user.user_name;
        NSString *str = [NSString stringWithFormat:@"<%@> 举手了！",name];
        [CCTool showMessage:str];
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
    else if(event == CCSocketEvent_UserCustomUpdate)
    {
        NSDictionary *info = noti.userInfo;
        CCUser *user= info[@"user"];
        NSString *message = [NSString stringWithFormat:@"userid--:%@--custom--:%ld",user.user_id,(long)user.user_custom];
        [CCTool showMessage:message];
        NSLog(@"user custom update!");
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
        [CCTool showMessage:socketMsg];
    }
    else
    {
        NSString *imageUrl = msg[@"content"];
        NSString *imageMessage = [NSString stringWithFormat:@"收到聊天Pic-:%@",imageUrl];
        [CCTool showMessage:imageMessage];
    }
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

#pragma mark --
#pragma mark -- loading 加载框
- (void)loading_Add
{
    [self loading_Add:nil];
}
- (void)loading_Add:(NSString *)message
{
    [CCTool loadingAddTo:self.view message:message];
}
- (void)loading_Remove
{
    [CCTool loadingRemove];
}

#pragma mark --
#pragma mark --sockets delegate 事件
/** socket连接失败 */
- (void)onFailed
{
    [CCTool showToast:@"socket连接失败！"];
}

/** socket连接成功 */
- (void)onSocketConnected:(NSString *)nsp
{
    [CCTool showToast:@"socket连接成功！"];
}

/** socket重连 */
- (void)onsocketReconnectiong
{
    [CCTool showToast:@"socket重连......！"];
}

/** socket断开(同时开始重连) */
- (void)onconnectionClosed
{
    [CCTool showToast:@"socket断开重连！"];
}

/** socket重连成功 */
- (void)onSocketReconnected:(NSString *)nsp
{
    [CCTool showToast:@"socket重连成功！"];
}

#pragma mark -- 断开重连
static bool gl_sub_error_show = false;

- (void)atlas_ServerReconnect
{
    if (gl_sub_error_show == true)
    {
        return;
    }
    gl_sub_error_show = true;
    
    NSLog(@"%s__%d", __func__, __LINE__);
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIAlertView bk_showAlertViewWithTitle:@"提示" message:@"将要断开流服务,请确认是否重连？" cancelButtonTitle:@"取消" otherButtonTitles:@[@"重连"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            gl_sub_error_show = false;
            if (buttonIndex == 1)
            {
                //重连
                NSLog(@"onServerDisconnected --- 重连！");
                [[CCStreamerBasic sharedStreamer]streamServerReConnect:^(BOOL result, NSError *error, id info) {
                    if (result)
                    {
                        return ;
                    }
                    if (error.code == 301)
                    {
                        [CCTool showError:error];
                    }
                    NSLog(@"onServerDisconnected-dd___%s__res__%d__error:%@__info:%@__",__func__,result,error,info);
                }];
            }
        }];
    });
}

@end
