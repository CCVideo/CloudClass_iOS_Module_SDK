//
//  CCStreamModeSpeak.h
//  CCClassRoom
//
//  Created by cc on 17/12/26.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDSDocManager.h"

#define CCNotiDelCurrentShowDoc @"CCNotiDelCurrentShowDoc"

@class CCDoc;

typedef NS_ENUM(NSInteger, CCStreamModeSpeakRole) {
    CCStreamModeSpeakRole_Teacher,//老师
    CCStreamModeSpeakRole_Student,//学生
    CCStreamModeSpeakRole_Assistant,//学生设为讲师之后身份
    CCStreamModeSpeakRole_Inspector, //隐身者
};

@interface CCStreamModeSpeak : UIView
@property (strong, nonatomic) UINavigationController *showVC;
@property (strong, nonatomic) UIView *docView;

@property (assign, nonatomic) BOOL isFull;//视频是否是全屏
@property (strong, nonatomic) NSMutableArray *data;
@property (assign, nonatomic) NSInteger fullInfoIndex;//全屏的视频信息
@property (nonatomic,assign)  BOOL                  isLandSpace;
@property (strong, nonatomic) CCDoc *nowDoc;
@property (assign, nonatomic) NSInteger nowDocpage;
@property (assign, nonatomic) CCStreamModeSpeakRole role;
@property (strong, nonatomic) CCStreamView *streamShowInDoc;//视屏放大显示到文档区

- (id)initWithLandspace:(BOOL)isLandSpace  docView:(CCDocVideoView *)view;
- (id)initWithLandspace:(BOOL)isLandSpace;
- (void)addBack;
- (void)removeBack;

- (void)viewDidAppear:(BOOL)autoHidden;


- (void)showStreamView:(CCStreamView *)view;
- (void)removeStreamView:(CCStreamView *)view;
- (void)removeStreamViewAll;

- (void)fire;
- (void)reloadData;

- (void)showMovieBig:(NSIndexPath *)indexPath;

- (void)hideOrShowVideo:(BOOL)hidden;
- (void)disableTapGes:(BOOL)enable;
- (void)hideOrShowView:(BOOL)hidden;
- (BOOL)clickBack:(UIButton *)btn;
- (BOOL)clickFront:(UIButton *)btn;

- (void)showStreamInDoc:(NSDictionary *)data;
@end
