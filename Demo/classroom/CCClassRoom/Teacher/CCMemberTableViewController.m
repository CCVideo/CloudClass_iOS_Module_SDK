//
//  CCMemberTableViewController.m
//  CCClassRoom
//
//  Created by cc on 17/1/18.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCMemberTableViewController.h"
#import "DefinePrefixHeader.pch"
#import "CCStudentActionManager.h"
#import "SULogger.h"
#import <BlocksKit+UIKit.h>
#import "LoadingView.h"
#import <AFNetworking.h>
#import "CCRewardView.h"
#import "CCTipsView.h"

@implementation CCMemberModel
- (id)initWithDic:(NSDictionary *)info blackList:(NSArray *)blackList
{
    if (self = [super init])
    {
        self.userID = info[@"id"];
        self.name = info[@"name"];
        self.micType = (CCUserMicStatus)[info[@"status"] integerValue];
        self.requestTime = [info[@"requestTime"] doubleValue];
        self.publishTime = [info[@"publishTime"] doubleValue];
        self.streamID = info[@"streamId"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH.mm.ss";
        NSString *time = info[@"joinTime"];
        NSDate *date = [dateFormatter dateFromString:time];
        self.joinTime = [date timeIntervalSince1970];
        
        for (NSString *userID in blackList)
        {
            if ([userID isEqualToString:self.userID])
            {
                self.isMute = YES;
                break;
            }
        }
        
        NSInteger paltform = [info[@"platform"] integerValue];
        if (paltform == 2 || paltform == 3)
        {
            self.loginType = CCUserPlatform_Mobile;
        }
        else
        {
            self.loginType = CCUserPlatform_PC;
        }
        NSString *role = info[@"role"];
        if ([role isEqualToString:KKEY_CCRole_Student])
        {
            //学生
            self.type = CCMemberType_Student;
        }
        else if ([role isEqualToString:KKEY_CCRole_Teacher])
        {
            self.type = CCMemberType_Teacher;
            //            self.micType = CCUserMicStatus_None;
        }
        else if ([role isEqualToString:KKEY_CCRole_Assistant])
        {
            self.type = CCMemberType_Assistant;
        }
    }
    return self;
}

- (id)initWithUser:(CCUser *)user
{
    if (self = [super init])
    {
        self.userID = user.user_id;
        self.name = user.user_name;
        self.micType = user.user_status;
        self.requestTime = user.user_requestTime;
        self.publishTime = user.user_publishTime;
        self.streamID = user.user_streamID;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH.mm.ss";
        NSString *time = user.user_joinTime;
        NSDate *date = [dateFormatter dateFromString:time];
        self.joinTime = [date timeIntervalSince1970];
        self.isMute = !user.user_chatState;
        self.drawStatus = user.user_drawState;
        
        self.loginType = user.user_platform;
        if (user.user_role == CCRole_Student)
        {
            //学生
            self.type = CCMemberType_Student;
        }
        else if (user.user_role == CCRole_Teacher)
        {
            self.type = CCMemberType_Teacher;
            //            self.micType = CCUserMicStatus_None;
        }
        else if (user.user_role == CCRole_Assistant)
        {
            self.type = CCMemberType_Assistant;
        }
    }
    return self;
}
@end

@interface CCMemberTableViewCell : UITableViewCell
@property (strong, nonatomic) UIImageView *logintypeIcon;
@property (strong, nonatomic) UILabel *nameLabel;//名字
@property (strong, nonatomic) UIImageView *typeIcon;//身份
@property (strong, nonatomic) UIImageView *rewardIcon;//奖励图标
@property (strong, nonatomic) UILabel *rewardCount; //奖励数量

@property (strong, nonatomic) UIImageView *micIcon;
@property (strong, nonatomic) UILabel *micNumLabel;
@property (strong, nonatomic) UIImageView *micTypeIcon;//正在连麦还是排麦中
@property (strong, nonatomic) UIImageView *isMuteIcon;//禁言
@property (strong, nonatomic) UIImageView *rightActionImageView;
@property (strong, nonatomic) UIView *line;
@property (strong, nonatomic) UIImageView *handupStateImageView;//学生音频状态
@property (strong, nonatomic) UIImageView *drawStateImageView;//授权标注图标

//micnumlabel -> isMuteIcon -> drawstate -> handupstate -> mictypeIcon
@end

@implementation CCMemberTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self addSubview:self.logintypeIcon];
        [self addSubview:self.nameLabel];
        [self addSubview:self.typeIcon];
        [self addSubview:self.rewardIcon];
        [self addSubview:self.rewardCount];
        [self addSubview:self.micIcon];
        [self addSubview:self.micNumLabel];
        [self addSubview:self.isMuteIcon];
        [self addSubview:self.drawStateImageView];
        [self addSubview:self.handupStateImageView];
        [self addSubview:self.micTypeIcon];
        [self addSubview:self.rightActionImageView];
        [self addSubview:self.line];
        WS(ws);
        [self.logintypeIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.mas_left).offset(CCGetRealFromPt(20));
            make.centerY.mas_equalTo(ws);
        }];
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.logintypeIcon.mas_right).offset(CCGetRealFromPt(15));
            make.centerY.mas_equalTo(ws);
        }];
        [self.typeIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.nameLabel.mas_right).offset(CCGetRealFromPt(7));
            make.centerY.mas_equalTo(ws);
        }];
        [self.rewardIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.typeIcon.mas_right).offset(CCGetRealFromPt(7));
            make.centerY.mas_equalTo(ws);
        }];
        [self.rewardCount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.rewardIcon.mas_right).offset(CCGetRealFromPt(7));
            make.centerY.mas_equalTo(ws);
        }];
        
        [self.rightActionImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.mas_right).offset(-CCGetRealFromPt(20));
            make.centerY.mas_equalTo(ws);
        }];
        [self.micTypeIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.rightActionImageView.mas_left).offset(-CCGetRealFromPt(10));
            make.centerY.mas_equalTo(ws);
        }];
        [self.handupStateImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.micTypeIcon.mas_left).offset(-CCGetRealFromPt(10));
            make.centerY.mas_equalTo(ws);
        }];
        [self.drawStateImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.handupStateImageView.mas_left).offset(-CCGetRealFromPt(10));
            make.centerY.mas_equalTo(ws);
        }];
        [self.isMuteIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.drawStateImageView.mas_left).offset(-CCGetRealFromPt(10));
            make.centerY.mas_equalTo(ws);
        }];
        [self.micNumLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.isMuteIcon.mas_left).offset(-CCGetRealFromPt(10));
            make.centerY.mas_equalTo(ws);
        }];
        [self.micIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.micNumLabel.mas_left).offset(-CCGetRealFromPt(10));
            make.centerY.mas_equalTo(ws);
        }];
        
        [self.line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws);
            make.bottom.mas_equalTo(ws);
            make.height.mas_equalTo(0.5);
        }];
    }
    return self;
}

