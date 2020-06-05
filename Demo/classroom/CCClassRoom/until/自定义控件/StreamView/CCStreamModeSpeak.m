//
//  CCStreamModeSpeak.m
//  CCClassRoom
//
//  Created by cc on 17/12/26.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCStreamModeSpeak.h"
#import <BlocksKit+UIKit.h>
#import "CCDocViewController.h"
#import "CCPlayViewController.h"
#import "AppDelegate.h"
#import "CCPushViewController.h"
#import "CCTeachCopyViewController.h"
#import "CCStreamerView.h"
#import <SDCycleScrollView.h>
#import "CCDocListViewController.h"
#import "CCDocSkipViewController.h"
#import "CCCollectionViewCellSpeak.h"
#import "CCUploadFile.h"
#import "CCDrawMenuView.h"
#import "CCEqualCellSpaceFlowLayout.h"

@interface CCStreamModeSpeak()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) UIImageView *backView;
@property (strong, nonatomic) UIButton *fullBtn;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (assign, nonatomic) BOOL isShow;//文档是否是全屏模式
@property (strong, nonatomic) UITapGestureRecognizer *docViewTapGes;//文档区域点击手势
@property (strong, nonatomic) UIButton *smallBtn;
@property (strong, nonatomic) UIButton *skipBtn;
@property (strong, nonatomic) UIView *progressView;
@property (strong, nonatomic) UIButton *backBtn;//后退按钮
@property (strong, nonatomic) UIButton *frontBtn;//前进按钮

@property (strong, nonatomic) NSMutableArray *dataArr;
///是否滚动过
@property(nonatomic, assign) BOOL isScroll;
///bgView中的麦克风view
@property(nonatomic, strong) UIImageView *audioImgView;
///bgView中的CCStreamView
@property (strong, nonatomic) CCStreamView *info;
///文档是否是全屏模式
@property (assign, nonatomic) BOOL isFullDoc;

@end

@implementation CCStreamModeSpeak
- (id)initWithLandspace:(BOOL)isLandSpace
{
    if (self = [super init])
    {
        self.isLandSpace = isLandSpace;
        self.isShow = YES;
        self.nowDocpage = -1;
        self.isScroll = NO;
        [self initUI];
        //        [self recoverDoc];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveSocketEvent object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiChangeDoc object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiDocSelectedPage object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiDelDoc object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiDocViewControllerClickSamll object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveProNoti:) name:CCNotiUploadFileProgress object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveDocChange object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceivePageChange object:nil];
        [self performSelector:@selector(startTimer) withObject:nil afterDelay:1.f];
    }
    return self;
}

- (void)initUI
{
    self.backView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    self.docView = [UIView new];
    self.docView.backgroundColor = [[UIColor alloc] initWithRed:1.f green:1.f blue:1.f alpha:0.2];
    self.docView.clipsToBounds = YES;
    
    if (!self.isLandSpace)
    {
        self.fullBtn = [UIButton new];
        [self.fullBtn setTitle:@"" forState:UIControlStateNormal];
        [self.fullBtn setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
        [self.fullBtn setImage:[UIImage imageNamed:@"fullscreen_touch"] forState:UIControlStateSelected];
        [self.fullBtn addTarget:self action:@selector(clickFull:) forControlEvents:UIControlEventTouchUpInside];
        
        self.skipBtn = [UIButton new];
        [self.skipBtn setTitle:@"" forState:UIControlStateNormal];
        [self.skipBtn setImage:[UIImage imageNamed:@"switch"] forState:UIControlStateNormal];
        [self.skipBtn setImage:[UIImage imageNamed:@"switch_touch"] forState:UIControlStateSelected];
        [self.skipBtn addTarget:self action:@selector(clickSkip:) forControlEvents:UIControlEventTouchUpInside];
        
        self.backBtn = [UIButton new];
        [self.backBtn setTitle:@"" forState:UIControlStateNormal];
        [self.backBtn setImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
        [self.backBtn setImage:[UIImage imageNamed:@"left_touch"] forState:UIControlStateSelected];
        [self.backBtn addTarget:self action:@selector(clickBack:) forControlEvents:UIControlEventTouchUpInside];
        
        self.frontBtn = [UIButton new];
        [self.frontBtn setTitle:@"" forState:UIControlStateNormal];
        [self.frontBtn setImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
        [self.frontBtn setImage:[UIImage imageNamed:@"right_touch"] forState:UIControlStateSelected];
        [self.frontBtn addTarget:self action:@selector(clickFront:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    _collectionView = ({
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        if (self.isLandSpace)
        {
            layout.itemSize = CGSizeMake(162.f, 92.f);
            layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        }
        else
        {
//            layout = [[CCEqualCellSpaceFlowLayout alloc] initWthType:AlignWithRight];
            
            layout.itemSize = CGSizeMake(92.f, 162.f);
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        }
        layout.minimumLineSpacing = 5.f;
        
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width,167) collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.scrollsToTop = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        [collectionView registerClass:[CCCollectionViewCellSpeak class] forCellWithReuseIdentifier:@"cell"];
        collectionView.contentInset = UIEdgeInsetsMake(0, 5.f, 0, 0.f);
        if (self.isLandSpace)
        {
            collectionView.alwaysBounceVertical = YES;
        }
        else
        {
//            collectionView.transform = CGAffineTransformIdentity;
//            collectionView.transform = CGAffineTransformMakeScale(-1, 1);
        }
        collectionView;
    });
    
    [self layoutIfNeeded];
    [self addSubview:self.backView];
    __weak typeof(self) weakSelf = self;
    [self.backView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf).offset(0.f);
    }];
    [self addSubview:self.docView];
    
    if (self.isLandSpace)
    {
        CGFloat height = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        height = height - [CCTool tool_MainWindowSafeArea_Bottom];
        CGFloat width = [UIScreen mainScreen].bounds.size.width;//height*16.f/9.f;
        CGFloat x = 0;//(MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) - width - [CCTool tool_MainWindowSafeArea_Left] - [CCTool tool_MainWindowSafeArea_Right])/2.f;

//        self.docView.frame = CGRectMake(x, 0, width, height);
        [self.docView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf).offset(0.f);
            make.left.equalTo(weakSelf).offset(x);
            make.width.mas_equalTo(width);
            make.bottom.equalTo(weakSelf).offset(0.f);
//            make.height.mas_equalTo(height);

        }];
        [[self hdsDocView] setDocFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - [CCTool tool_MainWindowSafeArea_Left] - [CCTool tool_MainWindowSafeArea_Right], [UIScreen mainScreen].bounds.size.height) displayMode:2];
    }
    else
    {
        CGFloat width = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
//        self.docView.frame = CGRectMake(0, 0, width, width*9.f/16.f);
        [self.docView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_equalTo(weakSelf).offset(0.f);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(width*9.f/16.f);

        }];
    }

    [self.docView addSubview:self.fullBtn];
    if (!self.isLandSpace)
    {
        [self.fullBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
            make.bottom.mas_equalTo(weakSelf.docView.mas_bottom).offset(-10.f);
        }];
        
        [self.docView addSubview:self.skipBtn];
        [self.skipBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.docView.mas_left).offset(CCGetRealFromPt(30));
            make.bottom.mas_equalTo(weakSelf.docView.mas_bottom).offset(-10.f);
        }];
        
        [self.docView addSubview:self.backBtn];
        [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(weakSelf.docView).offset(0.f);
            make.left.mas_equalTo(weakSelf.docView.mas_left).offset(CCGetRealFromPt(30));
        }];
        
        [self.docView addSubview:self.frontBtn];
        [self.frontBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(weakSelf.docView).offset(0.f);
            make.right.mas_equalTo(weakSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
        }];
    }
    
    [self addSubview:self.collectionView];
    if (self.isLandSpace)
    {
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf).offset(0.f);
            make.bottom.mas_equalTo(weakSelf).offset(0.f);
            make.top.mas_equalTo(weakSelf).offset(CCGetRealFromPt(80) + 35 + 10);
            make.width.mas_equalTo(167.f);
        }];
    }
    else
    {
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.left.mas_equalTo(weakSelf).offset(0.f);
//            make.left.mas_equalTo(weakSelf).offset(100);
            
            make.top.mas_equalTo(weakSelf.docView.mas_bottom).offset(5.f);
            make.height.mas_equalTo(167.f);
        }];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
    self.docViewTapGes = tap;
    [self.docView addGestureRecognizer:tap];

    
    //没有文档下部按钮和进度隐藏
    self.skipBtn.hidden = YES;
    //    self.fullBtn.hidden = YES;
    self.backBtn.hidden = YES;
    self.frontBtn.hidden = YES;
    [self bringSubviewToFront:self.fullBtn];
}


