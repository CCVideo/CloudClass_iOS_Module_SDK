//
//  LiveViewController.m
//  NewCCDemo
//
//  Created by cc on 2016/11/23.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "CCLoginViewController.h"
#import "TextFieldUserInfo.h"
#import "CCPlayViewController.h"
#import <AFNetworking.h>
#import <AVFoundation/AVFoundation.h>
#import <BlocksKit+UIKit.h>
#import "CCStreamShowView.h"
#import "STDPingServices.h"
#import "LoadingView.h"

#define KK_Login_Username   @"ccusername"
#define KK_Login_Pwd        @"ccpwd"

#define InfomationTop  74

@interface CCLoginViewController ()<UITextFieldDelegate>
@property(nonatomic,strong)UIImageView          *iconImageView;
@property(nonatomic,strong)UILabel              *roomNameLabel;
@property(nonatomic,strong)UILabel              *descLabel;
@property(nonatomic,strong)UILabel              *informationLabel;
@property(nonatomic,strong)TextFieldUserInfo    *textFieldUserName;
@property(nonatomic,strong)TextFieldUserInfo    *textFieldUserPassword;

@property(nonatomic,strong)UIButton             *loginBtn;
@property(nonatomic,strong)LoadingView          *loadingView;
@property(nonatomic,strong)NSArray       *serverList;
@property(nonatomic,strong)CCStreamerBasic *streamer;
@property(nonatomic,strong)NSMutableArray *showStream;
@end

