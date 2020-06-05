//
//  HDSChatView.h
//  CCClassRoom
//
//  Created by Chenfy on 2019/12/24.
//  Copyright © 2019 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dialogue.h"
#import "CCPublicTableViewCell.h"
#import <Masonry.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSChatView : UIView
@property(nonatomic,assign)BOOL hasMessage;
@property(nonatomic,assign)BOOL isLandSpace;
@property(nonatomic,assign)BOOL currentIsInBottom;

@property(nonatomic,copy)NSString *viewerId;

#pragma mark -- 初始化
- (instancetype)initWithDataArray:(NSArray *)array;
- (instancetype)initWithDataArray:(NSArray *)array landspace:(BOOL)isLandSpace;
- (instancetype)initWithArray:(NSArray *)array landspace:(BOOL)isLandSpace viewid:(NSString *)vid;

- (void)chatReceiveMediaMessage:(NSDictionary *)dic;
- (void)chatReceiveChatMessage:(NSDictionary *)dic;

- (void)hiddenChatView:(BOOL)hidden;



@end

NS_ASSUME_NONNULL_END
