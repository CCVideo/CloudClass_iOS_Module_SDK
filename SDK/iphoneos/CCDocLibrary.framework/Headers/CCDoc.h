//
//  CCDoc.h
//  CCClassRoom
//
//  Created by cc on 17/4/24.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#pragma mark
#pragma mark --version 2.0
typedef NS_ENUM(NSInteger,CCDocLoadType) {
    CCDocLoadTypeLoading, //dp加载中
    CCDocLoadTypeComplete, //加载完成
    CCDocLoadTypeErrorDp, //dp加载失败
    CCDocLoadTypeErrorImage, //图片加载失败
    CCDocLoadTypeErrorAnimation, //动画加载失败
    CCDocLoadTypeErrorWB, //白板加载失败
    CCDocLoadTypeRetryFail  //重试后仍然失败
};
//文档加载回调
typedef void(^CCDocLoadBlock)(CCDocLoadType type ,CGFloat w ,CGFloat h ,id error);

@interface CCDoc : NSObject
@property (strong, nonatomic) NSString *docID;
@property (strong, nonatomic) NSString *docName;
@property (strong, nonatomic) NSString *md5;
@property (assign, nonatomic) NSInteger pageSize;
@property (strong, nonatomic) NSString *roomID;
@property (assign, nonatomic) BOOL useSDK;
@property (assign, nonatomic) float size;
@property (strong, nonatomic) NSString *picDomain;
@property (assign, nonatomic) BOOL isReleatedDoc;
@property (assign, nonatomic) long mode;
@property (assign, nonatomic) NSInteger status;

/** 初始化文档model */
- (id)initWithDic:(NSDictionary *)dic picDomain:(NSString *)domain;
/** 获取文档图标 */
- (NSString *)getDocIconAddress;
/** 获取文档每页地址 */
- (NSString *)getDocUrlString:(NSInteger)picNum;

@end
