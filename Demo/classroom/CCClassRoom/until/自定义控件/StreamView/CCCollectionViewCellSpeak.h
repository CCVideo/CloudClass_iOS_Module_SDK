//
//  CCCollectionViewCellSpeak.h
//  CCClassRoom
//
//  Created by cc on 17/5/22.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCLoadingView.h"

@interface CCCollectionViewCellSpeak : UICollectionViewCell
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) CCStreamView *info;
@property (strong, nonatomic) CCLoadingView *loadingView;
@property (strong, nonatomic) UIImageView *audioImageView;
/**
当前展示状态 0 - 全无，1-loading 2-只听音频 3-无效
*/
@property (assign, nonatomic) NSInteger loadStatus;

- (void)loadwith:(CCStreamView *)info showNameAtTop:(BOOL)top;
@end
