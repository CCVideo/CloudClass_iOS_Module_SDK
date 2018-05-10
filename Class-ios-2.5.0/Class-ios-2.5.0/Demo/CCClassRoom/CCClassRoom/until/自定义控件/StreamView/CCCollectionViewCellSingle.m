//
//  CCCollectionViewCellSingle.m
//  CCClassRoom
//
//  Created by cc on 17/4/19.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCCollectionViewCellSingle.h"
#import "DefinePrefixHeader.pch"

@interface CCCollectionViewCellSingle()
@property (strong, nonatomic) CCStreamShowView *info;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIImageView *audioImageView;
@property (strong, nonatomic) UIImageView *drawImageView;
@property (strong, nonatomic) UIImageView *lockImageView;
@property (strong, nonatomic) UIImageView *assistantView;
@property (strong, nonatomic) UIView *bottomView;
@end

#define StreamViewBottomDelBtn 10.f
#define BtnDelViewBottom 10.f

@implementation CCCollectionViewCellSingle
- (void)loadwith:(CCStreamShowView *)info showBtn:(BOOL)show showNameAtTop:(BOOL)top
{
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
    if (!self.audioImageView)
    {
        self.audioImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kaimai"]];
        [self addSubview:self.audioImageView];
    }
    if (!self.drawImageView)
    {
        self.drawImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pencil-2"]];
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
        [self addSubview:self.assistantView];
    }
    if (!self.bottomView)
    {
        self.bottomView = [UIView new];
        self.bottomView.backgroundColor = CCRGBAColor(0, 0, 0, 0.5);
        [self addSubview:self.bottomView];
    }
    [self addSubview:info];
    [self sendSubviewToBack:info];
    [self bringSubviewToFront:self.lockImageView];
    [self bringSubviewToFront:self.audioImageView];
    [self bringSubviewToFront:self.drawImageView];
    [self bringSubviewToFront:self.assistantView];
    self.audioImageView.hidden = NO;
    self.drawImageView.hidden = NO;
    self.lockImageView.hidden = NO;
    
    for (CCUser *user in [CCStreamer sharedStreamer].getRoomInfo.room_userList)
    {
        if ([user.user_id isEqualToString:info.userID])
        {
            self.drawImageView.hidden = !user.user_drawState;
            if (user.user_audioState)
            {
                self.audioImageView.image = [UIImage imageNamed:@"kaimai"];
            }
            else
            {
                self.audioImageView.image = [UIImage imageNamed:@"guanmai"];
            }
            self.lockImageView.hidden = !user.rotateLocked;
            self.assistantView.hidden = !user.user_AssistantState;
        }
    }
    
    self.nameLabel.text = info.name;
    
    __weak typeof(self) weakSelf = self;
    [info mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf).offset(1.f);
        make.right.mas_equalTo(weakSelf).offset(-1.f);
        make.top.mas_equalTo(weakSelf).offset(1.f);
        make.bottom.mas_equalTo(weakSelf).offset(-1.f);
    }];
    
    if (top)
    {
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf).offset(10.f);
            make.width.mas_equalTo(30.f);
            make.top.mas_equalTo(weakSelf).offset(75.f);
        }];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        [self.audioImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(weakSelf.nameLabel).offset(0.f);
            make.left.mas_equalTo(weakSelf.nameLabel.mas_right).offset(5.f);
        }];
        
        [self.drawImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(weakSelf.audioImageView).offset(0.f);
            make.left.mas_equalTo(weakSelf.audioImageView.mas_right).offset(0.f);
        }];
        UIView *leftView;
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
    }
    else
    {
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf).offset(10.f);
            make.width.mas_equalTo(weakSelf);
            make.bottom.mas_equalTo(weakSelf).offset(-4.f);
        }];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        [self.audioImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(weakSelf.nameLabel).offset(0.f);
            make.right.mas_equalTo(weakSelf).offset(-5.f);
        }];
        
        [self.drawImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(weakSelf.audioImageView).offset(0.f);
            make.right.mas_equalTo(weakSelf.audioImageView.mas_left).offset(0.f);
        }];
        UIView *rightView;
        if (self.drawImageView.hidden)
        {
            [self.lockImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf.audioImageView).offset(0.f);
                make.right.mas_equalTo(weakSelf.audioImageView.mas_left).offset(0.f);
            }];
            rightView = self.audioImageView;
        }
        else
        {
            [self.lockImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf.audioImageView).offset(0.f);
                make.right.mas_equalTo(weakSelf.drawImageView.mas_left).offset(0.f);
            }];
            rightView = self.drawImageView;
        }
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
    }
    
    if (!top)
    {
        self.layer.borderColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.1].CGColor;
        self.layer.borderWidth = 1.f;
        self.backgroundColor = [UIColor clearColor];
    }
    else
    {
        self.backgroundColor = [UIColor blackColor];
    }
    
    if ([info.userID isEqualToString:ShareScreenViewUserID])
    {
        self.audioImageView.hidden = YES;
        self.drawImageView.hidden = YES;
    }
    if (info.role == CCRole_Teacher)
    {
        self.drawImageView.hidden = YES;
        self.assistantView.hidden = YES;
    }
    info.backgroundColor = [UIColor blackColor];
    CCClassType classType = [CCStreamer sharedStreamer].getRoomInfo.room_class_type;
    if (classType == CCClassType_Auto || classType == CCClassType_Named || [info.userID isEqualToString:ShareScreenViewUserID] || info.role == CCRole_Teacher)
    {
        self.lockImageView.hidden = YES;
    }
    if ([info.userID isEqualToString:ShareScreenViewUserID])
    {
        self.assistantView.hidden = YES;
    }
    
    NSString *haveAudio = [info.stream.attributes objectForKey:@"audio"];
    if (![haveAudio isEqualToString:@"true"])
    {
        self.audioImageView.image = [UIImage imageNamed:@"nomai"];
    }
}

- (void)dealloc
{
//    [self.info removeFromSuperview];
//    self.info = nil;
}

- (void)moveLabelToTop:(BOOL)top
{
    __weak typeof(self) weakSelf = self;
    if (top)
    {
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf).offset(10.f);
            make.width.mas_equalTo(30.f);
            make.top.mas_equalTo(weakSelf).offset(20.f);
        }];
    }
    else
    {
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf).offset(10.f);
            make.width.mas_equalTo(30.f);
            make.top.mas_equalTo(weakSelf).offset(75.f);
        }];
    }
    [self setNeedsDisplay];
}

+ (CGFloat)getHeightWithWidth:(CGFloat)width showBtn:(BOOL)show isLandspace:(BOOL)isLandspace
{
    CGFloat streamViewH;
    if (isLandspace)
    {
        streamViewH = width/(16.f/9.f);
    }
    else
    {
        streamViewH = width*16.f/9.f;
    }
    if (!show)
    {
        return streamViewH;
    }
    CGFloat btnHeight = [UIImage imageNamed:@"silence-1"].size.height;
    return streamViewH + StreamViewBottomDelBtn + btnHeight + BtnDelViewBottom;
}
@end
