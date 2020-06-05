iOS聊天组件

[TOC]

# 聊天组件说明文档

聊天组件的核心类是CCChatManager;
```objc
//在工程需要的地方引入头文件
#import <CCChatLibrary/CCChatLibrary.h>

//1、类的实例化
+ (instancetype)sharedChat;

//2、与BaseSDK建立联系
- (void)addBasicClient:(CCStreamerBasic *)basic;
```

## 1 事件的监听(包括图片、以及表情、文本、禁言)
### 1.1 监听消息事件的回调通知
下面所有的场景都以demo为例，如场景：CCPlayViewController控制器，具体可参考demo实现；
在控制器添加监听，如下：
```objc
//#pragma mark -- 接收
-(void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveSocketEvent object:nil];
}
```
在不需要使用的时候移除监听，如下
```objc
-(void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
```
监听事件处理如下：
```objc
- (void)receiveSocketEvent:(NSNotification *)noti
{
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    id value = noti.userInfo[@"value"];
    
    if (event == CCSocketEvent_Chat)
    {
        NSLog(@"%d", __LINE__);
        //聊天信息
        [self chat_message:value];
    }
  else if (event == CCSocketEvent_GagOne)
    {
        //判断自己是否被禁言
        BOOL isSelfGag = [self.ccChatManager isUserGag];
    }
    else if (event == CCSocketEvent_GagAll)
    {
        //判断房间是否被禁言
        BOOL isSelfGag = [self.ccChatManager isRoomGag];
    }
}

//解析聊天信息
- (void)chat_message:(NSDictionary *)dic
{
    CCLog(@"chat_message_received:%@",dic);
    __unused NSString *role = dic[@"userrole"];
 	//根据userid判断消息的发送者
    
    NSString *msg = dic[@"msg"];
    if ([msg isKindOfClass:[NSString class]] || [msg isKindOfClass:[NSMutableString class]])
    {
        [self showMessage:@"收到聊天message!"];
    }
    else
    {
        [self showMessage:@"收到聊天Pic!"];
    }
}
```

## 2 消息的发送

由发送端发起通知
```objc
/*!
 @method
 @abstract 发送公聊信息
 */
- (BOOL)sendMsg:(NSString *)message;
```
object 参数说明：

| 参数名称    | 参数类型     | 说明   | 是否必须 |
| ------- | -------- | ---- | ---- |
| message | NSString | 发送消息 | 必选   |

## 3 图片的发送
由发送端发起通知
```objc
/*!
 @method
 @abstract 发送聊天图片
 @param image 图片
 @param completion 回调
 */
- (void)sendImage:(UIImage *)image completion:(CCComletionBlock)completion;
```
object 参数说明：

| 参数名称  | 参数类型    | 说明      | 是否必须 |
| ----- | ------- | ------- | ---- |
| image | UIImage | image数据 | 必选   |

## 4 公有的方法
### 4.1 当前房间是否禁言
```objc
/*!
 @method
 @abstract 用户是否被禁言
 */
- (BOOL)isRoomGag;
```
### 4.2 当前用户是否被禁言
```objc

/*!
 @method
 @abstract 房间是否被禁言
 */
- (BOOL)isUserGag;
```
### 4.3 禁言单个用户
```objc
/*!
 @method
 @abstract 对某个学生禁言
 @param userID 学生ID
 
 @return 操作结果
 */
- (BOOL)gagUser:(NSString *)userID;
```

### 4.4 取消禁言某个用户

```objc
/*!
 @method
 @abstract 取消对某个学生禁言
 @param userID 学生ID
 
 @return 操作结果
 */
- (BOOL)recoveGagUser:(NSString *)userID;
```

### 4.5 全体禁言

```objc
/*!
 @method
 @abstract 全体禁言
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)gagAll:(CCComletionBlock)completion;
```

### 4.6 取消全体禁言

```objc
/*!
 @method
 @abstract 取消全体禁言
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)recoverGagAll:(CCComletionBlock)completion;
```


