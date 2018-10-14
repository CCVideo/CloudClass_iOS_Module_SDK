//
//  CCCollectionViewCellTile.m
//  CCClassRoom
//
//  Created by cc on 17/4/20.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCCollectionViewCellTile.h"

@interface CCCollectionViewCellTile()
@property (strong, nonatomic) UIButton *micBtn;
@property (strong, nonatomic) UIButton *phoneBtn;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) CCStreamView *info;
@end

#define NamelabelDelLeft 10.f
#define NamelabelDelBottom 10.f
#define PhoneBtnDelRight 10.f
#define PhoneBtnDelMicBtn 10.f

@implementation CCCollectionViewCellTile
- (void)loadwith:(CCStreamView *)info showBtn:(BOOL)show showNameLabel:(BOOL)showLabel
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
    
//    self.nameLabel.text = info.name;
    
    self.micBtn.hidden = !show;
    self.phoneBtn.hidden = !show;
    self.nameLabel.hidden = !showLabel;
    
    self.micBtn.hidden = YES;
    self.phoneBtn.hidden = YES;
    self.nameLabel.hidden = YES;
    
    __weak typeof(self) weakSelf = self;
//    if (info.stream.type == CCStreamType_Local)
//    {
//        UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
//        if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
//        {
//            [info setCameraViewTransform:CGAffineTransformIdentity];
//        }
//        else
//        {
//            if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
//            {
//                [info setCameraViewTransform:CGAffineTransformMakeRotation(M_PI_2)];
//            }
//            else
//            {
//                [info setCameraViewTransform:CGAffineTransformMakeRotation(-M_PI_2)];
//            }
//        }
//    }

    [info mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(weakSelf).offset(1.f);
//        make.height.mas_equalTo(info.mas_width).dividedBy(9.f/16.f);
    }];
    
    if (show)
    {
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf).offset(NamelabelDelLeft);
            make.bottom.mas_equalTo(weakSelf).offset(-NamelabelDelBottom);
            make.width.mas_equalTo(weakSelf.mas_width).dividedBy(3.f);
        }];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    else
    {
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(weakSelf);
            make.width.mas_equalTo(weakSelf);
            make.bottom.mas_equalTo(weakSelf).offset(-4.f);
        }];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
    }
   
    [self.phoneBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nameLabel.mas_centerY).offset(0.f);
        make.right.mas_equalTo(weakSelf).offset(-PhoneBtnDelRight);
    }];
    
    [self.micBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.phoneBtn.mas_centerY).offset(0.f);
        make.right.mas_equalTo(weakSelf.phoneBtn.mas_left).offset(-PhoneBtnDelMicBtn);
    }];
    
//    self.layer.cornerRadius = 2.f;
//    self.layer.masksToBounds = YES;
//    self.layer.borderColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.2].CGColor;
//    self.layer.borderWidth = 1.f;
    
    info.backgroundColor = StreamColor;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    CCLog(@"%s__%d", __func__, __LINE__);
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
@end
