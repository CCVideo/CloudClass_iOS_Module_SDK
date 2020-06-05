//
//  CCSpeaker.h
//  CCClassRoomBasic
//
//  Created by cc on 18/7/5.
//  Copyright © 2018年 cc. All rights reserved.
//


/*!  头文件基本信息。这个用在每个源代码文件的头文件的最开头。
 
 @header CCSpeaker.h
 
 @abstract 关于这个源代码文件的一些基本描述
 
 @author Created by cc on 18/7/5.
 
 @version 1.00 18/7/5 Creation (此文档的版本信息)
 
 //  Copyright © 2018年 cc. All rights reserved.
 
 */


#import <Foundation/Foundation.h>

#import "CCStream.h"

@interface CCSpeaker : NSObject
//LiveClass
//创建流管理组建
+ (CCSpeaker *)shareSpeakerHDS;
//清楚组件数据
- (void)speakerDestory;
/*!
 是否是自己下麦
 */
@property (assign, nonatomic) BOOL callStopLianMaiByStudent;//学生自己下麦
/**
 @property
 @abstract 可订阅的流
 */
@property (strong, nonatomic) NSMutableArray *streamsCanSub; //可订阅
/**
 @property
 @abstract 已通知订阅的流
 */
@property (strong, nonatomic) NSMutableArray *streamsNotify;//已通知
/**
 @property
 @abstract 已订阅的流
 */
@property (strong, atomic) NSMutableArray *streamsSubed; //已订阅
/**
 @property
 @abstract 已删除的流
 */
@property (strong, nonatomic) NSMutableArray *streamsRemove; //已删除
/**
 @property
 @abstract 所有流
 */
@property (strong, nonatomic) NSMutableArray *streamsAll;    //所有流

//正在订阅的流的流ID
@property (strong, nonatomic) NSMutableArray *subStreamIDs;
//已经移除的流的流ID
@property (strong, nonatomic) NSMutableArray *removedStreamIDs;
//已经通知订阅的流的流ID
@property (strong, nonatomic) NSMutableArray *notifyStreamIDs;

- (void)onStreamIdSub:(NSString *)sid;
- (void)onStreamIdNotify:(NSString *)sid;
- (void)onStreamIdRemove:(NSString *)sid;

- (void)onStreamIdSub_remove:(NSString *)sid;
- (void)onStreamIdNotify_remove:(NSString *)sid;
- (void)onStreamIdRemove_remove:(NSString *)sid;

//流管理API
- (void)onStreamCanSubAdd:(CCStream *)stream;
- (void)onStreamCanSubRemove:(CCStream *)stream;

- (void)onStreamNotifyAdd:(CCStream *)stream;
- (void)onStreamNotifyRemove:(CCStream *)stream;

- (void)onStreamSubedAdd:(CCStream *)stream;
- (void)onStreamSubedRemove:(CCStream *)stream;

- (void)onStreamRemoveAdd:(CCStream *)stream;
- (void)onStreamRemoveRemove:(CCStream *)stream;

- (void)onStreamAllAdd:(CCStream *)stream;
- (void)onStreamAllRemove:(CCStream *)stream;

/**
 @property
 @abstract 本地流
 */
@property (strong, nonatomic) CCStream *localStream;
/**
 @property
 @abstract 混合流
 */
@property (strong, nonatomic) CCStream *mixedStream;

/*!
 @method
 @abstract 获取流对象
 @param streamID 流id
 @return 操作结果
 */
- (CCStream *)streamWithStreamID:(NSString *)streamID;

/*!
 @method
 @abstract 获取已经订阅的流
 @param streamID 流id
 @return 操作结果
 */
- (CCStream *)streamSubedWithStreamID:(NSString *)streamID;

/*!
 @method
 @abstract 获取未订阅的流
 @param streamID 流id
 @return 操作结果
 */
- (CCStream *)streamCanSubWithStreamID:(NSString *)streamID;


/*!
 @method
 @abstract 获取已经移除的流
 @param streamID 流id
 @return 操作结果
 */
- (CCStream *)streamRemovedWithStreamID:(NSString *)streamID;

/*!
 @method
 @abstract 删除指定的流
 @param object 流对象
 */
- (void)streamRemoveFromRemovedStream:(CCStream *)object;

/*!
 @method
 @abstract 删除指定的流
 @param object object
 */
- (void)streamRemoveFromAllStreams:(CCStream *)object;

/*!
 @method
 @abstract 获取所有的流
 @return 操作结果
 */
- (NSArray *)getAllStreams;

/*!
 @method
 @abstract 释放所有的流
 */
- (void)releaseAllStreams;


/*!
 @method
 @abstract 获取错误信息
 @return 操作结果
 */
- (NSString *)errorMessageFromInfo:(NSDictionary*)dic;


@end
