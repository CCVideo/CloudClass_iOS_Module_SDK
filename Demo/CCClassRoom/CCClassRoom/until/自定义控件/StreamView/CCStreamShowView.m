//
//  CCStreamShowView.m
//  CCClassRoom
//
//  Created by cc on 17/2/22.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCStreamShowView.h"
#import <CCClassRoomBasic/CCClassRoomBasic.h>
#import <BlocksKit+UIKit.h>
#import "CCStreamerModeTile.h"
#import "CCPlayViewController.h"

@interface CCStreamShowView()
@property (strong, nonatomic) CCStreamerModeTile *streamTile;
@property (strong, nonatomic) NSMutableArray *showViews;

@property (strong, nonatomic) UIView *backView;//未上课的时候显示的
@property (assign, nonatomic) BOOL backViewIsShow;//未上课图是否显示
@property (strong, nonatomic) NSTimer *autoHiddenTimer;
@end

@implementation CCStreamShowView
- (void)configWithMode:(NSString *)mode
{
    __weak typeof(self) weakSelf = self;
    
    if (self.streamTile)
    {
        [self.streamTile removeFromSuperview];
        self.streamTile = nil;
    }
    
    NSArray *local = [NSArray arrayWithArray:self.showViews];
    
        self.streamTile = [[CCStreamerModeTile alloc] init];
        self.streamTile.showVC = self.showVC;
        self.streamTile.showBtn = self.showBtn;
        [self addSubview:self.streamTile];
        [self.streamTile mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(weakSelf).offset(0.f);
        }];
        
        for (CCStream *view in local)
        {
            [self.streamTile showStreamView:view];
        }
}

- (void)showBackView
{
    self.backViewIsShow = YES;
    if (!self.backView)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
        UIImageView *bokeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"book"]];
        UILabel *label = [[UILabel alloc] init];
        label.text = @"还没上课，先休息一会儿";
        label.textColor = [UIColor whiteColor];
        [label sizeToFit];
        [imageView addSubview:bokeView];
        [imageView addSubview:label];
        imageView.userInteractionEnabled = YES;
        
        [bokeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(imageView);
            make.centerY.mas_equalTo(imageView);
        }];
        
        [label mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(imageView);
            make.top.mas_equalTo(bokeView.mas_bottom).offset(10.f);
        }];
        
        self.backView = imageView;
        [self addSubview:self.backView];
        __weak typeof(self) weakSelf = self;
        [self.backView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(weakSelf);
        }];
    }
    [self bringSubviewToFront:self.backView];
    self.backView.hidden = NO;
}

- (void)removeBackView
{
    self.backViewIsShow = NO;
    [self sendSubviewToBack:self.backView];
    self.backView.hidden = YES;
}

- (void)showStreamView:(CCStream *)view
{
    if (!view)
    {
        CCLog(@"%s___show nil view", __func__);
        return;
    }
    [self.streamTile showStreamView:view];
}

- (void)removeStreamView:(CCStream *)view
{
    [self.streamTile removeStreamView:view];
    [self.streamTile reloadData];
}

- (void)reloadData
{
    [self.streamTile reloadData];
}

- (void)removeStreamViewByStreamID:(NSString *)streamID
{
    [self.streamTile removeStreamViewByStreamID:streamID];
    [self.streamTile reloadData];
}


- (void)viewDidAppear
{
    
}

#pragma mark -
- (void)dealloc
{
    
}
@end
