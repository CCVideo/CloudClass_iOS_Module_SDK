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
@property (assign, nonatomic) int maxAudioBand;

@property (strong, nonatomic) NSMutableArray *subAbleStreams; //可订阅
@property (strong, nonatomic) NSMutableArray *calledSubAbleStreams;//已通知
@property (strong, nonatomic) NSMutableArray *subStreams; //已订阅
@property (strong, nonatomic) NSMutableArray *removedStreams; //已删除
@property (strong, nonatomic) NSMutableArray *allStreams;    //所有流

@property (strong, nonatomic) CCStream *localStream;
@property (strong, nonatomic) CCStream *mixedStream;
@property (assign, nonatomic) BOOL isSub;

- (CCStream *)getStreamWithID:(NSString *)streamID;

- (CCStream *)getSubscribeStreamWithID:(NSString *)streamID;

- (CCStream *)getRemovedStremWithID:(NSString *)streamID;

- (void)removeStreamFromRemovedStream:(CCStream *)object;
- (void)removeStreamdFromAllStreams:(CCStream *)object;

- (NSArray *)getAllStreams;

- (void)realsesAllStream;

- (NSString *)getErrorMsgFrom:(NSDictionary*)dic;

@end
