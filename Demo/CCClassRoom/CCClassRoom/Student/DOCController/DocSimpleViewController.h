//
//  DocSimpleViewController.h
//  CCClassRoom
//
//  Created by cc on 18/7/13.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "CCBaseViewController.h"
#import <CCClassRoomBasic/CCClassRoomBasic.h>
#import <CCDocLibrary/CCDocLibrary.h>
#import "AppDelegate.h"
 
@interface DocSimpleViewController : CCBaseViewController
// 用户id 
@property (copy, nonatomic)NSString *user_id;
// 是否擦除所有
@property (assign, nonatomic)BOOL wipeAll;
//文档展示
@property(nonatomic,strong)CCDocVideoView  *ccVideoView;
//基础j依赖库
@property(nonatomic,strong)CCStreamerBasic *stremer;


@end
