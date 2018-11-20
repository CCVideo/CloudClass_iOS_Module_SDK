//
//  CCDocPPTView.h
//  CCClassRoom
//
//  Created by cc on 18/7/3.
//  Copyright © 2018年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCDocLibrary.h"

@interface CCDocVideoView : UIView<CCStreamerBasicDelegate>

- (void)addBasicClient:(CCStreamerBasic *)basic;
- (void)startDocView;
//PPT动画展示
//初始化View
-(instancetype)initWithFrame:(CGRect)frame;
/** 设置frame */
- (void)setDocFrame:(CGRect)frame;
//添加监听
- (void)addObserverNotify;
//移除监听
- (void)removeObserverNotify;
//设置日志开关
+ (void)setLogState:(BOOL)open;
//视频框
- (void)setPlayerFrame:(CGRect)playerFrame superView:(UIView *)showView;

//事件处理
- (void)onSocketReceive:(NSString *)event value:(id)object;
- (void)onSocketReceive:(NSString *)message onTopic:(NSString *)topic;

#pragma mark -- 画笔相关操作
/** 设置手势开关 */
- (void)setGestureOpen:(BOOL)open;
/** 设置画笔宽度 */
- (void)setStrokeWidth:(CGFloat)width;
/** 设置画笔颜色 */
- (void)setStrokeColor:(UIColor *)color;
/** 设置当前是否是橡皮擦 */
- (void)setCurrentIsEraser:(BOOL)eraser;
/** 撤销画笔 */
- (void)revokeLastDraw;
/** 学生撤销 */
- (void)revokeLastDrawByStudent;
/** 清除当前页的画笔数据 */
- (void)revokeAllDraw;
/** 清空整个文档的画笔数据 */
- (void)revokeAllDocDraw;
/** 释放白板资源 */
- (void)docRelease;

#pragma mark -- 用户权限相关
/** 设置文档是否可编辑 */
- (void)setDocEditable:(BOOL)canEdit;
/** 设为讲师 */
- (BOOL)authUserAsTeacher:(NSString *)userId;
/** 取消设为讲师 */
- (BOOL)cancleAuthUserAsTeacher:(NSString *)userId;
/** 授权标注 */
- (BOOL)authUserDraw:(NSString *)userId;
/** 取消授权标注 */
- (BOOL)cancleAuthUserDraw:(NSString *)userId;

#pragma mark -- 回放相关API
/** 清屏 */
- (void)clearAllDrawViews;
/** 是否是回放 playback --- 回放 */
@property (copy, nonatomic)NSString *docSource;


@end
