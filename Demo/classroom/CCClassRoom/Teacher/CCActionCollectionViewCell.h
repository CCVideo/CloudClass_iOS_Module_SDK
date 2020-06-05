//
//  CCActionCollectionViewCell.h
//  CCClassRoom
//
//  Created by cc on 17/10/23.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

//老师点击视频时显示的单个view尺寸（之前定义的50，由于显示不全加了5）
#define KEY_ITEM_WIDTH  50 + 5

@interface CCActionCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *label;
- (void)loadWith:(NSString *)imageName text:(NSString *)text;
@end
