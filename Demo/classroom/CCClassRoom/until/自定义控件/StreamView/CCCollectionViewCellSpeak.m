//
//  CCCollectionViewCellSpeak.m
//  CCClassRoom
//
//  Created by cc on 17/5/22.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCCollectionViewCellSpeak.h"
#import "AppDelegate.h"

#define NamelabelDelLeft 10.f
#define NamelabelDelBottom 10.f

@interface CCCollectionViewCellSpeak()

@property (strong, nonatomic) UIImageView *drawImageView;
@property (strong, nonatomic) UIImageView *lockImageView;
@property (strong, nonatomic) UIImageView *assistantView;
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UILabel *bandWidthLabel;

@property (strong, nonatomic) UIView *audioView;
@property (strong, nonatomic) UIImageView *changeAudioImage;
@property (strong, nonatomic) UIButton *changeAudioButton;
//流状态数据
@property (strong, nonatomic) NSMutableDictionary *steamStatuDic;
@end

@implementation CCCollectionViewCellSpeak
- (void)loadwith:(CCStreamView *)info showNameAtTop:(BOOL)top
{
    NSLog(@"CCCollectionViewCellSpeak %@ , %@,  %@",info,info.stream.userID,info.stream.streamID);
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    __weak typeof(self) weakSelf = self;
    //这里不能简单的remove，要判断是不是在当前view的子view中才能remove，不然remove另外一个cell的视图
    if (self.info && self.info.superview == self)
    {
        [self.info removeFromSuperview];
        self.info = nil;
    }
    self.info = info;
    if (!self.nameLabel)
    {
        self.nameLabel = [UILabel new];
        self.nameLabel.font = [UIFont systemFontOfSize:FontSizeClass_12];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.nameLabel];
    }
    if (!self.bandWidthLabel)
    {
        self.bandWidthLabel = [UILabel new];
        self.bandWidthLabel.font = [UIFont systemFontOfSize:FontSizeClass_12];
        self.bandWidthLabel.textAlignment = NSTextAlignmentRight;
        self.bandWidthLabel.textColor = [UIColor greenColor];
        [self addSubview:self.bandWidthLabel];
    }
    
    if (!self.audioImageView)
    {
        self.audioImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kaimai"]];
        [self addSubview:self.audioImageView];
    }
    if (!self.drawImageView)
    {
        self.drawImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pencil-2"]];
        self.drawImageView.hidden = YES;
        [self addSubview:self.drawImageView];
    }
    if (!self.lockImageView)
    {
        self.lockImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock2"]];
        [self addSubview:self.lockImageView];
    }
    if (!self.assistantView)
    {
        self.assistantView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"teacher2"]];
        self.assistantView.hidden = YES;
        [self addSubview:self.assistantView];
    }
    if (!self.bottomView)
    {
        self.bottomView = [UIView new];
        self.bottomView.backgroundColor = CCRGBAColor(0, 0, 0, 0.5);
        [self addSubview:self.bottomView];
    }
    if (!self.loadingView)
    {
        self.loadingView = [CCLoadingView createLoadingView:info.stream.streamID];
        [self addSubview:self.loadingView];
        self.loadingView.tipString = @"点击加载";
        [self.loadingView setHidden:YES];
        [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(weakSelf);
        }];
    }
    
    if (!self.audioView) {
        self.audioView = [UIView new];
        self.audioView.backgroundColor = CCRGBAColor(1, 1, 1,1);
        [self addSubview:self.audioView];
        self.audioView.hidden = YES;
    }
    
    if (!self.changeAudioImage) {
        self.changeAudioImage = [UIImageView new];
        self.changeAudioImage.image = [UIImage imageNamed:@"changeAudioback"];
        [self.audioView addSubview:self.changeAudioImage];
    }
    
    if (!self.changeAudioButton) {
        self.changeAudioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.changeAudioButton setTitle:@"转换为视频" forState:UIControlStateNormal];
        [self.changeAudioButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.changeAudioButton.backgroundColor = [UIColor orangeColor];
        self.changeAudioButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.changeAudioButton addTarget:self action:@selector(changeAudioClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.audioView addSubview:self.changeAudioButton];
    }
    
    [self addSubview:info];
    [self sendSubviewToBack:info];
    [self bringSubviewToFront:self.nameLabel];
    [self bringSubviewToFront:self.lockImageView];
    [self bringSubviewToFront:self.audioImageView];
    [self bringSubviewToFront:self.drawImageView];
    [self bringSubviewToFront:self.assistantView];
    self.nameLabel.hidden = NO;
    

