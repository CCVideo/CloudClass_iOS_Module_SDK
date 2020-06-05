iOS_base组件

[TOC]
## 1.概述
CC基础版SDK 是一个适用于iOS平台的云课堂SDK，使用此SDK可以与CC视频云服务进行对接，在iOS端使用CC视频的云课堂功能。

### 1.1 功能特性
| 功能        | 描述                       | 备注   |
| :-------- | :----------------------- | :--- |
| 推流        | 支持推流到服务器                 |      |
| 拉流        | 支持从服务器订阅流                |      |
| 获取流状态     | 支持获取流的状态(发报数、收报数、丢包数、延时) |      |
| 前后摄像头切换   | 支持手机前后摄像头切换              |      |
| 后台播放      | 支持直播退到后台只播放音频            |      |
| 支持https协议 | 支持接口https请求              |      |

### 1.2 阅读对象
本文档为技术文档，需要阅读者：

1. 具备基本的iOS开发能力
2. 准备接入CC视频的云课堂SDK相关功能

### 1.3 SDK架构

1. 支持的CPU架构有armv7,arm64
2. 支持的最低系统版本iOS9
3. 模拟器支持：ipad air及以上版本，iphone 5s及以上版本模拟器；

## 2.开发准备

开发所需相关账号请咨询CC视频客户人员提供；

### 2.1 开发环境
1. Xcode : iOS 开发IDE

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
5. General->Embedded Binaries中添加云课堂SDK相关动态库
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

注：快速集成主要提供的是推流和拉流(核心功能)。
基本的直播流程可参考Demo的相关功能函数；


