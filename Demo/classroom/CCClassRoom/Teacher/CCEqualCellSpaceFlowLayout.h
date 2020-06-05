//
//  CCEqualCellSpaceFlowLayout.h
//  CCClassRoom
//
//  Created by 刘强强 on 2019/9/25.
//  Copyright © 2019 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,AlignType){
//    AlignWithLeft,
//    AlignWithCenter,
    AlignWithRight
};
NS_ASSUME_NONNULL_BEGIN

@interface CCEqualCellSpaceFlowLayout : UICollectionViewFlowLayout
//两个Cell之间的距离
@property (nonatomic,assign)CGFloat betweenOfCell;
//cell对齐方式
@property (nonatomic,assign)AlignType cellType;

-(instancetype)initWthType : (AlignType)cellType;
//全能初始化方法 其他方式初始化最终都会�走到这里
-(instancetype)initWithType:(AlignType) cellType betweenOfCell:(CGFloat)betweenOfCell;
@end

NS_ASSUME_NONNULL_END