//    self.audioImageView.hidden = NO;
//    self.drawImageView.hidden = NO;
    //在此处判断是否关麦room_userList房间的用户列表
    for (CCUser *user in [CCStreamerBasic sharedStreamer].getRoomInfo.room_userList)
    {
        //找到问题所在了，userID取值不同导致比对不上。  user.user_uid对比info.stream.userID，否则不行的奥。
        CCUser *userGet = [[CCStreamerBasic sharedStreamer]getUserInfoWithStreamID:info.stream.streamID];
        NSLog(@"~~~~~~~~~~~~user.user_id:%@~~~~~~~~userGet.user_id:%@~~~~~info.stream.userID:%@",user.user_id,userGet.user_id,info.stream.userID);
        if ([user.user_id isEqualToString:info.stream.userID])
        {
            self.nameLabel.text = user.user_name;
            XXLogSaveAPIPar(XXLogFuncLine, @{@"user_audioState":@(user.user_audioState)});
            if (user.user_audioState)
            {
                self.audioImageView.image = [UIImage imageNamed:@"kaimai"];
            }
            else
            {
                self.audioImageView.image = [UIImage imageNamed:@"guanmai"];
            }
            
            self.drawImageView.hidden = !user.user_drawState;
            self.lockImageView.hidden = !user.rotateLocked;
            self.assistantView.hidden = !user.user_AssistantState;
        }
    }
   
    info.backgroundColor = [UIColor redColor];
    [info mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf).offset(1.f);
        make.right.mas_equalTo(weakSelf).offset(-1.f);
        make.top.mas_equalTo(weakSelf).offset(1.f);
        make.bottom.mas_equalTo(weakSelf).offset(-1.f);
    }];

    if (top)
    {
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf).offset(NamelabelDelLeft);
            make.top.mas_equalTo(weakSelf).offset(NamelabelDelBottom);
            make.width.mas_equalTo(30.f);
        }];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        
        [self.bandWidthLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf).offset(0);
            make.bottom.mas_equalTo(weakSelf).offset(-4.f);
        }];
        self.bandWidthLabel.textAlignment = NSTextAlignmentLeft;
        
        [self.audioImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(weakSelf.nameLabel).offset(0.f);
            make.left.mas_equalTo(weakSelf.nameLabel.mas_right).offset(5.f);
        }];
        UIView *leftView;
        [self.drawImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(weakSelf.audioImageView).offset(0.f);
            make.left.mas_equalTo(weakSelf.audioImageView.mas_right).offset(0.f);
        }];
        if (self.drawImageView.hidden)
        {
            [self.lockImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf.audioImageView).offset(0.f);
                make.left.mas_equalTo(weakSelf.audioImageView.mas_right).offset(0.f);
            }];
            leftView = self.audioImageView;
        }
        else
        {
            [self.lockImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf.audioImageView).offset(0.f);
                make.left.mas_equalTo(weakSelf.drawImageView.mas_right).offset(0.f);
            }];
            leftView = self.drawImageView;
        }
        if (!self.lockImageView.hidden)
        {
            leftView = self.lockImageView;
        }
        [self.assistantView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(weakSelf.audioImageView).offset(0.f);
            make.left.mas_equalTo(leftView.mas_right).offset(0.f);
        }];
        self.bottomView.hidden = YES;
        
        [self.audioView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(weakSelf);
        }];
        
        if (appdelegate.shouldNeedLandscape) {
            [self.changeAudioButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(weakSelf.bottomView.mas_top);
                make.left.mas_equalTo(weakSelf).offset(10);
                make.right.mas_equalTo(weakSelf).offset(-10);
            }];
            [self.changeAudioImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(weakSelf.changeAudioButton.mas_top);
                make.left.and.right.mas_equalTo(weakSelf);
            }];
        } else {
            [self.changeAudioButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(weakSelf.bottomView.mas_top);
                make.left.mas_equalTo(weakSelf).offset(10);
                make.right.mas_equalTo(weakSelf).offset(-10);
            }];
            [self.changeAudioImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf.audioView).offset(-10);
                make.left.and.right.mas_equalTo(weakSelf);
            }];
        }
        
    }
    else
    {
//        NSLog(@"user3.user_id=%@ user3.user_name==%@ streamID=%@",user3.user_id,user3.user_name, info.stream.streamID);
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf).offset(10.f);
            make.width.mas_equalTo(weakSelf.frame.size.width - 40);
            make.bottom.mas_equalTo(weakSelf).offset(-4.f);
        }];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        [self.bandWidthLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf).offset(0);
            make.top.mas_equalTo(weakSelf).offset(NamelabelDelBottom);
        }];
        self.bandWidthLabel.textAlignment = NSTextAlignmentLeft;
        [self.audioImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(weakSelf.nameLabel).offset(0.f);
            make.right.mas_equalTo(weakSelf).offset(-NamelabelDelLeft);
        }];
        UIView *rightView = self.audioImageView;
        
        [self.drawImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(weakSelf.audioImageView).offset(0.f);
            make.right.mas_equalTo(rightView.mas_left).offset(0.f);
        }];
        
        if (!self.drawImageView.hidden)
        {
            rightView = self.drawImageView;
        }
        [self.lockImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(weakSelf.audioImageView).offset(0.f);
            make.right.mas_equalTo(rightView.mas_left).offset(0.f);
        }];
        if (!self.lockImageView.hidden)
        {
            rightView = self.lockImageView;
        }
        [self.assistantView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(weakSelf.audioImageView).offset(0.f);
            make.right.mas_equalTo(rightView.mas_left).offset(0.f);
        }];
        self.bottomView.hidden = NO;
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.mas_equalTo(info).offset(0.f);
            make.top.mas_equalTo(weakSelf.nameLabel.mas_top).offset(-5.f);
        }];
        
        [self.audioView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(weakSelf);
        }];
        if (appdelegate.shouldNeedLandscape) {
            [self.changeAudioButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(weakSelf.bottomView.mas_top);
                make.left.mas_equalTo(weakSelf).offset(10);
                make.right.mas_equalTo(weakSelf).offset(-10);
            }];
            [self.changeAudioImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(weakSelf.changeAudioButton.mas_top);
                make.left.and.right.mas_equalTo(weakSelf);
            }];
        } else {
            [self.changeAudioButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(weakSelf.bottomView.mas_top);
                make.left.mas_equalTo(weakSelf).offset(10);
                make.right.mas_equalTo(weakSelf).offset(-10);
            }];
            [self.changeAudioImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf.audioView).offset(-10);
                make.left.and.right.mas_equalTo(weakSelf);
            }];
        }
        
    }
    
    if ([info.stream.userID isEqualToString:ShareScreenViewUserID])
    {
        self.audioImageView.hidden = YES;
        self.drawImageView.hidden = YES;
    }
    if (info.stream.role == CCRole_Teacher)
    {
        self.drawImageView.hidden = YES;
        self.assistantView.hidden = YES;
    }
    self.layer.borderColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.1].CGColor;
    self.layer.borderWidth = 1.f;
    self.backgroundColor = [UIColor clearColor];
    info.backgroundColor = [UIColor blackColor];
    
    CCClassType classType = [CCStreamerBasic sharedStreamer].getRoomInfo.room_class_type;
    if (classType == CCClassType_Auto || classType == CCClassType_Named || [info.stream.userID isEqualToString:ShareScreenViewUserID])
    {
        self.lockImageView.hidden = YES;
    }
    if ([info.stream.userID isEqualToString:ShareScreenViewUserID])
    {
        self.assistantView.hidden = YES;
    }
    
