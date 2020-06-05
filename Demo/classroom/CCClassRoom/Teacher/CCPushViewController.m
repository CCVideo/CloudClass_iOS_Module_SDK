//
//  PushViewController.m
//  NewCCDemo
//
//  Created by cc on 2016/12/2.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "CCPushViewController.h"
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
#import "CCDocViewController.h"
#import "CCStreamCheck.h"
#import "HDSDocManager.h"
#import "CCChangeScrollBtn.h"

#define infomationViewClassRoomIconLeft 3
#define infomationViewErrorwRight 9.f
#define infomationViewHandupImageViewRight 16.f
#define infomationViewHostNamelabelLeft  13.f
#define infomationViewHostNamelabelRight 0.f

@interface CCPushViewController ()
<UITextFieldDelegate,
UIActionSheetDelegate,
UIGestureRecognizerDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
HyPopMenuViewDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource,
CCDrawMenuViewDelegate,
CCStreamerBasicDelegate>
@property(nonatomic,assign)BOOL hasMessage;

@property(nonatomic,strong)CCStreamerView     *streamView;

@property(nonatomic,strong)CCStream *mixedStream;
@property(nonatomic,strong)CCStream *localStream;

@property(nonatomic,strong)UILabel              *hostNameLabel;
@property(nonatomic,strong)UILabel              *userCountLabel;
@property(nonatomic,strong)UIImageView          *informtionBackImageView;
@property(nonatomic,strong)UIImageView          *classRommIconImageView;

@property(nonatomic,strong)UIView               *informationView;
@property(nonatomic,strong)UIButton             *rightSettingBtn;
@property(nonatomic,strong)UIButton             *closeBtn;

@property(nonatomic,strong)UIButton             *publicChatBtn;
@property(nonatomic,strong)UIButton             *cameraChangeBtn;
@property(nonatomic,strong)UIButton             *micChangeBtn;
@property(nonatomic,strong)UIButton             *startPublishBtn;
@property(nonatomic,strong)UIButton             *stopPublishBtn;
@property(nonatomic,strong)UIButton             *menuBtn;
#pragma mark strong -- 开始录制
@property(nonatomic,assign)CCRecordType         liveRecordType;
@property(nonatomic,strong)UIButton             *buttonRecord;  //切麦按钮
@property(nonatomic,strong)UIActionSheet        *actionSheetCamera;
@property(nonatomic,strong)UIActionSheet        *actionSheetRecord;

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
@property (strong, nonatomic) CCDrawMenuView *drawMenuView;
#pragma mark strong
@property(nonatomic,strong)CCRoom *room;
@property(nonatomic,assign)BOOL willTeacherRewardShow;
//是否显示黑流提示
@property(nonatomic,strong)NSMutableArray *showBlackVideoArray;
@property(nonatomic,strong)CCStreamerBasic *stremer;
@property(nonatomic,strong)CCBarleyManager *ccBarelyManager;
@property(nonatomic,strong)CCDocVideoView *ccVideoView;
@property(nonatomic,strong)CCChatManager *ccChatManager;
@property(nonatomic,strong)CCStreamView *shareScreen;
@property(nonatomic,strong)CCDragView *shareScreenView;
@property(nonatomic,strong)UITapGestureRecognizer *shareScreenViewGes;
@property(nonatomic,assign)CGRect shareScreenViewOldFrame;
@property(nonatomic,strong)UIButton *windowFullScreenBtn;

@property(nonatomic,strong)HDSTool *hdsTool;

@property(nonatomic,strong)CCChangeScrollBtn *changeScrollBtn;
///是否是切换文档回来的
@property(nonatomic,assign)BOOL isChangeDoc;

@end

@implementation CCPushViewController

-(instancetype)initWithLandspace:(BOOL)landspace
{
    self = [super init];
    if(self) {
        self.isLandSpace = landspace;
        [self addObserver];
        [self initBaseSdkComponent];
    }
    return self;
}
//工具类
- (HDSTool *)hdsTool
{
    return [HDSTool sharedTool];
}

- (void)onServerDisconnected
{
    [UIAlertView bk_showAlertViewWithTitle:@"流服务连接异常" message:@"请退出直播间，重新加入直播间！" cancelButtonTitle:@"确认" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
    }];
}

#pragma mark - 生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentIsInBottom = YES;
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
    
    [self configHandupImage];
    [self loginAction];
    [self.view addSubview:self.changeScrollBtn];
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
        [[CCStreamerBasic sharedStreamer] setOrientation:UIInterfaceOrientationLandscapeRight];
        [UIApplication sharedApplication].statusBarHidden = YES;
    }
    if (!self.isChangeDoc && self.changeScrollBtn.isHidden) {
        
        [self dragAction];
    }
    self.isChangeDoc = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _willTeacherRewardShow = YES;
    [self.streamView viewDidAppear];
    
    [self notifyChangeDevicePortroit];
    [self.hdsTool updateMirrorType];
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
    [UIApplication sharedApplication].statusBarHidden = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(room_user_count) object:nil];
    [self.room_user_cout_timer invalidate];
    self.room_user_cout_timer = nil;
}
#pragma mark -- 组件化关联
- (void)initBaseSdkComponent
{
    //基础sdk
    self.stremer = [CCStreamerBasic sharedStreamer];
    [self.stremer addObserver:self];

    //排麦
    self.stremer.isUsePaiMai = YES;
    [self.stremer addObserver:self.ccBarelyManager];
    [self.ccBarelyManager addBasicClient:self.stremer];

    //初始话管理器
    HDSDocManager *hdsM = [HDSDocManager sharedDoc];
    CCDocVideoView *videoView = [hdsM hdsDocView];
    self.ccVideoView = videoView;
    
    //白板
    [self.stremer addObserver:self.ccVideoView];
    [self.ccVideoView addBasicClient:self.stremer];
    
    //聊天
    [self.stremer addObserver:self.ccChatManager];
    [self.ccChatManager addBasicClient:self.stremer];
}

