//
//  PushViewController.m
//  NewCCDemo
//
//  Created by cc on 2016/12/2.
//  Copyright © 2016年 cc. All rights reserved.
//

static BOOL gl_stream_sub = true;

#define Log_Mark(mark) NSLog(@"--%@----%s----%d--",mark,__func__,__LINE__)
#import "CCPlayViewController.h"
#import "CCLiveStudentSetController.h"
#import "CustomTextField.h"
#import "CCMemberTableViewController.h"
#import <BlocksKit+UIKit.h>
#import "LoadingView.h"
#import "HDSDocManager.h"
#import "GCPrePermissions.h"
#import "CCLoginScanViewController.h"
#import "CCLoginViewController.h"
#import "CCSignView.h"
#import "CCPhotoNotPermissionVC.h"
#import <AFNetworking.h>
#import "AppDelegate.h"
#import "CCVoteView.h"
#import "CCVoteResultView.h"
#import "TZImagePickerController.h"
#import "CCDocViewController.h"
#import "CCDragView.h"
#import "CCStreamCheck.h"
#import "CCDocListViewController.h"
#import "CCBrainView.h"
#import "CCTicketVoteView.h"
#import "CCTickeResultView.h"
#import "CCRewardView.h"
#import "CCTipsView.h"
#import "CCLoadingView.h"
#import <MetalKit/MetalKit.h>
#import "CCPickView.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>
#import "CCChangeScrollBtn.h"

#define infomationViewClassRoomIconLeft 3
#define infomationViewErrorwRight 9.f
#define infomationViewHandupImageViewRight 16.f
#define infomationViewHostNamelabelLeft  13.f
#define infomationViewHostNamelabelRight 0.f

#define TeacherNamedDelTime 0

typedef void(^CCRejoinBlock)(BOOL result);

@interface CCPlayViewController ()<UITextFieldDelegate,UIActionSheetDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CCDrawMenuViewDelegate,CCStreamerBasicDelegate>
@property(nonatomic,strong)UIAlertView *invitAltertView;//老师上麦邀请
@property(nonatomic,assign)UIAlertView *teacherAlertView;//关麦等的提示框
@property(nonatomic,strong)UIAlertView *loginAlertView;

@property(nonatomic,strong)UIView *videoCutView;
//CCStreamView替换为CCStreamerView
@property(nonatomic,strong)CCStreamerBasic *stremer;

@property(nonatomic,strong)NSString *localStreamID;
@property(nonatomic,strong)CCStream *mixedStream;
@property(nonatomic,strong)CCStream *localStream;
@property(nonatomic,strong)CCStream *localStreamOne;

@property(nonatomic,strong)CCStreamerView     *streamView;
@property(nonatomic,strong)CCStreamView       *preView;
@property(nonatomic,strong)CCStreamView       *teacherPreView;

@property(nonatomic,strong)CCBarleyManager  *ccBarelyManager;
#pragma mark strong - 排麦
@property(nonatomic,strong)CCDocVideoView  *ccVideoView;
//聊天
@property(nonatomic,strong)CCChatManager    *ccChatManager;
@property(nonatomic,strong)UILabel              *hostNameLabel;
@property(nonatomic,strong)UILabel              *userCountLabel;
@property(nonatomic,strong)UIImageView          *informtionBackImageView;
@property(nonatomic,strong)UIImageView          *classRommIconImageView;

@property(nonatomic,strong)UIButton             *publicChatBtn;
@property(nonatomic,strong)UIButton             *lianMaiBtn;
@property(nonatomic,strong)UIButton             *studentSetBtn;

@property(nonatomic,strong)UIView               *informationView;
@property(nonatomic,strong)UIButton             *rightSettingBtn;

@property(nonatomic,strong)CustomTextField      *chatTextField;
@property(nonatomic,strong)UIButton             *sendButton;
@property(nonatomic,strong)UIButton             *sendPicButton;
@property(nonatomic,strong)UIButton             *sendFlowerButton;
@property(nonatomic,strong)UIView               *contentView;
@property(nonatomic,strong)UIButton             *rightView;

@property(nonatomic,copy)NSString               *antename;
@property(nonatomic,copy)NSString               *anteid;
@property(nonatomic,strong)UIView               *emojiView;
@property(nonatomic,assign)CGRect               keyboardRect;

@property(nonatomic,assign)NSInteger            micStatus;//0:默认状态  1:排麦中   2:连麦中
@property(nonatomic,strong)LoadingView          *loadingView;
@property(nonatomic,strong)NSTimer              *room_user_cout_timer;//获取房间人数定时器

@property(nonatomic,strong)UIImageView *handupImageView;

@property(nonatomic,assign)BOOL dismissByInvite;
@property(nonatomic,strong)UIView *keyboardTapView;

@property(nonatomic,strong)CCSignView *signView;//点名答到视图
#pragma mark strong
@property(nonatomic,strong)CCBrainView *brainView;
#pragma mark strong
@property(nonatomic,strong)CCTicketVoteView *ticketVotView;
#pragma mark strong
@property(nonatomic,strong)CCTickeResultView *ticketResultView;
@property(nonatomic,copy)NSString *ticketResult;
@property(nonatomic,strong)NSDictionary *dicTicketsContents;
@property(nonatomic,strong)NSDictionary *dicTicketsResult;

@property(strong,nonatomic)UIImagePickerController      *picker;

@property(nonatomic,strong)UILabel *timerLabel;
@property(nonatomic,strong)NSTimer *timerTimer;

@property(nonatomic,strong)CCVoteView *voteView;
@property(nonatomic,strong)CCVoteResultView *voteResultView;

@property(nonatomic,assign)NSInteger singleAns;
@property(nonatomic,strong)NSMutableArray *multiAns;

@property(nonatomic,strong)UIButton *hideVideoBtn;
@property(nonatomic,strong)UIButton *handupBtn;

@property(nonatomic,strong)CCDragView *shareScreenView;
@property(nonatomic,strong)CCDragView *assistantCameraView;
@property(nonatomic,strong)UITapGestureRecognizer *shareScreenViewGes;
@property(nonatomic,strong)UITapGestureRecognizer *assistantCameraViewGes;
@property(nonatomic,assign)CGRect shareScreenViewOldFrame;
@property(nonatomic,assign)CGRect assistantCameraOldFrame;
@property(nonatomic,strong)CCStreamView *shareScreen;
@property(nonatomic,strong)CCStreamView *assistantCamera;

@property(nonatomic,strong)CCDragView *teacherSecondStreamView;
@property(nonatomic,strong)UITapGestureRecognizer *teacherSecondStreamViewGes;
@property(nonatomic,assign)CGRect teacherSecondStreamViewOldFrame;
@property(nonatomic,strong)CCStreamView *teacherSecondStream;

#pragma mark strong
@property(nonatomic,strong)UIButton *windowFullScreenBtn;
@property(nonatomic,strong)UIButton *windowFullScreenBtnAss;
@property(nonatomic,copy)NSString *warmPlayUrlString;

#pragma mark strong
@property(nonatomic,strong)CCRoom *room;
#pragma mark strong -- 判断是否展示reward view
@property(nonatomic,assign)BOOL willShowRewardView;
@property(nonatomic,assign)BOOL willReJoinAlertShow;
@property (nonatomic,copy) NSString *allow_audio;
@property (nonatomic,copy) NSString *userid;
@property (nonatomic,strong) NSDictionary *bigSmaDic;
@property (strong, nonatomic) NSArray *pickerViewData;
@property (assign, nonatomic) NSInteger pickerViewSelectedIndex;
///是否是自己操作
@property(nonatomic, assign) BOOL isSelfOperation;

@property(nonatomic,strong)HDSTool *hdsTool;

@property(nonatomic,strong)CCChangeScrollBtn *changeScrollBtn;

@end

@implementation CCPlayViewController

- (id)initWithLandspace:(BOOL)landspace
{
    if (self = [super init])
    {
        self.isLandSpace = landspace;
        self.singleAns = -2;
        self.multiAns = nil;
        [self initBaseSDKComponent];
        [self addObserver];
    }
    return self;
}

- (HDSTool *)hdsTool
{
    return [HDSTool sharedTool];
}

- (void)onSocketConnected:(NSString *)nsp
{
    NSLog(@"doc---------reload--!");
    [self docStartLoading];
}

- (void)onServerDisconnected
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIAlertView bk_showAlertViewWithTitle:@"流服务连接异常" message:@"请退出直播间，重新加入直播间！" cancelButtonTitle:@"确认" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
    });
}
- (void)onFailed
{
    [UIAlertView bk_showAlertViewWithTitle:@"消息系统连接异常" message:@"请退出直播间，重新加入直播间！" cancelButtonTitle:@"确认" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
    }];
}

-(void)onLiveEvent:(CCLiveEvent)event info:(NSDictionary<NSString *,NSString *> *)info
{
//    NSLog(@"==onLiveEvent==%lu====%@=",(unsigned long)event, info);
}
#pragma mark - 懒加载
- (CCRoom *)room
{
    return [[CCStreamerBasic sharedStreamer] getRoomInfo];
}
///-- 组件化
- (CCStreamerBasic *)stremer
{
    if (!_stremer) {
        _stremer = [CCStreamerBasic sharedStreamer];
    }
    return _stremer;
}

///组件化 | 聊天
- (CCChatManager *)ccChatManager
{
    if (!_ccChatManager) {
        _ccChatManager = [CCChatManager sharedChat];
    }
    return _ccChatManager;
}

///组件化 | 排麦
- (CCBarleyManager *)ccBarelyManager
{
    if (!_ccBarelyManager) {
        _ccBarelyManager = [CCBarleyManager sharedBarley];
    }
    return _ccBarelyManager;
}

