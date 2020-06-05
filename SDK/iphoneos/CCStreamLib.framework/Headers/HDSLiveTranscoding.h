//
//  HDSLiveTranscoding.h
//  CCStreamLib
//
//  Created by Chenfy on 2020/3/25.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface  HDSLiveTranscodingUser : NSObject
@property (assign, nonatomic) NSUInteger uid;
@property (assign, nonatomic) CGRect rect;
@property (assign, nonatomic) NSInteger zOrder;

@end

@interface HDSLiveTranscoding : NSObject
@property (assign, nonatomic) CGSize size;
@property (copy, nonatomic) NSArray<HDSLiveTranscodingUser *> *_Nullable transcodingUsers;

@end

NS_ASSUME_NONNULL_END
