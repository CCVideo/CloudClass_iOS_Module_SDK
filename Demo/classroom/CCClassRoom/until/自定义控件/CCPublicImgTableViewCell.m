//
//  CCPublicImgTableViewCell.m
//  CCClassRoom
//
//  Created by 刘强强 on 2020/3/23.
//  Copyright © 2020 cc. All rights reserved.
//

#import "CCPublicImgTableViewCell.h"
#import "UIButton+UserInfo.h"
#import "Utility.h"
#import <UIImageView+WebCache.h>
#import "CCImageView.h"
#import "PopoverView.h"

@interface CCPublicImgTableViewCell ()
@property(nonatomic,strong)UIButton                 *button;
@property(nonatomic,assign)BOOL                     *isPublisher;
@property(nonatomic,copy)AnteSomeone                atsoBlock;
@property(nonatomic,copy) NSString                  *antename;
@property(nonatomic,copy) NSString                  *anteid;
@property(nonatomic,strong)UIImageView              *picImageView;
@property(nonatomic,strong)Dialogue                 *dialogue;

@end

@implementation CCPublicImgTableViewCell

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
    [self.button setTitle:dialogue.username forState:UIControlStateNormal];
    [self.button setUserid:dialogue.userid];
    [self.button setAttributedTitle:dialogue.showAttributedString forState:UIControlStateNormal];

    [self.picImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?x-oss-process=image/resize,w_150",dialogue.picInfo[@"content"]]]];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setupSubviews];
        
    }
    return self;
}

-(void)setupSubviews {
    WS(ws)
    [self.contentView addSubview:self.button];
    [self.contentView addSubview:self.picImageView];
    [self.contentView bringSubviewToFront:self.button];
    [_button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.mas_equalTo(ws.contentView);
    }];
    
    [_picImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.button).offset(0.f);
        make.bottom.mas_equalTo(ws.contentView.mas_bottom).offset(-10.f);
        make.width.mas_equalTo(80.f);
        make.height.mas_equalTo(80.f);
        make.top.mas_equalTo(ws.button.mas_bottom).offset(10.f);
    }];
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
    NSString *str = [sender titleForState:UIControlStateNormal];
    
    NSRange range = [str rangeOfString:@": "];
    if(range.location == NSNotFound) {
        _antename = str;
    } else {
        _antename = [str substringToIndex:range.location];
    }
    _anteid = sender.userid;
    
    if(self.atsoBlock) {
        self.atsoBlock(_antename,_anteid);
    }
}

- (UIImageView *)picImageView
{
    if (!_picImageView)
    {
        _picImageView = [UIImageView new];
        _picImageView.contentMode = UIViewContentModeScaleAspectFit;
        _picImageView.clipsToBounds = YES;
        _picImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchImageView:)];
        [_picImageView addGestureRecognizer:tap];
    }
    return _picImageView;
}

- (void)touchImageView:(UITapGestureRecognizer *)ges
{
    CCImageView *imageView = [[CCImageView alloc] initWithImageUrl:self.dialogue.picInfo[@"content"]];
    [imageView show];
}

@end
