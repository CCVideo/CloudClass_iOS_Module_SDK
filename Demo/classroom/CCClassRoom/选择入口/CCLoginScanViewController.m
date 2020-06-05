//
//  CCScanViewController.m
//  CCClassRoom
//
//  Created by cc on 17/1/22.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCLoginScanViewController.h"
#import "CCScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CCLoginViewController.h"
#import "CCLoginDirectionViewController.h"
#import "TextFieldUserInfo.h"
#import <UIAlertView+BlocksKit.h>
#import <CCClassRoomBasic/CCClassRoomBasic.h>

#import "CCTicketVoteView.h"
#import "CCTickeResultView.h"
#import "CCBrainView.h"

@interface CCLoginScanViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UILabel *versionLabel;
@property (strong, nonatomic) UIButton *loginBtn;
@property (strong, nonatomic) TextFieldUserInfo *textFieldUserName;
@property (strong, nonatomic) UIButton *leftBtn;
@property (strong, nonatomic) UIButton *rightBtn;
@end

@implementation CCLoginScanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ScanSuccess:) name:@"ScanSuccess" object:nil];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_build = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"V%@", app_build];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(reportHDSLog) forControlEvents:UIControlEventTouchUpInside];
    [self.versionLabel addSubview:btn];
    self.versionLabel.userInteractionEnabled = YES;
    
    WS(ws);
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.versionLabel);
    }];
    
    [self.view addSubview:self.textFieldUserName];
    [self.textFieldUserName mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(65));
        make.right.mas_equalTo(ws.view).with.offset(-CCGetRealFromPt(65));
        make.top.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(592));
        make.height.mas_equalTo(CCGetRealFromPt(100));
    }];
    [self.view addSubview:self.loginBtn];
    [self.loginBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(65));
        make.right.mas_equalTo(ws.view).with.offset(-CCGetRealFromPt(65));
        make.top.mas_equalTo(ws.textFieldUserName.mas_bottom).with.offset(CCGetRealFromPt(70));
        make.height.mas_equalTo(CCGetRealFromPt(100));
    }];
    self.loginBtn.enabled = NO;
    [self.view addSubview:self.leftBtn];
    [self.leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.view).offset(14.f + [CCTool tool_MainWindowSafeArea_Bottom]);
        make.left.mas_equalTo(ws.view).offset(10.f);
    }];
    [self.view addSubview:self.rightBtn];
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.view).offset(14.f + [CCTool tool_MainWindowSafeArea_Bottom]);
        make.right.mas_equalTo(ws.view).offset(-10.f);
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(schemeApp:) name:SCHEAMAPP object:nil];
    
    [self testAlert];
}