#pragma mark - 生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    //是否需要加入合流
    [[CCStreamerBasic sharedStreamer] setNeedJoinMixStream:YES];
    [self contentImageViewDealShow];
    if (self.isLandSpace)
    {
        [[CCStreamerBasic sharedStreamer] setOrientation:UIInterfaceOrientationLandscapeRight];
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appdelegate.shouldNeedLandscape = self.isLandSpace;
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    self.navigationController.navigationBarHidden=YES;
    [self initUI];
    [self setVideoParentView];
    
    if (_isLandSpace) {
        [[HDSDocManager sharedDoc]setDpListen:^(CCDocLoadType type, CGFloat w, CGFloat h, id error) {
            NSLog(@"dpLosten-------------------------------------");
            if (type == CCDocLoadTypeComplete)
            {
                [self refreshMenuPageUI];
            }
        }];
    }
    self.keyboardTapView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.keyboardTapView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleTap:)];
    [self.keyboardTapView addGestureRecognizer:singleTap];
    
    if (![HDSTool roomLiveStatusOn])
    {
        //停止直播，显示背景视图
        [self.streamView showBackView];
        [self showWarmPlayVideo];
    }
    [self configHandupImage];
    
    if (self.videoAndAudioNoti)
    {
        for (NSNotification *noti in self.videoAndAudioNoti)
        {
            [self receiveSocketEvent:noti];
        }
    }
    [self.videoAndAudioNoti removeAllObjects];
    self.videoAndAudioNoti = nil;
    ///刷新人员列表
    [[NSRunLoop currentRunLoop] addTimer:self.room_user_cout_timer forMode:NSRunLoopCommonModes];
    [self loginAction];
    [self.view addSubview:self.changeScrollBtn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if (self.isLandSpace)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    if ([[CCStreamerBasic sharedStreamer] getRoomInfo].timerDuration >= 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiReceiveSocketEvent object:nil userInfo:@{@"event":@(CCSocketEvent_TimerStart)}];
    } else {
        self.timerView.hidden = YES;
    }
    NSString *userID = [CCStreamerBasic sharedStreamer].getRoomInfo.user_id;
    for (CCUser *user in [CCStreamerBasic sharedStreamer].getRoomInfo.room_userList)
    {
        if ([user.user_id isEqualToString:userID])
        {
            if ((user.user_AssistantState || user.user_drawState) && self.isLandSpace)
            {
                if (user.user_AssistantState)
                {
                    NSString *imageUrl = @"www";
                    if ([imageUrl hasPrefix:@"#"] || [imageUrl hasSuffix:@"#"])
                    {
                        [self drawMenuView1:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Full];
                    }
                    else
                    {
                        [self drawMenuView1:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Full|CCDragStyle_Page];
                    }
                }
                else if(user.user_drawState)
                {
                    [self drawMenuView1:CCDragStyle_DrawAndBack|CCDragStyle_Full];
                }
            }
            else
            {
                [self.drawMenuView removeFromSuperview];
                self.drawMenuView = nil;
                self.drawMenuView.hidden = YES;
                [self paintingAction];
            }
            CCRoomTemplate template = [CCStreamerBasic sharedStreamer].getRoomInfo.room_template;
            if (template == CCRoomTemplateSpeak)
            {
                self.drawMenuView.hidden = NO;
//                if (self.isLandSpace && !self.changeScrollBtn.isHidden) {
//
//                    [self dragAction];
//                }else if(self.isLandSpace){
//                    [self paintingAction];
//                }
            }
            else
            {
                self.drawMenuView.hidden = YES;
                [self paintingAction];
            }
        }
    }
    if (!self.isLandSpace) {
        [self paintingAction];
        [self.ccVideoView setHiddenSlider:NO];
        [self.ccVideoView setDocEditable:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _willShowRewardView = YES;
    [self.streamView viewDidAppear];
    [self reAttachVideoAndShareScreenView];
    [self contentImageViewDealShow];
    
    [self.hdsTool updateMirrorType];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PublishEnd"];
    self.navigationController.navigationBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if (self.voteView)
    {
        [self.voteView removeFromSuperview];
        self.voteView = nil;
    }
    if (self.voteResultView)
    {
        [self.voteResultView removeFromSuperview];
        self.voteResultView = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _willShowRewardView = NO;
    if (self.voteView)
    {
        [self.voteView removeFromSuperview];
        self.voteView = nil;
    }
}

-(void)room_user_cout_timerAction {
    
    [self.stremer updateUserCount];
}


- (void)talkerAudioWithStream:(CCStream *)stream
{
    @try {
        CCRole role = stream.role;
        if (role != CCRole_Student)
        {
            return;
        }
        if (_talker_audio == 1)
        {
            //1、订阅音频流
            [[CCStreamerBasic sharedStreamer] changeStream:stream audioState:YES completion:^(BOOL result, NSError *error, id info) {
            }];
        } else {
            //2、订阅视频流
            [[CCStreamerBasic sharedStreamer] changeStream:stream audioState:NO completion:^(BOOL result, NSError *error, id info) {
            }];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

//刷新订阅的所有的学生流
- (void)talkerAudioStreamRefresh
{
    NSArray *showViewsArray = self.streamView.showViews;
    for (CCStreamView *view in showViewsArray)
    {
        CCStream *stream = view.stream;
        [self talkerAudioWithStream:stream];
    }
}

- (void)contentImageViewDealShow
{
    //调整隐身者角色
    if (self.roleType == CCRole_Inspector) {
        _contentBtnView.hidden = YES;
        _contentBtnView.alpha = 0;
    } else {
        _contentBtnView.hidden = NO;
        _contentBtnView.alpha = 1;
    }
}
#pragma mark -- 文档加载
- (void)docStartLoading
{
    //3、设置文档区域背景色
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //4、设置文档区域背景色
        [self.ccVideoView startDocView];
        [self.ccVideoView setDocBackGroundColor:[UIColor whiteColor]];
    });
}

- (void)loginAction
{
    [self docStartLoading];
    //2、自动连麦
    [self autoLianMai];
}

#pragma mark 自动连麦判断
- (void)autoLianMai
{
    NSLog(@"KKKKKKK--------request lian mai!");
    CCClassType classType = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_class_type;
    if (classType == CCClassType_Rotate && [HDSTool roomLiveStatusOn] && [[CCStreamerBasic sharedStreamer] getRoomInfo].user_role != CCRole_Inspector)
    {
        [[CCBarleyManager sharedBarley] handsUp:^(BOOL result, NSError *error, id info) {
            if (result) {
                [CCTool showMessage:@"自动连麦成功"];
            }else{
                [CCTool showMessageError:error];
            }
        }];
    }
}

- (void)addLoginSocketAlert
{
    NSInteger count = [CCStreamerBasic sharedStreamer].getRoomInfo.room_userList.count;
    if (count == 0)
    {
        UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"正在登录"];
        [alert show];
        _loginAlertView = alert;
    }
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

- (void)changeMictype:(CCClassType)mictype
{
    WS(ws);
    if (mictype == CCClassType_Auto || mictype == CCClassType_Named)
    {
        [_publicChatBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.contentBtnView).offset(CCGetRealFromPt(30));
            make.width.equalTo(@85);
            make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
        }];
        [_lianMaiBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.publicChatBtn.mas_right).offset(CCGetRealFromPt(30));
            make.width.equalTo(@85);
            make.bottom.mas_equalTo(ws.publicChatBtn);
        }];
        
        //zhangkai
        [_studentSetBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(ws.lianMaiBtn.mas_right).offset(CCGetRealFromPt(30));
            make.right.equalTo(self.view).offset(-7);
            make.width.equalTo(@85);
            make.bottom.mas_equalTo(ws.lianMaiBtn);
        }];
        _handupBtn.hidden = YES;
    }
    else if (mictype == CCClassType_Rotate)
    {
        _handupBtn.hidden = NO;
        [_publicChatBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.contentBtnView).offset(CCGetRealFromPt(7));
            make.width.equalTo(@85);
            make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
        }];
        [_handupBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.publicChatBtn.mas_right).offset(CCGetRealFromPt(7));
            make.width.equalTo(@85);
            make.bottom.mas_equalTo(ws.publicChatBtn);
        }];
        [_lianMaiBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.handupBtn.mas_right).offset(CCGetRealFromPt(7));
            make.width.equalTo(@85);
            make.bottom.mas_equalTo(ws.publicChatBtn);
        }];
        
        [_studentSetBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(ws.lianMaiBtn.mas_right).offset(CCGetRealFromPt(7));
            make.right.equalTo(self.view).offset(-7);
            make.width.equalTo(@85);
            make.bottom.mas_equalTo(ws.lianMaiBtn);
        }];
        
        /*
         [_publicChatBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
         make.left.mas_equalTo(ws.contentBtnView).offset(CCGetRealFromPt(30));
         make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
         }];
         [_handupBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
         make.left.mas_equalTo(ws.publicChatBtn.mas_right).offset(CCGetRealFromPt(30));
         make.bottom.mas_equalTo(ws.publicChatBtn);
         }];
         [_lianMaiBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
         make.left.mas_equalTo(ws.handupBtn.mas_right).offset(CCGetRealFromPt(30));
         make.bottom.mas_equalTo(ws.publicChatBtn);
         }];
         
         [_studentSetBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
         make.left.mas_equalTo(ws.lianMaiBtn.mas_right).offset(CCGetRealFromPt(30));
         make.width.equalTo(@90);
         make.bottom.mas_equalTo(ws.lianMaiBtn);
         }]*/
    }
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
        if(width > self.view.frame.size.width * 0.5)
        {
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

- (void)setMicStatus:(NSInteger)micStatus
{
    _micStatus = micStatus;
    NSInteger micNum = [self.ccBarelyManager getLianMaiNum];
    CCClassType mode = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_class_type;
    if (mode == CCClassType_Auto)
    {
        if (_micStatus == 0)
        {   //初始状态
            [self lianMaiBtnResetNormal:@"ligature" selected:@"ligature_touch" title:@" "];
        }
        else if (_micStatus == 1)
        {   //排麦中
            NSString *text = @"";
            if (micNum == 0)
            {
                text = @"排麦中";
            } else {
                text = [NSString stringWithFormat:@"麦序:%ld", (long)micNum];
            }
            [_lianMaiBtn setTitle:text forState:UIControlStateNormal];
            [self lianMaiBtnResetNormal:@"queuing" selected:@"queuing_touch" title:text];
        }
        else if (_micStatus == 2)
        {   //连麦中
            [self lianMaiBtnResetNormal:@"ligaturing" selected:@"ligaturing_touch" title:@" "];
            [self showAutoHiddenAlert:@"连麦成功"];
        }
    }
    else if (mode == CCClassType_Rotate)
    {
        if (_micStatus == 0 || _micStatus == 1)
        {
            self.lianMaiBtn.hidden = YES;
        } else {
            self.lianMaiBtn.hidden = NO;
            [self lianMaiBtnResetNormal:@"ligaturing" selected:@"ligaturing_touch" title:@" "];
            [self showAutoHiddenAlert:@"连麦成功"];
            //[self.streamView reloadData];
        }
    }
    else
    {
        if (_micStatus == 0)
        {   //初始状态
            [self lianMaiBtnResetNormal:@"handsup" selected:@"handsup_touch" title:@" "];
        }
        else if (_micStatus == 1)
        {   //排麦中
            [self lianMaiBtnResetNormal:@"hands" selected:@"hands_touch" title:@" "];
        }
        else if (_micStatus == 2)
        {   //连麦中
            [self lianMaiBtnResetNormal:@"ligaturing" selected:@"ligaturing_touch" title:@" "];
            [self showAutoHiddenAlert:@"连麦成功"];
        }
    }
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

- (void)dealSingleTap:(UITapGestureRecognizer *)tap
{
    [self.chatTextField resignFirstResponder];
}

-(void)initUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.streamView];
    WS(ws)
    //在此处进行自适应
    UIEdgeInsets insets = [CCTool tool_MainWindowSafeArea];
    [_streamView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(insets);
    }];
    
    [self.view addSubview:self.timerView];
    [self.timerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(10.f);
        make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(60) + [CCTool tool_MainWindowSafeArea_Top]);
        make.height.mas_equalTo(1);
        make.width.mas_equalTo(1);
    }];
    [self.view addSubview:self.topContentBtnView];
    
    [self.topContentBtnView addSubview:self.informationView];
    [self.topContentBtnView addSubview:self.rightSettingBtn];
    [self.topContentBtnView addSubview:self.hideVideoBtn];
    if (!self.isLandSpace || ![HDSTool roomLiveStatusOn])
    {
        self.hideVideoBtn.hidden = YES;
    }
    NSString *name = GetFromUserDefaults(LIVE_USERNAME);
    NSString *userName = [@"" stringByAppendingString:name.length == 0 ? @"CC小班课" : name];
    NSString *userCount = @"122个成员";
    CGSize userNameSize = [CCTool getTitleSizeByFont:userName font:[UIFont systemFontOfSize:FontSizeClass_14]];
    CGSize userCountSize = [CCTool getTitleSizeByFont:userCount font:[UIFont systemFontOfSize:FontSizeClass_12]];
    CGSize size = userNameSize.width > userCountSize.width ? userNameSize : userCountSize;
    if(size.width > MIN(self.view.frame.size.width, self.view.frame.size.width) * 0.2) {
        size.width = MIN(self.view.frame.size.width, self.view.frame.size.width) * 0.2;
    }
    [self.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.timerView.mas_right);
        make.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.view).offset(Height_StatusBar);//([CCTool tool_MainWindowSafeArea_Top]);
        make.height.mas_equalTo(35);
    }];
    [self.informationView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.topContentBtnView).offset(0);
        make.top.mas_equalTo(ws.topContentBtnView);
        make.bottom.mas_equalTo(ws.topContentBtnView);
        make.width.mas_equalTo(90 + size.width);
    }];
    
    [self.rightSettingBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(ws.topContentBtnView).offset(-CCGetRealFromPt(30));
        make.centerY.mas_equalTo(ws.informationView);
    }];
    
    [self.hideVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(ws.rightSettingBtn.mas_left).offset(-CCGetRealFromPt(30));
        make.centerY.mas_equalTo(ws.informationView);
    }];
    
    [self.view addSubview:self.contentBtnView];
    [self.view addSubview:self.chatView];
    [self.contentBtnView addSubview:self.publicChatBtn];
    [self.contentBtnView addSubview:self.handupBtn];
    [self.contentBtnView addSubview:self.lianMaiBtn];
    [self.contentBtnView addSubview:self.studentSetBtn];
    
    [_contentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.view);
        make.bottom.mas_equalTo(ws.view).offset(-[CCTool tool_MainWindowSafeArea_Bottom]);
        make.height.mas_equalTo(CCGetRealFromPt(130));
    }];
    
    [_chatView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(30));
        make.bottom.mas_equalTo(ws.contentBtnView.mas_top);
        //        make.width.mas_equalTo(CCGetRealFromPt(640));
        //        make.top.mas_equalTo(ws.view).offset(width*9.f/16.f);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
    }];
    
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
    
    [self.contentView addSubview:self.sendFlowerButton];
    self.sendFlowerButton.hidden = YES;
    CGSize sizeIm = CGSizeMake(1, 25);
    [self.sendFlowerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.contentView.mas_centerY);
        make.left.mas_equalTo(ws.sendPicButton.mas_right).offset(CCGetRealFromPt(1));
        make.size.mas_equalTo(sizeIm);
    }];
    
    [self.contentView addSubview:self.chatTextField];
    [_chatTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.contentView.mas_centerY);
        make.left.mas_equalTo(ws.sendFlowerButton.mas_right).offset(CCGetRealFromPt(5));
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
    [self changeMictype:[CCStreamerBasic sharedStreamer].getRoomInfo.room_class_type];
}

#pragma mark
#pragma mark -- 组件化关联
- (void)initBaseSDKComponent
{
    //基础sdk
    self.stremer = [CCStreamerBasic sharedStreamer];
    [self.stremer addObserver:self];
    
    //排麦
    self.stremer.isUsePaiMai = YES;
    [self.stremer addObserver:self.ccBarelyManager];
    [self.ccBarelyManager addBasicClient:self.stremer];
    
    HDSDocManager *hdsM = [HDSDocManager sharedDoc];
    CCDocVideoView *videoView = [hdsM hdsDocView];
    self.ccVideoView = videoView;
    
    //白板
    [self.stremer addObserver:self.ccVideoView];
    [self.ccVideoView addBasicClient:self.stremer];
    
    //聊天
    [self.stremer addObserver:self.ccChatManager];
    [self.ccChatManager addBasicClient:self.stremer];
    
//    [self.ccChatManager getChatHistoryData:^(BOOL result, NSError *error, id info) {
//        NSLog(@"====getChatHistoryData===%@",info);
//        NSLog(@"====getChatHistoryData===%f",[info[@"startLiveTime"] doubleValue]);
//    }];
}