- (void)setRole:(CCStreamModeSpeakRole)role
{
    _role = role;
    if (_role == CCStreamModeSpeakRole_Teacher)
    {
//         [self recoverDoc];
    }
    else if(_role == CCStreamModeSpeakRole_Assistant)
    {
        
    }
    else if (_role == CCStreamModeSpeakRole_Student)
    {
        self.skipBtn.hidden = YES;
        self.backBtn.hidden = YES;
        self.frontBtn.hidden = YES;
    }
    else if(_role == CCStreamModeSpeakRole_Inspector)
    {
        //TODO 隐身者
        self.skipBtn.hidden = YES;
        self.backBtn.hidden = YES;
        self.frontBtn.hidden = YES;
    }
}


//这里也要好好测试下
- (void)assistantRecoverDoc:(NSString *)docID currentPage:(NSInteger)pageNum roomID:(NSString *)roomID step:(NSInteger)step
{
    //TODO...
    [[self hdsDocView] getRelatedRoomDocs:nil userID:nil
                                       docID:docID docName:nil pageNumber:0 pageSize:0 completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~%s__%@", __func__, info);
            if ([[info objectForKey:@"result"] isEqualToString:@"OK"])
            {
                NSDictionary *dic = info;
                NSString *picDomain = [dic objectForKey:@"picDomain"];
                NSArray *docArr = dic[@"docs"];
                NSDictionary *doc = [docArr lastObject];
                CCDoc *newDoc = [[CCDoc alloc] initWithDic:doc picDomain:picDomain];

                [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiChangeDoc object:nil userInfo:@{@"value":newDoc, @"page":@(pageNum), @"step":@(step), @"recover":@(YES)}];
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiChangeDoc object:nil userInfo:@{@"page":@(pageNum), @"step":@(step), @"recover":@(YES)}];
                self.skipBtn.hidden = YES;
                self.nowDoc = nil;
                self.frontBtn.hidden = YES;
                self.backBtn.hidden = YES;
            }
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiChangeDoc object:nil userInfo:@{@"page":@(pageNum), @"step":@(step), @"recover":@(YES)}];
            self.skipBtn.hidden = YES;
            self.nowDoc = nil;
            self.frontBtn.hidden = YES;
            self.backBtn.hidden = YES;
        }
    }];
}

- (void)recoverDoc
{
    NSString *roomID = GetFromUserDefaults(DOC_ROOMID);
    NSString *nowRoomID = GetFromUserDefaults(LIVE_ROOMID);
    NSInteger animationStep = [GetFromUserDefaults(DOC_ANIMATIONSTEP) integerValue];
    if (![roomID isEqualToString:nowRoomID])
    {
        //发送白板
//        [[CCDocManager sharedManager] docPageChange:-1 docID:@"WhiteBorad" fileName:@"WhiteBorad" totalPage:0 url:@"#"];
        return;
    }
    NSString *docID = GetFromUserDefaults(DOC_DOCID);
    NSInteger pageNum = [GetFromUserDefaults(DOC_DOCPAGE) integerValue];
    if (docID.length > 0 && pageNum >= 0)
    {
        //TODO..
        NSString *userId = GetFromUserDefaults(LIVE_USERID);
        [[self hdsDocView] getRelatedRoomDocs:roomID userID:userId docID:docID docName:nil pageNumber:0 pageSize:0 completion:^(BOOL result, NSError *error, id info) {
            if (result)
            {
                NSLog(@"%s__%@", __func__, info);
                NSDictionary *dic = info;
                NSString *picDomain = [dic objectForKey:@"picDomain"];
                NSDictionary *doc = [dic objectForKey:@"doc"];
                CCDoc *newDoc = [[CCDoc alloc] initWithDic:doc picDomain:picDomain];
                //                [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiChangeDoc object:nil userInfo:@{@"value":newDoc, @"page":@(pageNum)}];
                [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiChangeDoc object:nil userInfo:@{@"value":newDoc, @"page":@(pageNum), @"step":@(animationStep)}];
            }
        }];
    }
    else
    {
        //发送白板
//        [[CCDocManager sharedManager] docPageChange:-1 docID:@"WhiteBorad" fileName:@"WhiteBorad" totalPage:0 url:@"#"];
    }
}


- (void)viewDidAppear:(BOOL)autoHidden
{
    [self addBack];
}
//就是这里的问题导致的数据无法移除
#pragma mark 整理数据
- (void)exchangeDataArr{
    //1、将教师放到第一个位置。
    self.dataArr = [NSMutableArray arrayWithCapacity:10];
    if (self.data.count == 1) {
        self.dataArr = self.data;
    }else{
        for (int i=0; i<self.data.count; i++) {
            CCStreamView *view = [self.data objectAtIndex:i];
            if (_isLandSpace) {
                //横屏版
                if (view.stream.role == CCRole_Teacher || view.stream.role == CCRole_Assistant) {
                    if (self.dataArr.count > 0) {
                        //防止空数组插入崩溃
                        [self.dataArr insertObject:view atIndex:0];
                    }else {
                        
                        [self.dataArr addObject:view];
                    }
                }else{
                    
                    [self.dataArr addObject:view];
                }
                
            }else {
                ///竖屏版
                if (view.stream.role == CCRole_Teacher || view.stream.role == CCRole_Assistant) {
                    
                    [self.dataArr addObject:view];
//                    [self.dataArr insertObject:self.data[i] atIndex:0];
                }else{
//                    CCStreamView *viewLast = [self.dataArr lastObject];
//                    if ([viewLast.stream.streamID isEqualToString:view.stream.streamID]) {
//
//                        continue;
//                    }
                    if (self.dataArr.count > 0) {
                        
                        [self.dataArr insertObject:view atIndex:0];
                    }else {
                        [self.dataArr addObject:view];
                    }
//                    [self.dataArr addObject:self.data[i]];
                }
            }
            
        }
        //2、防止偶发情况下加载两个教师的视频。
//        if (_isLandSpace) {
//
//            CCStreamView *localInfo0 = self.dataArr[0];
//            CCStreamView *localInfo1 = self.dataArr[1];
//            if ([localInfo0.stream.streamID isEqualToString:localInfo1.stream.streamID]) {
//                [self.dataArr removeObjectAtIndex:1];
//                [self.data removeObjectAtIndex:1];
//            }
//        }
    }
    
    
}
///校验是否已存在
//-(BOOL)checkId:(CCStreamView *)view {
//
//    for (CCStreamView *tempView in self.dataArr) {
//        if ([view.stream.streamID isEqualToString:tempView.stream.streamID]) {
//
//            return YES;
//        }
//    }
//
//    return NO;
//}


