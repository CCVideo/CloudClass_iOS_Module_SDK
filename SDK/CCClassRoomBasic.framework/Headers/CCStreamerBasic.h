/*!
 
 @header CCStreamer.h
 
 @abstract 小班课业务逻辑基本类
 
 @author Created by cc on 17/1/5.
 
 @version 1.00 17/1/5 Creation
 */

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "CCEncodeConfig.h"
#import "CCStream.h"
#import <CCFuncTool/CCFuncTool.h>
#import "CCSpeaker.h"

@class CCStreamView;
/**
 @brief 异步请求闭包回调
 
 @param result 结果
 @param error 错误信息
 @param info 回调数据
 */
typedef void(^CCComletionBlock)(BOOL result, NSError *error, id info);

@protocol CCStreamerBasicDelegate <NSObject>
@optional
/**
 @brief Triggers when client is disconnected from conference server.
 */
- (void)onServerDisconnected;
/**
 @brief Triggers when a stream is added.
 @param stream The stream which is added.
 */
- (void)onStreamAdded:(CCStream*)stream;
/**
 @brief Triggers when a stream is removed.
 @param stream The stream which is removed.
 */
- (void)onStreamRemoved:(CCStream*)stream;
/**
 @brief Triggers when an error happened on a stream.
 @detail This event only triggered for a stream that is being publishing or
 subscribing. SDK will not try to recovery the certain stream when this event
 is triggered. If you still need this stream, please re-publish or
 re-subscribe.
 @param stream The stream which is corrupted. It might be a LocalStream or
 RemoteStream.
 @param error The error happened. Currently, errors are reported by MCU.
 */
- (void)onStreamError:(NSError *)error forStream:(CCStream *)stream;

//解码完成
- (void)onStreamFrameDecoded:(CCStream *)stream;
/**
 socket连接失败
 */
- (void)onFailed;

/**
 socket连接成功
 */
- (void)onSocketConnected:(NSString *)nsp;

/**
 socket重连
 */
- (void)onsocketReconnectiong;
/**
 socket断开(同时开始重连)
 */
- (void)onconnectionClosed;

/**
 收到消息

 @param event 时间名称
 @param object 数据
 */
- (void)onSocketReceive:(NSString *)event value:(id)object;

/**
 socket重连成功
 */
- (void)onSocketReconnected:(NSString *)nsp;

/**
 @brief Triggers when a message is received.
 @param senderId Sender's ID.
 @param message Message received.
 */
- (void)onMessageReceivedFrom:(NSString*)senderId message:(NSString*)message;

/**
 socket 收到消息
 */
- (void)onSocketReceive:(NSString *)message onTopic:(NSString *)topic;
@end


/**
 socket代理
 */
@protocol CCStreamerSocketMethod <NSObject>

/*!
 发送消息(没有消息内容)
 
 @param name 消息名称
 */
- (void)send:(NSString *)name;

/*!
 发送消息(消息为字符串)
 
 @param name 消息名称
 @param str  消息内容
 */
- (void)send:(NSString *)name str:(NSString *)str;
/*!
 发送消息
 
 @param name 消息名称
 @param par  数据
 */
- (void)send:(NSString *)name par:(NSDictionary *)par;

/*!
 发送Publish消息
 
 @param par  数据
 */
- (BOOL)sendPublishMessage:(NSDictionary *)par;

/*!
 发送消息(没有消息内容)
 
 @param message 消息名称
 */
- (void)sendMQTT:(NSString *)message;

/**
 添加observer
 */
- (void)addObserver:(id<CCStreamerBasicDelegate>)observer;

/*!
 移除observer
 */
- (void)removeObserver:(id<CCStreamerBasicDelegate>)observer;
@end

/*!
 @brief 业务逻辑基本类
 */
@interface CCStreamerBasic : NSObject<CCStreamerSocketMethod>
/**
 * 是否使用排麦组件
 */
@property (assign, nonatomic) BOOL isUsePaiMai;

/*!
 @brief 房间ID
 */
@property (strong, nonatomic, readonly) NSString *roomID;

/*!
@brief 账号ID
 */
@property (strong, nonatomic, readonly) NSString *accountID;

/*!
 @brief  用户ID
 */
@property (strong, nonatomic, readonly) NSString *userID;

/*!
 @brief  推流ID
 */
