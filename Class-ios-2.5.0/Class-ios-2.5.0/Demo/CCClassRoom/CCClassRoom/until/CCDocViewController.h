//
//  CCDocViewController.h
//  CCClassRoom
//
//  Created by cc on 17/3/30.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCBaseViewController.h"
#import "CCStreamerView.h"
#define CCNotiDocViewControllerClickSamll @"CCNotiDocViewControllerClickSamll"


@interface CCDocViewController : CCBaseViewController
@property (strong, nonatomic) UIView *docView;
@property (strong, nonatomic) CCStreamerView *streamView;
- (id)initWithDocView:(UIView *)view streamView:(CCStreamerView *)streamView;
- (void)showOrHideDrawView:(BOOL)show calledByDraw:(BOOL)calledByDraw;
- (void)docPageChange;
@end
