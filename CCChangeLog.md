

[TOC]

# 《组件化SDK变更说明》

# version 3.0.0 
> 版本 3.0.0   时间：2018-07-16

### 一、功能拆分
1、对基础版SDK、及全功能版SDK做了组件化分离；

# version 3.1.0
> 版本 3.1.0   时间：2018-09-12
### 一、新增功能
1、增加了排麦、举手、进入房间提醒
2、支持橡皮檫，激光笔，荧光笔。
3、直播时间

# version_3.2.0
> 版本 3.2.0   时间：2018-11-20

### 一、新增功能
1、老师可以撤销所有人画笔；
2、增加助教角色；
3、增加文档同步；

### 二、修改API
无

### 三、新增API

1、CCDocLibrary 库
```objc
/** 学生撤销 */
- (void)revokeLastDrawByStudent;
```

2、CCClassRoomBasic 库
```objc
/*!
 @method
 @abstract 订阅音频流
 @param stream 流
 @param completion 回调
 */
- (void)playAudio:(CCStream*)stream completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 取消订阅音频流
 @param stream 流
 @param completion 回调
 */
- (void)pauseAudio:(CCStream*)stream completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 订阅视频流
 @param stream 流
 @param completion 回调
 */
- (void)playVideo:(CCStream*)stream completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 取消订阅音频流
 @param stream 流
 @param completion 回调
 */
- (void)pauseVideo:(CCStream*)stream completion:(CCComletionBlock)completion;
```

# version_3.3.0
> 版本 3.3.0   时间：2018-12-18

## CCBarleyLibrary

### 一、功能修改
1、无；

### 二、接口变更 
1、无；

## CCChatLibrary

### 一、功能修改
1、无；

### 二、接口变更 
1、无；

## CCClassRoomBasic

### 一、功能修改
 1、增加异常监听上报功能；

### 二、接口变更 
1、新增API
```objc
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
```

## CCDocLibrary

### 一、功能修改
1、增加房间文档获取；
2、增加房间文档取消关联；
3、增加文档翻页
4、文档加载流程优化为分步加载；

### 二、接口变更 

1、新增接口

```objc
/** 文档环境初始化 */
- (void)initDocEnvironment;
  /** 设置文档竖屏支持优先（主要反映在白板部分） */
- (void)setDocPortrait:(BOOL)portrait;
  /** 开始加载文档 */
- (void)startDocView;
  /** 设置文档区域背景色 */
- (void)setDocBackGroundColor:(UIColor *)color;

#pragma mark -- 文档相关
/*!
 @method
 @abstract 获取房间机构文档
 @param roomID 房间ID(缺省为当前登录的房间ID)
 @param userID 房间ID(缺省为当前登录的房间userID)
 @param docID  文档ID（可选）
 @param docName 文档名字(可选)
 @param page    请求页码（获取指定页，默认返回第一页<可选>）
 @param size    请求每页条目数（每页的数据条数，默认每页50<可选>）
 @param completion 回调
 @return 操作结果
 */
- (BOOL)getRelatedRoomDocs:(NSString *)roomID
                    userID:(NSString *)userID
                     docID:(NSString *)docID
                   docName:(NSString *)docName
                pageNumber:(int)page
                  pageSize:(int)size
                completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 删除机构文档
 @param docID 文档ID
 @param roomID 房间ID(缺省为当前登录的房间ID)
 @param userID 房间ID(缺省为当前登录的房间userID)
 @param completion 回调
 @return 操作结果
 */
- (BOOL)unReleatedDoc:(NSString *)docID roomID:(NSString *)roomID userID:(NSString *)userID completion:(CCComletionBlock)completion;

/** 获取当前文档 */
- (NSString *)docCurrentDocId;
#pragma mark -- 文档切换相关API
/** 切换到白板 */
- (void)docPageToWhiteBoard;
  /** 切换到另一个文档 */
- (void)docChangeTo:(CCDoc *)doc;
  /** 向前翻页 */
- (void)docPageToFront;
  /** 回退翻页 */
- (void)docPageToBack;
```

# version_3.4.0
> 版本 3.4.0   时间：2019-2-28

## CCBarleyLibrary

### 一、功能修改
1、无；

### 二、接口变更 
1、无；


## CCChatLibrary

### 一、功能修改
1、无；

### 二、接口变更 
1、无；

## CCClassRoomBasic

### 一、功能修改
	1、流状态监听；
 	2、取消流状态监听；
 	3、麦克风音量检测；
 	4、取消麦克风音量检测；
	5、增加分流录制功能；
	6、增加节点探测功能；
