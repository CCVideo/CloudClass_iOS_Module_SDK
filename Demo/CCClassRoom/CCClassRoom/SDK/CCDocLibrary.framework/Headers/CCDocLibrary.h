//
//  CCDocLibrary.h
//  CCDocLibrary
//
//  Created by cc on 18/7/5.
//  Copyright © 2018年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

// 0 调试环境 | 1 打包环境
#define EnvOnLine 1

#if EnvOnLine

//ADD DEPEND LIBRARY HERE
#import <CCClassRoomBasic/CCClassRoomBasic.h>
#import "CCDocVideoView.h"

#else

//SDK 使用
#import "CCStreamerBasic.h"
#import "CCStream.h"
#import "CCEncodeConfig.h"
#import "CCStreamer.h"
#import <CCFuncTool/CCFuncTool.h>

#endif

//! Project version number for CCDocLibrary.
FOUNDATION_EXPORT double CCDocLibraryVersionNumber;

//! Project version string for CCDocLibrary.
FOUNDATION_EXPORT const unsigned char CCDocLibraryVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CCDocLibrary/PublicHeader.h>


