iOS快速接入文档


[TOC]
# iOS快速集成对接说明文档

## 1.概述
提供云课堂基础SDK功能，包括推流，拉流，排麦组件，聊天以及白板组件。为用户提供快速，简便的方法开展自己的实时互动课堂。

### 1.1 功能特性
ios端SDK目前支持了音视频SDK、白板插件、聊天插件以及排麦插件；

#### 1.1.1 音视频SDK功能
|           |                          |      |
| --------- | ------------------------ | ---- |
| 功能特性      | 描述                       | 备注   |
| 推流        | 支持推流到服务器                 |      |
| 拉流        | 支持从服务器订阅流                |      |
| 获取流状态     | 支持获取流的状态(发报数、收报数、丢包数、延时) |      |
| 前后摄像头切换   | 支持手机前后摄像头切换              |      |
| 后台播放      | 支持直播退到后台只播放音频            |      |
| 支持https协议 | 支持接口https请求              |      |

#### 1.1.2 白板插件功能

| |  |  |
| --- | --- | --- |
| 功能特性 | 描述 | 备注 |
| 文档翻页 |支持接收服务端的文档翻页数据|
| PPT动画  |支持接收服务器的PPT动画数据|
| 画笔功能  |支持画笔、清除、撤销、历史数据|
| 授权标注功能  |学生被授权，支持画笔功能|
| 设为讲师功能  |学生被设为讲师，支持画笔、清除、翻页ppt|

#### 1.1.3 聊天插件功能
|         |                  |      |
| ------- | ---------------- | ---- |
| 功能特性    | 描述               | 备注   |
| 文本、表情发送 | 支持接收服务端的文本和表情数据  |      |
| 图片发送    | 支持接收服务器的图片数据     |      |
| 禁言      | 分为指定用户的禁言，以及全体禁言 |      |

#### 1.1.3 排麦插件功能
|      |                      |      |
| ---- | -------------------- | ---- |
| 功能特性 | 描述                   | 备注   |
| 自由连麦 | 互动者可自由连麦,无需老师确认      |      |
| 自动连麦 | 互动者进入房间后自动连麦         |      |
| 举手连麦 | 互动者可举手申请连麦,需老师确认才可连麦 |      |

### 1.2 阅读对象
本文档为技术文档，需要阅读者：

1. 具备基本的iOS开发能力 
2. 准备接入获得场景视频的音视频SDK相关功能

## 2.开发准备

### 2.1 开发环境

1. Xcode : iOS 开发IDE
2. 支持的CPU架构有armv7,arm64
3. 支持的最低系统版本iOS9
4. 模拟器支持：ipad air及以上版本，iphone 5s及以上版本模拟器；
5. 开发所需相关账号请咨询CC视频客户人员提供；

### 2.2 Xcode配置

```
1. Build Settings   ->    Build Options  ->   Enable Bitcode   ->		NO
```

```
2. Build Settings -> Always Enbed Swift Standar Libraries ->YES
```

```
3. 工程加入云课堂SDK相关动态库
```

```
4. 添加需要的系统库:VideoToolbox.framework、libstdc++.tbd、libicucore.tbd
```

```
5. General->Embedded Binaries中添加云课堂SDK相关动态库；
```

```
6. Build Settings   ->   Other Linker Flags 添加-ObjC
```

```
7. Capabilities -> Background Modes -> Audio，AirPlay，And Picture in Picture
```

```
8. Info.plist 增加Privacy - Microphone Usage Description、Privacy - Photo Library Usage Description、Privacy - Camera Usage Description
```

## 3.快速集成

注：快速集成主要提供的是推流和拉流的功能(核心功能)。白板、聊天以及排麦组件另有开发文档描述。

