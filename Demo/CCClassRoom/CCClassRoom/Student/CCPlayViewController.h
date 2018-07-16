//
//  PushViewController.h
//  NewCCDemo
//
//  Created by cc on 2016/12/2.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CCClassRoomBasic/CCClassRoomBasic.h>
#import "CCBaseViewController.h"

@interface CCPlayViewController : CCBaseViewController
//userid
@property(nonatomic,copy)  NSString  *viewerId;
@property(nonatomic,strong)CCStreamerBasic *stremer;
@property(strong, nonatomic) NSDictionary *info;
@property(assign, nonatomic) BOOL isLandSpace;
@property(assign, nonatomic) AVCaptureDevicePosition cameraPosition;
@property(nonatomic,strong)CCStreamView         *preView;
@end
