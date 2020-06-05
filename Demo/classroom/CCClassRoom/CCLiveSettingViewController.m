//
//  CCLiveSettingViewController.m
//  CCClassRoom
//
//  Created by cc on 17/1/20.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCLiveSettingViewController.h"
#import "CCLiveVideoAndAudioViewController.h"
#import "DefinePrefixHeader.pch"
#import <BlocksKit+UIKit.h>
#import "CCSettingOneTableViewCell.h"
#import "CCSettingTwoTableViewCell.h"
#import "CCRoomMaxNumCountEditViewController.h"
#import "LoadingView.h"
#import "CCPickView.h"
#import "HDSTool.h"

typedef NS_ENUM(NSInteger, CCSettingType) {
    CCSettingType_AllMute,//全体禁言
    CCSettingType_AllCloseMic,//全体关麦
    CCSettingType_AllDown,//全体下麦
    CCSettingType_VideoMirror,//视频镜像
    CCSettingType_LianmaiMode,//连麦模式
    CCSettingType_MovieAuto,//视频轮播
    CCSettingType_MovieAutoTime,//轮播频率
    CCSettingType_TeacherBitrate,//老师视频清晰度
    CCSettingType_StudentBitrate,//学生端清晰度
    CCSettingType_VideoAndAudio,//连麦音视频
};

@interface CCLiveSettingViewController ()<UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UISwitch *swi;
@property (weak, nonatomic) IBOutlet UISwitch *audioSwitch;
@property (strong, nonatomic) UISwitch *movieSwitch;
@property (strong, nonatomic) UILabel *movieTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *movieLabel;
@property (weak, nonatomic) IBOutlet UILabel *lianMaiLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxStreamsLabel;
@property (weak, nonatomic) IBOutlet UILabel *teacherBitrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *studentBitrateLabel;
@property (strong, nonatomic) NSArray *pickerViewData;
@property (strong, nonatomic) NSIndexPath *tableViewSelectedIndexpath;
@property (assign, nonatomic) NSInteger pickerViewSelectedIndex;
@property (assign, nonatomic) CCUserBitrate selectedBitrate;
@property (strong,nonatomic) LoadingView          *loadingView;
@property(nonatomic,copy)NSString   *resolutionResult;
@property(nonatomic,copy)NSString   *mirrorText;

@property(nonatomic,strong)HDSTool *hdsTool;
@property(nonatomic,strong)CCPickView *selectPicker;

@end

@implementation CCLiveSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    _mirrorText = @"";
    UIView *line = [UIView new];
    [line setBackgroundColor:CCRGBColor(229,229,229)];
    line.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 0.5f);
    self.tableView.tableFooterView = line;
    self.tableView.separatorColor = CCRGBColor(229, 229, 229);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMicType:) name:CCNotiReceiveSocketEvent object:nil];
    self.tableView.delegate = self;
    self.resolutionResult = @"240P";
    self.resolutionResult = [self.hdsTool defaultResolutionString];
}

- (HDSTool *)hdsTool
{
    return [HDSTool sharedTool];
}

- (IBAction)changed:(id)sender
{
    BOOL mute = self.swi.isOn;
    if (mute)
    {
        [[CCChatManager sharedChat] gagAll:^(BOOL result, NSError *error, id info) {
            
        }];
    }
    else
    {
        [[CCChatManager sharedChat] recoverGagAll:^(BOOL result, NSError *error, id info) {
            
        }];
    }
}

- (IBAction)changeAllMicState:(id)sender
{
    //切换麦克风状态  全体关麦
    [[CCBarleyManager sharedBarley] changeRoomAudioState:!self.audioSwitch.isOn completion:^(BOOL result, NSError *error, id info) {
        NSLog(@"%s__%d__%@__%@__%@", __func__, __LINE__, @(result), error, info);
    }];
}

