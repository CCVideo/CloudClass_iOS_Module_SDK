//
//  LiveViewController.h
//  NewCCDemo
//
//  Created by cc on 2016/11/23.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CCClassRoomBasic/CCClassRoomBasic.h>
#import "CCBaseViewController.h"

@interface CCLoginViewController : CCBaseViewController
@property (strong, nonatomic) NSString *roomID;
@property (strong, nonatomic) NSString *userID;
@property (assign, nonatomic) CCRole roleType;
@property (assign, nonatomic) BOOL needPassword;
@property (assign, nonatomic) BOOL isLandSpace;//是否横屏
@property (strong, nonatomic) NSArray *serverModels;

@end
