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

#import "CCStreamerBasic.h"

@interface CCSpeaker : NSObject
//LiveClass
/**
 @property
 @abstract 最大带宽
 */
@property (assign, nonatomic) int maxAudioBand;
/**
 @property
 @abstract 可订阅的流
 */
@property (strong, nonatomic) NSMutableArray *subAbleStreams; //可订阅
/**
 @property
 @abstract 已通知订阅的流
 */
@property (strong, nonatomic) NSMutableArray *calledSubAbleStreams;//已通知
/**
 @property
 @abstract 已订阅的流
 */
@property (strong, nonatomic) NSMutableArray *subStreams; //已订阅
/**
 @property
 @abstract 已删除的流
 */
@property (strong, nonatomic) NSMutableArray *removedStreams; //已删除
/**
 @property
 @abstract 所有流
 */
@property (strong, nonatomic) NSMutableArray *allStreams;    //所有流

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
/**
 @property
 @abstract 是否已订阅
 */
@property (assign, nonatomic) BOOL isSub;

/*!
 @method
 @abstract 获取流对象
 @param streamID 流id
 @return 操作结果
 */
- (CCStream *)getStreamWithID:(NSString *)streamID;

/*!
 @method
 @abstract 获取已经订阅的流
 @param streamID 流id
 @return 操作结果
 */
- (CCStream *)getSubscribeStreamWithID:(NSString *)streamID;
/*!
 @method
 @abstract 获取已经移除的流
 @param streamID 流id
 @return 操作结果
 */
- (CCStream *)getRemovedStremWithID:(NSString *)streamID;
/*!
 @method
 @abstract 删除指定的流
 @param object 流对象
 */
- (void)removeStreamFromRemovedStream:(CCStream *)object;
/*!
 @method
 @abstract 删除指定的流
 @param object object
 */
- (void)removeStreamdFromAllStreams:(CCStream *)object;

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
- (void)realsesAllStream;

/*!
 @method
 @abstract 获取错误信息
 @return 操作结果
 */
- (NSString *)getErrorMsgFrom:(NSDictionary*)dic;

/** 移除缓存数据 */
- (void)clearCacheDatas;

@end
