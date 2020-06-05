//
//  CCMacroHeaderInner.h
//  CCClassRoomBasic
//
//  Created by cc on 2018/12/3.
//  Copyright © 2018年 cc. All rights reserved.
//

#ifndef CCMacroHeaderInner_h
#define CCMacroHeaderInner_h


typedef void(^SuccessBlock)(id object);
typedef void(^FailBlock)(id object, NSError *error);

#define kVideoCodec         @"VideoCodec"
#define kAudioMaxBandWidth  @"kAudioMaxBandWidth"
#define kVideoMaxBandWidth  @"kVideoMaxBandWidth"


#define LOGIN @"/api/login"
#define STARTLIVE @"/api/live/start"
#define STOPLIVE @"/api/live/stop"

#define STARTLIANMAI @"/api/user/speak/request"
#define CANCLELIANMAI @"/api/user/speak/cancel"
#define STOPLIANMAI @"/api/user/speak/down"
#define UPDATELIANMAISTATE @"/api/user/speak/result"

#define ROTATE @"/api/user/speak/rotate"
#define ROTATELOCK @"/api/user/speak/lock"

#define PUBLISHCUSTOMMEASSAGE @"/api/live/announcement/release"
#define CLEANCUSTOMMEASSAGE @"/api/live/announcement/remove"

#define ROOMSETTING @"/own/api/room/update"

#define INVITELIANMAI @"/api/user/speak/invite"
#define CERTAINLIANMAI @"/api/user/speak/certain"
#define ACCEPTINVITE @"/api/user/speak/accept"

#define GETDOCHISTORY @"https://view.csslcloud.net/api/view/info"
#define GETROOMDESC @"/api/user/room/desc"

#define GETDOCS @"/servlet/docs"
#define DELDOC @"/servlet/delete"
#define GETDOC @"/servlet/doc"

#define RELEATEDGETDOCS @"/api/doc/auth/list"
#define UNRELEATEDDOC @"/api/doc/unrelate"

#define AUTH @"/api/room/auth"
#define AUTHLOGIN @"/api/room/join"
#define GETUSERINFO @"/api/room/user_detail"
//#define GETROOMINFO @"/api/room/room_detail"
#define GETROOMINFO @"/api/room/room_desc"
#define GETSERVER @"/api/dispatch"

#define LOGINOUT @"/api/user/logout"
#define GETUSERLIST @"/api/room/list"

#define PICTOKEN @"/api/oss/token"

#define REMOVEVIDEOANDAUDIO @"/api/insert_media"
//获取房间用户列表接口(解决流匹配不上的问题)
#define API_ROOM_SPEAK_CONTEXT   @"/api/room/speakcontext"

//获取节点
#define SSS_Domain  @"https://ccapi.csslcloud.net/api/dispatch"
#define SSS_ACTIVATY    @"/api/active"
//网络检测
typedef void(^CCSNetDomainBlcok)(BOOL result,float time ,NSString *domain);

//获取系统版本
#define IOS_SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//判断 iOS 8 或更高的系统版本
#define IOS_VERSION_8_OR_LATER (([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0)? (YES):(NO))

extern bool openLog;

#define CCLog(...) if(openLog == true) {\
NSLog(__VA_ARGS__);\
}

#define API_LOGIN @"/api/login"
#define API_STARTLIVE @"/api/live/start"
#define API_STOPLIVE @"/api/live/stop"
#define API_AUTH @"/api/room/auth"
#define API_AUTHLOGIN @"/api/room/join"
#define API_PICTOKEN @"/api/oss/token"
#define API_LIVESTATE @"/api/live/stat"
#define API_STREAMADD @"/api/atlas/stream/added"
#define API_STREAMREMOVE @"/api/atlas/stream/remove"
#define API_STREAMSUB @"/api/atlas/stream/subscribe"
#define API_STREAMUNSUB @"/api/atlas/stream/unsubscribe"
#define API_GETSERVERLIST @"/api/dispatch"
#define API_GETSERVERDETECT @"/api/detect"
#define API_GETVIDEOPLAYURL @"/api/v1/serve/video/playurl"

#define API_GETROOMINFO @"/api/room/room_desc"
#define API_ROOMSETTING @"/own/api/room/update"
#define API_LEAVE @"/api/atlas/stream/break"
#define API_ATLASKICKOUT @"/api/atlas/user/kickout"

#define API_ACTIVATY    @"/api/active" //网络检测
#define API_URL_ATLAS_TOKEN @"/api/atlas/token/create"  //获取atlasToken

//获取atlasToken
#define API_URL_ATLAS_TOKEN @"/api/atlas/token/create"
#pragma mark -- 直播录制
#define API_RECORD_START     @"/api/record/start"
#define API_RECORD_PAUSE     @"/api/record/pause"
#define API_RECORD_RESUME    @"/api/record/resume"
#define API_RECORD_END       @"/api/record/end"

#define WeakSelf(weakSelf)      __weak __typeof(self)weakSelf = self;

#endif /* CCMacroHeaderInner_h */
