//
//  CCUser_PrivateHeader.h
//  CCStreamer
//
//  Created by cc on 17/5/19.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCUser.h"

@interface CCUser ()
@property (strong, nonatomic, readwrite) NSString *user_id;
@property (strong, nonatomic, readwrite) NSString *user_ip;
@property (strong, nonatomic, readwrite) NSString *user_name;
@property (assign, nonatomic, readwrite) CCUserPlatform user_platform;
@property (assign, nonatomic, readwrite) NSTimeInterval user_publishTime;
@property (assign, nonatomic, readwrite) NSTimeInterval user_requestTime;
@property (strong, nonatomic, readwrite) NSString *user_joinTime;
@property (assign, nonatomic, readwrite) CCRole user_role;
@property (strong, nonatomic, readwrite) NSString *user_socketID;
@property (assign, nonatomic, readwrite) CCUserMicStatus user_status;
@property (strong, nonatomic, readwrite) NSString *user_streamID;
@property (assign, nonatomic, readwrite) BOOL user_chatState;
@property (assign, nonatomic, readwrite) BOOL user_videoState;
@property (assign, nonatomic, readwrite) BOOL user_audioState;
@property (assign, nonatomic, readwrite) BOOL      user_drawState;
@property (assign, nonatomic, readwrite) BOOL rotateLocked;
@property (assign, nonatomic, readwrite) BOOL      handup;
@property (assign, nonatomic, readwrite) BOOL user_AssistantState;
- (id)initWithInfo:(NSDictionary *)dic;
@end