-(void)setVideoParentView
{
    [[HDSDocManager sharedDoc] setVideoParentView:self.view];
    CGRect vfm = CGRectMake(SCREEN_WIDTH * 0.5 - 100, SCREEN_HEIGHT * 0.5 - 60, 200, 120);
    
    [[HDSDocManager sharedDoc] setVideoParentViewFrame:vfm];
    [[HDSDocManager sharedDoc] initDocEnvironment];
}

- (void)touchInfoMationView
{
    //跳往成员列表
    CCMemberTableViewController *memberVC = [[CCMemberTableViewController alloc] init];
    memberVC.myRole = CCMemberType_Student;
    main_async_safe(^{
        [self.navigationController pushViewController:memberVC animated:YES];
    });
}

- (void)touchSettingBtn
{    
    __weak typeof(self) weakSelf = self;
    [UIAlertView bk_showAlertViewWithTitle:@"" message:@"是否确认退出房间" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1)
        {
            //移除暖场动画
            [self.streamView stopWarmPlayVideo];
            [weakSelf removeObserver];
            [weakSelf loginOutWithBack:YES];
        }
    }];
}

- (void)touchSettingBtnKickout:(NSString *)message
{
    __weak typeof(self) weakSelf = self;
    [UIAlertView bk_showAlertViewWithTitle:@"" message:message cancelButtonTitle:nil otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        //移除暖场动画
        [self.streamView stopWarmPlayVideo];
        [weakSelf removeObserver];
        [weakSelf loginOutWithBack:YES];
    }];
}

-(void)viewPress {
    [_chatTextField resignFirstResponder];
}

//进行聊天
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

////0:默认状态  1:排麦中   2:连麦中
#pragma mark 排麦事件
- (void)lianMaiBtnClicked
{
    _lianMaiBtn.selected = NO;
    __weak typeof(self) weakSelf = self;
    if (self.micStatus == 2)
    {
        NSString *camera = [[CCStreamerBasic sharedStreamer] getRoomInfo].videoState ? @"关闭摄像头" : @"开启摄像头";
        NSString *mic = [[CCStreamerBasic sharedStreamer] getRoomInfo].audioState ? @"关闭麦克风" : @"开启麦克风";
        CCClassType classType = [CCStreamerBasic sharedStreamer].getRoomInfo.room_class_type;
        
        if (classType == CCClassType_Rotate)
        {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:camera, mic, nil];
            [sheet showInView:self.view];
        }
        else
        {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:camera, mic, @"下麦", nil];
            [sheet showInView:self.view];
        }
    }
    else if(self.micStatus == 0)
    {
        _lianMaiBtn.enabled = NO;
        GCPrePermissions *permissions = [GCPrePermissions sharedPermissions];
        [permissions showMicrophonePermissionsWithTitle:@"麦克风设置提醒" message:@"设置麦克风" denyButtonTitle:@"暂不" grantButtonTitle:@"设置" completionHandler:^(BOOL hasPermission, GCDialogResult userDialogResult, GCDialogResult systemDialogResult) {
            BOOL result = [[CCBarleyManager sharedBarley] handsUp:^(BOOL result, NSError *error, id info) {
                if (result)
                {
                    //1.切换为排麦中。
                    weakSelf.micStatus = 1;
                }
                else
                {
                    //2、不做处理  系统错误
                    weakSelf.micStatus = 0;
                    NSString *message = [CCTool toolErrorMessage:error];
                    [UIAlertView bk_showAlertViewWithTitle:@"" message:message cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    }];
                }
                _lianMaiBtn.enabled = YES;
            }];
            if (!result)
            {
                _lianMaiBtn.enabled = YES;
            }
        }];
    }
    else if (self.micStatus == 1)
    {
        _lianMaiBtn.enabled = NO;
        NSString *title = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_class_type == CCClassType_Auto ? @"确定取消排麦" : @"确定取消举手" ;
        UIAlertView *alertView = [UIAlertView bk_showAlertViewWithTitle:@"注意" message:title cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 0)
            {
                _lianMaiBtn.enabled = YES;
            }
            else
            {
                if (self.micStatus == 2)
                {
                    //已经上麦了
                    [UIAlertView bk_showAlertViewWithTitle:@"" message:@"已经上麦" cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    }];
                    _lianMaiBtn.enabled = YES;
                }
                else
                {
                    //取消排麦  handsUpCancel
                    BOOL result = [[CCBarleyManager sharedBarley] handsUpCancel:^(BOOL result, NSError *error, id info) {
                        if (result)
                        {
                            //切换为初始状态
                            weakSelf.micStatus = 0;
                        }
                        else
                        {
                            NSString *message = [CCTool toolErrorMessage:error];
                            [UIAlertView bk_showAlertViewWithTitle:@"" message:message cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                            }];
                        }
                        _lianMaiBtn.enabled = YES;
                    }];
                    if (!result)
                    {
                        self.lianMaiBtn.enabled = YES;
                    }
                }
            }
        }];
        [alertView show];
    }
}

- (void)handupBtnClicked
{
    BOOL result;
    if (!_handupBtn.selected)
    {
        result = [[CCBarleyManager sharedBarley] handup];
    }
    else
    {
        result = [[CCBarleyManager sharedBarley] cancleHandup];
    }
    if (result)
    {
        _handupBtn.selected = !_handupBtn.selected;
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
    _chatTextField.text = nil;
    [_chatTextField resignFirstResponder];
}

-(void)sendPicBtnClicked {
    [_chatTextField resignFirstResponder];
    [self selectImage];
}

- (void)rewardSendFlower
{
    CCShareObject *shareObj = [CCShareObject sharedObj];
    BOOL allowSend = shareObj.isAllowSendFlower;
    if (!allowSend)
    {
        [[CCTipsView new] showMessage:@"鲜花生长中，3分钟后才可以送出哟！"];
        return;
    }
    [self.chatTextField resignFirstResponder];
    CCRoom *room = [[CCStreamerBasic sharedStreamer]getRoomInfo];
    if (![HDSTool roomLiveStatusOn])
    {
        return;
    }
    NSArray *userArr = room.room_userList;
    CCUser *uNow = nil;
    for (CCUser *user in userArr)
    {
        if (user.user_role == CCRole_Teacher)
        {
            uNow = user;
            break;
        }
    }
    if (!uNow)
    {
        return;
    }
    NSString *uid = uNow.user_id;
    NSString *uname = uNow.user_name;
    NSString *type = @"flower";
    NSString *sid = room.user_id;
    [[CCStreamerBasic sharedStreamer]rewardUid:uid uName:uname type:type sender:sid];
    [CCRewardView addTimeLimit];
}

- (void)backFace {
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

- (void)hideVideoBtnClicked:(UIButton *)btn
{
    btn.selected = !btn.selected;
    [self.streamView hideOrShowVideo:btn.selected];
}

#pragma mark - timer
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
    } completion:^(BOOL finished) {
        ws.timerLabel.alpha = 1.f;
        ws.timerLabel.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - CCStreamerBasic noti
- (void)chat_message_chat_message:(NSDictionary *)dic
{
    [self.chatView chatReceiveChatMessage:dic];
}

- (void)beconeUnActive
{
    NSLog(@"%s", __func__);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf popToScanVC];
    });
}

- (void)room_customMessage:(NSDictionary *)dic
{
    NSLog(@"%s --%@", __func__, dic);
}