-(void)setVideoParentView {
    HDSDocManager *hdsM = [HDSDocManager sharedDoc];
    [hdsM setVideoParentView:self.view];
    CGRect vfm = CGRectMake(SCREEN_WIDTH * 0.5 - 100, SCREEN_HEIGHT * 0.5 - 60, 200, 120);
    [hdsM setVideoParentViewFrame:vfm];
    [hdsM initDocEnvironment];
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

- (void)statPreview
{
    WS(weakSelf);
    [self.preview removeFromSuperview];
    self.preview  = nil;
    
    BOOL cameraFront = self.hdsTool.isCameraFront;
    [self.stremer createLocalStream:YES cameraFront:cameraFront];
    
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

#pragma mark 首先登录
- (void)loginAction
{
    [self loginSuccess];
}

//登录成功
- (void)loginSuccess
{
    [self PPTStartRender];
    [self statPreview];
    
    //判断是否要推流
    [self autoStart];
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
                [[HDSDocManager sharedDoc]beEditableCancel];
//                [self resetDocPPTFrame];
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
    if (_isLandSpace) {

        CGRect fm = CGRectMake(0, 0, width, height);
        [[HDSDocManager sharedDoc]setDocFrame:fm displayMode:2];
        self.streamView.steamSpeak.backgroundColor = [UIColor whiteColor];
    }else {
        return;
        CGRect fm = CGRectMake(0, 0, width - x_r, h_r);
//        [[HDSDocManager sharedDoc]setDocFrame:fm displayMode:1];
        [[HDSDocManager sharedDoc] refreshDocFrame:1];
        self.streamView.steamSpeak.backgroundColor = [UIColor whiteColor];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return (gestureRecognizer != self.navigationController.interactivePopGestureRecognizer);
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
            make.left.mas_equalTo(ws.streamView);
            make.right.mas_equalTo(ws.streamView);
//            make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(60));
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
        CCRoomTemplate template = [self.stremer  getRoomInfo].room_template;
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
        [self.view addSubview:self.chatView];
        [self.contentBtnView addSubview:self.publicChatBtn];
        [self.contentBtnView addSubview:self.cameraChangeBtn];
        [self.contentBtnView addSubview:self.micChangeBtn];
        [self.contentBtnView addSubview:self.menuBtn];
        [self.contentBtnView addSubview:self.startPublishBtn];
        [self.contentBtnView addSubview:self.stopPublishBtn];
        [self.contentBtnView addSubview:self.buttonRecord];

        self.cameraChangeBtn.hidden = YES;
        self.micChangeBtn.hidden = YES;
        self.stopPublishBtn.hidden = YES;
        self.startPublishBtn.hidden = NO;
        self.buttonRecord.hidden = YES;

        [_contentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.streamView);
            make.bottom.mas_equalTo(ws.streamView);
            make.height.mas_equalTo(CCGetRealFromPt(130));
        }];
        
        float oneWidth = [UIImage imageNamed:@"message"].size.width;
        CGFloat width = self.isLandSpace ? MAX(self.view.frame.size.width, self.view.frame.size.height) : MIN(self.view.frame.size.width, self.view.frame.size.height);
        float all = width - 6*oneWidth;
        float oneDel = all/7.f;
        
        [_publicChatBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.contentBtnView).offset(oneDel);
            make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
        }];
        
        [_cameraChangeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.publicChatBtn.mas_right).offset(oneDel);
            make.bottom.mas_equalTo(ws.publicChatBtn);
        }];
        
        [_startPublishBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
            make.centerX.mas_equalTo(ws.contentBtnView);
        }];
        [_stopPublishBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
            make.centerX.mas_equalTo(ws.contentBtnView);
        }];
        
        float oneWidthRD = [UIImage imageNamed:@"start"].size.width;
        [_buttonRecord mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
            make.right.mas_equalTo(ws.micChangeBtn.mas_left).offset(-oneDel);
            make.width.mas_equalTo(oneWidthRD);
        }];

        [_menuBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.contentBtnView).offset(-oneDel);
            make.bottom.mas_equalTo(ws.publicChatBtn);
        }];
        
        [_micChangeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.menuBtn.mas_left).offset(-oneDel);
            make.bottom.mas_equalTo(ws.publicChatBtn);
        }];
        
        [_chatView mas_remakeConstraints:^(MASConstraintMaker *make) {
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

#pragma mark - auto start - 进入房间处理是否推流
- (void)autoStart
{
    BOOL hasAssistant = self.room.room_assist_on;
    if (hasAssistant)
    {
        [self first_start_no_assistant];
#pragma mark -- HDS_MARK___MODIFY
        //暂时不处理助教角色--20200403
//        [self first_start_has_assistant];
    }
    else
    {
        [self first_start_no_assistant];
    }
}
#pragma mark -- Room Condition 1
#pragma mark -- 房间没有助教
- (void)first_start_no_assistant
{
    if (self.room.room_manual_record)
    {
        [self room_hand_record_not_assistant_not];
#pragma mark -- HDS_MARK___MODIFY
        //暂时不处理助教角色--20200403
//        [self room_hand_record_assistant_not];
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
            BOOL withRecord = (buttonIndex ==  1) ? YES : NO;

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
                        [weakSelf recordChangeButtonUITo:CCRecordType_Start];
                    }
                    //这里没有更新publish以及更新麦序
                    [self.stremer publish:^(BOOL result, NSError *error, id info) {
                        if (result) {
                            [self.ccBarelyManager updateUserState:weakSelf.room.user_id roomID:nil publishResult:YES streamID:weakSelf.stremer.localStreamID completion:^(BOOL result, NSError *error, id info) {
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
                                }else {
                                    //调整展示ppt
                                    [self updateSwitchSuccess];
                                    if (self.isLandSpace && [self.ccVideoView docCurrentPPT].docID == nil)
                                    {
                                        //将菜单栏切到白板
                                        [self drawMenuView1:NO];
                                    }else if(self.isLandSpace && [self.ccVideoView docCurrentPPT].docID != nil){
                                        self.streamView.steamSpeak.nowDoc = [self.ccVideoView docCurrentPPT];
                                        self.streamView.steamSpeak.nowDocpage = [self.ccVideoView docCurrentPage] + 1;
                                        [self drawMenuView1:YES];
                                    }
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

#pragma mark -- Room Condition 2
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
        WS(weakSelf);
        [UIAlertView bk_showAlertViewWithTitle:@"注意" message:KKEY_open_recording cancelButtonTitle:KKEY_cancel otherButtonTitles:@[KKEY_open] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1)
            {
                [self.stremer startLiveWithRecord:YES completion:^(BOOL result, NSError *error, id info) {
                    [self.stremer publish:^(BOOL result, NSError *error, id info) {
                          //模拟麦序更新失败的情况
                          [self.ccBarelyManager updateUserState:self.room.user_id roomID:nil publishResult:YES streamID:weakSelf.stremer.localStreamID completion:^(BOOL result, NSError *error, id info) {
                                  if (!result)
                                  {
                                      [CCTool showMessageError:error];
                                  }else {
                                      [self updateSwitchSuccess];
                                      if (self.isLandSpace && [self.ccVideoView docCurrentPPT].docID == nil)
                                      {
                                          //将菜单栏切到白板
                                          [self drawMenuView1:NO];
                                      }else if(self.isLandSpace && [self.ccVideoView docCurrentPPT].docID != nil){
                                          self.streamView.steamSpeak.nowDoc = [self.ccVideoView docCurrentPPT];
                                          self.streamView.steamSpeak.nowDocpage = [self.ccVideoView docCurrentPage] + 1;
                                          [self drawMenuView1:YES];
                                      }
                                  }
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

#pragma mark -- 开始直播
- (void)startPublishBtnClicked
{
//    self.stremer.localStreamID = nil;
    if (self.room.room_manual_record)
    {
        [self startPublishHandRecord];
    }
    else
    {
        [self startPublishHandRecordNot];
    }
}

//开启手动录制
- (void)startPublishHandRecord
{
    WS(weakSelf);
    [UIAlertView bk_showAlertViewWithTitle:KKEY_tips_title message:KKEY_open_recording cancelButtonTitle:KKEY_cancel otherButtonTitles:@[KKEY_open] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        _loadingView = [[LoadingView alloc] initWithLabel:KKEY_loading];
        [self.view addSubview:_loadingView];
        
        [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        BOOL withRecord = NO;//是否开启录制
        if (buttonIndex == 1)
        {
            withRecord = YES;
        }
        else
        {
            withRecord = NO;
        }
        //是否开启直播，返回值都是
        [self.stremer startLiveWithRecord:withRecord completion:^(BOOL result, NSError *error, id info) {
            if (result)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf handRecordPublishStartResetUI:YES];
                    [weakSelf.loadingView removeFromSuperview];
                });
                if (withRecord)
                {
                    [weakSelf recordChangeButtonUITo:CCRecordType_Start];
                }
               //还有什么方式获取streamID
                [self.stremer publish:^(BOOL result, NSError *error, id info) {
                    if (result) {
                        [self.ccBarelyManager updateUserState:weakSelf.room.user_id roomID:nil publishResult:YES streamID:self.stremer.localStreamID  completion:^(BOOL result, NSError *error, id info) {
                            if (!result)
                            {
                                [CCTool showMessage:@"老师推流成功，麦序更新失败！"];
                            }else {
                                [self updateSwitchSuccess];
                                if (self.isLandSpace && [self.ccVideoView docCurrentPPT].docID == nil)
                                {
                                    //将菜单栏切到白板
                                    [self drawMenuView1:NO];
                                }else if(self.isLandSpace && [self.ccVideoView docCurrentPPT].docID != nil){
                                    self.streamView.steamSpeak.nowDoc = [self.ccVideoView docCurrentPPT];
                                    self.streamView.steamSpeak.nowDocpage = [self.ccVideoView docCurrentPage] + 1;
                                    [self drawMenuView1:YES];
                                }
                            }
                        }];
                    }else{
                        [weakSelf publishRetry];
                    }
                }];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.loadingView removeFromSuperview];
                    NSLog(@"publish error:%@", error);
                    [weakSelf publishRetry];
                });
            }
        }];
    }];
}
//未开启手动录制
- (void)startPublishHandRecordNot
{
    [self startPublish];
}

#pragma mark 开始推流  开始直播
- (void)startPublish
{
//    开始推流
    _loadingView = [[LoadingView alloc] initWithLabel:@"请稍候..."];
    [self.view addSubview:_loadingView];
    [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    CCLiveStatus status = [self.stremer  getRoomInfo].live_status;
    __weak typeof(self) weakSelf = self;
    if (status == CCLiveStatus_Stop)
    {
        [self.stremer startLive:^(BOOL result, NSError *error, id info) {
            if (result) {
                [self.stremer publish:^(BOOL result, NSError *error, id info) {
                    if (result) {
                        [self.ccBarelyManager updateUserState:weakSelf.room.user_id roomID:nil publishResult:YES streamID:weakSelf.stremer.localStreamID completion:^(BOOL result, NSError *error, id info) {
                            if (!result)
                            {
                                [CCTool showMessage:@"老师推流成功，麦序更新失败！"];
                            }
                        }];
                        [[HDSDocManager sharedDoc] skipDoc];
                        [weakSelf.loadingView removeFromSuperview];
                        [[NSUserDefaults standardUserDefaults] setObject:info forKey:@"streamID"];
                    }else{
                        [weakSelf.loadingView removeFromSuperview];
                        [UIAlertView bk_showAlertViewWithTitle:@"注意" message:@"老师推流失败" cancelButtonTitle:@"取消" otherButtonTitles:@[@"重试"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                            if (buttonIndex == 1)
                            {
                                [self rePublish];
                            }
                            else
                            {
                                [self stopPublish];
                            }
                        }];
                    }
                }];
            }else{
                [weakSelf.loadingView removeFromSuperview];
                [UIAlertView bk_showAlertViewWithTitle:@"注意" message:@"老师开启直播失败" cancelButtonTitle:@"取消" otherButtonTitles:@[@"重试"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 1)
                    {
                        [self startPublish];
                    }
                    else
                    {
                        [self unPublish];
                    }
                }];
            }
        }];
    }
    else
    {
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
                            [self.ccBarelyManager updateUserState:weakSelf.room.user_id roomID:nil publishResult:YES streamID:weakSelf.stremer.localStreamID completion:^(BOOL result, NSError *error, id info) {
                                if (!result)
                                {
                                    [CCTool showMessage:@"老师推流成功，麦序更新失败！"];
                                }else {
                                    [self updateSwitchSuccess];
                                    //调整展示ppt
                                    if (self.isLandSpace && [self.ccVideoView docCurrentPPT].docID == nil)
                                    {
                                        //将菜单栏切到白板
                                        [self drawMenuView1:NO];
                                    }else if(self.isLandSpace && [self.ccVideoView docCurrentPPT].docID != nil){
                                        self.streamView.steamSpeak.nowDoc = [self.ccVideoView docCurrentPPT];
                                        self.streamView.steamSpeak.nowDocpage = [self.ccVideoView docCurrentPage] + 1;
                                        [self drawMenuView1:YES];
                                    }
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

- (void)publishDirectly
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
    if (status == CCLiveStatus_Start)
    {
        [self.stremer  startLive:^(BOOL result, NSError *error, id info) {
            if (result)
            {
                NSLog(@"%s", __func__);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf handRecordPublishStartResetUI:YES];
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.loadingView removeFromSuperview];
            });
        }];
    }
}

- (void)publishDirectlyWithUnPublish
{
    [self.stremer unPublish:^(BOOL result, NSError *error, id info) {
        _loadingView = [[LoadingView alloc] initWithLabel:@"请稍候..."];
        [self.view addSubview:_loadingView];
        [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        CCLiveStatus status = [self.stremer  getRoomInfo].live_status;
        __weak typeof(self) weakSelf = self;
        if (status == CCLiveStatus_Start)
        {
            [self.stremer  startLive:^(BOOL result, NSError *error, id info) {
                if (result)
                {
                    NSLog(@"%s", __func__);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf handRecordPublishStartResetUI:YES];
                    });
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_loadingView removeFromSuperview];
                });
            }];
        }
    }];
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

- (void)touchInfoMationView
{
    //跳往成员列表
    CCMemberTableViewController *memberVC = [[CCMemberTableViewController alloc] init];
    memberVC.ccDocVideoView = self.ccVideoView;
    [self pushController:memberVC animation:YES];
}

- (void)touchSettingBtn
{
    //跳往设置界面
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    CCLiveSettingViewController *settingVC = [story instantiateViewControllerWithIdentifier:@"live_setting"];
    [self pushController:settingVC animation:YES];
}

- (void)pushController:(UIViewController *)vc animation:(BOOL)animation
{
    main_async_safe(^{
        [self.navigationController pushViewController:vc animated:animation];
    });
}

-(CCStreamerView *)streamView {
    if(!_streamView) {
        _streamView = [CCStreamerView new];
        CCRoomTemplate template = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_template;
        _streamView.showVC = self.navigationController;
        _streamView.isLandSpace = self.isLandSpace;
        if (template == CCRoomTemplateSpeak) {
            [self drawMenuView1:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Page|CCDragStyle_Full];
        }
        if (self.isLandSpace && template == CCRoomTemplateSpeak)
        {
            self.hideVideoBtn.hidden = NO;
            self.drawMenuView.hidden = NO;
            [_streamView disableTapGes:NO];
            [self dragAction];
        }
        else
        {
            self.hideVideoBtn.hidden = YES;
            self.drawMenuView.hidden = YES;
            [_streamView disableTapGes:YES];
            [self paintingAction];
        }
        [_streamView configWithMode:template role:CCRole_Teacher];
    }
    return _streamView;
}

-(void)viewPress
{
    [_chatTextField resignFirstResponder];
}

-(void)publicChatBtnClicked
{
    [_chatTextField becomeFirstResponder];
}

#pragma mark 切换摄像头
-(void)cameraChangeBtnClicked
{
    if (_cameraChangeBtn.selected)
    {
        [self.stremer setVideoOpened:YES userID:nil];
        _cameraChangeBtn.selected = !_cameraChangeBtn.selected;
    }
    else
    {
        [self.stremer setVideoOpened:NO userID:nil];
        _cameraChangeBtn.selected = !_cameraChangeBtn.selected;
    }
}

#pragma maark 关麦
-(void)micChangeBtnClicked
{
    NSString *uid = self.room.user_id;
    _micChangeBtn.selected = !_micChangeBtn.selected;
    WS(weakSelf);
    BOOL audioOpen = !_micChangeBtn.selected;
    [HDSTool mediaSwitchUserid:uid state:audioOpen role:CCRole_Teacher response:^(BOOL result, id  _Nullable info, NSError * _Nullable error) {
        if (result)
        {
            [weakSelf.stremer setAudioOpened:audioOpen userID:nil];
        } else {
            _micChangeBtn.selected = !_micChangeBtn.selected;
            [CCTool showMessage:error.domain];
        }
    }];
}

#pragma mark 结束直播事件，下麦也要更新麦序
-(void)stopPublishBtnClick
{
    [UIAlertView bk_showAlertViewWithTitle:@"注意" message:@"是否确认结束直播" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1)
        {
            [self unPublish];
        }
    }];
}

-(void)unPublish
{
    __weak typeof(self) weakSelf = self;
    _loadingView = [[LoadingView alloc] initWithLabel:@"请稍候..."];
    [self.view addSubview:_loadingView];
    [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.stremer unPublish:^(BOOL result, NSError *error, id info) {
            if (result) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.stremer stopLive:^(BOOL result, NSError *error, id info) {
                        [_loadingView removeFromSuperview];
                        if (result)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf publishEndResetUI];
                                [weakSelf.streamView removeStreamView:self.preview];
                                [weakSelf statPreview];
                            });
                        }
                    }];
                });
            }else {
                [_loadingView removeFromSuperview];
                [CCTool showMessageError:error];
            }
        }];
}

