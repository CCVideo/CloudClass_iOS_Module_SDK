[TOC]
## 1.概述
CC基础版SDK 是一个适用于iOS平台的云课堂SDK，使用此SDK可以与CC视频云服务进行对接，在iOS端使用CC视频的云课堂功能。

### 1.1 功能特性
| 功能        | 描述                       | 备注   |
| :-------- | :----------------------- | :--- |
| 推流        | 支持推流到服务器                 |      |
| 拉流        | 支持从服务器订阅流                |      |
| 前后摄像头切换   | 支持手机前后摄像头切换              |      |
| 后台播放      | 支持直播退到后台只播放音频            |      |
| 支持https协议 | 支持接口https请求              |      |

### 1.2 阅读对象
本文档为技术文档，需要阅读者：

* 具备基本的iOS开发能

* 准备接入CC视频的云课堂SDK相关功能

### 1.3 SDK架构
* 支持的CPU架构有armv7,arm64

* 支持的最低系统版本iOS9

* 模拟器支持：ipad air及以上版本，iphone 5s及以上版本模拟器；


## 2.开发准备

开发所需相关账号请咨询CC视频客户人员提供；

### 2.1 开发环境
* Xcode : iOS 开发IDE

### 2.2 Xcode配置
```
1. Build Settings   ->    Build Options  ->   Enable Bitcode   ->		NO
```

```
2. Build Settings -> Always Enbed Swift Standar Libraries ->YES
```

```
3. 工程加入动态库 CCClassRoomBasic.framework
```

```
4. 添加需要的系统库:
 libz.thd、
 libstdc++.thd、
 libicucore.thd、
 AudioToolbox.framework, 
 VideoToolBox.framework, 
 Accelerate.framework, 
 SystemConfiguration.framework, 
 libc++.tbd, libresolv.tbd, 
 CoreMedia.framework, 
 CoreTelephony.framework, 
 AVFoundation.framework, 
 CoreML.framework;

```

```
5. General->Embedded Binaries中添加动态库 CCClassRoomBasic.framework
```

```
6. Build Settings   ->   Other Linker Flags 添加-ObjC
```

```
7. Capabilities -> Background Modes -> Audio，AirPlay，And Picture in Picture
```

```
8. Info.plist 增加Privacy - Microphone Usage Description、Privacy - Photo Library Usage Description、Privacy - Camera Usage Description、Privacy - Calendars Usage Description
```

## 3.快速集成

注：快速集成主要提供的是推流和拉流(核心功能)。
基本的直播流程可参考Demo的 loginAction 功能函数；