#warning 问题在这里 每次本学生都会走这个方法，导致每次都是红色的 先隐藏起来
//    NSString *haveAudio = [info.stream.attributes objectForKey:@"audio"];
//    if (![haveAudio isEqualToString:@"true"])
//    {
//        self.audioImageView.image = [UIImage imageNamed:@"nomai"];
//        
//    }
    [self addObserver];
    
    UITapGestureRecognizer *reco = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGresRec:)];
    //    [self addGestureRecognizer:reco];
    [self.loadingView addGestureRecognizer:reco];
    if (self.loadStatus == 0) {
        [self.loadingView stopLoading];
        self.audioView.hidden = YES;
    } else if (self.loadStatus == 1) {
        [self.loadingView startLoading];
        self.audioView.hidden = YES;
    } else if (self.loadStatus == 2) {
        [self.loadingView stopLoading];
        self.audioView.hidden = NO;
    }
}
- (void)addObserver
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeStatus:) name:KKEY_Loading_changed object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeAudio:) name:KKEY_Audio_changed object:nil];
    
}
- (void)removeObserver
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

//s收到黑流
- (void)changeStatus:(NSNotification *)object
{
    NSDictionary *dicInfo = object.object;
    
    CCStream *stream = dicInfo[@"stream"];
    
    if (![stream.streamID isEqualToString:self.info.stream.streamID])
    {
        return;
    }
    self.steamStatuDic = [NSMutableDictionary dictionaryWithDictionary:dicInfo];
    
    //    BOOL isRemote = [dicInfo[@"type"]boolValue];
    //    self.bandWidthLabel.text = [NSString stringWithFormat:@"%@%@Kb/S",isRemote?@"↓":@"↑",dicInfo[@"bandWidth"]];
    
    int status = [dicInfo[@"status"]intValue];
    if (status == 1001)
    {
        self.loadingView.hidden = YES;
        [self.loadingView stopLoading];
    }
    else
    {
        if (self.audioView.hidden) {
            self.loadingView.hidden = NO;
            [self.loadingView startLoading];
        }
    }
}