-(void)closeBtnClicked
{
    CCUser *userCopy = [CCTool tool_room_user_role:CCRole_Assistant];
    if (userCopy)
    {
        [self closeBtnClickedWithAssistant]; //助教在房间内
    }
    else
    {
        [self closeBtnClickedWithAssistantNone]; //没有助教在房间内
    }
}
//关闭按钮，离开房间
#pragma mark 右上角的按钮离开房间
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
            [[HDSDocManager sharedDoc] clearAllDrawData];
            [[HDSDocManager sharedDoc] hdsReleaseDoc];//清空文档
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            dispatch_async(dispatch_get_main_queue(),^{
                if (weakSelf.startPublishBtn.hidden)
                {
                    //1、停止推流
                    [self.stremer unPublish:^(BOOL result, NSError *error, id info) {
                        if (result) {
                            //2、停止直播
                            [self.stremer stopLive:^(BOOL result, NSError *error, id info) {
                                if (result)
                                {
                                    //3、退出房间
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.stremer leave:^(BOOL result, NSError *error, id info) {
                                        if (result) {
                                            [weakSelf.loadingView removeFromSuperview];
                                            [weakSelf popToScanVC];
                                            
                                        }else {
                                            [_loadingView removeFromSuperview];
                                            [CCTool showMessageError:error];
                                        }
                                    }];
                                  });
                                }else {
                                    [_loadingView removeFromSuperview];
                                    [CCTool showMessageError:error];
                                }
                            }];
                        }else {
                            ///停止推流失败
                            [_loadingView removeFromSuperview];
                            [CCTool showMessageError:error];
                            
                        }
                  }];
                }
                else
                {
                    [weakSelf.loadingView removeFromSuperview];
                    [self.stremer leave:^(BOOL result, NSError *error, id info) {
                        NSLog(@"%s", __func__);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.loadingView removeFromSuperview];
                            [weakSelf popToScanVC];
                        });
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
            [[HDSDocManager sharedDoc] hdsReleaseDoc];//清空文本
            dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 10*NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^{
                [weakSelf popToScanVC];
            });
            
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                if (weakSelf.startPublishBtn.hidden)
                {
                    [self.stremer unPublish:^(BOOL result, NSError *error, id info) {
                            [self.stremer  leave:^(BOOL result, NSError *error, id info) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [weakSelf.loadingView removeFromSuperview];
                                    [weakSelf popToScanVC];
                                });
                            }];
                    }];
                }
                else
                {
                    [self.stremer  leave:^(BOOL result, NSError *error, id info) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.loadingView removeFromSuperview];
                        [weakSelf popToScanVC];
                        });
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