#pragma mark 开启、关闭、变更轮播
- (void)changeMovieAuto:(id)sender
{
    BOOL movieAuto = self.movieSwitch.isOn;
    __weak typeof(self) weakSelf = self;
    if (movieAuto)
    {
        float time = [CCStreamerBasic sharedStreamer].getRoomInfo.rotateTime;
        //开启关闭、变更轮播
        [[CCBarleyManager sharedBarley] changeRoomRotate:CCRotateType_Open time:time completion:^(BOOL result, NSError *error, id info) {
            [weakSelf.tableView reloadData];
        }];
    }
    else
    {
        [[CCBarleyManager sharedBarley] changeRoomRotate:CCRotateType_Close time:0 completion:^(BOOL result, NSError *error, id info) {
            [weakSelf.tableView reloadData];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateData];
    [self.tableView reloadData];
}

- (void)updateData
{
    self.swi.on = ![CCStreamerBasic sharedStreamer].getRoomInfo.room_allow_chat;
    self.audioSwitch.on = ![CCStreamerBasic sharedStreamer].getRoomInfo.room_allow_audio;
    self.movieSwitch.on = [CCStreamerBasic sharedStreamer].getRoomInfo.rotateState;
    self.movieTimeLabel.text = [NSString stringWithFormat:@"%@秒", @([CCStreamerBasic sharedStreamer].getRoomInfo.rotateTime)];
    CCVideoMode micType = [CCStreamerBasic sharedStreamer].getRoomInfo.room_video_mode;
    NSString *title;
    if (micType == CCVideoMode_AudioAndVideo)
    {
        title = @"视频连麦";
    }
    else
    {
        title = @"音频连麦";
    }
    self.movieLabel.text = title;
    
    CCClassType mode = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_class_type;
    if (mode == CCClassType_Auto)
    {
        title = @"自由连麦";
    }
    else if(mode == CCClassType_Named)
    {
        title = @"举手连麦";
    }
    else
    {
        title = @"自动连麦";
    }
    self.lianMaiLabel.text = title;
    
    NSInteger count = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_max_streams;
    self.maxStreamsLabel.text = [NSString stringWithFormat:@"%@", @(count)];
    [self changeBitrate];
}

- (void)changeMicType:(NSNotification *)noti
{
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    if (event == CCSocketEvent_MediaModeUpdate)
    {
        CCVideoMode micType = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_video_mode;
        NSString *title;
        if (micType == CCVideoMode_AudioAndVideo)
        {
            title = @"音频、视频都开放";
        }
        else
        {
            title = @"仅开放音频";
        }
        self.movieLabel.text = title;
    }
    else if (event == CCSocketEvent_LianmaiModeChanged)
    {
        CCClassType mode = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_class_type;
        NSString *title;
        if (mode == CCClassType_Auto)
        {
            title = @"自由连麦";
        }
        else if(mode == CCClassType_Named)
        {
            title = @"举手连麦";
        }
        else
        {
            title = @"自动连麦";
        }
        self.lianMaiLabel.text = title;
    }
    else if (event == CCSocketEvent_MaxStreamsChanged)
    {
        NSInteger count = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_max_streams;
        self.maxStreamsLabel.text = [NSString stringWithFormat:@"%@", @(count)];
    }
    else if (event == CCSocketEvent_TeacherBitRateChanged || event == CCSocketEvent_StudentBitRateChanged)
    {
        [self changeBitrate];
    }
}

- (void)changeBitrate
{
    //该处设置学生、老师分辨率功能改为：设置 分辨率；
}

#define TOPLINETAG 1001
#define BOTTOMLINETAG 1002
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 4;
    }
    else if (section == 1)
    {
        return 1;
    }
    else if (section == 2)
    {
        return 1;
    }
    else if (section == 3)
    {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellOneResuseIndetifer = @"SettingOneCell";
    static NSString *cellTwoResuseIndetifer = @"SettingTwoCell";
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            CCSettingTwoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellTwoResuseIndetifer forIndexPath:indexPath];
            self.swi = cell.swi;
            cell.leftLabel.text = @"全体禁言";
            [self.swi addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
            [self updateData];
            return cell;
        }
        else if(indexPath.row == 1)
        {
            CCSettingTwoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellTwoResuseIndetifer forIndexPath:indexPath];
            self.audioSwitch = cell.swi;
            cell.leftLabel.text = @"全体关麦";
            [self.audioSwitch addTarget:self action:@selector(changeAllMicState:) forControlEvents:UIControlEventValueChanged];
            [self updateData];
            return cell;
        }
        else if (indexPath.row == 2)
        {
            CCSettingOneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellOneResuseIndetifer forIndexPath:indexPath];
            cell.leftLabel.text = @"全体下麦";
            cell.rightLabel.text = @"";
            [self updateData];
            return cell;
        }
        else if (indexPath.row == 3)
        {
            CCSettingOneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellOneResuseIndetifer forIndexPath:indexPath];
            cell.leftLabel.text = @"视频镜像";
            NSString *text = [self.hdsTool mirrorText];
            _mirrorText = text;
            cell.rightLabel.text = _mirrorText;
            return cell;
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            CCSettingOneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellOneResuseIndetifer forIndexPath:indexPath];
            self.lianMaiLabel = cell.rightLabel;
            cell.leftLabel.text = @"连麦模式";
            [self updateData];
            return cell;
        }
        else if(indexPath.row == 1)
        {
            CCSettingTwoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellTwoResuseIndetifer forIndexPath:indexPath];
            self.movieSwitch = cell.swi;
            cell.leftLabel.text = @"视频轮播";
            [self.movieSwitch addTarget:self action:@selector(changeMovieAuto:) forControlEvents:UIControlEventValueChanged];
            [self updateData];
            return cell;
        }
        else if (indexPath.row == 2)
        {
            CCSettingOneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellOneResuseIndetifer forIndexPath:indexPath];
            cell.leftLabel.text = @"轮播频率";
            self.movieTimeLabel = cell.rightLabel;
            [self updateData];
            return cell;
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            CCSettingOneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellOneResuseIndetifer forIndexPath:indexPath];
            self.teacherBitrateLabel = cell.rightLabel;
            
            NSString *selectedResolution = [self.hdsTool userdefaultSelectedResolutionHeight];
            if (selectedResolution == nil) {
                cell.rightLabel.text = @"240P";
            }else{
                cell.rightLabel.text = self.resolutionResult;
            }
            
            cell.leftLabel.text = @"老师视频分辨率";
            [self updateData];
            return cell;
        }
        else if(indexPath.row == 1)
        {
            CCSettingOneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellOneResuseIndetifer forIndexPath:indexPath];
            cell.leftLabel.text = @"学生视频分辨率";
            [self updateData];
            return cell;
        }
    }
    else if (indexPath.section == 3)
    {
        if (indexPath.row == 0)
        {
            CCSettingOneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellOneResuseIndetifer forIndexPath:indexPath];
            cell.leftLabel.text = @"连麦音视频";
            cell.rightLabel.text = @"";
            [self updateData];
            return cell;
        }
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *topLine = [cell viewWithTag:TOPLINETAG];
    if (!topLine)
    {
        UIView *line = [UIView new];
        [line setBackgroundColor:CCRGBColor(229,229,229)];
        line.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 0.5f);
        line.tag = TOPLINETAG;
        [cell addSubview:line];
        [line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(cell);
            make.right.left.mas_equalTo(cell);
            make.height.mas_equalTo(0.5f);
        }];
        topLine = line;
    }
    
    UIView *bottomLine = [cell viewWithTag:BOTTOMLINETAG];
    if (!bottomLine)
    {
        UIView *line = [UIView new];
        [line setBackgroundColor:CCRGBColor(229,229,229)];
        line.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 0.5f);
        line.tag = BOTTOMLINETAG;
        [cell addSubview:line];
        [line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(cell);
            make.right.left.mas_equalTo(cell);
            make.height.mas_equalTo(0.5f);
        }];
        bottomLine = line;
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    topLine.hidden = YES;
    bottomLine.hidden = YES;
    
    if (section == 0)
    {
        if (row == 0)
        {
            topLine.hidden = NO;
        }
        if (row == 3)
        {
            bottomLine.hidden = NO;
        }
    }
    
    if (section == 1)
    {
        if (row == 0)
        {
            topLine.hidden = NO;
        }
        if (row == 1)
        {
            bottomLine.hidden = NO;
        }
    }
    if (section == 2)
    {
        if (row == 0)
        {
            topLine.hidden = NO;
        }
        if (row == 1)
        {
            bottomLine.hidden = NO;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableViewSelectedIndexpath = indexPath;
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0)
    {
        if (row ==  2) {
            //全体下麦
            UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:@"是否确定将学生全部踢下麦"];
            [sheet bk_setCancelButtonWithTitle:@"取消" handler:^{
                
            }];
            [sheet bk_setDestructiveButtonWithTitle:@"确定" handler:^{
                
            }];
            [sheet bk_setCancelBlock:^{
                
            }];
            [sheet bk_setHandler:^{
            [[CCBarleyManager sharedBarley] changeRoomAllKickDown:^(BOOL result, NSError *error, id info) {
                NSLog(@"%s__%d__%@__%@__%@~~~~~~currentThread:%@", __func__, __LINE__, @(result), error, info,[NSThread currentThread]);
            }];
            } forButtonAtIndex:1];
            [sheet showInView:self.view];
        }
        if (row == 3) {
            [self functionRowMirror:indexPath];
        }
    }
    else if (section == 1)
    {
        if (row == 0) {
            [self performSegueWithIdentifier:@"SetToLianmai" sender:self];
        }
        else if (row == 2)
        {
            CCRoomMaxNumCountEditViewController *vc = [[CCRoomMaxNumCountEditViewController alloc] init];
            main_async_safe(^{
                [self.navigationController pushViewController:vc animated:YES];
            });
        }
    }
    else if (section == 2)
    {
        if (row == 0)
        {
            //老师视频清晰度
            if ([self roomLiveStatusOn])
            {
                UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:@"直播中禁止更换状态！"];
                [sheet bk_setDestructiveButtonWithTitle:@"确定" handler:^{
                    
                }];
                [sheet showInView:self.view];
                return;
            }
            [self resolutionSelected];
        }
    }
    else if (section == 3)
    {
        if (row == 0)
        {
            //添加直播中禁止更换状态
            if ([self roomLiveStatusOn])
            {
                UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:@"直播中禁止更换状态！"];
                [sheet bk_setDestructiveButtonWithTitle:@"确定" handler:^{
                    
                }];
                [sheet showInView:self.view];
                return;
            }
            [self performSegueWithIdentifier:@"SetToVideoAndAudio" sender:self];
        }
    }
}
//判断房间是否已经开始直播
- (BOOL)roomLiveStatusOn {
    CCLiveStatus status = [[CCStreamerBasic sharedStreamer]getRoomInfo].live_status;
    return status == CCLiveStatus_Start ? YES:NO;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20)];
    return view;
}
- (void)resolutionSelected
{
    WS(weakSelf);
    CCPickView *picker = [[CCPickView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [picker setTitle:@"视频分辨率"];
    
    picker.stremer = [CCStreamerBasic sharedStreamer];
    __weak CCPickView *weakPicker = picker;
    picker.CCPickViewCancle = ^(CCPickView * _Nonnull removeView) {
        __strong CCPickView *strongPicker = weakPicker;
        [strongPicker removeFromSuperview];
    };
    picker.CCPickViewSuccess = ^(CCPickView * _Nonnull removeView, NSInteger index, NSString * _Nonnull text) {
        weakSelf.resolutionResult = text;
        __strong CCPickView *strongPicker = weakPicker;
        [strongPicker removeFromSuperview];
        
        [self.tableView reloadData];
    };
    [self.tableView.superview addSubview:picker];
    [picker showPickView];
}

- (void)tap:(UITapGestureRecognizer *)ges
{
    [ges.view removeFromSuperview];
}

#pragma mark - 内存警告和生命结束
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiReceiveSocketEvent object:nil];
}


#pragma mark -- PickView
- (void)functionRowMirror:(NSIndexPath *)indexPath
{
    CCPickView *picker = [[CCPickView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    picker.picktype = HSPickerType_mirror;
    [picker setTitle:@"视频镜像"];
    self.selectPicker = picker;
    picker.stremer = [CCStreamerBasic sharedStreamer];
    __weak CCPickView *weakPicker = picker;
    picker.CCPickViewCancle = ^(CCPickView * _Nonnull removeView) {
        __strong CCPickView *strongPicker = weakPicker;
        [strongPicker removeFromSuperview];
        
    };
    picker.CCPickViewSuccess = ^(CCPickView * _Nonnull removeView, NSInteger index, NSString * _Nonnull text) {
        __strong CCPickView *strongPicker = weakPicker;
        [strongPicker removeFromSuperview];
        
        self.mirrorText = text;
        self.hdsTool.mirrorType = (HSMirrorType)index;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    };
    [self.view addSubview:picker];
    [picker showPickView];
}

@end
