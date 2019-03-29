//
//  CCDocPPTView.h
//  CCClassRoom
//
//  Created by cc on 18/7/3.
//  Copyright © 2018年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCDocLibrary.h"
#import "CCDoc.h"

@interface CCDocVideoView : UIView<CCStreamerBasicDelegate>
/** 关联base库 */
- (void)addBasicClient:(CCStreamerBasic *)basic;
/** 文档环境初始化 */
- (void)initDocEnvironment;
/** 文档加载状态监听 */
- (void)setOnDpCompleteListener:(CCDocLoadBlock)OnDpCompleteListener;
/** 设置文档竖屏支持优先（主要反映在白板部分） */
- (void)setDocPortrait:(BOOL)portrait;
/** 开始加载文档 */
//画笔删除只能删除自己
- (void)startDocView;
/** 设置文档区域背景色 */
- (void)setDocBackGroundColor:(UIColor *)color;
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
#pragma mark --
#pragma mark -- 插播音视频相关
//设置 player 容器
- (BOOL)setVideoPlayerContainer:(UIView *)playerContainer;
//设置 player frame
- (void)setVideoPlayerFrame:(CGRect)playerFrame;

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

#pragma mark -- 文档相关
/*!
 @method
 @abstract 获取房间机构文档
 @param roomID 房间ID(缺省为当前登录的房间ID)
 @param userID 房间ID(缺省为当前登录的房间userID)
 @param docID  文档ID（可选）
 @param docName 文档名字(可选)
 @param page    请求页码（获取指定页，默认返回第一页<可选>）
 @param size    请求每页条目数（每页的数据条数，默认每页50<可选>）
 @param completion 回调
 @return 操作结果
 */
- (BOOL)getRelatedRoomDocs:(NSString *)roomID
                    userID:(NSString *)userID
                     docID:(NSString *)docID
                   docName:(NSString *)docName
                pageNumber:(int)page
                  pageSize:(int)size
                completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 删除机构文档
 @param docID 文档ID
 @param roomID 房间ID(缺省为当前登录的房间ID)
 @param userID 房间ID(缺省为当前登录的房间userID)
 @param completion 回调
 @return 操作结果
 */
- (BOOL)unReleatedDoc:(NSString *)docID roomID:(NSString *)roomID userID:(NSString *)userID completion:(CCComletionBlock)completion;

/** 获取当前文档 */
- (NSString *)docCurrentDocId;
#pragma mark -- 文档切换相关API
/** 切换到白板 */
- (void)docPageToWhiteBoard;
/** 切换到另一个文档 */
- (void)docChangeTo:(CCDoc *)doc;
/** 向前翻页 */
- (void)docPageToFront;
/** 回退翻页 */
- (void)docPageToBack;

#pragma mark -- 回放相关API
/** 清屏 */
- (void)clearAllDrawViews;
/** 是否是回放 playback --- 回放 */
@property (copy, nonatomic)NSString *docSource;

- (void)onSocketReceivePlayback:(NSDictionary *)dataDic;

@end
