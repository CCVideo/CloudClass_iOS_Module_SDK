//
//  CCTeachCopyViewController.m
//  CCClassRoom
//
//  Created by cc on 2018/9/25.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "CCTeachCopyViewController.h"
#import "CCPublicTableViewCell.h"
#import "CustomTextField.h"
#import "CCLiveSettingViewController.h"
#import "CCMemberTableViewController.h"
#import "LoadingView.h"
#import "CCStreamerView.h"
#import <BlocksKit+UIKit.h>
#import "CCLoginScanViewController.h"
#import "CCDocListViewController.h"
#import "CCTemplateViewController.h"
#import "CCSignViewController.h"
#import "CCSignResultViewController.h"
#import "CCSignManger.h"
#import "CCStudentActionManager.h"
#import <Photos/Photos.h>
#import "CCPhotoNotPermissionVC.h"
#import <AFNetworking.h>
#import "HyPopMenuView.h"
#import "CCUploadFile.h"
#import "TZImagePickerController.h"
#import "CCLoginViewController.h"
#import "CCActionCollectionViewCell.h"
#import "CCStreamModeTeach_Teacher.h"
#import "CCStreamerModeTile.h"
#import "CCStreamModeSingle.h"
#import "AppDelegate.h"
#import "CCDrawMenuView.h"
#import "CCRewardView.h"
#import "CCLoadingView.h"
#import "CCStreamCheck.h"
#define infomationViewClassRoomIconLeft 3
#define infomationViewErrorwRight 9.f
#define infomationViewHandupImageViewRight 16.f
#define infomationViewHostNamelabelLeft  13.f
#define infomationViewHostNamelabelRight 0.f

@interface CCTeachCopyViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,HyPopMenuViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, CCDrawMenuViewDelegate,CCStreamerBasicDelegate>
@property(nonatomic,assign)BOOL hasMessage;
@property(nonatomic,strong)CCStreamerView       *streamView;
@property(nonatomic,strong)UILabel              *hostNameLabel;
@property(nonatomic,strong)UILabel              *userCountLabel;
@property(nonatomic,strong)UIImageView          *informtionBackImageView;
@property(nonatomic,strong)UIImageView          *classRommIconImageView;

@property(nonatomic,strong)UIView               *informationView;
@property(nonatomic,strong)UIButton             *rightSettingBtn;
@property(nonatomic,strong)UIButton             *closeBtn;

#pragma mark -- 助教切麦按钮
@property(nonatomic,strong)UIButton             *publicChatBtn;
@property(nonatomic,strong)UIButton             *cameraChangeBtn;
@property(nonatomic,strong)UIButton             *micChangeBtn;
@property(nonatomic,strong)UIButton             *startPublishBtn;
@property(nonatomic,strong)UIButton             *stopPublishBtn;
@property(nonatomic,strong)UIButton             *menuBtn;

@property(nonatomic,strong)CustomTextField      *chatTextField;
@property(nonatomic,strong)UIButton             *sendButton;
@property(nonatomic,strong)UIButton             *sendPicButton;
@property(nonatomic,strong)UIView               *contentView;
@property(nonatomic,strong)UIButton             *rightView;
@property(nonatomic,strong)NSMutableArray       *tableArray;
@property(nonatomic,copy)NSString               *antename;
@property(nonatomic,copy)NSString               *anteid;
@property(nonatomic,strong)UIView               *emojiView;
@property(nonatomic,assign)CGRect               keyboardRect;
@property(nonatomic,strong)LoadingView          *loadingView;
@property(nonatomic,strong)NSTimer              *room_user_cout_timer;//获取房间人数定时器

@property(nonatomic,strong)UIImageView *handupImageView;
@property(nonatomic,strong)UIView *keyboardTapView;

@property(nonatomic,strong)CCStudentActionManager *actionManager;
@property(strong,nonatomic)UIImagePickerController      *picker;
@property(nonatomic,assign)BOOL currentIsInBottom;

@property(nonatomic,strong)HyPopMenuView *menu;
@property(nonatomic,strong)CCUploadFile *uploadFile;
@property(nonatomic,strong)CCStreamView *preview;
@property(nonatomic,strong)NSArray *actionData;
@property(nonatomic,strong)NSIndexPath *movieClickIndexPath;
@property(nonatomic,strong)CCUser *movieClickUser;
@property(nonatomic,strong)UIButton *hideVideoBtn;
@property (strong, nonatomic)CCDrawMenuView *drawMenuView;

#pragma mark strong
@property(nonatomic,strong)CCRoom *room;
@property(nonatomic,assign)BOOL willTeacherRewardShow;
@property(nonatomic,assign)BOOL isInBackground;
@property(nonatomic,strong)NSMutableArray *showBlackVideoArray;
@property(nonatomic,strong)CCStreamerBasic *stremer;
@property(nonatomic,strong)CCBarleyManager *ccBarelyManager;
@property(nonatomic,strong)CCDocVideoView *ccVideoView;
@property(nonatomic,strong)CCChatManager *ccChatManager;
@property(nonatomic,strong)CCStream *mixedStream;
@property(nonatomic,strong)CCStream *localStream;
///合屏流之外的流
//@property(nonatomic,strong)CCStream *otherStream;
@property(nonatomic,strong)CCStreamView *shareScreen;
@property(nonatomic,strong)CCStreamView *assistantCamera;
@property(nonatomic,strong)CCDragView *shareScreenView;
@property(nonatomic,strong)CCDragView *assistantCameraView;
@property(nonatomic,strong)UITapGestureRecognizer *shareScreenViewGes;
@property(nonatomic,strong)UITapGestureRecognizer *assistantCameraViewGes;
@property(nonatomic,assign)CGRect shareScreenViewOldFrame;
@property(nonatomic,assign)CGRect assistantCameraOldFrame;
@property(nonatomic,strong)UIButton *windowFullScreenBtn;
@property(nonatomic,strong)UIButton *windowFullScreenBtnAss;

@end

@implementation CCTeachCopyViewController

-(instancetype)initWithLandspace:(BOOL)landspace
{
    self = [super init];
    if(self) {
        self.isLandSpace = landspace;
        [self addObserver];
        //初始化组件
        [self initBaseSdkComponent];
    }
    return self;
}
#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentIsInBottom = YES;
    self.isInBackground = NO;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    self.navigationController.navigationBarHidden=YES;
    
    if (self.isLandSpace)
    {
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appdelegate.shouldNeedLandscape = self.isLandSpace;
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
    }
    
    [self initUI];
    [self setVideoParentView];
    
    self.keyboardTapView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.keyboardTapView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleTap:)];
    [self.keyboardTapView addGestureRecognizer:singleTap];
    
    SaveToUserDefaults(SET_CAMERA_DIRECTION, @"前置摄像头");
    
    [self.contentView addSubview:self.ccVideoView];
    /*老师异常退出之后，再次登录，要拉取处于推流中学生的流*/
    if ([[CCStreamerBasic sharedStreamer] getRoomInfo].live_status == CCLiveStatus_Start)
    {
        //订阅所有的流
        NSArray *allStreamIDS = [[CCStreamerBasic sharedStreamer] getSpeakInfo].streamsSubed;
        for (NSDictionary *info in allStreamIDS)
        {
            NSNotification *noti = [[NSNotification alloc] initWithName:CCNotiNeedSubscriStream object:nil userInfo:info];
        }
    }
    [self configHandupImage];
    //必须先登录
    [self loginAction];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _willTeacherRewardShow = NO;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(room_user_count) object:nil];
    [self.room_user_cout_timer invalidate];
    self.room_user_cout_timer = nil;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    CCWeakProxy *weakProxy = [CCWeakProxy proxyWithTarget:self];
    self.room_user_cout_timer = [NSTimer scheduledTimerWithTimeInterval:3.f target:weakProxy selector:@selector(room_user_count) userInfo:nil repeats:YES];
    
    if (self.isLandSpace)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
}

#pragma mark -- 组件化关联
- (void)initBaseSdkComponent
{
    //基础sdk
    self.stremer = [CCStreamerBasic sharedStreamer];
    [self.stremer addObserver:self];//也就是代理
    
    //排麦
    self.stremer.isUsePaiMai = YES;
    [self.stremer addObserver:self.ccBarelyManager];
    [self.ccBarelyManager addBasicClient:self.stremer];
    
    //白板
    HDSDocManager *hdsM = [HDSDocManager sharedDoc];
    CCDocVideoView *videoView = [hdsM hdsDocView];
    self.ccVideoView = videoView;
    
    //白版
    [self.stremer addObserver:self.ccVideoView];
    [self.ccVideoView addBasicClient:self.stremer];
    
    //聊天
    [self.stremer addObserver:self.ccChatManager];
    [self.ccChatManager addBasicClient:self.stremer];
}

-(void)setVideoParentView {
    [[HDSDocManager sharedDoc] setVideoParentView:self.view];
    CGRect vfm = CGRectMake(SCREEN_WIDTH * 0.5 - 100, SCREEN_HEIGHT * 0.5 - 60, 200, 120);
    [[HDSDocManager sharedDoc] setVideoParentViewFrame:vfm];
    [[HDSDocManager sharedDoc] initDocEnvironment];
}

#pragma mark 首先登录
- (void)loginAction{
    //必须创建本地流
    __weak typeof(self) weakSelf = self;
    [self.stremer createLocalStream:YES cameraFront:YES];
    
    [[CCStreamerBasic sharedStreamer] startPreview:^(BOOL result, NSError *error, id info) {
        weakSelf.preview = info;
        [weakSelf.streamView showStreamView:weakSelf.preview];
        [weakSelf.view sendSubviewToBack:weakSelf.streamView];
        [weakSelf rotati];
    }];
    
    [self loginSuccess];
}

- (void)listenStreamBlack
{
    return;
    //    [[CCStreamerBasic sharedStreamer]onStreamStatsListener:^(BOOL result, NSError *error, id info) {
    //        if (self.room.live_status == CCLiveStatus_Stop) {
    //            return ;
    //        }
    //        NSLog(@"__result_%d__error__%@__info__%@",result,error,info);
    //        NSDictionary *dicInfo = (NSDictionary *)info;
    //        NSString *action = dicInfo[@"action"];
    //
    //        CCStream *stream = (CCStream *)dicInfo[@"stream"];
    //        NSLog(@"黑流 %@  %@",stream.streamID, dicInfo[@"type"]);
    //        if ([action isEqualToString:@"streamInfo"])
    //        {
    //            [[NSNotificationCenter defaultCenter]postNotificationName:KKEY_Loading_changed object:info];
    //        }
    //    }];
}

- (void)postStreamStatusMessage:(id)obj
{
    NSLog(@"AAAAAAAAAAAAAAAAA___%@",obj);
    NSDictionary *dicReceive = obj;
    int status = [dicReceive[@"status"]intValue];
    BOOL isRemote = [dicReceive[@"type"]boolValue];
    CCStream *stream = dicReceive[@"stream"];
    NSDictionary *dicNew = @{@"streamID":stream.streamID,@"role":@(CCRole_Student)};
    
    [[NSNotificationCenter defaultCenter]postNotificationName:KKEY_Loading_changed object:obj];
    
    if (status == 1003 && isRemote)
    {   //重新订阅
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"流ID:%@订阅失败，请选择",stream.streamID] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *reSubAction = [UIAlertAction actionWithTitle:@"重新加载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.showBlackVideoArray removeObject:stream.streamID];
            NSNotification *nofity = [NSNotification notificationWithName:@"black" object:nil userInfo:dicNew];
            [self reSub:nofity];
            NSLog(@"re_re_substream");
        }];
        UIAlertAction *audioAction = [UIAlertAction actionWithTitle:@"只听音频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            //取消订阅视频频流
            [[CCStreamerBasic sharedStreamer] changeStream:stream videoState:NO completion:^(BOOL result, NSError *error, id info) {
                //修改本地音视频流状态
                NSLog(@"pauseVideo  result %d , info %@ , error %@",(result?1:0),info,error);
                if (result) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:KKEY_Audio_changed object:@{@"result":@"audio",@"stream":stream}];
                }
            }];
            
        }];
        UIAlertAction *changeAction = [UIAlertAction actionWithTitle:@"切换节点(退出到登录页面选择节点)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self closeBtnClickedWithAssistant];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.showBlackVideoArray removeObject:stream.streamID];
        }];
        [alert addAction:reSubAction];
        [alert addAction:audioAction];
        [alert addAction:changeAction];
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:true completion:nil];
    }
    if (status == 1003 && !isRemote)
    {   //重新推流
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"流ID:%@订推流失败，请选择",stream.streamID] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *changeAction = [UIAlertAction actionWithTitle:@"重新推流" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self rePublishBlackFlow];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.showBlackVideoArray removeObject:stream.streamID];
        }];
        [alert addAction:changeAction];
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:true completion:nil];
        NSLog(@"re_re_publish");
    }
}

- (void)changeAudio:(NSNotification *)object {
    NSDictionary *dicInfo = object.object;
    NSString *result = dicInfo[@"result"];
    CCStream *stream = dicInfo[@"stream"];
    if ([result isEqualToString:@"all"]) {
        [self.showBlackVideoArray removeObject:stream.streamID];
    } else {
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _willTeacherRewardShow = YES;
    [self.streamView viewDidAppear];
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

- (void)dealSingleTap:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:self.view];
    [self.chatTextField resignFirstResponder];
    if(CGRectContainsPoint(self.tableView.frame, point))
    {
        
    }
    else
    {
        
    }
}