//主视频模式跟随，老师切换视频  找不到方法
- (void)clickFllowBtn:(UIButton *)btn
{
    NSString *fllowStreamID = [self.stremer  getRoomInfo].teacherFllowUserID;
    btn.enabled = NO;
    if (fllowStreamID.length != 0)
    {
        //关闭
        [self.ccBarelyManager  changeMainStreamInSigleTemplate:@"" completion:^(BOOL result, NSError *error, id info) {
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
            NSArray *userList = [self.stremer  getRoomInfo].room_userList;
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
    _chatTextField.text = nil;
    [_chatTextField resignFirstResponder];
}

-(void)sendPicBtnClicked {
    [_chatTextField resignFirstResponder];
    NSLog(@"thrend-----:%@",[NSThread currentThread]);
    NSLog(@"thrend-----:%d",[NSThread isMainThread]);

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
    CCClassType mode = [self.stremer  getRoomInfo].room_class_type;
    if (mode == CCClassType_Auto)
    {
        [self setHandupImageHidden:YES];
    }
    else if(mode == CCClassType_Rotate)
    {
        //点名连麦
        NSArray *dic = [self.stremer  getRoomInfo].room_userList;
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
        NSArray *dic = [self.stremer  getRoomInfo].room_userList;
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

- (void)hideVideoBtnClicked:(UIButton *)btn
{
    btn.selected = !btn.selected;
    [self.streamView hideOrShowVideo:btn.selected];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self chatSendMessage];
    return YES;
}

-(void)chatSendMessage {
    NSString *str = _chatTextField.text;
    if(str == nil || str.length == 0)
    {
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
    NSLog(@"发送的聊天信息为：%@",str);
    [self.ccChatManager sendMsg:str];
}

- (void)getProWithDocID:(NSNotification *)noti
{
    NSString *docID = [noti.userInfo objectForKey:@"docID"];
    [self proWithDocID:docID];
}

//成功上传了但是并没有成功刷新，导致图片一直出不来。
- (void)proWithDocID:(NSString *)docID{
    WS(ws);
    [self.ccVideoView getRelatedRoomDocs:nil userID:nil docID:docID docName:nil pageNumber:0 pageSize:0 completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSString *result = [info objectForKey:@"result"];
            
            if (![result isEqualToString:@"OK"])
            {
                return ;
            }
            int status = [[info[@"docs"] lastObject][@"status"] intValue];
            if (status == 1)

            {
                [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiUploadFileProgress object:nil userInfo:@{@"pro":@(2)}];
                NSDictionary *dic = info;
                NSString *picDomain = [dic objectForKey:@"picDomain"];
                NSArray *docArr = dic[@"docs"];
                NSDictionary *doc = [docArr lastObject];
                CCDoc *newDoc = [[CCDoc alloc] initWithDic:doc picDomain:picDomain];
                [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiChangeDoc object:nil userInfo:@{@"value":newDoc, @"page":@(0)}];
            }
            //-2: 未上传  -1:上传失败  0: 上传成功 1: 转换成功 2: 转换中 3: 转换失败
            else if (status == -2 || status == -1 || status == 0 || status == 2 || status == 3)
            {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    sleep(0.5f);
                    [ws proWithDocID:docID];
                });
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiUploadFileProgress object:nil userInfo:@{@"pro":@(2)}];
            }
        }
    }];
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
        self.contentBtnView.hidden = YES;
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
    
    [_chatView mas_remakeConstraints:^(MASConstraintMaker *make) {
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
    [self.chatView chatReceiveChatMessage:dic];
}

- (void)room_user_count
{
    [self.stremer updateUserCount];
}

- (void)room_customMessage:(NSDictionary *)dic
{
    /*
     action = release(表示需要显示的公告) remove(表示清除公告);
     announcement = sfjsdjflsdkjf(内容);
     */
    NSLog(@"%s --%@", __func__, dic);
}
#pragma mark - 通知事件
- (void)receiveSocketEvent:(NSNotification *)noti
{
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    NSLog(@"接到的通知：%@",noti);
    id value = noti.userInfo[@"value"];
    if (event == CCSocketEvent_UserListUpdate)
    {
        //房间列表
        NSInteger str = [self.stremer  getRoomInfo].room_user_count;
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
    else if (event == CCSocketEvent_MediaModeUpdate)
    {
        CCVideoMode micType = [self.stremer  getRoomInfo].room_video_mode;
        [self.streamView roomMediaModeUpdate:micType];
    }
    else if (event == CCSocketEvent_VideoStateChanged)
    {
        CCUser *user = noti.userInfo[@"user"];
        [self.streamView streamView:user.user_id videoOpened:user.user_videoState];
    }
    else if (event == CCSocketEvent_AudioStateChanged || event == CCSocketEvent_ReciveAnssistantChange)
    {
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
//        NSDictionary *list = [self.stremer  getNamedInfo];
//        NSLog(@"%s__%@", __func__, list);
    }
    else if (event == CCSocketEvent_StudentNamed)
    {
//        NSArray *list = [self.stremer  getStudentNamedList];
//        NSLog(@"%s__%@", __func__, list);
    }
    else if (event == CCSocketEvent_LianmaiStateUpdate || event == CCSocketEvent_LianmaiModeChanged || event == CCSocketEvent_HandupStateChanged)
    {
        [self configHandupImage];
        //隐藏的导航栏出现
        [self.streamView showMenuBtn];
    }
    else if (event == CCSocketEvent_SocketReconnectedFailed)
    {
        __weak typeof(self) weakSelf = self;
        _loadingView = [[LoadingView alloc] initWithLabel:@"正在关闭直播间..."];
        [weakSelf.view addSubview:_loadingView];
        [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        [weakSelf removeObserver];
        [UIAlertView bk_showAlertViewWithTitle:@"" message:@"网络太差" cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.stremer  leave:^(BOOL result, NSError *error, id info) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                [weakSelf.loadingView removeFromSuperview];
                SaveToUserDefaults(DOC_DOCID, nil);
                SaveToUserDefaults(DOC_DOCPAGE, @(-1));
                SaveToUserDefaults(DOC_ROOMID, nil);
                [weakSelf popToScanVC];
                });
            }];
        }];
    }
    else if (event == CCSocketEvent_TemplateChanged)
    {
//        CCRoomTemplate template = (CCRoomTemplate)[[noti.userInfo objectForKey:@"value"] integerValue];
//        [self.streamView configWithMode:template role:CCRole_Teacher];
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
        NSString *followID = [self.stremer  getRoomInfo].teacherFllowUserID;
        _fllowBtn.selected = followID.length == 0 ? NO : YES;
    }
    else if (event == CCSocketEvent_StreamRemoved)
    {
        __weak typeof(self) weakSelf = self;
        _loadingView = [[LoadingView alloc] initWithLabel:@"正在关闭直播间..."];
        [weakSelf.view addSubview:_loadingView];
        [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        [weakSelf removeObserver];
        [UIAlertView bk_showAlertViewWithTitle:@"" message:@"流断开了" cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.stremer  leave:^(BOOL result, NSError *error, id info) {
                dispatch_sync(dispatch_get_main_queue(), ^{
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
    else if (event == CCSocketEvent_PublishStart)
    {
        [[HDSDocManager sharedDoc] clearAllDrawViews];
        [[HDSDocManager sharedDoc] skipDoc];
        CCRoomTemplate template = [self.stremer  getRoomInfo].room_template;
        if (self.isLandSpace && template == CCRoomTemplateSpeak)
        {
            self.hideVideoBtn.hidden = NO;
            [[HDSDocManager sharedDoc] beAuthDraw];
            [self.streamView disableTapGes:NO];
            
        }
        else
        {
            self.hideVideoBtn.hidden = YES;
        }
        [self handRecordPublishStartResetUI:YES];
        if (self.isLandSpace && [self.ccVideoView docCurrentPPT].docID == nil)
        {
            //将菜单栏切到白板
            [self drawMenuView1:NO];
        }else if(self.isLandSpace && self.streamView.steamSpeak.nowDoc.docID != nil){
            self.streamView.steamSpeak.nowDocpage = [self.ccVideoView docCurrentPage] + 1;
            [self drawMenuView1:YES];
        }
    }
    else if (event == CCSocketEvent_PublishEnd)
    {
        //清理文档数据变为白板
        [[HDSDocManager sharedDoc] clearAllDrawViews];
        self.hideVideoBtn.hidden = YES;
        self.hideVideoBtn.selected = NO;
        [self.streamView hideOrShowVideo:NO];
        [self publishEndResetUI];
        [_changeScrollBtn removeFromSuperview];
        _changeScrollBtn = nil;
        [self.view addSubview:self.changeScrollBtn];
        [self dragAction];
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
        NSLog(@"nofity---:%@",noti);
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
    else if (event == CCSocketEvent_Cup)
    {
        [self rewardTeacherCup:value];
    }
    else if (event == CCSocketEvent_Flower)
    {
        [self rewardTeacherFlower:value];
    }
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
    [[CCRewardView shareReward]showRole:type user:user withTarget:self isTeacher:YES];
}

- (void)beconeUnActive
{
    NSLog(@"%s", __func__);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self popToScanVC];
    });
}

#pragma mark - 关闭视频方法失败
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == _actionSheetCamera)
    {
        if (buttonIndex == 0)
        {
            _cameraChangeBtn.selected = !_cameraChangeBtn.selected;
            [self.stremer setVideoOpened:YES userID:nil];
            return;
            //切换摄像头
            if ([GetFromUserDefaults(SET_CAMERA_DIRECTION) isEqualToString:@"前置摄像头"])
            {
                SaveToUserDefaults(SET_CAMERA_DIRECTION, @"后置摄像头");
            }
            else
            {
                SaveToUserDefaults(SET_CAMERA_DIRECTION, @"前置摄像头");
            }
        }
        else if(buttonIndex == 1)
        {
            _cameraChangeBtn.selected = !_cameraChangeBtn.selected;
            [self.stremer  setVideoOpened:NO userID:nil];
        }
    }
    if (actionSheet == _actionSheetRecord)
    {
        if (self.liveRecordType == CCRecordType_Start || self.liveRecordType == CCRecordType_Resume)
        {
            if (buttonIndex == 0) //暂停录制
            {
                [self recordChangeToType:CCRecordType_Pause];
            }
            if (buttonIndex == 1) //停止录制
            {
                [self recordChangeToType:CCRecordType_End];
            }
        }
        if (self.liveRecordType == CCRecordType_Pause)
        {
            if (buttonIndex == 0) //继续录制
            {
                [self recordChangeToType:CCRecordType_Resume];
            }
            if (buttonIndex == 1) //停止录制
            {
                [self recordChangeToType:CCRecordType_End];
            }
        }
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    
}

#pragma mark - 1.2
- (void)showMenu
{
    //文档库
     _menu = [HyPopMenuView sharedPopMenuManager];
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

    CCRoomTemplate template = [self.stremer  getRoomInfo].room_template;
    //布局切换
    
//    if (template == CCRoomTemplateSpeak)
//    {
//        _menu.dataSource = @[ model, model1, model2, model4,model5];
//    }
//    else
//    {
//        _menu.dataSource = @[ model2, model4,model5];
//    }
     
    //不包含切麦功能
    if (template == CCRoomTemplateSpeak)
    {
        _menu.dataSource = @[ model, model1, model2, model4];
    }
    else
    {
        _menu.dataSource = @[ model2, model4];
    }
    _menu.delegate = self;
    _menu.popMenuSpeed = 12.0f;
    _menu.automaticIdentificationColor = false;
    _menu.animationType = HyPopMenuViewAnimationTypeCenter;
    _menu.backgroundType = HyPopMenuViewBackgroundTypeDarkBlur;
    _menu.column = self.isLandSpace ? 2 : 2;
    [_menu openMenu];
}

#pragma 上传图片
- (void)popMenuView:(HyPopMenuView*)popMenuView didSelectItemAtIndex:(NSUInteger)index
{
    NSLog(@"%s__%lu", __func__, (unsigned long)index);
    CCRoomTemplate template = [self.stremer  getRoomInfo].room_template;
    if (template != CCRoomTemplateSpeak)
    {
        index += 2;
    }
    switch (index) {
            //文档库
        case CCSetType_Documents:
        {
            [self set_documents];
        }
            break;
            //图片
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
    [self pushController:settingVC animation:YES];
}

#pragma mark 上传图片操作
- (void)set_uploadImage
{
    if (!self.uploadFile)
    {
        self.uploadFile = [CCUploadFile new];
        self.uploadFile.isLandSpace = self.isLandSpace;
    }
    WS(ws);
    //这里上传的是图片信息
    [self.uploadFile uploadImage:self.navigationController roomID:self.roomID completion:^(BOOL result) {
        ws.uploadFile = nil;
        if (!result)
        {
            [UIAlertView bk_showAlertViewWithTitle:@"" message:@"正在上传图片，请稍候操作" cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            }];
        }else{
            [CCTool showMessage:@"上传图片成功"];
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
        [self pushController:vc animation:YES];
    }
    else
    {
        CCSignViewController *settingVC = [story instantiateViewControllerWithIdentifier:@"SignIn"];
        settingVC.isLandSpace = self.isLandSpace;
        [self pushController:settingVC animation:YES];
    }
}
- (void)set_set
{
    //设置
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    CCLiveSettingViewController *settingVC = [story instantiateViewControllerWithIdentifier:@"live_setting"];
    [self pushController:settingVC animation:YES];
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
    [self pushController:settingVC animation:YES];
}

#pragma mark - send Pic
- (void)selectImage
{
    WS(ws)
    [HDSTool photoLibraryAuth:^(BOOL result, NSDictionary * _Nullable info, NSError * _Nullable error) {
        if (result) {
            [ws pickImage];
        } else {
            [ws pushPhotoLibrary];
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
    if (self.isLandSpace)
    {
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appdelegate.shouldNeedLandscape = NO;
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
    }
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
    [self.navigationController presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)notifyChangeDevicePortroit
{
    float timeDelay = 0.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.isLandSpace)
        {
            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            appdelegate.shouldNeedLandscape = YES;
            NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
            [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
            [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
        }
    });
}

#pragma mark - 点击头像放大
#define ACTIONVIEWH 120
#define ACTIONVIEWTAG 2001
/*
 这里不放大的原因是，userID都不匹配，主要是通知传值的userID不对。
 */
- (void)receiveClickNoti:(NSNotification *)noti
{
    NSString *type = [noti.userInfo objectForKey:@"type"];
    NSString *userID = [noti.userInfo objectForKey:@"userID"];
    self.movieClickIndexPath = [noti.userInfo objectForKey:@"indexPath"];
    for (CCUser *user in self.stremer.getRoomInfo.room_userList)
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
{
    NSMutableArray *data = [NSMutableArray array];
    //1、判断视频是否开启
    if (user.user_videoState)
    {
        [data addObject:@{@"image":@"action_closecamera", @"text":@"关闭视频", @"type":@(0)}];
    }
    else
    {
        [data addObject:@{@"image":@"action_opencamera", @"text":@"开放视频", @"type":@(1)}];
    }
    //2、判断饮品是否开启
    if (user.user_audioState)
    {
        [data addObject:@{@"image":@"action_closemicrophone", @"text":@"关麦", @"type":@(2)}];
    }
    else
    {
        [data addObject:@{@"image":@"action_openmicrophone", @"text":@"开麦", @"type":@(3)}];
    }
    //3、如果是助教 或者 教师，则只有：麦克风、摄像头、踢下麦  0&4
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
    //返回底部的操作选项，data，用于显示在collection中
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
        collectionView.backgroundColor = [UIColor yellowColor];
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

#pragma mark 点击底部弹出框，进行操作
- (void)mediaSwitchAudio:(NSString *)uid state:(BOOL)open
{
    WS(weakSelf);
    [HDSTool mediaSwitchUserid:uid state:open role:CCRole_Student response:^(BOOL result, id  _Nullable info, NSError * _Nullable error) {
        if (result)
        {
            [weakSelf.stremer setAudioOpened:open userID:uid];
        } else {
            [CCTool  showMessage:error.domain];
        }
    }];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger type = [[self.actionData[indexPath.item] objectForKey:@"type"] integerValue];
    NSString *userid = self.movieClickUser.user_id;
    switch (type) {
        case 0://关闭视频
        {
            [self.stremer  setVideoOpened:NO userID:userid];
        }
            break;
        case 1://开启视频
        {
            [self.stremer  setVideoOpened:YES userID:userid];
        }
            break;
        case 2:
        {
            //关麦
            [self mediaSwitchAudio:userid state:NO];
            break;
        }
            break;
        case 3:
        {
            //开麦
            [self mediaSwitchAudio:userid state:YES];
            break;
        }
            break;
        case 4:
        {
            //轮播模式解锁用户
            [self.ccBarelyManager rotateUnLockUser:userid completion:^(BOOL result, NSError *error, id info) {
            }];
        }
            break;
        case 5:
        {
            //轮播模式锁定用户
            [self.ccBarelyManager  rotateLockUser:userid completion:^(BOOL result, NSError *error, id info) {
            }];
        }
            break;
        case 6:
        {
            //取消对某个学生的标注功能
              [self.ccVideoView cancleAuthUserDraw:userid];
        }
            break;
        case 7:
        {
            //授权学生的标注功能  user_uid
               [self.ccVideoView authUserDraw:userid];
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
                CCRole roleNow = self.movieClickUser.user_role;
                if (roleNow == CCRole_Assistant)
                {
                    //助教下麦  
                    [[CCBarleyManager sharedBarley] assistDM:self.movieClickUser completion:^(BOOL result, NSError *error, id info) {
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
                   [self.ccBarelyManager kickUserFromSpeak:userid completion:^(BOOL result, NSError *error, id info) {
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
            [self.ccVideoView cancleAuthUserAsTeacher:userid];
        }
            break;
        case 12:
        {
            [self.ccVideoView authUserAsTeacher:userid];
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
    NSString *sid = [self.stremer getRoomInfo].user_id;
    [self.stremer rewardUid:uid uName:uname type:typeF sender:sid];
}
#pragma mark - draw加载图片
- (CCDrawMenuView *)drawMenuView1:(BOOL)showPageChange
{
    if (_drawMenuView)
    {
        _drawMenuView.delegate = nil;
        [_drawMenuView removeFromSuperview];
        _drawMenuView = nil;
    }
    //房间模式不匹配，则不展示文档翻页
    CCRoom *room = [self room];
    if (room.room_template != CCRoomTemplateSpeak) {
        return nil;
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_drawMenuView bringSubviewToFront:self.view];
        });
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

//
- (void)drawBtnClicked:(UIButton *)btn
{    
    [[HDSDocManager sharedDoc] beAuthDraw];
}

- (void)frontBtnClicked:(UIButton *)btn
{
    //撤销
    [[HDSDocManager sharedDoc] revokeDrawLast];
}

- (void)cleanBtnClicked:(UIButton *)btn
{
    [[HDSDocManager sharedDoc] revokeDrawAll];
}

- (void)pageFrontBtnClicked:(UIButton *)btn
{
    [self.streamView clickFront:nil];
}

- (void)pageBackBtnClicked:(UIButton *)btn
{
    [self.streamView clickBack:nil];
}

- (void)menuBtnClicked:(UIButton *)btn
{
    //显示操作栏
    [self.streamView hideOrShowView:YES];
}

- (void)docPageChange
{
    NSString *textPN = [NSString stringWithFormat:@"%@ / %@", @(self.streamView.steamSpeak.nowDocpage+1), @(self.streamView.steamSpeak.nowDoc.pageSize)];
    self.drawMenuView.pageLabel.text = textPN;
}

#pragma mark 获取通知，更新版本
- (void)receiveDocChange:(NSNotification *)noti
{
    CCDoc *nowDoc = noti.userInfo[@"value"];
    self.isChangeDoc = YES;
    if (nowDoc){
        BOOL oldState = self.drawMenuView.hidden;
        NSInteger nowDocpage = [noti.userInfo[@"page"] integerValue];
        NSInteger size = nowDoc.pageSize;
        [self.drawMenuView removeFromSuperview];
        self.drawMenuView = nil;
        BOOL showPageChange = size > 1 ? YES : NO;
        //显示的是 1/24视图
        [self drawMenuView1:showPageChange];
        NSString *textPN = [NSString stringWithFormat:@"%@ / %@", @(nowDocpage+1), @(size)];
        self.drawMenuView.pageLabel.text = textPN;
        self.drawMenuView.hidden = oldState;
        //切换文档...zhankgai...modify..20190808
        if ([nowDoc.docName isEqualToString:@"WhiteBoard"])
        {
            [[HDSDocManager sharedDoc]toWhiteBoard];
        }
        else
        {
            [self.ccVideoView docChangeTo:nowDoc];
        }
        UIViewController *topVC = self.navigationController.visibleViewController;
        if ([topVC isKindOfClass:[CCDocViewController class]])
        {
            CCDocViewController *docVC = (CCDocViewController *)topVC;
            [docVC docPageChange];
        }
    }
    [self resetDocPPTFrame];
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
    //4、正常退出，清空文档记录
    SaveToUserDefaults(DOC_DOCID, nil);
    SaveToUserDefaults(DOC_DOCPAGE, @(-1));
    SaveToUserDefaults(DOC_ROOMID, nil);

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

//调整鲜花奖杯，聊天视图层次
- (void)changeKeyboardViewUp
{
    [self.view bringSubviewToFront:self.contentView];
}

#pragma mark -- 黑流检测
- (void)postStreamStatusMessage:(id)obj
{
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
             [[CCStreamerBasic sharedStreamer] changeStream:stream videoState:NO completion:^(BOOL result, NSError *error, id info) {
                NSLog(@"pauseVideo  result %d , info %@ , error %@",(result?1:0),info,error);
                if (result) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:KKEY_Audio_changed object:@{@"result":@"audio",@"stream":stream}];
                }
            }];
        }];
        UIAlertAction *changeAction = [UIAlertAction actionWithTitle:@"切换节点(退出到登录页面选择节点)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self closeBtnClickedWithAssistantNone];
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
            [self rePublish];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.showBlackVideoArray removeObject:stream.streamID];
        }];
        [alert addAction:changeAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:true completion:nil];
    }
}
#pragma mark  问题
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

- (void)stopPublish
{
    WS(weakSelf);
    [self.stremer  stopLive:^(BOOL result, NSError *error, id info) {
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
                // zhangkai 继续展示预览的视频，否则，会停顿在当前的视频页面
                [weakSelf.streamView removeStreamView:self.preview];
                [weakSelf statPreview];
            });
        }
    }];
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
    }
}

#pragma mark -- 切麦按钮
//修改录制按钮样式
- (void)recordChangeButtonUITo:(CCRecordType)type
{
    self.liveRecordType = type;
    NSString *imageName = nil;
    switch (type) {
        case CCRecordType_Start:
        case CCRecordType_Resume:
            imageName = @"on_rec";
            break;
        case CCRecordType_Pause:
            imageName = @"pause_rec";
            break;
        case CCRecordType_End:
            imageName = @"start_rec";
            break;
        default:
            break;
    }
    UIImage *image = [UIImage imageNamed:imageName];
    [self.buttonRecord setBackgroundImage:image forState:UIControlStateNormal];
}
#pragma mark -- liveRecord相关
- (void)buttonRecordClicked
{
    NSLog(@"buttonRecordStartClicked__");
    switch (self.liveRecordType)
    {
        case CCRecordType_Start:
        case CCRecordType_Pause:
        case CCRecordType_Resume:
        {
            [self recordToChoice];
        }
            break;
        case CCRecordType_End:
        {
            [self recordChangeToType:CCRecordType_Start];
        }
            break;
        default:
            break;
    }
}

//录制进行中
- (void)recordToChoice
{
    [self.actionSheetRecord showInView:self.view];
}

//录制结束
- (void)recordChangeToType:(CCRecordType)type
{
    WS(weakSelf);
    CCStreamerBasic *streamer = self.stremer ;
    [streamer recordTo:type completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            [weakSelf recordChangeButtonUITo:type];
            return ;
        }
        [CCTool showMessageError:error];
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
            [weakSelf recordChangeButtonUITo:type];
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
    
    if (NO)  //20190524...移除手动录制功能
    {
        self.buttonRecord.hidden = NO;
        float oneWidth = [UIImage imageNamed:@"message"].size.width;
        float oneWidthRecord = [UIImage imageNamed:@"start"].size.width/2;
        
        CGFloat width = self.isLandSpace ? MAX(self.view.frame.size.width, self.view.frame.size.height) : MIN(self.view.frame.size.width, self.view.frame.size.height);
        float all = width - 5*oneWidth - oneWidthRecord;
        float oneDel = all/7.f;
        [_publicChatBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.contentBtnView).offset(oneDel);
            make.right.mas_equalTo(ws.cameraChangeBtn.mas_left).offset(-oneDel);
            make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
        }];
        
        [_cameraChangeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.publicChatBtn.mas_right).offset(oneDel);
            make.right.mas_equalTo(ws.stopPublishBtn.mas_left).offset(-oneDel);
            make.bottom.mas_equalTo(ws.publicChatBtn);
        }];
        
        [_stopPublishBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
            make.left.mas_equalTo(ws.cameraChangeBtn.mas_right).offset(oneDel);
            make.right.mas_equalTo(ws.buttonRecord.mas_left).offset(-oneDel);
        }];
        
        [_buttonRecord mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
            make.left.mas_equalTo(ws.stopPublishBtn.mas_right);
            make.right.mas_equalTo(ws.micChangeBtn.mas_left).offset(-oneDel);
            make.width.mas_equalTo(oneWidthRecord);
            make.height.mas_equalTo(ws.stopPublishBtn.mas_height);
        }];
        
        [_micChangeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.buttonRecord.mas_right);
            make.right.mas_equalTo(ws.menuBtn.mas_left).offset(-oneDel);
            make.bottom.mas_equalTo(ws.publicChatBtn);
        }];
        
        [_menuBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.micChangeBtn.mas_right);
            make.right.mas_equalTo(ws.contentBtnView).offset(-oneDel);
            make.bottom.mas_equalTo(ws.publicChatBtn);
        }];
    }
    else
    {
        self.buttonRecord.hidden = YES;
        [_stopPublishBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
            make.centerX.mas_equalTo(ws.contentBtnView);
        }];
    }
}