@implementation CCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"验证";
    
    [self.view addSubview:self.informationLabel];
    
    WS(ws);
    [_informationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));
        make.top.mas_equalTo(ws.view).offset(InfomationTop);;
        make.width.mas_equalTo(ws.view.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(CCGetRealFromPt(24));
    }];
    
    [self.view addSubview:self.iconImageView];
    [self.view addSubview:self.roomNameLabel];
    [self.view addSubview:self.descLabel];
    
    [self.iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws.view).offset(0.f);
        make.top.mas_equalTo(ws.informationLabel.mas_bottom).offset(0.f);
    }];
    [self.roomNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(10.f);
        make.right.mas_equalTo(ws.view).offset(-10.f);
        make.top.mas_equalTo(ws.iconImageView.mas_bottom).offset(10.f);
    }];
    [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(10.f);
        make.right.mas_equalTo(ws.view).offset(-10.f);
        make.top.mas_equalTo(ws.roomNameLabel.mas_bottom).offset(10.f);
    }];
    
    [self.view addSubview:self.textFieldUserName];

    [self.textFieldUserName mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.descLabel.mas_bottom).with.offset(CCGetRealFromPt(22));
        make.height.mas_equalTo(CCGetRealFromPt(92));
    }];
    
    UIView *line1 = [UIView new];
    [self.view addSubview:line1];
    [line1 setBackgroundColor:CCRGBColor(238,238,238)];
    [line1 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.textFieldUserName.mas_top);
        make.height.mas_equalTo(1);
    }];
    
    if (self.needPassword)
    {
        [self.view addSubview:self.textFieldUserPassword];
        [self.textFieldUserPassword mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(ws.textFieldUserName);
            make.top.mas_equalTo(ws.textFieldUserName.mas_bottom);
            make.height.mas_equalTo(ws.textFieldUserName);
        }];
        
        UIView *line = [UIView new];
        [self.view addSubview:line];
        [line setBackgroundColor:CCRGBColor(238,238,238)];
        [line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.view);
            make.top.mas_equalTo(ws.textFieldUserPassword.mas_bottom);
            make.height.mas_equalTo(1);
        }];
        
        [self.view addSubview:self.loginBtn];
        [_loginBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(65));
            make.right.mas_equalTo(ws.view).with.offset(-CCGetRealFromPt(65));
            make.top.mas_equalTo(line.mas_bottom).with.offset(CCGetRealFromPt(70));
            make.height.mas_equalTo(CCGetRealFromPt(86));
        }];
    }
    else
    {
//        [self.textFieldUserPassword mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.mas_equalTo(ws.textFieldUserName);
//            make.top.mas_equalTo(ws.textFieldUserName.mas_bottom);
//            make.height.mas_equalTo(ws.textFieldUserName);
//        }];
//        
        UIView *line = [UIView new];
        [self.view addSubview:line];
        [line setBackgroundColor:CCRGBColor(238,238,238)];
        [line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.view);
            make.top.mas_equalTo(ws.textFieldUserName.mas_bottom);
            make.height.mas_equalTo(1);
        }];
        
        [self.view addSubview:self.loginBtn];
        [_loginBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(65));
            make.right.mas_equalTo(ws.view).with.offset(-CCGetRealFromPt(65));
            make.top.mas_equalTo(line.mas_bottom).with.offset(CCGetRealFromPt(70));
            make.height.mas_equalTo(CCGetRealFromPt(86));
        }];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:CONTROLLER_INDEX];
    [self addObserver];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.textFieldUserName.text = GetFromUserDefaults(KK_Login_Username);
    self.textFieldUserPassword.text = GetFromUserDefaults(KK_Login_Pwd);
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    if (self.needPassword)
    {
        if(StrNotEmpty(_textFieldUserName.text) && StrNotEmpty(_textFieldUserPassword.text))
        {
            self.loginBtn.enabled = YES;
            [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
        } else {
            self.loginBtn.enabled = NO;
            [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
        }
    }
    else
    {
        if(StrNotEmpty(_textFieldUserName.text))
        {
            self.loginBtn.enabled = YES;
            [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
        } else {
            self.loginBtn.enabled = NO;
            [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
        }
    }
}

-(void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)dealloc {
    [self removeObserver];
}

-(UIButton *)loginBtn {
    if(_loginBtn == nil) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginBtn.backgroundColor = MainColor;
        _loginBtn.layer.cornerRadius = CCGetRealFromPt(43);
        _loginBtn.layer.masksToBounds = YES;
        [_loginBtn setTitle:@"登 录" forState:UIControlStateNormal];
        [_loginBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSizeClass_18]];
        [_loginBtn setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
        [_loginBtn setTitleColor:CCRGBAColor(255, 255, 255, 0.4) forState:UIControlStateDisabled];
        [_loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];

        [_loginBtn setBackgroundImage:[self createImageWithColor:MainColor] forState:UIControlStateNormal];
        [_loginBtn setBackgroundImage:[self createImageWithColor:CCRGBAColor(242,124,25,0.2)] forState:UIControlStateDisabled];
        [_loginBtn setBackgroundImage:[self createImageWithColor:CCRGBColor(229,118,25)] forState:UIControlStateHighlighted];
    }
    return _loginBtn;
}

- (UIImage*)createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

//监听touch事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [self keyboardHide];
}

-(void)loginAction
{
    
    SaveToUserDefaults(KK_Login_Username, self.textFieldUserName.text);
    SaveToUserDefaults(KK_Login_Pwd, self.textFieldUserPassword.text);
    
    [self.view endEditing:YES];
    [self keyboardHide];
    
    _loadingView = [[LoadingView alloc] initWithLabel:@"正在登录..."];
    [self.view addSubview:_loadingView];
    
    [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    SaveToUserDefaults(SET_USER_NAME, self.textFieldUserName.text);
    __weak typeof(self) weakSelf = self;
    CCEncodeConfig *config = [[CCEncodeConfig alloc] init];
    config.reslution = CCResolution_HIGH;
//    https://class.csslcloud.net/index/presenter/?roomid=EF7327639D208BA09C33DC5901307461
//    self.roomID = @"EF7327639D208BA09C33DC5901307461";
//    self.userID = @"C6D427413B4A8E53";
//    self.userID = @"83F203DAC2468694";
//    self.roomID = @"23804F8EBD3BB1F59C33DC5901307461";
//    self.textFieldUserPassword.text = @"111";
//    self.textFieldUserName.text = @"CC";
    [self authWithRoomID:self.roomID userID:self.userID role:1 password:self.textFieldUserPassword.text nickName:self.textFieldUserName.text completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            [weakSelf streamLoginSuccess:info];
        }
        else
        {
            [weakSelf.loadingView removeFromSuperview];
             NSLog(@"__%s__%d__%@", __func__, __LINE__, error);
            [weakSelf streamLoginFail:error];
        }
    }];
}

