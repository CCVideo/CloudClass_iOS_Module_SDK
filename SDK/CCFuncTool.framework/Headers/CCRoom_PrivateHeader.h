//
//  CCRoom_PrivateHeader.h
//  CCStreamer
//
//  Created by cc on 17/4/28.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCRoom.h"

@interface CCRoom ()

@property (assign, nonatomic, readwrite) CCClassType room_class_type;//连麦方式
@property (strong, nonatomic, readwrite) NSString *room_desc;//房间描述
@property (assign, nonatomic, readwrite) CCLiveStatus live_status;//直播间状态
@property (assign, nonatomic, readwrite) NSInteger room_max_streams;//最大连麦人数
@property (assign, nonatomic, readwrite) NSInteger room_max_users;//房间人数上限
@property (strong, nonatomic, readwrite) NSString *room_name;//房间名称
@property (assign, nonatomic, readwrite) CCUserBitrate room_publisher_bitrate;//老师端推流码率
@property (assign, nonatomic, readwrite) CCUserBitrate room_talker_bitrate;//学生端推流码率
@property (assign, nonatomic, readwrite) CCUserBitrate room_publisher_audioBitrate;
@property (assign, nonatomic, readwrite) CCUserBitrate room_talker_audioBitrate;
@property (assign, nonatomic, readwrite) CCRoomTemplate room_template;//房间模板
@property (strong, nonatomic, readwrite) NSString *user_id;//pusher  用户id
@property (strong, nonatomic, readwrite) NSString *user_name;//用户登录名
@property (assign, nonatomic, readwrite) CCRole user_role;//用户角色
@property (assign, nonatomic, readwrite) CCVideoMode room_video_mode;//音视频模式
@property (assign, nonatomic, readwrite) BOOL room_allow_chat;//房间是否处于全体禁言
@property (assign, nonatomic, readwrite) BOOL room_allow_audio;//房间是否全体关闭麦克风
@property (assign, nonatomic, readwrite) BOOL audioState;//音频是否开启
@property (assign, nonatomic, readwrite) BOOL videoState;//视频是否开启
@property (assign, nonatomic, readwrite) NSInteger room_user_count;//房间人数
@property (assign, nonatomic, readwrite) BOOL allow_chat;//个人是否被禁言(老师不会被禁言)
@property (strong, nonatomic, readwrite) NSString *teacherFllowUserID;//学生端是否跟随老师画面(只在当次连麦有效，当老师开启之后，学生不能切换视频大小)
@property (strong, nonatomic, readwrite) NSMutableArray *room_userList;//房间的用户列表
@property (strong, nonatomic, readwrite) NSString *docServer;//文档服务器地址
@property (strong, nonatomic, readwrite) NSString *rtmpUrl;
@property (assign, nonatomic, readwrite) NSTimeInterval timerStart;
@property (assign, nonatomic, readwrite) NSTimeInterval timerDuration;
@property (assign, nonatomic, readwrite) BOOL rotateState;
@property (assign, nonatomic, readwrite) float rotateTime;
@property (strong, nonatomic, readwrite) NSString *areaCode;
@property (assign, nonatomic, readwrite) BOOL show_exit;
@property (strong, nonatomic, readwrite) NSString *video_zoom;
@property (assign, nonatomic, readwrite) NSTimeInterval videoSuspendTime;
@property (assign, nonatomic, readwrite) NSInteger videoStatus;
@property (strong, nonatomic) NSString *room_chart_server;//pusher接口
@property (strong, nonatomic) NSString *live_atlas_token;//intel token
@property (strong, nonatomic) NSString *user_roomID;//房间id
@property (strong, nonatomic) NSString *user_sessionID;//用户sessionID
//@property (strong, nonatomic) NSString *live_startTime;
@property (strong, nonatomic) NSString *room_userID;//扫码的userid
@property (assign, nonatomic) CCVideoOriMode isLandSpace;//是否是横屏推流
//暖场动画参数
@property (strong, nonatomic, readwrite) NSDictionary *warmVideoDic;
/** 房间是否开启助教功能 */
@property (assign, nonatomic, readwrite)BOOL  room_assist_on;
/** 房间是否开启手动录制功能 */
@property (assign, nonatomic, readwrite)BOOL  room_manual_record;
/** 房间是否开启cdn推流 */
@property (assign, nonatomic, readwrite)NSInteger  room_pubcdn_switch;
/** 房间开启实时画笔功能 */
@property(nonatomic,assign,readwrite)BOOL room_timely_pencil;