-(void)initUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.streamView];
    WS(ws)
    [self.streamView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo([CCTool tool_MainWindowSafeArea]);
    }];
    {
        [self.view addSubview:self.topContentBtnView];
        [self.topContentBtnView addSubview:self.informationView];
        [self.topContentBtnView addSubview:self.closeBtn];
        [self.topContentBtnView addSubview:self.fllowBtn];
        [self.topContentBtnView addSubview:self.hideVideoBtn];
        
        NSString *name = GetFromUserDefaults(LIVE_USERNAME);
        NSString *userName = [@"" stringByAppendingString:name.length == 0 ? @"CC小班课" : name];
        NSString *userCount = @"122个成员";
        CGSize userNameSize = [CCTool getTitleSizeByFont:userName font:[UIFont systemFontOfSize:FontSizeClass_14]];
        CGSize userCountSize = [CCTool getTitleSizeByFont:userCount font:[UIFont systemFontOfSize:FontSizeClass_12]];
        
        CGSize size = userNameSize.width > userCountSize.width ? userNameSize : userCountSize;
        
        if(size.width > self.view.frame.size.width * 0.2) {
            size.width = self.view.frame.size.width * 0.2;
        }
        
        [self.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.view);
            make.right.mas_equalTo(ws.view);
            make.top.mas_equalTo(ws.view).offset([CCTool tool_MainWindowSafeArea_Top]);
            make.height.mas_equalTo(35);
        }];
        
        [self.informationView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.topContentBtnView).offset(CCGetRealFromPt(30));
            make.top.mas_equalTo(ws.topContentBtnView);
            make.bottom.mas_equalTo(ws.topContentBtnView);
            make.width.mas_equalTo(85 + size.width);
        }];
        
        [self.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.topContentBtnView).offset(-CCGetRealFromPt(30));
            make.centerY.mas_equalTo(ws.informationView);
        }];
        
        [self.fllowBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.closeBtn.mas_left).offset(-CCGetRealFromPt(30));
            make.centerY.mas_equalTo(ws.informationView);
        }];
        
        [self.hideVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.closeBtn.mas_left).offset(-CCGetRealFromPt(30));
            make.centerY.mas_equalTo(ws.informationView);
        }];
        
        CCRoomTemplate template = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_template;
        if (template == CCRoomTemplateSingle)
        {
            self.fllowBtn.hidden = NO;
        }
        else
        {
            self.fllowBtn.hidden = YES;
        }
    }
    {
        [self.view addSubview:self.contentBtnView];
        [self.view addSubview:self.tableView];
        [self.contentBtnView addSubview:self.publicChatBtn];
        [self.contentBtnView addSubview:self.cameraChangeBtn];
        [self.contentBtnView addSubview:self.micChangeBtn];
        [self.contentBtnView addSubview:self.menuBtn];
        [self.contentBtnView addSubview:self.startPublishBtn];
        [self.contentBtnView addSubview:self.stopPublishBtn];
        
        self.cameraChangeBtn.hidden = YES;
        self.micChangeBtn.hidden = YES;
        self.stopPublishBtn.hidden = YES;
        self.startPublishBtn.hidden = NO;
        
        [_contentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.view);
            make.bottom.mas_equalTo(ws.view).offset(-[CCTool tool_MainWindowSafeArea_Bottom]);
            make.height.mas_equalTo(CCGetRealFromPt(130));
        }];
        
        float oneWidth = [UIImage imageNamed:@"message"].size.width;
        CGFloat width = self.isLandSpace ? MAX(self.view.frame.size.width, self.view.frame.size.height) : MIN(self.view.frame.size.width, self.view.frame.size.height);
        float all = width - 5*oneWidth;
        float oneDel = all/6.f;
        
        [_startPublishBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
            make.centerX.mas_equalTo(ws.contentBtnView);
        }];
        
        [_stopPublishBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
            make.centerX.mas_equalTo(ws.contentBtnView);
        }];
        
        [_publicChatBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.contentBtnView).offset(oneDel);
            make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
        }];
        
        [_menuBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.contentBtnView).offset(-oneDel);
            make.bottom.mas_equalTo(ws.publicChatBtn);
        }];
        
        
        [_micChangeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.menuBtn.mas_left).offset(-oneDel);
            make.bottom.mas_equalTo(ws.publicChatBtn);
        }];
        
        [_cameraChangeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.publicChatBtn.mas_right).offset(oneDel);
            make.bottom.mas_equalTo(ws.publicChatBtn);
        }];
        
        [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(30));
            make.bottom.mas_equalTo(ws.contentBtnView.mas_top);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
        }];
    }
    {
        [self.view addSubview:self.contentView];
        [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.mas_equalTo(ws.view);
            make.height.mas_equalTo(CCGetRealFromPt(110));
        }];
        
        [self.contentView addSubview:self.sendPicButton];
        UIImage *image = [UIImage imageNamed:@"photo"];
        [self.sendPicButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(ws.contentView.mas_centerY);
            make.left.mas_equalTo(ws.contentView).offset(CCGetRealFromPt(1));
            make.size.mas_equalTo(image.size);
        }];
        
        [self.contentView addSubview:self.chatTextField];
        [_chatTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(ws.contentView.mas_centerY);
            make.left.mas_equalTo(ws.sendPicButton.mas_right).offset(CCGetRealFromPt(0));
            make.height.mas_equalTo(CCGetRealFromPt(78));
        }];
        
        [self.contentView addSubview:self.sendButton];
        [_sendButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(ws.contentView.mas_centerY);
            make.left.mas_equalTo(ws.chatTextField.mas_right).offset(CCGetRealFromPt(10));
            make.right.mas_equalTo(ws.contentView).offset(-CCGetRealFromPt(10));
            make.height.mas_equalTo(CCGetRealFromPt(84));
        }];
        
        self.contentView.hidden = YES;
    }
}

//开始直播后的UI
- (void)publishAreadyStartUI:(BOOL)isStart
{
    WS(weakSelf);
    if (isStart)
    {
        //调整btn显示隐藏
        weakSelf.startPublishBtn.hidden = YES;
        weakSelf.cameraChangeBtn.hidden = NO;
        weakSelf.stopPublishBtn.hidden = NO;
        weakSelf.micChangeBtn.hidden = NO;
        [weakSelf.loadingView removeFromSuperview];
    }
    CCRoom *room = [self.stremer getRoomInfo];
    BOOL hasAssistant = room.room_assist_on;
    if (hasAssistant)
    {
        [self handRecordPublishStartResetUI:YES];
    }
}

#pragma mark - auto start
- (void)autoStart
{
    BOOL hasAssistant = self.room.room_assist_on;
    if (hasAssistant)
    {
        [self first_start_has_assistant];
    }
    else
    {
        [self first_start_no_assistant];
    }
}

#pragma mark -- 房间没有助教
- (void)first_start_no_assistant
{
    if (self.room.room_manual_record)
    {
        [self room_hand_record_assistant_not];
    }
    else
    {
        [self room_hand_record_not_assistant_not];
    }
}

//mark -- 是否开启手动录制
- (void)room_hand_record_assistant_not
{
    CCLiveStatus status = self.room.live_status;
    __weak typeof(self) weakSelf = self;
    if (status == CCLiveStatus_Start)
    {
        [UIAlertView bk_showAlertViewWithTitle:KKEY_tips_title message:KKEY_open_recording cancelButtonTitle:KKEY_cancel otherButtonTitles:@[KKEY_continue] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            _loadingView = [[LoadingView alloc] initWithLabel:KKEY_loading];
            [self.view addSubview:_loadingView];
            
            [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
            }];
            BOOL withRecord = NO;
            if (buttonIndex == 1)
            {
                withRecord = YES;
            }
            else
            {
                withRecord = NO;
            }
            [self.stremer  startLiveWithRecord:withRecord completion:^(BOOL result, NSError *error, id info) {
                if (result)
                {
                    NSLog(@"%s", __func__);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf handRecordPublishStartResetUI:YES];
                        [weakSelf.loadingView removeFromSuperview];
                    });
                    //修改录制按钮状态
                    if (withRecord)
                    {
                        //2019年09月24日16:35:42
                        //                        [weakSelf recordChangeButtonUITo:CCRecordType_Start];
                    }
                    //这里没有更新publish以及更新麦序
                    [self.stremer publish:^(BOOL result, NSError *error, id info) {
                        if (result) {
                            [self.ccBarelyManager updateUserState:weakSelf.room.user_id roomID:nil publishResult:YES streamID:weakSelf.stremer.localStreamID completion:^(BOOL result, NSError *error, id info) {
                                //                                [self showTestMessage:@"test----004"];
                                if (!result)
                                {
                                    [CCTool showMessage:@"老师推流成功，麦序更新失败"];
                                }
                            }];
                        }
                        else
                        {
                            //重新推流
                            [weakSelf publishRetry];
                        }
                    }];
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.loadingView removeFromSuperview];
                    });
                    NSLog(@"publish error:%@", error);
                    [weakSelf publishRetry];
                }
            }];
        }];
    }
}
- (void)room_hand_record_not_assistant_not
{
    CCRoom *room = [self.stremer getRoomInfo];
    CCLiveStatus status = room.live_status;
    __weak typeof(self) weakSelf = self;
    if (status == CCLiveStatus_Start)
    {
        [UIAlertView bk_showAlertViewWithTitle:@"注意" message:KKEY_continue_liveing cancelButtonTitle:@"取消" otherButtonTitles:@[@"继续"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1)
            {
                NSLog(@"%s__%d", __func__, __LINE__);
                [self.stremer publish:^(BOOL result, NSError *error, id info) {
                    if (result) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.loadingView removeFromSuperview];
                            [self.ccBarelyManager updateUserState:weakSelf.room.user_id roomID:nil publishResult:YES streamID:weakSelf.stremer.localStreamID completion:^(BOOL result, NSError *error, id info) {
                                if (!result)
                                {
                                    [CCTool showMessage:@"老师推流成功，麦序更新失败!"];
                                }
                            }];
                            //调整btn显示隐藏
                            [weakSelf publishAreadyStartUI:YES];
                        });
                    }else{
                        [weakSelf.loadingView removeFromSuperview];
                        [weakSelf publishAreadyStartUI:YES];
                        [weakSelf publishRetry];
                    }
                }];
            }
            else
            {
                [weakSelf.loadingView removeFromSuperview];
                [self stopPublish];
            }
        }];
    }
}

#pragma mark -- 房间有助教
- (void)first_start_has_assistant
{
    if (self.room.room_manual_record)
    {
        [self room_hand_record_assistant];
    }
    else
    {
        [self room_hand_record_not_assistant];
    }
}
//mark -- 是否开启手动录制
- (void)room_hand_record_assistant
{
    CCLiveStatus status = self.room.live_status;
    if (status == CCLiveStatus_Start)
    {
        [self handRecordPublishStartResetUI:YES];
        __weak typeof(self)weakSelf = self;
        
        [UIAlertView bk_showAlertViewWithTitle:@"注意" message:KKEY_open_recording cancelButtonTitle:KKEY_cancel otherButtonTitles:@[KKEY_open] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1)
            {
                [weakSelf recordChangeToType:CCRecordType_Start response:^(BOOL result, NSError *error, id info) {
                    [self.stremer startLive:^(BOOL result, NSError *error, id info) {
                        [self.stremer publish:^(BOOL result, NSError *error, id info) {
                            //模拟麦序更新失败的情况
                            [self.ccBarelyManager updateUserState:self.room.user_id roomID:nil publishResult:YES streamID:weakSelf.stremer.localStreamID completion:^(BOOL result, NSError *error, id info) {
                                if (!result)
                                {
                                    [CCTool showMessageError:error];
                                }
                            }];
                        }];
                    }];
                }];
            }else{//如果没有开启录制，直接推流展示
                [weakSelf startPublish];
            }
        }];
    }
}
//不存在该情况,<有助教必须开启手动录制>
- (void)room_hand_record_not_assistant
{
}

#pragma mark -- 重新推流
- (void)publishRetry
{
    [UIAlertView bk_showAlertViewWithTitle:@"" message:@"推流异常，请重新推流或退出房间重新进入！" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1)
        {
            //先停止推流，否则，处于推流中，无法停止直播。
            [self.stremer unPublish:^(BOOL result, NSError *error, id info) {
                if (result) {
                    [self rePublish];
                }
            }];
        }
    }];
}
//显示正在推流中，不能停止直播
- (void)rePublish
{
    __weak typeof(self) weakSelf = self;
    [self.stremer  stopLive:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSLog(@"%s", __func__);
            [weakSelf startPublish];
        }
        else
        {
            if (error.code != 4002)
            {
                NSString *errMsg = [CCTool toolErrorMessage:error];
                [UIAlertView bk_showAlertViewWithTitle:@"" message:errMsg cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                }];
            }
            else
            {
                [weakSelf startPublish];
            }
        }
    }];
}

//录制结束
- (void)recordChangeToType:(CCRecordType)type response:(CCComletionBlock)block
{
    WS(weakSelf);
    CCStreamerBasic *streamer = self.stremer ;
    [streamer recordTo:type completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            //            [weakSelf recordChangeButtonUITo:type];
            block(YES,nil,nil);
            return ;
        }
        [UIAlertView bk_showAlertViewWithTitle:nil message:@"录制状态切换失败！" cancelButtonTitle:@"取消" otherButtonTitles:@[@"放弃切换"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1)
            {
                //如果放弃录制，则跳过录制阶段
                block(YES,nil,nil);
            }
        }];
    }];
}

////修改录制按钮样式
//- (void)recordChangeButtonUITo:(CCRecordType)type
//{
//    self.liveRecordType = type;
//    NSString *imageName = nil;
//    switch (type) {
//        case CCRecordType_Start:
//        case CCRecordType_Resume:
//            imageName = @"on_rec";
//            break;
//        case CCRecordType_Pause:
//            imageName = @"pause_rec";
//            break;
//        case CCRecordType_End:
//            imageName = @"start_rec";
//            break;
//        default:
//            break;
//    }
//    UIImage *image = [UIImage imageNamed:imageName];
//    [self.buttonRecord setBackgroundImage:image forState:UIControlStateNormal];
//}

- (void)handRecordPublishStartResetUI:(BOOL)handRecord
{
    handRecord = self.room.room_manual_record;
    WS(ws);
    //调整btn显示隐藏
    self.startPublishBtn.hidden = YES;
    self.cameraChangeBtn.hidden = NO;
    self.stopPublishBtn.hidden = NO;
    self.micChangeBtn.hidden = NO;
    [self.loadingView removeFromSuperview];
    
    //    self.buttonRecord.hidden = YES;
    [_stopPublishBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
        make.centerX.mas_equalTo(ws.contentBtnView);
    }];
}

- (void)startPublish
{
    //开始推流
    _loadingView = [[LoadingView alloc] initWithLabel:@"请稍候..."];
    [self.view addSubview:_loadingView];
    
    [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    NSLog(@"%s", __func__);
    CCLiveStatus status = [self.stremer  getRoomInfo].live_status;
    __weak typeof(self) weakSelf = self;
    if (status == CCLiveStatus_Stop){
        
        //直接调用publish  跟必须能麦序
        [self.stremer startLive:^(BOOL result, NSError *error, id info) {
            if (result) {
                [self.stremer publish:^(BOOL result, NSError *error, id info) {
                    if (result) {
                        ///更新麦序
                        [weakSelf teacherCopyUpdateMicStatus:result];
                        [[NSUserDefaults standardUserDefaults] setObject:info forKey:@"streamID"];
                    }else{
                        [UIAlertView bk_showAlertViewWithTitle:@"注意" message:@"助教推流失败，是否重新推流" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                            if (buttonIndex == 1) {
                                [self.stremer stopLive:^(BOOL result, NSError *error, id info) {
                                    if (result) {
                                        [weakSelf startPublish];
                                    }
                                }];
                            }
                        }];
                    }
                }];
            }else{
                [CCTool showMessageError:error];
            }
            [_loadingView removeFromSuperview];
        }];
    }else {
        ///直播中
        //打断点会z导致崩溃  继续上场直播，并没有推流
        [UIAlertView bk_showAlertViewWithTitle:@"注意" message:@"是否继续上场直播" cancelButtonTitle:@"取消" otherButtonTitles:@[@"继续"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1)
            {
                NSLog(@"%s__%d", __func__, __LINE__);
                [self.stremer publish:^(BOOL result, NSError *error, id info) {
                    if (result) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //推流完成之后，更新麦序
                            [weakSelf.loadingView removeFromSuperview];
                            ///更新麦序
                            [weakSelf teacherCopyUpdateMicStatus:result];
                            //调整btn显示隐藏
                            [weakSelf publishAreadyStartUI:YES];
                        });
                    }else{
                        [weakSelf.loadingView removeFromSuperview];
                        [weakSelf publishAreadyStartUI:YES];
                        [weakSelf publishRetry];
                    }
                }];
            }
            else
            {
                [weakSelf.loadingView removeFromSuperview];
                [self stopPublish];
            }
        }];
    }
}

- (void)touchInfoMationView
{
    //跳往成员列表
    CCMemberTableViewController *memberVC = [[CCMemberTableViewController alloc] init];
    memberVC.ccDocVideoView = self.ccVideoView;
    [self.navigationController pushViewController:memberVC animated:YES];
}

- (void)touchSettingBtn
{
    //跳往设置界面
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    CCLiveSettingViewController *settingVC = [story instantiateViewControllerWithIdentifier:@"live_setting"];
    [self.navigationController pushViewController:settingVC animated:YES];
}

-(void)viewPress {
    [_chatTextField resignFirstResponder];
}

-(void)publicChatBtnClicked
{    
    BOOL isMute = ![[CCStreamerBasic sharedStreamer] getRoomInfo].allow_chat;
    BOOL isMuteAll = ![[CCStreamerBasic sharedStreamer] getRoomInfo].room_allow_chat;
    if (isMute || isMuteAll)
    {
        NSString *messgage = isMuteAll ? @"全体禁言中" : @"禁言中";
        [UIAlertView bk_showAlertViewWithTitle:@"" message:messgage cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
        return;
    }
    [_chatTextField becomeFirstResponder];
}

-(void)cameraChangeBtnClicked {
    if (_cameraChangeBtn.selected) {
        //setVideoOpened设置视频状态
        [[CCStreamerBasic sharedStreamer] setVideoOpened:YES userID:nil];
        //设置流视频状态
        _cameraChangeBtn.selected = !_cameraChangeBtn.selected;
    }
    else
    {
        //未选中，表示视频推流
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"切换摄像头", @"关闭摄像头", nil];
        [sheet showInView:self.view];
    }
}