-(UILabel *)informationLabel
{
    if(_informationLabel == nil)
    {
        _informationLabel = [UILabel new];
        [_informationLabel setBackgroundColor:CCRGBColor(250, 250, 250)];
        [_informationLabel setFont:[UIFont systemFontOfSize:FontSizeClass_12]];
        [_informationLabel setTextColor:CCRGBColor(102, 102, 102)];
        [_informationLabel setTextAlignment:NSTextAlignmentLeft];
        [_informationLabel setText:@""];
    }
    return _informationLabel;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (UIImageView *)iconImageView
{
    if (!_iconImageView)
    {
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"portrait"]];
    }
    return _iconImageView;
}

- (UILabel *)roomNameLabel
{
    if (!_roomNameLabel)
    {
        _roomNameLabel = [UILabel new];
        _roomNameLabel.font = [UIFont systemFontOfSize:FontSizeClass_18];
        _roomNameLabel.textAlignment = NSTextAlignmentCenter;
        _roomNameLabel.numberOfLines = 1;
        _roomNameLabel.text = GetFromUserDefaults(LIVE_ROOMNAME);
    }
    return _roomNameLabel;
}

- (UILabel *)descLabel
{
    if (!_descLabel)
    {
        _descLabel = [UILabel new];
        _descLabel.font = [UIFont systemFontOfSize:FontSizeClass_15];
        _descLabel.textColor = [UIColor lightGrayColor];
        _descLabel.textAlignment = NSTextAlignmentCenter;
        _descLabel.numberOfLines = 2;
        NSString *desc = GetFromUserDefaults(LIVE_ROOMDESC);
        desc = [self filterHTML:desc];
        _descLabel.text = desc;
    }
    return _descLabel;
}