- (void)configWithModel:(CCMemberModel*)model
{
    if (model.loginType == CCUserPlatform_PC)
    {
        //pc登录
        self.logintypeIcon.image = [UIImage imageNamed:@"computer"];
    }
    else
    {
        self.logintypeIcon.image = [UIImage imageNamed:@"phone"];
    }
    self.nameLabel.text = model.name;
    CGSize size = [CCTool getTitleSizeByFont:model.name font:[UIFont systemFontOfSize:FontSizeClass_13]];
    float width = size.width > 120 ? 120 : size.width + 2;
    WS(ws);
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.logintypeIcon.mas_right).offset(CCGetRealFromPt(15));
        make.centerY.mas_equalTo(ws);
        make.width.mas_equalTo(width);
    }];
    self.typeIcon.hidden = model.type == CCMemberType_Teacher ? NO : YES;
    
    MASViewAttribute *rightView = self.mas_right;
    if (model.type == CCMemberType_Teacher)
    {
        self.rightActionImageView.hidden = NO;
        self.micTypeIcon.hidden = YES;
        self.handupStateImageView.hidden = YES;
        self.drawStateImageView.hidden = YES;
        self.isMuteIcon.hidden = YES;
        self.micNumLabel.hidden = YES;
        self.micIcon.hidden = YES;
        [self.rightActionImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(rightView).offset(-CCGetRealFromPt(20));
            make.centerY.mas_equalTo(ws);
        }];
        rightView = self.rightActionImageView.mas_left;
    }
    else
    {
        self.rightActionImageView.hidden = YES;
        if (model.micType == CCUserMicStatus_Connected)
        {
            self.micTypeIcon.hidden = NO;
            [self.micTypeIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(rightView).offset(-CCGetRealFromPt(10));
                
                make.centerY.mas_equalTo(ws);
            }];
            rightView = self.micTypeIcon.mas_left;
        }
        else
        {
            self.micTypeIcon.hidden = YES;
        }
        if (model.handup)
        {
            self.handupStateImageView.hidden = NO;
            [self.handupStateImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(rightView).offset(-CCGetRealFromPt(10));
                make.centerY.mas_equalTo(ws);
            }];
            rightView = self.handupStateImageView.mas_left;
        }
        else
        {
            self.handupStateImageView.hidden = YES;
        }
        if (model.drawStatus)
        {
            self.drawStateImageView.hidden = NO;
            [self.drawStateImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(rightView).offset(-CCGetRealFromPt(10));
                make.centerY.mas_equalTo(ws);
            }];
            rightView = self.drawStateImageView.mas_left;
        }
        else
        {
            self.drawStateImageView.hidden = YES;
        }
        if (model.isMute)
        {
            self.isMuteIcon.hidden = NO;
            [self.isMuteIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(rightView).offset(-CCGetRealFromPt(10));
                make.centerY.mas_equalTo(ws);
            }];
            rightView = self.isMuteIcon.mas_left;
        }
        else
        {
            self.isMuteIcon.hidden = YES;
        }
        if(model.micType == CCUserMicStatus_Wait || model.micType == CCUserMicStatus_Inviteing)
        {
            self.micIcon.hidden = NO;
            self.micNumLabel.hidden = NO;
            if ([[CCStreamerBasic sharedStreamer] getRoomInfo].room_class_type == CCClassType_Auto)
            {
                self.micNumLabel.text = [NSString stringWithFormat:@"第%ld位，排麦中...", (long)model.micNum];
                self.micIcon.image = [UIImage imageNamed:@"clock"];
            }
            else
            {
                if (model.micType == CCUserMicStatus_Wait)
                {
                    self.micNumLabel.text = [NSString stringWithFormat:@"第%ld位，举手中...", (long)model.micNum];
                    self.micIcon.image = [UIImage imageNamed:@"hangs3"];
                }
                else
                {
                    self.micNumLabel.text = [NSString stringWithFormat:@"邀请连麦中..."];
                    self.micIcon.image = [UIImage imageNamed:@"invite"];
                }
            }
            [self.micNumLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(rightView).offset(-CCGetRealFromPt(10));
                make.centerY.mas_equalTo(ws);
            }];
            rightView = self.micNumLabel.mas_left;
            [self.micIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(rightView).offset(-CCGetRealFromPt(10));
                make.centerY.mas_equalTo(ws);
            }];
        }
        else
        {
            self.micIcon.hidden = YES;
            self.micNumLabel.hidden = YES;
        }
    }
}

