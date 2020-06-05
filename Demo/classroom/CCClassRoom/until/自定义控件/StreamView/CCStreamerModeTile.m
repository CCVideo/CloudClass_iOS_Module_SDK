//
//  CCStreamerBasicModeTile.m
//  CCClassRoom
//
//  Created by cc on 17/4/10.
//  Copyright © 2017年 cc. All rights reserved.
//


#define TAG 10001

//#import "CCStreamerBasicModeTile.h"
#import "CCStreamerModeTile.h"

#import "CCCollectionViewLayout.h"
#import "CCCollectionViewCellTile.h"
//#import <CCClassRoom/CCClassRoom.h>
#import <BlocksKit+UIKit.h>
#import "CCPushViewController.h"
#import "CCTeachCopyViewController.h"
#import "CCPlayViewController.h"
//#import "CCStreamView.h"

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

//@implementation CCStreamerBasicModeTile
@implementation CCStreamerModeTile
- (id)init
{
    if (self = [super init])
    {
        self.isShow = YES;
        [self initUI];
         [self performSelector:@selector(startTimer) withObject:nil afterDelay:1.f];
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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
    [self.collectionView addGestureRecognizer:tap];
    CCRole role = [CCStreamerBasic sharedStreamer].getRoomInfo.user_role;
    if (role == CCRole_Teacher)
    {
        tap.enabled = NO;
    }
    else
    {
        tap.enabled = YES;
    }
    [self.collectionView reloadData];
    
//    [self bringSubviewToFront:self.noTeacherStreamLabel];
//    self.noTeacherStreamLabel.hidden = NO;
}

- (void)showStreamView:(id)view
{
    if (!self.data)
    {
        self.data = [NSMutableArray array];
    }
        
    if ([view isKindOfClass:[CCStream class]])
    {
        CCStream *viewTemp = (CCStream *)view;
        if (viewTemp.role == CCRole_Teacher) {

            CCStreamView *showview = [[CCStreamView alloc] initWithStream:viewTemp renderMode:[HDSDocManager sharedDoc].voidModel];
            showview.frame = CGRectMake(0, 0, 90, 160);
            //        [showview setCameraViewMirror:YES];
            ///校验是否已存在
            BOOL isHave = NO;
            
            NSInteger i = 0;
            for (CCStreamView *view in self.data) {
                if ([view.stream.streamID isEqualToString:showview.stream.streamID]) {
                    isHave = YES;
                    [self.data replaceObjectAtIndex:i withObject:showview];
                    break;
                }
                i ++;
            }
            if (!isHave) {
                [self.data insertObject:showview atIndex:0];
            }
        }else {
            CCStreamView *showview = [[CCStreamView alloc] initWithStream:viewTemp renderMode:[HDSDocManager sharedDoc].voidModel];
            showview.frame = CGRectMake(0, 0, 90, 160);
            //        [showview setCameraViewMirror:YES];
            ///校验是否已存在
            BOOL isHave = NO;
            
            NSInteger i = 0;
            for (CCStreamView *view in self.data) {
                if ([view.stream.streamID isEqualToString:showview.stream.streamID]) {
                    isHave = YES;
                    [self.data replaceObjectAtIndex:i withObject:showview];
                    break;
                }
                i ++;
            }
            
            if (!isHave) {
                
                [self.data addObject:showview];
            }
            
        }

    }
    else
    {
        if ([view isKindOfClass:[CCStreamView class]]) {
            CCStreamView *tempView = (CCStreamView *)view;
            if (tempView.stream.role == CCRole_Teacher) {
                ///校验是否已存在
                BOOL isHave = NO;
                
                NSInteger i = 0;
                for (CCStreamView *view in self.data) {
                    if ([view.stream.streamID isEqualToString:tempView.stream.streamID]) {
                        isHave = YES;
                        [self.data replaceObjectAtIndex:i withObject:tempView];
                        break;
                    }
                    i ++;
                }
                
                if (!isHave) {
                    if (self.data.count > 0) {
                        
                        [self.data insertObject:tempView atIndex:0];
                    }else {
                        [self.data addObject:tempView];

                    }
                }
                
            }else {
                ///校验是否已存在
               BOOL isHave = NO;
               
               NSInteger i = 0;
               for (CCStreamView *view in self.data) {
                   if ([view.stream.streamID isEqualToString:tempView.stream.streamID]) {
                       isHave = YES;
                       [self.data replaceObjectAtIndex:i withObject:tempView];
                       break;
                   }
                   i ++;
               }
               
               if (!isHave) {
                   
                   [self.data addObject:tempView];
               }
                
            }
        }

    }
    [self.collectionView reloadData];
}

- (NSInteger)sortByPublishTime:(NSDictionary *)info
{
    NSDictionary *otherInfo = info[@"otherInfo"];
    CCRole role = (CCRole)[otherInfo[@"role"] integerValue];
    if (role == CCRole_Teacher)
    {
        return 0;
    }
    else
    {
        
    }
    return 0;
}

- (void)sort:(BOOL)animated
{
    NSArray *localdata = [NSArray arrayWithArray:self.data];
    localdata = [localdata sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        CCStreamView *info1 = obj1;
        CCStreamView *info2 = obj2;
        NSArray *userInfos = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList;
        NSTimeInterval time1 = 0;
        NSTimeInterval time2 = 0;
        BOOL oneInUserList = NO;
        BOOL twoInUserList = NO;
        for (CCUser *localInfo in userInfos)
        {
            if ([localInfo.user_id isEqualToString: info1.stream.userID])
            {
                time1 = localInfo.user_publishTime;
                //自己预览的没有publishTime，默认排在最后边
                if (time1 == 0)
                {
                    time1 = [[NSDate date] timeIntervalSince1970];
                    time1 = floor(time1*1000);
                }
                
                CCRole role = localInfo.user_role;
                //老师的流默认排在第一位
                if (role == CCRole_Teacher)
                {
                    time1 = 0;
                }
                oneInUserList = YES;
            }
            if ([localInfo.user_id isEqualToString: info2.stream.userID])
            {
                time2 = localInfo.user_publishTime;
                //自己预览的没有publishTime，默认排在最后边
                if (time2 == 0)
                {
                    time2 = [[NSDate date] timeIntervalSince1970];
                    time2 = floor(time2*1000);
                }
                
                CCRole role = localInfo.user_role;
                //老师的流默认排在第一位
                if (role == CCRole_Teacher)
                {
                    time2 = 0;
                }
                twoInUserList = YES;
            }
        }
        if (!oneInUserList)
        {
            time1 = [[NSDate date] timeIntervalSince1970];
            time1 = floor(time1*1000);
        }
        if (!twoInUserList)
        {
            time2 = [[NSDate date] timeIntervalSince1970];
            time2 = floor(time2*1000);
        }
        return time1 < time2 ? NSOrderedAscending : NSOrderedDescending;
    }];
    self.data = [NSMutableArray arrayWithArray:localdata];
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
- (void)removeStreamViewAll
{
    [self.data removeAllObjects];
    [self.collectionView reloadData];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CCCollectionViewCellTile *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    BOOL showAtTop = self.data.count == 1 ? YES : NO;
    [cell loadwith:self.data[indexPath.item] showAtTop:showAtTop];
    
    cell.delegate = self;
    CCRole role = [CCStreamerBasic sharedStreamer].getRoomInfo.user_role;
    if (role == CCRole_Teacher)
    {
        cell.userInteractionEnabled = YES;
    }
    else
    {
        cell.userInteractionEnabled = NO;
    }
    
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
//    [self tapGes:nil];
    if ([CCStreamerBasic sharedStreamer].getRoomInfo.user_role == CCRole_Teacher)
    {
        CCStreamView *view = [self.data objectAtIndex:indexPath.item];
        if (![view.stream.userID isEqualToString:[CCStreamerBasic sharedStreamer].getRoomInfo.user_id])
        {
            NSDictionary *info = @{@"type":NSStringFromClass([self class]), @"userID":view.stream.userID, @"indexPath":indexPath};
            [[NSNotificationCenter defaultCenter] postNotificationName:CLICKMOVIE object:nil userInfo:info];
        }
    }
}

#pragma mark - cell delegate
- (void)clickMicBtn:(UIButton *)btn info:(CCStreamView *)info
{
    btn.selected = !btn.selected;
    NSString *userID = info.stream.userID;
    for (CCUser *user in [[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList)
    {
        if ([userID isEqualToString:user.user_id])
        {
            //设置音频状态
//            [[CCStreamerBasic sharedStreamer] setAudioOpened:!user.user_audioState userID:userID];
            
            //设置流音频状态  替换之前的方法
            [[CCStreamerBasic sharedStreamer] changeStream:info.stream audioState:!user.user_audioState completion:^(BOOL result, NSError *error, id info) {
                
            }];
            
        }
    }
}

- (void)clickPhoneBtn:(UIButton *)btn info:(CCStreamView *)info
{
    [UIAlertView bk_showAlertViewWithTitle:@"" message:@"确定挂断连麦?" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1)
        {
            NSString *userID = info.stream.userID;
//            [[CCStreamerBasic sharedStreamer] kickUserFromLianmai:userID completion:^(BOOL result, NSError *error, id info) {
//
//            }];
            [[CCBarleyManager sharedBarley] kickUserFromSpeak:userID completion:^(BOOL result, NSError *error, id info) {
                
            }];
        }
    }];
}

#pragma mark - method
#pragma mark - hidden btn
- (void)addBack
{
    UIViewController *vc;
    for (UIViewController *viewc in self.showVC.viewControllers)
    {
        if ([viewc isKindOfClass:[CCPushViewController class]] || [viewc isKindOfClass:[CCTeachCopyViewController class]] || [viewc isKindOfClass:[CCPlayViewController class]])
        {
            vc = viewc;
        }
    }
    if ([vc isKindOfClass:[CCPushViewController class]])
    {
        CCPushViewController *playVC = (CCPushViewController *)vc;
        if ([[CCStreamerBasic sharedStreamer] getRoomInfo].room_template == CCRoomTemplateSingle)
        {
            playVC.fllowBtn.hidden = NO;
        }
        else
        {
            playVC.fllowBtn.hidden = YES;
        }
        playVC.contentBtnView.hidden = NO;
        [playVC hiddenChatView:NO];
        playVC.topContentBtnView.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            [playVC.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                //              make.top.mas_equalTo(playVC.view).offset(CCGetRealFromPt(60));
                make.top.mas_equalTo(playVC.view).offset(Height_StatusBar);
                make.left.mas_equalTo(playVC.view);
                make.right.mas_equalTo(playVC.view);
                make.height.mas_equalTo(35);
            }];
            [playVC.contentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (Height_StatusBar > 20) {
                  
                    make.left.and.right.mas_equalTo(playVC.view).offset(0);
                    make.bottom.mas_equalTo(playVC.view).offset(-38);
                }else {
                    
                    make.left.and.bottom.and.right.mas_equalTo(playVC.view).offset(0);
                }
                make.height.mas_equalTo(CCGetRealFromPt(130));
            }];
            [playVC.chatView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(playVC.view).offset(CCGetRealFromPt(30));
                make.bottom.mas_equalTo(playVC.contentBtnView.mas_top);
                make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
            }];
            [playVC.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
        self.isShow = YES;
    }
    else if ([vc isKindOfClass:[CCTeachCopyViewController class]])
    {
        CCTeachCopyViewController *playVC = (CCTeachCopyViewController *)vc;
        if ([[CCStreamerBasic sharedStreamer] getRoomInfo].room_template == CCRoomTemplateSingle)
        {
            playVC.fllowBtn.hidden = NO;
        }
        else
        {
            playVC.fllowBtn.hidden = YES;
        }
        playVC.contentBtnView.hidden = NO;
        playVC.tableView.hidden = NO;
        playVC.topContentBtnView.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            [playVC.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.top.mas_equalTo(playVC.view).offset(CCGetRealFromPt(60));
                make.top.mas_equalTo(playVC.view).offset(Height_StatusBar);

                make.left.mas_equalTo(playVC.view);
                make.right.mas_equalTo(playVC.view);
                make.height.mas_equalTo(35);
            }];
            [playVC.contentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (Height_StatusBar > 20) {
                  
                    make.left.and.right.mas_equalTo(playVC.view).offset(0);
                    make.bottom.mas_equalTo(playVC.view).offset(-38);
                }else {
                    
                    make.left.and.bottom.and.right.mas_equalTo(playVC.view).offset(0);
                }
                make.height.mas_equalTo(CCGetRealFromPt(130));
            }];
            [playVC.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(playVC.view).offset(CCGetRealFromPt(30));
                make.bottom.mas_equalTo(playVC.contentBtnView.mas_top);
                make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
            }];
            [playVC.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
        self.isShow = YES;
    }
    else if ([vc isKindOfClass:[CCPlayViewController class]])
    {
        CCPlayViewController *playVC = (CCPlayViewController *)vc;
        playVC.contentBtnView.hidden = NO;
        [playVC hiddenChatView:NO];
        playVC.topContentBtnView.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            [playVC.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.top.mas_equalTo(playVC.view).offset(CCGetRealFromPt(60));
                make.top.mas_equalTo(playVC.view).offset(Height_StatusBar);
//                make.left.mas_equalTo(playVC.view);
                make.left.mas_equalTo(playVC.timerView.mas_right);
                make.right.mas_equalTo(playVC.view);
                make.height.mas_equalTo(35);
            }];
            [playVC.contentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (Height_StatusBar > 20) {
                  
                    make.left.and.right.mas_equalTo(playVC.view).offset(0);
                    make.bottom.mas_equalTo(playVC.view).offset(-38);
                }else {
                    
                    make.left.and.bottom.and.right.mas_equalTo(playVC.view).offset(0);
                }
                make.height.mas_equalTo(CCGetRealFromPt(130));
            }];
            [playVC.chatView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(playVC.view).offset(CCGetRealFromPt(30));
                make.bottom.mas_equalTo(playVC.contentBtnView.mas_top);
                make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
            }];
            [playVC.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
        self.isShow = YES;
    }
