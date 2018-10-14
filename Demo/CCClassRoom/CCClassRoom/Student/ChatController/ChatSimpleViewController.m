//
//  ChatSimpleViewController.m
//  CCClassRoom
//
//  Created by cc on 18/7/13.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "ChatSimpleViewController.h"
#import <CCClassRoomBasic/CCClassRoomBasic.h>
#import <CCChatLibrary/CCChatLibrary.h>
#import <CCChatLibrary/CCChatManager.h>

#import <UIImageView+WebCache.h>
#import "CCPhotoNotPermissionVC.h"
#import "GCPrePermissions.h"
#import <Photos/Photos.h>
#import "TZImagePickerController.h"
#import "ChatTableViewCell.h"

#define KKEY_Teacher    @"老师:"
#define KKEY_Student    @"学生:"

@interface ChatSimpleViewController ()<UITableViewDelegate,UITableViewDataSource>
//组件
@property(nonatomic,strong)CCStreamerBasic *stremer;
@property(nonatomic,strong)CCChatManager    *ccChatManager;

//UI配置演示
@property(nonatomic,strong)UITableView      *tableView;
@property(nonatomic,strong)NSMutableArray   *arrMessage;

@property(nonatomic,strong)UIImageView  *imageV;
@property(nonatomic,strong)UIButton  *btnImage;
@property(nonatomic,strong)UITextField  *textField;
@property(nonatomic,strong)UIButton  *btnSend;

@end

@implementation ChatSimpleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenKeyBoard)];
    [self.view addGestureRecognizer:tap];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initUI];
    [self initFunction];
    // Do any additional setup after loading the view.
}

- (void)hiddenKeyBoard
{
    [self.textField resignFirstResponder];
}

/*
 chatLog =             (
 {
 content = "gyjgjgj2 ";
 time = 43;
 userAvatar = "";
 userCustomMark = "";
 userId = 8619cc28525b4d548460437c87e61243;
 userName = e123;
 userRole = unknow;
 },

 
 value:{
 msg = "sd ";
 time = "16:42:55";
 useravatar = "";
 userid = 8619cc28525b4d548460437c87e61243;
 username = e123;
 userName = presenter;
 }
 
 */

- (void)initFunction
{
    WS(weakSelf);
    self.arrMessage = [NSMutableArray array];
    [self initBaseSDKComponent];
    [self.ccChatManager getChatHistoryData:^(BOOL result, NSError *error, id info) {
        NSArray *chatArray = info[@"chatLog"];
        NSTimeInterval timeStartLive = [info[@"startLiveTime"]doubleValue];

        self.title = [NSString stringWithFormat:@"startLiveTime:%f",timeStartLive];
        NSLog(@"timeStartLive___%f",timeStartLive);
        [weakSelf.arrMessage addObjectsFromArray:chatArray];
        [weakSelf.tableView reloadData];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeObserver];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addObserver];
}

- (CCStreamerBasic *)stremer
{
    if (!_stremer) {
        _stremer = [CCStreamerBasic sharedStreamer];
    }
    return _stremer;
}

#pragma mark -- 组件化 | 聊天
- (CCChatManager *)ccChatManager
{
    if (!_ccChatManager) {
        _ccChatManager = [CCChatManager sharedChat];
    }
    return _ccChatManager;
}

#pragma mark -- 组件化关联
- (void)initBaseSDKComponent
{
    self.stremer.videoMode = CCVideoPortrait;
    //聊天
    [self.stremer addObserver:self.ccChatManager];
    [self.ccChatManager addBasicClient:self.stremer];
}

#pragma mark -- 接收
-(void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveSocketEvent object:nil];
}
-(void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)initUI
{
#define KKSPACE 100
    
    WS(weakSelf);
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.view).offset(10);
        make.top.mas_equalTo(weakSelf.view).offset(80);
        make.height.mas_equalTo(160);
        make.width.mas_equalTo(280);
    }];
    
    [self.view addSubview:self.imageV];
    [self.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view);
        make.left.mas_equalTo(weakSelf.view);
        make.width.height.mas_equalTo(120);
    }];
    
    [self.view addSubview:self.textField];
    [self.view addSubview:self.btnSend];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.tableView.mas_bottom).offset(10);
        make.left.mas_equalTo(weakSelf.view).offset(10);
        make.right.mas_equalTo(weakSelf.btnSend.mas_left).offset(10);
        make.height.mas_equalTo(35);
    }];
    
    [self.btnSend mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(weakSelf.textField);
        make.right.mas_equalTo(weakSelf.tableView.mas_right);
        make.width.mas_equalTo(60);
    }];
    
    [self.view addSubview:self.btnImage];
    [self.btnImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(weakSelf.tableView);
        make.top.mas_equalTo(weakSelf.textField.mas_bottom).offset(20);
        make.height.mas_equalTo(35);
    }];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [UITableView new];
        _tableView.backgroundColor = [UIColor lightGrayColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrMessage.count;
}

