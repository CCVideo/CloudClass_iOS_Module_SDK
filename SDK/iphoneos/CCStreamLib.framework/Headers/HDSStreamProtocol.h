//
//  HDSStreamProtocol.h
//  CCStreamLib
//
//  Created by Chenfy on 2020/3/16.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LiveStream.h"
#import "HDSLiveTranscoding.h"

/** 直播事件状态 */
typedef enum : NSUInteger {
    /** 播放直播开始重试 */
    CCPlay_BeginRetry = 1,
    /** 播放直播重试成功 */
    CCPlay_RetrySuccess = 2,
    
    /** 发布直播开始重试 */
    CCPublish_BeginRetry = 3,
    /** 发布直播重试成功 */
    CCPublish_RetrySuccess = 4,
    
    /** 拉流临时中断 */
    CCPlay_TempDisconnected = 5,
    /** 推流临时中断 */
    CCPublish_TempDisconnected = 6,
    
    /** 视频卡顿开始 */
    CCPlay_VideoBreak = 7,
    /** 视频卡顿结束 */
    CCPlay_VideoBreakEnd = 8,
    
    /** 音频卡顿开始 */
    CCPlay_AudioBreak = 9,
    /** 音频卡顿结束 */
    CCPlay_AudioBreakEnd = 10,
    
    /** 注册推流信息失败 */
    CCPublishInfo_RegisterFailed = 11,
    /** 注册推流信息成功 */
    CCPublishInfo_RegisterSuccess = 12,
    
} CCLiveEvent;

NS_ASSUME_NONNULL_BEGIN
/** 镜像类型 */
typedef NS_ENUM(NSInteger,LiveMirrorType) {
    /** 预览启用镜像，推流不启用镜像 */
    LiveMirrorType_PreviewMirrorPublishNoMirror,
    /** 预览启用镜像，推流启用镜像 */
    LiveMirrorType_PreviewCaptureBothMirror,
    /** 预览不启用镜像，推流不启用镜像 */
    LiveMirrorType_PreviewCaptureBothNoMirror,
    /** 预览不启用镜像，推流启用镜像 */
    LiveMirrorType_PreviewNoMirrorPublishMirror
};


//视频填充模式
typedef NS_ENUM(NSInteger,HDSRenderMode){
    /** 等比缩放，可能有黑边 */
    HDSRenderMode_AspactFit,
    /** 等比缩放填充整View，可能有部分被裁减 */
    HDSRenderMode_AspactFill
};
//流状态
typedef NS_ENUM(NSInteger,LiveBlaskStatus) {
    LiveBlaskStatus_Init = 1000, //初始状态
    LiveBlaskStatus_isOK, //流正常
    LiveBlaskStatus_isLoading, //正在加载流
    LiveBlaskStatus_isBlack //流异常（黑流）
};

@protocol HDSStreamAPIProtocol <NSObject>
/**
* 初始化
* @param role 角色
* @param rid 房间id
* @param appid 声网appid
* @param uid 声网的uid
* @param token 声网的token
*/
- (instancetype)initAgoraLiveManager:(int)role roomid:(NSString *)rid appid:(NSString *)appid uid:(int)uid token:(NSString *)token;

/**
* 初始化
* @param rid CC直播间id
* @param userid CC用户id
* @param appid 即构appid
* @param appsign 即构签名信息
* @param token 即构token
* @param sid 即构的流id
*/
- (instancetype)initZegoLiveManager:(NSString *)rid appid:(long)appid appsign:(NSData *)appsign userid:(NSString *)userid token:(NSString *)token streamid:(NSString *)sid;

/**
* 初始化
* @param rid CC直播间id
* @param userid CC用户id
* @param token Atlas token
 */
- (instancetype)initAtlasLiveManager:(NSString *)role rid:(NSString *)rid userid:(NSString *)userid token:(NSString *)token;

/**
 * 设置视频配置
 *  320*240     0
 *  640*480     1
 *  1280*720    2
 */
- (void)configEngine:(int)resolution;

/**
* 更新 token
*/
- (void)updateToken:(NSString *)token;