//    if (self.timer)
//    {
//        [self.timer invalidate];
//        self.timer = nil;
//    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startTimer) object:nil];
//    CCStreamerView *streamView = (CCStreamerView *)self.superview;
    CCStreamerView *streamView = (CCStreamerView *)self.superview;

    [streamView stopTimer];
}

- (void)removeBack
{
    [self startTimer];
}

- (void)startTimer
{
//    if (self.timer)
//    {
//        [self.timer invalidate];
//        self.timer = nil;
//    }
//    CCWeakProxy *weakProxy = [CCWeakProxy proxyWithTarget:self];
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.f target:weakProxy selector:@selector(fire) userInfo:nil repeats:NO];
    CCStreamerView *streamView = (CCStreamerView *)self.superview;
    [streamView startTimer];
}

- (void)fire
{
    CCRole role = [CCStreamerBasic sharedStreamer].getRoomInfo.user_role;
    if (role != CCRole_Teacher)
    {
        if (self.isShow)
        {
            [self tapGes:nil];
        }   
    }
}

- (void)tapGes:(UITapGestureRecognizer *)ges
{
    //全屏转为半屏的时候，要考虑是不是有未开始上课图片
    UIView *backView = [self viewWithTag:SpeakModeStopBackViewTag];
    if (backView)
    {
        return;
    }
    UIViewController *vc;
    for (UIViewController *viewc in self.showVC.viewControllers)
    {
        if ([viewc isKindOfClass:[CCPushViewController class]] || [viewc isKindOfClass:[CCPlayViewController class]] || [viewc isKindOfClass:[CCTeachCopyViewController class]])
        {
            vc = viewc;
        }
    }
    
    if (self.isShow)
    {
        //隐藏
        CCPushViewController *playVC = (CCPushViewController *)vc;
        if ([playVC isKindOfClass:[CCPushViewController class]] ||
            [playVC isKindOfClass:[CCTeachCopyViewController class]] ||
            [playVC isKindOfClass:[CCPlayViewController class]])
        {
            
            [UIView animateWithDuration:0.2 animations:^{
                [playVC.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.mas_equalTo(playVC.view.mas_top).offset(0.f);//(-(0.f + [CCTool tool_MainWindowSafeArea_Top]))
                    if ([playVC isKindOfClass:[CCPlayViewController class]])
                    {
                        CCPlayViewController *playVC = (CCPlayViewController *)vc;
                        make.left.mas_equalTo(playVC.timerView.mas_right);
                    }
                    else
                    {
                        make.left.mas_equalTo(playVC.view);
                    }
                    make.right.mas_equalTo(playVC.view);
                    make.height.mas_equalTo(35);
                }];
                [playVC.contentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.and.right.mas_equalTo(playVC.view);
                    make.top.mas_equalTo(playVC.view.mas_bottom);
                    make.height.mas_equalTo(CCGetRealFromPt(130));
                }];
                [playVC.chatView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(playVC.view).offset(CCGetRealFromPt(30));
                    make.bottom.mas_equalTo(playVC.view);
                    make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
                }];
                
                [playVC.view layoutIfNeeded];
            } completion:^(BOOL finished) {
            }];
        }
    }
    else
    {
        //显示
        CCPushViewController *playVC = (CCPushViewController *)vc;
        if ([playVC isKindOfClass:[CCPushViewController class]] ||
            [playVC isKindOfClass:[CCPlayViewController class]] ||
            [playVC isKindOfClass:[CCTeachCopyViewController class]])
        {
            [UIView animateWithDuration:0.2 animations:^{
                [playVC.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(playVC.view).offset(Height_StatusBar);//+ [CCTool tool_MainWindowSafeArea_Top]
//                    make.left.mas_equalTo(playVC.view);
                    if ([playVC isKindOfClass:[CCPlayViewController class]])
                    {
                        CCPlayViewController *playVC = (CCPlayViewController *)vc;
                        make.left.mas_equalTo(playVC.timerView.mas_right);
                    }
                    else
                    {
                        make.left.mas_equalTo(playVC.view);
                    }
                    make.right.mas_equalTo(playVC.view);
                    make.height.mas_equalTo(35);
                }];
                [playVC.contentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    if (Height_StatusBar > 20) {
                      
                        make.left.and.right.mas_equalTo(playVC.view).offset(0);
                        make.bottom.mas_equalTo(playVC.view).offset(-38);
                    }else {
                        
                        make.left.and.bottom.and.right.mas_equalTo(playVC.view).offset(0);
                    }
                    make.height.mas_equalTo(CCGetRealFromPt(130));
                }];
                [playVC.chatView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(playVC.view).offset(CCGetRealFromPt(30));
                    make.bottom.mas_equalTo(playVC.contentBtnView.mas_top);
                    make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
                }];
                [playVC.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                [self startTimer];
            }];
        }
    }
    self.isShow = !self.isShow;
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

- (void)dealloc
{
    NSLog(@"%@__%s", NSStringFromClass([self class]), __func__);
//    if (self.timer)
//    {
//        [self.timer invalidate];
//        self.timer = nil;
//    }
//    CCStreamerView *streamView = (CCStreamerView *)self.superview;
    CCStreamerView *streamView = (CCStreamerView *)self.superview;

    [streamView stopTimer];
    
    [self.data removeAllObjects];
    self.data = nil;
}
@end
