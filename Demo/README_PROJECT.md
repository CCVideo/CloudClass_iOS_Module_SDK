[TOC]

# 时间： 2019-08-02

##  工程正常运行注意事项：
订阅流流程有调整，请参考集成文档做微调；
### 1、版本支持
	支持最低版本：iOS9.0 ；
### 2、依赖SDK
	工程主要依赖 framework
	CCBarleyLibrary.framework
	CCClassRoomBasic.framework、
	CCChatLibrary.framework、
	CCDocLibrary.framework、
	CCFuncTool.framework、
	WebRTC.framework、
	加 DocUI.bundle资源库；

### 3、需另外下载集成SDK
用户需要到如下地址：[WebRTC下载地址](http://liveclass.csslcloud.net/SDK/HDSRTC_4.2.zip)   
	下载 WebRTC.framework 库 ，并将其添加到工程内；
### 4、SDK在工程内配置
	将 WebRTC.framework 库 添加到项目的 Target -> General -> Embedded Binaries 内；

### 5、最后
	运行工程即可；