- (void)reportHDSLog
{
    NSString *uid = GetFromUserDefaults(Login_UID);
    [[CCStreamerBasic sharedStreamer]reportLogInfo:uid];
    dispatch_async(dispatch_get_main_queue(), ^{
        [CCTool showMessage:@"日志已上报！"];
    });
}
-(void)testAlert {
    //    if (DEBUG) {
    //        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    //        NSString *app_build = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    //        self.versionLabel.text = [NSString stringWithFormat:@"V%@", app_build];
    //        NSString *app_build_version = [infoDictionary objectForKey:@"CFBundleVersion"];
    //
    //        [CCTool showMessage:app_build_version];
    //    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    self.textFieldUserName.text = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)schemeApp:(NSNotification *)nofi {
    NSLog(@"schemeApp  ");
    NSMutableArray * navArray = [self.navigationController.viewControllers mutableCopy];
    for (UIViewController *vc in navArray) {
        if ([vc isKindOfClass:NSClassFromString(@"CCLoginViewController")]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
        }
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@",nofi.object];
    if ([urlStr containsString:@"csslcloud://minclass?"] || [urlStr containsString:@"csslcloud://"]) {
        NSRange range = [urlStr rangeOfString:@"?"];
        if (range.length == 0) {
            urlStr = [urlStr stringByReplacingOccurrencesOfString:@"csslcloud://miniclass?" withString:@""];
        } else {
            urlStr = [urlStr substringFromIndex:(range.location + 1)];
        }
    }
    CCLoginViewController *liveVC = [[CCLoginViewController alloc] init];
    NSArray *arr = [urlStr componentsSeparatedByString:@"&"];
    for (NSString *name in arr) {
        if ([name containsString:@"roomid"]) {
            NSString *roomid = [name stringByReplacingOccurrencesOfString:@"roomid=" withString:@""];
            liveVC.roomID = roomid;
        } else if ([name containsString:@"userid"]) {
            NSString *userid = [name stringByReplacingOccurrencesOfString:@"userid=" withString:@""];
            liveVC.userID = userid;
        } else if ([name containsString:@"role"]) {
            NSString *role = [name stringByReplacingOccurrencesOfString:@"role=" withString:@""];
            CCRole role1 = [CCTool roleFromRoleString:role];
            liveVC.role = role1;
        }
    }
    liveVC.isLandSpace = NO;
    
    main_async_safe(^{
        [self.navigationController pushViewController:liveVC animated:YES];
    });
}

- (void)ScanSuccess:(NSNotification *)noti
{
    NSString *userId = noti.userInfo[@"userID"];
    NSString *roomId = noti.userInfo[@"roomID"];
    NSString *role = noti.userInfo[@"role"];
    NSInteger authtype = [noti.userInfo[@"authtype"] integerValue];
    BOOL needPassword = authtype == 2 ? NO : YES;
    CCRole role1 = [CCTool roleFromRoleString:role];
    UIStoryboard *mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    CCLoginDirectionViewController *directionVC = (CCLoginDirectionViewController *)[mainStory instantiateViewControllerWithIdentifier:@"Direction"];
    if (role1 == CCRole_Teacher || role1 == CCRole_Assistant)
    {
        directionVC.needPassword = YES;
    }
    else
    {
        if (role1 == CCRole_Teacher)
        {
            directionVC.needPassword = YES;
        }
        else
        {
            directionVC.needPassword = needPassword;
        }
    }
    directionVC.role = role1;
    directionVC.role = role1;
    SaveToUserDefaults(LIVE_ROLE, @(directionVC.role));
    SaveToUserDefaults(LIVE_ROOMID, roomId);
    directionVC.userID = userId;
    directionVC.roomID = roomId;
    main_async_safe(^{
        [self.navigationController pushViewController:directionVC animated:YES];
    });
}

- (IBAction)touchScan:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            // 许可对话没有出现，发起授权许可
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        main_async_safe(^{
                            CCScanViewController *scanViewController = [[CCScanViewController alloc] initWithType:1];
                            [weakSelf.navigationController pushViewController:scanViewController animated:YES];
                        });
                    }else{
                        main_async_safe(^{
                            //用户拒绝
                            CCScanViewController *scanViewController = [[CCScanViewController alloc] initWithType:1];
                            [weakSelf.navigationController pushViewController:scanViewController animated:YES];
                            
                        });                        
                    }
                });
            }];
        }
            break;
        case AVAuthorizationStatusAuthorized:{
            // 已经开启授权，可继续
            dispatch_async(dispatch_get_main_queue(), ^{
                CCScanViewController *scanViewController = [[CCScanViewController alloc] initWithType:1];
                [weakSelf.navigationController pushViewController:scanViewController animated:YES];
            });
        }
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted: {
            // 用户明确地拒绝授权，或者相机设备无法访问
            dispatch_async(dispatch_get_main_queue(), ^{
                CCScanViewController *scanViewController = [[CCScanViewController alloc] initWithType:1];
                [weakSelf.navigationController pushViewController:scanViewController animated:YES];
            });
        }
            break;
        default:
            break;
    }
}

- (IBAction)leftBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"LoginScanToUserGuide" sender:self];
}

- (void)rightBtnClicked:(UIButton *)btn
{
    [self touchScan:btn];
}

- (void)loginAction
{
    self.loginBtn.enabled = NO;
    if ([self.textFieldUserName.text isEqualToString:@"Apple"] || [self.textFieldUserName.text isEqualToString:@"apple"]) {
        ///苹果审核员理解错误,导致输入错误,进行兼容
        [self parseCodeStr:@"http://cloudclass.csslcloud.net/index/presenter/?roomid=663263B87944FD2F9C33DC5901307461&userid=A4753A771ACA77AB"];
    }else {
        
        [self parseCodeStr:self.textFieldUserName.text];
    }
}