- (void)publishEndResetUI
{
    //调整UI
    WS(weakSelf);
    weakSelf.cameraChangeBtn.hidden = YES;
    weakSelf.stopPublishBtn.hidden = YES;
    weakSelf.micChangeBtn.hidden = YES;
    weakSelf.startPublishBtn.hidden = NO;
    weakSelf.cameraChangeBtn.selected = NO;
    weakSelf.micChangeBtn.selected = NO;
    weakSelf.fllowBtn.selected = NO;
    [weakSelf.loadingView removeFromSuperview];
    weakSelf.buttonRecord.hidden = YES;
    
    float oneWidth = [UIImage imageNamed:@"message"].size.width;
    CGFloat width = self.isLandSpace ? MAX(self.view.frame.size.width, self.view.frame.size.height) : MIN(self.view.frame.size.width, self.view.frame.size.height);
    float all = width - 5*oneWidth;
    __unused float oneDel = all/6.f;
    
    [_startPublishBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.contentBtnView).offset(-CCGetRealFromPt(25));
        make.centerX.mas_equalTo(weakSelf.contentBtnView);
    }];
    //修改录制按钮状态
    [self recordChangeButtonUITo:CCRecordType_End];
}

- (void)reSub:(NSNotification *)noti
{
    NSDictionary *info = noti.userInfo;
    NSString *streamID = [info objectForKey:@"stream"];
    __weak typeof(self) weakSelf = self;
    [self.stremer  unsubscribeWithStream:[self.stremer  getStreamWithStreamID:streamID] completion:^(BOOL result, NSError *error, id info) {
        if (result) {
            NSLog(@"unsubcribe stream success %@",streamID);
        }
        else
        {
            NSLog(@"unsubcribe stream fail:%@", error);
        }
        //CCStreamType_ShareScreen屏幕共享流
        if (weakSelf.shareScreen.stream.type == CCStreamType_ShareScreen){
            [weakSelf removeShareScreenView];
        }else{
            [weakSelf.streamView removeStreamViewByStreamID:info];
        }
        [self.stremer subcribeWithStream:[self.stremer  getStreamWithStreamID:streamID] completion:^(BOOL result, NSError *error, id info) {
            NSLog(@"%s__%d__%@", __func__, __LINE__, info);
            if (result)
            {
                CCStreamView *view = info;
                [weakSelf.streamView showStreamView:view];
            }else{
                [CCTool showMessageError:error];
            }
        }];
    }];
}
#pragma mark -- 教师推拉流事件，停止推流，单纯的推拉流
- (void)teacherPublish
{
     WS(weakSelf);
    [self.stremer publish:^(BOOL result, NSError *error, id info) {
        if (!result)
        {
            [UIAlertView bk_showAlertViewWithTitle:nil message:@"上麦失败，是否重试" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确认"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1)
                {
                    [self teacherPublish];
                }
            }];
        }else{
           //推流完成之后，更新麦序
            [self.ccBarelyManager updateUserState:self.room.user_id roomID:nil publishResult:YES streamID:weakSelf.stremer.localStreamID completion:^(BOOL result, NSError *error, id info) {
                if (!result)
                {
                    NSLog(@"老师推流成功，麦序更新失败！");
                }
            }];
        }
    }];
}