- (void)setRewardRole:(CCMemberType)memberType count:(int)count reload:(BOOL)reload
{
    //计数
    int countFinal = 0;
    if (count == 0)
    {
        countFinal = 0;
    }
    else
    {
        NSString *text = self.rewardCount.text;
        if (reload)
        {
            text = @"";
        }
        text = [text stringByReplacingOccurrencesOfString:@"X" withString:@""];
        text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
        countFinal = [text intValue] + count;
        self.rewardCount.text = [NSString stringWithFormat:@"X %d",countFinal];
    }
    if (countFinal == 0)
    {
        self.rewardIcon.image = nil;
        self.rewardCount.text = @"";
    }
    else if (memberType == CCMemberType_Teacher && countFinal > 0)
    {
        self.rewardIcon.image = [UIImage imageNamed:@"flower_small"];
    }
    else
    {
        self.rewardIcon.image = [UIImage imageNamed:@"cup_small"];
    }
}
#pragma mark - 懒加载
- (UIImageView *)rightActionImageView
{
    if (!_rightActionImageView)
    {
        _rightActionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"talking"]];
    }
    return _rightActionImageView;
}

- (UIImageView *)logintypeIcon
{
    if (!_logintypeIcon)
    {
        _logintypeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"computer"]];
    }
    return _logintypeIcon;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel)
    {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:FontSizeClass_13];
    }
    return _nameLabel;
}

- (UIImageView *)typeIcon
{
    if (!_typeIcon)
    {
        _typeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"teacher"]];
    }
    return _typeIcon;
}
//奖励：奖杯、鲜花
- (UIImageView *)rewardIcon
{
    if (!_rewardIcon)
    {
        _rewardIcon = [[UIImageView alloc]init];
    }
    return _rewardIcon;
}

