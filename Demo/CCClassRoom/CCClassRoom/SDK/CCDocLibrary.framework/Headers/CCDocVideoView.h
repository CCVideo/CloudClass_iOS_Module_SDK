//
//  CCDocPPTView.h
//  CCClassRoom
//
//  Created by cc on 18/7/3.
//  Copyright © 2018年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCDocLibrary.h"

@interface CCDocVideoView : UIView<CCStreamerBasicDelegate>

- (void)addBasicClient:(CCStreamerBasic *)basic;
- (void)startDocView;
//PPT动画展示
//初始化View
-(instancetype)initWithFrame:(CGRect)frame;
/** 设置frame */
- (void)setDocFrame:(CGRect)frame;
//添加监听
- (void)addObserverNotify;
//移除监听
- (void)removeObserverNotify;

//视频框
- (void)setPlayerFrame:(CGRect)playerFrame superView:(UIView *)showView;

//事件处理
- (void)onSocketReceive:(NSString *)event value:(id)object;


@end
