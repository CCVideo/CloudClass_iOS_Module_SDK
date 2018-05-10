//
//  CCStreamCheck.m
//  CCClassRoom
//
//  Created by cc on 17/12/18.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCStreamCheck.h"

@implementation CCStreamCheck
+ (instancetype)shared
{
    static CCStreamCheck *s_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[self alloc] init];
    });
    return s_instance;
}

- (void)addStream:(NSString *)stream role:(CCRole)role
{
    dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 10*NSEC_PER_SEC);
    NSLog(@"%s__%d__%@", __func__, __LINE__, stream);
    dispatch_after(time, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"%s__%d__%@", __func__, __LINE__, stream);
        [[CCStreamer sharedStreamer] getConnectionStats:stream completion:^(BOOL result, NSError *error, id info) {
            if (result)
            {
                CCConnectionStatus *status = info;
                NSLog(@"Date:%@", status.timeStamp);
                BOOL nilStream = YES;
                for (CCAudioReceiveStatus *rev in status.mediaChannelStats)
                {
                    if (rev.bytesReceived != 0)
                    {
                        nilStream = NO;
                    }
                }
                if (nilStream)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiStreamCheckNilStream object:nil userInfo:@{@"stream":stream, @"role":@(role)}];
                }
            }
        }];
        
    });
}
@end
