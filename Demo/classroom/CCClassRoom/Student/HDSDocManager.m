//
//  HDSDocManager.m
//  CCClassRoom
//
//  Created by Chenfy on 2019/7/22.
//  Copyright © 2019 cc. All rights reserved.
//

#import "HDSDocManager.h"
#import "CCDrawMenuView.h"

@interface HDSDocManager()
@property(nonatomic,strong)UIView           *docParentView;

@property(nonatomic,strong)CCDocVideoView   *docView;
@property(nonatomic,strong)UIView           *videoView;
@property(nonatomic,assign)CGRect           frameVideo;

@property(nonatomic,strong)CCRoom           *room;

@end

@implementation HDSDocManager

static HDSDocManager *_docManager = nil;

+ (instancetype)sharedDoc
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _docManager = [[HDSDocManager alloc]init];
    });
    return _docManager;
}

- (CCRoom *)room
{
    return [CCRoom shareRoomHDS];
}

- (CCDocVideoView *)hdsDocView
{
    return self.docView;
}

- (void)setDpListen:(CCDocLoadBlock)loadBlack
{
    [self.hdsDocView setOnDpCompleteListener:loadBlack];
}

//离开界面的时候要被销毁掉
- (void)hdsReleaseDoc
{
    [self.docView removeObserverNotify];
    if (self.docView)
    {
        [self.docView docRelease];
    }
    _docView = nil;
}

- (void)setVideoParentView:(UIView *)videoView
{
    _videoView = videoView;
    [self.docView setVideoPlayerContainer:videoView];
}

- (void)setVideoParentViewFrame:(CGRect)frame
{
    _frameVideo = frame;
    [self.docView setVideoPlayerFrame:frame];
}

/*******************************/
- (CCDocVideoView *)docView
{
    if (!_docView)
    {
        CGRect frame = CGRectZero;
        /** 画板尺寸标准：9/16 */
        frame = CGRectMake(0, 0, SCREEN_WIDTH, (9/16.0)*(SCREEN_WIDTH));
        _docView = [[CCDocVideoView alloc]initWithFrame:frame];
        _docView.tag = 1000;
        [_docView addObserverNotify];
        [CCDocVideoView setWhiteBoardTypeOld:YES];
        [_docView setGestureOpen:NO];
        [_docView setVideoPlayerContainer:self.videoView];
        [_docView setVideoPlayerFrame:self.frameVideo];
        _docView.alpha = 1.0; //xyz
    }
    return _docView;
}

- (void)setDocParentView:(UIView *)view
{
    _docParentView = view;
}

- (void)initDocEnvironment
{
    [self.docView initDocEnvironment];
}

- (void)startDocView
{
    [self.docView startDocView];
}

- (void)setDocFrame:(CGRect)frame displayMode:(int)displayMode
{
    [self.docView setDocFrame:frame displayMode:displayMode];
}

- (void)refreshDocFrame:(int)displayMode
{
    CGRect frm = self.docParentView.bounds;
    [self.docView setDocFrame:frm displayMode:displayMode];
}

- (void)setDocStrokeWidth:(CGFloat)width
{
    [self.docView setStrokeWidth:width];
}
- (void)setDocStrokeColor:(UIColor *)color
{
    [self.docView setStrokeColor:color];
}

- (void)setDocGestureOpen:(BOOL)open
{
    [self.docView setGestureOpen:open];
}
- (void)setDocEditable:(BOOL)edit
{
    [self.docView setDocEditable:edit];
}
- (void)setDocEraser:(BOOL)eraser
{
    [self.docView setCurrentIsEraser:eraser];
}

- (void)beEditable
{
    [self setDocEditable:YES];
}

- (void)beEditableCancel
{
    [self setDocEditable:NO];
}

- (void)beAuthDraw
{
    [self hdsSetDrawDefaultColor:nil];
    [self setDocEraser:NO];
    [self setDocEditable:YES];
}
- (void)beAuthDrawCancel
{
    [self setDocEditable:NO];
}

- (void)beAuthTeacher
{
    [self hdsSetDrawDefaultColor:nil];
    [self setDocEraser:NO];
    [self setDocEditable:YES];
}
- (void)beAuthTeacherCancel
{
    [self setDocEditable:NO];
}

- (void)authDraw:(NSString *)uid
{
    [self.docView authUserDraw:uid];
}
- (void)authDrawCancel:(NSString *)uid
{
    [self.docView cancleAuthUserDraw:uid];
}

- (void)authTeacher:(NSString *)uid
{
    [self.docView authUserAsTeacher:uid];
}
- (void)authTeacherCancel:(NSString *)uid
{
    [self.docView cancleAuthUserAsTeacher:uid];
}

- (void)revokeDrawLast
{
    [self.docView revokeLastDrawByStudent];
}
- (void)revokeDrawAll
{
    [self.docView revokeAllDraw];
}

#pragma mark -- 业务相关
- (CCDoc *)hdsCurrentDoc
{
    return [self.docView docCurrentPPT];
}

- (NSUInteger)hdsCurrentDocPage
{
    return [self.docView docCurrentPage];
}

- (BOOL)pageToFront
{
    return [self.docView docPageToFront];
}
- (BOOL)pageToBack
{
    return [self.docView docPageToBack];
}

- (void)docSkip:(CCDoc *)doc toPage:(NSInteger)page
{
//    return;
    [self.docView docSkip:doc toPage:page];
}
- (void)toWhiteBoard
{
    [self.docView docPageToWhiteBoard];
}
- (void)clearAllDrawData
{
    [self.docView docPageToWhiteBoard];
    [self.docView clearAllDrawViews];
}
-(void)clearAllDrawViews
{
    [self.docView clearAllDrawViews];
}

-(void)skipDoc
{
    [self.docView docSkip:self.docView.docCurrentPPT toPage:self.docView.docCurrentPage];
}

- (void)hdsSetDrawDefaultColor:(UIColor * _Nullable )color
{
    [CCDrawMenuView resetDefaultColor];
    if (!color)
    {
        color = CCRGBColor(120, 167, 245);;
    }
    [self setDocStrokeColor:color];
}

/** 设置文档是否可编辑 默认隐藏 */
- (void)setHiddenSlider:(BOOL)isHidden {
    [self.docView setHiddenSlider:isHidden];
}
@end
