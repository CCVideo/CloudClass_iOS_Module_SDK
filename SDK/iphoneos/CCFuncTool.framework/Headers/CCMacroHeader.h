//
//  CCMacroHeader.h
//  CCClassRoomBasic
//
//  Created by cc on 2018/12/3.
//  Copyright © 2018年 cc. All rights reserved.
//

#ifndef CCMacroHeader_h
#define CCMacroHeader_h

//角色定义
#define KKEY_CCRole_Teacher         @"presenter"
#define KKEY_CCRole_Student         @"talker"
#define KKEY_CCRole_Watcher         @"audience"
#define KKEY_CCRole_Inspector       @"inspector"
#define KKEY_CCRole_Assistant       @"assistant"

//网络检测
typedef void(^CCNetDomainBlcok)(BOOL result,float time ,NSString *domain);
/*!
 * @brief    流视图填充方式枚举
 */
typedef enum{
    /*!
     *  根据应用方向旋转
     */
    CCVideoChangeByInterface,
    /*!
     *  竖屏
     */
    CCVideoPortrait,
    /*!
     *  横屏
     */
    CCVideoLandscape,
}CCVideoOriMode;

//流状态
typedef NS_ENUM(NSInteger,CCBlaskStatus) {
    CCBlaskStatus_Init = 1000, //初始状态
    CCBlaskStatus_isOK, //流正常
    CCBlaskStatus_isLoading, //正在加载流
    CCBlaskStatus_isBlack //流异常（黑流）
};

//直播录制状态
typedef NS_ENUM(NSInteger,CCRecordType) {
    CCRecordType_Start, //正在录制
    CCRecordType_Pause, //暂停录制
    CCRecordType_Resume,//继续录制
    CCRecordType_End    //停止录制
};
//服务类型
typedef NS_ENUM(NSInteger,CCRoomType) {
    CCRoomType_Atlas,   //atlas
    CCRoomType_Atlas_1  //atlas_1
};
/**
 @brief 异步请求闭包回调
 
 @param result 结果
 @param error 错误信息
 @param info 回调数据
 */
typedef void(^CCComletionBlock)(BOOL result, NSError *error, id info);


/*!
 * @brief 相机对焦模式枚举
 * @constant CCFocusModeAuto 自动对焦
 * @constant CCFocusModeManual 手动对焦
 */
typedef enum{
    CCFocusModeAuto,
    CCFocusModeManual,
}CCFocusMode;
/*!
 * @brief    用户角色身份枚举
 * @constant CCRole_Teacher     教师端
 * @constant CCRole_Student     互动者
 * @constant CCRole_Watcher     观看者
 * @constant CCRole_Inspector   隐身者
 * @constant CCRole_Assistant   助教者
 * @constant CCRole_UnKnow      占位
 */