#pragma mark 修改doc的通知  447行
- (void)receiveSocketEvent:(NSNotification *)noti
{
    if ([noti.name isEqualToString:CCNotiReceiveSocketEvent])
    {
        CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
        if (event == CCSocketEvent_PublishEnd)
        {
            UIViewController *vc = self.showVC.visibleViewController;
            if ([vc isKindOfClass:[CCDocViewController class]])
            {
                __weak typeof(self) weakSelf = self;
                [self clickFull:^(BOOL result, NSError *error, id info) {
                    [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(startTimer) object:nil];
                    CCStreamerView *streamView = (CCStreamerView *)weakSelf.superview;
                    [streamView stopTimer];
                }];
            }
            [self clickSmall:self.smallBtn];
            
            [self isShowFrontAndSkipAndBackBtn];
        }
        else if (event == CCSocketEvent_PublishStart)
        {
            CCRoom *room = [CCRoom shareRoomHDS];
            CCUser *user = [self getCurrentUser:room.user_id];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self speakPusherEventCCSocketEvent_ReciveAnssistantChange:user];
            });
        }
        else if (event == CCSocketEvent_ReciveAnssistantChange)
        {
            CCUser *user = noti.userInfo[@"user"];
            [self speakPusherEventCCSocketEvent_ReciveAnssistantChange:user];
        }
        else if (event == CCSocketEvent_DocPageChange)
        {
            @try {
                CCRoom *room = [CCRoom shareRoomHDS];
                CCUser *user = [self getCurrentUser:room.user_id];
                NSString *userID = [CCStreamerBasic sharedStreamer].getRoomInfo.user_id;
                if ([user.user_id isEqualToString:userID])
                {
                    BOOL userAuth = user.user_AssistantState;
                    NSDictionary *docDic = noti.userInfo[@"value"][@"value"];
                    
                    UIViewController *vc = self.showVC.visibleViewController;
                    if ([vc isKindOfClass:[CCDocViewController class]])
                    {
                        self.frontBtn.hidden = YES;
                        self.backBtn.hidden = YES;
                        self.skipBtn.hidden = YES;
                    }
                    else
                    {
                        ///半屏幕
                        if ((userAuth || user.user_role == CCRole_Teacher || user.user_role == CCRole_Assistant) && [docDic[@"totalPage"] intValue] > 1)
                        {
                            self.frontBtn.hidden = NO;
                            self.backBtn.hidden = NO;
                            self.skipBtn.hidden = NO;
                        }
                        else
                        {
                            self.frontBtn.hidden = YES;
                            self.backBtn.hidden = YES;
                            self.skipBtn.hidden = YES;
                        }
                    }
                    
                    
                }
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            
        }
        else if (event == CCSocketEvent_ReciveInterCutAudioOrVideo)
        {
            return;
            //Mark 视频暂停标注问题。。。Remove
            NSDictionary *dicResult = [noti userInfo];
            NSDictionary *par = dicResult[@"value"];
            NSString *action = par[@"action"];
            NSString *type = par[@"type"];
            NSString *handler = par[@"handler"];
            //处理视频暂停播放状态，横屏隐藏老师直播框
            if ([action isEqualToString:@"avMedia"] && [type isEqualToString:@"videoMedia"]) {
                if ([handler isEqualToString:@"play"])
                {
                    if (self.isLandSpace)
                    {
                        [self hideOrShowVideo:NO];
                    }
                }
                if ([handler isEqualToString:@"pause"])
                {
                    if (self.isLandSpace)
                    {
                        [self hideOrShowVideo:YES];
                    }
                }
            }
        }
    }
    //此处为了获取相应的图片的URL，然后进行加载哦，打印URL
    else if ([noti.name isEqualToString:CCNotiChangeDoc])
    {
        self.nowDoc = noti.userInfo[@"value"];
        if (!self.nowDoc)
        {
            return;
        }
        BOOL recover = [[noti.userInfo objectForKey:@"recover"] boolValue];
        NSInteger step = 0;
        step = [[noti.userInfo objectForKey:@"step"] integerValue];
        if (self.nowDoc)
        {
            NSMutableArray *urls = [NSMutableArray arrayWithCapacity:self.nowDoc.pageSize];
            for (int i = 0; i < self.nowDoc.pageSize; i++)
            {
            //getDocUrlString 获取文档每页地址
//                NSString *url = [self.nowDoc getPicUrl:i];
                NSString *url = [self.nowDoc getDocUrlString:i];
                [urls addObject:url];
            }
            
            NSLog(@"~~~~~~~~~~~~~要展示的文档的地址数组URL：%@",urls);
            if (urls.count > 0)
            {
                //                self.fullBtn.hidden = NO;
                if (urls.count > 1)
                {
                    self.skipBtn.hidden = NO;
                    self.frontBtn.hidden = NO;
                    self.backBtn.hidden = NO;
                }
                else
                {
                    self.skipBtn.hidden = YES;
                    self.frontBtn.hidden = YES;
                    self.backBtn.hidden = YES;
                }

                self.nowDocpage = [noti.userInfo[@"page"] integerValue];
                [self skipToPage:self.nowDocpage];
                SaveToUserDefaults(DOC_ROOMID, self.nowDoc.roomID);
                SaveToUserDefaults(DOC_DOCPAGE, @(self.nowDocpage));
                SaveToUserDefaults(DOC_DOCID, self.nowDoc.docID);
            }
            else
            {
                self.skipBtn.hidden = YES;
                if (!self.isLandSpace)
                {
                    self.docViewTapGes.enabled = YES;
                }
                self.frontBtn.hidden = YES;
                self.backBtn.hidden = YES;
                //发送白板，这里应该发送白板
                [[HDSDocManager sharedDoc] clearAllDrawData];
                SaveToUserDefaults(DOC_DOCID, nil);
                SaveToUserDefaults(DOC_DOCPAGE, @(-1));
                SaveToUserDefaults(DOC_ROOMID, nil);
            }
        }
        else
        {
            self.skipBtn.hidden = YES;
            //            self.fullBtn.hidden = YES;
            self.frontBtn.hidden = YES;
            self.backBtn.hidden = YES;
        }
    }
    else if ([noti.name isEqualToString:CCNotiDocSelectedPage])
    {
        NSInteger num = [noti.userInfo[@"value"] integerValue];
        self.nowDocpage = num;
        HDSDocManager *hdsM = [HDSDocManager sharedDoc];
        CCDoc *doc = [hdsM hdsCurrentDoc];
        [hdsM docSkip:doc toPage:self.nowDocpage];
        SaveToUserDefaults(DOC_DOCPAGE, @(num));
    }
    else if ([noti.name isEqualToString:CCNotiDelDoc])
    {
        CCDoc *delDoc = noti.userInfo[@"value"];
        if ([delDoc.docID isEqualToString:self.nowDoc.docID])
        {
            //要删除记录的数据 发送白板
            SaveToUserDefaults(DOC_DOCID, nil);
            SaveToUserDefaults(DOC_DOCPAGE, @(-1));
            SaveToUserDefaults(DOC_ROOMID, nil);
            if (!self.isLandSpace)
            {
                self.docViewTapGes.enabled = YES;
            }
            self.nowDoc = nil;
            self.nowDocpage = -1;
            self.skipBtn.hidden = YES;
            //            self.fullBtn.hidden = YES;
            self.frontBtn.hidden = YES;
            self.backBtn.hidden = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiDelCurrentShowDoc object:nil userInfo:nil];
        }
    }
    else if ([noti.name isEqualToString:CCNotiDocViewControllerClickSamll])
    {
        //文档点击取消全屏
        [self docChangeToSmall];
    }
//    else if ([noti.name isEqualToString:CCNotiReceiveDocChange])
//    {
//        NSString *docID = [noti.userInfo objectForKey:@"docID"];
//        NSInteger pageNum = [[noti.userInfo objectForKey:@"pageNum"] integerValue];
//        NSInteger step = [[noti.userInfo objectForKey:@"step"] integerValue];
//        NSString *roomID = [noti.userInfo objectForKey:@"roomid"];
//        [self assistantRecoverDoc:docID currentPage:pageNum roomID:roomID step:step];
//    }
    
#warning 接收白板的通知。
//    else if ([noti.name isEqualToString:CCNotiReceivePageChange])
//    {
//        NSString *docID = [noti.userInfo objectForKey:@"docID"];
//        if ([docID isEqualToString:self.nowDoc.docID])
//        {
//            NSInteger pageNum = [[noti.userInfo objectForKey:@"pageNum"] integerValue];
//            self.nowDocpage = pageNum;
//            [self skipToPage:pageNum];
//
//            UIViewController *visibleVC = self.showVC.visibleViewController;
//            if ([visibleVC isKindOfClass:[CCDocViewController class]])
//            {
//                CCDocViewController *docVC = (CCDocViewController *)visibleVC;
//                [docVC docPageChange];
//            }
//            else
//            {
//                for (UIViewController *vc in self.showVC.viewControllers)
//                {
//                    if ([vc isKindOfClass:[CCPlayViewController class]])
//                    {
//                        CCPlayViewController *playVC = (CCPlayViewController *)vc;
//                        [playVC docPageChange];
//                        break;
//                    }
//                    else if ([vc isKindOfClass:[CCPushViewController class]])
//                    {
//                        CCPushViewController *playVC = (CCPushViewController *)vc;
//                        [playVC docPageChange];
//                        break;
//                    }
//                }
//            }
//        }
//    }
}

//获取当前学员
- (CCUser *)getCurrentUser:(NSString *)uid
{
    NSArray *arrayUser = [CCRoom shareRoomHDS].room_userList;
    CCUser *userNew = nil;
    for (CCUser *user in arrayUser)
    {
        if ([user.user_id isEqualToString:uid])
        {
            userNew = user;
            break;
        }
    }
    return userNew;
}
- (void)speakPusherEventCCSocketEvent_ReciveAnssistantChange:(CCUser *)user
{
    NSString *userID = [CCStreamerBasic sharedStreamer].getRoomInfo.user_id;
    if ([user.user_id isEqualToString:userID])
    {
        BOOL userAuth = user.user_AssistantState;
        CCDoc *doc = [[HDSDocManager sharedDoc]hdsCurrentDoc];
        if (userAuth && doc.pageSize > 1 && !self.isFullDoc)
        {
            self.frontBtn.hidden = NO;
            self.backBtn.hidden = NO;
            self.skipBtn.hidden = NO;
        }
        else
        {
            self.frontBtn.hidden = YES;
            self.backBtn.hidden = YES;
            self.skipBtn.hidden = YES;
        }
    }
}



//- (void)docChangeToBig
//{
//    //全屏
//    //恢复
//    [self addBack];
//    if (!self.isLandSpace)
//    {
//        self.docViewTapGes.enabled = YES;
//    }
//    self.skipBtn.hidden = YES;
//    self.frontBtn.hidden = YES;
//    self.backBtn.hidden = YES;
//    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    appdelegate.shouldNeedLandscape = YES;
//    CCDocViewController *docVC = [[CCDocViewController alloc] initWithDocView:self.docView streamView:self.superview];
//    [self.showVC presentViewController:docVC animated:NO completion:^{
//        [self.fullBtn setImage:[UIImage imageNamed:@"exitfullscreen"] forState:UIControlStateNormal];
//        [self.fullBtn setImage:[UIImage imageNamed:@"exitfullscreen_touch"] forState:UIControlStateSelected];
//        [self skipToPage:self.nowDocpage];
//    }];
//}

#pragma mark - 被设为讲师
- (BOOL)user_teacher_copy
{
    NSString *userID = [CCStreamerBasic sharedStreamer].getRoomInfo.user_id;
    CCUser *user = [[CCStreamerBasic sharedStreamer] getUSerInfoWithUserID:userID];
    if (user && (user.user_AssistantState || user.user_role == CCRole_Teacher))
    {
        return YES;
    }
    return NO;
}

