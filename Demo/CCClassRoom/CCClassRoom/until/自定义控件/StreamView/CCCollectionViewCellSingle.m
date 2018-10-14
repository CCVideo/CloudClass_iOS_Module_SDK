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
@property (strong, nonatomic) UIButton *micBtn;
@property (strong, nonatomic) UIButton *phoneBtn;
@property (strong, nonatomic) CCStreamView *info;
@property (strong, nonatomic) UILabel *nameLabel;
@end

#define StreamViewBottomDelBtn 10.f
#define BtnDelViewBottom 10.f

@implementation CCCollectionViewCellSingle
- (void)loadwith:(CCStreamView *)info showBtn:(BOOL)show
{
    if (self.info && self.info.superview == self)
    {
        [self.info removeFromSuperview];
        self.info = nil;
    }
    self.info = info;
    if (!self.micBtn)
    {
        self.micBtn = [UIButton new];
        self.micBtn.titleLabel.text = @"";
        [self.micBtn setBackgroundImage:[UIImage imageNamed:@"silence-1"] forState:UIControlStateNormal];
        [self.micBtn setBackgroundImage:[UIImage imageNamed:@"microphone-1"] forState:UIControlStateSelected];
        [self.micBtn addTarget:self action:@selector(clickMic) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.micBtn];
    }
    if (!self.phoneBtn)
    {
        self.phoneBtn = [UIButton new];
        self.phoneBtn.titleLabel.text = @"";
        [self.phoneBtn setBackgroundImage:[UIImage imageNamed:@"hangup-1"] forState:UIControlStateNormal];
        [self.phoneBtn setBackgroundImage:[UIImage imageNamed:@"hangup_touch-1"] forState:UIControlStateSelected];
        [self.phoneBtn addTarget:self action:@selector(clickPhone) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.phoneBtn];
    }
    if (!self.nameLabel)
    {
        self.nameLabel = [UILabel new];
        self.nameLabel.font = [UIFont systemFontOfSize:FontSizeClass_12];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.nameLabel];
    }
    [self addSubview:info];
    [self sendSubviewToBack:info];
    [self bringSubviewToFront:self.micBtn];
    [self bringSubviewToFront:self.phoneBtn];
    self.micBtn.hidden = !show;
    self.phoneBtn.hidden = !show;
    
//    self.nameLabel.text = info.name;
    
    __weak typeof(self) weakSelf = self;
    [info mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf).offset(1.f);
        make.right.mas_equalTo(weakSelf).offset(-1.f);
        make.top.mas_equalTo(weakSelf).offset(1.f);
        make.bottom.mas_equalTo(weakSelf).offset(-1.f);
//        make.left.right.top.mas_equalTo(weakSelf).offset(1.f);
//        make.height.mas_equalTo(info.mas_width).dividedBy(9.f/16.f);
    }];
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf);
        make.width.mas_equalTo(weakSelf);
        make.bottom.mas_equalTo(weakSelf).offset(-4.f);
    }];
    [self.micBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(info.mas_bottom).offset(StreamViewBottomDelBtn);
        make.left.mas_equalTo(weakSelf.mas_left).offset(0.f);
    }];
    [self.phoneBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.micBtn.mas_top).offset(0.f);
        make.right.mas_equalTo(weakSelf.mas_right).offset(0.f);
    }];
    
//    self.layer.cornerRadius = 2.f;
//    self.layer.masksToBounds = YES;
    self.layer.borderColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.1].CGColor;
    self.layer.borderWidth = 1.f;
    self.backgroundColor = [UIColor clearColor];
    info.backgroundColor = [UIColor blackColor];
}

- (void)clickMic
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickMicBtn:info:)])
    {
        [self.delegate clickMicBtn:self.micBtn info:self.info];
    }
}

- (void)clickPhone
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickPhoneBtn:info:)])
    {
        [self.delegate clickPhoneBtn:self.phoneBtn info:self.info];
    }
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
