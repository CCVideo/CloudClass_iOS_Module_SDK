
# 时间： 2019-03-26

## SDK集成注意事项：

### 1、版本支持
	支持最低版本：iOS9.0 ；
### 2、所有依赖SDK
	需要添加如下SDK：
	CCBarleyLibrary.framework、
	CCChatLibrary.framework、
	CCClassRoomBasic.framework、
	CCDocLibrary.framework、
	CCFuncTool.framework、
	WebRTC.framework、
	DocUI.bundle；
### 3、SDK包内提供
	SDK包内已经提供SDK如下：
	CCBarleyLibrary.framework、
	CCChatLibrary.framework、
	CCClassRoomBasic.framework、
	CCDocLibrary.framework、
	CCFuncTool.framework、
	DocUI.bundle；
### 4、WebRTC.framework 下载
   用户需要到如下地址：[WebRTC下载地址](http://liveclass.csslcloud.net/SDK/RTCSDK.zip )   
	下载 WebRTC.framework 库 ，并将其添加到工程内；
### 5、项目集成
	将 	
	CCBarleyLibrary.framework、
	CCChatLibrary.framework、
	CCClassRoomBasic.framework、
	CCDocLibrary.framework、
	CCFuncTool.framework、
	WebRTC.framework； 库 
	添加到项目的 Target -> General -> Embedded Binaries 内；

### 6、功能集成
	根据SDK相关API集成相关功能；