- (void)changeAudioClick:(UIButton *)sender {
    [self.loadingView startLoading];
    self.loadStatus = 1;
    __weak typeof(self) weakSelf = self;
    
    //    [[CCStreamerBasic sharedStreamer] playVideo:self.info.stream completion:^(BOOL result, NSError *error, id info) {
    [[CCStreamerBasic sharedStreamer] changeStream:self.info.stream videoState:YES completion:^(BOOL result, NSError *error, id info) {
        if (result) {
            [weakSelf.loadingView stopLoading];
            self.loadStatus = 0;
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.audioView.hidden = YES;
                NSNotification *nof = [[NSNotification alloc]initWithName:KKEY_Audio_changed object:@{@"result":@"all",@"obj":self.steamStatuDic} userInfo:@{@"result":@"all",@"obj":self.steamStatuDic}];
                [weakSelf changeAudio:nof];
                //                [[NSNotificationCenter defaultCenter] postNotificationName:KKEY_Audio_changed object:@{@"result":@"all",@"obj":self.steamStatuDic}];
            });
        } else {
            CCLog(@"订阅视频失败");
        }
    }];
}

- (void)changeAudio:(NSNotification *)object
{
    NSDictionary *dicInfo = object.object;
    NSString *result = dicInfo[@"result"];
    if ([result isEqualToString:@"Tip"]) {
        return;
    }
    CCStream *stream = dicInfo[@"obj"][@"stream"];
    NSLog(@" longGresRec 当前streamID %@,期待streamID %@",self.info.stream.streamID,stream.streamID);
    if ([stream.streamID isEqualToString:self.info.stream.streamID]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([result isEqualToString:@"audio"]) {
                self.loadingView.hidden = YES;
                [self.loadingView stopLoading];
                self.audioView.hidden = NO;
                self.loadStatus = 2;
            } else {
                self.audioView.hidden = YES;
                self.loadStatus = 0;
            }
        });
    }
}

- (void)tapGresRec:(UILongPressGestureRecognizer *)ges {
    //    NSLog(@"longGresRec   %@  streamID  %@  %@",self.info.stre.name  , self.info.stream.streamID , self.steamStatuDic[@"type"]);
    if (self.steamStatuDic) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KKEY_Audio_changed object:@{@"result":@"Tip",@"obj":self.steamStatuDic}];
    }
}

- (void)dealloc
{
    return;
    //该处不能移除，负责教室模式切换会有问题
    [self removeObserver];
    [self.info removeFromSuperview];
    self.info = nil;
}
@end
