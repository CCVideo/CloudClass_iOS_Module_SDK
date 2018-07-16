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

* 具备基本的iOS开发能力

* 准备接入CC视频的云课堂SDK相关功能

### 1.3 SDK架构
* 支持的CPU架构有armv7,arm64

* 支持的最低系统版本iOS8


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
4. 添加需要的系统库:VideoToolbox.framework、libstdc++.tbd、libicucore.tbd
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


首先，需要下载最新版本的SDK，下载地址为：[Live_iOS_Play_SDK](https://github.com/CCVideo/Live_Android_Play_SDK)

### 3.1 导入framework
| 名称                         | 描述       |
| :------------------------- | :------- |
| CCClassRoomBasic.framework | 云课堂业务SDK |



### 3.2 framework添加Embedded Binaries
由于framework是动态库需要将CCClassRoomBasic.framework添加到Embedded Binaries

### 3.3 配置依赖系统库

工程需要下列系统库:libz.thd、libstdc++.thd、libicucore.thd、VideoToolBox.framework
### 3.4 创建SDK实例

在需要使用SDK的文件引入头文件

```objc
import <CCClassRoomBasic/CCClassRoomBasic.h>
```

创建SDK实例：
```objc
- (void)createBasic
{
 	CCEncodeConfig *config = [[CCEncodeConfig alloc] init];
    config.reslution = CCResolution_HIGH;
    
    self.streamerBasic = [CCStreamerBasic sharedStreamer];
    self.streamerBasic.videoMode = CCVideoPortrait;
    [self.streamerBasic addObserver:self];
}
```
系统代理回调

```objc
//视频流add回调
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#pragma mark - 流
- (void)onServerDisconnected
{
    [self.streamerBasic leave:^(BOOL result, NSError *error, id info) {
        
    }];
    WS(ws);
    dispatch_async(dispatch_get_main_queue(), ^{
      //退出当前控制器
      [ws.navigationController popViewControllerAnimated:NO];
    });
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
            [weakSelf.streamView showStreamView:info];
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}
```
### 3.5 加入直播间和直播间开始结束的接口
加入直播间的接口
```objc
    CCEncodeConfig *config = [[CCEncodeConfig alloc] init];
    config.reslution = CCResolution_HIGH;
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

### 3.6 推流调用接口
推流
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

### 3.7 结束推流接口

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

### 3.8 订阅流接口调用

```objc
- (void)autoSub:(CCStream *)stream
{
    __weak typeof(self) weakSelf = self;
    [self.stremer subcribeWithStream:stream qualityLevel:0 completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            [weakSelf.streamView showStreamView:info];
        }
        else
        {
            [weakSelf showError:error];
        }
    }];
}

```

### 3.9 取消订阅流接口调用

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

### 3.10 切换摄像头接口调用

```objc
- (void)changeCamera
{
    [self.stremer setCameraType:self.cameraIsBack ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront];
}
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
```
### 4.6 添加RTMP推流/取消RTMP推流

添加RTMP流到服务端：
* 添加RTMP流方法
```objc
- (BOOL)addExternalOutput:(NSString*)url completion:(CCComletionBlock)completion;
```

取消RTMP流到服务端：

* 取消添加RTMP流方法
```objc
- (BOOL)removeExternalOutput:(NSString *)url completion:(CCComletionBlock)completion;
```

### 4.7 切换摄像头

切换摄像头，前置摄像头和后置摄像头：

* 切换摄像头方法
```objc
- (BOOL)setCameraType:(AVCaptureDevicePosition)pos;
```

### 4.8 开启视频/关闭视频

开启本地视频流，也就是相机采集的视频：

* 开启相机视频方法

```objc
- (void)enableVideo;
```

关闭本地视频，也就是关闭相机采集的视频：

* 关闭相机视频方法
```objc
- (void)disableVideo;
```
### 4.9 开启音频/关闭音频

开启本地视频流的音频，也就是相机采集的音频流：

* 开启本地音频方法

```objc
- (void)enableAudio;
```

关闭本地视频流的音频，也就是关闭相机采集的音频流：

* 关闭本地音频方法

```objc
- (void)disableAudio;
```


## 5.API查询
Doc目录打开index.html文件

## 6.Q&A
### 6.1 运行崩溃
```objc
dyld: Library not loaded: @rpath/CCClassRoomBasic.framework/CCClassRoomBasic
  Referenced from: /var/containers/Bundle/Application/E8CDE526-6F19-415B-9BA4-2380AB0A1FDE/CCClassRoom.app/CCClassRoom
  Reason: image not found
```
解决办法参考3.2












