//
//  CCCollectionViewCellTile.h
//  CCClassRoom
//
//  Created by cc on 17/4/20.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCollectionViewCellSingle.h"
#import <CCClassRoomBasic/CCClassRoomBasic.h>

@interface CCCollectionViewCellTile : UICollectionViewCell
@property (assign, nonatomic) id<CCCollectionViewCellSingleDelegate> delegate;
- (void)loadwith:(CCStreamView *)info showBtn:(BOOL)show showNameLabel:(BOOL)showLabel;
@end
