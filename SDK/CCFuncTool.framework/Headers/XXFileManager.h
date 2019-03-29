//
//  CCFileMamaner.h
//  LockMethodThread
//
//  Created by cc on 2018/11/29.
//  Copyright © 2018年 cc. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark -- 本地存储文件名
extern NSString *const CC_FILE_EXCEPTION;
extern NSString *const CC_FILE_ROOM;
extern NSString *const CC_FILE_STREAM_STATUS;
extern NSString *const CC_FILE_STREAM;
extern NSString *const CC_FILE_SERVER;
extern NSString *const CC_FILE_SOCKET_STATUS;
extern NSString *const CC_FILE_SOCKET;
extern NSString *const CC_FILE_API;

//XXLog打印
extern bool gl_open_log;

#define XXLog(...)      \
if(gl_open_log == true) {   \
NSLog(@"\n%s \n第%d行 \n%@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__]); \
}\

//获取当前函数的:名称、行数
#define XXLogFuncLine [NSString stringWithFormat:@"%s_[%d]",__func__,__LINE__]
//房间信息
#define XXLogSaveRoom(info) \
[[XXFileManager sharedManager]writeRoomInfo:info]
//服务server信息
#define XXLogSaveServer(server) \
[[XXFileManager sharedManager]writeServerStatus:server]
//保存API func Log
#define XXLogSaveAPIFunc(func) \
[[XXFileManager sharedManager]writeApi:func param:@{} result:YES response:@{}]
//保存API par Log
#define XXLogSaveAPIPar(func,par) \
[[XXFileManager sharedManager]writeApi:func param:par result:YES response:@{}]
//保存API result Log
#define XXLogSaveAPIResult(func,par,res) \
[[XXFileManager sharedManager]writeApi:func param:par result:res response:@{}]
//保存API response Log
#define XXLogSaveAPI(func,par,res,resp) \
[[XXFileManager sharedManager]writeApi:func param:par result:res response:resp]

//Log socket event
#define XXLogSaveSocketEvent(event) \
[[XXFileManager sharedManager]writeSocketEvent:event]
//Log socket status
#define XXLogSaveSocketStatus(status) \
[[XXFileManager sharedManager]writeSocketStatus:status]
//Log mqtt event
#define XXLogSaveMQTTEvent(event) \
[[XXFileManager sharedManager]writeMQTTEvent:event]
//Log mqtt status
#define XXLogSaveMQTTStatus(status) \
[[XXFileManager sharedManager]writeMQTTStatus:status]
//Log stream info
#define XXLogSaveStreamInfo(info) \
[[XXFileManager sharedManager]writeStreamInfo:info]
//Log stream status
#define XXLogSaveStreamStatus(status,sid) \
[[XXFileManager sharedManager]writeStreamStatus:status sid:sid]


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,CCLogType) {
    CCLogTypeRoom,  //房间信息
    CCLogTypeStreamStatus,//流状态
    CCLogTypeStream,    //流信息
    CCLogTypeServer,    //服务连接
    CCLogTypeSocketStatus,  //socket状态
    CCLogTypeSocket,        //socket信息
    CCLogTypeApi,           //API log
    CCLogTypeException,     //崩溃异常
    CCLogTypeAll   //所有log
};

//获取时间数据
typedef NS_ENUM(NSInteger,CCTimeType) {
    CCTimeTypeYear,
    CCTimeTypeMonth,
    CCTimeTypeDay,
    CCTimeTypeHour,
    CCTimeTypeMin,
    CCTimeTypeSecond,
    CCTimeTypeTimeStamp
};

//获取系统目录路径
typedef NS_ENUM(NSInteger,CCDirectoryRootType) {
    CCDirectoryRootTypeHome,
    CCDirectoryRootTypeDocuments,
    CCDirectoryRootTypeLibrary,
    CCDirectoryRootTypeCache,
    CCDirectoryRootTypeTemp,
    CCDirectoryDayTypeCCInfo
};

@interface XXFileManager : NSObject
//单例文件
+ (instancetype)sharedManager;
//log过期删除
+ (void)setLogExpireRemove:(BOOL)remove;
//log过期天数
+ (void)setLogExpireDays:(NSInteger)days;
//设置是否启用log开关
+ (void)setLogFunctionOpen:(BOOL)open;
//启动时初始化环境
+ (void)startUp;
//检查过期文件
- (void)updateLocalLogFile;
//读取本地所有日志
- (NSDictionary *)readInfoLocalAll;
//读取一天的日志
- (NSDictionary *)readInfoDayWithOffset:(NSInteger)offset;
- (NSDictionary *)readInfoDayWithDayName:(NSString *)dayDirName;
//读取文件内容
- (NSArray *)readInfo:(NSInteger)dayOffset logType:(CCLogType)type;
- (NSArray *)readInfoDayDirName:(NSString *)dayDirName logType:(CCLogType)type;
//写日志
- (void)writeInfo:(NSDictionary *)dicInfo to:(CCLogType)type;
//获取当前时间
- (NSString*)currentTimeString:(CCTimeType)type;
//获取文件App路径
- (NSString *)rootDirectory:(CCDirectoryRootType)type;
//清除今天的log
- (void)removeTodayLog;

#pragma mark -- 功能接口
- (void)writeRoomInfo:(id)obj;
- (void)writeStreamInfo:(id)obj;
- (void)writeStreamStatus:(id)obj sid:(id)sid;
- (void)writeSocketEvent:(id)obj;
- (void)writeSocketStatus:(id)obj;
- (void)writeMQTTEvent:(id)obj;
- (void)writeMQTTStatus:(id)obj;
- (void)writeServerStatus:(id)obj;

- (void)writeApi:(NSString *)func;
- (void)writeApi:(NSString *)func param:(NSDictionary *)param;
- (void)writeApi:(NSString *)func param:(NSDictionary *)param result:(BOOL)result;
- (void)writeApi:(NSString *)func param:(NSDictionary *)param result:(BOOL)result response:(id)obj;

#pragma mark --NSUserdefault存取
- (void)userSetValue:(id)value forKey:(NSString *)key;
- (id)userValueForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
