//
//  CCCollectionViewCellTile.h
//  CCClassRoom
//
//  Created by cc on 17/4/20.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCollectionViewCellSingle.h"

@interface CCCollectionViewCellTile : UICollectionViewCell
@property (weak, nonatomic) id<CCCollectionViewCellSingleDelegate> delegate;

- (void)loadwith:(CCStreamView *)info showAtTop:(BOOL)top;
@end
