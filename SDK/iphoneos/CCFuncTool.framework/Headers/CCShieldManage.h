//
//  CCShieldManage.h
//  CCFuncTool
//
//  Created by 刘强强 on 2020/4/10.
//  Copyright © 2020 com.class.chenfy. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_OPTIONS(NSUInteger, CCShieldType) {
    CCShieldTypeUnrecognizedSelector = 1 << 1,
    CCShieldTypeContainer = 1 << 2,
    CCShieldTypeNSNull = 1 << 3,
    CCShieldTypeKVO = 1 << 4,
    CCShieldTypeNotification = 1 << 5,
    CCShieldTypeTimer = 1 << 6,
    CCShieldTypeDangLingPointer = 1 << 7,
    CCShieldTypeExceptDangLingPointer = (CCShieldTypeUnrecognizedSelector | CCShieldTypeContainer |
                                          CCShieldTypeNSNull| CCShieldTypeKVO |
                                          CCShieldTypeNotification | CCShieldTypeTimer)
};
@protocol CCShieldManageProtocol <NSObject>

- (void)ccShieldManageRecordWithReason:(NSError *_Nonnull)reason;

@end
NS_ASSUME_NONNULL_BEGIN

@interface CCShieldManage : NSObject
/**
 注册SDK，默认只要开启就打开防Crash，如果需要DEBUG关闭，请在调用处使用条件编译
 本注册方式不包含CCShieldTypeDangLingPointer类型
 */
+ (void)registerStabilitySDK:(id<CCShieldManageProtocol>)record;

/**
 本注册方式不包含CCShieldTypeDangLingPointer类型
 
 @param ability ability
 */
+ (void)registerStabilityWithAbility:(CCShieldType)ability record:(id<CCShieldManageProtocol>)record;

/**
 ///注册CCShieldTypeDangLingPointer需要传入存储类名的array，不支持系统框架类。
 
 @param ability ability description
 @param classNames 野指针类列表
 */
+ (void)registerStabilityWithAbility:(CCShieldType)ability withClassNames:(nonnull NSArray<NSString *> *)classNames record:(id<CCShieldManageProtocol>)record;
@end

NS_ASSUME_NONNULL_END