#pragma mark 教师通知事件
- (void)receiveSocketEvent:(NSNotification *)noti
{
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    id value = noti.userInfo[@"value"];
    NSLog(@"~~~~~~~~~~~~receiveSocketEvent%s__%@__noti:%@", __func__, noti.name,noti);
    if (event == CCSocketEvent_UserListUpdate)
    {
        NSLog(@"%d", __LINE__);
        //房间列表
        NSInteger str = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_user_count;
        NSString *userCount = [NSString stringWithFormat:@"%ld个成员", (long)str];
        _userCountLabel.text = userCount;
        
        [self publicChatBtnResetBackGroundImage];
    }
    else if (event == CCSocketEvent_Announcement)
    {
        NSLog(@"%d", __LINE__);
        //公告
        [self room_customMessage:value];
    }
    else if (event == CCSocketEvent_Chat)
    {
        NSLog(@"%d", __LINE__);
        //聊天信息
        [self chat_message_chat_message:value];
    }
    else if (event == CCSocketEvent_GagOne)
    {
        NSLog(@"%d", __LINE__);
        //禁言或者取消禁言
        BOOL isMute = [[CCStreamerBasic sharedStreamer] getRoomInfo].allow_chat;
        [self publicChatBtnResetBackGroundImage];
        
        CCUser *user = noti.userInfo[@"user"];
        if ([user.user_id isEqualToString:[CCStreamerBasic sharedStreamer].getRoomInfo.user_id])
        {
            NSString *title = !isMute ? @"您被老师开启禁言" : @"您被老师关闭禁言";
            if (self.teacherAlertView)
            {
                [self.teacherAlertView dismissWithClickedButtonIndex:0 animated:NO];
                self.teacherAlertView = nil;
            }
            __weak typeof(self) weakSelf = self;
            if (![CCTool controllerIsShow:self]) return;
            
            self.teacherAlertView = [UIAlertView bk_showAlertViewWithTitle:@"注意" message:title cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (alertView == weakSelf.teacherAlertView)
                {
                    weakSelf.teacherAlertView = nil;
                }
            }];
        }
    }
    else if (event == CCSocketEvent_VideoStateChanged)
    {
        NSLog(@"%d", __LINE__);
        CCUser *user = noti.userInfo[@"user"];
        [self.streamView streamView:user.user_id videoOpened:user.user_videoState];
    }
    else if (event == CCSocketEvent_AudioStateChanged)
    {
        NSLog(@"%d", __LINE__);
        CCUser *user = noti.userInfo[@"user"];
        BOOL changeByTeacher = [noti.userInfo[@"byTeacher"] boolValue];
        [self.streamView reloadData];
        if ([user.user_id isEqualToString:[[CCStreamerBasic sharedStreamer] getRoomInfo].user_id] && [HDSTool roomLiveStatusOn] && changeByTeacher && self.navigationController.visibleViewController == self)
        {
            BOOL isMute = [[CCStreamerBasic sharedStreamer] getRoomInfo].audioState;
            NSString *title = isMute ? @"您被老师开启麦克风" : @"您被老师关闭麦克风";
            if (self.teacherAlertView)
            {
                [self.teacherAlertView dismissWithClickedButtonIndex:0 animated:NO];
                self.teacherAlertView = nil;
            }
            if (![CCTool controllerIsShow:self]) return;
            __weak typeof(self) weakSelf = self;
            if (!self.isSelfOperation) {
                self.teacherAlertView = [UIAlertView bk_showAlertViewWithTitle:@"注意" message:title cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (alertView == weakSelf.teacherAlertView)
                    {
                        weakSelf.teacherAlertView = nil;
                    }
                }];
            }else {
                self.isSelfOperation = NO;
            }
        }
    }
    else if (event == CCSocketEvent_GagAll)
    {   //全体禁言
        NSLog(@"%d", __LINE__);
        BOOL isMuteAll = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_allow_chat;
        [self publicChatBtnResetBackGroundImage];
        
        NSString *title = !isMuteAll ? @"老师开启全体禁言" : @"老师关闭全体禁言";
        if (self.teacherAlertView)
        {
            [self.teacherAlertView dismissWithClickedButtonIndex:0 animated:NO];
            self.teacherAlertView = nil;
        }
#pragma mark 老师开启和关闭全体禁言
        __weak typeof(self) weakSelf = self;
        self.teacherAlertView = [UIAlertView bk_showAlertViewWithTitle:@"注意" message:title cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (alertView == weakSelf.teacherAlertView)
            {
                weakSelf.teacherAlertView = nil;
            }
        }];
    }
    else if (event == CCSocketEvent_PublishStart)
    {
        NSLog(@"time_test----CCSocketEvent_PublishStart");
        //开始推流 这个时候获取老湿streamID开始订阅老湿的流
        [self.streamView removeBackView];
        [[HDSDocManager sharedDoc] clearAllDrawViews];
        CCRoomTemplate template = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_template;
        //要判断隐身者，隐身者并不拉流
        if (self.isLandSpace && template == CCRoomTemplateSpeak)
        {
            self.drawMenuView.hidden = NO;
            if (self.drawMenuView != nil) {
                [self dragAction];
            }
            self.hideVideoBtn.hidden = NO;
        }
        else
        {
            self.hideVideoBtn.hidden = YES;
        }
        self.studentSetBtn.hidden = YES;
        [self.streamView removeBackView];
        [self.streamView configWithMode:template role:CCRole_Student];
        CCClassType classType = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_class_type;
        if (classType == CCClassType_Rotate && [[CCStreamerBasic sharedStreamer] getRoomInfo].user_role != CCRole_Inspector)
        {
            [[CCBarleyManager sharedBarley] handsUp:^(BOOL result, NSError *error, id info) {
                if (result) {
                    [CCTool showMessage:@"自动连麦成功"];
                }else{
                    [CCTool showMessageError:error];
                }
            }];
        }
        if (!_isLandSpace)
        {
            //解决停止直播再次开始直播，竖屏界面问题
            CCUser *user = [self getCurrentUser:self.room.user_id];
            [self playPusherEventCCSocketEvent_ReciveAnssistantChange:user isAnssistantChange:NO];
        }
        [self.ccVideoView setDocEditable:NO];
    }
    else if (event == CCSocketEvent_PublishEnd)
    {
        NSLog(@"%d", __LINE__);
        NSLog(@"time_test----CCSocketEvent_PublishEnd");
        //结束推流  取消订阅
        if (self.micStatus == 2)
        {
            [self stopPublish];
            self.micStatus = 0;
        }
        else
        {
            self.micStatus = 0;
        }
        self.studentSetBtn.hidden = NO;
        [[HDSDocManager sharedDoc] clearAllDrawData];
        [self.streamView showBackView];
        //停止直播，存储标记，然后用于再次直播的变大变小的判断。  在离开页面的时候清空存储，防止对下次登录造成污染。
        [[NSUserDefaults standardUserDefaults] setObject:@"small" forKey:@"PublishEnd"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (self.signView)
        {
            [self.signView removeFromSuperview];
            self.signView = nil;
        }
        if (self.voteView)
        {
            [self.voteView removeFromSuperview];
            self.voteView = nil;
        }
        if (self.voteResultView)
        {
            [self.voteResultView removeFromSuperview];
            self.voteResultView = nil;
        }
        self.drawMenuView.hidden = YES;
        [_changeScrollBtn removeFromSuperview];
        _changeScrollBtn = nil;
        [self.view addSubview:self.changeScrollBtn];
        [self paintingAction];
        self.hideVideoBtn.hidden = YES;
        self.hideVideoBtn.selected = NO;
        [self.streamView hideOrShowVideo:NO];
    }
    else if (event == CCSocketEvent_LianmaiStateUpdate)
    {
        //更新麦序
        NSLog(@"%d", __LINE__);
        CCClassType mode = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_class_type;
        if (self.micStatus == 1 && mode == CCClassType_Auto)
        {
            NSInteger micNum = [self.ccBarelyManager getLianMaiNum];
            NSString *text = [NSString stringWithFormat:@"   麦序:%ld", (long)micNum];
            [self.lianMaiBtn setTitle:text forState:UIControlStateNormal];
        }
        [self configHandupImage];
    }
    else if (event == CCSocketEvent_KickFromRoom)
    {
        NSLog(@"%d", __LINE__);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self touchSettingBtnKickout:@"您已被退出房间"];
        });
    }
    else if (event == CCSocketEvent_MediaModeUpdate)
    {
        NSLog(@"%d", __LINE__);
        CCVideoMode micType = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_video_mode;
        [self.streamView roomMediaModeUpdate:micType];
    }
    else if (event == CCSocketEvent_TeacherNamed)
    {
        if ([self roleIsInspector])
        {
            //隐身者不能参加互动
            return;
        }
        _chatTextField.text = nil;
        [_chatTextField resignFirstResponder];
        NSLog(@"%d", __LINE__);
        if (self.signView)
        {
            [self.signView removeFromSuperview];
            self.signView = nil;
        }
        NSDictionary *info = [noti.userInfo objectForKey:@"value"];
        NSTimeInterval duration = [[info objectForKey:@"duration"] doubleValue];
        duration -= TeacherNamedDelTime;
        self.signView = [[CCSignView alloc] initWithTime:duration completion:^(BOOL result) {
            if (result)
            {
                [[CCStreamerBasic sharedStreamer] studentNamed];
            }
        }];
        [self.signView show];
    }
    else if (event == CCSocketEvent_UserCountUpdate)
    {
        NSInteger allCount = [value integerValue];
        NSString *userCount = [NSString stringWithFormat:@"%ld个成员", (long)allCount];
        _userCountLabel.text = userCount ;
    }
    else if (event == CCSocketEvent_LianmaiModeChanged)
    {
        NSLog(@"%d", __LINE__);
        [self configHandupImage];
        [self changeMictype:[CCStreamerBasic sharedStreamer].getRoomInfo.room_class_type];
        CCClassType mode  = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_class_type;
        if (mode == CCClassType_Auto || mode == CCClassType_Rotate)
        {
            _lianMaiBtn.hidden = (mode == CCClassType_Rotate);
            [self lianMaiBtnResetNormal:@"ligature" selected:@"ligature_touch" title:@" "];
        }
        else
        {
            _lianMaiBtn.hidden = NO;
            [self lianMaiBtnResetNormal:@"handsup" selected:@"handsup_touch" title:@" "];
        }
        self.micStatus = self.micStatus;
    }
    else if (event == CCSocketEvent_ReciveLianmaiInvite)
    {
        NSLog(@"%d", __LINE__);
        XXLogSaveAPIPar(XXLogFuncLine, @{@"event":@(event)});
        [self receiveInvite:noti];
    }
    else if (event == CCSocketEvent_ReciveCancleLianmaiInvite)
    {
        NSLog(@"%d", __LINE__);
        if (self.invitAltertView)
        {
            self.dismissByInvite = YES;
            NSLog(@"%s__%d", __func__, __LINE__);
            [self.invitAltertView dismissWithClickedButtonIndex:-1 animated:YES];
            self.invitAltertView = nil;
        }
    }
    else if (event == CCSocketEvent_SocketReconnectedFailed)
    {
        NSLog(@"%d", __LINE__);
        //退出
        __weak typeof(self) weakSelf = self;
        [UIAlertView bk_showAlertViewWithTitle:@"" message:@"网路太差" cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [[CCStreamerBasic sharedStreamer] leave:^(BOOL result, NSError *error, id info) {
                
            }];
            [weakSelf popToScanVC];
        }];
    }
    else if (event == CCSocketEvent_TemplateChanged)
    {
        NSLog(@"模版切换----：%d", __LINE__);
        //        CCRoomTemplate template = (CCRoomTemplate)[[noti.userInfo objectForKey:@"value"] integerValue];
        //        if (self.isLandSpace && template == CCRoomTemplateSpeak)
        //        {
        //            self.hideVideoBtn.hidden = NO;
        //            self.drawMenuView.hidden = NO;
        //        }
        //        else
        //        {
        //            self.hideVideoBtn.hidden = YES;
        //            self.drawMenuView.hidden = YES;
        //        }
        //        self.hideVideoBtn.selected = NO;
        //        NSLog(@"~~~~~~~~~~~~~~~房间模板：%d",template);
        //        [self.streamView configWithMode:template role:CCRole_Student];
        
        //        [self loginOut];
    }
    else if (event == CCSocketEvent_DocDraw)
    {
        NSLog(@"%d", __LINE__);
        if ([value isKindOfClass:[NSString class]])
        {
            NSError *err = nil;
            value = [NSJSONSerialization JSONObjectWithData:[value dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:NSJSONReadingMutableLeaves
                                                      error:&err];
        }
    }
    else if (event == CCSocketEvent_DocPageChange)
    {
        NSLog(@"%d", __LINE__);
        UIViewController *topVC = self.navigationController.visibleViewController;
        if ([topVC isKindOfClass:[CCDocViewController class]])
        {
            CCDocViewController *docVC = (CCDocViewController *)topVC;
            [docVC docPageChange];
        }
    }
    else if (event == CCSocketEvent_ReciveDocAnimationChange)
    {
        NSLog(@"%d", __LINE__);
    }
    else if (event == CCSocketEvent_TimerStart)
    {
        NSLog(@"%d", __LINE__);
        NSLog(@"!!!!!!!!!!!!!--------start!-----");
        //计时器开始
        [self timeTimerStart];
        [self timerOpenForDocController:YES];
    }
    else if (event == CCSocketEvent_TimerEnd)
    {
        NSLog(@"%d", __LINE__);
        NSLog(@"!!!!!!!!!!!!!--------end!-----");
        //计时器结束
        [self timeTimerEnd];
        [self timerOpenForDocController:NO];
    }
    else if (event == CCSocketEvent_ReciveVote)
    {
        if ([self roleIsInspector])
        {
            //隐身者不能参加互动
            return;
        }
        _chatTextField.text = nil;
        [_chatTextField resignFirstResponder];
        //答题开始
        if (self.voteView)
        {
            [self.voteView removeFromSuperview];
            self.voteView = nil;
        }
        if (self.voteResultView)
        {
            [self.voteResultView removeFromSuperview];
            self.voteResultView = nil;
        }
        WS(ws);
        NSInteger ansCount = [[value objectForKey:@"voteCount"] integerValue];
        BOOL isSingle = [[value objectForKey:@"voteType"] integerValue] == 1 ? NO : YES;
        NSString *voteID = [value objectForKey:@"voteId"];
        NSString *publisherID = [value objectForKey:@"publisherId"];
        __weak typeof(self) weakSelf = self;
        self.voteView = [[CCVoteView alloc] initWithCount:ansCount singleSelection:isSingle closeblock:^{
            [ws.voteView removeFromSuperview];
            ws.voteView = nil;
        } voteSingleBlock:^(NSInteger index) {
            weakSelf.singleAns = index;
            [ws.voteView removeFromSuperview];
            ws.voteView = nil;
            BOOL isSuccess = [[CCStreamerBasic sharedStreamer] sendVoteSelected:nil singleAns:index voteID:voteID publisherID:publisherID];
            if (isSuccess) {
                [self showAutoHiddenAlert:@"提交成功"];
            }
        } voteMultipleBlock:^(NSMutableArray *indexArray) {
            weakSelf.multiAns = indexArray;
            [ws.voteView removeFromSuperview];
            ws.voteView = nil;
            BOOL isSuccess = [[CCStreamerBasic sharedStreamer] sendVoteSelected:indexArray singleAns:-1 voteID:voteID publisherID:publisherID];
            if (isSuccess) {
                [self showAutoHiddenAlert:@"提交成功"];
            }
        } singleNOSubmit:^(NSInteger index) {
        } multipleNOSubmit:^(NSMutableArray *indexArray) {
        }];
        self.singleAns = -2;
        self.multiAns = nil;
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow addSubview:self.voteView];
        [_voteView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(keyWindow);
        }];
        [self.voteView layoutIfNeeded];
    }
    else if (event == CCSocketEvent_ReciveStopVote)
    {
        if (self.voteView)
        {
            [self.voteView removeFromSuperview];
            self.voteView = nil;
        }
        if (self.voteResultView)
        {
            [self.voteResultView removeFromSuperview];
            self.voteResultView = nil;
        }
    }
    else if (event == CCSocketEvent_ReciveVoteAns)
    {
        if ([self roleIsInspector])
        {
            //隐身者不能参加互动
            return;
        }
        _chatTextField.text = nil;
        [_chatTextField resignFirstResponder];
        if (self.voteView)
        {
            [self.voteView removeFromSuperview];
            self.voteView = nil;
        }
        if (self.voteResultView)
        {
            [self.voteResultView removeFromSuperview];
            self.voteResultView = nil;
        }
        WS(ws);
        NSDictionary *result = value;
        self.voteResultView = [[CCVoteResultView alloc] initWithResultDic:result mySelectIndex:self.singleAns mySelectIndexArray:self.multiAns closeblock:^{
            [ws.voteResultView removeFromSuperview];
            ws.voteResultView = nil;
        }];
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow addSubview:self.voteResultView];
        [self.voteResultView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(keyWindow);
        }];
        [self.voteResultView layoutIfNeeded];
    }
    else if (event == CCSocketEvent_StreamRemoved)
    {
        //退出
        __weak typeof(self) weakSelf = self;
        [UIAlertView bk_showAlertViewWithTitle:@"" message:@"流断开了" cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [weakSelf stopLianMai];
        }];
    }
    else if (event == CCSocketEvent_ReciveDrawStateChanged)
    {
        [self.streamView reloadData];
        //授权标注列表变动
        CCUser *user = noti.userInfo[@"user"];
        if ([user.user_id isEqualToString:self.room.user_id])
        {
            [[HDSDocManager sharedDoc]hdsSetDrawDefaultColor:nil];
            UIViewController *topVC = self.navigationController.visibleViewController;
            if ([topVC isKindOfClass:[CCDocViewController class]])
            {
                CCDocViewController *docVC = (CCDocViewController *)topVC;
                [docVC showOrHideDrawView:user.user_drawState calledByDraw:YES];
            }
            else if ([topVC isKindOfClass:[CCPlayViewController class]])
            {
                if (user.user_drawState)
                {
                    [self showAutoHiddenAlert:@"你已被老师开启授权标注"];
                    if (self.isLandSpace)
                    {
                        [[HDSDocManager sharedDoc]beAuthDraw];
                    }
                    //开启授权
                    CCRoomTemplate template = [CCStreamerBasic sharedStreamer].getRoomInfo.room_template;
                    if (self.isLandSpace && !user.user_AssistantState)
                    {
                        //开启
                        [self drawMenuView1:CCDragStyle_DrawAndBack|CCDragStyle_Full];
                        self.drawMenuView.hidden = YES;
                        if (template == CCRoomTemplateSpeak)
                        {
                            self.drawMenuView.hidden = NO;
                            if (self.changeScrollBtn.hidden) {
                                
                                [self dragAction];
                            }
                        }
                        else
                        {
                            self.drawMenuView.hidden = YES;
                            [self paintingAction];
                        }
                        [self.streamView disableTapGes:NO];
                    }
                }
                else
                {
                    //关闭授权
                    if (self.isLandSpace)
                    {
                        if (!user.user_AssistantState)
                        {
                            //关闭
                            [self.drawMenuView removeFromSuperview];
                            self.drawMenuView = nil;
                            [self.streamView disableTapGes:YES];
                            self.drawMenuView.hidden = YES;
                            [self paintingAction];
                            [_changeScrollBtn removeFromSuperview];
                            _changeScrollBtn = nil;
                            [self.view addSubview:self.changeScrollBtn];
                            if (self.isLandSpace) {
                                
                                [self.ccVideoView setHiddenSlider:YES];
                            }else {
                                [self.ccVideoView setHiddenSlider:NO];
                            }
                        }
                    }
                    [self revokeUserDrawState:user];
                    [self showAutoHiddenAlert:@"你已被老师关闭授权标注"];
                }
            }
        }
    }
    else if (event == CCSocketEvent_HandupStateChanged)
    {
        CCUser *user = [noti.userInfo objectForKey:@"user"];
        if ([user.user_id isEqualToString:[CCStreamerBasic sharedStreamer].getRoomInfo.user_id])
        {
            self.handupBtn.selected = user.handup;
        }
        [self configHandupImage];
    }
    else if (event == CCSocketEvent_RotateLockedStateChanged)
    {
        [self.streamView reloadData];
    }
    else if (event == CCSocketEvent_ReciveAnssistantChange)
    {
        CCUser *user = noti.userInfo[@"user"];
        [self playPusherEventCCSocketEvent_ReciveAnssistantChange:user isAnssistantChange:YES];
    }
    else if (event == CCSocketEvent_ReciveStreamBigOrSmall)
    {
        [self.streamView showStreamInDoc:value];
    }
    //头脑风暴
    else if (event == CCSocketEvent_BrainstomSend)
    {
        if ([self roleIsInspector])
        {
            return;
        }
        [self socketBrainstom:0 value:value];
    }
    else if (event == CCSocketEvent_BrainstomReply)
    {
        if ([self roleIsInspector])
        {
            return;
        }
        [self socketBrainstom:1 value:value];
    }
    else if (event == CCSocketEvent_BrainstomEnd)
    {
        if ([self roleIsInspector])
        {
            return;
        }
        [self socketBrainstom:2 value:value];
    }
    //投票
    else if (event == CCSocketEvent_VoteSend)
    {
        if ([self roleIsInspector])
        {
            return;
        }
        [self socketVote:0 value:value];
    }
    else if (event == CCSocketEvent_VoteReply)
    {
        if ([self roleIsInspector])
        {
            return;
        }
        [self socketVote:1 value:value];
    }
    else if (event == CCSocketEvent_VoteEnd)
    {
        if ([self roleIsInspector])
        {
            return;
        }
        [self socketVote:2 value:value];
    }
    else if (event == CCSocketEvent_TalkerAudioUpdate)
    {
        NSDictionary *info = noti.userInfo;
        NSInteger talker_audio = [info[@"talker_audio"]integerValue];
        _talker_audio = talker_audio;
        [self talkerAudioStreamRefresh];
    }
    //奖杯、鲜花
    else if(event == CCSocketEvent_Flower)
    {
        [self rewardFlower:value];
    }
    else if(event == CCSocketEvent_Cup)
    {
        [self rewardCup:value];
    }
    else if (event == CCSocketEvent_BroadcastMsg)
    {
        NSLog(@"CCSocketEvent_BroadcastMsg--value==%@",value);
    }
    else if (event == CCSocketEvent_ReciveInterCutAudioOrVideo)
    {

    }
}
#pragma mark -- 取消用户的可编辑状态
- (void)revokeUserDrawState:(CCUser *)user
{
    if (user && !user.user_drawState && !user.user_AssistantState)
    {
        [[HDSDocManager sharedDoc]beAuthDrawCancel];
    }
}

