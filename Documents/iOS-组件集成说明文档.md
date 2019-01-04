[TOC]
# 推拉流基础版组件集成说明

## 1.概述
CC基础版SDK 是一个适用于iOS平台的云课堂SDK，使用此SDK可以与CC视频云服务进行对接，在iOS端使用CC视频的云课堂功能。

### 1.1 功能特性
ios端SDK目前支持了基础版SDK、白板插件、聊天插件以及排麦插件；

#### 1.1.1 基础版SDK功能
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

用于展示老师端的操作；

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

* 具备基本的iOS开发能力

* 准备接入CC视频的云课堂SDK相关功能

## 2.开发准备

### 2.1 开发环境
* Xcode : iOS 开发IDE
* 支持的CPU架构有armv7,arm64
* 支持的最低系统版本iOS8
* 模拟器支持：ipad air及以上版本，iphone 5s及以上版本模拟器；
* 开发所需相关账号请咨询CC视频客户人员提供；

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

注：快速集成主要提供的是推流和拉流的功能(核心功能)。白板、聊天以及排麦组件另有开发文档描述。

首先，需要下载最新版本的SDK，下载地址为：[CloudClass_iOS_Base_SDK](https://github.com/CCVideo/CloudClass_iOS_Base_SDK)

### 3.1 导入framework
| 名称                         | 描述           |
| :------------------------- | :----------- |
| CCClassRoomBasic.framework | CC音视频核心jar包  |
| CCDocLibrary.framework     | CC白板插件核心jar包 |
| CCChatLibrary.framework    | CC聊天插件核心jar包 |
| CCBarleyLibrary.framework  | CC排麦插件核心jar包 |

### 3.2 framework添加Embedded Binaries

由于framework是动态库需要将CCClassRoomBasic.framework、CCDocLibrary.framework  、CCChatLibrary.framework、CCBarleyLibrary.framework 添加到Embedded Binaries；

### 3.3 配置依赖库

工程需要下列系统库:libz.thd、libstdc++.thd、libicucore.thd、VideoToolBox.framework

### 3.4 组件使用
组件使用是基于基础版SDK的；

#### 3.4.1 基础版SDK实例化

在需要使用SDK的文件引入头文件

```objc
import <CCClassRoomBasic/CCClassRoomBasic.h>
在@interface 添加CCStreamerBasic、CCRoom实例属性，方便后续调用；
@property(nonatomic,strong)CCRoom   *room;
@property(nonatomic,strong)CCStreamerBasic *stremer;

```

创建SDK实例：
```objc
- (CCStreamerBasic *)stremer
{
    if (!_stremer) {
        _stremer = [CCStreamerBasic sharedStreamer];
    }
    return _stremer;
}
- (CCRoom *)room
{
    return [self.stremer getRoomInfo];
}
```

#### 3.4.2 文档组件实例化

在需要使用文档组件的文件引入头文件

```objc
#import <CCDocLibrary/CCDocLibrary.h>
在@interface CCDocVideoView 实例属性方便后续调用；
@property(nonatomic,strong)CCDocVideoView   *ccVideoView;

```

创建SDK实例：

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

#### 3.4.3 聊天组件实例化

在需要使用文档组件的文件引入头文件

```objc
#import <CCChatLibrary/CCChatLibrary.h>
在@interface CCChatManager实例属性方便后续调用；
@property(nonatomic,strong)CCChatManager    *ccChatManager;

```

创建SDK实例：

```objc
- (CCChatManager *)ccChatManager
{
    if (!_ccChatManager) {
        _ccChatManager = [CCChatManager sharedChat];
    }
    return _ccChatManager;
}
```

#### 3.4.4 排麦组件实例化

在需要使用文档组件的文件引入头文件

```objc
#import <CCBarleyLibrary/CCBarleyLibrary.h>
在@interface CCBarleyManager实例属性方便后续调用；
@property(nonatomic,strong)CCBarleyManager  *ccBarelyManager;

```

创建SDK实例：

```objc
- (CCBarleyManager *)ccBarelyManager
{
    if (!_ccBarelyManager) {
        _ccBarelyManager = [CCBarleyManager sharedBarley];
    }
    return _ccBarelyManager;
}
```


## 4 组件与基础版SDK建立关联
要使用文档、聊天、排麦组件需要配合基础版SDK使用，要建立关联，如下：

```objc
- (void)initBaseSDKComponent
{
    self.stremer = [CCStreamerBasic sharedStreamer];
    self.stremer.videoMode = CCVideoPortrait;
    [self.stremer addObserver:self];
    
    //白板
    [self.stremer addObserver:self.ccVideoView];
    [self.ccVideoView addBasicClient:self.stremer];
    //聊天
    [self.stremer addObserver:self.ccChatManager];
    [self.ccChatManager addBasicClient:self.stremer];
    //排麦
    self.stremer.isUsePaiMai = YES;
    [self.stremer addObserver:self.ccBarelyManager];
    [self.ccBarelyManager addBasicClient:self.stremer];
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