- (ChatTableViewCell *)createCellContentPic:(BOOL)isPic table:(UITableView *)tableView
{
    NSString *resuseString = isPic ? @"pic":@"msg";
    NSString *cellReuseIndertifer = resuseString;
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIndertifer];
    if (!cell)
    {
        cell = [[ChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIndertifer];
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
/*
 Dialogue *dialogue = [[Dialogue alloc] init];
 dialogue.userid = dic[@"userid"];
 dialogue.username = [dic[@"username"] stringByAppendingString:@": "];
 dialogue.userrole = dic[@"userrole"];
 NSString *msg = dic[@"msg"];
 if ([msg isKindOfClass:[NSString class]] || [msg isKindOfClass:[NSMutableString class]])
 {
 //        dialogue.msg = msg;
 dialogue.msg = [Dialogue removeLinkTag:msg];
 dialogue.type = DialogueType_Text;
 }
 else
 {
 dialogue.picInfo = (NSDictionary *)msg;
 dialogue.type = DialogueType_Pic;
 }
 */
    ChatTableViewCell *cell = nil;
    NSDictionary *dicMsg = self.arrMessage[indexPath.row];
    id msg = dicMsg[@"msg"];
    
    if ([msg isKindOfClass:[NSString class]] || [msg isKindOfClass:[NSMutableString class]])
    {
        cell = [self createCellContentPic:NO table:tableView];
    }
    else
    {
        cell = [self createCellContentPic:YES table:tableView];
    }
    NSString *role =dicMsg[@"userrole"];
    if ([role isEqualToString:@"talker"])
    {
        [cell setRole:RoleType_Student];
    }
    else if([role isEqualToString:@"presenter"])
    {
        [cell setRole:RoleType_Teacher];
    }
    else
    {
        [cell setRole:RoleType_Unknow];
    }
    if ([msg isKindOfClass:[NSString class]] || [msg isKindOfClass:[NSMutableString class]])
    {
        NSString *username = dicMsg[@"username"];
        NSString *newL = [NSString stringWithFormat:@"%@:%@",username,msg];
        cell.labelName.text = newL;
    }
    else
    {
        NSString *urlString = dicMsg[@"msg"][@"content"];
        NSString *username = dicMsg[@"username"];
        NSString *newL = [NSString stringWithFormat:@"%@:",username];
        cell.labelName.text = newL;
        
        NSURL *urlImage = [NSURL URLWithString:urlString];
        [cell.imageV sd_setImageWithURL:urlImage];
    }
  
    return cell;
}


- (UIImageView *)imageV
{
    if (!_imageV) {
        _imageV = [[UIImageView alloc]init];
        _imageV.backgroundColor = [UIColor lightGrayColor];
    }
    return _imageV;
}

- (UIButton *)btnImage
{
    if (!_btnImage)
    {
        _btnImage = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnImage.backgroundColor = [UIColor orangeColor];
        [_btnImage setTitle:@"选择图片" forState:UIControlStateNormal];
        [_btnImage addTarget:self action:@selector(selectImage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnImage;
}

#pragma mark - send Pic
- (void)selectImage
{
    self.textField.text = @"";
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
    [self pushImagePickerController];
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
                    ws.imageV.image = photos.lastObject;
                }
            }];
        }];
        
        [imagePickerVc setImagePickerControllerDidCancelHandle:^{
        
        }];
        
        [ws.navigationController presentViewController:imagePickerVc animated:YES completion:nil];
    });
}


- (UITextField *)textField
{
    if (!_textField)
    {
        _textField = [[UITextField alloc]init];
        _textField.placeholder = @"请输入需要发送的消息";
        _textField.backgroundColor = [UIColor lightGrayColor];
    }
    return _textField;
}

- (UIButton *)btnSend
{
    if (!_btnSend)
    {
        _btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnSend.backgroundColor = [UIColor orangeColor];
        [_btnSend setTitle:@"发送" forState:UIControlStateNormal];
        [_btnSend addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnSend;
}

- (void)sendMessage
{
    WS(weakSelf);
    NSString *text = self.textField.text;
    UIImage *image = self.imageV.image;
    self.imageV.image = nil;
    if (image)
    {
        [self.ccChatManager sendImage:image completion:^(BOOL result, NSError *error, id info) {
            weakSelf.imageV.image = nil;
            
        }];
        return;
    }
    if (text && [text length] > 0) {
        [self.ccChatManager sendMsg:text];
    }
    self.textField.text = @"";
}

- (void)receiveSocketEvent:(NSNotification *)noti
{
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    id value = noti.userInfo[@"value"];
    NSLog(@"%s__%@__%@", __func__, noti.name, @(event));
    
    if (event == CCSocketEvent_Chat)
    {
        NSLog(@"%d", __LINE__);
        //聊天信息
        [self chat_message:value];
    }
    else if (event == CCSocketEvent_GagOne)
    {
        //判断自己是否被禁言
        BOOL isSelfGag = [self.ccChatManager isUserGag];
    }
    else if (event == CCSocketEvent_GagAll)
    {
        //判断房间是否被禁言
        BOOL isSelfGag = [self.ccChatManager isRoomGag];
    }
    else if (event == CCSocketEvent_LianmaiStateUpdate)
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
}

- (void)chat_message:(NSDictionary *)dic
{
    CCLog(@"chat_message_received:%@",dic);
    [self.arrMessage addObject:dic];
    [self.tableView reloadData];
    [self scrollToBottom];
}

- (void)scrollToBottom
{
    CGFloat yOffset = 0; //设置要滚动的位置 0最顶部 CGFLOAT_MAX最底部
    if (self.tableView.contentSize.height > self.tableView.bounds.size.height)
    {
        yOffset = self.tableView.contentSize.height - self.tableView.bounds.size.height;
    }
    [self.tableView setContentOffset:CGPointMake(0, yOffset) animated:YES];
}



@end
