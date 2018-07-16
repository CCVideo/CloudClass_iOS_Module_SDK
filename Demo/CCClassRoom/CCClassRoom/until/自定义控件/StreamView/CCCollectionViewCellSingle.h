//
//  CCCollectionViewCellSingle.h
//  CCClassRoom
//
//  Created by cc on 17/4/19.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CCClassRoomBasic/CCClassRoomBasic.h>

@protocol CCCollectionViewCellSingleDelegate;

@interface CCCollectionViewCellSingle : UICollectionViewCell
@property (assign, nonatomic) id<CCCollectionViewCellSingleDelegate> delegate;
+ (CGFloat)getHeightWithWidth:(CGFloat)width showBtn:(BOOL)show isLandspace:(BOOL)isLandspace;
- (void)loadwith:(CCStreamView *)info showBtn:(BOOL)show;
@end

@protocol CCCollectionViewCellSingleDelegate <NSObject>

- (void)clickMicBtn:(UIButton *)btn info:(CCStreamView *)info;
- (void)clickPhoneBtn:(UIButton *)btn info:(CCStreamView *)info;
@end