//设置音频状态
-(void)micChangeBtnClicked {
    _micChangeBtn.selected = !_micChangeBtn.selected;
    if(_micChangeBtn.selected) {
        //changeStream
        [self.stremer setAudioOpened:NO userID:nil];
    } else {
        [self.stremer setAudioOpened:YES userID:nil];
    }
}


-(void)stopPublishBtnClick
{
    __weak typeof(self) weakSelf = self;
    [UIAlertView bk_showAlertViewWithTitle:@"" message:@"是否确认结束直播" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1)
        {
            _loadingView = [[LoadingView alloc] initWithLabel:@"请稍候..."];
            [self.view addSubview:_loadingView];
            
            [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
            }];
            ///先结束推流,再结束直播
            [self.stremer unPublish:^(BOOL result, NSError *error, id info) {
                if (result) {
                    [[CCStreamerBasic sharedStreamer] stopLive:^(BOOL result, NSError *error, id info) {
                        if (result)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //调整UI
                                weakSelf.cameraChangeBtn.hidden = YES;
                                weakSelf.stopPublishBtn.hidden = YES;
                                weakSelf.micChangeBtn.hidden = YES;
                                weakSelf.startPublishBtn.hidden = NO;
                                weakSelf.cameraChangeBtn.selected = NO;
                                weakSelf.micChangeBtn.selected = NO;
                                weakSelf.fllowBtn.selected = NO;
                            });
                        }
                        [weakSelf.loadingView removeFromSuperview];
                    }];
                }
            }];
        }
    }];
}

-(void)closeBtnClicked
{
    CCUser *userCopy = [CCTool tool_room_user_role:CCRole_Teacher];
    if (userCopy)
    {
        [self closeBtnClickedWithAssistant]; //没有助教在房间内
    }
    else
    {
        [self closeBtnClickedWithAssistantNone]; //助教在房间内
    }
}
//关闭按钮，离开房间
- (void)closeBtnClickedWithAssistantNone
{
    NSString *message;
    if (self.startPublishBtn.hidden)
    {
        //表示正在推流
        message = @"是否确认离开课堂?离开后将结束直播";
    }
    else
    {
        message = @"是否确认离开课堂";
    }
    
    __weak typeof(self) weakSelf = self;
    [UIAlertView bk_showAlertViewWithTitle:@"" message:message cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1)
        {
            NSLog(@"%s", __func__);
            _loadingView = [[LoadingView alloc] initWithLabel:@"正在关闭直播间..."];
            [weakSelf.view addSubview:_loadingView];
            
            [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
            }];
            [weakSelf removeObserver];
            NSLog(@"%s", __func__);
            
            dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 10*NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^{
                [weakSelf popToScanVC];
            });
            
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                if (weakSelf.startPublishBtn.hidden)
                {
                    [[CCStreamerBasic sharedStreamer] stopLive:^(BOOL result, NSError *error, id info) {
                        if (result)
                        {
                            [[CCStreamerBasic sharedStreamer] leave:^(BOOL result, NSError *error, id info) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [weakSelf.loadingView removeFromSuperview];
                                    //正常退出，清空文档记录
                                    SaveToUserDefaults(DOC_DOCID, nil);
                                    SaveToUserDefaults(DOC_DOCPAGE, @(-1));
                                    SaveToUserDefaults(DOC_ROOMID, nil);
                                    [weakSelf popToScanVC];
                                });
                            }];
                        }
                    }];
                }
                else
                {
                    [[CCStreamerBasic sharedStreamer] leave:^(BOOL result, NSError *error, id info) {
                        NSLog(@"%s", __func__);
                        [weakSelf.loadingView removeFromSuperview];
                        //正常退出，清空文档记录
                        SaveToUserDefaults(DOC_DOCID, nil);
                        SaveToUserDefaults(DOC_DOCPAGE, @(-1));
                        SaveToUserDefaults(DOC_ROOMID, nil);
                        [weakSelf popToScanVC];
                    }];
                }
            });
        }
    }];
}
- (void)closeBtnClickedWithAssistant
{
    NSString *message = @"是否确认离开课堂";
    
    __weak typeof(self) weakSelf = self;
    [UIAlertView bk_showAlertViewWithTitle:@"" message:message cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1)
        {
            NSLog(@"%s", __func__);
            _loadingView = [[LoadingView alloc] initWithLabel:@"正在离开直播间..."];
            [weakSelf.view addSubview:_loadingView];
            
            [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
            }];
            [weakSelf removeObserver];
            NSLog(@"%s", __func__);
            
            dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 10*NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^{
                [weakSelf popToScanVC];
            });
            
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                if (weakSelf.startPublishBtn.hidden)
                {
                    [[CCStreamerBasic sharedStreamer]unPublish:^(BOOL result, NSError *error, id info) {
                        [[CCStreamerBasic sharedStreamer] leave:^(BOOL result, NSError *error, id info) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf.loadingView removeFromSuperview];
                                //正常退出，清空文档记录
                                SaveToUserDefaults(DOC_DOCID, nil);
                                SaveToUserDefaults(DOC_DOCPAGE, @(-1));
                                SaveToUserDefaults(DOC_ROOMID, nil);
                                [weakSelf popToScanVC];
                            });
                        }];
                    }];
                }
                else
                {
                    [[CCStreamerBasic sharedStreamer] leave:^(BOOL result, NSError *error, id info) {
                        NSLog(@"%s", __func__);
                        [weakSelf.loadingView removeFromSuperview];
                        //正常退出，清空文档记录
                        SaveToUserDefaults(DOC_DOCID, nil);
                        SaveToUserDefaults(DOC_DOCPAGE, @(-1));
                        SaveToUserDefaults(DOC_ROOMID, nil);
                        [weakSelf popToScanVC];
                    }];
                }
            });
        }
    }];
}

- (void)clickMenuBtn:(UIButton *)btn
{
    [self showMenu];
}

- (void)clickFllowBtn:(UIButton *)btn
{
    NSString *fllowStreamID = [[CCStreamerBasic sharedStreamer] getRoomInfo].teacherFllowUserID;
    btn.enabled = NO;
    if (fllowStreamID.length != 0)
    {
        //关闭
        [self.ccBarelyManager changeMainStreamInSigleTemplate:@"" completion:^(BOOL result, NSError *error, id info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                btn.enabled = YES;
            });
        }];
    }
    else
    {
        //要获取当前大屏的
        NSString *teacherID = [self.streamView touchFllow];
        if (teacherID.length == 0)
        {
            NSArray *userList = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList;
            for (CCUser *info in userList)
            {
                if (info.user_role == CCRole_Teacher)
                {
                    teacherID = info.user_id;
                    break;
                }
            }
        }
        [self.ccBarelyManager changeMainStreamInSigleTemplate:teacherID completion:^(BOOL result, NSError *error, id info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                btn.enabled = YES;
            });
        }];
    }
}

- (void)faceBoardClick {
    BOOL selected = !_rightView.selected;
    _rightView.selected = selected;
    
    if(selected) {
        [_chatTextField setInputView:self.emojiView];
    } else {
        [_chatTextField setInputView:nil];
    }
    
    [_chatTextField becomeFirstResponder];
    [_chatTextField reloadInputViews];
}

-(void)sendBtnClicked {
    [self chatSendMessage];
    [_chatTextField resignFirstResponder];
}

-(void)sendPicBtnClicked {
    [_chatTextField resignFirstResponder];
    [self selectImage];
}

- (void) backFace {
    NSString *inputString = _chatTextField.text;
    if ( [inputString length] > 0) {
        NSString *string = nil;
        NSInteger stringLength = [inputString length];
        if (stringLength >= FACE_NAME_LEN) {
            string = [inputString substringFromIndex:stringLength - FACE_NAME_LEN];
            NSRange range = [string rangeOfString:FACE_NAME_HEAD];
            if ( range.location == 0 ) {
                string = [inputString substringToIndex:[inputString rangeOfString:FACE_NAME_HEAD options:NSBackwardsSearch].location];
            } else {
                string = [inputString substringToIndex:stringLength - 1];
            }
        }
        else {
            string = [inputString substringToIndex:stringLength - 1];
        }
        _chatTextField.text = string;
    }
}

- (void)faceButtonClicked:(id)sender {
    NSInteger i = ((UIButton*)sender).tag;
    
    NSMutableString *faceString = [[NSMutableString alloc]initWithString:_chatTextField.text];
    [faceString appendString:[NSString stringWithFormat:@"[em2_%02d]",(int)i]];
    _chatTextField.text = faceString;
}

- (void)configHandupImage
{
    CCClassType mode = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_class_type;
    if (mode == CCClassType_Auto)
    {
        [self setHandupImageHidden:YES];
    }
    else if(mode == CCClassType_Rotate)
    {
        //点名连麦
        NSArray *dic = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList;
        NSInteger count = 0;
        for (CCUser *info in dic)
        {
            if (info.handup)
            {
                count++;
            }
        }
        if (count > 0)
        {
            [self setHandupImageHidden:NO];
        }
        else
        {
            [self setHandupImageHidden:YES];
            //隐藏收的按钮
        }
    }
    else
    {
        //点名连麦
        NSArray *dic = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList;
        NSInteger count = 0;
        for (CCUser *info in dic)
        {
            CCUserMicStatus micType = info.user_status;
            if (micType == CCUserMicStatus_Wait)
            {
                count++;
            }
        }
        if (count > 0)
        {
            [self setHandupImageHidden:NO];
        }
        else
        {
            [self setHandupImageHidden:YES];
            //隐藏收的按钮
        }
    }
}

- (void)setHandupImageHidden:(BOOL)hidden
{
    WS(ws);
    if (hidden)
    {
        self.handupImageView.hidden = YES;
        NSString *name = GetFromUserDefaults(LIVE_USERNAME);
        NSString *userName = [@"" stringByAppendingString:name.length == 0 ? @"421小班课" : name];
        NSString *userCount = @"122个成员";
        CGSize userNameSize = [CCTool getTitleSizeByFont:userName font:[UIFont systemFontOfSize:FontSizeClass_14]];
        CGSize userCountSize = [CCTool getTitleSizeByFont:userCount font:[UIFont systemFontOfSize:FontSizeClass_12]];
        
        CGSize size = userNameSize.width > userCountSize.width ? userNameSize : userCountSize;
        
        CGFloat width = infomationViewClassRoomIconLeft + self.classRommIconImageView.image.size.width + infomationViewHostNamelabelLeft + size.width + infomationViewHostNamelabelRight + infomationViewHandupImageViewRight;
        if(width > self.view.frame.size.width * 0.5) {
            width = self.view.frame.size.width * 0.5;
        }
        
        [_informationView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width);
        }];
        [_hostNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.classRommIconImageView.mas_right).offset(infomationViewHostNamelabelLeft);
            make.right.mas_equalTo(ws.informationView).offset(-10);
            make.top.mas_equalTo(ws.informationView).offset(CCGetRealFromPt(2));
        }];
    }
    else
    {
        self.handupImageView.hidden = NO;
        NSString *name = GetFromUserDefaults(LIVE_USERNAME);
        NSString *userName = [@"" stringByAppendingString:name.length == 0 ? @"421小班课" : name];
        NSString *userCount = @"122个成员";
        CGSize userNameSize = [CCTool getTitleSizeByFont:userName font:[UIFont systemFontOfSize:FontSizeClass_14]];
        CGSize userCountSize = [CCTool getTitleSizeByFont:userCount font:[UIFont systemFontOfSize:FontSizeClass_12]];
        
        CGSize size = userNameSize.width > userCountSize.width ? userNameSize : userCountSize;
        
        CGFloat width = infomationViewClassRoomIconLeft + self.classRommIconImageView.image.size.width + infomationViewHostNamelabelLeft + size.width + infomationViewHostNamelabelRight + self.handupImageView.image.size.width + infomationViewHandupImageViewRight;
        if(width > self.view.frame.size.width * 0.5) {
            width = self.view.frame.size.width * 0.5;
        }
        
        [_informationView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width);
        }];
        [_hostNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.classRommIconImageView.mas_right).offset(infomationViewHostNamelabelLeft);
            make.right.mas_equalTo(ws.handupImageView.mas_left).offset(-infomationViewHostNamelabelRight);
            make.top.mas_equalTo(ws.informationView).offset(CCGetRealFromPt(2));
        }];
    }
}

- (UIButton *)hideVideoBtn
{
    if(!_hideVideoBtn) {
        _hideVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hideVideoBtn setBackgroundImage:[UIImage imageNamed:@"hide"] forState:UIControlStateNormal];
        [_hideVideoBtn setBackgroundImage:[UIImage imageNamed:@"hide_touch"] forState:UIControlStateHighlighted];
        [_hideVideoBtn setBackgroundImage:[UIImage imageNamed:@"hide_on"] forState:UIControlStateSelected];
        [_hideVideoBtn addTarget:self action:@selector(hideVideoBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hideVideoBtn;
}

- (void)hideVideoBtnClicked:(UIButton *)btn
{
    btn.selected = !btn.selected;
    [self.streamView hideOrShowVideo:btn.selected];
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.chatTextField resignFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellPush";
    Dialogue *dialogue = [_tableArray objectAtIndex:indexPath.row];
    CCPublicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[CCPublicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    WS(ws);
    [cell reloadWithDialogue:dialogue antesomeone:^(NSString *antename, NSString *anteid) {
        self.actionManager = [CCStudentActionManager new];
        [self.actionManager showWithUserID:dialogue.userid inView:ws.view dismiss:^(BOOL result, id info) {
            
        }];
    }];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CCGetRealFromPt(26);
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, CCGetRealFromPt(26))];
    view.backgroundColor = CCClearColor;
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Dialogue *dialogue = [self.tableArray objectAtIndex:indexPath.row];
    return dialogue.msgSize.height + 10;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self chatSendMessage];
    return YES;
}

-(void)chatSendMessage {
    NSString *str = _chatTextField.text;
    if(str == nil || str.length == 0) {
        return;
    }
    if (str.length > 300)
    {
        [CCTool showMessage:@"消息长度超过300字限制！"];
        return;
    }
    _chatTextField.text = nil;
    [_chatTextField resignFirstResponder];
    str = [Dialogue addLinkTag:str];
    [[CCChatManager sharedChat] sendMsg:str];
}
//前后台监听
- (void)appInBack
{
    self.isInBackground = YES;
}
- (void)appInFront
{
    
}

