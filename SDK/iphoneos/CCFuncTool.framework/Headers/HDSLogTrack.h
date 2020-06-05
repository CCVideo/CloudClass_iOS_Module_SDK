//
//  HDSLogTrack.h
//  CCClassRoomBasic
//
//  Created by Chenfy on 2020/3/29.
//  Copyright © 2020 cc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CCFuncTool/CCFuncTool.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark -- 类型定义
typedef NSString KS;
typedef int      KI;
typedef NSDictionary KDIC;
typedef CFAbsoluteTime KT;

#pragma mark -- 操作状态码
typedef NS_ENUM(NSInteger,KStatus) {
    KStatus_200 = 200,
    KStatus_400 = 400,
    KStatus_401 = 401,
    KStatus_402 = 402
};

@interface HDSLogTrack : NSObject

+ (instancetype)logTrack;

#pragma mark -- 基本信息更新
- (void)updateAreaCode:(KS *)areacode;
- (void)updateJoinRoom:(KS *)accountid roomid:(KS *)rid platform:(KI)platform;
- (void)updateJoinRole:(KS *)role userid:(KS *)uid uname:(KS *)uname;
#pragma mark -- join上报
- (void)rJoinSuccess:(KT)start request:(KDIC *)request message:(KS *)msg;
- (void)rJoinFail:(KT)start request:(KDIC *)request response:(KDIC *)response;
#pragma mark -- API 上报
- (void)rReportApi:(KT)start event:(KS *)event request:(KDIC *)request response:(KDIC *)response;
/*
 KEvent_pusher
 KEvent_streamConJoin
 
 KEvent_streamJoinChannel
 KEvent_streamJoinChannelFail
 
 KEvent_zegoPublish
 KEvent_agoraPublish
 KEvent_altasPublish
 
 KEvent_zegopull
 KEvent_agoraPull
 KEvent_altasPull
 
 KEvent_teacherSwitchPlatform
 KEvent_studentSwitchPlatform
 
 KEvent_serverDisconnected
 */
- (void)rReport:(KS *)event status:(KStatus)status message:(KS *)msg;
- (void)rReport:(KS *)event status:(KStatus)status info:(KDIC *)info;

/*
 KEvent_onUserJoined
 KEvent_onUserOffline
 */
- (void)rReportStreamJoinLeave:(BOOL)isJoin streamid:(KS *)streamid;

/*
 API 网络请求异常时调用
 */
- (void)rNetFail:(KT)start event:(KS *)event request:(KDIC *)request msg:(KS *)msg;

/*
 400: SOCKET重连 - reconnect
 401: SOCKET断开 - disconnect
 */
- (void)rReportPusherStatus:(BOOL)isConnect socketUrl:(KS *)socketUrl;

/*
 timerNum 上报次数
 liveStartTime 直播开始时间
 */
- (void)rReportHeartBeat:(int)timerNum liveStartTime:(KS *)liveStartTime;

@end

NS_ASSUME_NONNULL_END
