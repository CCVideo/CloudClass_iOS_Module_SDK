//
//  CCStreamerModeTile.m
//  CCClassRoom
//
//  Created by cc on 17/4/10.
//  Copyright © 2017年 cc. All rights reserved.
//


#define TAG 10001

#import "CCStreamerModeTile.h"
#import "CCCollectionViewLayout.h"
#import "CCCollectionViewCellTile.h"
#import <CCClassRoomBasic/CCClassRoomBasic.h>
#import <BlocksKit+UIKit.h>
#import "CCPlayViewController.h"
#import "CCStreamShowView.h"

@interface CCStreamerModeTile()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CCCollectionViewCellSingleDelegate>
{
    
}
@property (strong, nonatomic) UIImageView *backView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *data;
//@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) BOOL isShow;
@property (strong, nonatomic) UILabel *noTeacherStreamLabel;//学生端，老师的流没有了，给出提示
@end

@implementation CCStreamerModeTile
- (id)init
{
    if (self = [super init])
    {
        self.isShow = YES;
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    self.noTeacherStreamLabel = [UILabel new];
    self.noTeacherStreamLabel.text = @"老师暂时离开了，请稍等";
    self.noTeacherStreamLabel.font = [UIFont systemFontOfSize:FontSizeClass_16];
    self.noTeacherStreamLabel.textColor = [UIColor whiteColor];
    self.noTeacherStreamLabel.layer.shadowColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.3f].CGColor;
    self.noTeacherStreamLabel.layer.shadowOffset = CGSizeMake(1, 1);
    self.noTeacherStreamLabel.textAlignment = NSTextAlignmentCenter;
    self.noTeacherStreamLabel.hidden = YES;
    [self addSubview:self.noTeacherStreamLabel];
    __weak typeof(self) weakSelf = self;
    [self.noTeacherStreamLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf);
    }];
    
    self.backView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    _collectionView = ({
        
        CCCollectionViewLayout *layout = [CCCollectionViewLayout new];
        layout.itemSize = CGSizeMake(90.f, 160.f);
        
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width,160) collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.scrollsToTop = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.scrollEnabled = NO;
        [collectionView registerClass:[CCCollectionViewCellTile class] forCellWithReuseIdentifier:@"cell"];
        collectionView;
    });
    
    [self addSubview:self.backView];
    [self.backView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf).offset(0.f);
    }];
   
    [self addSubview:self.collectionView];
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf).offset(0.f);
    }];
    [self.collectionView reloadData];
}

- (void)showStreamView:(CCStream *)view
{
    if (!self.data)
    {
        self.data = [NSMutableArray array];
    }
    if ([view isKindOfClass:[CCStream class]])
    {
        CCStreamView *showview = [[CCStreamView alloc] initWithStream:view];
        showview.frame = CGRectMake(0, 0, 90, 160);
        [self.data insertObject:showview atIndex:0];
    }
    else
    {
        [self.data insertObject:view atIndex:0];
    }
    [self.collectionView reloadData];
}

- (void)removeStreamViewByStreamID:(NSString *)streamID
{
    
    for (CCStreamView *localInfo in self.data)
    {
        if ([localInfo.stream.streamID isEqualToString:streamID])
        {
            [self.data removeObject:localInfo];
            [self.collectionView reloadData];
            break;
        }
    }
}

- (void)removeStreamView:(CCStream *)view
{
    if (view == nil)
    {
        //去除预览
        for (CCStreamView *localInfo in self.data)
        {
            if (localInfo.stream.type == CCStreamType_Local)
            {
                [self.data removeObject:localInfo];
                [self.collectionView reloadData];
                break;
            }
        }
    }
    else
    {
        for (CCStreamView *localInfo in self.data)
        {
            if ([localInfo.stream.streamID isEqualToString:view.streamID])
            {
                [self.data removeObject:localInfo];
                [self.collectionView reloadData];
                break;
            }
        }
    }
}
- (void)reloadData
{
    [self.collectionView reloadData];
}


- (void)layoutSubviews
{
    [self.collectionView reloadData];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    CCLog(@"%s__%d", __func__, __LINE__);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CCCollectionViewCellTile *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell loadwith:self.data[indexPath.item] showBtn:self.showBtn showNameLabel:self.data.count <= 1 ? NO : YES];
    cell.delegate = self;
//    cell.userInteractionEnabled = NO;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.data.count == 1)
    {
        return CGSizeMake(self.frame.size.width, self.frame.size.height);
    }
    else if (self.data.count <= 4)
    {
        return CGSizeMake(self.frame.size.width/2.f, self.frame.size.height/2.f);
    }
    else if (self.data.count <= 9)
    {
        return CGSizeMake(self.frame.size.width/3.f, self.frame.size.height/3.f);
    }
    else if (self.data.count <= 16)
    {
        return CGSizeMake(self.frame.size.width/4.f, self.frame.size.height/4.f);
    }
    else if (self.data.count <= 25)
    {
        return CGSizeMake(self.frame.size.width/5.f, self.frame.size.height/5.f);
    }
    else if (self.data.count <= 36)
    {
        return CGSizeMake(self.frame.size.width/6.f, self.frame.size.height/6.f);
    }
    else if (self.data.count <= 49)
    {
        return CGSizeMake(self.frame.size.width/7.f, self.frame.size.height/7.f);
    }
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCLog(@"%s__%d", __func__, __LINE__);
}

- (void)dealloc
{
    NSLog(@"%@__%s", NSStringFromClass([self class]), __func__);
//    if (self.timer)
//    {
//        [self.timer invalidate];
//        self.timer = nil;
//    }
    CCStreamShowView *streamView = (CCStreamShowView *)self.superview;
}
@end
