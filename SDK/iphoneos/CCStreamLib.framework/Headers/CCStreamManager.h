//
//  CCStreamManager.h
//  CCStreamLib
//
//  Created by Chenfy on 2020/3/16.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDSStreamProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCStreamManager : NSObject<HDSStreamCallBackProtocol>
//代理
@property(nonatomic,weak)id <HDSStreamCallBackProtocol>delegate;

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

/**
* 停止/恢复接收指定视频流
*/
- (int)muteRemoteVideoStream:(LiveStream *)stream mute:(BOOL)mute;

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

NS_ASSUME_NONNULL_END
