[TOC]

#  排麦组件

聊天组件的核心类是CCBarleyManager;
```objc
//在工程需要的地方引入头文件
#import <CCBarleyLibrary/CCBarleyLibrary.h>

//1、类的实例化
+ (instancetype)sharedBarley;

//2、与BaseSDK建立联系
- (void)addBasicClient:(CCStreamerBasic *)basic;
```

# 1. 排麦模式

## 1.1 举手连麦

### 1.1.1 学生可举手申请连麦,需老师确认才可连麦

### 1.1.2 老师可以邀请学生连麦,需学生同意才可连麦

## 1.2 自由连麦

### 1.2.1 学生可自由连麦,无需老师确认

## 1.3 自动连麦

### 1.3.1 学生进入房间后自动连麦

# 2. 排麦事件

## 2.0 请求连麦

点击自由连麦、举手，以及自动连麦都必须要调用该接口

应用模式：举手连麦，自由连麦，自动连麦。

```objc
/*!
 @method
 @abstract 开始连麦(改为排麦中)
 @return 操作结果
 */
- (BOOL)handsUp:(CCComletionBlock)completion;
```


## 2.1 同意学生举手连麦

举手状态由互动者端发起，通知老师端，老师端可以同意或者不同意。

应用模式：举手连麦，自由连麦，自动连麦。

```objc
/*!
 @method
 @abstract 同意举手学生连麦
 @param userID 学生ID
 @param completion 结果
 @return 操作结果
 */
- (BOOL)certainHandup:(NSString *)userID completion:(CCComletionBlock)completion;

```


## 2.2 取消连麦

点击自由连麦、举手，以及自动连麦都必须要调用该接口

应用模式：举手连麦，自由连麦，自动连麦。

```objc
/*!
 @method
 @abstract 取消排麦
 @return 操作结果
 */
- (BOOL)handsUpCancel:(CCComletionBlock)completion;
```

## 2.3 主动下麦

点击自由连麦、举手，以及自动连麦都必须要调用该接口

应用模式：举手连麦，自由连麦，自动连麦。

```objc
/*!
 @method
 @abstract 结束连麦
 @return 操作结果
 */
- (BOOL)handsDown:(CCComletionBlock)completion;
```


## 2.4 邀请学生上麦

老师端发送邀请，接收端是互动者。

应用模式：举手连麦

```objc
/*!
 @method
 @abstract 老师邀请没有举手学生连麦(只对老师有效)
 @param userID 学生ID
 @return 操作结果
 */
- (BOOL)inviteUserSpeak:(NSString *)userID completion:(CCComletionBlock)completion;
```


## 2.5 取消邀请

取消邀请由老师端发起

应用模式：举手连麦，自由连麦，自动连麦。

```objc
/*!
 @method
 @abstract 老师取消对学生的上麦邀请
 @param userID 学生ID
 @param completion 结果
 @return 操作结果
 */
- (BOOL)cancleInviteUserSpeak:(NSString *)userID completion:(CCComletionBlock)completion;
```


## 2.6 接受老师邀请

学生端接受老师的上麦邀请，同意上麦。

应用模式：举手连麦

```objc
/*!
 @method
 @abstract 同意老师的上麦邀请
 @param completion 结果
 @return 操作结果
 */
- (BOOL)acceptTeacherInvite:(CCComletionBlock)completion;
```


## 2.7 拒绝老师连麦邀请

拒绝老师连麦邀请由学生端发起

应用模式：举手连麦，自由连麦，自动连麦。

```objc
/*!
 @method
 @abstract 拒绝老师的连麦邀请
 @param completion 结果
 @return 操作结果
 */
- (BOOL)refuseTeacherInvite:(CCComletionBlock)completion;
```


## 2.8 上麦更新

上麦更新是在两种情况下执行

​	1.推流成功之后为更新自己上麦状态，通知其他人订阅，需调用。

​	2.学生不能创建本地流或者推流失败，需将其麦序让出。

应用模式：举手连麦，自由连麦，自动连麦。

```objc
/*!
 @method
 @abstract 更新连麦状态
 @param userID 用户id
 @param roomID 房间id
 @param result 推流结果
 @param streamID 流id
 @param completion 回调block
 @return 操作结果
 */
- (BOOL)updateUserState:(NSString *)userID roomID:(NSString *)roomID publishResult:(BOOL)result streamID:(NSString *)streamID completion:(CCComletionBlock)completion;
```