- (void)docChangeToSmall
{
    self.isFullDoc = NO;
    //半屏
    WS(weakSelf);
    if (!self.isLandSpace)
    {
        self.docViewTapGes.enabled = YES;
        [[HDSDocManager sharedDoc] beEditableCancel];
    }
    
    BOOL teacherCopy = [self user_teacher_copy];
    
    CCDoc *doc = [[HDSDocManager sharedDoc]hdsCurrentDoc];
    self.nowDoc = doc;
    if ((_role == CCStreamModeSpeakRole_Teacher || teacherCopy) && doc.pageSize > 1)
    {
        self.skipBtn.hidden = NO;
        self.frontBtn.hidden = NO;
        self.backBtn.hidden = NO;
    }else {
        self.skipBtn.hidden = YES;
        self.frontBtn.hidden = YES;
        self.backBtn.hidden = YES;
    }

    [self addSubview:self.docView];
    [self.docView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self).offset(0.f);
        make.height.mas_equalTo(self.mas_width).dividedBy(16.f/9.f);
    }];

    if (!_isLandSpace) {
        ///视屏版本才做这个'
        CGFloat width = 97*self.dataArr.count;
        if (width > SCREEN_WIDTH) {
            ///需要滚动,
            self.collectionView.scrollEnabled = YES;
            [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.left.mas_equalTo(self).offset(0.f);
                make.top.mas_equalTo(self.docView.mas_bottom).offset(5.f);
                make.height.mas_equalTo(167.f);
            }];
            
        }else {
            self.collectionView.scrollEnabled = NO;
            [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self).offset(0.f);
                make.width.mas_equalTo(width);
                make.top.mas_equalTo(self.docView.mas_bottom).offset(5.f);
                make.height.mas_equalTo(167.f);
            }];
            
        }
        
    }
    //        可以解决横竖屏切换时显示聊天区问题
//    for (UIViewController *viewc in self.showVC.viewControllers)
//    {
//        if ([viewc isKindOfClass:[CCPlayViewController class]])
//        {
//            CCPlayViewController *playVC = (CCPlayViewController *)viewc;
//            playVC.contentBtnView.hidden = NO;
//            playVC.topContentBtnView.hidden = NO;
//            playVC.tableView.hidden = NO;
//
//            break;
//        }else if ([viewc isKindOfClass:[CCPushViewController class]]){
//            CCPushViewController *pushVC = (CCPushViewController *)viewc;
//            pushVC.contentBtnView.hidden = NO;
//            pushVC.topContentBtnView.hidden = NO;
//            pushVC.tableView.hidden = NO;
//
//            break;
//        }
//
//    }
    
    //全屏转为半屏的时候，要考虑是不是有未开始上课图片
    UIView *backView = [self viewWithTag:SpeakModeStopBackViewTag];
    [self bringSubviewToFront:backView];
    
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.shouldNeedLandscape = NO;
    [self.showVC dismissViewControllerAnimated:NO completion:^{
        [weakSelf.fullBtn setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
        [weakSelf.fullBtn setImage:[UIImage imageNamed:@"fullscreen_touch"] forState:UIControlStateSelected];
        [weakSelf skipToPage:weakSelf.nowDocpage];
        //开启定时器自动隐藏
        [weakSelf startTimer];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[HDSDocManager sharedDoc]refreshDocFrame:1];
                if (!weakSelf.isFull)
                {
                    [weakSelf.collectionView reloadData];
                }
            });
        });
    }];
    [self isShowFrontAndSkipAndBackBtn];
}

- (void)clickFull:(CCComletionBlock)completion
{
    //跳转一个新横屏界面
    UIViewController *vc = self.showVC.visibleViewController;
    if ([vc isKindOfClass:[CCDocViewController class]])
    {
        //半屏
        __weak typeof(self) weakSelf = self;
        if (!self.isLandSpace)
        {
            self.docViewTapGes.enabled = YES;
        }
        if (self.nowDoc.pageSize > 1)
        {
            self.skipBtn.hidden = NO;
        }
        self.frontBtn.alpha = 1.f;
        self.backBtn.alpha = 1.f;
        self.skipBtn.alpha = 1.f;
        [self addSubview:self.docView];
        [self.docView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(self).offset(0.f);
            make.height.mas_equalTo(self.mas_width).dividedBy(16.f/9.f);
        }];
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.left.mas_equalTo(self).offset(0.f);
            make.top.mas_equalTo(self.docView.mas_bottom).offset(5.f);
            make.height.mas_equalTo(160.f);
        }];
   
        //全屏转为半屏的时候，要考虑是不是有未开始上课图片
        UIView *backView = [self viewWithTag:SpeakModeStopBackViewTag];
        [self bringSubviewToFront:backView];
        
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appdelegate.shouldNeedLandscape = NO;
        [self.showVC dismissViewControllerAnimated:NO completion:^{
            [weakSelf.fullBtn setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
            [weakSelf.fullBtn setImage:[UIImage imageNamed:@"fullscreen_touch"] forState:UIControlStateSelected];
            [weakSelf skipToPage:weakSelf.nowDocpage];
            //开启定时器自动隐藏
            [weakSelf startTimer];
            if (completion)
            {
                completion(YES, nil, nil);
            }
        }];
    }
    else
    {
        self.isFullDoc = YES;
        //全屏
        //恢复
        [self addBack];
        self.docViewTapGes.enabled = NO;
        self.skipBtn.hidden = YES;
        self.frontBtn.hidden = YES;
        self.backBtn.hidden = YES;
        
        //可以解决横竖屏切换时显示聊天区问题
        for (UIViewController *viewc in self.showVC.viewControllers)
        {
            if ([viewc isKindOfClass:[CCPlayViewController class]])
            {
                CCPlayViewController *playVC = (CCPlayViewController *)viewc;
                playVC.contentBtnView.hidden = YES;
                playVC.topContentBtnView.hidden = YES;
                [playVC hiddenChatView:YES];
                break;
            }else if ([viewc isKindOfClass:[CCPushViewController class]]){
                CCPushViewController *pushVC = (CCPushViewController *)viewc;
                pushVC.contentBtnView.hidden = YES;
                pushVC.topContentBtnView.hidden = YES;
                [pushVC  hiddenChatView:YES];
                break;
            }

        }

        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appdelegate.shouldNeedLandscape = YES;
        //这里传递的是CCStreamerView
        CCDocViewController *docVC = [[CCDocViewController alloc] initWithDocView:self.docView streamView:self.superview];
        docVC.modalPresentationStyle  = 0;
        [self.showVC presentViewController:docVC animated:NO completion:^{
            [self.fullBtn setImage:[UIImage imageNamed:@"exitfullscreen"] forState:UIControlStateNormal];
            [self.fullBtn setImage:[UIImage imageNamed:@"exitfullscreen_touch"] forState:UIControlStateSelected];
            [self skipToPage:self.nowDocpage];
        }];
        [self isShowFrontAndSkipAndBackBtn];
    }
}

//打印全部的view数据
- (void)showStreamView:(id)view
{
    if (!self.data)
    {
        self.data = [NSMutableArray array];
    }
    ///校验是否已存在
    BOOL isHave = NO;
    CCStreamView *tempView = view;
    NSLog(@"tempView.stream.streamID===%@",tempView.stream.streamID);
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
        
        [self.data addObject:view];
    }

    
    for (int i=0; i<self.data.count; i++)
    {
        CCStreamView *view = self.data[i];
        NSLog(@"~~~~~~~~~~~~~~教师学生ID：%@",view.stream.userID);
    }
    [self exchangeDataArr];

//    [self sortData];

    if (!self.isFull)
    {
        [self.collectionView reloadData];
    }
    if (!_isLandSpace) {
        ///竖屏版本才做这个'
        CGFloat width = 97*self.dataArr.count;
        if (width > SCREEN_WIDTH) {
            ///需要滚动,
            self.collectionView.scrollEnabled = YES;
            if ([self.docView.superview isKindOfClass:[self.collectionView.superview class]]) {
                
                [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.left.mas_equalTo(self).offset(0.f);
                    make.top.mas_equalTo(self.docView.mas_bottom).offset(5.f);
                    make.height.mas_equalTo(167.f);
                }];
            }
            if (!self.isScroll) {

                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];

            }

        }else {
            self.collectionView.scrollEnabled = NO;
            if ([self.docView.superview isKindOfClass:[self.collectionView.superview class]]) {
                
                [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(self).offset(0.f);
                    make.width.mas_equalTo(width);
                    make.top.mas_equalTo(self.docView.mas_bottom).offset(5.f);
                    make.height.mas_equalTo(167.f);
                }];
            }

        }

    }
    
    NSString *video_zoom = [CCStreamerBasic sharedStreamer].getRoomInfo.video_zoom;
    //如果是结束直播，就做个标记，下次再进入就执行变小。离开界面的时候删除。  结束通知
    if (video_zoom == nil || [video_zoom isEqualToString:@""]) {
        [self showStreamInDoc:@{@"type":@"small", @"streamid":video_zoom}];
        return;
    }
    
    if (video_zoom > 0 && ![video_zoom isEqualToString:self.streamShowInDoc.stream.streamID])
    {
        [self showStreamInDoc:@{@"type":@"big", @"streamid":video_zoom}];
        
        NSString *smallStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"PublishEnd"];
        if ([smallStr isEqualToString:@"small"]) {
            [self showStreamInDoc:@{@"type":@"small", @"streamid":video_zoom}];
        }
        
    }
    
}

