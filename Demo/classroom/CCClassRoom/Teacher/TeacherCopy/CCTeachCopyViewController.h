//
//  CCTeachCopyViewController.h
//  CCClassRoom
//
//  Created by cc on 2018/9/25.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "CCBaseViewController.h"

@interface CCTeachCopyViewController : CCBaseViewController
- (id)initWithLandspace:(BOOL)landspace;

@property(nonatomic,copy)  NSString             *viewerId;
@property(nonatomic,copy)  NSString             *sessionId;

@property(nonatomic,strong) NSString            *roomID;

@property(nonatomic,strong)UIImageView          *contentBtnView;
@property(nonatomic,strong)UITableView          *tableView;
@property(nonatomic,strong)UIImageView          *topContentBtnView;
@property(nonatomic,strong)UIButton             *fllowBtn;
@property(nonatomic,assign)BOOL                  isLandSpace;
@property(nonatomic,assign)CCVideoOriMode       videoOriMode;
- (void)docPageChange;
//调整鲜花奖杯，聊天视图层次
- (void)changeKeyboardViewUp;
-(void)removeObserver;


@end
