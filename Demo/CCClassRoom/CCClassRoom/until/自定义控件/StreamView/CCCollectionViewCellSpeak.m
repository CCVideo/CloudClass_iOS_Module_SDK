//
//  CCCollectionViewCellSpeak.m
//  CCClassRoom
//
//  Created by cc on 17/5/22.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCCollectionViewCellSpeak.h"

#define NamelabelDelLeft 10.f
#define NamelabelDelBottom 10.f

@interface CCCollectionViewCellSpeak()

@end

@implementation CCCollectionViewCellSpeak
- (void)loadwith:(CCStreamView *)info showBtn:(BOOL)show
{
    NSLog(@"%s__%@", __func__, info);
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
    [self addSubview:info];
    [self sendSubviewToBack:info];
    self.nameLabel.hidden = NO;
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
//    self.layer.cornerRadius = 2.f;
//    self.layer.masksToBounds = YES;
    self.layer.borderColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.1].CGColor;
    self.layer.borderWidth = 1.f;
    self.backgroundColor = [UIColor clearColor];
    info.backgroundColor = [UIColor blackColor];
}
@end
