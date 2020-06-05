//
//  HDSDocManager.h
//  CCClassRoom
//
//  Created by Chenfy on 2019/7/22.
//  Copyright © 2019 cc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CCFuncTool/CCFuncTool.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSDocManager : NSObject
#pragma mark -- 业务相关
@property(nonatomic,assign)NSUInteger docPage;
@property(nonatomic,assign)NSUInteger docTotalPage;
///渲染模式
@property(nonatomic, assign) HDSRenderMode voidModel;
@property(nonatomic,assign)BOOL isPreviewGravityFollow;


- (CCDoc *)hdsCurrentDoc;
- (NSUInteger)hdsCurrentDocPage;

- (BOOL)pageToFront;
- (BOOL)pageToBack;
- (void)docSkip:(CCDoc *)doc toPage:(NSInteger)page;
- (void)toWhiteBoard;
#pragma mark -- 功能相关
+ (instancetype)sharedDoc;

- (CCDocVideoView *)hdsDocView;

- (void)setDpListen:(CCDocLoadBlock)loadBlack;
//销毁界面
- (void)hdsReleaseDoc;

- (void)setVideoParentView:(UIView *)videoView;

- (void)setVideoParentViewFrame:(CGRect)frame;

- (void)setDocParentView:(UIView *)view;

- (void)initDocEnvironment;

- (void)startDocView;

- (void)setDocFrame:(CGRect)frame displayMode:(int)displayMode;
- (void)refreshDocFrame:(int)displayMode;

- (void)setDocStrokeWidth:(CGFloat)width;
- (void)setDocStrokeColor:(UIColor *)color;

- (void)setDocGestureOpen:(BOOL)open;
- (void)setDocEditable:(BOOL)canEdit;
- (void)setDocEraser:(BOOL)eraser;

- (void)beEditable;
- (void)beEditableCancel;

- (void)beAuthDraw;
- (void)beAuthDrawCancel;

- (void)beAuthTeacher;
- (void)beAuthTeacherCancel;


- (void)authDraw:(NSString *)uid;
- (void)authDrawCancel:(NSString *)uid;

- (void)authTeacher:(NSString *)uid;
- (void)authTeacherCancel:(NSString *)uid;


- (void)revokeDrawLast;
- (void)revokeDrawAll;

- (void)clearAllDrawData;
- (void)clearAllDrawViews;

-(void)skipDoc;

#pragma mark -- 恢复文档默认画笔颜色
- (void)hdsSetDrawDefaultColor:(UIColor * _Nullable )color;
/** 设置文档是否可编辑 默认隐藏 */
- (void)setHiddenSlider:(BOOL)isHidden;

@end

NS_ASSUME_NONNULL_END