/** 处理聊天区域的背景色 */
- (void)tableview_bgColorOndirectPor:(BOOL)isPortrait
{
    if (_hasMessage)
    {
        return;
    }
    _hasMessage = YES;
    //解决聊天文字显示不清问题
    if (!self.isLandSpace)
    {
        _tableView.backgroundColor = [UIColor clearColor];
    }
    else
    {
        _tableView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
}

#pragma mark - keyboard notification
- (void)keyboardWillShow:(NSNotification *)notif {
    [self.view addSubview:self.keyboardTapView];
    [self.view bringSubviewToFront:self.contentView];
    if(![self.chatTextField isFirstResponder]) {
        return;
    }
    NSDictionary *userInfo = [notif userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    _keyboardRect = [aValue CGRectValue];
    CGFloat y = _keyboardRect.size.height;
    //    CGFloat x = _keyboardRect.size.width;
    
    if ([self.chatTextField isFirstResponder]) {
        self.contentBtnView.hidden = YES;
        self.contentView.hidden = NO;
        WS(ws)
        [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.view);
            make.bottom.mas_equalTo(ws.view).offset(-y);
            make.height.mas_equalTo(CCGetRealFromPt(110));
        }];
        
        [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(30));
            make.bottom.mas_equalTo(ws.contentBtnView.mas_top);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
        }];
        
        [UIView animateWithDuration:0.25f animations:^{
            [ws.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    WS(ws)
    
    [self.keyboardTapView removeFromSuperview];
    self.contentBtnView.hidden = NO;
    self.contentView.hidden = YES;
    [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(ws.view);
        make.height.mas_equalTo(CCGetRealFromPt(110));
    }];
    
    [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(30));
        make.bottom.mas_equalTo(ws.contentBtnView.mas_top);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
    }];
    
    [UIView animateWithDuration:0.25f animations:^{
        self.contentView.hidden = YES;
        [ws.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - CCStreamerBasic noti
- (void)chat_message_chat_message:(NSDictionary *)dic
{
    [self tableview_bgColorOndirectPor:NO];
    Dialogue *dialogue = [[Dialogue alloc] init];
    dialogue.userid = dic[@"userid"];
    dialogue.username = [dic[@"username"] stringByAppendingString:@": "];
    dialogue.userrole = dic[@"userrole"];
    NSString *msg = dic[@"msg"];
    NSString *type = dic[@"isMessage"];
    
    if ([type isEqualToString:@"1"])
    {
        dialogue.msg = [Dialogue removeLinkTag:msg];
        dialogue.type = DialogueType_Text;
    }
    else
    {
        NSDictionary *dicPic = @{@"content":msg};
        dialogue.picInfo = dicPic;
        dialogue.picUrl = msg;
        dialogue.type = DialogueType_Pic;
    }
    dialogue.time = dic[@"time"];
    dialogue.myViwerId = _viewerId;
    WS(weakSelf);
    [dialogue calcMsgSize:_tableView.frame.size.width font:[UIFont systemFontOfSize:FontSizeClass_16] block:^{
        [_tableArray addObject:dialogue];
        
        if([_tableArray count] >= 1){
            [_tableView reloadData];
            
            if (weakSelf.currentIsInBottom)
            {
                //在最底部
                NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:([_tableArray count]-1) inSection:0];
                [_tableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
    }];
}

- (void)chat_message_media_message:(NSDictionary *)dic
{
    [self tableview_bgColorOndirectPor:NO];
    Dialogue *dialogue = [[Dialogue alloc] init];
    dialogue.userid = dic[@"userid"];
    dialogue.username = [dic[@"username"] stringByAppendingString:@": "];
    dialogue.userrole = dic[@"userrole"];
    NSString *msg = dic[@"msg"];
    if ([msg isKindOfClass:[NSString class]])
    {
        msg = [Dialogue removeLinkTag:msg];
        dialogue.msg = msg;
        dialogue.type = DialogueType_Text;
    }
    else
    {
        dialogue.picInfo = (NSDictionary *)msg;
        dialogue.type = DialogueType_Pic;
    }
    dialogue.time = dic[@"time"];
    dialogue.myViwerId = _viewerId;
    WS(weakSelf);
    [dialogue calcMsgSize:_tableView.frame.size.width font:[UIFont systemFontOfSize:FontSizeClass_16] block:^{
        [_tableArray addObject:dialogue];
        
        if([_tableArray count] >= 1){
            [_tableView reloadData];
            
            if (weakSelf.currentIsInBottom)
            {
                //在最底部
                NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:([_tableArray count]-1) inSection:0];
                [_tableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
    }];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat height = scrollView.frame.size.height;
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat bottomOffset = scrollView.contentSize.height - contentOffsetY;
    CGFloat del = bottomOffset - height;
    if (del <= 25)
    {
        //在最底部
        self.currentIsInBottom = YES;
    }
    else
    {
        self.currentIsInBottom = NO;
    }
}

- (void)room_user_count
{
    [[CCStreamerBasic sharedStreamer] updateUserCount];
}

- (void)room_customMessage:(NSDictionary *)dic
{
    /*
     action = release(表示需要显示的公告) remove(表示清除公告);
     announcement = sfjsdjflsdkjf(内容);
     */
    NSLog(@"%s --%@", __func__, dic);
}

- (void)receiveSocketEvent:(NSNotification *)noti
{
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    id value = noti.userInfo[@"value"];
    if (event == CCSocketEvent_UserListUpdate)
    {
        //房间列表
        NSInteger str = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_user_count;
        NSString *userCount = [NSString stringWithFormat:@"%ld个成员", (long)str];
        _userCountLabel.text = userCount;
    }
    else if (event == CCSocketEvent_Announcement)
    {
        //公告
        [self room_customMessage:value];
    }
    else if (event == CCSocketEvent_Chat)
    {
        //聊天信息
        [self chat_message_chat_message:value];
    }
    else if (event == CCSocketEvent_GagOne)
    {
        NSLog(@"%d", __LINE__);
        BOOL isMute = [[CCStreamerBasic sharedStreamer] getRoomInfo].allow_chat;
        if (isMute && [[CCStreamerBasic sharedStreamer] getRoomInfo].room_allow_chat)
        {
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message"] forState:UIControlStateNormal];
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message_touch"] forState:UIControlStateHighlighted];
        }
        else
        {
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"chat_mut"] forState:UIControlStateNormal];
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"chat_mut"] forState:UIControlStateNormal];
        }
    }
    else if (event == CCSocketEvent_MediaModeUpdate)
    {
        CCVideoMode micType = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_video_mode;
        [self.streamView roomMediaModeUpdate:micType];
    }
    else if (event == CCSocketEvent_VideoStateChanged)
    {
        CCUser *user = noti.userInfo[@"user"];
        [self.streamView streamView:user.user_id videoOpened:user.user_videoState];
    }
    else if (event == CCSocketEvent_AudioStateChanged || event == CCSocketEvent_ReciveAnssistantChange)
    {
        //        CCUser *user = noti.userInfo[@"user"];
        //        [self.streamView streamView:user.user_id audioOpened:user.user_audioState];
        [self.streamView reloadData];
    }
    else if (event == CCSocketEvent_UserCountUpdate)
    {
        NSInteger allCount = [value integerValue];
        NSString *userCount = [NSString stringWithFormat:@"%ld个成员", (long)allCount];
        _userCountLabel.text = userCount ;
    }
    else if (event == CCSocketEvent_TeacherNamedInfo)
    {
        //        NSDictionary *list = [[CCStreamerBasic sharedStreamer] getNamedInfo];
        //        NSLog(@"%s__%@", __func__, list);
    }
    else if (event == CCSocketEvent_StudentNamed)
    {
        //        NSArray *list = [[CCStreamerBasic sharedStreamer] getStudentNamedList];
        //        NSLog(@"%s__%@", __func__, list);
    }
    else if (event == CCSocketEvent_LianmaiStateUpdate || event == CCSocketEvent_LianmaiModeChanged || event == CCSocketEvent_HandupStateChanged)
    {
        [self configHandupImage];
        //影藏的导航栏出现
        [self.streamView showMenuBtn];
    }
    else if (event == CCSocketEvent_SocketReconnectedFailed)
    {
        //退出
        __weak typeof(self) weakSelf = self;
        
        _loadingView = [[LoadingView alloc] initWithLabel:@"正在关闭直播间..."];
        [weakSelf.view addSubview:_loadingView];
        
        [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        [weakSelf removeObserver];
        [UIAlertView bk_showAlertViewWithTitle:@"" message:@"网络太差" cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [[CCStreamerBasic sharedStreamer] leave:^(BOOL result, NSError *error, id info) {
                [weakSelf.loadingView removeFromSuperview];
                //正常退出，清空文档记录
                SaveToUserDefaults(DOC_DOCID, nil);
                SaveToUserDefaults(DOC_DOCPAGE, @(-1));
                SaveToUserDefaults(DOC_ROOMID, nil);
                [weakSelf popToScanVC];
                
            }];
            //            [self popToScanVC];
        }];
    }
    else if (event == CCSocketEvent_TemplateChanged)
    {
        //        CCRoomTemplate template = (CCRoomTemplate)[[noti.userInfo objectForKey:@"value"] integerValue];
        //        [self.streamView configWithMode:CCRoomTemplateSpeak role:CCRole_Teacher];
        //        if (self.isLandSpace && template == CCRoomTemplateSpeak)
        //        {
        //            self.hideVideoBtn.hidden = NO;
        //            self.drawMenuView.hidden = NO;
        //            [_streamView disableTapGes:NO];
        //        }
        //        else
        //        {
        //            self.hideVideoBtn.hidden = YES;
        //            self.drawMenuView.hidden = YES;
        //            [_streamView disableTapGes:YES];
        //        }
        //        self.hideVideoBtn.selected = NO;
    }
    else if (event == CCSocketEvent_MainStreamChanged)
    {
        NSString *followID = [[CCStreamerBasic sharedStreamer] getRoomInfo].teacherFllowUserID;
        _fllowBtn.selected = followID.length == 0 ? NO : YES;
    }
    else if (event == CCSocketEvent_StreamRemoved)
    {
        //退出
        __weak typeof(self) weakSelf = self;
        _loadingView = [[LoadingView alloc] initWithLabel:@"正在关闭直播间..."];
        [weakSelf.view addSubview:_loadingView];
        
        [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        [weakSelf removeObserver];
        [UIAlertView bk_showAlertViewWithTitle:@"" message:@"流断开了" cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [[CCStreamerBasic sharedStreamer] leave:^(BOOL result, NSError *error, id info) {
                [weakSelf.loadingView removeFromSuperview];
                //正常退出，清空文档记录
                SaveToUserDefaults(DOC_DOCID, nil);
                SaveToUserDefaults(DOC_DOCPAGE, @(-1));
                SaveToUserDefaults(DOC_ROOMID, nil);
                [weakSelf popToScanVC];
                
            }];
            //            [self popToScanVC];
        }];
    }
    else if (event == CCSocketEvent_PublishStart)
    {
        CCRoomTemplate template = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_template;
        if (self.isLandSpace && template == CCRoomTemplateSpeak)
        {
            self.hideVideoBtn.hidden = NO;
        }
        else
        {
            self.hideVideoBtn.hidden = YES;
        }
        [self publishIsLivingResetUI:YES];
    }
    else if (event == CCSocketEvent_PublishEnd)
    {
        self.hideVideoBtn.hidden = YES;
        self.hideVideoBtn.selected = NO;
        [self.streamView hideOrShowVideo:NO];
        [self publishIsLivingResetUI:NO];
    }
    else if (event == CCSocketEvent_DocDraw)
    {
        
    }
    else if (event == CCSocketEvent_DocPageChange)
    {
        
    }
    else if (event == CCSocketEvent_ReciveDocAnimationChange)
    {
        
    }
    else if (event == CCSocketEvent_KickFromRoom)
    {
        NSLog(@"%d", __LINE__);
        [self removeObserver];
        
        __weak typeof(self) weakSelf = self;
        [UIAlertView bk_showAlertViewWithTitle:@"注意" message:@"您已被退出房间" cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [weakSelf popToScanVC];
        }];
    }
    else if (event == CCSocketEvent_ReciveDrawStateChanged || event == CCSocketEvent_RotateLockedStateChanged)
    {
        [self.streamView reloadData];
    }
    else if (event == CCSocketEvent_RecivePublishError)
    {
        CCUser *user = [noti.userInfo objectForKey:@"user"];
        if (user)
        {
            NSString *message = [NSString stringWithFormat:@"%@ 连麦设备不可用,上麦失败", user.user_name];
            [UIAlertView bk_showAlertViewWithTitle:@"注意" message:message cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
            }];
        }
    }
    /*
     else if (event == CCSocketEvent_Cup)
     {
     [self rewardTeacherCup:value];
     }
     else if (event == CCSocketEvent_Flower)
     {
     [self rewardTeacherFlower:value];
     }
     */
}

//奖励
- (void)rewardTeacherFlower:(id)obj
{
    NSLog(@"rewardTeacherFlower__%@",obj);
    NSDictionary *dicData = obj[@"data"];
    NSString *uid = dicData[@"uid"];
    NSString *uname = dicData[@"uname"];
    __unused NSString *sid = dicData[@"sender"];
    
    CCUser *user = [self getCurrentUser:uid];
    if (!user)
    {
        return;
    }
    CCMemberType mType = [self getRewardType:user];
    NSString *title = [self getRewardTitle:uid user:uname];
    
    [self showRewardView:mType msg:title];
}

- (void)rewardTeacherCup:(id)obj
{
    NSLog(@"rewardTeacherFlower__%@",obj);
    NSDictionary *dicData = obj[@"data"];
    NSString *uid = dicData[@"uid"];
    NSString *uname = dicData[@"uname"];
    __unused NSString *sid = dicData[@"sender"];
    
    CCUser *user = [self getCurrentUser:uid];
    if (!user)
    {
        return;
    }
    CCMemberType mType = [self getRewardType:user];
    NSString *title = [self getRewardTitle:uid user:uname];
    
    [self showRewardView:mType msg:title];
}
//获取当前学员
- (CCUser *)getCurrentUser:(NSString *)uid
{
    NSArray *arrayUser = self.room.room_userList;
    CCUser *userNew = nil;
    for (CCUser *user in arrayUser)
    {
        if ([user.user_id isEqualToString:uid])
        {
            userNew = user;
            break;
        }
    }
    return userNew;
}
//获取配型
- (CCMemberType)getRewardType:(CCUser *)user
{
    CCMemberType mType = CCMemberType_Teacher;
    if (user.user_role == CCRole_Teacher)
    {
        mType = CCMemberType_Teacher;
    }
    else
    {
        mType = CCMemberType_Student;
    }
    return mType;
}
//获取展示标题
- (NSString *)getRewardTitle:(NSString *)uid user:(NSString *)uname
{
    if ([self.room.user_id isEqualToString:uid])
    {
        return @"你";
    }
    else
        return uname;
}

- (void)showRewardView:(CCMemberType)type msg:(NSString *)user
{
    if (!_willTeacherRewardShow)
    {
        return;
    }
    [[CCRewardView shareReward] showRole:type user:user withTarget:self isTeacher:YES];
}

- (void)beconeUnActive
{
    NSLog(@"%s", __func__);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self popToScanVC];
    });
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [CCTool showMessage:@"当前功能暂未开放！"];
        return;
        
        //切换摄像头
        /*
         if ([GetFromUserDefaults(SET_CAMERA_DIRECTION) isEqualToString:@"前置摄像头"])
         {
         [[CCStreamerBasic sharedStreamer] setCameraType:AVCaptureDevicePositionBack];
         SaveToUserDefaults(SET_CAMERA_DIRECTION, @"后置摄像头");
         }
         else
         {
         [[CCStreamerBasic sharedStreamer] setCameraType:AVCaptureDevicePositionFront];
         SaveToUserDefaults(SET_CAMERA_DIRECTION, @"前置摄像头");
         }
         */
    }
    else if(buttonIndex == 1)
    {
        //关闭摄像头
        _cameraChangeBtn.selected = !_cameraChangeBtn.selected;
        [[CCStreamerBasic sharedStreamer] setVideoOpened:NO userID:nil];
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    
}

