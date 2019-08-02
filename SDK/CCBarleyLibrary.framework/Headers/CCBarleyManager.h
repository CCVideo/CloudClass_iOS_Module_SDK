//
//  CCBarleyManager.h
//  CCBarleyLibrary
//
//  Created by cc on 18/7/10.
//  Copyright © 2018年 cc. All rights reserved.
//


/*!  头文件基本信息。这个用在每个源代码文件的头文件的最开头。
 
 @header CCBarleyManager.h
 
 @abstract 关于这个源代码文件的一些基本描述
 
 @author Created by cc on 18/7/10.
 
 @version 1.00 18/7/10 Creation (此文档的版本信息)
 
 //  Copyright © 2018年 cc. All rights reserved.
 
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CCBarleyLibrary.h"

@interface CCBarleyManager : NSObject<CCStreamerBasicDelegate>
@property(strong,nonatomic)CCStreamerBasic  *basic;
//单例
+ (instancetype)sharedBarley;
- (void)addBasicClient:(CCStreamerBasic *)basic;
//排麦socket event
- (void)onSocketReceive:(NSString *)event value:(id)object;
/** socket 收到消息 */
- (void)onSocketReceive:(NSString *)message onTopic:(NSString *)topic;
//设置日志开关
+ (void)setLogState:(BOOL)open;
#pragma mark
#pragma mark -- 与老师互动接口
/*!
 @method
 @abstract 学生举手
 @return 状态
 */
- (BOOL)handup;

/*!
 @method
 @abstract 学生取消举手
 @return 状态
 */
- (BOOL)cancleHandup;

#pragma mark
#pragma mark -- 上下麦接口

/**
 @method
 @abstract 切换房间上麦状态(全部踢下麦)
 
 @param completion 回调
 @return 操作结果
 */
- (BOOL)changeRoomAllKickDown:(CCComletionBlock)completion;

/*!
 @method
 @abstract 开始连麦(改为排麦中)
 @return 操作结果
 */
- (BOOL)handsUp:(CCComletionBlock)completion;

/*!
 @method
 @abstract 同意举手学生连麦
 @param userID 学生ID
 @param completion 结果
 @return 操作结果
 */
- (BOOL)certainHandup:(NSString *)userID completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 取消排麦
 @return 操作结果
 */
- (BOOL)handsUpCancel:(CCComletionBlock)completion;

/*!
 @method
 @abstract 结束连麦
 @return 操作结果
 */
- (BOOL)handsDown:(CCComletionBlock)completion;

/*!
 @method
 @abstract 将连麦者踢下麦
 @param userID 连麦者userID
 
 @return 操作结果
 */
- (BOOL)kickUserFromSpeak:(NSString *)userID completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 老师邀请没有举手学生连麦(只对老师有效)
 @param userID 学生ID
 @return 操作结果
 */
- (BOOL)inviteUserSpeak:(NSString *)userID completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 老师取消对学生的上麦邀请
 @param userID 学生ID
 @param completion 结果
 @return 操作结果
 */
- (BOOL)cancleInviteUserSpeak:(NSString *)userID completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 同意老师的上麦邀请
 @param completion 结果
 @return 操作结果
 */
- (BOOL)acceptTeacherInvite:(CCComletionBlock)completion;

/*!
 @method
 @abstract 拒绝老师的连麦邀请
 @param completion 结果
 @return 操作结果
 */
- (BOOL)refuseTeacherInvite:(CCComletionBlock)completion;

/*!
 @method
 @abstract 更新连麦状态
 @param userID 用户id
 @param roomID 房间id
 @param result 推流结果
 @param streamID 流id
 @param completion 回调block
 @return 操作结果
 */
- (BOOL)updateUserState:(NSString *)userID roomID:(NSString *)roomID publishResult:(BOOL)result streamID:(NSString *)streamID completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 踢出房间
 @param userID     用户ID
 
 @return 操作结果
 */
- (BOOL)kickUserFromRoom:(NSString *)userID;

/*!
 @method
 @abstract 获取麦序
 @return 麦序
 */
- (NSInteger)getLianMaiNum;

#pragma mark --
#pragma mark -- 助教相关API
#pragma mark -- 助教上下麦
/*!
 @method
 @abstract 助教上麦--助教推流后调用，更新状态为3
 @param completion 回调
 */
- (void)assistLM:(BOOL)published completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 助教下麦--助教下麦，状态变更为0
 @param completion 回调
 */
- (void)assistDM:(CCUser *)user completion:(CCComletionBlock)completion;

#pragma mark -- 讲师下麦
/*!
 @method
 @abstract 老师下麦--老师下麦，状态变更为0
 @param user 被下麦用户，如果为nil，默认当前g用户
 @param userId 被谁下麦 | nil 自己下麦
 @param completion 回调
 */
- (void)presentDM:(CCUser *)user byUser:(NSString *)userId completion:(CCComletionBlock)completion;

#pragma mark -- 老师、助教预上麦
/*!
 @method
 @abstract 讲师\助教 -- 状态变更为5
 @param user 预上麦人员
 @param completion 回调
 */
- (void)rolePreLM:(CCUser *)user completion:(CCComletionBlock)completion;

#pragma mark --
#pragma mark -- 房间级配置
/*!
 @method
 @abstract 切换连麦模式
 @param type 模式
 @return 操作结果
 */
- (BOOL)setSpeakMode:(CCClassType)type completion:(CCComletionBlock)completion;
/*!
 @method
 @abstract 改变房间模板
 @param tem 模板
 
 @return 操作结果
 */
- (BOOL)changeRoomTemplateMode:(CCRoomTemplate)tem completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 主视频模式跟随，老师切换视频(userID 为空表示关闭)
 @param userID 切换到大屏的学生ID
 @return 操作结果
 */
- (BOOL)changeMainStreamInSigleTemplate:(NSString *)userID completion:(CCComletionBlock)completion;

/**
 @method
 @abstract 开启、关闭、变更轮播
 
 @param type 操作类型
 @param time 轮播时间(开启或者变更的时候需要该参数，关闭不需要)
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)changeRoomRotate:(CCRotateType)type time:(float)time completion:(CCComletionBlock)completion;

/**
 @method
 @abstract 轮播模式锁定用户
 
 @param userID 用户ID
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)rotateLockUser:(NSString *)userID completion:(CCComletionBlock)completion;

/**
 @method
 @abstract 轮播模式解锁用户
 
 @param userID 用户ID
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)rotateUnLockUser:(NSString *)userID completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 改变连麦音视频权限
 @param videoMode 连麦音视频权限
 
 @return 操作结果
 */
- (BOOL)changeRoomVideoMode:(CCVideoMode)videoMode completion:(CCComletionBlock)completion;

@end
