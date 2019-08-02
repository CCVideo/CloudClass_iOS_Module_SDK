[TOC]

# 白板与文档组件

# 1. 白板画笔相关
## 1.1 白板基础功能
### 1.1.1 白板初始化
白板与文档组件的核心类是CCDocViewManager;
```objc
//在工程需要的地方引入头文件
#import <CCDocLibrary/CCDocLibrary.h>

//1、类的实例化
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
### 1.1.2 建立Base库的依赖

```objc
//与BaseSDK建立联系
- (void)addBasicClient:(CCStreamerBasic *)basic;
```

### 1.1.3 修改画板的尺寸

```objc
/** 设置frame */
- (void)setDocFrame:(CGRect)frame;
```

### 1.1.4 添加画板相关监听事件

```objc
//添加监听
- (void)addObserverNotify;
```

### 1.1.4 移除画板监听事件

```objc
//移除监听
- (void)removeObserverNotify;
```

### 1.1.5 设置日志开关

```objc
//设置日志开关
+ (void)setLogState:(BOOL)open;
```

### 1.1.6 socket事件接收

```objc
//事件处理
- (void)onSocketReceive:(NSString *)event value:(id)object;
- (void)onSocketReceive:(NSString *)message onTopic:(NSString *)topic;

```

### 1.1.7 设置插播音视频view

```objc
//视频框
- (void)setPlayerFrame:(CGRect)playerFrame superView:(UIView *)showView;
```

## 1.2 设置手指触发画笔
```objc
- (void)setDocEditable:(BOOL)canEdit;
```
object 参数说明：

| 参数名称    | 参数类型 | 说明                | 是否必须 |
| ------- | ---- | ----------------- | ---- |
| canEdit | BOOL | YES：支持画笔；NO：不支持画笔 | 必选   |


## 1.3 设置画笔的粗细（支持老师端，或是被设为讲师，或是授权标注，才需要设置）

```objc
/** 设置画笔宽度 */
- (void)setStrokeWidth:(CGFloat)width;
```
object 参数说明：

| 参数名称  | 参数类型    | 说明                   | 是否必须 |
| ----- | ------- | -------------------- | ---- |
| width | CGFloat | 设置画笔的粗细，精度为CGFloat类型 | 必选   |

## 1.4 设置画笔的颜色（支持老师端，或是被设为讲师，或是授权标注，才需要设置）
```objc
/** 设置画笔颜色 */
- (void)setStrokeColor:(UIColor *)color;
```
object 参数说明：

| 参数名称  | 参数类型    | 说明    | 是否必须 |
| ----- | ------- | ----- | ---- |
| color | UIColor | 画笔的颜色 | 必选   |

## 1.5 撤销画笔（支持老师端，或是被设为讲师，或是授权标注，才需要设置）

```objc
/** 老师撤销画笔(可以撤销所有人) */
- (void)revokeLastDraw;
/** 学生撤销 */
- (void)revokeLastDrawByStudent;
```

## 1.6 清空画笔数据（支持老师端，或是被设为讲师，或是授权标注，才需要设置）

1、清空当前页的画笔数据：
```objc
/** 清除当前页的画笔数据 */
- (void)revokeAllDraw;
```

2、清空整个文档的画笔数据
```objc
/** 清空整个文档的画笔数据 */
- (void)revokeAllDocDraw;
```

## 1.7 橡皮擦功能
1、是否开启橡皮擦功能：
```objc
/** 设置当前是否是橡皮擦 */
- (void)setCurrentIsEraser:(BOOL)eraser;
```

object 参数说明：

| 参数名称   | 参数类型 | 说明      | 是否必须 |
| ------ | ---- | ------- | ---- |
| eraser | BOOL | 是否开启橡皮擦 | 必选   |

## 1.8 手势支持功能
1、是否打开文档手势支持：
```objc
/** 设置手势开关 */
- (void)setGestureOpen:(BOOL)open;
```
如果关闭手势支持，文档会恢复缩放前的状态；

object 参数说明：

| 参数名称 | 参数类型 | 说明       | 是否必须 |
| ---- | ---- | -------- | ---- |
| open | BOOL | 是否开启文档手势 | 必选   |

## 1.9 文档加载状态监听
1、文档加载监听
```objc
/** 文档加载状态监听 */
- (void)setOnDpCompleteListener:(CCDocLoadBlock)OnDpCompleteListener;
```

## 1.10 插播音视频相关
1、设置player容器
```objc
//设置 player 容器
- (BOOL)setVideoPlayerContainer:(UIView *)playerContainer;

