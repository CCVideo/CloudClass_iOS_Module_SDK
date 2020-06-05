//
//  CCCommonTool.h
//  CCClassRoomBasic
//
//  Created by cc on 2018/12/3.
//  Copyright © 2018年 cc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCAFNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCCommonTool : NSObject
/*!
 @method
 @abstract 获取网络超时时间
 
 @return 操作结果
 */
+ (NSTimeInterval)getNetTimeoutInterval;

/*!
 @method
 @abstract 配置网络超时时间
 
 @param timeout 超时时间
 */
+ (void)setNetTimeoutInterval:(NSTimeInterval)timeout;

/*!
 @method
 @abstract 获取直播socket信令注册事件
 
 @return 操作结果
 */
+ (NSArray *)getAllSocketActionName;
/*!
 @method
 @abstract 获取旁听socket信令注册事件
 
 @return 操作结果
 */
+ (NSArray *)getJoinAuditSocketActionName;

/*!
 @method
 @abstract 创建设备唯一标识
 
 @return 操作结果
 */
+ (NSString *)uniqueMark;
/*!
 @method
 @abstract 删除创建的设备唯一标识
 */
+ (void)deleteUniqueMark;

/*!
 @method
 @abstract 启动日志记录（内部使用，不需外部参与）
 */
+ (void)fileStartUp;

/*!
 @method
 @abstract 日志记录开关
 
 @param open 开关
 */
+ (void)fileSetLogFunctionOpen:(BOOL)open;

/*!
@method
@abstract 获取SDK版本
*/
+ (NSString *)hdsSDKVersion;

+ (NSString *)logCheckString:(NSString *)obj;
@end

NS_ASSUME_NONNULL_END