- (void)playPusherEventCCSocketEvent_ReciveAnssistantChange:(CCUser *)user isAnssistantChange:(BOOL)isAnssistantChange
{
    [self.streamView reloadData];
    if ([user.user_id isEqualToString:self.room.user_id])
    {
        [[HDSDocManager sharedDoc]hdsSetDrawDefaultColor:nil];
        
        UIViewController *topVC = self.navigationController.visibleViewController;
        if ([topVC isKindOfClass:[CCDocViewController class]])
        {
            CCDocViewController *docVC = (CCDocViewController *)topVC;
            [docVC showOrHideDrawView:user.user_AssistantState calledByDraw:NO];
        }
        else if ([topVC isKindOfClass:[CCPlayViewController class]])
        {
            if (user.user_AssistantState)
            {
                if (isAnssistantChange) {
                    
                    [self showAutoHiddenAlert:@"你已被老师开启设为讲师"];
                }
                CCRoomTemplate template = [CCStreamerBasic sharedStreamer].getRoomInfo.room_template;
                if (self.isLandSpace)
                {
                    [[HDSDocManager sharedDoc]beAuthTeacher];
                    NSString *imageUrl = @"www";
                    if ([imageUrl hasPrefix:@"#"] || [imageUrl hasSuffix:@"#"])
                    {
                        [self drawMenuView1:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Full];
                    }
                    else
                    {
                        [self drawMenuView1:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Page|CCDragStyle_Full];
                    }
                    self.drawMenuView.hidden = YES;
                    if (template == CCRoomTemplateSpeak)
                    {
                        self.drawMenuView.hidden = NO;
                        [self dragAction];
                    }
                    else
                    {
                        self.drawMenuView.hidden = YES;
                        [self paintingAction];
                    }
                    [self.streamView disableTapGes:NO];
                }
                else
                {
                    [[HDSDocManager sharedDoc]beAuthTeacherCancel];
                }
            }
            else
            {
                if (isAnssistantChange) {
                    
                    [self showAutoHiddenAlert:@"你已被老师关闭设为讲师"];
                }
                [self revokeUserDrawState:user];
                if (!user.user_drawState)
                {
                    [self.drawMenuView removeFromSuperview];
                    self.drawMenuView = nil;
                    [self.streamView disableTapGes:YES];
                    self.drawMenuView.hidden = YES;
                    [self paintingAction];
                    if (self.isLandSpace) {
                        [self.ccVideoView setHiddenSlider:YES];
                    }else {
                        
                        [self.ccVideoView setHiddenSlider:NO];
                    }
                    [_changeScrollBtn removeFromSuperview];
                    _changeScrollBtn = nil;
                    [self.view addSubview:self.changeScrollBtn];
                    [self.ccVideoView setHiddenSlider:YES];
                }
                else
                {
                    CCRoomTemplate template = [CCStreamerBasic sharedStreamer].getRoomInfo.room_template;
                    if (self.isLandSpace && !user.user_AssistantState)
                    {
                        [self drawMenuView1:CCDragStyle_DrawAndBack|CCDragStyle_Full];
                        self.drawMenuView.hidden = YES;
                        if (template == CCRoomTemplateSpeak)
                        {
                            self.drawMenuView.hidden = NO;
                            [self dragAction];
                        }
                        else
                        {
                            self.drawMenuView.hidden = YES;
                            [self paintingAction];
                            if (self.isLandSpace) {
                                [self.ccVideoView setHiddenSlider:YES];
                            }else {
                                
                                [self.ccVideoView setHiddenSlider:NO];
                            }
                        }
                        [self.streamView disableTapGes:NO];
                    }
                }
                
            }
        }
    }
    [self refreshMenuPageUI_copy];
}

//头脑风暴并没有做区分，如果是隐身者是不显示的
- (void)socketBrainstom:(int)type value:(NSDictionary *)obj {
    // 0 send 1 replay 2 end
    NSDictionary *dataDic = obj[@"data"];
    NSString *markId = dataDic[@"id"];
    if (type == 0) {
        NSString *title = dataDic[@"title"];
        NSString *content = dataDic[@"content"];
        self.brainView = [[CCBrainView alloc]initTitle:title content:content complete:^(BOOL result,BOOL edited,NSString *title,NSString *content) {
            if (result) {
                if (!content || [content length] == 0 || edited == NO)
                {
                    UIAlertView *altV = [UIAlertView bk_alertViewWithTitle:@"请填写问答！"];
                    [altV bk_setCancelButtonWithTitle:@"确认" handler:^{
                    }];
                    [altV show];
                    return ;
                }
                [[CCStreamerBasic sharedStreamer] sendBrainReply:markId title:title text:content];
                [self.brainView removeFromSuperview];
            }
        }];
        [self.brainView show];
    }
    if (type == 1) {
        return;
    }
    if (type == 2) {
        [self.brainView removeFromSuperview];
    }
}

//投票
- (void)socketVote:(int)type value:(NSDictionary *)obj {
    __weak typeof(self)weakSelf = self;
    NSDictionary *dicData = obj[@"data"];
    NSString *markId = dicData[@"id"];
    if (type == 0) {
        self.ticketResult = @"";
        self.dicTicketsContents = dicData;
        NSString *title = dicData[@"title"];
        NSNumber *type = dicData[@"type"];
        NSArray *choices = dicData[@"choices"];
        self.ticketVotView = [[CCTicketVoteView alloc]initTitle:title type:[type intValue] choices:choices complete:^(BOOL result, NSArray *select, NSString *answer) {
            if (result) {
                weakSelf.ticketResult = answer;
                //发送投票答案
                [[CCStreamerBasic sharedStreamer] sendVoteTickedReply:markId title:title choice:select];
            }
        }];
        [self.ticketVotView show];
    }
    if (type == 1) {
        return;
    }
    if (type == 2) {
        //没有参与投票，结果页不展示
        if (!self.dicTicketsContents)
        {
            return;
        }
        self.dicTicketsResult = dicData;
        self.ticketResultView = [[CCTickeResultView alloc]initWithChoiceContent:self.dicTicketsContents result:self.dicTicketsResult select:self.ticketResult];
        [self.ticketResultView show];
    }
}

//reward 奖励、鲜花
- (void)rewardFlower:(id)obj
{
    NSLog(@"rewardFlower__%@",obj);
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
- (void)rewardCup:(id)obj
{
    NSLog(@"rewardCup%@",obj);
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
    if (!_willShowRewardView)
    {
        return;
    }
    [[CCRewardView shareReward]showRole:type user:user withTarget:self isTeacher:NO];
}

- (void)receiveInvite:(NSNotification *)noti
{
    CCClassType mode = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_class_type;
    if (mode == CCClassType_Auto)
    {
        [self publish];
    }
    else
    {
        if (self.invitAltertView)
        {
            self.dismissByInvite = YES;
            NSLog(@"%s__%d", __func__, __LINE__);
            [self.invitAltertView dismissWithClickedButtonIndex:-1 animated:YES];
            self.invitAltertView = nil;
        }
        //教师邀请上麦
        self.dismissByInvite = NO;
        self.invitAltertView = [UIAlertView bk_showAlertViewWithTitle:@"" message:@"老师邀请上麦" cancelButtonTitle:@"拒绝" otherButtonTitles:@[@"同意"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex >= 0)
            {
                if (buttonIndex == 0)
                {
                    //拒绝老师的连麦邀请
                    [[CCBarleyManager sharedBarley] refuseTeacherInvite:^(BOOL result, NSError *error, id info) {
                        NSLog(@"%@__%@__%@", @(result), error, info);
                        self.micStatus = 0;
                    }];
                }
                else
                {
                    //接受老师的连麦邀请
                    [[CCBarleyManager sharedBarley] acceptTeacherInvite:^(BOOL result, NSError *error, id info) {
                        NSLog(@"%@__%@__%@", @(result), error, info);
                    }];
                }
            }
        }];
    }
}
#pragma mark 预览
- (void)startPreview:(CCComletionBlock)completion
{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[CCStreamerBasic sharedStreamer] startPreviewMode:[HDSDocManager sharedDoc].voidModel completion:^(BOOL result, NSError *error, id info) {
            if (result) {
                CCStreamView *view = info;
                weakSelf.preView = view;
                if (completion)
                {
                    completion(YES, nil, info);
                }
            }else{
                [CCTool showMessageError:error];
            }
        }];
    });
}

#pragma mark 推流
///预览
- (void)publish
{
    NSLog(@"~~~~~~~~~~~~~publish+++++++++++++++%s__%d", __func__, __LINE__);
    //如果是隐身者，不做推流操作
    if (self.roleType == CCRole_Inspector)  return;
    
    SaveToUserDefaults(SET_CAMERA_DIRECTION, @"前置摄像头");
    CCEncodeConfig *config = [[CCEncodeConfig alloc] init];
    config.reslution = CCResolution_240;
    __weak typeof(self) weakSelf = self;
    BOOL cameraFront = self.hdsTool.isCameraFront;
    [self.stremer createLocalStream:YES cameraFront:cameraFront];
    
    //1.开始预览
    [self startPreview:^(BOOL result, NSError *error, id info) {
        if (!result)
        {
            NSLog(@"----%d---%@----%@---",result,error,info);
            NSString *errorMsg = [CCTool toolErrorMessage:error];
            [UIAlertView bk_showAlertViewWithTitle:@"注意" message:errorMsg cancelButtonTitle:@"取消" otherButtonTitles:@[@"重试"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1)
                {
                    [weakSelf publish];
                }
                else
                {
                    [weakSelf stopPublish];
                }
            }];
        }else{
            [weakSelf satrtPublish];
        }
    }];
}
///推流
-(void)satrtPublish
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        //2、显示界面
        NSLog(@"~~~~~~~~~~~~weakSelf.preView:%@",weakSelf.preView);
        [weakSelf.streamView showStreamView:weakSelf.preView];
    });
    //3、添加关麦事件
    if (![self.stremer getRoomInfo].room_allow_audio)
    {
        [self.stremer setAudioOpened:NO userID:nil];
    }
    //3、直播成功之后，开始推流。
    [weakSelf.stremer publish:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCRoom *room = [CCRoom shareRoomHDS];
            if (room.room_video_mode == CCVideoMode_Audio)
            {
                [weakSelf.stremer setVideoOpened:NO userID:nil];
                if ([weakSelf.stremer getRoomInfo].room_allow_audio)
                {
                    [weakSelf.stremer setAudioOpened:YES userID:nil];
                }
            }
            else
            {
                if ([weakSelf.stremer getRoomInfo].room_allow_audio)
                {
                    [weakSelf.stremer setAudioOpened:YES userID:nil];
                }
                [weakSelf.stremer setVideoOpened:YES userID:nil];
            }
            weakSelf.localStreamID = weakSelf.stremer.localStreamID;
            //4、推流成功，更新用户排麦状态。
            [weakSelf.ccBarelyManager updateUserState:weakSelf.room.user_id roomID:nil publishResult:YES streamID:weakSelf.localStreamID completion:^(BOOL result, NSError *error, id info) {
                if (result) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.micStatus = 2;
                    });
                }else{
                    [CCTool showMessageError:error];
                }
            }];
        }
        else
        {
            NSString *errorMsg = [CCTool toolErrorMessage:error];
            [UIAlertView bk_showAlertViewWithTitle:@"注意" message:errorMsg cancelButtonTitle:@"取消" otherButtonTitles:@[@"重试"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1)
                {
                    [weakSelf satrtPublish];
                }
                else
                {
                    [weakSelf stopPublish];
                }
            }];
        }
    }];
}