```
2、修改player位置大小
```objc
 //设置 player frame
- (void)setVideoPlayerFrame:(CGRect)playerFrame;

```


# 2 权限相关

## 2.1 设为讲师/取消设为讲师
1、设为讲师
```objc
/** 设为讲师 */
- (BOOL)authUserAsTeacher:(NSString *)userId;
```
| 参数     | 参数说明    |
| ------ | ------- |
| userId | 指定的用户id |

2、取消设为讲师
```objc
/** 取消设为讲师 */
- (BOOL)cancleAuthUserAsTeacher:(NSString *)userId;
```

| 参数     | 参数说明    |
| ------ | ------- |
| userId | 指定的用户id |

## 2.2 授权标注/取消授权标注

1、授权标注
```objc
/** 授权标注 */
- (BOOL)authUserDraw:(NSString *)userId;
```

| 参数     | 参数说明    |
| ------ | ------- |
| userId | 指定的用户id |

2、取消授权标注
```objc
/** 取消授权标注 */
- (BOOL)cancleAuthUserDraw:(NSString *)userId;
```

| 参数     | 参数说明    |
| ------ | ------- |
| userId | 指定的用户id |




# 3. 加载画板内容
## 3.1 画板加载
### 3.1.1 文档环境初始化

```objc
/** 文档环境初始化 */
- (void)initDocEnvironment;
```
### 3.1.2 设置文旦横竖屏支持等级(白板）

```objc
/** 设置文档竖屏支持优先（主要反映在白板部分） */
- (void)setDocPortrait:(BOOL)portrait;
```

### 3.1.3 设置文档背景色

```objc
/** 设置文档区域背景色 */
- (void)setDocBackGroundColor:(UIColor *)color;
```

### 3.1.4 开始加载文档

进入房间成功后，初始化文档环境后调用；
（需要迟于initDocEnvironment 一定时间调用，大概1s左右；也可根据具体测试情况调整下）
```objc
- (void)startDocView;
```
## 3.2 获取房间关联文档
1、获取房间关联文档

```objc
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
```
## 3.3 取消文档关联
1、取消房间文档关联

```objc
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
```
## 3.4 文档切换、翻页相关

### 3.4.1 doc切为白板
```objc
/** 切换到白板 */
- (void)docPageToWhiteBoard;
```

### 3.4.2 doc切换文档
```objc
/** 切换到另一个文档 */
- (void)docChangeTo:(CCDoc *)doc;
```

### 3.4.3 doc向前翻页
```objc
/** 向前翻页 */
- (void)docPageToFront;
```

### 3.4.4 doc回退翻页
```objc
/** 回退翻页 */
- (void)docPageToBack;
```

### 3.4.5 获取当前文档
```objc
/** 获取当前Doc */
- (CCDoc *)docCurrentPPT;
```

### 3.4.6 获取当前文档页码
```objc
/** 获取文档当前页码 */
- (NSInteger)docCurrentPage;
```

### 3.4.7 文档跳页
```objc
/** 跳转到某一页 */
- (void)docSkip:(CCDoc *)doc toPage:(NSInteger)page;
```


# 4. 事件消息通知

## 4.1 添加消息监听

在需要画板的相关控制器内根据需求添加与移除监听事件
```objc
#pragma mark -- 接收
-(void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveSocketEvent object:nil];
}
-(void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

```

## 4.2 监听事件处理

收到监听事件后根据业务需求进行其它相关操作

```objc

- (void)receiveSocketEvent:(NSNotification *)noti
{
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    id value = noti.userInfo[@"value"];
   
if (event == CCSocketEvent_ReciveDrawStateChanged)
    {
               //授权标注事件
         CCUser *user = noti.userInfo[@"user"];
        if (user.user_drawState)
        {
            //被授权标注..客户开展后续自己的业务
        }
    }
    else if (event == CCSocketEvent_ReciveAnssistantChange)
    {
        //设为讲师事件
        CCUser *user = noti.userInfo[@"user"];
        if (user.user_AssistantState)
        {
            //被设为讲师..客户开展后续自己的业务
        }
    }
}
```