#pragma mark - 1.2
- (void)showMenu
{
    //    if (!_menu)
    //    {
    _menu = [HyPopMenuView sharedPopMenuManager];
    //文档库
    PopMenuModel* model = [PopMenuModel
                           allocPopMenuModelWithImageNameString:@"document"
                           touchImageNameString:@"document_touch"
                           AtTitleString:@""
                           AtTextColor:[UIColor grayColor]
                           AtTransitionType:PopMenuTransitionTypeCustomizeApi
                           AtTransitionRenderingColor:nil];
    //上传图片
    PopMenuModel* model1 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"photo2"
                            touchImageNameString:@"photo2_touch"
                            AtTitleString:@""
                            AtTextColor:[UIColor grayColor]
                            AtTransitionType:PopMenuTransitionTypeSystemApi
                            AtTransitionRenderingColor:nil];
    //点名
    PopMenuModel* model2 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"roll2"
                            touchImageNameString:@"roll2_touch"
                            AtTitleString:@""
                            AtTextColor:[UIColor grayColor]
                            AtTransitionType:PopMenuTransitionTypeCustomizeApi
                            AtTransitionRenderingColor:nil];
    //布局切换...废弃。。。20190321
    PopMenuModel* model3 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"layout-1"
                            touchImageNameString:@"layout_touch"
                            AtTitleString:@""
                            AtTextColor:[UIColor grayColor]
                            AtTransitionType:PopMenuTransitionTypeSystemApi
                            AtTransitionRenderingColor:nil];
    //设置
    PopMenuModel* model4 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"set-1"
                            touchImageNameString:@"set_touch-1"
                            AtTitleString:@""
                            AtTextColor:[UIColor grayColor]
                            AtTransitionType:PopMenuTransitionTypeCustomizeApi
                            AtTransitionRenderingColor:nil];
    //切麦
    PopMenuModel* model5 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"cherrynor"
                            touchImageNameString:@"cherryact"
                            AtTitleString:@""
                            AtTextColor:[UIColor grayColor]
                            AtTransitionType:PopMenuTransitionTypeCustomizeApi
                            AtTransitionRenderingColor:nil];
    
    CCRoomTemplate template = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_template;
    //布局切换
    
    if (template == CCRoomTemplateSpeak)
    {
        _menu.dataSource = @[ model, model1, model2, model4,model5];
    }
    else
    {
        _menu.dataSource = @[ model2, model4,model5];
    }
    /*2019年09月24日15:12:17
     //不包含切麦功能
     if (template == CCRoomTemplateSpeak)
     {
     _menu.dataSource = @[ model, model1, model2, model4];
     }
     else
     {
     _menu.dataSource = @[ model2, model4];
     }
     */
    _menu.delegate = self;
    _menu.popMenuSpeed = 12.0f;
    _menu.automaticIdentificationColor = false;
    _menu.animationType = HyPopMenuViewAnimationTypeCenter;
    //    }
    
    _menu.backgroundType = HyPopMenuViewBackgroundTypeDarkBlur;
    _menu.column = self.isLandSpace ? 3 : 2;
    [_menu openMenu];
}

#pragma mark - menu
- (void)popMenuView:(HyPopMenuView*)popMenuView didSelectItemAtIndex:(NSUInteger)index
{
    NSLog(@"%s__%lu", __func__, (unsigned long)index);
    CCRoomTemplate template = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_template;
    if (template != CCRoomTemplateSpeak)
    {
        index += 2;
    }
    switch (index) {
        case CCSetType_Documents:
        {
            [self set_documents];
        }
            break;
        case CCSetType_UploadImage:
        {
            [self set_uploadImage];
        }
            break;
        case CCSetType_CallName:
        {
            [self set_callName];
        }
            break;
        case CCSetType_Set:
        {
            [self set_set];
        }
            break;
        case CCSetType_CherryMic:
        {
            [self set_cherry];
        }
            break;
        case CCSetType_LayOut:
        {
            [self set_cherry];
        }
            break;
        default:
            break;
    }
}

- (void)set_documents
{
    //文档库
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    CCDocListViewController *settingVC = [story instantiateViewControllerWithIdentifier:@"DocList"];
    [self.navigationController pushViewController:settingVC animated:YES];
}
- (void)set_uploadImage
{
    if (!self.uploadFile)
    {
        self.uploadFile = [CCUploadFile new];
        self.uploadFile.isLandSpace = self.isLandSpace;
    }
    WS(ws);
    [self.uploadFile uploadImage:self.navigationController roomID:self.roomID completion:^(BOOL result) {
        ws.uploadFile = nil;
        NSLog(@"%s", __func__);
        if (!result)
        {
            [UIAlertView bk_showAlertViewWithTitle:@"" message:@"正在上传图片，请稍候操作" cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
            }];
        }
    }];
}
- (void)set_callName
{
    //点名
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    if ([[CCSignManger sharedInstance] isSignIng])
    {
        CCSignResultViewController *vc = [story instantiateViewControllerWithIdentifier:@"SignResult"];
        vc.isLandSpace = self.isLandSpace;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        CCSignViewController *settingVC = [story instantiateViewControllerWithIdentifier:@"SignIn"];
        settingVC.isLandSpace = self.isLandSpace;
        [self.navigationController pushViewController:settingVC animated:YES];
    }
}
- (void)set_set
{
    //设置
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    CCLiveSettingViewController *settingVC = [story instantiateViewControllerWithIdentifier:@"live_setting"];
    [self.navigationController pushViewController:settingVC animated:YES];
}
- (void)set_cherry
{
    //切麦
    [self cherryEventClicked];
}
- (void)set_layout
{
    //布局切换
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    CCTemplateViewController *settingVC = [story instantiateViewControllerWithIdentifier:@"Template"];
    settingVC.isLandSpace = self.isLandSpace;
    [self.navigationController pushViewController:settingVC animated:YES];
}

#pragma mark - send Pic
- (void)selectImage
{
    __block CCPhotoNotPermissionVC *_photoNotPermissionVC;
    WS(ws)
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch(status) {
        case PHAuthorizationStatusNotDetermined: {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if(status == PHAuthorizationStatusAuthorized) {
                    [ws pickImage];
                } else if(status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
                    _photoNotPermissionVC = [CCPhotoNotPermissionVC new];
                    [self.navigationController pushViewController:_photoNotPermissionVC animated:NO];
                }
            }];
        }
            break;
        case PHAuthorizationStatusAuthorized: {
            [ws pickImage];
        }
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied: {
            NSLog(@"4");
            _photoNotPermissionVC = [CCPhotoNotPermissionVC new];
            [self.navigationController pushViewController:_photoNotPermissionVC animated:NO];
        }
            break;
        default:
            break;
    }
}

-(void)pickImage {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self pickImageOnMainThread];
    });
}
-(void)pickImageOnMainThread {
#ifndef USELOCALPHOTOLIBARY
    [self pushImagePickerController];
#else
    if([self isPhotoLibraryAvailable]) {
        _picker = [[UIImagePickerController alloc]init];
        _picker.view.backgroundColor = [UIColor clearColor];
        UIImagePickerControllerSourceType sourcheType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        _picker.sourceType = sourcheType;
        _picker.delegate = self;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf presentViewController:_picker animated:YES completion:nil];
        });
    }
#endif
}

//支持相片库
- (BOOL)isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image= [info objectForKey:UIImagePickerControllerOriginalImage];
    WS(ws)
    [_picker dismissViewControllerAnimated:YES completion:^{
        //发送图片
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.ccChatManager sendImage:image completion:^(BOOL result, NSError *error, id info) {
                
            }];
        });
        ws.picker = nil;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    WS(ws)
    [_picker dismissViewControllerAnimated:YES completion:^{
        ws.picker = nil;
    }];
}

- (NSString *)randomName:(int)len
{
    return [NSString stringWithFormat:@"%f.jpg", [[NSDate date] timeIntervalSince1970]];
}

+ (NSData *)zipImageWithImage:(UIImage *)image
{
    if (!image) {
        return nil;
    }
    CGFloat maxFileSize = 32*1024;
    CGFloat compression = 0.9f;
    NSData *compressedData = UIImageJPEGRepresentation(image, compression);
    while ([compressedData length] > maxFileSize) {
        compression *= 0.9;
        compressedData = UIImageJPEGRepresentation([[self class] compressImage:image newWidth:image.size.width*compression], compression);
    }
    return compressedData;
}

+ (UIImage *)compressImage:(UIImage *)image newWidth:(CGFloat)newImageWidth
{
    if (!image) return nil;
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    float width = newImageWidth;
    float height = image.size.height/(image.size.width/width);
    
    float widthScale = imageWidth /width;
    float heightScale = imageHeight /height;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    if (widthScale > heightScale) {
        [image drawInRect:CGRectMake(0, 0, imageWidth /heightScale , height)];
    }
    else {
        [image drawInRect:CGRectMake(0, 0, width , imageHeight /widthScale)];
    }
    
    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

#pragma mark - tz
- (void)pushImagePickerController {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.sortAscendingByModificationDate = YES;
    imagePickerVc.allowEdited = NO;
    WS(ws);
    __weak typeof(TZImagePickerController *) weakPicker = imagePickerVc;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        [weakPicker dismissViewControllerAnimated:YES completion:^{
            if (photos.count > 0)
            {
                //发送图片
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [self.ccChatManager sendImage:[photos lastObject] completion:^(BOOL result, NSError *error, id info) {
                        
                    }];
                });
            }
        }];
    }];
    [imagePickerVc setImagePickerControllerDidCancelHandle:^{

    }];
    imagePickerVc.modalPresentationStyle = 0;
    [self.navigationController presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - action view
#define ACTIONVIEWH 120
#define ACTIONVIEWTAG 2001
- (void)receiveClickNoti:(NSNotification *)noti
{
    NSString *type = [noti.userInfo objectForKey:@"type"];
    NSString *userID = [noti.userInfo objectForKey:@"userID"];
    self.movieClickIndexPath = [noti.userInfo objectForKey:@"indexPath"];
    
    for (CCUser *user in [CCStreamerBasic sharedStreamer].getRoomInfo.room_userList)
    {
        if ([user.user_id isEqualToString:userID])
        {
            self.movieClickUser = user;
            [self showActionView:user type:type];
        }
    }
}
#pragma mark -- 用户点击视频框，显示响应事件
- (NSMutableArray *)arrayMovieClickedOPData:(CCUser *)user type:(NSString *)type
{   //以后这里要优化
    NSMutableArray *data = [NSMutableArray array];
    if (user.user_videoState)
    {
        [data addObject:@{@"image":@"action_closecamera", @"text":@"关闭视频", @"type":@(0)}];
    }
    else
    {
        [data addObject:@{@"image":@"action_opencamera", @"text":@"开放视频", @"type":@(1)}];
    }
    if (user.user_audioState)
    {
        [data addObject:@{@"image":@"action_closemicrophone", @"text":@"关麦", @"type":@(2)}];
    }
    else
    {
        [data addObject:@{@"image":@"action_openmicrophone", @"text":@"开麦", @"type":@(3)}];
    }
    //如果是助教，则只有：麦克风、摄像头、踢下麦
    if (user.user_role == CCRole_Assistant || user.user_role == CCRole_Teacher)
    {
        return data;
    }
    //    if (user.rotateLocked)
    //    {
    //        [data addObject:@{@"image":@"action_lock", @"text":@"不轮播", @"type":@(4)}];
    //    }
    //    else
    //    {
    //        [data addObject:@{@"image":@"action_unlock", @"text":@"参与轮播", @"type":@(5)}];
    //    }
    if (user.user_drawState)
    {
        [data addObject:@{@"image":@"action_penciloff", @"text":@"取消授权", @"type":@(6)}];
    }
    else
    {
        [data addObject:@{@"image":@"action_pencil", @"text":@"授权标注", @"type":@(7)}];
    }
    if ([type isEqualToString:NSStringFromClass([CCStreamModeSpeak class])])
    {
        [data addObject:@{@"image":@"action_fullscreen2", @"text":@"全屏视频", @"type":@(8)}];
    }
    else if ([type isEqualToString:NSStringFromClass([CCStreamerModeTile class])])
    {
        
    }
    else if ([type isEqualToString:NSStringFromClass([CCStreamModeSingle class])])
    {
        if (self.movieClickIndexPath)
        {
            [data addObject:@{@"image":@"action_fullscreen2", @"text":@"主视频", @"type":@(9)}];
        }
    }
    [data addObject:@{@"image":@"action_shotoff", @"text":@"踢下麦", @"type":@(10)}];
    if (user.user_AssistantState)
    {
        [data addObject:@{@"image":@"action_teacheroff", @"text":@"撤销讲师", @"type":@(11)}];
    }
    else
    {
        [data addObject:@{@"image":@"action_teacher", @"text":@"设为讲师", @"type":@(12)}];
    }
    [data addObject:@{@"image":@"cup_pink", @"text":@"奖励奖杯", @"type":@(13)}];
    
    return data;
}

- (void)showActionView:(CCUser *)user type:(NSString *)type
{
    NSMutableArray *data = [self arrayMovieClickedOPData:user type:type];
    self.actionData = [NSArray arrayWithArray:data];
    
    UIView *backView = [self.view viewWithTag:ACTIONVIEWTAG];
    if (backView)
    {
        [backView removeFromSuperview];
    }
    backView = [UIView new];
    backView.tag = ACTIONVIEWTAG;
    [self.view addSubview:backView];
    __weak typeof(self) weakSelf = self;
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.view).offset(0.f);
    }];
    
    UIView *view = [UIView new];
    view.backgroundColor= [UIColor whiteColor];
    
    UICollectionView *collectionView;
    collectionView = ({
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(KEY_ITEM_WIDTH, ACTIONVIEWH);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 15.f;
        
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,ACTIONVIEWH) collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.scrollsToTop = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.backgroundColor = CCRGBColor(241, 241, 241);
        [collectionView registerClass:[CCActionCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        collectionView.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
        collectionView;
    });
    [view addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view).offset(0.f);
        make.right.mas_equalTo(view).offset(0.f);
        make.top.mas_equalTo(view).offset(0.f);
        make.height.mas_equalTo(ACTIONVIEWH);
    }];
    
    UIButton *cancleBtn = [UIButton new];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn addTarget:self action:@selector(hideActionView:) forControlEvents:UIControlEventTouchUpInside];
    cancleBtn.titleLabel.font = [UIFont systemFontOfSize:FontSizeClass_16];
    [cancleBtn setTitleColor: CCRGBColor(95, 95, 95) forState:UIControlStateNormal];
    [view addSubview:cancleBtn];
    
    [cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(view).offset(0.f);
        make.bottom.mas_equalTo(view).offset(-10.f);
        make.top.mas_equalTo(collectionView.mas_bottom).offset(10.f);
        make.left.mas_equalTo(view).offset(30.f);
        make.right.mas_equalTo(view).offset(-30.f);
    }];
    
    [backView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(weakSelf.view).offset(0.f);
        //        make.height.mas_equalTo(130.f);
    }];
    
    UIView *topView = [UIView new];
    [backView addSubview:topView];
    topView.backgroundColor = CCRGBAColor(0, 0, 0, 0.5);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideActionView:)];
    [backView addGestureRecognizer:tap];
    [topView addGestureRecognizer:tap];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.top.mas_equalTo(backView);
        make.bottom.mas_equalTo(view.mas_top).offset(0.f);
    }];
}