- (void)stopLianMai
{
    if (!self.stremer.localStreamID || self.stremer.localStreamID.length == 0)
    {
        [CCTool showMessage:@"目前没有上麦！"];
        return;
    }
    WS(weakSelf);
    [weakSelf.ccBarelyManager handsDown:^(BOOL result, NSError *error, id info) {
        if (result) {
            [weakSelf.streamView removeStreamView:info];
        } else {
            NSString *message = [CCTool toolErrorMessage:error];
            [UIAlertView bk_showAlertViewWithTitle:@"" message:message cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            }];
        }
    }];
}

#pragma mark 拉流代理
- (void)SDKNeedsubStream:(NSNotification *)notify
{
    if (!gl_stream_sub)
    {
        return;
    }
    NSLog(@"XXXXXXXXXXXX--------SDK--sub");
    [CCRoom shareRoomHDS].live_status = CCLiveStatus_Start;
    
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
         self.studentSetBtn.hidden = YES;
         [self autoSub:stream];
#pragma mark -- 添加如下代码会导致横屏UI错乱
//         [self.streamView removeBackView];
    });
}

- (void)SDKNeedUnsubStream:(NSNotification *)notify
{
    if (!gl_stream_sub)
    {
        return;
    }
    NSLog(@"XXXXXXXXXXXX--------SDK--unsub");
    NSDictionary *dicInfo = notify.userInfo;
    
    CCStream *stream = dicInfo[@"stream"];

    if ([stream.userID isEqualToString:self.stremer.userID])
    {
        //自己的流不订阅
        return;
    }
    [self autoUnSub:stream];
}

#pragma mark --展示
- (void)showRole:(CCStream *)stream
{
    CCRole role = stream.role;
    NSString *roleString = [CCRoom stringFromRole:role];
    NSString *streamAdd = [NSString stringWithFormat:@"streamadd-role-<%@>",roleString];
    [CCTool showMessage:streamAdd];
}

- (void)autoSub:(CCStream *)stream
{
    NSLog(@"stream.streamID==%@",stream.streamID);
    
    [self.stremer subcribeWithStream:stream completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSLog(@"sub success %s__%d__%@__%@__%@", __func__, __LINE__, stream.streamID, @(result),info);
        }
        else
        {
            NSLog(@"sub fail %s__%d__%@__%@__%@", __func__, __LINE__, stream.streamID, @(result),info);
            [CCTool showMessageError:error];
        }
    }];
}

//解码完成,加载视图
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
    if (stream.type != CCStreamType_ShareScreen && stream.type != CCStreamType_AssistantCamera) {
        
        //遍历循环，防止view重复
        NSArray *showViewsArray = self.streamView.showViews;
        if (showViewsArray) {
            for (CCStreamView *showV in showViewsArray) {
                if ([showV.stream.userID isEqualToString:view.stream.userID]) {
                    [self.streamView removeStreamView:showV];
                }
            }
        }
    }
    if (stream.type == CCStreamType_ShareScreen)
    {
        [weakSelf showShareScreenView:view];
    }
    else if (stream.type == CCStreamType_AssistantCamera)
    {
        [weakSelf showAuxiliaryCameraView:view];
    }
    else
    {
        [weakSelf.streamView showStreamView:view];
    }
    [weakSelf checkStream:view.stream.streamID role:view.stream.role];
}

- (void)autoUnSub:(CCStream *)stream
{
    WS(weakSelf);
    [self.stremer unsubscribeWithStream:stream completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCStream *ccstream = info;
            //            [weakSelf.streamView removeStreamViewByStreamID:ccstream.streamID];
            //移除桌面共享
            if(stream.type == CCStreamType_ShareScreen){
                [weakSelf removeShareScreenView];
            }else if (stream.type == CCStreamType_AssistantCamera) {
                
                [weakSelf removeAssistantCameraView];
            } else {
                [weakSelf.streamView removeStreamViewByStreamID:ccstream.streamID];
            }
        }
        else
        {
            [CCTool showMessageError:error];
            if (error.code == 6003)
            {
                [weakSelf performSelector:@selector(autoUnSub:) withObject:stream afterDelay:1.f];
            }
        }
    }];
}

#pragma mark 下麦也要更新麦序
- (void)stopPublish
{
    __weak typeof(self) weakSelf = self;
    [self.stremer unPublish:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSString *localStreamid = weakSelf.stremer.localStreamID;
            weakSelf.localStreamID = localStreamid;
            [weakSelf.streamView removeStreamView:weakSelf.preView];
            
            [weakSelf.ccBarelyManager updateUserState:self.room.user_id roomID:self.room.user_roomID publishResult:NO streamID:localStreamid completion:^(BOOL result, NSError *error, id info) {
                
            }];
            //修改麦克风状态
            [weakSelf setMicStatus:0];
        }
        else
        {
            [CCTool showMessageError:error];
        }
    }];
}

//退出界面
- (void)loginOutWithBack:(BOOL)willBack
{
    if (_loadingView)
    {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
    _loadingView = [[LoadingView alloc] initWithLabel:@"正在关闭直播间..."];
    [self.view addSubview:_loadingView];
    [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.preView removeFromSuperview];
    [self.streamView removeStreamView:self.preView];
    __weak typeof(self) weakSelf = self;
    self.ccVideoView = nil;
    //停止预览
    [[CCStreamerBasic sharedStreamer] stopPreview:^(BOOL result, NSError *error, id info) {
        [self.stremer unPublish:^(BOOL result, NSError *error, id info) {
        }];
        //需要释放掉原视图，防止白板内容没被删除。
        [[HDSDocManager sharedDoc] hdsReleaseDoc];
        [[CCStreamerBasic sharedStreamer] leave:^(BOOL result, NSError *error, id info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.loadingView removeFromSuperview];
                [weakSelf.stremer clearData];
                if (willBack)
                {
                    [weakSelf popToScanVC];
                }
            });
        }];
    }];
    self.preView = nil;
}

#pragma mark - UIActionSheetDelegate
- (void)mediaSwitchAudio:(NSString *)uid state:(BOOL)open
{
    [HDSTool mediaSwitchUserid:uid state:open role:CCRole_Student response:^(BOOL result, id  _Nullable info, NSError * _Nullable error) {
        if (result)
        {
            [self.stremer setAudioOpened:open userID:nil];
        } else {
            [CCTool showMessage:error.domain];
        }
    }];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) return;

    if(buttonIndex == 0)
    {
        if ([[CCStreamerBasic sharedStreamer] getRoomInfo].room_video_mode == CCVideoMode_AudioAndVideo)
        {
            if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"关闭摄像头"]) {
                [self.stremer setVideoOpened:NO userID:nil];
            }else{
                [self.stremer setVideoOpened:YES userID:nil];
            }
        }
    }
    else if(buttonIndex == 1)
    {
        self.isSelfOperation = YES;
        NSString *uid = self.room.user_id;
        //关闭麦克风
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"关闭麦克风"]) {
            [self mediaSwitchAudio:uid state:NO];
        }else{
            if ([[CCStreamerBasic sharedStreamer] getRoomInfo].room_allow_audio) {
                [self mediaSwitchAudio:uid state:YES];
            }else {
                [CCTool showMessage:@"全体关麦中,不能操作"];
            }
        }
    }
    else if (buttonIndex == 2)
    {
        //下麦
        [self stopLianMai];
    }
}

#pragma mark 键盘发送聊天信息
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self chatSendMessage];
    return YES;
}

-(void)chatSendMessage {
    NSString *str = _chatTextField.text;
    if(str == nil || str.length == 0) {
        return;
    }
    _chatTextField.text = nil;
    [_chatTextField resignFirstResponder];
    //这里要去str处理
    str = [Dialogue addLinkTag:str];
    //发送公聊信息
    [self.ccChatManager sendMsg:str];
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
    
    if ([self.chatTextField isFirstResponder]) {
        [self contentImageViewDealShow];
        self.contentView.hidden = NO;
        WS(ws)
        [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.view);
            make.bottom.mas_equalTo(ws.view).offset(-y);
            make.height.mas_equalTo(CCGetRealFromPt(110));
        }];
        [_chatView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(30));
            make.bottom.mas_equalTo(ws.contentBtnView.mas_top);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
            //            make.width.mas_equalTo(CCGetRealFromPt(640));
            //            make.top.mas_equalTo(ws.view).offset(width*9.f/16.f);
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
    [self contentImageViewDealShow];
    
    self.contentView.hidden = YES;
    [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(ws.view);
        make.height.mas_equalTo(CCGetRealFromPt(110));
    }];
    [_chatView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(30));
        make.bottom.mas_equalTo(ws.contentBtnView.mas_top);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
        //        make.width.mas_equalTo(CCGetRealFromPt(640));
        //        make.top.mas_equalTo(ws.view).offset(width*9.f/16.f);
    }];
    
    [UIView animateWithDuration:0.25f animations:^{
        self.contentView.hidden = YES;
        [ws.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - send Pic
- (void)selectImage
{
    WS(weakSelf);
    [HDSTool photoLibraryAuth:^(BOOL result, NSDictionary * _Nullable info, NSError * _Nullable error) {
        if (result) {
            [weakSelf pickImage];
        }
        else
        {
            [weakSelf pushPhotoLibrary];
        }
    }];
}
#pragma mark -- 图片选择
- (void)pushPhotoLibrary
{
    dispatch_async(dispatch_get_main_queue(), ^{
       CCPhotoNotPermissionVC *_photoNotPermissionVC = [CCPhotoNotPermissionVC new];
        [self.navigationController pushViewController:_photoNotPermissionVC animated:NO];
    });
}


-(void)pickImage {
    dispatch_async(dispatch_get_main_queue(), ^{
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
    });
}

//支持相片库
- (BOOL)isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary];
}

#pragma mark 找不到上传图片Token
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image= [info objectForKey:UIImagePickerControllerOriginalImage];
    WS(ws)
    [_picker dismissViewControllerAnimated:YES completion:^{
        //发送图片
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[CCChatManager sharedChat] sendImage:image completion:^(BOOL result, NSError *error, id info) {
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

#pragma mark - tz
- (void)pushImagePickerController {
    WS(ws);
    dispatch_async(dispatch_get_main_queue(), ^{
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
        imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
        imagePickerVc.allowPickingVideo = NO;
        imagePickerVc.allowPickingImage = YES;
        imagePickerVc.allowPickingOriginalPhoto = YES;
        imagePickerVc.sortAscendingByModificationDate = YES;
        imagePickerVc.allowEdited = NO;
        
        __weak typeof(TZImagePickerController *) weakPicker = imagePickerVc;
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            [weakPicker dismissViewControllerAnimated:YES completion:^{
                if (photos.count > 0)
                {
                    //发送图片
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        [[CCChatManager sharedChat] sendImage:photos.lastObject completion:^(BOOL result, NSError *error, id info) {
                        }];
                    });
                }
            }];
        }];
        [imagePickerVc setImagePickerControllerDidCancelHandle:^{
        }];
        imagePickerVc.modalPresentationStyle = 0;
        [ws.navigationController presentViewController:imagePickerVc animated:YES completion:nil];
    });
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
    
    @try {
        [self.windowFullScreenBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf.shareScreenView.mas_right).offset(-10.f);
            make.bottom.mas_equalTo(weakSelf.shareScreenView.mas_bottom).offset(-10.f);
        }];
    } @catch (NSException *exception) {
        XXLogSaveAPIPar(XXLogFuncLine, @{@"event_stu":@"tap"});
    } @finally {
        
    }
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
    @try {
        [self.windowFullScreenBtnAss mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf.assistantCameraView.mas_right).offset(-10.f);
            make.bottom.mas_equalTo(weakSelf.assistantCameraView.mas_bottom).offset(-10.f);
        }];
    } @catch (NSException *exception) {
        XXLogSaveAPIPar(XXLogFuncLine, @{@"event_stu":@"tapAssistant"});
    } @finally {
        
    }
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
    self.assistantCameraView.frame = self.assistantCameraOldFrame;
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
///删除辅屏幕共享
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