首先，下载最新版本的组件化基础版SDK: [CloudClass_iOS_Module_SDK](https://github.com/CCVideo/CloudClass_iOS_Module_SDK)

下载WebRTC库[WebRTC下载](http://liveclass.csslcloud.net/SDK/HDSRTC_4.2.zip)集成

### 3.1 导入framework
| 名称                         | 描述       |
| :------------------------- | :------- |
| CCClassRoomBasic.framework | 云课堂业务SDK |
| CCBarleyLibrary.framework  | 云课堂业务SDK |
| CCChatLibrary.framework    | 云课堂业务SDK |
| CCDocLibrary.framework     | 云课堂业务SDK |
| CCFuncTool.framework       | 云课堂业务SDK |
| WebRTC.framework           | 云课堂业务SDK |
| DocUI.bundle               | 云课堂资源库   |



### 3.2 framework添加Embedded Binaries
由于framework是动态库需要将
CCClassRoomBasic.framework、
CCBarleyLibrary.framework、
CCChatLibrary.framework、
CCDocLibrary.framework 、
CCFuncTool.framework、
WebRTC.framework 
添加到Embedded Binaries

### 3.3 配置依赖系统库

工程需要下列系统库:
libz.thd、
libstdc++.thd、
libicucore.thd、
AudioToolbox.framework, 
VideoToolBox.framework, 
Accelerate.framework, 
SystemConfiguration.framework, 
libc++.tbd, 
libresolv.tbd, 
CoreMedia.framework,
CoreTelephony.framework, 
AVFoundation.framework, 
CoreML.framework;

### 3.4 创建SDK实例

#### 3.4.1 流服务组件初始化
在需要使用SDK的文件引入头文件

```objc
import <CCClassRoomBasic/CCClassRoomBasic.h>
```

创建SDK实例：
```objc
- (void)createBasic
{
 	  CCEncodeConfig *config = [[CCEncodeConfig alloc] init];
    config.reslution = CCResolution_LOW;
    
    self.streamerBasic = [CCStreamerBasic sharedStreamer];
    [self.streamerBasic addObserver:self];
}
```
#### 3.4.2 无排麦组件流监听处理

系统代理回调

```objc
//视频流add回调
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#pragma mark - 流
- (void)onServerDisconnected
{

}

- (void)onStreamAdded:(CCStream*)stream
{
    if ([stream.userID isEqualToString:self.stremer.userID])
    {
        //自己的流不订阅
        self.localStream = stream;
        return;
    }
    if (stream.type == CCStreamType_Mixed)
    {
        self.mixedStream = stream;
    }
  	//订阅视频流
    [self autoSub:stream];
}

- (void)onStreamRemoved:(CCStream*)stream
{
    if ([stream.userID isEqualToString:self.stremer.userID])
    {
        //自己的流没有订阅
        return;
    }
    [self autoUnSub:stream];
}

- (void)onStreamError:(NSError *)error forStream:(CCStream *)stream
{
    CCLog(@"%s__%d__%@__%@", __func__, __LINE__, error, stream.streamID);
}

- (void)autoSub:(CCStream *)stream
{
	WS(ws);
  [self.stremer subcribeWithStream:stream qualityLevel:0 completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

//解码完成，视图渲染在该函数渲染
- (void)onStreamFrameDecoded:(CCStream *)stream
{
	//渲染后的视图
    CCStreamView *view = [[CCStreamView alloc] initWithStream:stream];;

}
```
#### 3.4.3 依靠排麦组件流监听处理
1、添加事件监听
```objc
-(void)addObserver
{
//房间事件通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveSocketEvent object:nil];
    
//需要开始推流通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publish) name:CCNotiNeedStartPublish object:nil];
//停止推流通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPublish) name:CCNotiNeedStopPublish object:nil];
    
//流可以订阅通知 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SDKNeedsubStream:) name:CCNotiNeedSubscriStream object:nil];
//流需要取消订阅通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SDKNeedUnsubStream:) name:CCNotiNeedUnSubcriStream object:nil];   
}

- (void)SDKNeedsubStream:(NSNotification *)notify
{
  NSDictionary *dicInfo = notify.userInfo;
   
   CCStream *stream = dicInfo[@"stream"];
   if ([stream.userID isEqualToString:self.stremer.userID])
   {
       //自己的流不订阅
       self.localStream = stream;
       return;
   }
   
   if (stream.type == CCStreamType_Mixed)
   {
       self.mixedStream = stream;
       return;
   }
   
   dispatch_async(dispatch_get_global_queue(0, 0), ^{
       [self autoSub:stream];
   });   
}
//订阅
- (void)autoSub:(CCStream *)stream
{
    [self.stremer subcribeWithStream:stream completion:^(BOOL result, NSError *error, id info) {
        [self cc_updateAudioSession];
        if (result){


        }
        else
        {

        }
    }];
}
//渲染
- (void)onStreamFrameDecoded:(CCStream *)stream
{
    //主线程更新
    dispatch_async(dispatch_get_main_queue(), ^{
   	 CCStreamView *view = [[CCStreamView alloc] initWithStream:stream];;
    });
}

```
#### 3.4.4 流渲染函数

```objc
- (void)onStreamFrameDecoded:(CCStream *)stream
{    
    CCStreamView *view = [[CCStreamView alloc] initWithStream:stream];;
}
```


### 3.5 加入直播间和直播间开始结束的接口
加入直播间的接口
```objc
    CCEncodeConfig *config = [[CCEncodeConfig alloc] init];
    config.reslution = CCResolution_LOW;
    //具体参见demo
    NSString *authSessionID = self.info[@"data"][@"sessionid"];
    NSString *user_id = self.info[@"data"][@"userid"];
    self.stremer = [CCStreamerBasic sharedStreamer];
    self.stremer.videoMode = CCVideoPortrait;
    [self.stremer addObserver:self];
    [self.stremer joinWithAccountID:self.viewerId sessionID:authSessionID config:config areaCode:nil events:@[@"connect",                     @"disconnect",@"reconnecting",@"reconnect_failed",@"reconnect"] completion:^(BOOL result, NSError *error, id info) {
       
       
    }];
    
```
开始直播
```objc
 [weakSelf.stremer startLive:^(BOOL result, NSError *error, id info) {
                        if (result)
                        {
                            CCLog(@"%s__%d", __func__, __LINE__);
                        }
                        else
                        {
                            [weakSelf showError:error];
                        }
                    }];

```

结束直播
```objc
- (void)stopLive
{
    __weak typeof(self) weakSelf = self;
    [self.stremer stopLive:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}
```

### 3.6 推流相关调用
#### 3.6.1 创建本地流
```objc
#pragma mark -- 创建本地流
/*!
 @method
 @abstract 创建本地流
 @param createVideo 流是否创建视频
 @param front 设备相机
 */
- (void)createLocalStream:(BOOL)createVideo cameraFront:(BOOL)front;

```
#### 3.6.2 开启本地流预览
```objc
#pragma mark - 开启预览
/*!
 @method (1000)
 @abstract 开始预览
 @discussion 开启摄像头开启预览，在推流开始之前开启
 @param completion 回调
 */
- (void)startPreview:(CCComletionBlock)completion;

```
#### 3.6.3 关闭本地流预览
```objc
#pragma mark - 停止预览
/*!
 @method
 @abstract 停止预览(login out 包含该操作)
 @return 操作结果
 */
- (BOOL)stopPreview:(CCComletionBlock)completion;

```
#### 3.6.4 推流
```objc
- (void)publish
{
    __weak typeof(self) weakSelf = self;
    [self.stremer publish:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}
```
#### 3.6.5 结束推流
```objc
- (void)unpublish
{
    __weak typeof(self) weakSelf = self;
    [self.stremer unPublish:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            CCLog(@"%s__%d", __func__, __LINE__);
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

```


### 3.7 拉流相关掉用
#### 3.7.1 订阅流
```objc
- (void)autoSub:(CCStream *)stream
{
    __weak typeof(self) weakSelf = self;
    [self.stremer subcribeWithStream:stream qualityLevel:0 completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
				//拉流成功
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

```
#### 3.7.2 取消订阅流
```objc
- (void)autoUnSub:(CCStream *)stream
{
    __weak typeof(self) weakSelf = self;
    [self.stremer unsubscribeWithStream:stream completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            [weakSelf.streamView removeStreamView:info];
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

```

### 3.8 获取城市节点列表

```objc
/*!
 @method
 @abstract 获取节点列表
 @param accountId 用户账号ID
 @param completion 回调
 @return 操作结果
 */
- (BOOL)getRoomServerWithAccountID:(NSString *)accountId completion:(CCComletionBlock)completion;
```

### 3.9 流状态监听
#### 3.9.1 流状态监听API及实例

1、开启状态监听
```objc
/**
 * @abstract 流状态检测监听事件
 * @param completion 回调
 */
- (BOOL)setListenOnStreamStatus:(CCComletionBlock)completion;
```

```objc
//实例说明
[self.stremer setListenOnStreamStatus:^(BOOL result, NSError *error, id info) {
   NSDictionary *dicInfo = (NSDictionary *)info;
   NSString *action = info[@"action"];
   NSLog(@"listen_on_streame_info-------:%@",info);

}];

```

2、取消状态监听
```objc
/**
 * @abstract 流检测监听取消
 */
- (void)cancelListenStreamStatus;
```

```objc
//实例说明
[self.stremer cancelListenStreamStatus];
```
#### 3.9.2 流状态监听-数据返回说明
```objc
//1、流数据返回数据格式
{
    action = streamInfo;  //标记该条信息为：流信息
    bandWidth = 0;			//标记带宽数据：推流有效
    delay = 93;				//订阅流延时
    status = 1001;			//订阅流状态码
    stream = "<CCStream: 0x1c82624c0>"; //检测的流对象
    type = 1;             //流类型：  1 订阅流 0 推流
    isback = 0; 				//设备是否在后台 0 否 1 是
    streamException = 1； //1:推流端异常。2:订阅端异常 （如果流异常则会有该字段）
}
//2、网络状态返回数据格式
{
    action = netStatus; //标记该条信息为：网络状态统计
    delay = 93;         //订阅流延时
    netState = "93.000000";  //网络延时
    packetLost = "0.000000"; //丢包率
}
//3、流状态 status 说明
status：1001 开始检测 | 1002 检测中 | 1003 黑流，无视频数据
```

#### 3.9.3 流状态监听-数据实例
1、推流数据返回
```objc

2019-06-27 10:45:21.505391+0800 CCClassRoom[12236:4353539] listen_on_streame_info-------:{
    action = netStatus;
    delay = 71;
    netState = "368.029694";
    packetLost = "0.019802";
}
2019-06-27 10:45:23.511954+0800 CCClassRoom[12236:4352790] listen_on_streame_info-------:{
    action = streamInfo;
    bandWidth = 200;
    delay = 0;
    status = 1001;
    stream = "<CCStream: 0x1cc27dbc0>";
    type = 0;
}
```
2、订阅流数据返回
```objc
2019-06-27 10:43:31.121973+0800 CCClassRoom[12236:4352790] listen_on_streame_info-------:{
    action = streamInfo;  //标记该条信息为：流信息
    bandWidth = 0;			//标记带宽数据：推流有效
    delay = 93;				//订阅流延时
    status = 1001;			//订阅流状态码
    stream = "<CCStream: 0x1c82624c0>"; //检测的流对象
    type = 1;             //流类型：  1 订阅流 0 推流
}
2019-06-27 10:43:31.122268+0800 CCClassRoom[12236:4352521] listen_on_streame_info-------:{
    action = netStatus; //标记该条信息为：网络状态统计
    delay = 93;         //订阅流延时
    netState = "93.000000";  //网络延时
    packetLost = "0.000000"; //丢包率
}
```
#### 3.9.4 流状态监听-流异常处理
1、推流异常 < type == 0>
```objc
	判断返回数据的 ‘isback’ 数据返回值：
	1、 isback = 1 //app在后台			不做任何处理；
	
	2、 isback = 0 //app在前台

		接下来判断 status 数据（判断流异常原因）：
		2.1 status = 1003 
			2.1.1 可以切到音频
			2.1.2 可以断开重推

```
2、订阅流异常 < type == 1>

```objc
	1、status = 1003
		接下来判断 streamException 数据（判断流异常原因）：
		1.1 streamException = 1 推流端异常，本地不做处理；
		1.2 streamException = 2 
			1.2.1 订阅端异常，取消订阅，再次订阅；
			1.2.2 可以尝试切到音频
```




### 3.10 麦克风声音监听
1、开启mic声音监听

```objc
/**
 * @abstract 麦克风音量监听事件
 * @param completion 回调
 */
- (BOOL)setListenOnMicVoice:(CCComletionBlock)completion;
```
2、取消声音监听

```objc
/**
 * @abstract 本地音量监听取消
 */
- (void)cancelListenMicVoice;
```

## 4.功能使用
### 4.1 预览
预览是将初始化相机的流渲染出来：
```objc
- (void)startPreview:(CCComletionBlock)completion;
```

### 4.2 开始直播
点击开始直播，成功以后，进行推流和拉流操作：
* 开始直播方法
```objc
- (BOOL)startLive:(CCComletionBlock)completion;
```
### 4.3 结束直播
结束当前直播：
* 结束直播方法
```objc
- (BOOL)stopLive:(CCComletionBlock)completion;
```
### 4.4 推流/取消推流

推本地相机的流到服务器：
* 推流的方法
```objc
- (BOOL)publish:(CCComletionBlock)completion;
```

取消推相机本地流到服务器：
* 取消推流的方法
```objc
- (BOOL)unPublish:(CCComletionBlock)completion;
```
### 4.5 拉流/取消拉流

从服务端拉流：
* 拉流方法
```objc
- (BOOL)subcribeWithStream:(CCStream *)stream qualityLevel:(int)level completion:(CCComletionBlock)completion;
```
取消从服务端拉流：
* 取消拉流方法
```objc
- (BOOL)unsubscribeWithStream:(CCStream *)stream completion:(CCComletionBlock)completion;

视图渲染函数：
//解码完成进行流视图渲染
- (void)onStreamFrameDecoded:(CCStream *)stream;

```
### 4.6 流信息监听

1、注册监听
```objc
/**
 * @abstract 流状态检测监听事件
 * @param completion 回调
 */
- (BOOL)setListenOnStreamStatus:(CCComletionBlock)completion;
```

2、取消监听

```objc
/**
 * @abstract 流检测监听取消
 */
- (void)cancelListenStreamStatus;
```

### 4.7 麦克风音量监听

1、开启检测

```objc
/**
 * @abstract 麦克风音量监听事件
 * @param completion 回调
 */
- (BOOL)setListenOnMicVoice:(CCComletionBlock)completion;

```

2、取消检测

```objc
/**
 * @abstract 本地音量监听取消
 */
- (void)cancelListenMicVoice;

```

### 4.8 开启视频/关闭视频

* 开启关闭视频方法

```objc
/*!
 @method
 @abstract 设置视频状态(开始直播之后生效)
 @param opened 视频状态
 @param userID 学生ID(为空表示操作自己的视频)
 
 @return 操作结果
 */
- (BOOL)setVideoOpened:(BOOL)opened userID:(NSString *)userID;
```
### 4.9 开启音频/关闭音频

* 开启关闭音频方法

```objc
/*!
 @method
 @abstract 设置音频状态(开始直播之后才生效)
 @param opened 音频状态
 @param userID 学生ID(为空表示操作自己的音频)
 
 @return 操作结果
 */
- (BOOL)setAudioOpened:(BOOL)opened userID:(NSString *)userID;
```

### 4.10 被动监听事件

事件监听，建议在初始化sdk后做监听

#### 4.10.1 用户加入房间、退出房间通知
添加监听事件，具体参考集成示例工程；
```objc
- (void)receiveSocketEvent:(NSNotification *)noti
{
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    id value = noti.userInfo[@"value"];
    
    if(event == CCSocketEvent_UserJoin)
    {
        NSString *uname = value[@"name"];
        NSString *msg = [NSString stringWithFormat:@"<%@> 加入房间!",uname];
        [self showMessage:msg];
    }
    else if(event == CCSocketEvent_UserExit)
    {
        NSString *uname = value[@"name"];
        NSString *msg = [NSString stringWithFormat:@"<%@> 离开房间!",uname];
        [self showMessage:msg];
    }
}
```

#### 4.10.2 学员举手通知(举手连麦模式)
添加监听事件，具体参考集成示例工程；
```objc
- (void)receiveSocketEvent:(NSNotification *)noti
{
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    id value = noti.userInfo[@"value"];
    NSLog(@"%s__%@__%@", __func__, noti.name, @(event));
    
    if(event == CCSocketEvent_UserHandUp)
    {
        NSString *name = value[@"name"];
        NSString *str = [NSString stringWithFormat:@"<%@> 举手了！",name];
        [self showMessage:str];
    }
}
```

#### 4.10.3 用户自定义消息发送
添加监听事件，具体参考集成示例工程；
```objc
- (void)receiveSocketEvent:(NSNotification *)noti
{
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    id value = noti.userInfo[@"value"];
    NSLog(@"%s__%@__%@", __func__, noti.name, @(event));
    
    if(event == CCSocketEvent_PublishMessage)
    {
        NSString *val = value[@"value"];
        NSString *smessage = [NSString stringWithFormat:@"收到消息:%@",val];
    }
}
```

### 4.11 单条流音视频处理（是否接收远程流相关信息）

```objc
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
```

### 4.12 流服务重连
当出现推拉流异常，可以尝试调用该API进行流的恢复；
```objc
#pragma mark - 流服务器重连
/*!
 @method
 @abstract 流服务器重连
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)streamServerReConnect:(CCComletionBlock)completion;
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












