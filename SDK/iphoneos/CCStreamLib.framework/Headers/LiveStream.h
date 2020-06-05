//
//  LiveStream.h
//  LiveStreamLib
//
//  Created by Chenfy on 2020/3/17.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
 * @brief    用户角色身份枚举
 */
typedef enum{
    /*!
     *  基础流
     */
    LiveStreamType_Base,
    /*!
     *  本地流
     */
    LiveStreamType_Local,
    /*!
     *  远程流
     */
    LiveStreamType_Remote,
    /*!
     *  合屏流
     */
    LiveStreamType_Mixed,
    /*!
     *  屏幕共享流
     */
    LiveStreamType_ShareScreen,
    /*!
     *  辅助摄像头
     */
    LiveStreamType_AssistantCamera,

}LiveStreamType;
NS_ASSUME_NONNULL_BEGIN

@interface LiveStream : NSObject
/*!
 @brief  用户ID
 */
@property (strong, nonatomic, readonly) NSString *userID;
/*!
 @brief  流ID
 */
@property (strong, nonatomic, readonly) NSString *streamID;
/*!
@brief  流标记
*/
@property(assign, nonatomic, readonly)NSUInteger uid;
/*!
 @brief  流类型
 */
@property (assign, nonatomic, readwrite) LiveStreamType type;


//更新本地流配置
- (void)updateLocalStreamInfo:(NSString *)userid streamid:(NSString *)sid uid:(NSInteger)uid;

@end

NS_ASSUME_NONNULL_END