- (void)reAttachShareScreenView
{
    if (self.shareScreen && self.shareScreenView)
    {
        [self.shareScreenView removeFromSuperview];
        [self.view addSubview:self.shareScreenView];
        if (CGSizeEqualToSize(self.shareScreen.videoViewSize, CGSizeZero))
        {
            self.shareScreenView.frame = CGRectMake(0, 0, 160, 120);
        }
        else
        {
            CGSize newSize = self.shareScreen.videoViewSize;
            CGFloat height = newSize.height/newSize.width * self.shareScreenView.frame.size.width;
            CGRect newFrame = CGRectMake(self.view.frame.size.width - self.shareScreenView.frame.size.width - 10, 80, self.shareScreenView.frame.size.width, height);
            self.shareScreenView.frame = newFrame;
        }
    }
}

- (void)reAssistantCameraView
{
    if (self.assistantCamera && self.assistantCameraView)
    {
        [self.assistantCameraView removeFromSuperview];
        [self.view addSubview:self.assistantCameraView];
        if (CGSizeEqualToSize(self.assistantCamera.videoViewSize, CGSizeZero))
        {
            self.assistantCameraView.frame = CGRectMake(0, 0, 160, 120);
        }
        else
        {
            CGSize newSize = self.assistantCamera.videoViewSize;
            CGFloat height = newSize.height/newSize.width * self.assistantCameraView.frame.size.width;
            CGRect newFrame = CGRectMake(self.view.frame.size.width - self.assistantCameraView.frame.size.width - 10, 80, self.assistantCameraView.frame.size.width, height);
            self.assistantCameraView.frame = newFrame;
        }
    }
}

- (void)reAttachVideoAndShareScreenView
{
    [self reAttachShareScreenView];
    [self reAssistantCameraView];
    
    [self reAttachteacherSecondStreamView];
}

#pragma mark  - 高拍仪
- (void)showteacherSecondStreamView:(CCStreamView *)view
{
    self.teacherSecondStream = view;
    self.teacherSecondStreamView = [[CCDragView alloc] init];
    self.teacherSecondStreamView.frame = CGRectMake(0, 240, 160, 120);
    self.teacherSecondStreamView.backgroundColor = [UIColor blackColor];
    [self.teacherSecondStreamView addSubview:view];
    [view addObserver:self forKeyPath:@"videoViewSize" options:NSKeyValueObservingOptionNew context:nil];
    __weak typeof(self) weakSelf = self;
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.teacherSecondStreamView);
    }];
    
    self.teacherSecondStreamViewGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap1:)];
    self.teacherSecondStreamViewGes.numberOfTapsRequired = 2;
    [self.teacherSecondStreamView addGestureRecognizer:self.teacherSecondStreamViewGes];
    
    [self.view addSubview:self.teacherSecondStreamView];
}

- (void)removeteacherSecondStreamView
{
    [self.teacherSecondStream removeObserver:self forKeyPath:@"videoViewSize"];
    [self.teacherSecondStreamView removeFromSuperview];
    self.teacherSecondStreamViewOldFrame = CGRectZero;
    self.teacherSecondStreamViewGes = nil;
    self.teacherSecondStreamView = nil;
    self.teacherSecondStream = nil;
}

- (void)reAttachteacherSecondStreamView
{
    if (self.teacherSecondStream && self.teacherSecondStreamView)
    {
        [self.teacherSecondStreamView removeFromSuperview];
        [self.view addSubview:self.teacherSecondStreamView];
        if (CGSizeEqualToSize(self.teacherSecondStream.videoViewSize, CGSizeZero))
        {
            self.teacherSecondStreamView.frame = CGRectMake(0, 240, 160, 120);
        }
        else
        {
            CGSize newSize = self.teacherSecondStream.videoViewSize;
            CGFloat height = newSize.height/newSize.width * self.teacherSecondStreamView.frame.size.width;
            CGRect newFrame = CGRectMake(self.view.frame.size.width - self.teacherSecondStreamView.frame.size.width - 10, 240, self.teacherSecondStreamView.frame.size.width, height);
            self.teacherSecondStreamView.frame = newFrame;
        }
    }
}

- (void)tap1:(UITapGestureRecognizer *)ges
{
    self.teacherSecondStreamViewOldFrame = self.teacherSecondStreamView.frame;
    self.teacherSecondStreamView.frame = [UIScreen mainScreen].bounds;
    self.teacherSecondStreamView.dragEnable = NO;
    self.teacherSecondStreamViewGes.enabled = NO;
    
    [self.teacherSecondStreamView removeFromSuperview];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.teacherSecondStreamView];
    ges.enabled = NO;
    UIButton *smallBtn = [UIButton new];
    [smallBtn setTitle:@"" forState:UIControlStateNormal];
    [smallBtn setImage:[UIImage imageNamed:@"exitfullscreen"] forState:UIControlStateNormal];
    [smallBtn setImage:[UIImage imageNamed:@"exitfullscreen_touch"] forState:UIControlStateSelected];
    [smallBtn addTarget:self action:@selector(clickSmall1:) forControlEvents:UIControlEventTouchUpInside];
    [self.teacherSecondStreamView addSubview:smallBtn];
    __weak typeof(self) weakSelf = self;
    [smallBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.teacherSecondStreamView.mas_right).offset(-10.f);
        make.bottom.mas_equalTo(weakSelf.teacherSecondStreamView.mas_bottom).offset(-10.f);
    }];
}

- (void)clickSmall1:(UIButton *)btn
{
    [btn removeFromSuperview];
    [self.teacherSecondStreamView removeFromSuperview];
    [self.view addSubview:self.teacherSecondStreamView];
    self.teacherSecondStreamView.frame = self.teacherSecondStreamViewOldFrame;
    self.teacherSecondStreamView.dragEnable = YES;
    self.teacherSecondStreamViewGes.enabled = YES;
}

#pragma mark - draw
- (CCDrawMenuView *)drawMenuView1:(CCDragStyle)style
{
    if (_drawMenuView)
    {
        _drawMenuView.delegate = nil;
        [_drawMenuView removeFromSuperview];
        _drawMenuView = nil;
        self.drawMenuView.hidden = YES;
    }
    if (!_drawMenuView)
    {
        _drawMenuView = [[CCDrawMenuView alloc] initWithStyle:style];
        _drawMenuView.delegate = self;
        [self.view addSubview:_drawMenuView];
        __weak typeof(self) weakSelf = self;
        [_drawMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(weakSelf.view).offset(0.f);
            make.top.mas_equalTo(weakSelf.view).offset(20.f);
        }];
        NSString *textPN = [NSString stringWithFormat:@"%@ / %@", @(self.streamView.steamSpeak.nowDocpage+1), @(self.streamView.steamSpeak.nowDoc.pageSize)];
        _drawMenuView.pageLabel.text = textPN;
    }
    return _drawMenuView;
}

- (void)drawBtnClicked:(UIButton *)btn
{
    [self showDrawMenu:btn];
}

- (void)frontBtnClicked:(UIButton *)btn
{
    //撤销
    [[HDSDocManager sharedDoc]revokeDrawLast];
}

- (void)cleanBtnClicked:(UIButton *)btn
{
    [[HDSDocManager  sharedDoc]revokeDrawAll];
}

- (void)pageFrontBtnClicked:(UIButton *)btn
{
    BOOL res = [self.streamView clickFront:nil];
    if (res)
    {
        [self refreshMenuPageUI];
    }
}

- (void)pageBackBtnClicked:(UIButton *)btn
{
    BOOL res = [self.streamView clickBack:nil];
    if (res)
    {
        [self refreshMenuPageUI];
    }
}

- (void)refreshMenuPageUI
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self refreshMenuPageUI_copy];
    });
}

- (void)refreshMenuPageUI_copy
{
    HDSDocManager *hdsM = [HDSDocManager sharedDoc];
    CCDoc *doc =  [hdsM hdsCurrentDoc];
    NSUInteger pageNow = [hdsM hdsCurrentDocPage];
    
    NSString *textPN = [NSString stringWithFormat:@"%@ / %@", @(pageNow+1), @(doc.pageSize)];
    if ([doc.docID isEqualToString:@"WhiteBorad"])
    {
        textPN = @"1 / 1";
        ///隐藏按钮
    }
    self.drawMenuView.pageLabel.text = textPN;
}

- (void)menuBtnClicked:(UIButton *)btn
{
    //显示操作栏
    [self.streamView hideOrShowView:YES];
}

- (void)showDrawMenu:(UIButton *)btn
{
    
}

- (void)docPageChange
{
    NSString *textPN = [NSString stringWithFormat:@"%@ / %@", @(self.streamView.steamSpeak.nowDocpage+1), @(self.streamView.steamSpeak.nowDoc.pageSize)];
    self.drawMenuView.pageLabel.text = textPN;
}

- (void)docChange:(NSNotification *)noti
{
    UIViewController *topVC = self.navigationController.visibleViewController;
    CCUser *user = [self.hdsTool toolGetUserFromUserID:self.viewerId];
    if ([topVC isKindOfClass:[CCDocViewController class]])
    {
        CCDocViewController *docVC = (CCDocViewController *)topVC;
        [docVC showOrHideDrawView:user.user_AssistantState calledByDraw:NO];
    }
    else if ([topVC isKindOfClass:[CCPlayViewController class]])
    {
        CCRoomTemplate template = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_template;
        if (self.isLandSpace)
        {
            NSString *imageUrl = @"www";
            if ([imageUrl hasPrefix:@"#"] || [imageUrl hasSuffix:@"#"])
            {
                [self drawMenuView1:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Full];
            }
            else
            {
                [self drawMenuView1:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Page|CCDragStyle_Full];
            }
            self.drawMenuView.hidden = YES;
            if (template == CCRoomTemplateSpeak)
            {
                self.drawMenuView.hidden = NO;
                [self dragAction];
            }
            else
            {
                self.drawMenuView.hidden = YES;
                [self paintingAction];
            }
            [self.streamView disableTapGes:NO];
        }
    }
}

#pragma mark - stream nil check
- (void)checkStream:(NSString *)streamID role:(CCRole)role
{
    [[CCStreamCheck shared] addStream:streamID role:role];
}

- (void)reSub:(NSNotification *)noti
{
    NSDictionary *info = noti.userInfo;
    NSLog(@"%s__%d__%@", __func__, __LINE__, info);
    NSString *streamID = [info objectForKey:@"streamID"];
    WS(weakSelf);
    CCStream *stream = [[CCStreamerBasic sharedStreamer] getStreamWithStreamID:streamID];
    
    [[CCStreamerBasic sharedStreamer] unsubscribeWithStream:stream completion:^(BOOL result, NSError *error, id info) {
        NSLog(@"call--unsub--line:<%d>-result:%d --error:%@--info:%@",__LINE__,result,error,info);
#warning 新增处理共享屏幕，对比的参数值发生了改变
        if (weakSelf.shareScreen.stream.type == CCStreamType_ShareScreen)
        {
            [weakSelf removeShareScreenView];
        }
        else if (weakSelf.shareScreen.stream.type == CCStreamType_AssistantCamera)
        {
            [weakSelf removeAssistantCameraView];
        } else {
            [weakSelf.streamView removeStreamViewByStreamID:info];
        }
        NSInteger count = weakSelf.streamView.showViews.count;
        if (weakSelf.shareScreenView)
        {
            count++;
        }
        [self.stremer subcribeWithStream:[[CCStreamerBasic sharedStreamer] getStreamWithStreamID:streamID] completion:^(BOOL result, NSError *error, id info) {
            NSLog(@"call--sub--line:<%d>-result:%d --error:%@--info:%@",__LINE__,result,error,info);
        }];
    }];
}

- (void)popToScanVC
{
    [HDSTool sharedTool].mirrorType = 0;
    [HDSTool popToController:[CCLoginViewController class] navigation:self.navigationController landscape:self.isLandSpace];
}

- (void)showWarmPlayVideo
{
    if (self.warmPlayUrlString && [self.warmPlayUrlString length] != 0) return;
    WS(ws);
    [HDSTool roomWarmPlayInfo:^(BOOL result, NSDictionary * _Nullable info, NSError * _Nullable error) {
        if (!result) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *playUrlString = info[@"data"][@"app_playurl"];
            ws.warmPlayUrlString = playUrlString;
            [ws.streamView startWarmPlayVideo:playUrlString];
        });
    }];
}

//用户角色判断
- (BOOL)roleIsInspector
{
    if (self.roleType == CCRole_Inspector)
    {
        return YES;
    }
    return NO;
}

//调整鲜花奖杯，聊天视图层次
- (void)changeKeyboardViewUp
{
    [self.view bringSubviewToFront:self.contentView];
}

