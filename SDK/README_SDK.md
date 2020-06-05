
# 时间： 2020-03-17

## SDK集成注意事项：
### 特别提醒:
        需要在join接口之前初始化SDK并添加所必须的监听

### 1、版本支持
	支持最低版本：iOS9.0 ；
### 2、所有依赖SDK
	需要添加如下SDK：
	CCBarleyLibrary.framework、
	CCChatLibrary.framework、
	CCDocLibrary.framework、
	CCFuncTool.framework、
	CCClassRoomBasic.framework、
	ZegoLiveRoom.framework、
	MQTTClient.framework、
	SocketRocket.framework、
	DocUI.bundle；
### 3、SDK包内提供
	SDK包内已经提供SDK如下：
	CCBarleyLibrary.framework、
	CCChatLibrary.framework、
	CCClassRoomBasic.framework、
	CCDocLibrary.framework、
	CCFuncTool.framework、
	ZegoLiveRoom.framework、
	MQTTClient.framework、
	SocketRocket.framework、
	DocUI.bundle；
### 4、项目集成
	将 	
	CCBarleyLibrary.framework、
	CCChatLibrary.framework、
	CCClassRoomBasic.framework、
	CCDocLibrary.framework、
	CCFuncTool.framework、
	MQTTClient.framework、
	SocketRocket.framework、
	ZegoLiveRoom.framework
	添加到项目的 Target -> General -> Embedded Binaries 内；

### 5、功能集成
	根据SDK相关API集成相关功能；


