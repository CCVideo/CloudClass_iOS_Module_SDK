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
 @abstract 切换连麦模式
 @param type 模式
 @return 操作结果
 */
- (BOOL)setSpeakMode:(CCClassType)type completion:(CCComletionBlock)completion;

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

@end