#pragma mark -- 计时器
- (void)timeTimerStart
{
    self.timerView.hidden = NO;
    WS(ws);
    CGSize userNameSize = [CCTool getTitleSizeByFont:self.timerLabel.text font:[UIFont systemFontOfSize:FontSizeClass_12]];
    [self.timerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(10.f);
        make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(60));
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(60+userNameSize.width);
    }];
    
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
- (void)timeTimerEnd
{
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

- (void)timerOpenForDocController:(BOOL)open
{
    UIViewController *topVC = self.navigationController.visibleViewController;
    if ([topVC isKindOfClass:[CCDocViewController class]])
    {
        CCDocViewController *docVC = (CCDocViewController *)topVC;
        if (open)
        {
            [docVC startTimeTimer];
        }
        else
        {
            [docVC stopTimeTimer];
        }
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(UIView *)contentView {
    if(!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = CCRGBColor(248, 248, 248);
    }
    return _contentView;
}

-(CustomTextField *)chatTextField {
    if(!_chatTextField) {
        _chatTextField = [CustomTextField new];
        _chatTextField.delegate = self;
        _chatTextField.returnKeyType = UIReturnKeySend;
    }
    return _chatTextField;
}

-(UIButton *)rightView {
    if(!_rightView) {
        _rightView = [HDSTool createBtnCustom:@"chat_ic_face_nor" selected:@"chat_ic_face_hov" target:self action:@selector(faceBoardClick)];
        _rightView.frame = CGRectMake(0, 0, CCGetRealFromPt(48), CCGetRealFromPt(48));
        _rightView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _rightView.backgroundColor = CCClearColor;
    }
    return _rightView;
}

-(UIButton *)sendButton {
    if(!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _sendButton.tintColor = MainColor;
        _sendButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_sendButton setTitleColor:MainColor forState:UIControlStateNormal];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton.titleLabel setFont:[UIFont systemFontOfSize:FontSizeClass_16]];
        [_sendButton addTarget:self action:@selector(sendBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

-(UIButton *)sendPicButton {
    if(!_sendPicButton) {
        _sendPicButton = [HDSTool createBtnCustom:@"photo" hightLighted:@"photo_touch" target:self action:@selector(sendPicBtnClicked)];
    }
    return _sendPicButton;
}

- (UIButton *)sendFlowerButton
{
    if (!_sendFlowerButton)
    {
        _sendFlowerButton = [HDSTool createBtnCustom:@"flower_small" hightLighted:@"flower_small" target:self action:@selector(rewardSendFlower)];
    }
    return _sendFlowerButton;
}

-(UIImageView *)contentBtnView {
    if(!_contentBtnView) {
        _contentBtnView = [[UIImageView alloc] initWithImage:nil];
        _contentBtnView.userInteractionEnabled = YES;
        _contentBtnView.contentMode = UIViewContentModeScaleAspectFit;
    }
    [self contentImageViewDealShow];
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

- (HDSChatView *)chatView
{
    if (!_chatView)
    {
        _chatView = [[HDSChatView alloc]initWithArray:@[] landspace:self.isLandSpace viewid:self.viewerId];
    }
    return _chatView;
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
            //  计算每一个表情按钮的坐标和在哪一屏
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

-(UILabel *)hostNameLabel {
    if(!_hostNameLabel) {
        _hostNameLabel = [UILabel new];
        _hostNameLabel.font = [UIFont systemFontOfSize:FontSizeClass_12];
        _hostNameLabel.textAlignment = NSTextAlignmentLeft;
        _hostNameLabel.textColor = [UIColor whiteColor];
        //        NSString *name = GetFromUserDefaults(LIVE_USERNAME);
        NSString *name = GetFromUserDefaults(LIVE_ROOMNAME);
        NSString *userName = [@"" stringByAppendingString:name.length == 0 ? @"421小班课" : name];
        _hostNameLabel.text = userName;
    }
    return _hostNameLabel;
}

- (UILabel *)userCountLabel {
    if(!_userCountLabel) {
        _userCountLabel = [UILabel new];
        _userCountLabel.font = [UIFont systemFontOfSize:FontSizeClass_11];
        _userCountLabel.textAlignment = NSTextAlignmentLeft;
        _userCountLabel.textColor = [UIColor whiteColor];
        NSInteger str = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_user_count;
        NSString *userCount = [NSString stringWithFormat:@"%ld个成员", (long)str];
        _userCountLabel.text = userCount;
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
        _classRommIconImageView = [HDSTool createImageViewName:@"classroom"];
    }
    return _classRommIconImageView;
}

- (UIImageView *)handupImageView
{
    if (!_handupImageView)
    {
        _handupImageView = [HDSTool createImageViewName:@"hangs2"];
    }
    return _handupImageView;
}

-(CCStreamerView *)streamView {
    if(!_streamView) {
        _streamView = [[CCStreamerView alloc] init];
        CCRoomTemplate template = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_template;
        _streamView.showVC = self.navigationController;
        _streamView.isLandSpace = self.isLandSpace;
        if (self.isLandSpace && template == CCRoomTemplateSpeak)
        {
            self.hideVideoBtn.hidden = NO;
            self.drawMenuView.hidden = NO;
            [self paintingAction];
            if (self.isLandSpace) {
                
                [self.ccVideoView setHiddenSlider:YES];
            }else {
                [self.ccVideoView setHiddenSlider:NO];
            }
        }
        else
        {
            self.hideVideoBtn.hidden = YES;
            self.drawMenuView.hidden = YES;
            [self paintingAction];
        }
        NSLog(@"~~~~~~~~~~~~~~~房间模板：%d",template);
        [_streamView configWithMode:template role:self.roleType];
    }
    return _streamView;
}

-(UIButton *)publicChatBtn {
    if(!_publicChatBtn) {
        _publicChatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_publicChatBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_publicChatBtn addTarget:self action:@selector(publicChatBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self publicChatBtnResetBackGroundImage];
    }
    return _publicChatBtn;
}
#pragma mark -- 重制 _publicChatBtn 背景图片
- (void)publicChatBtnResetBackGroundImage
{
    BOOL isMute = ![[CCStreamerBasic sharedStreamer] getRoomInfo].allow_chat;
    BOOL isMuteAll = ![[CCStreamerBasic sharedStreamer] getRoomInfo].room_allow_chat;
    if (isMute || isMuteAll)
    {
        [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
        [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"mute_touch"] forState:UIControlStateHighlighted];
    } else {
        [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message-1"] forState:UIControlStateNormal];
        [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message_touch-1"] forState:UIControlStateHighlighted];
    }
}

- (UIButton *)lianMaiBtn
{
    if(!_lianMaiBtn) {
        _lianMaiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lianMaiBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        CCClassType mode = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_class_type;
        if (mode == CCClassType_Auto || mode == CCClassType_Rotate)
        {
            [self lianMaiBtnResetNormal:@"ligature" selected:@"ligature_touch" title:nil];
            _lianMaiBtn.hidden = (mode == CCClassType_Rotate);
        }
        else
        {
            [self lianMaiBtnResetNormal:@"handsup" selected:@"handsup_touch" title:nil];
        }
        _lianMaiBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        _lianMaiBtn.titleLabel.font = [UIFont systemFontOfSize:FontSizeClass_15];
        [_lianMaiBtn addTarget:self action:@selector(lianMaiBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lianMaiBtn;
}

- (void)lianMaiBtnResetNormal:(NSString *)normal selected:(NSString *)selected title:(NSString *)title
{
    [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
    [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:selected] forState:UIControlStateSelected];
    if (title && title.length != 0) {
        [_lianMaiBtn setTitle:title forState:UIControlStateNormal];
    }
}

- (UIButton *)studentSetBtn
{
    if(!_studentSetBtn) {
        _studentSetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_studentSetBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_studentSetBtn setBackgroundImage:[UIImage imageNamed:@"setvcnor.png"] forState:UIControlStateNormal];
        [_studentSetBtn setBackgroundImage:[UIImage imageNamed:@"setvc.png"] forState:UIControlStateHighlighted];
        [_studentSetBtn addTarget:self action:@selector(studentSetBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _studentSetBtn;
}
#pragma mark 弹出分辨率框
- (void)studentSetBtnClicked
{
    //跳往设置界面
    CCLiveStudentSetController *setVC = [CCLiveStudentSetController new];
    [self.navigationController pushViewController:setVC animated:YES];
}

- (UIButton *)handupBtn
{
    if(!_handupBtn) {
        _handupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_handupBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_handupBtn setBackgroundImage:[UIImage imageNamed:@"handsup"] forState:UIControlStateNormal];
        [_handupBtn setBackgroundImage:[UIImage imageNamed:@"hands"] forState:UIControlStateSelected];
        [_handupBtn addTarget:self action:@selector(handupBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _handupBtn;
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
            make.edges.mas_equalTo(ws.informationView );
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
#pragma mark 退出房间按钮
- (UIButton *)rightSettingBtn
{
    if (!_rightSettingBtn)
    {
        _rightSettingBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _rightSettingBtn.layer.cornerRadius = CCGetRealFromPt(10);
        _rightSettingBtn.layer.masksToBounds = YES;
        [_rightSettingBtn setTitle:@"" forState:UIControlStateNormal];
        [_rightSettingBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [_rightSettingBtn setBackgroundImage:[UIImage imageNamed:@"back_touch"] forState:UIControlStateHighlighted];
        [_rightSettingBtn addTarget:self action:@selector(touchSettingBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightSettingBtn;
}

#pragma mark - 添加监听和移除监听
-(void)addObserver
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveSocketEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publish) name:CCNotiNeedStartPublish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPublish) name:CCNotiNeedStopPublish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beconeUnActive) name:CCNotiNeedLoginOut object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reSub:) name:CCNotiStreamCheckNilStream object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(docChange:) name:CCNotiChangeDoc object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SDKNeedsubStream:) name:CCNotiNeedSubscriStream object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SDKNeedUnsubStream:) name:CCNotiNeedUnSubcriStream object:nil];
}

-(void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiReceiveSocketEvent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedStartPublish object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedStopPublish object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedSubscriStream object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedUnSubcriStream object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedLoginOut object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiStreamCheckNilStream object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiChangeDoc object:nil];
}

#pragma mark - 内存警告和生命周期结束
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    NSLog(@"playback dealloc-----------+++++++++++++!");
    if (self.shareScreen)
    {
        [self.shareScreen removeObserver:self forKeyPath:@"videoViewSize"];
    }
    if (self.assistantCamera) {
        [self.assistantCamera removeObserver:self forKeyPath:@"videoViewSize_ass"];
    }
    if (self.room_user_cout_timer) {
        [self.room_user_cout_timer invalidate];
        _room_user_cout_timer = nil;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(room_user_cout_timerAction) object:nil];
    }
    if (self.timerTimer)
    {
        [self.timerTimer invalidate];
        self.timerTimer = nil;
    }
}

- (void)hiddenChatView:(BOOL)hidden
{
    [self.chatView hiddenChatView:hidden];
}

#pragma mark -- 回调测试
- (void)onStartRouteOptimization
{
    NSLog(@"hhds_____001_____!");
    [self.hdsTool loadingViewShow:@"加载中" view:self.view];
    [self appUpdateUISwitch];
}
- (void)appUpdateUISwitch
{
    NSString *localStreamid = self.stremer.localStreamID;
    self.localStreamID = localStreamid;
    [self.streamView removeStreamViewAll];
}

- (void)onStudentDownMai
{
    [self.ccBarelyManager handsDown:^(BOOL result, NSError *error, id info) {
        
    }];
    //修改麦克风状态
    [self setMicStatus:0];
}
- (void)onReloadPreview
{

}
- (void)onStopRouteOptimization
{
    [self.hdsTool loadingViewDismiss];
}
- (void)switchPlatformError:(NSError *)error
{
    [self.hdsTool loadingViewDismiss];
    [self appLeaveRoom];
}
/** 学生退出直播间 */
- (void)appLeaveRoom
{
    WS(weakSelf);
    [self.loadingView removeFromSuperview];
    [self.stremer leave:^(BOOL result, NSError *error, id info) {
        NSLog(@"%s", __func__);
        [self.stremer clearData];
        [[HDSDocManager sharedDoc]hdsReleaseDoc];
        dispatch_async(dispatch_get_main_queue(), ^{
           [weakSelf.loadingView removeFromSuperview];
           [weakSelf popToScanVC];
           [CCTool showMessage:@"线路优化失败！"];
        });
    }];
}

-(CCChangeScrollBtn *)changeScrollBtn {
    if (!_changeScrollBtn) {
        _changeScrollBtn = [[CCChangeScrollBtn alloc] initWithFrame:CGRectMake(0, 60, 100, 50)];
        _changeScrollBtn.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.3];
        _changeScrollBtn.hidden = YES;
    }
    return _changeScrollBtn;
}
///显示
-(void)dragAction {
    CCRoomTemplate template = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_template;
    if (template == CCRoomTemplateSpeak && self.isLandSpace && [CCRoom shareRoomHDS].live_status == CCLiveStatus_Start) {
        
        self.changeScrollBtn.hidden = NO;
    }else {
        self.changeScrollBtn.hidden = YES;
    }
    if (self.isLandSpace) {
        [self.ccVideoView setHiddenSlider:YES];
    }else {
        
        [self.ccVideoView setHiddenSlider:NO];
    }
    [self.ccVideoView setDocEditable:NO];
}
///隐藏
-(void)paintingAction {
    self.changeScrollBtn.hidden = YES;
    [self.ccVideoView setHiddenSlider:YES];
    [self.ccVideoView setDocEditable:NO];
}
-(NSTimer *)room_user_cout_timer {
    if (!_room_user_cout_timer) {
        CCWeakProxy *weakProxy = [CCWeakProxy proxyWithTarget:self];
        _room_user_cout_timer = [NSTimer timerWithTimeInterval:5 target:weakProxy selector:@selector(room_user_cout_timerAction) userInfo:nil repeats:YES];
    }
    return _room_user_cout_timer;
}




@end
