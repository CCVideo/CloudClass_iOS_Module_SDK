//
//  CCCommonTool.h
//  CCClassRoomBasic
//
//  Created by cc on 2018/12/3.
//  Copyright © 2018年 cc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCCommonTool : NSObject
//socket事件
+ (NSArray *)getAllSocketActionName;
+ (NSArray *)getJoinAuditSocketActionName;

//唯一标识
+ (NSString *)uniqueMark;
+ (void)deleteUniqueMark;


@end

NS_ASSUME_NONNULL_END