@property (strong, nonatomic) NSString *localStreamID;//自己推流的流ID

#pragma mark - observer
/**
 添加observer
 */
- (void)addObserver:(id<CCStreamerBasicDelegate>)observer;

/**
 移除observer
 */
- (void)removeObserver:(id<CCStreamerBasicDelegate>)observer;

/**
 初始化CCStreamerBasic实例
 */
+ (instancetype)sharedStreamer;

/*!
 * @method
 * @abstract 设置是否加入Mix流
 * @param needJoinMixStream 是否加入Mix流
 */
- (void)setNeedJoinMixStream:(BOOL)needJoinMixStream;

/*!
 * @method
 * @abstract 异常检测
 * @param exception 崩溃异常
 * @param log log记录
 */
+ (void)setCrashListen:(BOOL)exception log:(BOOL)log;

/*!
 * @method
 * @abstract log上报
 */
- (void)reportLogInfo;

#pragma mark -- 流状态检测
/**
 * @abstract 流状态检测监听事件
 * @param completion 回调
 */
- (BOOL)setListenOnStreamStatus:(CCComletionBlock)completion;

/**
 * @abstract 流检测监听取消
 */
- (void)cancelListenStreamStatus;

#pragma mark -- 本地音量分贝检测
/**
 * @abstract 麦克风音量监听事件
 * @param completion 回调
 */
- (BOOL)setListenOnMicVoice:(CCComletionBlock)completion;

/**
 * @abstract 本地音量监听取消
 */
- (void)cancelListenMicVoice;

#pragma mark - 配置socket重连参数

/*!
 * @method
 * @abstract 设置访问域名
 * @discussion 设置访问域名
 * @param domain 课堂域名
 * @param area 区域参数 |- 国内：HB、HD、HN | 亚洲：DNY | 美国：MD、MX | 欧洲：OZD、OZX -|
 * @result 操作结果
 */
- (BOOL)setServerDomain:(NSString *)domain area:(NSString *)area;

/*!
 * @method
 * @abstract 获取访问域名
 * @result 域名
 */
- (NSString *)getServerDomain;

#pragma mark -- 创建本地流
/*!
 @method
 @abstract 创建本地流
 @param createVideo 流是否创建视频
 @param front 设备相机
 */
- (void)createLocalStream:(BOOL)createVideo cameraFront:(BOOL)front;

#pragma mark - 开启预览
/*!
 @method (1000)
 @abstract 开始预览
 @discussion 开启摄像头开启预览，在推流开始之前开启
 @param completion 回调
 */
- (void)startPreview:(CCComletionBlock)completion;
#pragma mark - 停止预览
/*!
 @method
 @abstract 停止预览(login out 包含该操作)
 @return 操作结果
 */
- (BOOL)stopPreview:(CCComletionBlock)completion;
#pragma mark - 登录
/*!
 @method
 @abstract 登录接口(login和join的合集)
 @param accountID 账号ID
 @param sessionID sessionID
 @param areaCode 节点
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)joinWithAccountID:(NSString *)accountID sessionID:(NSString *)sessionID config:(CCEncodeConfig *)config areaCode:(NSString *)areaCode events:(NSArray *)event completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 登录接口
 @param accountID 账号ID
 @param sessionID sessionID
 @param areaCode 节点
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)loginWithAccountID:(NSString *)accountID sessionID:(NSString *)sessionID areaCode:(NSString *)areaCode completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 登录接口
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)joinWithConfig:(CCEncodeConfig *)config events:(NSArray *)event completion:(CCComletionBlock)completion;

#pragma mark - 流服务器重连
/*!
 @method
 @abstract 流服务器重连
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)streamServerReConnect:(CCComletionBlock)completion;

#pragma mark - 推流
/*!
 @method
 @abstract 开始推流
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)publish:(CCComletionBlock)completion;
#pragma mark -- 推流失败重推

#pragma mark - 停止推流
/*!
 @method
 @abstract 结束推流
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)unPublish:(CCComletionBlock)completion;
#pragma mark - 订阅
/*!
 @method
 @abstract 订阅某人画面(不需要观看的时候要取消订阅)
 @param stream    流
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)subcribeWithStream:(CCStream *)stream completion:(CCComletionBlock)completion;

#pragma mark - 取消订阅
/*!
 @method
 @abstract 取消订阅某人画面
 @param stream 流
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)unsubscribeWithStream:(CCStream *)stream completion:(CCComletionBlock)completion;

#pragma mark - 设置位置
/**
 @method
 @abstract 修改合流的主视频流
 @param streamId 流id
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)setRegion:(NSString *)streamId completion:(CCComletionBlock)completion;

#pragma mark - 退出
/*!
 @method
 @abstract 退出
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)leave:(CCComletionBlock)completion;
#pragma mark - inner method
/*!
 @method
 @abstract 退出房间
 @param sessionId sessionId
 @param completion 回调闭包
 */
