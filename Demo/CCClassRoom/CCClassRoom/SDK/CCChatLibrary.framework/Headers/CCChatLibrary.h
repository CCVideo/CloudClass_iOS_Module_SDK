//
//  CCChatLibrary.h
//  CCChatLibrary
//
//  Created by cc on 18/7/11.
//  Copyright © 2018年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

// 0 调试环境 | 1 打包环境
#define EnvOnLine 1

#if EnvOnLine

//ADD DEPEND LIBRARY HERE
#import <CCClassRoomBasic/CCClassRoomBasic.h>
#import "CCChatManager.h"

#else

//SDK 使用
#import "CCStreamerBasic.h"
#import "CCStream.h"
#import "CCEncodeConfig.h"
#import "CCStreamer.h"
#import <CCFuncTool/CCFuncTool.h>

#endif


//! Project version number for CCChatLibrary.
FOUNDATION_EXPORT double CCChatLibraryVersionNumber;

//! Project version string for CCChatLibrary.
FOUNDATION_EXPORT const unsigned char CCChatLibraryVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CCChatLibrary/PublicHeader.h>