- (void)hideActionView:(UIButton *)btn
{
    UIView *view = [self.view viewWithTag:ACTIONVIEWTAG];
    [view removeFromSuperview];
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.actionData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CCActionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *info = self.actionData[indexPath.item];
    NSString *imageName = [info objectForKey:@"image"];
    NSString *text = [info objectForKey:@"text"];
    [cell loadWith:imageName text:text];
    //    cell.userInteractionEnabled = NO;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(KEY_ITEM_WIDTH, ACTIONVIEWH);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger type = [[self.actionData[indexPath.item] objectForKey:@"type"] integerValue];
    switch (type) {
        case 0://关闭视频
        {
            //            [self.stremer  setVideoOpened:NO userID:self.movieClickUser.user_id];
            //设置流视频状态
            
            [self.stremer changeStream:[self.stremer getStreamWithStreamID:self.movieClickUser.user_id] videoState:NO completion:^(BOOL result, NSError *error, id info) {
                if (result) {
                    NSLog(@"~~~~~~~~~~~~~~关闭视频成功：%@",info);
                }else{
                    NSLog(@"~~~~~~~~~~~~~~关闭视频失败：%@",info);
                }
            }];
            
        }
            break;
        case 1://开启视频
        {
            //            [self.stremer  setVideoOpened:YES userID:self.movieClickUser.user_id];
            [self.stremer changeStream:[self.stremer getStreamWithStreamID:self.movieClickUser.user_id] videoState:YES completion:^(BOOL result, NSError *error, id info) {
                if (result) {
                    NSLog(@"~~~~~~~~~~~~~~开启视频成功：%@",info);
                }else{
                    NSLog(@"~~~~~~~~~~~~~~开启视频失败：%@",info);
                }
            }];
        }
            break;
        case 2:
        {
            //关麦
            //            [self.stremer  setAudioOpened:NO userID:self.movieClickUser.user_id];
            [self.stremer changeStream:[self.stremer getStreamWithStreamID:self.movieClickUser.user_id] audioState:NO completion:^(BOOL result, NSError *error, id info) {
                if (result) {
                    NSLog(@"~~~~~~~~~~~~~~关麦成功：%@",info);
                }else{
                    NSLog(@"~~~~~~~~~~~~~~关麦失败：%@",info);
                }
                
            }];
            
        }
            break;
        case 3:
        {
            //开麦
            //            [self.stremer  setAudioOpened:YES userID:self.movieClickUser.user_id];
            [self.stremer changeStream:[self.stremer getStreamWithStreamID:self.movieClickUser.user_id] audioState:YES completion:^(BOOL result, NSError *error, id info) {
                if(result){
                    NSLog(@"~~~~~~~~~~~~~~开麦成功：%@",info);
                }else{
                    NSLog(@"~~~~~~~~~~~~~~开麦失败：%@",info);
                    
                }
            }];
        }
            break;
        case 4:
        {
            //轮播模式解锁用户
            [self.ccBarelyManager rotateUnLockUser:self.movieClickUser.user_id completion:^(BOOL result, NSError *error, id info) {
            }];
        }
            break;
        case 5:
        {
            //轮播模式锁定用户
            [self.ccBarelyManager  rotateLockUser:self.movieClickUser.user_id completion:^(BOOL result, NSError *error, id info) {
            }];
            
        }
            break;
        case 6:
        {
            //取消对某个学生的标注功能
            //            [self.stremer  cancleAuthUserDraw:self.movieClickUser.user_id];
            [self.ccVideoView cancleAuthUserDraw:self.movieClickUser.user_id];
        }
            break;
        case 7:
        {
            //            [self.stremer  authUserDraw:self.movieClickUser.user_id];
            [self.ccVideoView authUserDraw:self.movieClickUser.user_id];
        }
            break;
        case 8:
        {
            [self.streamView showMovieBig:self.movieClickIndexPath];
        }
            break;
        case 9:
        {
            [self.streamView changeTogBig:self.movieClickIndexPath];
        }
            break;
        case 10:
        {
            if (self.movieClickUser.user_status == CCUserMicStatus_Connected || self.movieClickUser.user_status == CCUserMicStatus_Connecting)
            {
                [[CCBarleyManager sharedBarley] kickUserFromSpeak:self.movieClickUser.user_id completion:^(BOOL result, NSError *error, id info) {
                    if (result)
                    {
                        NSLog(@"kickUser success");
                    }
                    else
                    {
                        NSLog(@"kickUser Fail:%@", error);
                    }
                }];
            }
            else
            {
                //学生已不在麦上
                UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"" message:@"学生已经下麦" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                [view show];
            }
        }
            break;
        case 11:
        {
            //            [[CCStreamerBasic sharedStreamer] cancleAuthUserAssistant:self.movieClickUser.user_id];
            [self.ccVideoView cancleAuthUserAsTeacher:self.movieClickUser.user_id];
        }
            break;
        case 12:
        {
            //对某个学生设为讲师
            //            [[CCStreamerBasic sharedStreamer] authUserAssistant:self.movieClickUser.user_id];
            [[self hdsDocView] authUserAsTeacher:self.movieClickUser.user_id];
        }
            break;
        case 13:
        {
            [self rewordCup];
        }
            break;
        default:
            break;
    }
    [self hideActionView:nil];
}
- (void)rewordCup
{
    //发送奖杯
    NSString *uid = self.movieClickUser.user_id;
    NSString *uname = self.movieClickUser.user_name;
    NSString *typeF = @"cup";
    NSString *sid = [[CCStreamerBasic sharedStreamer]getRoomInfo].user_id;
    //    [[CCStreamerBasic sharedStreamer]rewardUid:uid uName:uname type:typeF sender:sid];
}

- (void)drawBtnClicked:(UIButton *)btn
{
    
}

- (void)frontBtnClicked:(UIButton *)btn
{
    //撤销
    //    [[CCDocManager sharedManager] revokeDrawData];
}

- (void)cleanBtnClicked:(UIButton *)btn
{
    //    [[CCDocManager sharedManager] cleanDrawData];
}

- (void)pageFrontBtnClicked:(UIButton *)btn
{
    [self.streamView clickFront:nil];
    NSString *textPN = [NSString stringWithFormat:@"%@ / %@", @(self.streamView.steamSpeak.nowDocpage+1), @(self.streamView.steamSpeak.nowDoc.pageSize)];
    self.drawMenuView.pageLabel.text = textPN;
}

- (void)pageBackBtnClicked:(UIButton *)btn
{
    [self.streamView clickBack:nil];
    NSString *textPN = [NSString stringWithFormat:@"%@ / %@", @(self.streamView.steamSpeak.nowDocpage+1), @(self.streamView.steamSpeak.nowDoc.pageSize)];
    self.drawMenuView.pageLabel.text = textPN;
}

- (void)menuBtnClicked:(UIButton *)btn
{
    //显示操作栏
    [self.streamView hideOrShowView:YES];
}

- (void)docPageChange
{
    NSString *textPN = [NSString stringWithFormat:@"%@ / %@", @(self.streamView.steamSpeak.nowDocpage+1), @(self.streamView.steamSpeak.nowDoc.pageSize)];
    CCLog(@"PN______:< %@ >__%s____< %d >___",textPN,__func__,__LINE__);
    
    self.drawMenuView.pageLabel.text = textPN;
}

#pragma 加载白板，数据获取成功后通知。
- (void)receiveDocChange:(NSNotification *)noti
{
    CCDoc *nowDoc = noti.userInfo[@"value"];
    //打印书数据，是否能够出来
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~docID:%@~~~name:%@",nowDoc.docID,nowDoc.docName);
    if (nowDoc)
    {
        BOOL oldState = self.drawMenuView.hidden;
        NSInteger nowDocpage = [noti.userInfo[@"page"] integerValue];
        NSInteger size = nowDoc.pageSize;
        [self.drawMenuView removeFromSuperview];
        self.drawMenuView = nil;
        BOOL showPageChange = size > 1 ? YES : NO;
        [self drawMenuView1:showPageChange];
        
        NSString *textPN = [NSString stringWithFormat:@"%@ / %@", @(nowDocpage+1), @(size)];
        
        self.drawMenuView.pageLabel.text = textPN;
        self.drawMenuView.hidden = oldState;
    }
}

- (void)receiveCurrentShowDocDel:(NSNotification *)noti
{
    //删除正在显示的文档，会切换为白板，这个时候变更文档操作栏
    BOOL oldState = self.drawMenuView.hidden;
    [self.drawMenuView removeFromSuperview];
    self.drawMenuView = nil;
    [self drawMenuView1:NO];
    self.drawMenuView.hidden = oldState;
    
}


- (void)popToScanVC
{
    [self removeObserver];
    if ([_menu isOpenMenu])
    {
        [_menu closeMenu];
    }
    if (self.navigationController.topViewController == self.navigationController.visibleViewController)
    {
        //是push的
        for (UIViewController *vc in self.navigationController.viewControllers)
        {
            if ([vc isKindOfClass:[CCLoginViewController class]])
            {
                if (self.isLandSpace)
                {
                    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    appdelegate.shouldNeedLandscape = NO;
                    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
                    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
                }
                [self.navigationController popToViewController:vc animated:YES];
            }
        }
    }
    else
    {
        [self.navigationController dismissViewControllerAnimated:NO completion:^{
            for (UIViewController *vc in self.navigationController.viewControllers)
            {
                if ([vc isKindOfClass:[CCLoginViewController class]])
                {
                    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    appdelegate.shouldNeedLandscape = NO;
                    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
                    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
                    [self.navigationController popToViewController:vc animated:YES];
                }
            }
        }];
    }
}

- (void)rotati
{
}

//调整鲜花奖杯，聊天视图层次
- (void)changeKeyboardViewUp
{
    [self.view bringSubviewToFront:self.contentView];
}

- (void)stopPublish
{
    WS(weakSelf);
    [[CCStreamerBasic sharedStreamer] stopLive:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                //调整UI
                weakSelf.cameraChangeBtn.hidden = YES;
                weakSelf.stopPublishBtn.hidden = YES;
                weakSelf.micChangeBtn.hidden = YES;
                weakSelf.startPublishBtn.hidden = NO;
                weakSelf.cameraChangeBtn.selected = NO;
                weakSelf.micChangeBtn.selected = NO;
                weakSelf.fllowBtn.selected = NO;
                [weakSelf.loadingView removeFromSuperview];
            });
        }
    }];
}

#pragma mark -- reset publish ui
- (void)publishIsLivingResetUI:(BOOL)isLive
{
    //调整UI
    if (isLive)
    {
        self.cameraChangeBtn.hidden = NO;
        self.stopPublishBtn.hidden = NO;
        self.micChangeBtn.hidden = NO;
        self.startPublishBtn.hidden = YES;
        self.cameraChangeBtn.selected = NO;
        self.micChangeBtn.selected = NO;
        self.fllowBtn.selected = NO;
    }
    else
    {
        self.cameraChangeBtn.hidden = YES;
        self.stopPublishBtn.hidden = YES;
        self.micChangeBtn.hidden = YES;
        self.startPublishBtn.hidden = NO;
        self.cameraChangeBtn.selected = NO;
        self.micChangeBtn.selected = NO;
        self.fllowBtn.selected = NO;
    }
}

#pragma mark -- 助教下麦
- (void)assistantStopPublish
{
    WS(weakSelf);
    [[CCStreamerBasic sharedStreamer]unPublish:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            [self.ccBarelyManager assistDM:nil completion:^(BOOL result, NSError *error, id info) {
                
            }];
            [CCTool showMessage:@"您已下麦！"];
        }
    }];
}

#pragma mark
#pragma mark -- 切麦function
//有切麦按钮肯定有助教角色 -- 有助教
- (void)cherryEventClicked
{
    CCRoom *room = [[CCStreamerBasic sharedStreamer]getRoomInfo];
    if (room.live_status == CCLiveStatus_Stop)
    {
        [UIAlertView bk_showAlertViewWithTitle:nil message:@"直播未开始，不能使用切麦按钮。" cancelButtonTitle:nil otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
        return;
    }
    CCUser *userTeacher = [CCTool tool_room_user_role:CCRole_Teacher];
    if (!userTeacher)
    {
        [UIAlertView bk_showAlertViewWithTitle:nil message:@"房间无老师，不能使用切麦按钮。" cancelButtonTitle:nil otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
        return;
    }
    NSLog(@"buttonRecordClicked_________________");
    [UIAlertView bk_showAlertViewWithTitle:nil message:@"是否进行切麦？" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1)
        {
            [self cherryOn];
        }
    }];
}
//开始切麦
- (void)cherryOn
{
    CCUser *userTeacher = [CCTool tool_room_user_role:CCRole_Teacher];
    if (userTeacher)
    {
        [self room_has_teacher];
    }
    else
    {
        [self room_has_teacher_not];
    }
}
#pragma mark -- 房间是否有讲师
- (void)room_has_teacher
{
    CCRoom *room = [[CCStreamerBasic sharedStreamer]getRoomInfo];
    NSString *uid = room.user_id;
    CCUser *userCopy = [CCTool tool_room_user_userid:uid];
    if (userCopy.user_status == CCUserMicStatus_Connected)
    {
        //助教在麦 -- 助教下麦，通知老师上麦
        [self copy_down__teacher_up];
    }
    else if (userCopy.user_status == CCUserMicStatus_None)
    {
        //助教不在麦 -- 助教上麦，通知老师下麦
        [self copy_up_teacher_down];
    }
}
//房间没有老师
- (void)room_has_teacher_not
{
    CCRoom *room = [[CCStreamerBasic sharedStreamer]getRoomInfo];
    NSString *uid = room.user_id;
    CCUser *userLocal = [CCTool tool_room_user_userid:uid];
    //判断自己是否在麦上
    if (userLocal.user_status == CCUserMicStatus_Connected)
    {
        //助教在麦上
        return;
    }
    //助教上麦
    [self teacherCopyPublish];
}
//助教下麦，老师上麦
- (void)copy_down__teacher_up
{
    [[CCStreamerBasic sharedStreamer]unPublish:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            [CCTool showMessage:@"下麦成功！"];
        }
        [self.ccBarelyManager assistDM:nil completion:^(BOOL result, NSError *error, id info) {
            if (!result)
            {
                NSString *errMsg = [CCTool toolErrorMessage:error];
                [UIAlertView bk_showAlertViewWithTitle:nil message:errMsg cancelButtonTitle:@"取消" otherButtonTitles:@[@"重试"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    NSLog(@"———buttonIndex————%ld",(long)buttonIndex);
                    if (buttonIndex == 1)
                    {
                        [self copy_down__teacher_up];
                    }
                }];
            }
            [self callTeacherLM];
        }];
    }];
}
//通知老师上麦
- (void)callTeacherLM
{
    CCUser *userTeacher = [CCTool tool_room_user_role:CCRole_Teacher];
    [self.ccBarelyManager rolePreLM:userTeacher completion:^(BOOL result, NSError *error, id info) {
        if (!result)
        {
            NSString *errMsg = [CCTool toolErrorMessage:error];
            [UIAlertView bk_showAlertViewWithTitle:nil message:errMsg cancelButtonTitle:@"取消" otherButtonTitles:@[@"重试"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                NSLog(@"———buttonIndex————%ld",(long)buttonIndex);
                if (buttonIndex == 1)
                {
                    [self callTeacherLM];
                }
            }];
        }
    }];
}
// 助教上麦，通知老师下麦
- (void)copy_up_teacher_down
{
    CCUser *userCopy = [CCTool tool_room_user_role:CCRole_Assistant];
    CCUser *userTeacher = [CCTool tool_room_user_role:CCRole_Teacher];
    //通知讲师下麦
    [self.ccBarelyManager presentDM:userTeacher byUser:userCopy.user_id completion:^(BOOL result, NSError *error, id info) {
        if (!result)
        {
            NSString *errMsg = [CCTool toolErrorMessage:error];
            [UIAlertView bk_showAlertViewWithTitle:nil message:errMsg cancelButtonTitle:@"取消" otherButtonTitles:@[@"确认"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                NSLog(@"———buttonIndex————%ld",(long)buttonIndex);
                if (buttonIndex == 1)
                {
                    [self copy_up_teacher_down];
                }
            }];
            return ;
        }
        //助教上麦
        [self teacherCopyPublish];
    }];
}
#pragma mark -- 上麦
- (void)teacherCopyPublish
{
    //直接调用publish
    WS(weakSelf);
    ///开启直播
    [self.stremer startLive:^(BOOL result, NSError *error, id info) {
        if (result) {
            ///开始推流
            [[CCStreamerBasic sharedStreamer] publish:^(BOOL result, NSError *error, id info) {
                if (result)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ///更新麦序
                        
                        [weakSelf teacherCopyUpdateMicStatus:result];
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                    });
                    NSLog(@"publish error:%@", error);
                    [CCTool showMessage:@"切麦失败，请重试！"];
                }
                [weakSelf.loadingView removeFromSuperview];
            }];
        }
    }];
    
    
}

- (void)teacherCopyUpdateMicStatus:(BOOL)published
{
    WS(weakSelf);
    [self.ccBarelyManager assistLM:published completion:^(BOOL result, NSError *error, id info) {
        if (!result)
        {
            [UIAlertView bk_showAlertViewWithTitle:nil message:@"更新麦序异常！" cancelButtonTitle:@"取消" otherButtonTitles:@[@"重试"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1)
                {
                    [self teacherCopyUpdateMicStatus:published];
                }
            }];
        }
    }];
}

#pragma mark -- 助教下麦
- (void)teacherCopyUnpublish
{
    [[CCStreamerBasic sharedStreamer] unPublish:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            [CCTool showMessage:@"下麦成功！"];
        }
        [self.ccBarelyManager assistDM:nil completion:^(BOOL result, NSError *error, id info) {
            
        }];
    }];
}

#pragma mark--黑流检测重新推流 拉流
- (void)rePublishBlackFlow {
    [[CCStreamerBasic sharedStreamer]unPublish:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            [self teacherCopyPublish];
        }
    }];
}

