//
//  CCSignManger.m
//  CCClassRoom
//
//  Created by cc on 17/4/26.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCSignManger.h"
#import <BlocksKit+UIKit.h>

@interface CCSignManger()
@property (assign, nonatomic) NSTimeInterval startTime;
@property (assign, nonatomic) NSTimeInterval endTime;
@property (assign, nonatomic) NSInteger   allCount;
@property (assign, nonatomic) NSInteger  signedCount;
@property (assign, nonatomic) NSTimer *timer;
@property (assign, nonatomic) BOOL startSign;
@end

@implementation CCSignManger
+(instancetype)sharedInstance
{
    static CCSignManger *s_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[self alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:s_instance selector:@selector(noti:) name:CCNotiReceiveSocketEvent object:nil];
    });
    return s_instance;
}

//判断点名列表是否包含某个角色
- (BOOL)roomNameHasRole:(NSString *)roleType
{
    NSDictionary *info = [[CCStreamerBasic sharedStreamer] getNamedInfo];
    NSArray *userList = info[@"userList"];
    for (NSDictionary *dic in userList)
    {
        NSString *role = dic[@"role"];
        if ([role isEqualToString:roleType])
        {
            return YES;
        }
    }
    return NO;
}

- (void)noti:(NSNotification *)noti
{
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    if (event == CCSocketEvent_StudentNamed)
    {
        self.signedCount = [[CCStreamerBasic sharedStreamer] getStudentNamedList].count;
        [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiStudentSignEd object:nil userInfo:nil];
    }
    else if (event == CCSocketEvent_TeacherNamedInfo)
    {
        //获取老师点名的信息getNamedInfo
        NSDictionary *info = [[CCStreamerBasic sharedStreamer] getNamedInfo];
        BOOL start = [[info objectForKey:@"allowRollcall"] boolValue];
//        BOOL start = NO;
        if (start)
        {
            NSArray *list = [info objectForKey:@"userList"];
            BOOL hasAssistant = [self roomNameHasRole:@"assistant"];
            BOOL hasTeacher = [self roomNameHasRole:@"presenter"];
            self.allCount = list.count;
            if (hasAssistant)
            {
                self.allCount -= 1;//除去老师
            }
            
            if (hasTeacher)
            {
                self.allCount -= 1;//除去老师
            }
            if (self.allCount <= 0)
            {
                [UIAlertView bk_showAlertViewWithTitle:@"" message:@"没有学生在线不能发起点名" cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                   [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiSignTimeChanged object:nil userInfo:@{@"value":@(-10)}];
                }];
            }
            else
            {
                self.startSign = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiSignStartSuccess object:nil userInfo:nil];
            }
        }
        else
        {
             [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiSignTimeChanged object:nil userInfo:@{@"value":@(-10)}];
        }
    }
    else if (event == CCSocketEvent_PublishEnd)
    {
        [self stop];
    }
}

- (void)startSign:(NSInteger)count time:(NSTimeInterval)time
{
    if ([[CCStreamerBasic sharedStreamer] getRoomInfo].live_status != CCLiveStatus_Start)
    {
        [UIAlertView bk_showAlertViewWithTitle:@"" message:@"没有开始直播不能发起点名" cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        }];
    }
    else
    {
        self.startTime = [[NSDate date] timeIntervalSince1970];
        self.endTime = time + self.startTime;
        self.allCount = count;
        self.signedCount = 0;
        if (self.timer)
        {
            [self.timer invalidate];
            self.timer = nil;
        }
        [[CCStreamerBasic sharedStreamer] startNamed:(self.endTime - self.startTime)];
        CCWeakProxy *weakProxy = [CCWeakProxy proxyWithTarget:self];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:weakProxy selector:@selector(timerFire) userInfo:nil repeats:YES];
    }
}

- (BOOL)isSignIng
{
//    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
//    if (now <= self.endTime || !self.reSelectedTime)
//    {
//        return YES;
//    }
//    return NO;
    
    return self.startSign;
}

- (void)reSelectedSignTime
{
    self.startSign = NO;
}

- (void)stop
{
    [self timeFire];
    self.startSign = NO;
    self.allCount = 0;
    self.signedCount = 0;
    if (self.timer)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (NSInteger)getAllCount
{
    return self.allCount;
}

- (NSInteger)getSignEdCount
{
    return self.signedCount;
}

- (NSInteger)getSpuerPlusTime
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    return self.endTime - now;
}

- (void)timerFire
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now > self.endTime)
    {
        [self.timer invalidate];
        self.timer = nil;
        [self timeFire];
        [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiSignTimeChanged object:nil userInfo:@{@"value":@(self.endTime - now)}];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiSignTimeChanged object:nil userInfo:@{@"value":@(self.endTime - now)}];
    }
}

- (void)timeFire
{
    self.startTime = 0;
    self.endTime = 0;
}

- (void)dealloc
{
    if (self.timer)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}
@end
