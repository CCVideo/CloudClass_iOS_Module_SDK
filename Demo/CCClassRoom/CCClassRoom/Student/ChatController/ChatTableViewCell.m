//
//  ChatTableViewCell.m
//  CCClassRoom
//
//  Created by cc on 18/7/13.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "ChatTableViewCell.h"
#import <Masonry.h>

@implementation ChatTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)setRole:(RoleType)role
{
    if (role == RoleType_Teacher)
    {
        self.labelType.text = @"老师:";
        self.labelType.textColor = [UIColor orangeColor];
    }
    if (role == RoleType_Student)
    {
        self.labelType.text = @"学生:";
        self.labelType.textColor = [UIColor blackColor];
    }
    if (role == RoleType_Unknow)
    {
        self.labelType.text = @"";
        self.labelType.textColor = [UIColor blackColor];
    }
}

- (void)initUI
{
    [self.contentView addSubview:self.labelType];
    [self.contentView addSubview:self.labelName];
    [self.contentView addSubview:self.imageV];
    WS(weakSelf);
    [self.labelType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(weakSelf);
    }];
    [self.labelName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.labelType.mas_right).offset(10);
        make.top.bottom.mas_equalTo(weakSelf);
        make.width.mas_equalTo(100);
    }];
    
    [self.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(weakSelf);
        make.right.mas_equalTo(weakSelf).offset(10);
        make.width.mas_equalTo(60);
    }];
}

- (UILabel *)labelName
{
    if (!_labelName) {
        _labelName = [[UILabel alloc]init];
        _labelName.numberOfLines = 0;
        _labelName.lineBreakMode = NSLineBreakByCharWrapping;
        _labelName.font = [UIFont systemFontOfSize:14];
    }
    return _labelName;
}

- (UILabel *)labelType
{
    if (!_labelType) {
        _labelType = [[UILabel alloc]init];
        _labelType.font = [UIFont systemFontOfSize:14];
    }
    return _labelType;
}
- (UIImageView *)imageV
{
    if (!_imageV) {
        _imageV = [[UIImageView alloc]init];
    }
    return _imageV;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
