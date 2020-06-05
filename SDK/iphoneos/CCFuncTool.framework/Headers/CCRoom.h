//
//  CCRoom.h
//  CCStreamer
//
//  Created by cc on 17/4/28.
//  Copyright © 2017年 cc. All rights reserved.
//

/*!
 @header CCRoom.h
 @abstract 房间数据模型
 @author Created by cc on 17/5/19
 @version 1.00 Created by cc on 17/5/19
 */

#import <Foundation/Foundation.h>
#import "CCMacroHeader.h"

/*!
 * @brief 共享桌面流名字宏定义
 */
extern NSString* const ShareScreenViewName;

/*!
 * @brief 共享桌面流用户ID宏定义
 */
extern NSString* const ShareScreenViewUserID;
/*!
 * @brief 老师高拍仪用户名字宏定义
 */
extern NSString* const TeacherSecondStreamViewName;
/*!
 * @brief 老师高拍仪用户ID宏定义
 */
extern NSString* const TeacherSecondStreamViewUserID;
/*!
 * @brief 旁听CDN推流失败通知
 */
extern NSString* const CCNotiCDNPushError;
/*!
 * @brief 分流录制失败通知
 */
extern NSString* const CCNotiStartRecorderError;

/*!
 * @brief 异步请求闭包回调.
 @param result 结果
 @param error 错误信息
 @param info 回调数据
 */
typedef void(^CCComletionBlock)(BOOL result, NSError *error, id info);
/*!
 * @brief socket.io事件通知.
 */
extern NSString* const CCNotiReceiveSocketEvent;
/*!
 * @brief 断网事件通知.
 */
extern NSString* const CCNotiNetWorkDicconnect;
/*!
 * @brief 学生排麦中 轮到自己连麦(开始推流)通知.
 */
extern NSString* const CCNotiNeedStartPublish;
/*!
 * @brief 老师端踢下麦(学生端停止推流).
 */
extern NSString* const CCNotiNeedStopPublish;
/*!
 * @brief 有学生端连麦、其他学生端订阅该学生的流通知.
 */
extern NSString* const CCNotiNeedSubscriStream;
/*!
 * @brief 学生端下麦、其他学生取消订阅该学生的流通知.
 */
extern NSString* const CCNotiNeedUnSubcriStream;
/*!
 * @brief 退出房间(可能是被老师踢出房间)通知.
 */
extern NSString* const CCNotiNeedLoginOut;

/*!
 @class
 @abstract 房间数据模型
 */
@interface CCRoom : NSObject
/*!
 @property
 @abstract 连麦方式
 */
@property (assign, nonatomic, readonly) CCClassType room_class_type;
/*!
 @property
 @abstract 房间描述
 */
@property (strong, nonatomic, readonly) NSString *room_desc;
/*!
 @property
 @abstract 直播间状态
 */
@property (assign, nonatomic, readonly) CCLiveStatus live_status;
/*!
 @property
 @abstract 最大连麦人数
 */
@property (assign, nonatomic, readonly) NSInteger room_max_streams;
/*!
 @property
 @abstract 房间人数上限
 */
@property (assign, nonatomic, readonly) NSInteger room_max_users;
/*!
 @property
 @abstract 房间名称
 */
@property (strong, nonatomic, readonly) NSString *room_name;
/*!
 @property
 @abstract 老师端推流视频码率
 */
@property (assign, nonatomic, readonly) CCUserBitrate room_publisher_bitrate;
/*!
 @property
 @abstract 学生端推流视频码率
 */
@property (assign, nonatomic, readonly) CCUserBitrate room_talker_bitrate;
/*!
 @property
 @abstract 老师端推流音频码率
 */
@property (assign, nonatomic, readonly) CCUserBitrate room_publisher_audioBitrate;
/*!
 @property
 @abstract 学生端推流音频码率
 */
@property (assign, nonatomic, readonly) CCUserBitrate room_talker_audioBitrate;
/*!
 @property
 @abstract 房间模板
 */
@property (assign, nonatomic, readonly) CCRoomTemplate room_template;
/*!
 @property
 @abstract 用户id
 */
@property (strong, nonatomic, readonly) NSString *user_id;
/*!
 @property
 @abstract 用户登录名
 */
@property (strong, nonatomic, readonly) NSString *user_name;
/*!
 @property
 @abstract 用户角色
 */
@property (assign, nonatomic, readonly) CCRole user_role;
/*!
 @property
 @abstract 音视频模式
 */
@property (assign, nonatomic, readonly) CCVideoMode room_video_mode;
/*!
 @property
 @abstract 房间是否处于全体禁言
 */
@property (assign, nonatomic, readonly) BOOL room_allow_chat;

/**
 @property
 @abstract 房间是否全体关闭麦克风
 */
@property (assign, nonatomic, readonly) BOOL room_allow_audio;
/*!
 @property
 @abstract 音频是否开启
 */
@property (assign, nonatomic, readonly) BOOL audioState;
/*!
 @property
 @abstract 视频是否开启
 */
@property (assign, nonatomic, readonly) BOOL videoState;
/*!
 @property
 @abstract 房间人数
 */
@property (assign, nonatomic, readonly) NSInteger room_user_count;
/*!
 @property
 @abstract 个人是否被禁言(老师不会被禁言)
 */
