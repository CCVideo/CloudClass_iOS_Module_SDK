# mark

--- version 3.3.0 ---

## 一 CCBarleyLibrary

一、功能修改
1、无；

二、接口变更 
1、无；

## --- CCChatLibrary

一、功能修改
1、无；

二、接口变更 
1、无；

## --- CCClassRoomBasic

一、功能修改
 1、增加异常监听上报功能；
二、接口变更 

```C++
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

## --- CCDocLibrary

一、功能修改
1、增加房间文档获取；
2、增加房间文档取消关联；
3、增加文档翻页
4、文档加载流程优化为分步加载；

二、接口变更 

```C++
/** 文档环境初始化 */
- (void)initDocEnvironment;
/** 设置文档竖屏支持优先（主要反映在白板部分） */
- (void)setDocPortrait:(BOOL)portrait;
/** 开始加载文档 */
- (void)startDocView;
/** 设置文档区域背景色 */
- (void)setDocBackGroundColor:(UIColor *)color;
```

#pragma mark -- 文档相关

```C++
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
```

#pragma mark -- 文档切换相关API

```C++
/** 切换到白板 */
- (void)docPageToWhiteBoard;
/** 切换到另一个文档 */
- (void)docChangeTo:(CCDoc *)doc;
/** 向前翻页 */
- (void)docPageToFront;
/** 回退翻页 */
- (void)docPageToBack;
```

