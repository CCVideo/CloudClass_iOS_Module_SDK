//
//  CCEqualCellSpaceFlowLayout.m
//  CCClassRoom
//
//  Created by 刘强强 on 2019/9/25.
//  Copyright © 2019 cc. All rights reserved.
//

#import "CCEqualCellSpaceFlowLayout.h"

@interface CCEqualCellSpaceFlowLayout ()

@end

@implementation CCEqualCellSpaceFlowLayout
-(instancetype)init{
    return [self initWithType:AlignWithRight betweenOfCell:5.0];
}
-(void)setBetweenOfCell:(CGFloat)betweenOfCell{
    _betweenOfCell = betweenOfCell;
    self.minimumInteritemSpacing = betweenOfCell;
}
-(instancetype)initWthType:(AlignType)cellType{
    return [self initWithType:cellType betweenOfCell:5.0];
}
-(instancetype)initWithType:(AlignType)cellType betweenOfCell:(CGFloat)betweenOfCell{
    self = [super init];
    if (self){
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.minimumLineSpacing = 5;
        self.minimumInteritemSpacing = 5;
        self.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        _betweenOfCell = betweenOfCell;
        _cellType = cellType;
    }
    return self;
}
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray * layoutAttributes_t = [super layoutAttributesForElementsInRect:rect];
    NSArray * layoutAttributes = [[NSArray alloc]initWithArray:layoutAttributes_t copyItems:YES];
    //用来临时存放一行的Cell数组
    NSMutableArray * layoutAttributesTemp = [[NSMutableArray alloc]init];
    for (NSUInteger index = 0; index < layoutAttributes.count ; index++) {
        
        UICollectionViewLayoutAttributes *currentAttr = layoutAttributes[index]; // 当前cell的位置信息
        UICollectionViewLayoutAttributes *previousAttr = index == 0 ? nil : layoutAttributes[index-1]; // 上一个cell 的位置信
        UICollectionViewLayoutAttributes *nextAttr = index + 1 == layoutAttributes.count ?
        nil : layoutAttributes[index+1];//下一个cell 位置信息
        
        //加入临时数组
        [layoutAttributesTemp addObject:currentAttr];
        
        
        CGFloat previousY = previousAttr == nil ? 0 : CGRectGetMaxY(previousAttr.frame);
        CGFloat currentY = CGRectGetMaxY(currentAttr.frame);
        CGFloat nextY = nextAttr == nil ? 0 : CGRectGetMaxY(nextAttr.frame);
        //如果当前cell是单独一行
        if (currentY != previousY && currentY != nextY){
            if ([currentAttr.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
                [layoutAttributesTemp removeAllObjects];
                
            }else if ([currentAttr.representedElementKind isEqualToString:UICollectionElementKindSectionFooter]){
                [layoutAttributesTemp removeAllObjects];
                
            }else{
                [self setCellFrameWith:layoutAttributesTemp];
            }
        }
        //如果下一个cell在本行，这开始调整Frame位置
        else if( currentY != nextY) {
            [self setCellFrameWith:layoutAttributesTemp];
        }
    }
    return layoutAttributes;
}
//调整属于同一行的cell的位置frame
-(void)setCellFrameWith:(NSMutableArray*)layoutAttributes{

    CGFloat nowWidth = self.collectionView.frame.size.width - self.sectionInset.right;
    for (NSInteger index = layoutAttributes.count - 1 ; index >= 0 ; index-- ) {
        UICollectionViewLayoutAttributes * attributes = layoutAttributes[index];
        CGRect nowFrame = attributes.frame;
        
        nowFrame.origin.x = nowWidth - nowFrame.size.width;
        attributes.frame = nowFrame;
        nowWidth = nowWidth - nowFrame.size.width - _betweenOfCell;
    }
    
    [layoutAttributes removeAllObjects];
}
@end
