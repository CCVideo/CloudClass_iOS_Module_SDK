//
//  CCTableViewCell.m
//  NewCCDemo
//
//  Created by cc on 2016/12/5.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "CCPublicTableViewCell.h"
#import "UIButton+UserInfo.h"
#import "Utility.h"
#import <UIImageView+WebCache.h>
#import "CCImageView.h"
#import "XXLinkLabel.h"
#import "PopoverView.h"

@interface CCPublicTableViewCell()

@property(nonatomic,strong)UIButton                 *button;
@property(nonatomic,assign)BOOL                     *isPublisher;
@property(nonatomic,copy)AnteSomeone                atsoBlock;
@property(nonatomic,strong)XXLinkLabel              *label;
@property(nonatomic,copy) NSString                  *antename;
@property(nonatomic,copy) NSString                  *anteid;

@property(nonatomic,strong)Dialogue                 *dialogue;
@end

@implementation CCPublicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)reloadWithDialogue:(Dialogue *)dialogue antesomeone:(AnteSomeone)atsoBlock {
    self.atsoBlock = atsoBlock;
    self.dialogue = dialogue;
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    [self.button setTitle:dialogue.username forState:UIControlStateNormal];
    [self.button setUserid:dialogue.userid];
    self.label.attributedText = dialogue.showAttributedString;
    [self.button setAttributedTitle:nil forState:UIControlStateNormal];

}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        
        WS(ws)
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.button];
        [self.contentView addSubview:self.label];

        [self.contentView bringSubviewToFront:self.button];
        
        [_button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.mas_equalTo(ws.contentView);
        }];
        
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.button.mas_top);
            make.left.mas_equalTo(ws.contentView).offset(0.f);
            make.right.mas_equalTo(ws.contentView);
            make.bottom.equalTo(ws.contentView);
        }];
    }
    return self;
}

-(UIButton *)button {
    if(!_button) {
        _button = [UIButton new];
        _button.backgroundColor = CCClearColor;
        [_button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [_button.titleLabel setFont:[UIFont systemFontOfSize:FontSizeClass_16]];
        _button.layer.shadowColor = [CCRGBAColor(0,0,0,0.50) CGColor];
        _button.layer.shadowOffset = CGSizeMake(0, 1);
        [_button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

-(void)btnClicked:(UIButton *)sender {
    @try {
        
        NSString *str = [sender titleForState:UIControlStateNormal];
        
        NSRange range = [str rangeOfString:@": "];
        if(range.location == NSNotFound) {
            _antename = str;
        } else {
            _antename = [str substringToIndex:range.location];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    _anteid = sender.userid;
    
    if(self.atsoBlock) {
        self.atsoBlock(_antename,_anteid);
    }
}

- (void)touchImageView:(UITapGestureRecognizer *)ges
{
    CCImageView *imageView = [[CCImageView alloc] initWithImageUrl:self.dialogue.picInfo[@"content"]];
    [imageView show];
}

-(UILabel *)label {
    if(!_label) {
        _label = [XXLinkLabel new];
        _label.font = [UIFont systemFontOfSize:FontSizeClass_16];
        _label.numberOfLines = 0;
        _label.textColor = CCRGBColor(247,247,247);
        _label.textAlignment = NSTextAlignmentLeft;
        _label.lineBreakMode = NSLineBreakByCharWrapping;
        _label.linkTextColor = CCRGBColor(255, 0, 0);
        _label.regularType = XXLinkLabelRegularTypeUrl;
        
        _label.regularLinkClickBlock = ^(NSString *clickedString) {
            NSString *newStr = clickedString;
            NSURL *url = [NSURL URLWithString:newStr];
            if ([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:url];
                return;
            }
            else
            {
                if (![clickedString hasPrefix:@"http"])
                {
                    newStr = [NSString stringWithFormat:@"http://%@", clickedString];
                    url = [NSURL URLWithString:newStr];
                    if ([[UIApplication sharedApplication] canOpenURL:url])
                    {
                        [[UIApplication sharedApplication] openURL:url];
                        return;
                    }
                }
                
                if (![clickedString hasPrefix:@"https"])
                {
                    newStr = [NSString stringWithFormat:@"https://%@", clickedString];
                    url = [NSURL URLWithString:newStr];
                    if ([[UIApplication sharedApplication] canOpenURL:url])
                    {
                        [[UIApplication sharedApplication] openURL:url];
                        return;
                    }
                }
            }
        };
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGes:)];
        [_label addGestureRecognizer:longPress];
    }
    return _label;
}

#pragma mark - label link
- (void)longPressGes:(UILongPressGestureRecognizer *)ges
{
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.contentView.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.3];
            float radius = self.dialogue.msgSize.height/2.f;
            if (radius > 15.f)
            {
                radius = 15.f;
            }
            self.contentView.layer.cornerRadius = radius;
            self.contentView.layer.masksToBounds = YES;
            [self showMenu];
        }
            break;
        default:
            break;
    }
}

- (void)showMenu
{
    __weak typeof(self) weakself = self;
    PopoverAction *action1 = [PopoverAction actionWithTitle:@"复制消息" handler:^(PopoverAction *action) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.dialogue.msg;
        weakself.contentView.backgroundColor = [UIColor clearColor];
        weakself.contentView.layer.cornerRadius = 0.f;
        weakself.contentView.layer.masksToBounds = NO;
    }];
    PopoverView *popoverView = [PopoverView popoverView];
    popoverView.style = PopoverViewStyleDark;
    popoverView.showShade = YES;
    [popoverView showToView:self.label withActions:@[action1] hideBlock:^{
        weakself.contentView.backgroundColor = [UIColor clearColor];
        weakself.contentView.layer.cornerRadius = 0.f;
        weakself.contentView.layer.masksToBounds = NO;
    }];
}
@end

