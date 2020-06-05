//
//  CCCollectionViewCellSingle.h
//  CCClassRoom
//
//  Created by cc on 17/4/19.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCCollectionViewCellSingleDelegate;

@interface CCCollectionViewCellSingle : UICollectionViewCell
@property (weak, nonatomic) id<CCCollectionViewCellSingleDelegate> delegate;
+ (CGFloat)getHeightWithWidth:(CGFloat)width showBtn:(BOOL)show isLandspace:(BOOL)isLandspace;
- (void)loadwith:(CCStreamView *)info showBtn:(BOOL)show showNameAtTop:(BOOL)top;
- (void)moveLabelToTop:(BOOL)top;
@end

@protocol CCCollectionViewCellSingleDelegate <NSObject>

- (void)clickMicBtn:(UIButton *)btn info:(CCStreamView *)info;
- (void)clickPhoneBtn:(UIButton *)btn info:(CCStreamView *)info;
@end