- (void)sortData
{
    NSArray *localdata = [NSArray arrayWithArray:self.dataArr];
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

- (void)removeStreamView:(CCStreamView *)view
{
    SLog(@"%s__%d__%@", __func__, __LINE__, view.stream.streamID);
    if (view == nil) {
        //移除预览
        for (CCStreamView *localInfo in self.data)
        {
            if (localInfo.stream.type == CCStreamType_Local)
            {
                [self.dataArr removeObject:localInfo];
                [self.data removeObject:localInfo];
                
                [self.collectionView reloadData];
                break;
            }
        }
    }
    
    NSInteger i = 0;
    for (CCStreamView *localInfo in self.dataArr)
    {
        if ([localInfo.stream.streamID isEqualToString: view.stream.streamID] || view == localInfo)
        {
            [self.dataArr removeObject:localInfo];
            [self.data removeObject:localInfo];
            
            if (self.isFull)
            {
                if (i == self.fullInfoIndex)
                {
                    [self clickSmall:self.smallBtn];
                }
            }
            else
            {
                [self.collectionView reloadData];
            }
            break;
        }
        i++;
    }
    if ([view.stream.streamID isEqualToString:self.streamShowInDoc.stream.streamID])
    {
        //移除的stream是显示在文档区
        [self.streamShowInDoc removeFromSuperview];
        self.streamShowInDoc = nil;
    }
    if (!_isLandSpace) {
        ///视屏版本才做这个'
        CGFloat width = 97*self.dataArr.count;
        if (width > SCREEN_WIDTH) {
            ///需要滚动,
            self.collectionView.scrollEnabled = YES;
            if ([self.docView.superview isKindOfClass:[self.collectionView.superview class]]) {
                    
                [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.left.mas_equalTo(self).offset(0.f);
                    make.top.mas_equalTo(self.docView.mas_bottom).offset(5.f);
                    make.height.mas_equalTo(167.f);
                }];
            }
            
            if (!self.isScroll) {
                
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
                
            }
            
        }else {
            self.collectionView.scrollEnabled = NO;
            if ([self.docView.superview isKindOfClass:[self.collectionView.superview class]]) {
                
                [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(self).offset(0.f);
                    make.width.mas_equalTo(width);
                    make.top.mas_equalTo(self.docView.mas_bottom).offset(5.f);
                    make.height.mas_equalTo(167.f);
                }];
            }
        }
    }
}

- (void)removeStreamViewAll
{
    [self.data removeAllObjects];
    [self.dataArr removeAllObjects];
    [self.collectionView reloadData];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CCCollectionViewCellSpeak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell loadwith:self.dataArr[indexPath.item] showNameAtTop:NO];

    return cell;
     
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isScroll = YES;
}
#pragma mark 获取流状态
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s__%ld", __func__, (long)indexPath.item);
    NSLog(@"%s__%ld", __func__, (long)indexPath.row);
    XXLogSaveAPIPar(XXLogFuncLine, @{@"speak":@"响应点击"});
    @try {
        //这里采用的数据还是原数据，而显示的数据已经重新排列过了，所以导致错乱。
        CCStreamView *view = [self.dataArr objectAtIndex:indexPath.row];
        if (_role == CCStreamModeSpeakRole_Student || _role == CCStreamModeSpeakRole_Inspector) {
            XXLogSaveAPIPar(XXLogFuncLine, @{@"speak":@"开始放大1"});
            [self showMovieBig:indexPath];
        }
         else if (_role != CCStreamModeSpeakRole_Teacher)
        {
            XXLogSaveAPIPar(XXLogFuncLine, @{@"speak":@"操作框1"});
            [self clickedMovieTeacherOrAssistant:view indexPath:indexPath];
        }
        else
        {
            XXLogSaveAPIPar(XXLogFuncLine, @{@"speak":@"else判断"});
            CCUser *user3 = [[CCStreamerBasic sharedStreamer] getUSerInfoWithUserID:view.stream.userID];
            //用user3.user_id替换view.stream.userID
            if ([user3.user_id isEqualToString:[CCStreamerBasic sharedStreamer].getRoomInfo.user_id])
            {
                XXLogSaveAPIPar(XXLogFuncLine, @{@"speak":@"开始放大2"});
                [self showMovieBig:indexPath];
            }
            else
            {
                XXLogSaveAPIPar(XXLogFuncLine, @{@"speak":@"操作框1"});
                [self clickedMovieTeacherOrAssistant:view indexPath:indexPath];
            }
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

#pragma mark 崩溃点，老师、助教相互点击
- (void)clickedMovieTeacherOrAssistant:(CCStreamView *)videoView indexPath:(NSIndexPath *)indexPath
{
    CCUser *user3 = [[CCStreamerBasic sharedStreamer] getUSerInfoWithUserID:videoView.stream.userID];
//    NSDictionary *info = @{@"type":NSStringFromClass([self class]), @"userID":videoView.stream.userID, @"indexPath":indexPath};
    if (user3.user_id != nil) {
        
        NSDictionary *info = @{@"type":NSStringFromClass([self class]), @"userID":user3.user_id, @"indexPath":indexPath};
        [[NSNotificationCenter defaultCenter] postNotificationName:CLICKMOVIE object:nil userInfo:info];
    }
    
}

- (void)clickSmall:(UIButton *)btn
{
    self.isFull = NO;
    UIView *superView = btn.superview;
    [superView removeFromSuperview];
    
    [self.collectionView reloadData];

    for (UIViewController *viewc in self.showVC.viewControllers)
    {
        if ([viewc isKindOfClass:[CCPushViewController class]])
        {
            CCPushViewController *playVC = (CCPushViewController *)viewc;
            playVC.contentBtnView.hidden = NO;
            playVC.topContentBtnView.hidden = NO;
            [playVC hiddenChatView:NO];
            if ([[CCStreamerBasic sharedStreamer] getRoomInfo].room_template == CCRoomTemplateSingle)
            {
                playVC.fllowBtn.hidden = NO;
            }
            else
            {
                playVC.fllowBtn.hidden = YES;
            }
            break;
        }
        else if ([viewc isKindOfClass:[CCPlayViewController class]])
        {
            CCPlayViewController *playVC = (CCPlayViewController *)viewc;
            if (_role == CCStreamModeSpeakRole_Inspector) {
                playVC.contentBtnView.hidden = YES;
            }
            else
            {
                playVC.contentBtnView.hidden = NO;
            }
            playVC.topContentBtnView.hidden = NO;
            [playVC hiddenChatView:NO];
            break;
        }
        else if ([viewc isKindOfClass:[CCTeachCopyViewController class]])
        {
            CCTeachCopyViewController *playVC = (CCTeachCopyViewController *)viewc;
            playVC.contentBtnView.hidden = NO;
            playVC.topContentBtnView.hidden = NO;
            playVC.tableView.hidden = NO;
            if ([[CCStreamerBasic sharedStreamer] getRoomInfo].room_template == CCRoomTemplateSingle)
            {
                playVC.fllowBtn.hidden = NO;
            }
            else
            {
                playVC.fllowBtn.hidden = YES;
            }
            break;
        }
    }
}

#pragma mark - hideOrShowBtn
- (void)tapGes:(UITapGestureRecognizer *)ges
{
    //全屏转为半屏的时候，要考虑是不是有未开始上课图片
    UIView *backView = [self viewWithTag:SpeakModeStopBackViewTag];
    if (backView)
    {
        return;
    }
    
    for (UIViewController *viewc in self.showVC.viewControllers)
    {
        if ([viewc isKindOfClass:[CCPushViewController class]])
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //添加方崩溃机制
                @try {
                    [self teacherTapGes:(CCPushViewController *)viewc];
                } @catch (NSException *exception) {
                } @finally {
                }
            });
            break;
        }
        else if ([viewc isKindOfClass:[CCPlayViewController class]])
        {
            [self studentTapGes:(CCPlayViewController *)viewc];
            break;
        }
        else if ([viewc isKindOfClass:[CCTeachCopyViewController class]])
        {
            [self teacherCopyTapGes:(CCTeachCopyViewController *)viewc];
            break;
        }
    }
    
    self.isShow = !self.isShow;
    CCStreamerView *streamView = (CCStreamerView *)self.superview;
    [streamView stopTimer];
}