- (void)reSub:(NSNotification *)noti
{
    NSDictionary *info = noti.userInfo;
    NSLog(@"%s__%d__%@", __func__, __LINE__, info);
    NSString *streamID = [info objectForKey:@"stream"];
    CCRole role = (CCRole)[[info objectForKey:@"role"] integerValue];
    __weak typeof(self) weakSelf = self;
    [[CCStreamerBasic sharedStreamer] unsubscribeWithStream:[[CCStreamerBasic sharedStreamer] getStreamWithStreamID:streamID] completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSLog(@"unsubcribe stream success %@",streamID);
            
        }
        else
        {
            NSLog(@"unsubcribe stream fail:%@", error);
        }
        
        if (weakSelf.shareScreen.stream.type == CCStreamType_ShareScreen)
        {
            [weakSelf removeShareScreenView];
        } else if (weakSelf.shareScreen.stream.type == CCStreamType_AssistantCamera)
        {
            
            [weakSelf removeAssistantCameraView];
        }
        NSLog(@"%s__%d__%@", __func__, __LINE__, info);
        [[CCStreamerBasic sharedStreamer] subcribeWithStream:[[CCStreamerBasic sharedStreamer] getStreamWithStreamID:streamID] completion:^(BOOL result, NSError *error, id info) {
            NSLog(@"%s__%d__%@", __func__, __LINE__, info);
            if (result)
            {
                NSLog(@"%s__%@", __func__, info);
                CCStreamView *view = info;
                
                if(view.stream.type == CCStreamType_ShareScreen)
                {
                    [weakSelf showShareScreenView:view];
                }
                else
                {
                    [weakSelf.streamView showStreamView:view];
                }
            }
            //房子断流后重新连接不监听
            [self listenStreamBlack];
        }];
    }];
}

///辅助摄像头
- (void)showAuxiliaryCameraView:(CCStreamView *)view
{
    self.assistantCamera = view;
    self.assistantCameraView = [[CCDragView alloc] init];
    self.assistantCameraView.frame = CGRectMake(0, 0, 160, 120);
    self.assistantCameraView.backgroundColor = [UIColor blackColor];
    [self.assistantCameraView addSubview:view];
    [view addObserver:self forKeyPath:@"videoViewSize_ass" options:NSKeyValueObservingOptionNew context:nil];
    __weak typeof(self) weakSelf = self;
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.assistantCameraView);
    }];
    
    self.assistantCameraViewGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAssistant:)];
    self.assistantCameraViewGes.numberOfTapsRequired = 2;
    [self.assistantCameraView addGestureRecognizer:self.assistantCameraViewGes];
    
    [self.view addSubview:self.assistantCameraView];
}

- (void)tap:(UITapGestureRecognizer *)ges
{
    self.shareScreenViewOldFrame = self.shareScreenView.frame;
    self.shareScreenView.frame = [UIScreen mainScreen].bounds;
    
    self.shareScreenView.dragEnable = NO;
    self.shareScreenViewGes.enabled = NO;
    
    [self.shareScreenView removeFromSuperview];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.shareScreenView];
    
    self.windowFullScreenBtn = [UIButton new];
    [self.windowFullScreenBtn setTitle:@"" forState:UIControlStateNormal];
    [self.windowFullScreenBtn setImage:[UIImage imageNamed:@"exitfullscreen"] forState:UIControlStateNormal];
    [self.windowFullScreenBtn setImage:[UIImage imageNamed:@"exitfullscreen_touch"] forState:UIControlStateSelected];
    [self.windowFullScreenBtn addTarget:self action:@selector(clickSmall:) forControlEvents:UIControlEventTouchUpInside];
    [self.shareScreenView addSubview:self.windowFullScreenBtn];
    __weak typeof(self) weakSelf = self;
    [self.windowFullScreenBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.shareScreenView.mas_right).offset(-10.f);
        make.bottom.mas_equalTo(weakSelf.shareScreenView.mas_bottom).offset(-10.f);
    }];
}
- (void)tapAssistant:(UITapGestureRecognizer *)ges
{
    self.assistantCameraOldFrame = self.assistantCameraView.frame;
    self.assistantCameraView.frame = [UIScreen mainScreen].bounds;
    
    self.assistantCameraView.dragEnable = NO;
    self.assistantCameraViewGes.enabled = NO;
    
    [self.assistantCameraView removeFromSuperview];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.assistantCameraView];
    
    self.windowFullScreenBtnAss = [UIButton new];
    [self.windowFullScreenBtnAss setTitle:@"" forState:UIControlStateNormal];
    [self.windowFullScreenBtnAss setImage:[UIImage imageNamed:@"exitfullscreen"] forState:UIControlStateNormal];
    [self.windowFullScreenBtnAss setImage:[UIImage imageNamed:@"exitfullscreen_touch"] forState:UIControlStateSelected];
    [self.windowFullScreenBtnAss addTarget:self action:@selector(clickSmallAssistantCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.assistantCameraView addSubview:self.windowFullScreenBtnAss];
    __weak typeof(self) weakSelf = self;
    [self.windowFullScreenBtnAss mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.assistantCameraView.mas_right).offset(-10.f);
        make.bottom.mas_equalTo(weakSelf.assistantCameraView.mas_bottom).offset(-10.f);
    }];
}

- (void)clickSmall:(UIButton *)btn
{
    [btn removeFromSuperview];
    [self.shareScreenView removeFromSuperview];
    [self.view addSubview:self.shareScreenView];
    self.shareScreenView.frame = self.shareScreenViewOldFrame;
    self.shareScreenView.dragEnable = YES;
    self.shareScreenViewGes.enabled = YES;
}

- (void)clickSmallAssistantCamera:(UIButton *)btn
{
    [btn removeFromSuperview];
    [self.assistantCameraView removeFromSuperview];
    [self.view addSubview:self.assistantCameraView];
    self.assistantCameraView.frame = self.shareScreenViewOldFrame;
    self.assistantCameraView.dragEnable = YES;
    self.assistantCameraViewGes.enabled = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"videoViewSize"])
    {
        NSValue *value = change[@"new"];
        CGSize newSize = [value CGSizeValue];
        if (newSize.width != 0 && newSize.height != 0)
        {
            CGFloat height = newSize.height/newSize.width * self.shareScreenView.frame.size.width;
            CGRect newFrame = CGRectMake(self.view.frame.size.width - self.shareScreenView.frame.size.width - 10, 80, self.shareScreenView.frame.size.width, height);
            self.shareScreenView.frame = newFrame;
        }
    }else if ([keyPath isEqualToString:@"videoViewSize_ass"]) {
        NSValue *value = change[@"new"];
        CGSize newSize = [value CGSizeValue];
        if (newSize.width != 0 && newSize.height != 0)
        {
            CGFloat height = newSize.height/newSize.width * self.assistantCameraView.frame.size.width;
            CGRect newFrame = CGRectMake(self.view.frame.size.width - self.assistantCameraView.frame.size.width - 10, 80, self.assistantCameraView.frame.size.width, height);
            self.assistantCameraView.frame = newFrame;
        }
    }
}

#pragma mark 拉流的代理
- (void)SDKNeedsubStream:(NSNotification *)notify
{
    NSDictionary *dicInfo = notify.userInfo;
    CCStream *stream = dicInfo[@"stream"];
    
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self autoSub:stream];
    });
}

- (void)SDKNeedUnsubStream:(NSNotification *)notify
{
    NSDictionary *dicInfo = notify.userInfo;
    CCStream *stream = dicInfo[@"stream"];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [self autoUnSub:stream];
    });
}

- (void)onStreamError:(NSError *)error forStream:(CCStream *)stream
{
    NSLog(@"%s__%d__%@__%@", __func__, __LINE__, error, stream.streamID);
    [CCTool showMessageError:error];
}


- (void)autoSub:(CCStream *)stream
{
    [self.stremer subcribeWithStream:stream completion:^(BOOL result, NSError *error, id info) {
        if (result){
        }
        else
        {
            NSLog(@"PLAY___sub fail %s__%d__%@__%@__%@", __func__, __LINE__, stream.streamID, @(result),info);
        }
    }];
}


- (void)onStreamFrameDecoded:(CCStream *)stream
{
    //主线程更新
    dispatch_async(dispatch_get_main_queue(), ^{
        [self subSuccessFreshUIStream:stream];
    });
}

- (void)subSuccessFreshUIStream:(CCStream *)stream
{
    WeakSelf(weakSelf);
    CCStreamView *view = [[CCStreamView alloc] initWithStream:stream renderMode:[HDSDocManager sharedDoc].voidModel];;
    [self talkerAudioWithStream:stream];
    NSArray *showViewsArray = self.streamView.showViews;
    if (showViewsArray) {
        for (CCStreamView *showV in showViewsArray) {
            if ([showV.stream.userID isEqualToString:view.stream.userID]) {
                [self.streamView removeStreamView:showV];
            }
        }
    }
    if (stream.type == CCStreamType_ShareScreen)
    {
        [weakSelf showShareScreenView:view];
    }else if (stream.type == CCStreamType_AssistantCamera) {
        
        [weakSelf showAuxiliaryCameraView:view];
    }
    else{
        [weakSelf.streamView showStreamView:view];
    }
    [weakSelf checkStream:view.stream.streamID role:view.stream.role];
}

#pragma mark - stream nil check
- (void)checkStream:(NSString *)streamID role:(CCRole)role
{
    [[CCStreamCheck shared] addStream:streamID role:role];
}

#pragma mark 停止直播
- (void)autoUnSub:(CCStream *)stream
{
    NSLog(@"%s__%d__%@", __func__, __LINE__, stream.streamID);
    __weak typeof(self) weakSelf = self;
    [self.stremer unsubscribeWithStream:stream completion:^(BOOL result, NSError *error, id info) {
        NSLog(@"%s__%d__%@__%@", __func__, __LINE__, stream.streamID, @(result));
        if (result)
        {
            [weakSelf.streamView removeStreamViewByStreamID:stream.streamID];
            //移除桌面共享
            if(stream.type == CCStreamType_ShareScreen){
                [weakSelf removeShareScreenView];
            }
        }
        else
        {
            [CCTool showMessageError:error];
            if (error.code == 6003)
            {
                NSLog(@"取消订阅失败，重新取消订阅");
                [weakSelf performSelector:@selector(autoUnSub:) withObject:stream afterDelay:1.f];
            }
        }
    }];
}

- (void)talkerAudioWithStream:(CCStream *)stream
{
    @try {
        //1、订阅音频流
        [[CCStreamerBasic sharedStreamer] changeStream:stream audioState:YES completion:^(BOOL result, NSError *error, id info) {
        }];
        //2、订阅视频流
        [[CCStreamerBasic sharedStreamer] changeStream:stream videoState:YES completion:^(BOOL result, NSError *error, id info) {
        }];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}
#pragma mark - 屏幕共享
- (void)showShareScreenView:(CCStreamView *)view
{
    self.shareScreen = view;
    self.shareScreenView = [[CCDragView alloc] init];
    self.shareScreenView.frame = CGRectMake(0, 0, 160, 120);
    self.shareScreenView.backgroundColor = [UIColor blackColor];
    [self.shareScreenView addSubview:view];
    [view addObserver:self forKeyPath:@"videoViewSize" options:NSKeyValueObservingOptionNew context:nil];
    __weak typeof(self) weakSelf = self;
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.shareScreenView);
    }];
    self.shareScreenViewGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    self.shareScreenViewGes.numberOfTapsRequired = 2;
    [self.shareScreenView addGestureRecognizer:self.shareScreenViewGes];
    [self.view addSubview:self.shareScreenView];
}
- (void)removeShareScreenView
{
    [self.shareScreen removeObserver:self forKeyPath:@"videoViewSize"];
    [self.shareScreenView removeFromSuperview];
    self.shareScreenViewOldFrame = CGRectZero;
    self.shareScreenViewGes = nil;
    self.shareScreenView = nil;
    self.shareScreen = nil;
}
#pragma mark - 删除辅助摄像头
- (void)removeAssistantCameraView
{
    [self.assistantCamera removeObserver:self forKeyPath:@"videoViewSize_ass"];
    [self.assistantCameraView removeFromSuperview];
    self.assistantCameraOldFrame = CGRectZero;
    self.assistantCameraViewGes = nil;
    self.assistantCameraView = nil;
    self.assistantCamera = nil;
}

- (CCDocVideoView *)hdsDocView
{
    return [[HDSDocManager sharedDoc]hdsDocView];
}

//登录成功
- (void)loginSuccess
{
    
    [self PPTStartRender];
    [self statPreview];
    //判断是否要推流
    [self autoStart];
}
- (void)statPreview
{
    __weak typeof(self) weakSelf = self;
    [self.stremer createLocalStream:YES cameraFront:YES];
    
    [self.stremer startPreviewMode:[HDSDocManager sharedDoc].voidModel completion:^(BOOL result, NSError *error, id info) {
        if (result){
            weakSelf.preview = info;
            if (!self.isLandSpace)
            {
                weakSelf.preview.frame = CGRectMake(0, 0, 160, 90);
            }
            else
            {
                weakSelf.preview.frame = CGRectMake(0, 0, 90, 160);
            }
            [weakSelf.streamView showStreamView:weakSelf.preview];
        }else{
            [CCTool showMessage:@"教师预览失败"];
        }
    }];
}
//开始渲染PPT
- (void)PPTStartRender
{
    //设置文档区域背景色
    [[HDSDocManager sharedDoc] startDocView];
    [self.ccVideoView setDocBackGroundColor:[UIColor whiteColor]];
    [self setDocEditAble];
    [[HDSDocManager sharedDoc]setDpListen:^(CCDocLoadType type, CGFloat w, CGFloat h, id error) {
        NSLog(@"dpLosten-------------------------------------");
        if (type == CCDocLoadTypeComplete)
        {
            [self refreshMenuPageUI];
        }
    }];
}

- (void)setDocEditAble
{
    if (self.isLandSpace)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @try {
                [[HDSDocManager sharedDoc]beEditable];
                [self resetDocPPTFrame];
            } @catch (NSException *exception) {
                NSLog(@"NSException----:%@",exception);
            } @finally {
                
            }
        });
    }
}
//重制ppt的Frame
- (void)resetDocPPTFrame
{
    CGFloat width = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    CGFloat height = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    CGFloat h_r = height;
    CGFloat w_r = (16/9.0)*h_r;
    CGFloat x_r = (width - w_r)/2.0;
    CGRect fm = CGRectMake(0, 0, width - x_r, h_r);
    [[HDSDocManager sharedDoc]setDocFrame:fm displayMode:1];
    self.streamView.steamSpeak.backgroundColor = [UIColor whiteColor];
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
    NSLog(@"refreshMenuPageUI_copy------:%@",textPN);
    self.drawMenuView.pageLabel.text = textPN;
}

#pragma mark - 懒加载
///- draw
- (CCDrawMenuView *)drawMenuView1:(BOOL)showPageChange
{
    if (_drawMenuView)
    {
        _drawMenuView.delegate = nil;
        [_drawMenuView removeFromSuperview];
        _drawMenuView = nil;
    }
    if (!_drawMenuView)
    {
        if (!showPageChange)
        {
            _drawMenuView = [[CCDrawMenuView alloc] initWithStyle:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Full];
        }
        else
        {
            _drawMenuView = [[CCDrawMenuView alloc] initWithStyle:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Page|CCDragStyle_Full];
        }
        _drawMenuView.delegate = self;
        _drawMenuView.layer.cornerRadius = _drawMenuView.frame.size.height/2.f;
        _drawMenuView.layer.masksToBounds = YES;
        [self.view addSubview:_drawMenuView];
        
        NSString *title = [NSString stringWithFormat:@"%@ / %@", @(self.streamView.steamSpeak.nowDocpage), @(self.streamView.steamSpeak.nowDoc.pageSize)];
        self.drawMenuView.pageLabel.text = title;
        __weak typeof(self) weakSelf = self;
        [_drawMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(weakSelf.view).offset(0.f);
            make.top.mas_equalTo(weakSelf.view).offset(20.f);
        }];
    }
    return _drawMenuView;
}
#pragma mark -- 组件化 | 聊天
- (CCChatManager *)ccChatManager
{
    if (!_ccChatManager) {
        _ccChatManager = [CCChatManager sharedChat];
    }
    return _ccChatManager;
}
//排麦
- (CCBarleyManager *)ccBarelyManager
{
    if (!_ccBarelyManager) {
        _ccBarelyManager = [CCBarleyManager sharedBarley];
    }
    return _ccBarelyManager;
}