typedef enum{
    CCRole_Teacher,
    CCRole_Student,
    CCRole_Watcher,
    CCRole_Inspector,
    CCRole_Assistant,
    CCRole_UnKnow //占位
}CCRole;
/*!
 * @brief    skocket.io被动通知事件枚举
 * @constant CCSocketEvent_Chat 收到的聊天消息
 * @constant CCSocketEvent_UserListUpdate 在线列表
 * @constant CCSocketEvent_Announcement 公告
 * @constant CCSocketEvent_GagAll 全体禁言或者取消全体禁言
 * @constant CCSocketEvent_GagOne 禁言或者取消禁言(学生有效)
 * @constant CCSocketEvent_MediaModeUpdate 连麦音视频权限改变
 * @constant CCSocketEvent_PublishStart 开始推流
 * @constant CCSocketEvent_PublishEnd 推流结束,正在连麦的学生要停止连麦，停止订阅流
 * @constant CCSocketEvent_LianmaiStateUpdate 连麦状态变化
 * @constant CCSocketEvent_KickFromRoom 被踢出房间
 * @constant CCSocketEvent_UserCountUpdate 旁听人数
 * @constant CCSocketEvent_AudioStateChanged 改变音频状态
 * @constant CCSocketEvent_VideoStateChanged 改变视频状态
 * @constant CCSocketEvent_TeacherNamed 收到老师点名
 * @constant CCSocketEvent_TeacherNamedInfo 老师点名信息
 * @constant CCSocketEvent_StudentNamed 学生签到
 * @constant CCSocketEvent_LianmaiModeChanged 连麦模式变化
 * @constant CCSocketEvent_ReciveLianmaiInvite 在举手连麦模式中收到老师的连麦邀请
 * @constant CCSocketEvent_ReciveCancleLianmaiInvite 老师取消了连麦邀请
 * @constant CCSocketEvent_StreamRemoved 自己的流断开了
 * @constant CCSocketEvent_TemplateChanged 房间模板改变
 * @constant CCSocketEvent_MainStreamChanged 在跟随模式下老师切换主视频
 * @constant CCSocketEvent_MaxStreamsChanged 房间最大连麦人数变化
 * @constant CCSocketEvent_TeacherBitRateChanged 房间老师码率变化
 * @constant CCSocketEvent_StudentBitRateChanged 房间学生码率变化
 * @constant CCSocketEvent_DocDraw 文档画笔信息
 * @constant CCSocketEvent_DocPageChange 文档翻页
 * @constant CCSocketEvent_TimerStart 老师发起计时器
 * @constant CCSocketEvent_TimerEnd 老师结束计时器
 * @constant CCSocketEvent_ReciveVote 收到答题
 * @constant CCSocketEvent_ReciveStopVote 收到结束答题
 * @constant CCSocketEvent_ReciveDrawStateChanged 收到授权标注状态改变
 * @constant CCSocketEvent_HandupStateChanged 收到举手状态改变
 * @constant CCSocketEvent_SocketReconnecting socket重连中
 * @constant CCSocketEvent_SocketConnected socket连接成功
 * @constant CCSocketEvent_SocketReconnected socket重连成功
 * @constant CCSocketEvent_SocketConnectionClosed socket连接断开
 * @constant CCSocketEvent_SocketReconnectedFailed socket重连连接
 * @constant CCSocketEvent_RecivePublishError 上麦失败(老师拉学生上麦，而学生不具备上麦条件)
 * @constant CCSocketEvent_ReciveInterCutAudioOrVideo 插播音视频事件
 * @constant CCSocketEvent_ReciveDocAnimationChange 文档动画事件
 * @constant CCSocketEvent_ReciveAnssistantChange 设为讲师事件
 * @constant CCSocketEvent_ReciveStreamBigOrSmall web端老师双击放大
 * @constant CCSocketEvent_BrainstomSend 头脑风暴开始
 * @constant CCSocketEvent_BrainstomReply 头脑风暴回复
 * @constant CCSocketEvent_BrainstomEnd 头脑风暴结束
 * @constant CCSocketEvent_VoteSend 投票内容
 * @constant CCSocketEvent_VoteReply 投票回复
 * @constant CCSocketEvent_VoteEnd 投票结束
 * @constant CCSocketEvent_Flower  鲜花
 * @constant CCSocketEvent_Cup     奖杯
 * @constant CCSocketEvent_UserJoin 有用户加入房间
 * @constant CCSocketEvent_UserExit 有用户离开房间
 * @constant CCSocketEvent_PublishMessage 公聊消息
 * @constant CCSocketEvent_UserHandUp 用户举手
 * @constant CCSocketEvent_UserCustomUpdate 用户自定义状态更行
 * @constant CCSocketEvent_TalkerAudioUpdate  房间音频开关更新（学员订阅其他学员的流时：是否打开音频）
 * @constant CCSocketEvent_BroadcastMsg  用户通过API广播的消息

 */
typedef enum{
    CCSocketEvent_Chat,
    CCSocketEvent_UserListUpdate,
    CCSocketEvent_Announcement,
    CCSocketEvent_GagAll,
    CCSocketEvent_GagOne,
    CCSocketEvent_MediaModeUpdate,
    CCSocketEvent_PublishStart,
    CCSocketEvent_PublishEnd,
    CCSocketEvent_LianmaiStateUpdate,
    CCSocketEvent_KickFromRoom,
    CCSocketEvent_UserCountUpdate,
    CCSocketEvent_AudioStateChanged,
    CCSocketEvent_VideoStateChanged,
    CCSocketEvent_TeacherNamed,
    CCSocketEvent_TeacherNamedInfo,
    CCSocketEvent_StudentNamed,
    CCSocketEvent_LianmaiModeChanged,
    CCSocketEvent_ReciveLianmaiInvite,
    CCSocketEvent_ReciveCancleLianmaiInvite,
    CCSocketEvent_StreamRemoved,
    CCSocketEvent_TemplateChanged,
    CCSocketEvent_MainStreamChanged,
    CCSocketEvent_MaxStreamsChanged,
    CCSocketEvent_TeacherBitRateChanged,
    CCSocketEvent_StudentBitRateChanged,
    CCSocketEvent_DocDraw,
    CCSocketEvent_DocPageChange,
    CCSocketEvent_TimerStart,
    CCSocketEvent_TimerEnd,
    CCSocketEvent_ReciveVote,
    CCSocketEvent_ReciveVoteAns,
    CCSocketEvent_ReciveStopVote,
    CCSocketEvent_ReciveDrawStateChanged,
    CCSocketEvent_HandupStateChanged,
    CCSocketEvent_RotateLockedStateChanged,
    CCSocketEvent_SocketReconnecting,
    CCSocketEvent_SocketConnected,
    CCSocketEvent_SocketReconnected,
    CCSocketEvent_SocketConnectionClosed,
    CCSocketEvent_SocketReconnectedFailed,
    CCSocketEvent_RecivePublishError,
    CCSocketEvent_ReciveInterCutAudioOrVideo,
    CCSocketEvent_ReciveDocAnimationChange,
    CCSocketEvent_ReciveAnssistantChange,
    CCSocketEvent_ReciveStreamBigOrSmall,
    CCSocketEvent_BrainstomSend,
    CCSocketEvent_BrainstomReply,
    CCSocketEvent_BrainstomEnd,
    CCSocketEvent_VoteSend,
    CCSocketEvent_VoteReply,
    CCSocketEvent_VoteEnd,
    CCSocketEvent_Flower,
    CCSocketEvent_Cup,
    CCSocketEvent_UserJoin,
    CCSocketEvent_UserExit,
    CCSocketEvent_PublishMessage,
    CCSocketEvent_UserHandUp,
    CCSocketEvent_UserCustomUpdate,
    CCSocketEvent_TalkerAudioUpdate,
    CCSocketEvent_BroadcastMsg
    
}CCSocketEvent;
/*!
 * @brief    音视频模式枚举
 * @constant CCVideoMode_AudioAndVideo 连麦开放音视频
 * @constant CCVideoMode_Audio = 2 连麦只开放音频
 */