- (UILabel *)rewardCount
{
    if (!_rewardCount)
    {
        _rewardCount = [[UILabel alloc]init];
        _rewardCount.font = [UIFont systemFontOfSize:12];
        _rewardCount.text = @"";
    }
    return _rewardCount;
}
- (UIImageView *)micIcon
{
    if (!_micIcon)
    {
        _micIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock"]];
    }
    return _micIcon;
}

- (UIImageView *)isMuteIcon
{
    if (!_isMuteIcon)
    {
        _isMuteIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"prohibit"]];
        
    }
    return _isMuteIcon;
}

- (UIImageView *)micTypeIcon
{
    if (!_micTypeIcon)
    {
        _micTypeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"talking"]];
    }
    return _micTypeIcon;
}

- (UILabel *)micNumLabel
{
    if (!_micNumLabel)
    {
        _micNumLabel = [[UILabel alloc] init];
        _micNumLabel.font = [UIFont systemFontOfSize:FontSizeClass_15];
        _micNumLabel.textColor = CCRGBColor(255, 102, 51);
    }
    return _micNumLabel;
}

- (UIView *)line
{
    if (!_line)
    {
        UIView *line = [UIView new];
        [line setBackgroundColor:CCRGBColor(229,229,229)];
        _line = line;
    }
    return _line;
}

- (UIImageView *)handupStateImageView
{
    if (!_handupStateImageView)
    {
        _handupStateImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hangs3"]];
    }
    return _handupStateImageView;
}

- (UIImageView *)drawStateImageView
{
    if (!_drawStateImageView)
    {
        _drawStateImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pen"]];
    }
    return _drawStateImageView;
}

@end

@interface CCMemberTableViewController ()<UIActionSheetDelegate>
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) CCMemberModel *selectedModel;
@property (strong, nonatomic) UILabel *footerView;
@property (assign, nonatomic) NSInteger audienceCount;
@property (nonatomic, strong) CCStudentActionManager *actionManager;
@property (nonatomic, strong) NSTimer              *room_user_cout_timer;//获取房间人数定时器
@property (strong, nonatomic) LoadingView *loadingView;
@property(nonatomic, assign) BOOL isTouch;
@end

#define ACTIONSHEETTAGONE 1001
#define ACTIONSHEETTAGTWO 1002
#define ACTIONSHEETTAGTHTREE 1003
#define ACTIONSHEETTAGFOUR 1004
#define ACTIONSHEETTAGFIVE 1005

@implementation CCMemberTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[CCMemberTableViewCell class] forCellReuseIdentifier:@"ccMemberReuseIdentifier"];
    self.tableView.tableFooterView = [UIView new];
    
    [self addObserver];
    [self makeData:[[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList];
    self.footerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 49)];
    self.footerView.font = [UIFont systemFontOfSize:FontSizeClass_13];
    self.footerView.textColor = [UIColor colorWithRed:136.f/255.f green:136.f/255.f blue:136.f/255.f alpha:1.f];
    
    self.audienceCount = [CCStreamerBasic sharedStreamer].getRoomInfo.room_user_count - [[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList.count;
    if (self.audienceCount < 0)
    {
        self.audienceCount = 0;
    }

    self.footerView.text = [NSString stringWithFormat:@"还有%ld位旁听学生", (long)self.audienceCount];
    self.footerView.textAlignment = NSTextAlignmentCenter;
    self.tableView.tableFooterView = self.footerView;
    self.tableView.separatorColor = CCRGBColor(229, 229, 229);
    
    if (self.audienceCount == 0)
    {
        self.footerView.hidden = YES;
    }
    else
    {
        self.footerView.hidden = NO;
    }
    
    UILongPressGestureRecognizer *tap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showLog:)];
    tap.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:tap];
    CCWeakProxy *weakProxy = [CCWeakProxy proxyWithTarget:self];
    self.room_user_cout_timer = [NSTimer scheduledTimerWithTimeInterval:3.f target:weakProxy selector:@selector(room_user_count) userInfo:nil repeats:YES];
    
    self.isTouch = NO;
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.room_user_cout_timer)
    {
        [self.room_user_cout_timer invalidate];
        self.room_user_cout_timer = nil;
    }
}

- (void)showLog:(UILongPressGestureRecognizer *)ges
{
    if (ges.state == UIGestureRecognizerStateBegan)
    {
        [SULogger visibleChange];
    }
}