@property (assign, nonatomic) NSTimeInterval lastPusherTime;//speak_context、room_context过来的时间戳，防止先发后到状态刷新错误
@property (assign, nonatomic) NSTimeInterval liveStartTime;

//Chenfy..NEW
@property (strong, nonatomic) NSDictionary *room_userSettings; //房间用户信息配置
@property (strong, nonatomic) NSMutableDictionary *room_blackList; //旁听的禁言列表

//token验证
#pragma mark copy
@property(nonatomic,copy)NSString *authSessionId;
@property(nonatomic,copy)NSString *authClientId;

//数据上报
#pragma mark strong
@property(nonatomic,strong)NSString *domainReportDefault;
@property(nonatomic,strong)NSString *domainReportServer;
#pragma mark assign
@property(nonatomic,assign)int reportTimeInterval;
@property (assign, nonatomic)NSTimeInterval lastDocUpdateTime;//为了保持文档同步，做的记录最新文档更新时间

- (void)configureWith:(NSDictionary *)dic;
+ (CCRole)roleFromStr:(NSString *)str;
+ (NSString *)stringFromRole:(CCRole)role;

+ (NSString *)bitStrFrom:(CCUserBitrate)bitType;
+ (CCUserBitrate)birateTypeFromValue:(float)value;

- (NSMutableArray *)userListFromRoomContext:(NSDictionary *)roomContext;

#pragma mark -- 旁听者
@property(nonatomic,copy,readwrite)NSString *login_userId;
@property(nonatomic,copy,readwrite)NSString *login_Token;
@property(nonatomic,copy,readwrite)NSString *login_isp;

#pragma mark strong
//@property(nonatomic,assign,readwrite)BOOL allow_chat;
//@property(nonatomic,copy,readwrite) NSString *room_name;
//@property(nonatomic,copy,readwrite)NSString *room_desc;
@property(nonatomic,strong,readwrite)NSArray *array_chat_server;
@property(nonatomic,strong,readwrite)NSArray *array_doc_server;
@property(nonatomic,copy,readwrite)NSString *room_id;
@property(nonatomic,strong,readwrite)NSDictionary *media;
//@property(nonatomic,copy,readwrite)NSString *rtmp_addr;

@property(nonatomic,copy,readwrite)NSString *live_id;
@property(nonatomic,copy,readwrite)NSString *live_last;
//@property(nonatomic,copy,readwrite)NSString *live_startTime;
//@property(nonatomic,assign,readwrite)CCLiveStatus  live_status;

//@property(nonatomic,copy,readwrite)NSString *user_id;
//@property(nonatomic,copy,readwrite)NSString *user_name;
@property(nonatomic,copy,readwrite)NSString *user_role_string;
@property(nonatomic,copy,readwrite)NSString *user_roomId;
@property(nonatomic,copy,readwrite)NSString *user_sessionId;
//add
@property(nonatomic,assign,readwrite)BOOL user_allow_chat;

@property(nonatomic,strong,readwrite)NSDictionary *warm_video;

/**
 @property
 @abstract mqtt请求地址
 */
@property(nonatomic,copy,readwrite)NSString *mq_server;

- (void)configData:(NSDictionary *)dic;
- (void)configToken:(NSString *)token;
- (void)configUid:(NSString *)uid;
- (void)configIsp:(NSString *)isp;

@end
