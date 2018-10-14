//
//  CCStreamerModeTile.h
//  CCClassRoom
//
//  Created by cc on 17/4/10.
//  Copyright © 2017年 cc. All rights reserved.
//

//平铺模式  1个铺满 2~4个分成四份 4个以上分成九宫格

#import <UIKit/UIKit.h>
#import <CCClassRoomBasic/CCClassRoomBasic.h>

@interface CCStreamerModeTile : UIView
@property (strong, nonatomic) UINavigationController *showVC;
@property (assign, nonatomic) BOOL showBtn;//学生端不需要显示btn
- (void)showStreamView:(CCStream *)view;
- (void)removeStreamView:(CCStream *)view;
- (void)removeStreamViewByStreamID:(NSString *)streamID;
- (void)reloadData;
@end
