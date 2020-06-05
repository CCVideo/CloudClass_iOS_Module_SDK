//
//  CCStreamModeSingle.h
//  CCClassRoom
//
//  Created by cc on 17/4/10.
//  Copyright © 2017年 cc. All rights reserved.
//

//主视角模式
#import <UIKit/UIKit.h>

@interface CCStreamModeSingle : UIView
@property (strong, nonatomic) UINavigationController *showVC;
@property(nonatomic,assign)BOOL                  isLandSpace;
- (id)initWithLandspace:(BOOL)isLandSpace;
- (void)addBack;
- (void)removeBack;
- (NSString *)touchFllow;
- (void)showStreamView:(CCStreamView *)view;
- (void)removeStreamView:(CCStreamView *)view;
- (void)removeStreamViewAll;

- (void)fire;
- (void)reloadData;

- (void)changeTogBig:(NSIndexPath *)indexPath;
@end
