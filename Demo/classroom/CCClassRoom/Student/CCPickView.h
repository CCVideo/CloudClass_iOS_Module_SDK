//
//  CCPickView.h
//  CCClassRoom
//
//  Created by Mac on 2019/8/10.
//  Copyright © 2019 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,HSPickerType) {
    HSPickerType_resolution,
    HSPickerType_mirror
};

NS_ASSUME_NONNULL_BEGIN

@interface CCPickView : UIView<UIPickerViewDelegate,UIPickerViewDataSource>
@property(nonatomic,assign)HSPickerType picktype;

- (void)setTitle:(NSString *)title;

@property (strong, nonatomic) NSArray *pickerViewData;
@property (assign, nonatomic) NSInteger pickerViewSelectedIndex;

@property(nonatomic,strong)CCStreamerBasic *stremer;
@property (nonatomic,copy) void(^CCPickViewSuccess)(CCPickView *removeView,NSInteger index ,NSString *text);
@property (nonatomic,copy) void(^CCPickViewCancle)(CCPickView *removeView);

- (instancetype)initWithFrame:(CGRect)frame;
- (void)showPickView;

@end

NS_ASSUME_NONNULL_END