-(void)parseCodeStr:(NSString *)result {
    NSRange rangeRoomId = [result rangeOfString:@"roomid="];
    NSRange rangeUserId = [result rangeOfString:@"userid="];
    WS(ws)
    if (!StrNotEmpty(result) || rangeRoomId.location == NSNotFound || rangeUserId.location == NSNotFound)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"解析错误错误" message:@"课堂链接错误" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ws.textFieldUserName becomeFirstResponder];
        }];
        [alertController addAction:okAction];
        [ws presentViewController:alertController animated:YES completion:nil];
    } else {
        NSString *roomId = [result substringWithRange:NSMakeRange(rangeRoomId.location + rangeRoomId.length, rangeUserId.location - 1 - (rangeRoomId.location + rangeRoomId.length))];
        NSString *userId = @"";
        NSString *role = @"";
        userId = [result substringFromIndex:rangeUserId.location + rangeUserId.length];
        NSArray *slience = [result componentsSeparatedByString:@"/"];
        if (slience.count == 6)
        {
            role = slience[4];
        }
        NSLog(@"roomId = %@,userId = %@,slicence = %@",roomId,userId,slience);
        NSLog(@"roomId = %@,userId = %@",roomId,userId);
        SaveToUserDefaults(LIVE_USERID,userId);
        SaveToUserDefaults(LIVE_ROOMID,roomId);
        BOOL roleOk = [CCTool roleFromRoleStringIsRight:role];
        CCRole roleReal = [CCTool roleFromRoleString:role];
        if (!roleOk)
        {
            [UIAlertView bk_showAlertViewWithTitle:@"" message:@"扫码角色异常，请重试！" cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            }];
            return;
        }
        if (roleReal == CCRole_Watcher)
        {
            [UIAlertView bk_showAlertViewWithTitle:@"" message:@"请使用直播播放客户端启动" cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [ws.textFieldUserName becomeFirstResponder];
            }];
            return;
        }
        NSString *urlDealed = [[CCScanViewController new]dealURLClassToCCAPI:result];
        [[CCStreamerBasic sharedStreamer]setServerDomain:urlDealed area:nil];
        
        __weak typeof(self) weakSelf = self;
        userId = [userId stringByReplacingOccurrencesOfString:@" " withString:@""];
        [[CCStreamerBasic sharedStreamer] getRoomDescWithRoonID:roomId completion:^(BOOL result, NSError *error, id info) {
            weakSelf.loginBtn.enabled = YES;
            if (result)
            {
                NSString *result = info[@"result"];
                
                if ([result isEqualToString:@"OK"])
                {
                    NSString *name = info[@"data"][@"name"];
                    NSString *desc = info[@"data"][@"desc"];
                    SaveToUserDefaults(LIVE_ROOMNAME, name);
                    SaveToUserDefaults(LIVE_ROOMDESC, desc);
                    [ws.navigationController popViewControllerAnimated:NO];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ScanSuccess" object:nil userInfo:@{@"userID":userId, @"roomID":roomId, @"role":role, @"authtype":info[@"data"][@"authtype"]}];
                }
                else
                {
                    [ws.navigationController popViewControllerAnimated:NO];
                }
            }
            else
            {
                [ws.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

- (void) textFieldDidChange:(UITextField *) TextField
{
    if(StrNotEmpty(_textFieldUserName.text))
    {
        self.loginBtn.enabled = YES;
        [self.loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
    } else {
        self.loginBtn.enabled = NO;
        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
    }
}

#pragma mark - UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

//监听touch事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - 懒加载

-(UIButton *)loginBtn {
    if(_loginBtn == nil) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginBtn.backgroundColor = MainColor;
        _loginBtn.layer.cornerRadius = CCGetRealFromPt(100)/2.f;
        _loginBtn.layer.masksToBounds = YES;
        [_loginBtn setTitle:@"进入课堂" forState:UIControlStateNormal];
        [_loginBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSizeClass_16]];
        [_loginBtn setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
        [_loginBtn setTitleColor:CCRGBAColor(255, 255, 255, 0.4) forState:UIControlStateDisabled];
        [_loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
        
        [_loginBtn setBackgroundImage:[self createImageWithColor:MainColor] forState:UIControlStateNormal];
        [_loginBtn setBackgroundImage:[self createImageWithColor:CCRGBAColor(242,124,25,0.2)] forState:UIControlStateDisabled];
        [_loginBtn setBackgroundImage:[self createImageWithColor:CCRGBColor(229,118,25)] forState:UIControlStateHighlighted];
    }
    return _loginBtn;
}

- (UIButton *)leftBtn
{
    if(_leftBtn == nil) {
        _leftBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_leftBtn setTitle:@"" forState:UIControlStateNormal];
        [_leftBtn setBackgroundImage:[UIImage imageNamed:@"book-1"] forState:UIControlStateNormal];
        [_leftBtn addTarget:self action:@selector(leftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftBtn;
}

- (UIButton *)rightBtn
{
    if(_rightBtn == nil) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setTitle:@"" forState:UIControlStateNormal];
        [_rightBtn setBackgroundImage:[UIImage imageNamed:@"scan2"] forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

-(TextFieldUserInfo *)textFieldUserName
{
    if(_textFieldUserName == nil) {
        _textFieldUserName = [TextFieldUserInfo new];
        NSString *str = @"请输入课堂链接";
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
        [text addAttribute:NSForegroundColorAttributeName value:CCRGBColor(180,180,180) range:NSMakeRange(0, str.length)];
        [_textFieldUserName textFieldWithLeftText:@"" placeholderAttri:text lineLong:NO text:nil];
        _textFieldUserName.delegate = self;
        _textFieldUserName.tag = 3;
        _textFieldUserName.font = [UIFont systemFontOfSize:FontSizeClass_15];
        [_textFieldUserName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _textFieldUserName.layer.cornerRadius = CCGetRealFromPt(100)/2.f;
        _textFieldUserName.layer.masksToBounds = YES;
        _textFieldUserName.layer.borderColor = CCRGBColor(218, 218, 218).CGColor;
        _textFieldUserName.layer.borderWidth = 1.f;
    }
    return _textFieldUserName;
}

#pragma mark - 内存警告
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