-(UIView *)contentView {
    if(!_contentView) {
        _contentView = [UIView new];
        //        _contentView.backgroundColor = CCRGBAColor(171,179,189,0.30);
        _contentView.backgroundColor = CCRGBColor(248, 248, 248);
    }
    return _contentView;
}

-(CustomTextField *)chatTextField {
    if(!_chatTextField) {
        _chatTextField = [CustomTextField new];
        _chatTextField.delegate = self;
        _chatTextField.returnKeyType = UIReturnKeySend;
        //        _chatTextField.rightView = self.rightView;
        //        _chatTextField.text = @"中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦1中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦1中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦中华人民共和国城里啦中华人民共和";
    }
    return _chatTextField;
}

-(UIButton *)rightView {
    if(!_rightView) {
        _rightView = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightView.frame = CGRectMake(0, 0, CCGetRealFromPt(48), CCGetRealFromPt(48));
        _rightView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _rightView.backgroundColor = CCClearColor;
        [_rightView setImage:[UIImage imageNamed:@"chat_ic_face_nor"] forState:UIControlStateNormal];
        [_rightView setImage:[UIImage imageNamed:@"chat_ic_face_hov"] forState:UIControlStateSelected];
        [_rightView addTarget:self action:@selector(faceBoardClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightView;
}

-(UIButton *)sendButton {
    if(!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.tintColor = MainColor;
        [_sendButton setTitleColor:MainColor forState:UIControlStateNormal];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        _sendButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_sendButton.titleLabel setFont:[UIFont systemFontOfSize:FontSizeClass_16]];
        [_sendButton addTarget:self action:@selector(sendBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

-(UIButton *)sendPicButton {
    if(!_sendPicButton) {
        _sendPicButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendPicButton setBackgroundImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];
        [_sendPicButton setBackgroundImage:[UIImage imageNamed:@"photo_touch"] forState:UIControlStateHighlighted];
        [_sendPicButton addTarget:self action:@selector(sendPicBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendPicButton;
}

-(UIImageView *)contentBtnView {
    if(!_contentBtnView) {
        _contentBtnView = [[UIImageView alloc] initWithImage:nil];
        _contentBtnView.userInteractionEnabled = YES;
        _contentBtnView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _contentBtnView;
}

-(UIImageView *)topContentBtnView {
    if(!_topContentBtnView) {
        _topContentBtnView = [[UIImageView alloc] initWithImage:nil];
        _topContentBtnView.userInteractionEnabled = YES;
        _topContentBtnView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _topContentBtnView;
}

-(UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

-(NSMutableArray *)tableArray {
    if(!_tableArray) {
        _tableArray = [[NSMutableArray alloc] init];
    }
    return _tableArray;
}

-(UIView *)emojiView {
    if(!_emojiView) {
        _emojiView = [[UIView alloc] initWithFrame:_keyboardRect];
        _emojiView.backgroundColor = CCRGBColor(242,239,237);
        
        CGFloat faceIconSize = CCGetRealFromPt(60);
        CGFloat xspace = (_keyboardRect.size.width - FACE_COUNT_CLU * faceIconSize) / (FACE_COUNT_CLU + 1);
        CGFloat yspace = (_keyboardRect.size.height - 26 - FACE_COUNT_ROW * faceIconSize) / (FACE_COUNT_ROW + 1);
        
        for (int i = 0; i < FACE_COUNT_ALL; i++) {
            UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
            faceButton.tag = i + 1;
            
            [faceButton addTarget:self action:@selector(faceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            //            计算每一个表情按钮的坐标和在哪一屏
            CGFloat x = (i % FACE_COUNT_CLU + 1) * xspace + (i % FACE_COUNT_CLU) * faceIconSize;
            CGFloat y = (i / FACE_COUNT_CLU + 1) * yspace + (i / FACE_COUNT_CLU) * faceIconSize;
            
            faceButton.frame = CGRectMake(x, y, faceIconSize, faceIconSize);
            faceButton.backgroundColor = CCClearColor;
            [faceButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%02d", i+1]]
                        forState:UIControlStateNormal];
            faceButton.contentMode = UIViewContentModeScaleAspectFit;
            [_emojiView addSubview:faceButton];
        }
        //删除键
        UIButton *button14 = (UIButton *)[_emojiView viewWithTag:14];
        UIButton *button20 = (UIButton *)[_emojiView viewWithTag:20];
        
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        back.contentMode = UIViewContentModeScaleAspectFit;
        [back setImage:[UIImage imageNamed:@"chat_btn_facedel"] forState:UIControlStateNormal];
        [back addTarget:self action:@selector(backFace) forControlEvents:UIControlEventTouchUpInside];
        [_emojiView addSubview:back];
        
        [back mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(button14);
            make.centerY.mas_equalTo(button20);
        }];
    }
    return _emojiView;
}
- (UIButton *)startPublishBtn
{
    if (!_startPublishBtn)
    {
        _startPublishBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _startPublishBtn.layer.cornerRadius = CCGetRealFromPt(10);
        _startPublishBtn.layer.masksToBounds = YES;
        
        [_startPublishBtn setTitle:@"" forState:UIControlStateNormal];
        [_startPublishBtn setBackgroundImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
        [_startPublishBtn setBackgroundImage:[UIImage imageNamed:@"start_touch"] forState:UIControlStateHighlighted];
        [_startPublishBtn addTarget:self action:@selector(startPublish) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startPublishBtn;
}

-(UIView *)informationView {
    if(!_informationView) {
        _informationView = [UIView new];
        _informationView.backgroundColor = CCRGBAColor(0, 0, 0, 0.3);
        _informationView.layer.cornerRadius = CCGetRealFromPt(70) / 2;
        _informationView.layer.masksToBounds = YES;
        WS(ws)
        [_informationView addSubview:self.informtionBackImageView];
        [_informtionBackImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws.informationView);
        }];
        
        [_informationView addSubview:self.classRommIconImageView];
        [_classRommIconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.informationView).offset(infomationViewClassRoomIconLeft);
            make.centerY.mas_equalTo(ws.informationView);
            make.height.mas_equalTo(ws.informationView).offset(-6.f);
            make.width.mas_equalTo(ws.classRommIconImageView.mas_height);
        }];
        
        UIImageView *leftErrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"small_arrows"]];
        [_informationView addSubview:leftErrowImageView];
        [leftErrowImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.informationView).offset(-infomationViewErrorwRight);
            make.centerY.mas_equalTo(ws.informationView);
        }];
        
        [_informationView addSubview:self.handupImageView];
        [_handupImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(ws.informationView.mas_height).offset(-6.f);
            make.centerY.mas_equalTo(ws.informationView);
            make.width.mas_equalTo(ws.handupImageView.mas_height);
            make.right.mas_equalTo(ws.informationView).offset(-infomationViewHandupImageViewRight);
        }];
        
        [_informationView addSubview:self.hostNameLabel];
        [_hostNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.classRommIconImageView.mas_right).offset(infomationViewHostNamelabelLeft);
            make.right.mas_equalTo(ws.handupImageView.mas_left).offset(-infomationViewHostNamelabelRight);
            make.top.mas_equalTo(ws.informationView).offset(CCGetRealFromPt(3));
        }];
        [_informationView addSubview:self.userCountLabel];
        [_userCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.height.mas_equalTo(ws.hostNameLabel);
            make.bottom.mas_equalTo(ws.informationView).offset(-CCGetRealFromPt(3));
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchInfoMationView)];
        [_informationView addGestureRecognizer:tap];
        
    }
    return _informationView;
}
- (UIButton *)rightSettingBtn
{
    if (!_rightSettingBtn)
    {
        _rightSettingBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _rightSettingBtn.layer.cornerRadius = CCGetRealFromPt(10);
        _rightSettingBtn.layer.masksToBounds = YES;
        
        [_rightSettingBtn setTitle:@"" forState:UIControlStateNormal];
        [_rightSettingBtn setBackgroundImage:[UIImage imageNamed:@"set"] forState:UIControlStateNormal];
        [_rightSettingBtn setBackgroundImage:[UIImage imageNamed:@"set_touch"] forState:UIControlStateHighlighted];
        [_rightSettingBtn addTarget:self action:@selector(touchSettingBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightSettingBtn;
}

-(UILabel *)hostNameLabel {
    if(!_hostNameLabel) {
        _hostNameLabel = [UILabel new];
        _hostNameLabel.font = [UIFont systemFontOfSize:FontSizeClass_12];
        _hostNameLabel.textAlignment = NSTextAlignmentLeft;
        _hostNameLabel.textColor = [UIColor whiteColor];
        NSString *name = GetFromUserDefaults(LIVE_USERNAME);
        NSString *userName = [@"" stringByAppendingString:name.length == 0 ? @"421小班课" : name];
        
        _hostNameLabel.text = userName;
    }
    return _hostNameLabel;
}

-(UILabel *)userCountLabel {
    if(!_userCountLabel) {
        _userCountLabel = [UILabel new];
        _userCountLabel.font = [UIFont systemFontOfSize:FontSizeClass_11];
        _userCountLabel.textAlignment = NSTextAlignmentLeft;
        _userCountLabel.textColor = [UIColor whiteColor];
        NSInteger str = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_user_count;
        NSString *userCount = [NSString stringWithFormat:@"%ld个成员", (long)str];
        _userCountLabel.text = userCount ;
    }
    return _userCountLabel;
}

- (UIImageView *)informtionBackImageView
{
    if (!_informtionBackImageView)
    {
        _informtionBackImageView = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"setting"];
        image = [image stretchableImageWithLeftCapWidth:image.size.width/2.f topCapHeight:image.size.height/2.f];
        _informtionBackImageView.image = image;
    }
    return _informtionBackImageView;
}

- (UIImageView *)classRommIconImageView
{
    if (!_classRommIconImageView)
    {
        _classRommIconImageView = [[UIImageView alloc] init];
        _classRommIconImageView.image = [UIImage imageNamed:@"classroom"];
    }
    return _classRommIconImageView;
}

- (UIImageView *)handupImageView
{
    if (!_handupImageView)
    {
        _handupImageView = [[UIImageView alloc] init];
        _handupImageView.image = [UIImage imageNamed:@"hangs2"];
    }
    return _handupImageView;
}

-(CCStreamerView *)streamView {
    if(!_streamView) {
        _streamView = [CCStreamerView new];
        CCRoomTemplate template = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_template;
        _streamView.showVC = self.navigationController;
        _streamView.isLandSpace = self.isLandSpace;
        //        [_streamView configWithMode:template role:CCRole_Teacher];
        [self drawMenuView1:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Page|CCDragStyle_Full];
        if (self.isLandSpace && template == CCRoomTemplateSpeak)
        {
            self.hideVideoBtn.hidden = NO;
            self.drawMenuView.hidden = NO;
            [_streamView disableTapGes:NO];
        }
        else
        {
            self.hideVideoBtn.hidden = YES;
            self.drawMenuView.hidden = YES;
            [_streamView disableTapGes:YES];
        }
        [_streamView configWithMode:template role:CCRole_Assistant];
    }
    return _streamView;
}

-(UIButton *)publicChatBtn {
    if(!_publicChatBtn) {
        _publicChatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_publicChatBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message"] forState:UIControlStateNormal];
        [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message_touch"] forState:UIControlStateHighlighted];
        [_publicChatBtn addTarget:self action:@selector(publicChatBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _publicChatBtn;
}

-(UIButton *)cameraChangeBtn {
    if(!_cameraChangeBtn) {
        _cameraChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraChangeBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_cameraChangeBtn setBackgroundImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [_cameraChangeBtn setBackgroundImage:[UIImage imageNamed:@"camera_close"] forState:UIControlStateSelected];
        [_cameraChangeBtn addTarget:self action:@selector(cameraChangeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraChangeBtn;
}

-(UIButton *)micChangeBtn {
    if(!_micChangeBtn) {
        _micChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_micChangeBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_micChangeBtn setBackgroundImage:[UIImage imageNamed:@"microphone2"] forState:UIControlStateNormal];
        [_micChangeBtn setBackgroundImage:[UIImage imageNamed:@"silence2"] forState:UIControlStateSelected];
        [_micChangeBtn addTarget:self action:@selector(micChangeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _micChangeBtn;
}
-(UIButton *)stopPublishBtn {
    if(!_stopPublishBtn) {
        _stopPublishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stopPublishBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_stopPublishBtn setBackgroundImage:[UIImage imageNamed:@"over"] forState:UIControlStateNormal];
        [_stopPublishBtn setBackgroundImage:[UIImage imageNamed:@"over_touch"] forState:UIControlStateHighlighted];
        [_stopPublishBtn addTarget:self action:@selector(stopPublishBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stopPublishBtn;
}
-(UIButton *)closeBtn
{
    if(!_closeBtn)
    {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"close_touch"] forState:UIControlStateHighlighted];
        [_closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}
- (UIButton *)menuBtn
{
    if(!_menuBtn)
    {
        _menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_menuBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_menuBtn setBackgroundImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        [_menuBtn setBackgroundImage:[UIImage imageNamed:@"more_touch"] forState:UIControlStateHighlighted];
        [_menuBtn addTarget:self action:@selector(clickMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _menuBtn;
}
- (UIButton *)fllowBtn
{
    if(!_fllowBtn)
    {
        _fllowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fllowBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_fllowBtn setBackgroundImage:[UIImage imageNamed:@"follow"] forState:UIControlStateNormal];
        [_fllowBtn setBackgroundImage:[UIImage imageNamed:@"follow_touch"] forState:UIControlStateHighlighted];
        
        [_fllowBtn setBackgroundImage:[UIImage imageNamed:@"follow_on"] forState:UIControlStateSelected];
        [_fllowBtn addTarget:self action:@selector(clickFllowBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *followID = [[CCStreamerBasic sharedStreamer] getRoomInfo].teacherFllowUserID;
        _fllowBtn.selected = followID.length == 0 ? NO : YES;
    }
    return _fllowBtn;
}
- (CCRoom *)room
{
    return [[CCStreamerBasic sharedStreamer]getRoomInfo];
}
#pragma mark - 添加监听_和_移除监听
-(void)addObserver {
    NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveSocketEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beconeUnActive) name:CCNotiNeedLoginOut object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveClickNoti:) name:CLICKMOVIE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDocChange:) name:CCNotiChangeDoc object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotati) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCurrentShowDocDel:) name:CCNotiDelCurrentShowDoc object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appInBack) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appInFront) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assistantStopPublish) name:CCNotiNeedStopPublish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(teacherCopyPublish) name:CCNotiNeedStartPublish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SDKNeedsubStream:) name:CCNotiNeedSubscriStream object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SDKNeedUnsubStream:) name:CCNotiNeedUnSubcriStream object:nil];
}

-(void)removeObserver {
    NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiReceiveSocketEvent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedSubscriStream object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedUnSubcriStream object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedLoginOut object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CLICKMOVIE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiChangeDoc object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiDelCurrentShowDoc object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedStopPublish object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedStartPublish object:nil];
}
#pragma mark - 内存警告和移除
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    if (self.shareScreen)
    {
        [self.shareScreen removeObserver:self forKeyPath:@"videoViewSize"];
    }
    if (self.assistantCamera) {
        [self.assistantCamera removeObserver:self forKeyPath:@"videoViewSize_ass"];
    }
    if (self.room_user_cout_timer)
    {
        [self.room_user_cout_timer invalidate];
        self.room_user_cout_timer = nil;
    }
}


@end
