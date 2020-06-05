//
//  HDSLogFileReport.h
//  CCFuncTool
//
//  Created by Chenfy on 2020/4/7.
//  Copyright © 2020 com.class.chenfy. All rights reserved.
//

#import <Foundation/Foundation.h>

//账号id
#define KEYCC_LOG_accountid    @"cclogaccountid"
//房间id
#define KEYCC_LOG_roomid       @"cclogroomid"


NS_ASSUME_NONNULL_BEGIN

typedef void(^CCLogBlock)(BOOL result ,NSError * _Nullable obj);

@interface HDSLogFileReport : NSObject

- (void)logReport:(NSDictionary *)par upPath:(NSString *)upPath response:(CCLogBlock)block;

@end

NS_ASSUME_NONNULL_END