- (void)userLogout:(NSString *)sessionId response:(CCComletionBlock)completion;

#pragma mark -- 修改流源发送状态
/*!
 @method
 @abstract 设置视频状态(开始直播之后生效)
 @param opened 视频状态
 @param userID 学生ID(为空表示操作自己的视频)
 
 @return 操作结果
 */
- (BOOL)setVideoOpened:(BOOL)opened userID:(NSString *)userID;

/*!
 @method
 @abstract 设置音频状态(开始直播之后才生效)
 @param opened 音频状态
 @param userID 学生ID(为空表示操作自己的音频)
 
 @return 操作结果
 */
- (BOOL)setAudioOpened:(BOOL)opened userID:(NSString *)userID;

#pragma mark -- 修改远程流接收状态
/*!
 @method
 @abstract 设置流视频的状态
 @param stream  流
 @param video   视频流状态(开启/关闭)
 @param completion 成功闭包
  @return 操作结果
 */
- (BOOL)changeStream:(CCStream *)stream videoState:(BOOL)video completion:(CCComletionBlock)completion;
#pragma mark - 设置流音频的状态
/*!
 @method
 @abstract 设置流音频的状态
 @param stream  流
 @param audio   音频流状态(开启/关闭)
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)changeStream:(CCStream *)stream audioState:(BOOL)audio completion:(CCComletionBlock)completion;

#pragma mark - 直播录制相关
/*!
 @method
 @abstract 直播录制相关
 @param completion 回调
 @return 操作结果
 */
- (BOOL)recordTo:(CCRecordType)type completion:(CCComletionBlock)completion;

#pragma mark - 停止直播
/*!
 @method
 @abstract 停止直播
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)stopLive:(CCComletionBlock)completion;
#pragma mark - 开启直播
/*!
 @method
 @abstract 开启直播
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)startLive:(CCComletionBlock)completion;
/*!
 @method
 @abstract 开启直播
 @param record 是否开启直播录制
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)startLiveWithRecord:(BOOL)record completion:(CCComletionBlock)completion;
#pragma mark - 查询直播间状态
/*!
 @method
 @abstract 查询直播间状态
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)getLiveStatus:(CCComletionBlock)completion;

#pragma mark - 设置日志是否开启(默认开启)
/*!
 @method
 @abstract 设置日志是否开启(默认开启)
 @param state 状态
 */
+ (void)setLogState:(BOOL)state;

#pragma mark - 房间配置获取及修改
/*!
 @method
 @abstract 获取直播间简介
 @param roomID 房间ID
 @param completion 回调
 @return 操作结果
 */
- (BOOL)getRoomDescWithRoonID:(NSString *)roomID completion:(CCComletionBlock)completion;

#pragma mark - 节点列表
/*!
 @method
 @abstract 获取节点列表
 @param accountId 用户账号ID
 @param completion 回调
 @return 操作结果
 */
- (BOOL)getRoomServerWithAccountID:(NSString *)accountId completion:(CCComletionBlock)completion;
/*!
 @method
 @abstract 获取节点列表
 @param accountId 用户账号ID
 @param detect 是否包含延时探测
 @param completion 回调
 @return 操作结果
 */
- (BOOL)getRoomServerList:(NSString *)accountId detect:(BOOL)detect completion:(CCComletionBlock)completion;

#pragma mark - 人员状态custom变更
/*!
 @method
 @abstract 更新custom状态
 @param custom (0~999，初始和默认都为0)
 @param userid 用户id
 @param completion 回调
 @return 操作结果
 */
- (BOOL)updateUserCustom:(NSInteger)custom userId:(NSString *)userid completion:(CCComletionBlock)completion;