- (void)teacherUnPublish
{
    [self.stremer unPublish:^(BOOL result, NSError *error, id info) {
        if (!result)
        {
            [UIAlertView bk_showAlertViewWithTitle:nil message:@"下麦失败，是否重试" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确认"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1)
                {
                    [self teacherUnPublish];
                }
            }];
        }
    }];
}

#pragma mark -- 切麦function
- (void)cherryEventClicked
{
    [UIAlertView bk_showAlertViewWithTitle:nil message:@"此版本暂不支持助教，不能使用切麦按钮。" cancelButtonTitle:nil otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
    }];
    return;
    CCRoom *room = [self.stremer getRoomInfo];
    if (room.live_status == CCLiveStatus_Stop)
    {
        [UIAlertView bk_showAlertViewWithTitle:nil message:@"直播未开始，不能使用切麦按钮。" cancelButtonTitle:nil otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        }];
        return;
    }
    CCUser *userTeacher = [CCTool tool_room_user_role:CCRole_Assistant];
    if (!userTeacher)
    {
        [UIAlertView bk_showAlertViewWithTitle:nil message:@"房间无助教，不能使用切麦按钮。" cancelButtonTitle:nil otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        }];
        return;
    }
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
    CCRoom *room = [self.stremer getRoomInfo];
    NSString *uid = room.user_id;
    CCUser *userLocal = [CCTool tool_room_user_userid:uid];
    CCUserMicStatus micStatus = userLocal.user_status;
    if (micStatus == CCUserMicStatus_Connected)
    {
        [self cherryStateOnMai];
    }
    else
    {
        [self cherryStateDowmMai];
    }
}
//教师连麦中
- (void)cherryStateOnMai
{
    //老师自己下麦，通知助教上麦  设置为踢自己下麦
    CCUser *userTeacher = [CCTool tool_room_user_role:CCRole_Teacher];
    [self.ccBarelyManager presentDM:userTeacher byUser:nil completion:^(BOOL result, NSError *error, id info) {
        if (!result)
        {
            NSString *errMsg = [CCTool toolErrorMessage:error];
            [UIAlertView bk_showAlertViewWithTitle:nil message:errMsg cancelButtonTitle:@"取消" otherButtonTitles:@[@"重试"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                NSLog(@"cherryStateOnMai———buttonIndex————%ld",(long)buttonIndex);
                if (buttonIndex == 1)
                {
                    [self cherryStateOnMai];
                }
            }];
            return ;
        }
        //通知助教上麦..
        [self callCopyLM];
    }];
}
//通知助教上麦  kickUserFromSpeak
- (void)callCopyLM
{
    CCUser *userCopy = [CCTool tool_room_user_role:CCRole_Assistant];
    //讲师\助教 -- 状态变更为5  预上麦   难道就是上麦？
    [self.ccBarelyManager rolePreLM:userCopy completion:^(BOOL result, NSError *error, id info) {
        if(!result)
        {
            NSString *errMsg = [CCTool toolErrorMessage:error];
            [UIAlertView bk_showAlertViewWithTitle:nil message:errMsg cancelButtonTitle:@"取消" otherButtonTitles:@[@"重试"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                NSLog(@"cherryStateOnMai———buttonIndex————%ld",(long)buttonIndex);
                if (buttonIndex == 0)
                {
                    [self callCopyLM];
                }
            }];
            return ;
        }

        if (self.preview)
        {
            [self.streamView removeStreamView:self.preview];
            [self.streamView showStreamView:self.preview];
        }

        [CCTool showMessage:@"切麦成功！"];
    }];
}
//教师不在麦
- (void)cherryStateDowmMai
{
    WS(weakSelf);
    //1、通知助教下麦，老师自己上麦
    CCUser *userAssistant = [CCTool tool_room_user_role:CCRole_Assistant];
    //2、通知助教下麦
    [self.ccBarelyManager assistDM:userAssistant completion:^(BOOL result, NSError *error, id info) {
        if (!result)
        {
            NSString *errMsg = [CCTool toolErrorMessage:error];
            [UIAlertView bk_showAlertViewWithTitle:nil message:errMsg cancelButtonTitle:@"取消" otherButtonTitles:@[@"重试"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1)
                {
                    [self cherryStateDowmMai];
                }
            }];
            return ;
        }
        //3、老师自己推流上麦
        [weakSelf teacherPublish];
    }];
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