首先，下载最新版本的组件化基础版SDK: [云课堂iOS组件化SDK下载](https://doc.bokecc.com/class/developer/ios/documents/demo.html)


### 3.1 导入framework
| 名称                         | 描述       |
| :------------------------- | :------- |
| CCClassRoomBasic.framework | 云课堂业务SDK |
| CCBarleyLibrary.framework  | 云课堂业务SDK |
| CCChatLibrary.framework    | 云课堂业务SDK |
| CCDocLibrary.framework     | 云课堂业务SDK |
| CCFuncTool.framework       | 云课堂业务SDK |
| ZegoLiveRoom.framework     | 云课堂业务SDK |
| HDSSup.framework           | 云课堂业务SDK <可选>|
| DocUI.bundle               | 云课堂资源库   |



### 3.2 framework添加Embedded Binaries
由于framework是动态库需要将
CCClassRoomBasic.framework、
CCBarleyLibrary.framework、
CCChatLibrary.framework、
CCDocLibrary.framework 、
CCFuncTool.framework、
HDSSup.framework <可选>、
ZegoLiveRoom.framework
添加到Embedded Binaries

### 3.3 配置依赖系统库

工程需要下列系统库:libz.thd、libstdc++.thd、libicucore.thd、VideoToolBox.framework

### 3.4 流事件监听
#### 3.4.1 工具类创建
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

```objc
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#pragma mark - 流
- (void)onServerDisconnected
{
    WS(ws);
    [self.streamerBasic leave:^(BOOL result, NSError *error, id info){
       dispatch_async(dispatch_get_main_queue(), ^{
				 //退出当前控制器
				 [ws.navigationController popViewControllerAnimated:NO];
		 });
    }];
}
```

#### 3.4.2 场景一 流事件监听（不使用排麦组件）
<font color=#FF0000 >这里需要实现 CCStreamerBasicDelegate 相关协议</font>

1、主要协议函数如下：
```objc
/** @brief Triggers when a stream is added. */
- (void)onStreamAdded:(CCStream*)stream;

/** @brief Triggers when a stream is removed. */
- (void)onStreamRemoved:(CCStream*)stream;

```

2、示例如下：
```objc
//监听流事件--有流加入房间
- (void)onStreamAdded:(CCStream*)stream
{
	//todo ，订阅相关流
}

//监听流事件--有流离开房间
- (void)onStreamRemoved:(CCStream*)stream
{
	//todo ，取消订阅相关流
}

//监听流事件--流有异常
- (void)onStreamError:(NSError *)error forStream:(CCStream *)stream
{
    CCLog(@"__%@__%@", error, stream.streamID);
}
```

#### 3.4.3 场景二 流事件监听（使用排麦组件）
<font color=#FF0000 >
1、这里需要实现 CCStreamerBasicDelegate 相关协议；
2、添加流事件监听；
</font>

1、协议函数如下：
```objc
//解码完成（在该函数内部进行视频渲染）
- (void)onStreamFrameDecoded:(CCStream *)stream;
```
2、添加流事件监听

```objc
//一、添加流事件监听
-(void)addObserver
{
//1、有流需要订阅监听
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SDKNeedsubStream:) name:CCNotiNeedSubscriStream object:nil];
//2、有流需要取消订阅监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SDKNeedUnsubStream:) name:CCNotiNeedUnSubcriStream object:nil];
}

//二、移除流事件监听
-(void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedSubscriStream object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedUnSubcriStream object:nil];
}
```


3、示例如下：

```objc

#pragma mark 拉流代理
//有流需要订阅
- (void)SDKNeedsubStream:(NSNotification *)notify
{
    NSDictionary *dicInfo = notify.userInfo;
    CCStream *stream = dicInfo[@"stream"];
    //todo ，订阅相关流
}
//有流需要取消订阅
- (void)SDKNeedUnsubStream:(NSNotification *)notify
{
    NSDictionary *dicInfo = notify.userInfo;
    CCStream *stream = dicInfo[@"stream"];
    //todo ，取消订阅相关流
}

//订阅流成功后，渲染视频流（异步回调）
- (void)onStreamFrameDecoded:(CCStream *)stream
{
    //主线程更新
    dispatch_async(dispatch_get_main_queue(), ^{
     	//将要展示的视频流
    	CCStreamView *view = [[CCStreamView alloc] initWithStream:stream];
    	//放到需要展示的地方
    });
}

```
#### 3.4.4 线路优化监听
线路优化监听需要实现 CCStreamerBasicDelegate 协议的几个函数，然后在应用层做相应的逻辑处理： 具体使用可参考demo；
1、开始线路优化

```objc
/*!
 @method
 @abstract 开始线路优化（1.移除预览；2.将麦克风/摄像头状态置为初始状态；）
 */
- (void)onStartRouteOptimization;

```

2、线路优化结束

```objc
/*!
 @method
 @abstract 线路优化结束
*/
- (void)onStopRouteOptimization;
```

3、线路优化异常 
   优化中遇到失败，需要退出直播间，重新进入；

```objc
/*!
 @method
 @abstract 线路优化异常
 */
- (void)switchPlatformError:(NSError *)error;
```

4、重新加载预览
   优化中需要重新加载预览，否则出现黑流等异常
   
```objc
/*!
 @method 重新加载预览
 @abstract 需要重新创建本地流，创建预览
*/
- (void)onReloadPreview;

```

5、学生端下麦
  	学生端优化过程中需要下麦

```objc
/*!
@method
@abstract 学生端下麦
*/
- (void)onStudentDownMai;

```

### 3.5 加入直播间和直播间开始结束的接口
加入直播间的接口
```objc
    CCEncodeConfig *config = [[CCEncodeConfig alloc] init];
    config.reslution = CCResolution_LOW;
    //具体参见demo
    NSString *authSessionID = self.info[@"data"][@"sessionid"];
    NSString *user_id = self.info[@"data"][@"userid"];
    [self.streamer joinWithAccountID:self.viewerId sessionID:authSessionID config:config areaCode:nil events:nil completion:^(BOOL result, NSError *error, id info) {
       
       
    }];
    
```
开始直播
```objc
 [weakSelf.streamer startLive:^(BOOL result, NSError *error, id info) {
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
    [self.streamer stopLive:^(BOOL result, NSError *error, id info) {
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
    [self.streamer publish:^(BOOL result, NSError *error, id info) {
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
    [self.streamer unPublish:^(BOOL result, NSError *error, id info) {
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
//1、订阅流
- (void)autoSub:(CCStream *)stream
{
    __weak typeof(self) weakSelf = self;
	 [self.streamer subcribeWithStream:stream completion:^(BOOL result, NSError *error, id info) {
	        if (result)
	        {
	            NSLog(@"sub success");
	        }
	        else
	        {
	            NSLog(@"sub fail");            
	        }
	    }];
}
//2、订阅流成功后，渲染视频流
//解码完成,加载视图
- (void)onStreamFrameDecoded:(CCStream *)stream
{
    //主线程更新
    dispatch_async(dispatch_get_main_queue(), ^{
     	//将要展示的视频流
    	CCStreamView *view = [[CCStreamView alloc] initWithStream:stream];
    	//放到需要展示的地方
    });
}

```
#### 3.7.2 取消订阅流
```objc
- (void)autoUnSub:(CCStream *)stream
{
    __weak typeof(self) weakSelf = self;
    [self.streamer unsubscribeWithStream:stream completion:^(BOOL result, NSError *error, id info) {
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
- (BOOL)subcribeWithStream:(CCStream *)stream completion:(CCComletionBlock)completion;
```

* 渲染远程流
```objc
//解码完成
- (void)onStreamFrameDecoded:(CCStream *)stream;
```

取消从服务端拉流：
* 取消拉流方法
```objc
- (BOOL)unsubscribeWithStream:(CCStream *)stream completion:(CCComletionBlock)completion;
```

### 4.6 开启视频/关闭视频

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
### 4.7 开启音频/关闭音频

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

### 4.8 被动监听事件

事件监听，建议在初始化sdk后做监听

#### 4.8.1 用户加入房间、退出房间通知
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

#### 4.8.2 学员举手通知(举手连麦模式)
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

#### 4.8.3 用户自定义消息发送
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

### 4.9 单条流音视频处理
//pragma mark -- 修改远程流接收状态
```objc
#pragma mark - 设置流视频的状态
/*!
 @method
 @abstract 设置流视频的状态
 @param stream  流
 @param video   视频流状态(开启/关闭)
 @param completion 成功闭包
  @return 操作结果
 */
- (BOOL)changeStream:(CCStream *)stream videoState:(BOOL)video completion:(CCComletionBlock)completion;
- 
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