#pragma mark - 踢出房间
/*!
 @method
 @abstract 踢出房间
 @param userID     用户ID
 
 @return 操作结果
 */
- (BOOL)kickUserFromRoom:(NSString *)userID;

/*!
 @method
 @abstract 获取当前CCRoom
 @return 当前房间信息
 */
- (CCRoom *)getRoomInfo;

/*!
 @method
 @abstract 获取当前CCSpeaker
 @return 当前流信息
 */
- (CCSpeaker *)getSpeakInfo;

/**
 @method
 @abstract 获取用户
 
 @param userID 用户ID
 @return 用户
 */
- (CCUser *)getUSerInfoWithUserID:(NSString *)userID;

/**
 @method
 @abstract 获取用户
 
 @param streamID 流ID
 @return 用户
 */
- (CCUser *)getUserInfoWithStreamID:(NSString *)streamID;

/**
 @method
 @abstract 获取用户
 
 @param streamID 流ID
 @return 用户
 */
- (CCStream *)getStreamWithStreamID:(NSString *)streamID;

/*!
 @method 数据释放
 */
- (void)clearData;

@property (strong, nonatomic) CCStreamView *preView;

#pragma mark 新旁听功能
/**
 @method
 @abstract 旁听接口
 @param uid 用户id
 @param token token
 @param isp 节点
 */
- (void)joinAudit:(NSString *)uid token:(NSString *)token isp:(NSString *)isp complete:(CCComletionBlock)complete;

/**
 @method
 @abstract 创建socket连接
 @param events events
 */
- (void)auditCreateSocket:(NSArray *)events;

/**
 @method
 @auditCreateSocketForPlayback 创建socket连接
 */
- (void)auditCreateSocketForPlayback:(NSDictionary *)room;


#pragma mark --------- 互动相关 ------------
#pragma mark - 更新房间在线人数
/*!
 @method
 @abstract 更新房间在线人数
 */
- (BOOL)updateUserCount;

#pragma mark - 鲜花、奖杯
/**
 @method
 @abstract 奖杯、鲜花
 @param uid 用户id
 @param uName 用户名称
 @param actionType 操作类型 | flower 鲜花 cup 奖杯
 @param sid 发送者id
 */
- (BOOL)rewardUid:(NSString *)uid uName:(NSString *)uName type:(NSString *)actionType sender:(NSString *)sid;

#pragma mark - 公告清除
/*!
 @method
 @abstract 清除公告
 @param completion 回调结果
 @return 操作结果
 */
- (BOOL)removeAnnouncement:(CCComletionBlock)completion;

#pragma mark - 公告
/*!
 @method
 @abstract 发布公告
 @param message    公告内容
 @param completion 结果
 @return 操作结果
 */
- (BOOL)releaseAnnouncement:(NSString *)message completion:(CCComletionBlock)completion;

#pragma mark - 答题卡
/**
 @method
 @abstract 发送答题答案
 
 @param multAns 多选的答案
 @param singleAns 单选答案
 @param voteID 答题ID
 @param publisherID 答题发起者ID
 */
- (BOOL)sendVoteSelected:(NSArray *)multAns singleAns:(NSInteger)singleAns voteID:(NSString *)voteID publisherID:(NSString *)publisherID;

#pragma mark - 头脑风暴
/**
 @method
 @abstract 发送头脑风暴答案
 @param Id 问题id
 @param title 问题title
 @param content 问题回答
 */
- (BOOL)sendBrainReply:(NSString *)Id title:(NSString *)title text:(NSString *)content;

#pragma mark - 投票
/**
 @method
 @abstract 发送投票答案
 @param Id 投票id
 @param title 投票title
 @param choices 投票回答[0、1、2、3、4]
 */
- (BOOL)sendVoteTickedReply:(NSString *)Id title:(NSString *)title choice:(NSArray *)choices;

/*! @abstract 学生答到 */
- (BOOL)studentNamed;

/*! @abstract 获取答到的学生列表 */
- (NSArray *)getStudentNamedList;

/*! @abstract 获取老师点名的信息(老师端有效) */
- (NSDictionary *)getNamedInfo;

#pragma mark - 点名相关
/*!@abstract 老师开始点名 */
- (BOOL)startNamed:(NSTimeInterval)duration;


@end