@property (assign, nonatomic, readonly) BOOL allow_chat;
/*!
 @property
 @abstract 学生端是否跟随老师画面(只在当次连麦有效，当老师开启之后，学生不能切换视频大小)
 */
@property (strong, nonatomic, readonly) NSString *teacherFllowUserID;
/*!
 @property
 @abstract 房间的用户列表
 */
@property (strong, nonatomic, readonly) NSMutableArray *room_userList;
/*!
 @property
 @abstract 文档服务器地址
 */
@property (strong, nonatomic, readonly) NSString *docServer;
/*!
 @property
 @abstract 第三方推流地址
 */
@property (strong, nonatomic, readonly) NSString *rtmpUrl;
/*!
 @property
 @abstract 计时器剩余时间(秒)
 */
@property (assign, nonatomic, readonly) NSTimeInterval timerStart;
/*!
 @property
 @abstract 计时器时长
 */
@property (assign, nonatomic, readonly) NSTimeInterval timerDuration;

/**
 @property
 @abstract 房间开播时间
 */
@property (assign, nonatomic, readonly) NSTimeInterval liveStartTime;

/**
 @property
 @abstract 房间开播时间
 */
@property (assign, nonatomic, readonly) NSTimeInterval liveTimeoffset;

/**
 @property
 @abstract 轮播状态
 */
@property (assign, nonatomic, readonly) BOOL rotateState;
/**
 @property
 @abstract 轮播间隔
 */
@property (assign, nonatomic, readonly) float rotateTime;
/**
 @property
 @abstract 节点
 */
@property (strong, nonatomic, readonly) NSString* areaCode;
/**
 @property
 @abstract 是否显示退出按钮
 */
@property (assign, nonatomic, readonly) BOOL show_exit;
/**
 @property
 @abstract 老师双击放大显示的视频id
 */
@property (strong, nonatomic, readonly) NSString *video_zoom;
/**
 @property
 @abstract 插播视频暂停时间
 */
@property (assign, nonatomic, readonly) NSTimeInterval videoSuspendTime;
/**
 @property
 @abstract 插播视频的播放状态
 */
@property (assign, nonatomic, readonly) NSInteger videoStatus;
/**
 @property
 @abstract 暖场动画
 */
@property (strong, nonatomic, readonly) NSDictionary *warmVideoDic;

#pragma mark -- 旁听者
/**
 @property
 @abstract 登录userid
 */
@property(nonatomic,copy,readonly)NSString *login_userId;
/**
 @property
 @abstract 登录token
 */
@property(nonatomic,copy,readonly)NSString *login_Token;
/**
 @property
 @abstract 登录节点
 */
@property(nonatomic,copy,readonly)NSString *login_isp;
#pragma mark strong
/**
 @property
 @abstract 聊天服务器地址
 */
@property(nonatomic,strong,readonly)NSArray *array_chat_server;
/**
 @property
 @abstract 文档服务器地址
 */
@property(nonatomic,strong,readonly)NSArray *array_doc_server;
/**
 @property
 @abstract 房间id
 */
@property(nonatomic,copy,readonly)NSString *room_id;
/**
 @property
 @abstract 插播视频数据
 */
@property(nonatomic,strong,readonly)NSDictionary *media;
/**
 @property
 @abstract 直播id
 */
@property(nonatomic,copy,readonly)NSString *live_id;
/**
 @property
 @abstract 已经开播时间
 */
@property(nonatomic,copy,readonly)NSString *live_last;
/**
 @property
 @abstract 用户房间id
 */
@property(nonatomic,copy,readonly)NSString *user_roomId;
/**
 @property
 @abstract 用户是否允许聊天
 */
@property(nonatomic,assign,readonly)BOOL user_allow_chat;
/**
 @property
 @abstract 暖场视频数据
 */
@property(nonatomic,strong,readonly)NSDictionary *warm_video;
/**
 @property
 @abstract 房间是否开启助教功能
 */
@property (assign, nonatomic, readonly) BOOL  room_assist_on;
/**
 @property
 @abstract 房间是否开启手动录制功能
 */
@property (assign, nonatomic, readonly) BOOL  room_manual_record;
/**
 @property
 @abstract mqtt请求地址
 */
@property(nonatomic,copy,readonly)NSString *mq_server;
/**
 @property
 @abstract cdn推流设置
 */
@property(nonatomic,assign,readonly)NSInteger room_pubcdn_switch;
/**
 @property
 @abstract 房间开启实时画笔功能
 */
@property(nonatomic,assign,readonly)BOOL room_timely_pencil;
/**
 @property
 @abstract 房间默认分辨率
 */
@property(nonatomic,assign,readonly)NSInteger room_default_resolution;
/**
 @property
 @abstract 房间分辨率限制
 */
@property(nonatomic,assign,readonly)NSInteger room_max_resolution;

/**
 @property
 @abstract 房间服务类型
 */
@property(nonatomic,assign,readonly)CCRoomType room_server_type;
/**
 @property
 @abstract 房间级配置（学员订阅其他学员的流时：是否打开音频）
 */
@property(nonatomic,assign,readonly)NSInteger room_talker_audio;

@end