- (void)userMuteStateChange:(NSNotification *)noti
{
    NSString *userID = noti.userInfo[@"value"];
    BOOL isMute = [noti.userInfo[@"state"] boolValue];
    for (CCMemberModel *model in self.data)
    {
        if ([model.userID isEqualToString:userID])
        {
            model.isMute = isMute;
            [self.tableView reloadData];
            break;
        }
    }
}

- (void)receiveSocketEvent:(NSNotification *)noti
{
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    id value = noti.userInfo[@"value"];

    if (event == CCSocketEvent_UserListUpdate || event == CCSocketEvent_GagOne)
    {
        //在线列表
        [self makeData:[[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList];
        if (event == CCSocketEvent_GagOne)
        {
            if (![CCTool controllerIsShow:self]) return;

            BOOL isMute = [[CCStreamerBasic sharedStreamer] getRoomInfo].allow_chat;
            CCUser *user = noti.userInfo[@"user"];
            if ([user.user_id isEqualToString:[CCStreamerBasic sharedStreamer].getRoomInfo.user_id])
            {
                NSString *title = !isMute ? @"您被老师开启禁言" : @"您被老师关闭禁言";
                [UIAlertView bk_showAlertViewWithTitle:@"注意" message:title cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                }];
            }
        }
    }
    else if (event == CCSocketEvent_UserCountUpdate)
    {
        self.audienceCount = [noti.userInfo[@"audienceCount"] integerValue];
        self.footerView.text = [NSString stringWithFormat:@"还有%ld位旁听学生", (long)self.audienceCount];
        if (self.audienceCount == 0)
        {
            self.footerView.hidden = YES;
        }
        else
        {
            self.footerView.hidden = NO;
        }
        NSInteger count = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_user_count;
        self.title = [NSString stringWithFormat:@"%@个成员", @(count)];
    }
    else if (event == CCSocketEvent_LianmaiStateUpdate || event == CCSocketEvent_HandupStateChanged)
    {
        //连麦状态变化
        [self makeData:[[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList];
    }
    else if (event == CCSocketEvent_AudioStateChanged || event == CCSocketEvent_VideoStateChanged)
    {
        //麦克风、视频状态变化
        [self makeData:[[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList];
        if (event == CCSocketEvent_AudioStateChanged)
        {
            if (![CCTool controllerIsShow:self]) return;

            CCUser *user = noti.userInfo[@"user"];
            BOOL changeByTeacher = [noti.userInfo[@"byTeacher"] boolValue];
            if ([user.user_id isEqualToString:[[CCStreamerBasic sharedStreamer] getRoomInfo].user_id] && self.navigationController.visibleViewController == self && changeByTeacher)
            {
                BOOL isMute = [[CCStreamerBasic sharedStreamer] getRoomInfo].audioState;
                NSString *title = isMute ? @"您被老师开启麦克风" : @"您被老师关闭麦克风";
                [UIAlertView bk_showAlertViewWithTitle:@"注意" message:title cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                }];
            }
        }
    }
    else if (event == CCSocketEvent_ReciveDrawStateChanged)
    {
        //授权标注列表变动
        [self makeData:[[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList];
    }
//    else if(event == CCSocketEvent_Flower)
//    {
//        [self rewardFlower:value];
//    }
    else if (event == CCSocketEvent_Cup)
    {
        [self rewardCup:value];
//        [self makeData:[[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList];
    }
    else if (event == CCSocketEvent_PublishEnd || event == CCSocketEvent_PublishStart)
    {
        [self makeData:[[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList];
    }
}

//reward 奖励、鲜花
- (void)rewardFlower:(id)obj
{
    NSLog(@"rewardFlower__%@",obj);
    NSDictionary *dicData = obj[@"data"];
    NSString *uid = dicData[@"uid"];
   
    [self reward_flower_cup_ui:uid count:1];
}
- (void)rewardCup:(id)obj
{
    NSLog(@"rewardCup__%@",obj);
    NSDictionary *dicData = obj[@"data"];
    NSString *uid = dicData[@"uid"];
    
    [self reward_flower_cup_ui:uid count:1];
}
//更新鲜花、
- (void)reward_flower_cup_ui:(NSString *)uid count:(int)count
{
    NSString *uidLocal = uid;
    int index = (int)[self indexForUserId:uidLocal];
    CCMemberModel *model = [self modelForUid:uid];
    CCMemberTableViewCell *cell = [self cellForIndex:index];
    if (!model)
    {//人员已经不存在
        return;
    }
    if (count > 1)
    {
        [cell setRewardRole:model.type count:count reload:YES];
    }
    else
    {
        [cell setRewardRole:model.type count:count reload:NO];
    }
}
- (void)reward_update_ui:(NSString *)uid count:(int)count
{
    NSString *uidLocal = uid;
    int index = (int)[self indexForUserId:uidLocal];
    CCMemberModel *model = [self modelForUid:uid];
    CCMemberTableViewCell *cell = [self cellForIndex:index];
    if (!model)
    {//人员已经不存在
        return;
    }
    [cell setRewardRole:model.type count:count reload:YES];
}

//获取展示的用户
- (NSUInteger)indexForUserId:(NSString *)uid
{
    if (!self.data)
    {
        return -1;
    }
    NSUInteger indx = 0;
    for (CCMemberModel *mode in self.data)
    {
        if ([mode.userID isEqualToString:uid])
        {
            indx = [self.data indexOfObject:mode];
            break;
        }
    }
    return indx;
}

- (CCMemberTableViewCell *)cellForIndex:(int)index
{
    NSIndexPath *indexP = [NSIndexPath indexPathForRow:index inSection:0];
    CCMemberTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexP];
    return cell;
}

- (CCMemberModel *)modelForUid:(NSString *)uid
{
    for (CCMemberModel *mode in self.data)
    {
        if ([mode.userID isEqualToString:uid])
        {
            return mode;
        }
    }
    return nil;
}

- (void)showAutoHiddenAlert:(NSString *)title
{
    UIAlertView *alertV = [UIAlertView bk_alertViewWithTitle:title];
    [alertV show];
    
    [self performSelector:@selector(alertViewAutoHide:) withObject:alertV afterDelay:1];
}

- (void)alertViewAutoHide:(UIAlertView *)alertView
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)showData:(NSArray *)data
{
    
}

-(void)makeData:(NSArray *)list
{
    NSInteger count = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_user_count;
    self.title = [NSString stringWithFormat:@"%@个成员", @(count)];
    NSMutableArray *data = [NSMutableArray array];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH.mm.ss";
    if (list)
    {
        NSMutableArray *studentData = [NSMutableArray array];
        NSMutableArray *teacherData = [NSMutableArray array];
        NSMutableArray *studentWaitData = [NSMutableArray array];
        
        CCClassType mode = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_class_type;
        for (CCUser *info in list)
        {
            CCMemberModel *model = [[CCMemberModel alloc] init];
            model.handup = info.handup;
            model.userID = info.user_id;
            model.name = info.user_name;
            model.micType = info.user_status;
            model.requestTime = info.user_requestTime;
            model.publishTime = info.user_publishTime;
            model.streamID = info.user_streamID;
            model.drawStatus = info.user_drawState;
            NSString *time = info.user_joinTime;
            NSDate *date = [dateFormatter dateFromString:time];
            model.joinTime = [date timeIntervalSince1970];
            //            NSInteger paltform = info.user_platform;
            model.isMute = !info.user_chatState;
            model.loginType = info.user_platform;
            CCRole role = info.user_role;
            if (role == CCRole_Student)
            {
                //学生
                model.type = CCMemberType_Student;
                if (mode == CCClassType_Auto)
                {
                    if (model.micType == CCUserMicStatus_Wait || model.micType == CCUserMicStatus_Connecting)
                    {
                        //排麦中、上麦显示在顶部
                        [studentWaitData addObject:model];
                    }
                    else
                    {
                        [studentData insertObject:model atIndex:0];
                    }
                }
                else
                {
                    if (model.micType == CCUserMicStatus_Wait)
                    {
                        //排麦中、上麦显示在顶部
                        [studentWaitData addObject:model];
                    }
                    else
                    {
                        [studentData insertObject:model atIndex:0];
                    }
                }
            }
            else if (role == CCRole_Teacher)
            {
                model.type = CCMemberType_Teacher;
                //这里老师显示逻辑和学生一样
                //                model.micType = CCUserMicStatus_None;
                [teacherData insertObject:model atIndex:0];
            }
            else if (role == CCRole_Assistant)
            {
                //助教角色
                model.type = CCMemberType_Assistant;
                [teacherData insertObject:model atIndex:0];
            }
        }
        [studentWaitData sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            CCMemberModel *model1 = obj1;
            CCMemberModel *model2 = obj2;
            if (model1.requestTime >= model2.requestTime)
            {
                return NSOrderedDescending;
            }
            else
            {
                return NSOrderedAscending;
            }
        }];
        [studentData sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            CCMemberModel *model1 = obj1;
            CCMemberModel *model2 = obj2;
            if (model1.joinTime >= model2.joinTime)
            {
                return NSOrderedDescending;
            }
            else
            {
                return NSOrderedAscending;
            }
        }];
        int i = 1;
        for (CCMemberModel *model in studentWaitData)
        {
            model.micNum = i;
            i++;
        }
        [data addObjectsFromArray:teacherData];
        [data addObjectsFromArray:studentWaitData];
        [data addObjectsFromArray:studentData];
    }
    self.data = data;
    [self.tableView reloadData];
    
    [self updateFlowerAndCupData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *resuseIndentifier = @"ccMemberReuseIdentifier";
    CCMemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:resuseIndentifier forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[CCMemberTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resuseIndentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CCMemberModel *model = self.data[indexPath.row];
    [cell configWithModel:model];
    [cell setRewardRole:model.type count:0 reload:NO];
    if (indexPath.row == self.data.count - 1)
    {
        cell.line.hidden = NO;
    }
    else
    {
        cell.line.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCLiveStatus statusLive = [[CCStreamerBasic sharedStreamer]getRoomInfo].live_status;
    if (statusLive == CCLiveStatus_Stop) {
        [self showAutoHiddenAlert:@"直播未开始！"];
        return;
    }
    NSLog(@"ccc--:%ld",(long)indexPath.row);
    CCMemberModel *model = self.data[indexPath.row];
    if (model.type == CCMemberType_Teacher)
    {
        //助教不能操作老师
        return;
    }
    CCRole roleLocal = [[CCStreamerBasic sharedStreamer]getRoomInfo].user_role;
    if (roleLocal == CCRole_Teacher)
    {
        [self localTeacherClick:model];
    }
    else if (roleLocal == CCRole_Assistant)
    {
        [self localAssistantClick:model];
    }
    else if (roleLocal == CCRole_Student)
    {
        [self localStudentClick:model];
    }
}
#pragma mark -- 当前角色是老师
- (void)localTeacherClick:(CCMemberModel *)model
{
    if (model.type == CCMemberType_Student)
    {
        [self localTeacherClickStudent:model];
    }
    if (model.type == CCMemberType_Assistant)
    {
        [self localTeacherClickAssistant:model];
    }
}
//所有权限
- (void)localTeacherClickStudent:(CCMemberModel *)model
{
    [self teacher_clicked:model tableView:self.tableView];
}
//禁言、踢出房间
- (void)localTeacherClickAssistant:(CCMemberModel *)model
{
    [self assistant_teacher_event:model tableView:self.tableView];
}
#pragma mark -- 当前角色是助教
- (void)localAssistantClick:(CCMemberModel *)model
{
    if (model.type == CCMemberType_Student)
    {
        [self localAssistantClickStudent:model];
    }
    if (model.type == CCMemberType_Teacher)
    {
        [self assistant_teacher_event:model tableView:self.tableView];
    }
}
- (void)localAssistantClickStudent:(CCMemberModel *)model
{
    [self teacher_clicked:model tableView:self.tableView];
}
#pragma mark -- 当前角色是学生
- (void)localStudentClick:(CCMemberModel *)model
{
    //学生没有操作权限
    NSLog(@"localStudentClick__");
}

//点击事件
- (void)student_clicked:(CCMemberModel *)model tableView:(UITableView *)tableView
{
    CCShareObject *shareObj = [CCShareObject sharedObj];
    BOOL allowSend = shareObj.isAllowSendFlower;
    if (!allowSend)
    {
        [[CCTipsView new] showMessage:@"鲜花生长中，3分钟后才可以送出哟！"];
        return;
    }
    self.actionManager = [CCStudentActionManager new];
    self.actionManager.ccVideoView = self.ccDocVideoView;
    [self.actionManager studentCallWithUserID:model.userID inView:self.view dismiss:^(BOOL result, id info) {
        [tableView reloadData];
    }];
}

- (void)teacher_clicked:(CCMemberModel *)model tableView:(UITableView *)tableView
{
    self.actionManager = [CCStudentActionManager new];
    self.actionManager.ccVideoView = self.ccDocVideoView;
    [self.actionManager showWithUserID:model.userID inView:self.view dismiss:^(BOOL result, id info) {
        //[tableView reloadData];
    }];
}
//老师、助教
- (void)assistant_teacher_event:(CCMemberModel *)model tableView:(UITableView *)tableView
{
    self.actionManager = [CCStudentActionManager new];
    self.actionManager.ccVideoView = self.ccDocVideoView;
    [self.actionManager assistant:YES callModel:model inView:self.view dismiss:^(BOOL result, id info) {

    }];
}

#pragma mark -
- (void)room_user_count
{
//    [[CCStreamerBasic sharedStreamer] updateUserCount];
}


-(void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveSocketEvent object:nil];
}

-(void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiReceiveSocketEvent object:nil];
}

- (UIImage*)createImageWithColor: (UIColor*) color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

//===========
- (void)updateFlowerAndCupData
{
    /*
     {
     liveid = 6848A7E5569C2BCB;
     result = OK;
     started = 1;
     } */
    [[CCStreamerBasic sharedStreamer]getLiveStatus:^(BOOL result, NSError *error, id info) {
        NSString *resultString = info[@"result"];
        int start = [info[@"started"] intValue];
        if (![resultString isEqualToString:@"OK"] || start != 1)
        {
            NSString *errMsg = error.domain;
#pragma unused(errMsg)
            return ;
        }
        NSString *liveId = info[@"liveid"];
        [self getUserCountData:liveId];
    }];
}

- (void)getUserCountData:(NSString *)liveID
{
    __weak typeof(self)weakSelf = self;
    NSString *roomId = GetFromUserDefaults(LIVE_ROOMID);
    NSDictionary *par = @{
                          @"liveid":liveID,
                          @"roomid":roomId
                          };
    
    NSString *urlString = @"https://hand.csslcloud.net/backend/live/reward/";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:urlString parameters:par success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (!responseObject)
        {
            return ;
        }
        NSDictionary *dicRes = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        if (!dicRes)
        {
            return;
        }
        if (![dicRes[@"result"] isEqualToString:@"OK"])
        {
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *dicValue = dicRes[@"data"];
            NSDictionary *dicFinal = [weakSelf allUserFlowerCupData:dicValue];
            [self updateFlowerCupUI:dicFinal];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"warm_play_error!");
    }];
}

//刷新鲜花、奖杯 UI
- (NSDictionary *)allUserFlowerCupData:(NSDictionary *)dicData
{
    NSDictionary *dicFlower = dicData[@"total_flower"];
    NSDictionary *dicCup = dicData[@"total_cup"];
    
    NSMutableDictionary *dicNew = [NSMutableDictionary dictionaryWithDictionary:dicFlower];
    [dicNew addEntriesFromDictionary:dicCup];
    
    return dicNew;
}

- (void)updateFlowerCupUI:(NSDictionary *)dicValue
{
    //通过枚举类枚举
    NSEnumerator *enumerator = [dicValue keyEnumerator];
    NSString *key = nil;
    while (key = [enumerator nextObject]) {
        int count = [[dicValue objectForKey:key] intValue];
        NSLog(@"通过枚举类枚举--->%d",count);
        [self reward_update_ui:key count:count];
    }
}

- (void)showMessage:(NSString *)msg
{
    [UIAlertView bk_showAlertViewWithTitle:@"提示" message:msg cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
    }];
}

#pragma mark -- 上麦
- (void)memberStartPublish
{
    //直接调用publish
    WS(weakSelf);
    [[CCStreamerBasic sharedStreamer] startLive:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSLog(@"%s", __func__);
            dispatch_async(dispatch_get_main_queue(), ^{
                //调整btn显示隐藏
                [weakSelf showMessage:@"上麦成功！"];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.loadingView removeFromSuperview];
            });
            NSLog(@"publish error:%@", error);
        }
    }];
}

#pragma mark -- 助教下麦
- (void)memberStopPublish
{
    [[CCStreamerBasic sharedStreamer]unPublish:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            [CCTool showMessage:@"下麦成功！"];
        }
//        [[CCStreamerBasic sharedStreamer]assistDM:nil completion:^(BOOL result, NSError *error, id info) {
//
//        }];
    }];
}
///解决同意上麦中多次点击会返回到首页
- (void)onSelectVC {
    if (!self.isTouch) {
        
        self.isTouch = YES;
        
        [self.navigationController popViewControllerAnimated:true];
    }else {
        return;
    }
    
}

#pragma mark - 懒加载

#pragma mark - 内存警告和生命结束
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    [self removeObserver];
    if (self.room_user_cout_timer)
    {
        [self.room_user_cout_timer invalidate];
        self.room_user_cout_timer = nil;
    }
}
@end