### 二、接口变更 
1、新增API
```objc
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
```

## CCDocLibrary

### 一、功能修改
1、 新增文档加载状态监听
2、插播音视频接口变更
3、插播音视频同步

### 二、接口变更 

1、新增接口
```objc
/** 文档加载状态监听 */
- (void)setOnDpCompleteListener:(CCDocLoadBlock)OnDpCompleteListener;
```
2、插播音视频

```objc
//设置 player 容器
- (BOOL)setVideoPlayerContainer:(UIView *)playerContainer;
//设置 player frame
- (void)setVideoPlayerFrame:(CGRect)playerFrame;

```

# version_3.5.0
> 版本 3.5.0   时间：2019-03-23

## CCBarleyLibrary

### 一、功能修改
1、无；

### 二、接口变更 
1、无；


## CCChatLibrary

### 一、功能修改
1、无；

### 二、接口变更 
1、无；

## CCClassRoomBasic

### 一、功能修改
	1、部分功能接口废弃
### 二、接口变更 
1、弃用API
```objc
/*!
 * @method -- 暂时关闭
 * @abstract 设置摄像头
 * @discussion 切换摄像头
 * @param pos 摄像头位置
 * @result 操作结果
 */
- (BOOL)setCameraType:(AVCaptureDevicePosition)pos;

/*!
 @method -- 废弃
 @abstract 重新推流
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)rePublish:(CCComletionBlock)completion;

/*!
 @method -- 暂时关闭 
 @abstract 获取流状态
 @param stream 流
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)getConnectionStats:(CCStream *)stream completion:(CCComletionBlock)completion;

#pragma mark - 获取位置
/*!
 @method -- 废弃
 @abstract 获取布局位置
 @param stream 流
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)getRegion:(CCStream *)stream mixedStream:(CCStream *)mixedSteam completion:(CCComletionBlock)completion;

#pragma mark - 设置位置
/**
 @method -- 废弃
 @abstract 修改合流的主视频流
 @param stream 流
 @param regionID regionID
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)setRegion:(CCStream *)stream region:(NSString *)regionID mixedStream:(CCStream *)mixedSteam completion:(CCComletionBlock)completion;

#pragma mark - 合屏
/*!
 @method -- 废弃
 @abstract 合屏
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)mix:(CCComletionBlock)completion;
- 
#pragma mark - 取消合屏
/*! 
 @method -- 废弃
 @abstract 取消合屏
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)unmix:(CCComletionBlock)completion;

#pragma mark - 设置第三方推流地址
/*!
 @method -- 废弃
 @abstract 设置第三方推流地址
 @param url 第三方推流地址(rtmp地址)
 @param completion 结果
 @return 操作结果
 */
- (BOOL)addExternalOutput:(NSString*)url completion:(CCComletionBlock)completion;
- 
#pragma mark - 移除第三方推流地址
/*!
 @method -- 废弃
 @abstract 移除第三方推流地址
 @param url 第三方推流地址(rtmp地址)
 @param completion 结果
 @return 操作结果
 */
- (BOOL)removeExternalOutput:(NSString *)url completion:(CCComletionBlock)completion;
- 
#pragma mark - 变更第三方推流地址
/*!
 @method -- 废弃
 @abstract 变更第三方推流地址
 @param url 地址
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)updateExternalOutput:(NSString *)url completion:(CCComletionBlock)completion;

/*!
 @method -- 废弃
 @abstract 获取相机对象
 @return 相机对象
 */
- (AVCaptureSession *)getCaptureSession;

/*!
 @method -- 废弃
 @abstract 出发重连
 @param completion 回调闭包
 */
- (void)reconnectAtlas:(CCComletionBlock)completion;
```

## CCDocLibrary

### 一、功能修改
1、无

### 二、接口变更 

1、无


# version_3.6.0
> 版本 3.6.0   时间：2019-03-29

## CCBarleyLibrary

### 一、功能修改
1、无；

### 二、接口变更 
1、无；


## CCChatLibrary

### 一、功能修改
1、无；

### 二、接口变更 
1、无；

## CCClassRoomBasic

### 一、功能修改
	1、内部优化节点调度；
	2、iOS 音频动态显示
	3、iOS 网络节点延迟时间显示；
	4、修复插播音视频卡顿问题；
### 二、接口变更 


## CCDocLibrary

### 一、功能修改
1、无

### 二、接口变更 

1、无