- (void)teacherCopyTapGes:(CCTeachCopyViewController *)playVC
{
    if (self.isShow)
    {
        __weak typeof(self) weakSelf = self;
        if (self.showVC.visibleViewController == playVC)
        {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        }
        [UIView animateWithDuration:0.2 animations:^{
            [playVC.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(playVC.view.mas_top).offset(0);
                make.left.mas_equalTo(playVC.view);
                make.right.mas_equalTo(playVC.view);
                make.height.mas_equalTo(35);
            }];
            [weakSelf.fullBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(weakSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
                make.top.mas_equalTo(weakSelf.docView.mas_bottom);
            }];
            [weakSelf.skipBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(weakSelf.docView.mas_left).offset(CCGetRealFromPt(30));
                make.top.mas_equalTo(weakSelf.docView.mas_bottom);
            }];
            if (weakSelf.isLandSpace)
            {
                [playVC.contentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.and.right.mas_equalTo(playVC.view);
                    make.top.mas_equalTo(playVC.view.mas_bottom);
                    make.height.mas_equalTo(CCGetRealFromPt(130));
                }];
                [playVC.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(playVC.view).offset(CCGetRealFromPt(30));
                    make.bottom.mas_equalTo(playVC.view);
                    make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
                }];
                [weakSelf.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(weakSelf).offset(0.f);
                    make.bottom.mas_equalTo(weakSelf).offset(0.f);
                    make.top.mas_equalTo(weakSelf).offset(20);
                    make.width.mas_equalTo(167.f);
                }];
                playVC.tableView.hidden = YES;
            }
            [playVC.view layoutIfNeeded];
            [weakSelf layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    }
    else
    {
        //显示
        if (![playVC isKindOfClass:[CCTeachCopyViewController class]])
        {
            return;
        }
        __weak typeof(self) weakSelf = self;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [UIView animateWithDuration:0.2 animations:^{
            [playVC.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.top.mas_equalTo(weakSelf).offset(CCGetRealFromPt(60));
                make.top.mas_equalTo(weakSelf).offset(Height_StatusBar);
                make.left.mas_equalTo(weakSelf).offset(0);
                make.right.mas_equalTo(weakSelf).offset(-0);
                make.height.mas_equalTo(35);
            }];
            [weakSelf.fullBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(weakSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
                make.bottom.mas_equalTo(weakSelf.docView.mas_bottom).offset(-10.f);
            }];
            [weakSelf.skipBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(weakSelf.docView.mas_left).offset(CCGetRealFromPt(30));
                make.bottom.mas_equalTo(weakSelf.docView.mas_bottom).offset(-10.f);
            }];
            if (weakSelf.isLandSpace)
            {
                [playVC.contentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.and.bottom.and.right.mas_equalTo(weakSelf);
                    make.height.mas_equalTo(CCGetRealFromPt(130));
                }];
                [playVC.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(weakSelf).offset(CCGetRealFromPt(30));
                    make.bottom.mas_equalTo(playVC.contentBtnView.mas_top);
                    make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
                }];
                [weakSelf.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(weakSelf).offset(0.f);
                    make.bottom.mas_equalTo(weakSelf).offset(0.f);
                    make.top.mas_equalTo(weakSelf).offset(CCGetRealFromPt(80) + 35 + 10);
                    make.width.mas_equalTo(167.f);
                }];
                playVC.tableView.hidden = NO;
            }
            [playVC.view layoutIfNeeded];
            [weakSelf layoutIfNeeded];
        } completion:^(BOOL finished) {
            [weakSelf startTimer];
        }];
    }
}

//8.15日  崩溃点应该在这里
- (void)teacherTapGes:(CCPushViewController *)playVC
{
        if (self.isShow)
        {
            __weak typeof(self) weakSelf = self;
            if (self.showVC.visibleViewController == playVC)
            {
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            }
            [UIView animateWithDuration:0.2 animations:^{
                if ([self isCurrentViewControllerVisible:playVC]) {
                    
                    [playVC.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.bottom.mas_equalTo(playVC.view.mas_top).offset(0.f);
                        make.left.mas_equalTo(weakSelf).offset(0);
                        make.right.mas_equalTo(weakSelf).offset(0);
                        make.height.mas_equalTo(35);
                    }];
                    [weakSelf.fullBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.right.mas_equalTo(weakSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
                        make.top.mas_equalTo(weakSelf.docView.mas_bottom);
                    }];
                    [weakSelf.skipBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_equalTo(weakSelf.docView.mas_left).offset(CCGetRealFromPt(30));
                        make.top.mas_equalTo(weakSelf.docView.mas_bottom);
                    }];
                    if (weakSelf.isLandSpace)
                    {
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
                        [weakSelf.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                            make.right.mas_equalTo(weakSelf).offset(0.f);
                            make.bottom.mas_equalTo(weakSelf).offset(0.f);
                            make.top.mas_equalTo(weakSelf).offset(20);
                            make.width.mas_equalTo(167.f);
                        }];
                        [playVC hiddenChatView:YES];
                    }
                }
                [playVC.view layoutIfNeeded];
                [weakSelf layoutIfNeeded];
            } completion:^(BOOL finished) {
            }];
        }
        else
        {
            //显示
            if (![playVC isKindOfClass:[CCPushViewController class]])
            {
                return;
            }
            __weak typeof(self) weakSelf = self;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            [UIView animateWithDuration:0.2 animations:^{
                __strong typeof(self) strongSelf = weakSelf;
                if ([self isCurrentViewControllerVisible:playVC]) {
                    
                    [playVC.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        //                make.top.mas_equalTo(weakSelf).offset(CCGetRealFromPt(60));
                        make.top.mas_equalTo(playVC.view).offset(Height_StatusBar);
                        make.left.mas_equalTo(strongSelf).offset(0);
                        make.right.mas_equalTo(strongSelf).offset(0);
                        make.height.mas_equalTo(35);
                    }];
                    [strongSelf.fullBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.right.mas_equalTo(strongSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
                        make.bottom.mas_equalTo(strongSelf.docView.mas_bottom).offset(-10.f);
                    }];
                    [strongSelf.skipBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_equalTo(strongSelf.docView.mas_left).offset(CCGetRealFromPt(30));
                        make.bottom.mas_equalTo(strongSelf.docView.mas_bottom).offset(-10.f);
                    }];
                    if (strongSelf.isLandSpace)
                    {
                        [playVC.contentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                            make.left.and.bottom.and.right.mas_equalTo(strongSelf);
                            make.height.mas_equalTo(CCGetRealFromPt(130));
                        }];
                        [playVC.chatView mas_remakeConstraints:^(MASConstraintMaker *make) {
                            make.left.mas_equalTo(strongSelf).offset(CCGetRealFromPt(30));
                            make.bottom.mas_equalTo(playVC.contentBtnView.mas_top);
                            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
                        }];
                        [strongSelf.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                            make.right.mas_equalTo(strongSelf).offset(0.f);
                            make.bottom.mas_equalTo(strongSelf).offset(0.f);
                            make.top.mas_equalTo(strongSelf).offset(CCGetRealFromPt(80) + 35 + 10);
                            make.width.mas_equalTo(167.f);
                        }];
                        [playVC hiddenChatView:NO];
                    }
                }
                [playVC.view layoutIfNeeded];
                [strongSelf layoutIfNeeded];
            } completion:^(BOOL finished) {
                [weakSelf startTimer];
            }];
        }
}

-(BOOL)isCurrentViewControllerVisible:(UIViewController *)viewController
{
    return (viewController.isViewLoaded && viewController.view.window);
}

- (void)studentTapGes:(CCPlayViewController *)playVC
{
    if (self.isShow)
    {
        //隐藏
        __weak typeof(self) weakSelf = self;
        if (self.showVC.visibleViewController == playVC)
        {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        }
        [UIView animateWithDuration:0.2 animations:^{
            [playVC.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(playVC.view.mas_top).offset(0.f );
                //                make.left.mas_equalTo(playVC.view);
                make.left.mas_equalTo(playVC.timerView.mas_right).offset(0.f);
                make.right.mas_equalTo(playVC.view);
                make.height.mas_equalTo(35);
            }];
            [weakSelf.fullBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(weakSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
                make.top.mas_equalTo(weakSelf.docView.mas_bottom);
            }];
            if (weakSelf.isLandSpace)
            {
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
                [weakSelf.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(weakSelf).offset(0.f);
                    make.bottom.mas_equalTo(weakSelf).offset(0.f);
                    make.top.mas_equalTo(weakSelf).offset(20);
                    make.width.mas_equalTo(162.f);
                }];
                [playVC hiddenChatView:YES];
            }
            [playVC.view layoutIfNeeded];
            [weakSelf layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    }
    else
    {
        //显示
        __weak typeof(self) weakSelf = self;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [UIView animateWithDuration:0.2 animations:^{
            [playVC.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.top.mas_equalTo(weakSelf).offset(CCGetRealFromPt(60));
                //                make.left.mas_equalTo(playVC.view);
                make.top.mas_equalTo(playVC.view).offset(Height_StatusBar);//[CCTool tool_MainWindowSafeArea_Top]
                make.left.mas_equalTo(playVC.timerView.mas_right).offset(0.f);
                make.right.mas_equalTo(weakSelf);
                make.height.mas_equalTo(35);
            }];
            [weakSelf.fullBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(weakSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
                make.bottom.mas_equalTo(weakSelf.docView.mas_bottom).offset(-10.f);
            }];
            if (weakSelf.isLandSpace)
            {
                [playVC.contentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.and.bottom.and.right.mas_equalTo(weakSelf);
                    make.height.mas_equalTo(CCGetRealFromPt(130));
                }];
                [playVC.chatView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(weakSelf).offset(CCGetRealFromPt(30));
                    make.bottom.mas_equalTo(playVC.contentBtnView.mas_top);
                    make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
                }];
                [weakSelf.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(weakSelf).offset(0.f);
                    make.bottom.mas_equalTo(weakSelf).offset(0.f);
                    make.top.mas_equalTo(weakSelf).offset(CCGetRealFromPt(80) + 35 + 10);
                    make.width.mas_equalTo(162.f);
                }];
                [playVC hiddenChatView:NO];
            }
            [playVC.view layoutIfNeeded];
            [weakSelf layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self startTimer];
        }];
    }
}