-(TextFieldUserInfo *)textFieldUserName
{
    if(_textFieldUserName == nil) {
        _textFieldUserName = [TextFieldUserInfo new];
        [_textFieldUserName textFieldWithLeftText:@"" placeholder:@"请输入昵称" lineLong:NO text:nil];
        _textFieldUserName.delegate = self;
        _textFieldUserName.tag = 3;
        [_textFieldUserName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldUserName;
}

-(TextFieldUserInfo *)textFieldUserPassword {
    if(_textFieldUserPassword == nil) {
        _textFieldUserPassword = [TextFieldUserInfo new];
        [_textFieldUserPassword textFieldWithLeftText:@"" placeholder:@"请输入密码" lineLong:NO text:nil];
        _textFieldUserPassword.delegate = self;
        _textFieldUserPassword.tag = 4;
        _textFieldUserPassword.secureTextEntry = YES;
        [_textFieldUserPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldUserPassword;
}

- (void)didReceiveMemoryWarning {   
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)streamLoginSuccess:(NSDictionary *)info
{
    NSLog(@"%@",info);
    NSString *name = info[@"name"];
    SaveToUserDefaults(LIVE_USERNAME, name);
    SaveToUserDefaults(LIVE_ROOMNAME, info[@"name"]);
    SaveToUserDefaults(LIVE_ROOMDESC, info[@"desc"]);
    [_loadingView removeFromSuperview];
    //self.streamer 为nil
    CCPlayViewController *playVC = [[CCPlayViewController alloc]init];
    playVC.viewerId = self.userID;
    playVC.info = info;
    [self.navigationController pushViewController:playVC animated:YES];
    [self.showStream removeAllObjects];
}

- (void)streamLoginFail:(NSError *)error
{
    [_loadingView removeFromSuperview];
    
    [UIAlertView bk_showAlertViewWithTitle:@"" message:error.domain cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
    }];
}

#pragma mark - UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

+(int)convertToInt:(NSString*)strtemp {
    
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}

#define kMaxLength 20
- (void) textFieldDidChange:(UITextField *) TextField
{
    
    if (self.needPassword)
    {
        if(StrNotEmpty(_textFieldUserName.text) && StrNotEmpty(_textFieldUserPassword.text))
        {
            self.loginBtn.enabled = YES;
            [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
        } else {
            self.loginBtn.enabled = NO;
            [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
        }
    }
    else
    {
        if(StrNotEmpty(_textFieldUserName.text))
        {
            self.loginBtn.enabled = YES;
            [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
        } else {
            self.loginBtn.enabled = NO;
            [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
        }
    }
    
//    if(StrNotEmpty(_textFieldUserName.text) && StrNotEmpty(_textFieldUserPassword.text))
//    {
//        self.loginBtn.enabled = YES;
//        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
//    } else {
//        self.loginBtn.enabled = NO;
//        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
//    }
    
    NSString *toBeString = TextField.text;
    int length = [CCLoginViewController convertToInt:toBeString];
    UITextRange *selectedRange = [TextField markedTextRange];
    //获取高亮部分
    UITextPosition *position = [TextField positionFromPosition:selectedRange.start offset:0];
    //没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if(!position)
    {
        if(length > kMaxLength)
        {
            for (int i = 1; i < toBeString.length; i++)
            {
                NSString *str = [toBeString substringToIndex:toBeString.length - i];
                int length = [CCLoginViewController convertToInt:str];
                if (length <= kMaxLength)
                {
                    TextField.text = str;
                    break;
                }
            }
        }
    }
}

-(NSString *)filterHTML:(NSString *)html
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    //    NSString * regEx = @"<([^>]*)>";
    //    html = [html stringByReplacingOccurrencesOfString:regEx withString:@""];
    return html;
}

#pragma mark - keyboard notification

- (void)keyboardWillShow:(NSNotification *)notif {
    if(![self.textFieldUserName isFirstResponder] && ![self.textFieldUserPassword isFirstResponder])
    {
        return;
    }
    
    NSDictionary *userInfo = [notif userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat y = keyboardRect.size.height;
    
    for (int i = 1; i <= 4; i++) {
        UITextField *textField = [self.view viewWithTag:i];
        if ([textField isFirstResponder] == true && (SCREENH_HEIGHT - (CGRectGetMaxY(textField.frame) + CCGetRealFromPt(10))) < y) {
            WS(ws)
            [self.informationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));
                make.top.mas_equalTo(ws.view).with.offset( - (y - (SCREENH_HEIGHT - (CGRectGetMaxY(textField.frame) + CCGetRealFromPt(10)))));
                make.width.mas_equalTo(ws.view.mas_width).multipliedBy(0.5);
                make.height.mas_equalTo(CCGetRealFromPt(24));
            }];
            
            [UIView animateWithDuration:0.25f animations:^{
                [ws.view layoutIfNeeded];
            }];
        }
    }
}

-(void)keyboardHide {
    WS(ws)
    [self.informationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));
        make.top.mas_equalTo(ws.view).offset(InfomationTop);;
        make.width.mas_equalTo(ws.view.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(CCGetRealFromPt(24));
    }];
    
    [UIView animateWithDuration:0.25f animations:^{
        [ws.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notif {
    [self keyboardHide];
}

- (BOOL)authWithRoomID:(NSString *)roomID userID:(NSString *)userID role:(NSInteger)role password:(NSString *)password nickName:(NSString *)name completion:(CCComletionBlock)completion
{
    if (password.length == 0)
    {
        password = @"";
    }
    //Chenfy..TODO
    //'0': 教师 '1': 互动者 '2': 旁听者
    role = 1;
    NSString *url = @"https://ccapi.csslcloud.net/api/room/auth";
    NSDictionary *par = @{
                          @"roomid": roomID,
                          @"userid": userID,
                          @"role": [NSString stringWithFormat:@"%@", @(role)],
                          @"password": password,
                          @"name": name,
                          @"client":@"1"};
    __weak typeof(self) weakSelf = self;
    [[CCLoginViewController sessionManager] POST:url parameters:par success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *dic = responseObject;
        
        CCLog(@"dic:%@", dic);
        NSString *result = dic[@"result"];
        if ([result isEqualToString:@"FAIL"])
        {
            //失败
            NSError *error = [NSError errorWithDomain:[weakSelf getErrorMsgFrom:dic] code:2001 userInfo:nil];
            if (completion)
            {
                completion(NO, error, nil);
            }
        }
        else
        {
            if (completion)
            {
                completion(YES, nil, responseObject);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion)
            {
                completion(NO, error, nil);
            }
        });
    }];
    return YES;
}

- (NSString *)getErrorMsgFrom:(NSDictionary*)dic
{
    if (!dic)
    {
        return @"";
    }
    NSString *msg = @"";
    for (NSString *key in dic.allKeys)
    {
        if ([key isEqualToString:@"errorMsg"])
        {
            msg = dic[key];
        }
        else if([key isEqualToString:@"data"])
        {
            msg = dic[@"data"];
        }
        else if ([key isEqualToString:@"reason"])
        {
            msg = dic[@"reason"];
        }
    }
    return msg;
}

+ (AFHTTPSessionManager *)sessionManager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    return manager;
}
@end
