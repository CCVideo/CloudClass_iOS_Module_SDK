//
//  HDSReportClient.h
//  CCFuncTool
//
//  Created by Chenfy on 2020/2/7.
//  Copyright © 2020 com.class.chenfy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, CCErrorLevel) {
    CCErrorLevel_VERBOSE = 2,
    CCErrorLevel_DEBUG = 3,
    CCErrorLevel_INFO = 4,
    CCErrorLevel_WARN = 5,
    CCErrorLevel_ERROR = 6,
    CCErrorLevel_ASSERT = 7,
};
NS_ASSUME_NONNULL_BEGIN

#pragma mark -- 事件信息
static NSString *KEvent_join = @"join";
static NSString *KEvent_pusher = @"pusher";
static NSString *KEvent_startLive = @"startLive";
static NSString *KEvent_streamConJoin = @"streamConJoin";
static NSString *KEvent_streamJoinChannel = @"streamJoinChannel";
static NSString *KEvent_streamJoinChannelFail = @"streamJoinChannelFail";

static NSString *KEvent_zegoPublish = @"zegoPublish";
static NSString *KEvent_agoraPublish = @"agoraPublish";
static NSString *KEvent_altasPublish = @"altasPublish";

static NSString *KEvent_zegopull = @"zegopull";
static NSString *KEvent_agoraPull = @"agoraPull";
static NSString *KEvent_altasPull = @"altasPull";

static NSString *KEvent_onUserJoined = @"onUserJoined";
static NSString *KEvent_onUserOffline = @"onUserOffline";
static NSString *KEvent_serverDisconnected = @"serverDisconnected";

static NSString *KEvent_teacherSwitchPlatform = @"teacherSwitchPlatform";
static NSString *KEvent_studentSwitchPlatform = @"studentSwitchPlatform";
static NSString *KEvent_updateMicResult = @"updateMicResult";

static NSString *KEvent_heartBeat = @"heartBeat";



@interface HDSReportInfo : NSObject
@property(nonatomic,assign)NSTimeInterval responseTime;
/*
 VERBOSE = 2;

 DEBUG = 3;

 INFO = 4;

 WARN = 5;

 ERROR = 6;

 ASSERT = 7;
 */
@property(nonatomic,assign)CCErrorLevel       level;
@property(nonatomic,copy)NSString       *socketUrl;
//基本数据
@property(nonatomic,copy)NSString       *var_business;
@property(nonatomic,copy)NSString       *var_appVer;

@property(nonatomic,copy)NSString       *var_cdn;
@property(nonatomic,copy)NSString       *var_appid;
@property(nonatomic,copy)NSDictionary   *var_device;
@property(nonatomic,assign)int          var_serviceplatform;

@property(nonatomic,copy)NSString       *var_roomid;
@property(nonatomic,copy)NSString       *var_role;
@property(nonatomic,copy)NSString       *var_userid;
@property(nonatomic,copy)NSString       *var_username;
//事件数据
@property(nonatomic,copy)NSString       *event_event;
@property(nonatomic,assign)int          event_code;
@property(nonatomic,copy)NSString       *event_msg;
//data
@property(nonatomic,copy)NSDictionary   *event_data_requestmsg;
@property(nonatomic,copy)NSDictionary   *event_data_responsemsg;
@property(nonatomic,copy)NSDictionary   *event_data_stream;
@property(nonatomic,copy)NSDictionary   *event_data_pusher;
@property(nonatomic,copy)NSDictionary   *event_data_heartBeat;


@end

@interface HDSReportClient : NSObject

- (void)reportLogInfo:(HDSReportInfo *)info;

@end

NS_ASSUME_NONNULL_END
