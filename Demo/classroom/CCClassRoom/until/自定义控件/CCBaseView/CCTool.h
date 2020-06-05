//
//  CCTool.h
//  CCClassRoom
//
//  Created by cc on 18/6/15.
//  Copyright © 2018年 cc. All rights reserved.
//

/*!  头文件基本信息。这个用在每个源代码文件的头文件的最开头。
 
 @header CCTool.h
 
 @abstract 关于这个源代码文件的一些基本描述
 
 @author Created by cc on 18/6/15.
 
 @version 1.00 18/6/15 Creation (此文档的版本信息)
 
 //  Copyright © 2018年 cc. All rights reserved.
 
 */


#import <Foundation/Foundation.h>
//#import <CCClassRoom/CCClassRoom.h>

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

//消息提醒title
#define KKEY_tips_title         @"注意"
#define KKEY_continue_liveing   @"是否继续上场直播？"
#define KKEY_open_recording     @"是否开启视频录制？"

#define KKEY_cancel             @"取消"
#define KKEY_continue           @"继续"
#define KKEY_open               @"开启"
#define KKEY_loading            @"请稍候..."

//角色定义
#define KKEY_CCRole_Teacher         @"presenter"
#define KKEY_CCRole_Student         @"talker"
#define KKEY_CCRole_Watcher         @"audience"
#define KKEY_CCRole_Inspector       @"inspector"
#define KKEY_CCRole_Assistant       @"assistant"

@interface CCTool : NSObject

@property(nonatomic,strong)UINavigationController *navController;

+ (instancetype)sharedTool;

+ (BOOL)controllerIsShow:(UIViewController *)controller;

+ (UILabel *)createLabelText:(NSString *)text;
+ (UIButton *)createButtonText:(NSString *)text tag:(int)tag;
+ (UIButton *)createButton:(NSString *)title target:(id)target action:(SEL)selector;
+ (UIImage *)createImageWithColor:(UIColor *)color;
//处理网络不稳定，产生的异常消息<NSURLErrorDomain>
+ (NSString *)toolErrorMessage:(NSError *)error;

//角色判断
+ (BOOL)roleFromRoleStringIsRight:(NSString *)roleString;
+ (CCRole)roleFromRoleString:(NSString *)roleString;
//提示消息
+ (void)showMessage:(NSString *)msg;
+ (void)showMessageError:(NSError *)error;

+ (void)showTitle:(NSString *)title message:(NSString *)msg;
+ (void)showTitle:(NSString *)title message:(NSString *)msg sure:(NSString *)sure;

#pragma mark -- 助教相关
//房间是否存在助教
+ (BOOL)tool_roomHasAssistant;
+ (BOOL)tool_roomTeacherIsPublishing;
+ (BOOL)tool_roomCopyTIsPublishing;

+ (CCRoom *)tool_room;
+ (CCUser *)tool_room_user_userid:(NSString *)uid;
+ (CCUser *)tool_room_user_role:(CCRole)roleType;

//适配安全布局
+ (CGFloat)tool_MainWindowSafeArea_Top;
+ (CGFloat)tool_MainWindowIphoneXSafeArea_Top;

+ (CGFloat)tool_MainWindowSafeArea_Bottom;
+ (CGFloat)tool_MainWindowSafeArea_Left;
+ (CGFloat)tool_MainWindowSafeArea_Right;
+ (UIEdgeInsets)tool_MainWindowSafeArea;

/** 获取对应角色的auth类型 */
+ (NSString *)authTypeKeyForRole:(NSString *)role;
//时间转字符串
+ (NSString *)timerStringForTime:(NSTimeInterval)time;
//计算尺寸
+ (CGSize)getTitleSizeByFont:(NSString *)str font:(UIFont *)font;
+ (CGSize)getTitleSizeByFont:(NSString *)str width:(CGFloat)width font:(UIFont *)font;

@end