typedef enum{
    CCVideoMode_AudioAndVideo = 1,
    CCVideoMode_Audio = 2,
}CCVideoMode;
/*!
 * @brief    直播间状态枚举
 * @constant CCLiveStatus_Stop 未开始直播
 * @constant CCLiveStatus_Start 正在直播
 */
typedef enum{
    CCLiveStatus_Stop,
    CCLiveStatus_Start,
}CCLiveStatus;
/*!
 * @brief    连麦模式枚举
 * @constant CCClassType_Auto 自由连麦
 * @constant CCClassType_Named 举手连麦
 */
typedef enum {
    CCClassType_Rotate = 3,//自动连麦
    CCClassType_Auto = 2,//自由连麦
    CCClassType_Named = 1,//举手连麦
}CCClassType;
/*!
 * @brief    模板类型枚举
 * @constant CCRoomTemplateSpeak 主讲模式
 * @constant CCRoomTemplateSingle 主视角模式
 * @constant CCRoomTemplateTile 平铺模式
 * @constant CCRoomTemplateOneface 1V1
 * @constant CCRoomTemplateDoubleTeacher 双师
 */
typedef enum{
    CCRoomTemplateSpeak = 1,
    CCRoomTemplateSingle = 2,
    CCRoomTemplateTile = 4,
    CCRoomTemplateOneface = 8,
    CCRoomTemplateDoubleTeacher = 16,
}CCRoomTemplate;
/*!
 * @brief    上麦状态枚举
 * @constant CCUserMicStatus_None 初始状态
 * @constant CCUserMicStatus_Wait 排麦中
 * @constant CCUserMicStatus_Connecting 上麦
 * @constant CCUserMicStatus_Connected 连麦中
 * @constant CCUserMicStatus_Inviteing 邀请上麦中
 */
typedef enum{
    CCUserMicStatus_None,
    CCUserMicStatus_Wait,
    CCUserMicStatus_Connecting,
    CCUserMicStatus_Connected,
    CCUserMicStatus_Inviteing,
}CCUserMicStatus;
/*!
 * @brief    登录平台枚举
 * @constant CCUserPlatform_PC web端登录
 * @constant CCUserPlatform_Mobile 手机端登录
 */
typedef enum{
    CCUserPlatform_PC,
    CCUserPlatform_Mobile,
}CCUserPlatform;

/**
 * @brief  码率枚举
 
 - CCUserBitrate_1:
 */
typedef enum {
    CCUserBitrate_1 = 100,//100
    CCUserBitrate_2 = 200,//200
    CCUserBitrate_3 = 300,//300
    CCUserBitrate_4 = 500,//500
    CCUserBitrate_5 = 1000,//1000
    CCUserBitrate_6 = 2000,//2000
}CCUserBitrate;//码率

/**
 * @brief  轮播变更枚举
 
 */
typedef enum {
    CCRotateType_Open = 1,//开启轮播
    CCRotateType_Close = 0,//关闭轮播
    CCRotateType_Update = 2,//变更
}CCRotateType;//轮播
#endif /* CCMacroHeader_h */
