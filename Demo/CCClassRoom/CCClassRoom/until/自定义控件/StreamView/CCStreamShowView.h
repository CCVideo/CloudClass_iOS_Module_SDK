//
//  CCStreamShowView.h
//  CCClassRoom
//
//  Created by cc on 17/2/22.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CCClassRoomBasic/CCClassRoomBasic.h>

#define SpeakModeStopBackViewTag 10005 
#define AudioImageViewTag 10010
#define VideoImageViewTag 10011
#define NOVideoImageViewTag 10012

@interface CCStreamShowView : UIView
- (void)configWithMode:(NSString *)mode;
@property (strong, nonatomic) UINavigationController *showVC;
@property (assign, nonatomic) BOOL showBtn;//学生端不需要显示btn
@property(nonatomic,assign)BOOL                  isLandSpace;

- (void)showStreamView:(CCStream *)view;
- (void)removeStreamView:(CCStream *)view;
- (void)removeStreamViewByStreamID:(NSString *)streamID;
- (void)reloadData;

@end

