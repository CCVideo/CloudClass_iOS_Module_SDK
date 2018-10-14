//
//  CCChatManager.h
//  CCChatLibrary
//
//  Created by cc on 18/7/11.
//  Copyright © 2018年 cc. All rights reserved.
//


/*!  头文件基本信息。这个用在每个源代码文件的头文件的最开头。
 
 @header CCChatManager.h
 
 @abstract 关于这个源代码文件的一些基本描述
 
 @author Created by cc on 18/7/11.
 
 @version 1.00 18/7/11 Creation (此文档的版本信息)
 
 //  Copyright © 2018年 cc. All rights reserved.
 
 */


#import <Foundation/Foundation.h>
#import "CCChatLibrary.h"

@interface CCChatManager : NSObject<CCStreamerBasicDelegate>
//单例
+ (instancetype)sharedChat;
- (void)addBasicClient:(CCStreamerBasic *)basic;

//socket event -- chat
- (void)onSocketReceive:(NSString *)event value:(id)object;

#pragma mark - socket 聊天 send message
/*!
 @method
 @abstract 发送公聊信息
 */
- (BOOL)sendMsg:(NSString *)message;

/*!
 @method
 @abstract 发送聊天图片
 @param image 图片
 @param completion 回调
 */
- (void)sendImage:(UIImage *)image completion:(CCComletionBlock)completion;

#pragma mark - 禁言
/*!
 @method
 @abstract 对某个学生禁言
 @param userID 学生ID
 
 @return 操作结果
 */
- (BOOL)gagUser:(NSString *)userID;

/*!
 @method
 @abstract 取消对某个学生禁言
 @param userID 学生ID
 
 @return 操作结果
 */
- (BOOL)recoveGagUser:(NSString *)userID;

/*!
 @method
 @abstract 全体禁言
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)gagAll:(CCComletionBlock)completion;

/*!
 @method
 @abstract 取消全体禁言
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)recoverGagAll:(CCComletionBlock)completion;

/*!
 @method
 @abstract 用户是否被禁言
 */
- (BOOL)isUserGag;

/*!
 @method
 @abstract 房间是否被禁言
 */
- (BOOL)isRoomGag;

/*!
 @method
 @abstract 获取聊天历史数据
 */
- (void)getChatHistoryData:(CCComletionBlock)completion;

@end