首先，下载最新版本的组件化基础版SDK: [云课堂iOS组件化SDK下载](https://doc.bokecc.com/class/developer/ios/documents/demo.html)


### 3.1 导入framework
| 名称                         | 描述          |
| :------------------------- | :---------- |
| CCClassRoomBasic.framework | 云课堂音视频核心SDK  |
| CCDocLibrary.framework     | 云课堂白板插件核心SDK |
| CCChatLibrary.framework    | 云课堂聊天插件核心SDK |
| CCBarleyLibrary.framework  | 云课堂排麦插件核心SDK |
| MQTTClient.framework         | 云课堂消息补发SDK |
| SocketRocket.framework      | 云课堂消息补发socket SDK |
| ZegoLiveRoom.framework     | 云课堂业务SDK |
| HDSSup.framework           | 云课堂业务SDK <可选>| 


### 3.2 framework添加Embedded Binaries

由于framework是动态库需要将
CCClassRoomBasic.framework、
CCDocLibrary.framework  、
CCChatLibrary.framework、
CCBarleyLibrary.framework、
MQTTClient.framework、
SocketRocket.framework、
ZegoLiveRoom.framework 、
HDSSup.framework <可选>
添加到Embedded Binaries；

### 3.3 配置依赖库

工程需要下列系统库:libz.thd、libstdc++.thd、libicucore.thd、VideoToolBox.framework

### 3.4 组件使用
组件使用是基于基础版SDK的；

#### 3.4.1 基础版SDK实例化


在需要使用SDK的文件引入头文件


```objc
//import <CCClassRoomBasic/CCClassRoomBasic.h>
//在@interface 添加CCStreamerBasic、CCRoom实例属性，方便后续调用；
@property(nonatomic,strong)CCRoom   *room;
@property(nonatomic,strong)CCStreamerBasic *streamer;

```

创建SDK实例：
```objc
- (CCStreamerBasic *)streamer
{
    if (!_streamer) {
        _streamer = [CCStreamerBasic sharedStreamer];
    }
    return _streamer;
}
- (CCRoom *)room
{
    return [self.streamer getRoomInfo];
}
```

#### 3.4.2 登录房间
（1）解析房间链接，丛云课堂后台获取
```
例如：http://cloudclass.csslcloud.net/index/talker/?roomid=587C97AC7426B69C9C33DC5901307461&userid=83F203DAC2468694
解析：
域名：http://cloudclass.csslcloud.net/index/ 
角色：talker（学生）/presenter(老师)/inspector(隐身者)/watcher（旁听者）
roomid：587C97AC7426B69C9C33DC5901307461
userid：83F203DAC2468694

```

（2） 获取session  
```
开发者通过自己的服务器获取sessionid；
```

（3）获得sessionid以后，再加入房间  

```
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
```

**注意**：现在才可以真正的使用其他组件


#### 3.4.3 音视频SDK组件快速接入

##### 3.4.3.1 开始直播与结束直播
老师角色需要处理这两个接口，之后才可以推拉流；学生角色不需要处理这两个接口。

1、开始预览
```objc
  [self.streamer startPreview:^(BOOL result, NSError *error, id info) {
            CCStreamView *view = info;
		//将该view添加到屏幕上
   }];

```
 
2、开始直播

```objc
	
    [self.streamer startLive:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [CCTool showError:error];
        }
    }];
    
```

3、停止预览

```objc
[self.streamer stopPreview:^(BOOL result, NSError *error, id info) {
   if (result)
   {
			//从父视图移除该预览view
   }
   else
   {
       [CCTool showError:error];
   }
}];
```


4、停止直播

```objc
    [self.streamer stopLive:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [CCTool showError:error];
        }
    }];
```
 
#### 3.4.4 判断是否开启直播
 
 (1)当第一次进入房间判断是否开启直播（主动获取）
```objc
      //获取直播状态
      CCLiveStatus liveStatus = self.room.live_status;
```
(2)进入房间后监听回调，判断房间开始或者结束（被动监听）
```
//1、注册监听事件
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveSocketEvent object:nil];

//2、解析监听事件

- (void)receiveSocketEvent:(NSNotification *)noti
{
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    id value = noti.userInfo[@"value"];
    NSLog(@"%s__%@__%@", __func__, noti.name, @(event));
 
    if(event == CCSocketEvent_PublishStart)
    {
        //直播开启
    }
    else if(event == CCSocketEvent_PublishEnd)
    {
			//直播结束
    }   
}
 
```

#### 3.4.5 订阅流、取消订阅流、推流、停止推流

##### 3.4.5.1 注册流监听事件

```objc
  //推流监听
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startPublish) name:CCNotiNeedStartPublish object:nil];
  //停止推流监听
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPublish) name:CCNotiNeedStopPublish object:nil];
  //需要订阅流监听
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AppNeedsubStream:) name:CCNotiNeedSubscriStream object:nil];
  //需要取消订阅流监听
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AppNeedUnsubStream:) name:CCNotiNeedUnSubcriStream object:nil];

```

##### 3.4.5.2 推流流程
整体流程可以参考demo

1、开启预览（推流时如果已经开启则不必在此开启）

```objc
  [self.streamer startPreview:^(BOOL result, NSError *error, id info) {
            CCStreamView *view = info;
		//将该view添加到屏幕上
		//可以开始推流
		
   }];
```

2、开始推流（推流前提：已经开启预览）
```objc
     [self.streamer publish:^(BOOL result, NSError *error, id info) {
       if (result)
       {
         //推流成功需要更新麦序
         //TODO
        }
       else
       {
           [CCTool showError:error];
       }
   }];
```

3、更新麦序（推流成功后需要更新麦序）
```objc
//推流成功，更新用户排麦状态
[self.ccBarelyManager updateUserState:weakSelf.room.user_id roomID:nil publishResult:YES streamID:weakSelf.localStreamID completion:^(BOOL result, NSError *error, id info) {

 }];

```

4、完整推流代码
```objc
- (void)startPublish
{
    WS(weakSelf);
    //申请连麦成功，开始推流
    [self com_startPreview:^(BOOL result, NSError *error, id info) {
        if (!result) {
            [CCTool showError:error];
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.streamView showStreamView:info];
        });
        [weakSelf.streamer publish:^(BOOL result, NSError *error, id info) {
            if (result)
            {
                weakSelf.localStreamID = weakSelf.streamer.localStreamID;
                NSLog(@"%s__%d", __func__, __LINE__);
                //推流成功，更新用户排麦状态
                [self.ccBarelyManager updateUserState:weakSelf.room.user_id roomID:nil publishResult:YES streamID:weakSelf.localStreamID completion:^(BOOL result, NSError *error, id info) {

                }];
            }
            else
            {
                [CCTool showError:error];
            }
        }];
    }];
}
```

##### 3.4.5.3 停止推流

```objc
- (void)stopPublish
{
    WS(weakSelf);
    [self.streamer unPublish:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            weakSelf.localStreamID = weakSelf.streamer.localStreamID;
            NSLog(@"%s__%d", __func__, __LINE__);
            //推流成功，更新用户排麦状态
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.streamView removeStreamView:info];
                });
        }
        else
        {
            [CCTool showError:error];
        }
    }];
}
```

##### 3.4.5.4 离开房间

```objc
- (void)leave
{    
	[self.streamer leave:^(BOOL result, NSError *error, id info) {
      [self.streamer clearData];
 	}];
 }
```


#### 3.4.4 文档组件实例化

在需要使用文档组件的文件引入头文件

```objc
#import <CCDocLibrary/CCDocLibrary.h>
在@interface CCDocVideoView 实例属性方便后续调用；
@property(nonatomic,strong)CCDocVideoView   *ccVideoView;

```

（1）创建SDK实例：

```objc
- (CCDocVideoView *)ccVideoView
{
    if (!_ccVideoView) {
        CGRect frame = CGRectMake(0, 0, 200, 100);
        _ccVideoView = [[CCDocVideoView alloc]initWithFrame:frame];
        [_ccVideoView addObserverNotify];
    }
    return _ccVideoView;
}
```

（2）将文档组件添加到设备上

```objc
	//view 添加展示
   [self.view addSubview:self.ccVideoView];
```

（3）将文档加载数据

```objc
	//数据渲染
   [self.ccVideoView startDocView];
```

#### 3.4.5 聊天组件实例化

在需要使用文档组件的文件引入头文件

```objc
#import <CCChatLibrary/CCChatLibrary.h>
在@interface CCChatManager实例属性方便后续调用；
@property(nonatomic,strong)CCChatManager    *ccChatManager;

```

（1）创建SDK实例：

```objc
- (CCChatManager *)ccChatManager
{
    if (!_ccChatManager) {
        _ccChatManager = [CCChatManager sharedChat];
    }
    return _ccChatManager;
}
```
（2） 接口调用
	具体参考聊天组件集成说明文档；

#### 3.4.6 排麦组件实例化

在需要使用文档组件的文件引入头文件

```objc
#import <CCBarleyLibrary/CCBarleyLibrary.h>
在@interface CCBarleyManager实例属性方便后续调用；
@property(nonatomic,strong)CCBarleyManager  *ccBarelyManager;

```

（1）创建SDK实例：

```objc
- (CCBarleyManager *)ccBarelyManager
{
    if (!_ccBarelyManager) {
        _ccBarelyManager = [CCBarleyManager sharedBarley];
    }
    return _ccBarelyManager;
}
```

（2） 接口调用
	具体参考聊天组件集成说明文档；
	
### 3.5 音视频、画板组件、聊天组件、排麦组件回调相关事件，请查阅具体相关文档



## 4 组件与基础版SDK建立关联
要使用文档、聊天、排麦组件需要配合基础版SDK使用，要建立关联，如下：

```objc
- (void)initBaseSDKComponent
{
    self.streamer = [CCStreamerBasic sharedStreamer];
    [self.streamer addObserver:self];
    
    //白板
    [self.streamer addObserver:self.ccVideoView];
    [self.ccVideoView addBasicClient:self.streamer];
    //聊天
    [self.streamer addObserver:self.ccChatManager];
    [self.ccChatManager addBasicClient:self.streamer];
    //排麦
    self.streamer.isUsePaiMai = YES;
    [self.streamer addObserver:self.ccBarelyManager];
    [self.ccBarelyManager addBasicClient:self.streamer];
}
```


## 5.API查询
Document目录打开index.html文件

## 6.Q&A
### 6.1 运行崩溃
```objc
dyld: Library not loaded: @rpath/CCClassRoomBasic.framework/CCClassRoomBasic
  Referenced from: /var/containers/Bundle/Application/E8CDE526-6F19-415B-9BA4-2380AB0A1FDE/CCClassRoom.app/CCClassRoom
  Reason: image not found
```
解决办法参考3.2