/**
* 加入房间
*/
- (int)joinChannel:(BOOL)isLive;

/**
* 离开频道
*/
- (int)leaveChannel;

/**
* 开始预览
*/
- (int)startPreview:(HDSRenderMode)renderMode view:(UIView *)view;

/**
* 切换摄像头
*/
- (int)switchCamera;

/**
* 停止预览
*/
- (int)stopPreview;

/**
 * 渲染远程流
 */
- (int)setupRemoteVideo:(LiveStream *)stream videoView:(UIView *)videoView renderMode:(HDSRenderMode)mode;

/*
 * 设置流镜像
 */
- (void)setVideoMirrorMode:(LiveMirrorType)mode;

#pragma mark --
#pragma mark -- new
- (int)startPublish:(LiveStream *)stream;

- (int)stopPublish;

#pragma mark --
#pragma mark -- 拉流
- (int)subscribeStream:(LiveStream *)stream;
- (int)unSubscribeStream:(LiveStream *)stream;

- (int)renewToken:(NSString * _Nonnull)token;

#pragma mark -- 基础功能
/**
* 停止/恢复接收指定音频流
*/
- (int)muteRemoteAudioStream:(LiveStream *)stream mute:(BOOL)mute;
//public abstract void muteRemoteAudioStream(String streamId,int uid,boolean muted);

/**
* 停止/恢复接收指定视频流
*/
- (int)muteRemoteVideoStream:(LiveStream *)stream mute:(BOOL)mute;
//public abstract void muteRemoteVideoStream(String streamId, int uid,boolean muted);

/**
 * 开/关本地音频采集
 */
- (int)enableLocalAudio:(BOOL)enabled;

/**
 * 开/关本地视频采集
 */
- (int)enableLocalVideo:(BOOL)enabled;

#pragma mark -- 音视频功能

//配置设备方向
- (BOOL)setAppOrientation:(UIInterfaceOrientation)orientation;
/**
* @abstract 设置本地流预览是否跟随重力改变
*/
- (void)setPreviewGravityFollow:(BOOL)follow;

-(void)destory;

#pragma mark --
#pragma mark -- CDN 推流
- (int)managerAddPublishStreamUrl:(NSString *)url transcodingEnabled:(BOOL)encode;
- (int)managerRemovePublishStreamUrl:(NSString *)url;
- (int)managerSetLiveTranscoding:(HDSLiveTranscoding *_Nullable)transcoding;

@end


#pragma mark ------
#pragma mark -- 直播监听事件

@protocol HDSStreamCallBackProtocol <NSObject>
/**初始化成功*/
- (void)onInitSuccess;
   /**初始化失败*/
- (void)onInitFailure:(NSString *)errCode;

/**加入成功*/
- (void)onJoinChannelSuccess;
/**加入失败*/
- (void)onJoinFailure:(NSString *)errorMsg;

/**离开频道
 *participantId不为空表示需要调用接口执行leave
 */
- (void)onLeaveChannel:(NSString *)participantId;

/**离开失败*/
- (void)onLeaveFailure:(NSString *)errorMsg;

/**推流状态*/
- (void)onPublishSuccess;

  /**推流失败*/
- (void)onPublishFailure:(int)code message:(NSString *)errorMsg;

/**有用户加入*/
- (void)onUserJoined:(LiveStream *)stream;
/**用户掉线*/
- (void)onUserOffline:(LiveStream *)stream isLocal:(BOOL)isLocal;

//网络连接中断，且 SDK 无法在 10 秒内连接服务器回调
- (void)rtcEngineConnectionDidLost;
 /**token过期回调*/
- (void)rtcEngineTokenPrivilegeWillExpire:(NSString *_Nonnull)token;
 /**返回远程视频流的回调*/
- (void)rtcEngineFirstRemoteVideoFrameOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed;

- (void)hds_onLiveEvent:(CCLiveEvent)event info:(NSDictionary<NSString *,NSString *> *)info;

/**黑流回调*/
-(void)onStreamStats:(NSString *)streamId info:(NSMutableDictionary *)info;


@end


NS_ASSUME_NONNULL_END