- (void)autoSub:(CCStream *)stream
{
    [self.stremer subcribeWithStream:stream completion:^(BOOL result, NSError *error, id info) {
        NSLog(@"call sub result %s__%d__%@__%@__%@", __func__, __LINE__, stream.streamID, @(result),info);
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
    if (stream.type != CCStreamType_ShareScreen && stream.type != CCStreamType_AssistantCamera) {
        
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
    }else{
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
    WS(weakSelf);
    [self.stremer unsubscribeWithStream:stream completion:^(BOOL result, NSError *error, id info) {
        NSLog(@"%s__%d__%@__%@", __func__, __LINE__, stream.streamID, @(result));
        if (result)
        {
            //移除桌面共享
            if(stream.type == CCStreamType_ShareScreen)
            {
                [weakSelf removeShareScreenView];
            }else {
                [weakSelf.streamView removeStreamViewByStreamID:stream.streamID];
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

#pragma mark -- 组件化 | 聊天
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
        XXLogSaveAPIPar(XXLogFuncLine, @{@"event_teacher":@"tap"});
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

#pragma mark - 懒加载
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
///切麦按钮
- (UIButton *)buttonRecord
{
    if (!_buttonRecord)
    {
        _buttonRecord = [CCTool createButton:@"start" target:self action:@selector(buttonRecordClicked)];
        [self.buttonRecord setBackgroundImage:[UIImage imageNamed:@"start_rec"] forState:UIControlStateNormal];
        self.liveRecordType = CCRecordType_End;
        _buttonRecord.hidden = YES;
    }
    return _buttonRecord;
}

//切换摄像头按钮
- (UIActionSheet *)actionSheetCamera
{
    if (!_actionSheetCamera)
    {
        //未选中，表示视频推流  @"切换摄像头"
        _actionSheetCamera = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"开启摄像头", @"关闭摄像头", nil];
    }
    return _actionSheetCamera;
}
//切换record按钮点击
- (UIActionSheet *)actionSheetRecord
{
    //type record-on        @"暂停录制",@"停止录制"
    //type record-pause     @"继续录制",@"停止录制"
    NSArray *arrEvent = nil;
    if (self.liveRecordType == CCRecordType_Start)
    {
        arrEvent = @[@"暂停录制",@"停止录制"];
        _actionSheetRecord = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"暂停录制",@"停止录制", nil];
    }
    else if (self.liveRecordType == CCRecordType_Pause)
    {
        arrEvent = @[@"继续录制",@"停止录制"];
        _actionSheetRecord = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"继续录制",@"停止录制", nil];
    }
    return _actionSheetRecord;
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

-(UIView *)contentView {
    if(!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = CCRGBAColor(171,179,189,0.30);
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

-(HDSChatView *)chatView {
    if(!_chatView) {
        _chatView = [[HDSChatView alloc]initWithArray:@[] landspace:self.isLandSpace viewid:self.viewerId];
    }
    return _chatView;
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
            //计算每一个表情按钮的坐标和在哪一屏
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

-(UIView *)informationView
{
    if(!_informationView)
    {
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

-(UILabel *)hostNameLabel
{
    if(!_hostNameLabel)
    {
        _hostNameLabel = [UILabel new];
        _hostNameLabel.font = [UIFont systemFontOfSize:FontSizeClass_12];
        _hostNameLabel.textAlignment = NSTextAlignmentLeft;
        _hostNameLabel.textColor = [UIColor whiteColor];
        NSString *name = GetFromUserDefaults(LIVE_ROOMNAME);
        NSString *userName = [@"" stringByAppendingString:name.length == 0 ? @"421小班课" : name];
        
        _hostNameLabel.text = userName;
    }
    return _hostNameLabel;
}

-(UILabel *)userCountLabel
{
    if(!_userCountLabel)
    {
        _userCountLabel = [UILabel new];
        _userCountLabel.font = [UIFont systemFontOfSize:FontSizeClass_11];
        _userCountLabel.textAlignment = NSTextAlignmentLeft;
        _userCountLabel.textColor = [UIColor whiteColor];
        NSInteger str = [self.stremer  getRoomInfo].room_user_count;
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

-(UIButton *)publicChatBtn
{
    if(!_publicChatBtn) {
        _publicChatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_publicChatBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message"] forState:UIControlStateNormal];
        [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message_touch"] forState:UIControlStateHighlighted];
        [_publicChatBtn addTarget:self action:@selector(publicChatBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _publicChatBtn;
}

-(UIButton *)cameraChangeBtn
{
    if(!_cameraChangeBtn) {
        _cameraChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraChangeBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_cameraChangeBtn setBackgroundImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [_cameraChangeBtn setBackgroundImage:[UIImage imageNamed:@"camera_close"] forState:UIControlStateSelected];
        [_cameraChangeBtn addTarget:self action:@selector(cameraChangeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraChangeBtn;
}

-(UIButton *)micChangeBtn
{
    if(!_micChangeBtn)
    {
        _micChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_micChangeBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_micChangeBtn setBackgroundImage:[UIImage imageNamed:@"microphone2"] forState:UIControlStateNormal];
        [_micChangeBtn setBackgroundImage:[UIImage imageNamed:@"silence2"] forState:UIControlStateSelected];
        [_micChangeBtn addTarget:self action:@selector(micChangeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _micChangeBtn;
}

-(UIButton *)stopPublishBtn
{
    if(!_stopPublishBtn)
    {
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
        NSString *followID = [self.stremer  getRoomInfo].teacherFllowUserID;
        _fllowBtn.selected = followID.length == 0 ? NO : YES;
    }
    return _fllowBtn;
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
        [_startPublishBtn addTarget:self action:@selector(startPublishBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startPublishBtn;
}

- (CCRoom *)room
{
    return [self.stremer getRoomInfo];
}
#pragma mark - 添加监听_和_移除监听
-(void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getProWithDocID:) name:@"getProWithDocID" object:nil];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCurrentShowDocDel:) name:CCNotiDelCurrentShowDoc object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(teacherUnPublish) name:CCNotiNeedStopPublish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publishDirectlyWithUnPublish) name:CCNotiNeedStartPublish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SDKNeedsubStream:) name:CCNotiNeedSubscriStream object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SDKNeedUnsubStream:) name:CCNotiNeedUnSubcriStream object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reSub:) name:CCNotiStreamCheckNilStream object:nil];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedStopPublish object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedStartPublish object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"rePublishView" object:nil];
}

#pragma mark -内存警告和销毁
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
    if (self.room_user_cout_timer)
    {
        [self.room_user_cout_timer invalidate];
        self.room_user_cout_timer = nil;
    }
}

- (void)hiddenChatView:(BOOL)hidden
{
    [self.chatView hiddenChatView:hidden];
}


#pragma mark -- 回调测试
- (void)onStartRouteOptimization
{
    [self.hdsTool loadingViewShow:@"加载中" view:self.view];
    NSLog(@"hhds_____001_____!");
    [self appUpdateUISwitchStart];
}
- (void)appUpdateUISwitchStart
{
    WS(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.streamView removeStreamViewAll];
        _micChangeBtn.selected = NO;
        _cameraChangeBtn.selected = NO;
    });
}

- (void)onReloadPreview
{
    [self statPreview];
}
- (void)onStopRouteOptimization
{
    [self updateSwitchSuccess];
    [self.hdsTool loadingViewDismiss];
}
- (void)updateSwitchSuccess
{
    [self.stremer setAudioOpened:YES userID:nil];
    [self.stremer setVideoOpened:YES userID:nil];
}
- (void)switchPlatformError:(NSError *)error
{
    NSLog(@"hhds_____004_____!----%@---",error);
    [self.hdsTool loadingViewDismiss];
    [self appLeaveRoom];
}
/** 老师退出直播间 */
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


///文档缩放------
-(CCChangeScrollBtn *)changeScrollBtn {
    if (!_changeScrollBtn) {
        _changeScrollBtn = [[CCChangeScrollBtn alloc] initWithFrame:CGRectMake(0, 60, 100, 50)];
        _changeScrollBtn.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.3];
        _changeScrollBtn.hidden = YES;
    }
    return _changeScrollBtn;
}
-(void)dragAction {
    CCRoomTemplate template = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_template;
    if (template == CCRoomTemplateSpeak && self.isLandSpace) {
        
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

-(void)paintingAction {
    self.changeScrollBtn.hidden = YES;
    [self.ccVideoView setHiddenSlider:NO];
    [self.ccVideoView setDocEditable:NO];
}
@end


