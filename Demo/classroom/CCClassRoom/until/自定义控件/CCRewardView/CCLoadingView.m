//
//  CCLoadingView.m
//  CCClassRoom
//
//  Created by cc on 2018/8/23.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "CCLoadingView.h"
#import "AppDelegate.h"
@interface CCLoadingView ()
@property (nonatomic, strong)UIActivityIndicatorView  *loadingView;
@property (strong, nonatomic) UILabel *tipGestureLabel;

@end

@implementation CCLoadingView

+ (instancetype)createLoadingView
{
    CCLoadingView *lv = [[CCLoadingView alloc]init];
    return lv;
}
+ (instancetype)createLoadingView:(NSString *)sid
{
    CCLoadingView *lv = [[CCLoadingView alloc]init];
    lv.sid = sid;
    return lv;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    [self addSubview:self.loadingView];

    __weak typeof(self)weakSelf = self;
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf);
        make.centerY.mas_equalTo(weakSelf);

    }];

}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIActivityIndicatorView *)loadingView
{
    if (!_loadingView)
    {
        _loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
        _loadingView.color = [UIColor whiteColor];
        _loadingView.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0.5];
        _loadingView.hidesWhenStopped = YES;
    }
    return _loadingView;
}

-  (UILabel *)tipGestureLabel {
    if (!_tipGestureLabel) {
        _tipGestureLabel = [[UILabel alloc]initWithFrame:CGRectMake(10 , CGRectGetHeight(self.frame) - 30, CGRectGetWidth(self.frame) - 20, 15)];
        _tipGestureLabel.text = _tipString;
        [_tipGestureLabel setTextColor:[UIColor whiteColor]];
        _tipGestureLabel.backgroundColor = [UIColor orangeColor];
        _tipGestureLabel.font = [UIFont systemFontOfSize:12];
        _tipGestureLabel.hidden = YES;
        _tipGestureLabel.textAlignment = NSTextAlignmentCenter;
        _tipGestureLabel.layer.cornerRadius = 15 / 2;
        _tipGestureLabel.layer.masksToBounds = YES;
    }
    return _tipGestureLabel;
}

- (void)setTipString:(NSString *)tipString {
    _tipString = tipString;
    if (_tipString) {
        [self addSubview:self.tipGestureLabel];
        __weak typeof(self)weakSelf = self;

        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (appdelegate.shouldNeedLandscape) {
            self.loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
            [self.loadingView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.edges.mas_equalTo(weakSelf);
                make.centerY.mas_equalTo(weakSelf).offset(-40);
            }];
            [self.tipGestureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf).offset(20);
                make.left.mas_equalTo(weakSelf.mas_left).offset(20);
                make.right.mas_equalTo(weakSelf.mas_right).offset(-20);
                make.height.mas_equalTo(15);
            }];
        }
         else
         {
            [self.tipGestureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf).offset(40);
                make.left.mas_equalTo(weakSelf.mas_left).offset(10);
                make.right.mas_equalTo(weakSelf.mas_right).offset(-10);
                make.height.mas_equalTo(15);
            }];
         }
    }
}

- (void)startLoading
{
    if (![self.loadingView isAnimating])
    {
        [self.loadingView startAnimating];
        self.tipGestureLabel.hidden = NO;
    }
}

- (void)stopLoading
{
    if ([self.loadingView isAnimating])
    {
        [self.loadingView stopAnimating];
    }
    self.tipGestureLabel.hidden = YES;
}

- (BOOL)isAnimating {
    return self.loadingView.isAnimating;
}
@end
