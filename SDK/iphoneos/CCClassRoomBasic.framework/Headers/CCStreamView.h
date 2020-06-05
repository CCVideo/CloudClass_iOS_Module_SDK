//
//  CCStreamView.h
//  CCStreamer
//
//  Created by cc on 17/2/18.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCStream.h"
#import <CCStreamLib/CCStreamLib.h>


/*!
 @brief  流视图
 */
@interface CCStreamView : UIView
/*!
 @brief  该视图对应流ID
 */
@property (strong, nonatomic, readonly) CCStream *stream;
/*!
 @brief  视频画面大小(动态的)
 */
@property (assign, nonatomic, readonly) CGSize videoViewSize;

@property (strong, nonatomic)UIView *videoView;

/**
流视图生成方法

@param stream 流
@param mode 渲染模式
@return 流视图
*/
- (id)initWithStream:(CCStream *)stream renderMode:(HDSRenderMode)mode;


@end