#pragma mark - auto hidden
- (void)addBack
{
    if (self.isFull)
    {
        [self clickSmall:self.smallBtn];
    }
    for (UIViewController *viewc in self.showVC.viewControllers)
    {
        if ([viewc isKindOfClass:[CCPushViewController class]])
        {
            @try {
                [self teacherAddBack:(CCPushViewController *)viewc];
            } @catch (NSException *exception) {
            } @finally {}
            
            break;
        }
        else if ([viewc isKindOfClass:[CCPlayViewController class]])
        {
            @try {
                [self studentAddBack:(CCPlayViewController *)viewc];
            } @catch (NSException *exception) {
            } @finally {}
            
            break;
        }
        else if ([viewc isKindOfClass:[CCTeachCopyViewController class]])
        {
            @try {
                [self teacherCopyAddBack:(CCTeachCopyViewController *)viewc];
            } @catch (NSException *exception) {
            } @finally {
            }
            
            break;
        }
    }
    if ([self.showVC.visibleViewController isKindOfClass:[CCDocViewController class]])
    {
        [self docChangeToSmall];
    }
    self.isShow = YES;
    self.isFull = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startTimer) object:nil];
    CCStreamerView *streamView = (CCStreamerView *)self.superview;
    [streamView stopTimer];
    
    [self isShowFrontAndSkipAndBackBtn];
}

-(void)isShowFrontAndSkipAndBackBtn
{
    CCRoom *room = [CCRoom shareRoomHDS];
    CCUser *user = [self getCurrentUser:room.user_id];
    CCDoc *doc = [[HDSDocManager sharedDoc]hdsCurrentDoc];
    
    if ((_role == CCStreamModeSpeakRole_Teacher || (user.user_AssistantState && !self.isFullDoc)) && doc.pageSize > 1)//[CCRoom shareRoomHDS].live_status == CCLiveStatus_Start
    {
        self.skipBtn.hidden = NO;
        self.frontBtn.hidden = NO;
        self.backBtn.hidden = NO;
    }else {
        
        self.skipBtn.hidden = YES;
        self.frontBtn.hidden = YES;
        self.backBtn.hidden = YES;
    }
    
}

- (void)teacherCopyAddBack:(CCTeachCopyViewController *)playVC
{
    __weak typeof(self) weakSelf = self;
    playVC.topContentBtnView.hidden = NO;
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
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
//    [UIView animateWithDuration:0.2 animations:^{
        [playVC.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {

            make.top.mas_equalTo(playVC.view).offset(Height_StatusBar);
            make.left.mas_equalTo(weakSelf);
            make.right.mas_equalTo(weakSelf);
            make.height.mas_equalTo(35);
        }];
        [weakSelf.fullBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
            make.bottom.mas_equalTo(weakSelf.docView.mas_bottom).offset(-10.f);
        }];
        [weakSelf.skipBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.docView.mas_left).offset(CCGetRealFromPt(30));
            make.bottom.mas_equalTo(weakSelf.docView.mas_bottom).offset(-10.f);
        }];
        if (weakSelf.isLandSpace)
        {
            [playVC.contentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.and.bottom.and.right.mas_equalTo(weakSelf);
                make.height.mas_equalTo(CCGetRealFromPt(130));
            }];
            [playVC.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(weakSelf).offset(CCGetRealFromPt(30));
                make.bottom.mas_equalTo(playVC.contentBtnView.mas_top);
                make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
            }];
            
            [weakSelf.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(weakSelf).offset(0.f);
                make.bottom.mas_equalTo(weakSelf).offset(0.f);
                make.top.mas_equalTo(weakSelf).offset(CCGetRealFromPt(80) + 35 + 10);
                make.width.mas_equalTo(167.f);
            }];
            playVC.tableView.hidden = NO;
        }
        [playVC.view layoutIfNeeded];
        [weakSelf layoutIfNeeded];
//    } completion:^(BOOL finished) {
        [weakSelf.collectionView reloadData];
//    }];
}

- (void)teacherAddBack:(CCPushViewController *)playVC
{
    __weak typeof(self) weakSelf = self;
    playVC.topContentBtnView.hidden = NO;
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
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
//    [UIView animateWithDuration:0.2 animations:^{
        [playVC.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {

            make.top.mas_equalTo(playVC.view).offset(Height_StatusBar);
            make.left.mas_equalTo(weakSelf);
            make.right.mas_equalTo(weakSelf);
            make.height.mas_equalTo(35);
        }];
        
        if ([self.docView.superview isKindOfClass:[self.fullBtn.superview class]]) {
            
            [weakSelf.fullBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(weakSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
                make.bottom.mas_equalTo(weakSelf.docView.mas_bottom).offset(-10.f);
            }];
            
        }
        if ([self.docView.superview isKindOfClass:[self.skipBtn.superview class]]) {
            
            [weakSelf.skipBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(weakSelf.docView.mas_left).offset(CCGetRealFromPt(30));
                make.bottom.mas_equalTo(weakSelf.docView.mas_bottom).offset(-10.f);
            }];
        }
        
        if (weakSelf.isLandSpace)
        {
            [playVC.contentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.mas_equalTo(weakSelf);
                make.bottom.mas_equalTo(weakSelf);
                make.height.mas_equalTo(CCGetRealFromPt(130));
            }];
            [playVC.chatView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(weakSelf).offset(CCGetRealFromPt(30));
                make.bottom.mas_equalTo(playVC.contentBtnView.mas_top);
                make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
            }];
            
            [weakSelf.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(weakSelf).offset(0.f);
                make.bottom.mas_equalTo(weakSelf).offset(0.f);
                make.top.mas_equalTo(weakSelf).offset(CCGetRealFromPt(80) + 35 + 10);
                make.width.mas_equalTo(167.f);
            }];
            [playVC hiddenChatView:NO];
        }
        [playVC.view layoutIfNeeded];
        [weakSelf layoutIfNeeded];
//    } completion:^(BOOL finished) {
    
    [weakSelf.collectionView reloadData];
//    }];
}

- (void)studentAddBack:(CCPlayViewController *)playVC
{
    __weak typeof(self) weakSelf = self;
    playVC.contentBtnView.hidden = NO;
    [playVC hiddenChatView:NO];
    playVC.topContentBtnView.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
//    [UIView animateWithDuration:0.2 animations:^{
        [playVC.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(weakSelf).offset(CCGetRealFromPt(60));
            make.top.mas_equalTo(playVC.view).offset(Height_StatusBar);
            //            make.left.mas_equalTo(playVC.view);
            make.left.mas_equalTo(playVC.timerView.mas_right).offset(0.f);
            make.right.mas_equalTo(weakSelf);
            make.height.mas_equalTo(35);
        }];
        if ([self.docView.superview isKindOfClass:[self.fullBtn.superview class]]) {
            
            [weakSelf.fullBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(weakSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
                make.bottom.mas_equalTo(weakSelf.docView.mas_bottom).offset(-10.f);
            }];
        }
        if (weakSelf.isLandSpace)
        {
            [playVC.contentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.and.bottom.and.right.mas_equalTo(weakSelf);
                make.height.mas_equalTo(CCGetRealFromPt(130));
            }];
            [playVC.chatView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(playVC.view).offset(CCGetRealFromPt(30));
                make.bottom.mas_equalTo(playVC.contentBtnView.mas_top);
                make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
            }];
            
            [weakSelf.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(weakSelf).offset(0.f);
                make.bottom.mas_equalTo(weakSelf).offset(0.f);
                make.top.mas_equalTo(weakSelf).offset(CCGetRealFromPt(80) + 35 + 10);
                make.width.mas_equalTo(162.f);
            }];
            [playVC hiddenChatView:NO];
        }
        [playVC.view layoutIfNeeded];
        [weakSelf layoutIfNeeded];
//    } completion:^(BOOL finished) {
        
//    }];
}

- (void)removeBack
{
    [self startTimer];
}

- (void)startTimer
{
    CCStreamerView *streamView = (CCStreamerView *)self.superview;
    [streamView startTimer];
}

- (void)fire
{
    if (self.isShow)
    {
        [self tapGes:nil];
    }
}