## 2.9 学生举手

举手状态由互动者端发起，通知老师端，老师端可以同意或者不同意。

应用模式：举手连麦，自由连麦，自动连麦。

```objc
/*!
 @method
 @abstract 学生举手
 @return 状态
 */
- (BOOL)handup;
```


## 2.10 学生取消举手

举手状态由互动者端发起，通知老师端，老师端可以同意或者不同意。

应用模式：举手连麦，自由连麦，自动连麦。

```objc
/*!
 @method
 @abstract 学生取消举手
 @return 状态
 */
- (BOOL)cancleHandup;
```


## 2.11 踢人下麦

老师端发起踢人下麦

应用模式：举手连麦，自由连麦，自动连麦。

```objc
/*!
 @method
 @abstract 将连麦者踢下麦
 @param userID 连麦者userID
 
 @return 操作结果
 */
- (BOOL)kickUserFromSpeak:(NSString *)userID completion:(CCComletionBlock)completion;

```


## 2.12 设置连麦模式（可设置举手连麦，自由连麦，自动连麦，仅只有老师端）

老师端设置连麦模式

应用模式：举手连麦，自由连麦，自动连麦。

```objc
/*!
 @method
 @abstract 切换连麦模式
 @param type 模式
 @return 操作结果
 */
- (BOOL)setSpeakMode:(CCClassType)type completion:(CCComletionBlock)completion;

```

### 2.13 全体下麦(老师)
老师端调用全体下麦

```objc
/**
 @method
 @abstract 切换房间上麦状态(全部踢下麦)
 
 @param completion 回调
 @return 操作结果
 */
- (BOOL)changeRoomAllKickDown:(CCComletionBlock)completion;

```

# 3. 排麦通知事件

	下面所有的场景都以demo为例，如场景：CCPlayViewController控制器，具体可参考demo实现；

## 3.1 监听流服务事件

监听函数根据 3.2 监听事件自己定义；

## 3.2 学生排麦状态通知（上麦和下麦的回调通知）
在需要的控制器使用时添加监听事件
```objc
-(void)addObserver
{   
	//添加排麦房间状态监听
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveSocketEvent object:nil];
    //这块监听是监听上麦状态事件，逻辑可以根据需要设置
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startPublish) name:CCNotiNeedStartPublish object:nil];
    //这块监听是监听下麦状态事件，逻辑可以根据需要设置
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPublish) name:CCNotiNeedStopPublish object:nil];
    //用户需要退出通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needLogout) name:CCNotiNeedLoginOut object:nil];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SDKNeedsubStream:) name:CCNotiNeedSubscriStream object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SDKNeedUnsubStream:) name:CCNotiNeedUnSubcriStream object:nil];
    

}
  'startPublish'、'stopPublish'、'needLogout' - '监听事件请参考demo实现'
  'receiveSocketEvent:' - '下面会讲述'

```

## 3.3 移除监听
在控制器生命周期结束或不展现时移除监听；
```objc
-(void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
```

## 3.3 监听排麦其它相关事件
这里主要监听房间状态及交互事件

```objc
- (void)receiveSocketEvent:(NSNotification *)noti
{
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    id value = noti.userInfo[@"value"];
  
    if (event == CCSocketEvent_LianmaiStateUpdate)
    {
        //连麦状态变化
    }
    else if (event == CCSocketEvent_KickFromRoom)
    {
      //被踢出房间
    }
    else if (event == CCSocketEvent_LianmaiModeChanged)
    {
        //连麦模式变化
    }
    else if (event == CCSocketEvent_ReciveLianmaiInvite)
    {
        //在举手连麦模式中收到老师的连麦邀请
        //这块监听是监听邀请状态事件，逻辑可以根据需要设置
    }
    else if (event == CCSocketEvent_ReciveCancleLianmaiInvite)
    {
        //老师取消了连麦邀请
        //这块监听是监听取消邀请状态事件，逻辑可以根据需要设置
    }
    else if (event == CCSocketEvent_HandupStateChanged)
    {
        //收到举手状态改变
    }
    else if(event == CCSocketEvent_UserListUpdate)
    {
      //在线列表
    }
}
```