#pragma mark - click
- (void)skipToPage:(NSInteger)num
{
    if (num < 0 || self.nowDoc.pageSize <= 0)
    {
        return;
    }
    float progress = (num+1)/(float)self.nowDoc.pageSize;
}

- (void)clickSkip:(UIButton *)btn
{
    CCDoc *doc = [[HDSDocManager sharedDoc]hdsCurrentDoc];
    self.nowDoc = doc;
    
    CCDocSkipViewController *skipVc = [[CCDocSkipViewController alloc] init];
    skipVc.doc = self.nowDoc;
    [self.showVC pushViewController:skipVc animated:YES];
}

- (BOOL)clickBack:(UIButton *)btn
{
    BOOL result = [[HDSDocManager sharedDoc] pageToBack];
    if (result)
    {
        self.nowDocpage--;
    } else {
        //动画
    }
    return result;
}

- (BOOL)clickFront:(UIButton *)btn
{
    BOOL result =  [[HDSDocManager sharedDoc] pageToFront];
    if (result)
    {
        self.nowDocpage++;
    } else {
        
    }
    return result;
}

#pragma mark - upload file
#define ProBackViewTag 10001
#define ProFrontViewTag 10002
- (void)receiveProNoti:(NSNotification *)noti
{
    WS(ws);
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat pro = [[noti.userInfo objectForKey:@"pro"] floatValue];
        if (pro == 2)
        {
            [ws.progressView removeFromSuperview];
            ws.progressView = nil;
        }
        else
        {
            if (!ws.progressView)
            {
                UIView *backView = [[UIView alloc] initWithFrame:self.bounds];
                backView.backgroundColor = [[UIColor alloc] initWithRed:1.f green:1.f blue:1.f alpha:0.5];
                backView.userInteractionEnabled = NO;
                [ws addSubview:backView];
                WS(ws);
                [backView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.left.right.mas_equalTo(ws).offset(0.f);
                    make.height.mas_equalTo(ws.mas_width).dividedBy(16.f/9.f);
                }];
                
                UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [backView addSubview:activityView];
                [activityView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(backView).offset(0.f);
                }];
                [activityView startAnimating];
                
                UILabel *label = [UILabel new];
                label.text = @"文档正在准备中";
                label.font = [UIFont systemFontOfSize:FontSizeClass_16];
                label.textColor = CCRGBColor(86, 90, 98);
                [backView addSubview:label];
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(backView);
                    make.bottom.mas_equalTo(backView).offset(-12.f);
                }];
                
                ws.progressView = backView;
            }
            else
            {
            }
        }
    });
}

- (void)reloadData
{
    #pragma 2019年10月12日20:32:09
    if (_isFull == NO) {
        
        self.isFull = NO;
        UIView *superView = self.smallBtn.superview;
        [superView removeFromSuperview];
        
        [self.collectionView reloadData];
    }else {
        for (CCUser *user in [CCStreamerBasic sharedStreamer].getRoomInfo.room_userList)
        {
            if ([user.user_id isEqualToString:self.info.stream.userID])
            {
                if (user.user_audioState)
                {
                    self.audioImgView.image = [UIImage imageNamed:@"kaimai"];
                }
                else
                {
                    self.audioImgView.image = [UIImage imageNamed:@"guanmai"];
                }
                break;
            }
        }
    }
}

- (void)showMovieBig:(NSIndexPath *)indexPath
{
    @try {
        CCCollectionViewCellSpeak *cell = (CCCollectionViewCellSpeak *)[self.collectionView cellForItemAtIndexPath:indexPath];
        XXLogSaveAPIPar(XXLogFuncLine, @{@"speak":@"响应放大取cell"});
            if (cell)
            {
        //        黑流状态不允许方法
                XXLogSaveAPIPar(XXLogFuncLine, @{@"speak":@"响应放大已取到cell"});
                if (cell.loadStatus != 0)
                {
                    XXLogSaveAPIPar(XXLogFuncLine, @{@"speak":@"异常"});
                    return;
                }
                XXLogSaveAPIPar(XXLogFuncLine, @{@"speak":@"执行放大"});
                self.isFull = YES;
                self.fullInfoIndex = indexPath.item;
                if (!self.isShow)
                {
                    [self tapGes:nil];
                }
                UIButton *smallBtn = [UIButton new];
                [smallBtn setImage:[UIImage imageNamed:@"exitfullscreen"] forState:UIControlStateNormal];
                [smallBtn setImage:[UIImage imageNamed:@"exitfullscreen_touch"] forState:UIControlStateSelected];
                [smallBtn addTarget:self action:@selector(clickSmall:) forControlEvents:UIControlEventTouchUpInside];
                self.smallBtn = smallBtn;
                for (UIViewController *viewc in self.showVC.viewControllers)
                {
                    if ([viewc isKindOfClass:[CCPlayViewController class]])
                    {
                        CCPlayViewController *playVC = (CCPlayViewController *)viewc;
                        playVC.contentBtnView.hidden = YES;
                        playVC.topContentBtnView.hidden = YES;
                        [playVC hiddenChatView:YES];
                        break;
                    }
                }
                
                UIView *backView = [UIView new];
                cell.nameLabel.hidden = YES;
                UIView *info = cell.info;
                self.info = cell.info;
                UIView *oldView = info;
                oldView.backgroundColor = StreamColor;
                [backView addSubview:oldView];
                [backView addSubview:smallBtn];
                oldView.userInteractionEnabled = YES;
                
                self.audioImgView = [[UIImageView alloc] init];
                self.audioImgView.image = cell.audioImageView.image;
                [backView addSubview:self.audioImgView];
                
                
                UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
                [keyWindow addSubview:backView];
                [backView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(keyWindow);
                }];
                [oldView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(backView).offset(0.f);
                }];
                [smallBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(backView.mas_right).offset(-30.f);
                    make.bottom.mas_equalTo(backView.mas_bottom).offset(-30.f);
                }];
                [self.audioImgView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(backView);
                    make.bottom.equalTo(backView.mas_bottom).offset(-30);
                }];
            }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}

- (void)hideOrShowVideo:(BOOL)hidden
{
    self.collectionView.hidden = hidden;
}

- (void)disableTapGes:(BOOL)enable
{
    self.docViewTapGes.enabled = enable;
}

- (void)hideOrShowView:(BOOL)hidden
{
    [self tapGes:nil];
}

#pragma mark - draw
#pragma mark - showStreamInDoc
- (void)showStreamInDoc:(NSDictionary *)data
{
    NSString *type = [data objectForKey:@"type"];
    NSString *streamID = [data objectForKey:@"streamid"];
    if (type.length > 0 && streamID.length > 0)
    {
        if (self.isFull)
        {
            [self clickSmall:self.smallBtn];
        }
        if ([type isEqualToString:@"big"])
        {
            //放大
            for (CCStreamView *view in self.data)
            {
                if ([view.stream.streamID isEqualToString:streamID])
                {
                    //
                    if (self.streamShowInDoc)
                    {
                        [self.streamShowInDoc removeFromSuperview];

                        CCStreamView *localView = self.streamShowInDoc;
                        self.streamShowInDoc = nil;
                        //将原来的放回下部
                        CCStreamerView *streamerView = (CCStreamerView *)self.superview;
                        if (streamerView && !self.isLandSpace)
                        {
                            [streamerView changeVideoImageView:NO inView:localView];
                        }
                        [self showStreamView:localView];
                    }
                    [self removeStreamView:view];
                    self.streamShowInDoc = view;

                    CCStreamerView *streamerView = (CCStreamerView *)self.superview;
                    if (streamerView && !self.isLandSpace)
                    {
                        [streamerView changeVideoImageView:YES inView:self.streamShowInDoc];
                    }
                    [self.docView addSubview:self.streamShowInDoc];
                    WS(ws);
                    [self.streamShowInDoc mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.edges.mas_equalTo(ws.docView);
                        //                        make.top.left.right.mas_equalTo(ws).offset(0.f);
                        //                        make.height.mas_equalTo(ws.mas_width).dividedBy(16.f/9.f);
                    }];
                    break;
                }
            }
        }
        else
        {
            //缩小
            if ([self.streamShowInDoc.stream.streamID isEqualToString:streamID])
            {
                [self.streamShowInDoc removeFromSuperview];
                CCStreamerView *streamerView = (CCStreamerView *)self.superview;
                if (streamerView && !self.isLandSpace)
                {
                    [streamerView changeVideoImageView:NO inView:self.streamShowInDoc];
                }
                [self showStreamView:self.streamShowInDoc];
                self.streamShowInDoc = nil;
            }
        }
    }
}
#pragma mark -
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiReceiveSocketEvent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiChangeDoc object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiDelDoc object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiDocViewControllerClickSamll object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiUploadFileProgress object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiReceivePageChange object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiReceiveDocChange object:nil];
    CCStreamerView *streamView = (CCStreamerView *)self.superview;
    [streamView stopTimer];
    
    [self.data removeAllObjects];
    self.data = nil;
}

- (CCDocVideoView *)hdsDocView
{
    return [[HDSDocManager sharedDoc]hdsDocView];
}

@end
