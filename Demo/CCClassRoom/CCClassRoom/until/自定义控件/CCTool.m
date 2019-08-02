//
//  CCTool.m
//  CCClassRoom
//
//  Created by cc on 18/6/15.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "CCTool.h"
#import "AppDelegate.h"
#import <UIAlertView+BlocksKit.h>

@interface CCTool()
@property(nonatomic,strong)LoadingView *loadingView;
@end

@implementation CCTool

static CCTool *_tool = nil;

+(id)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tool = [[CCTool alloc]init];
    });
    return _tool;
}

+ (void)loadingAddTo:(UIView *)view message:(NSString *)message
{
    if (!message || message.length == 0)
    {
        message = @"正在登录...";
    }
    CCTool *tool = [CCTool shareInstance];
    
    [self loadingRemove];
    dispatch_async(dispatch_get_main_queue(), ^{
        LoadingView *loadingView = [[LoadingView alloc] initWithLabel:message];
        [view addSubview:loadingView];
        tool.loadingView = loadingView;
        
        [loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
    });
}

+ (void)loadingRemove
{
    CCTool *tool = [CCTool shareInstance];
    if (!tool.loadingView)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [tool.loadingView removeFromSuperview];
    });
}

//创建label
+ (UILabel *)createLabelText:(NSString *)text
{
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.text = text;
    label.font = [UIFont systemFontOfSize:FontSizeClass_15];
    return label;
}

+ (UIButton *)createButtonText:(NSString *)text tag:(int)tag
{
    UIButton *btn = [UIButton new];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    btn.titleLabel.numberOfLines = 0;
    btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    
    if (tag != -1) {
        btn.tag = tag;
    }
    if (tag == -2) {
        UIImage *imageNormal = [self createImageWithColor:[UIColor lightGrayColor]];
        UIImage *imageSelect = [self createImageWithColor:[UIColor orangeColor]];
        
        [btn setBackgroundImage:imageNormal forState:UIControlStateNormal];
        [btn setBackgroundImage:imageSelect forState:UIControlStateSelected];
    }
    
    [btn setTitle:text forState:UIControlStateNormal];
    return btn;
}


+ (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 10, 10);  //图片尺寸
    
    UIGraphicsBeginImageContext(rect.size); //填充画笔
    
    CGContextRef context = UIGraphicsGetCurrentContext(); //根据所传颜色绘制
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGContextFillRect(context, rect); //联系显示区域
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext(); // 得到图片信息
    
    UIGraphicsEndImageContext(); //消除画笔
    
    return image;
}


+ (CGFloat)tool_MainWindowSafeArea_Top {
    if (@available(iOS 11.0, *)) {
        return [(UIWindow *)[UIApplication sharedApplication].delegate window].safeAreaInsets.top;
    } else {
        return 0;
    }
}

+ (CGFloat)tool_MainWindowSafeArea_Bottom {
    if (@available(iOS 11.0, *)) {
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (appdelegate.shouldNeedLandscape) {
            return [(UIWindow *)[UIApplication sharedApplication].delegate window].safeAreaInsets.left;
        } else {
            return [(UIWindow *)[UIApplication sharedApplication].delegate window].safeAreaInsets.bottom;
        }
    } else {
        return 0;
    }
}

+ (CGFloat)tool_MainWindowSafeArea_Left {
    if (@available(iOS 11.0, *)) {
        return [(UIWindow *)[UIApplication sharedApplication].delegate window].safeAreaInsets.left;
    } else {
        return 0;
    }
}

+ (CGFloat)tool_MainWindowSafeArea_Right {
    if (@available(iOS 11.0, *)) {
        return [(UIWindow *)[UIApplication sharedApplication].delegate window].safeAreaInsets.right;
    } else {
        return 0;
    }
}

/**
 *竖屏  top : 44.000000
 //    left : 0.000000
 //    bottom : 34.000000
 //    right : 0.000000
 *
 *横屏  top : 0.000000
 //    left : 44.000000
 //    bottom : 21.000000
 //    right : 44.000000
 */

+ (UIEdgeInsets)tool_MainWindowSafeArea {
    if (@available(iOS 11.0, *)) {
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (appdelegate.shouldNeedLandscape) {
            return UIEdgeInsetsMake(0, [CCTool tool_MainWindowSafeArea_Left], 0, [CCTool tool_MainWindowSafeArea_Right]);
        } else {
            return [(UIWindow *)[UIApplication sharedApplication].delegate window].safeAreaInsets;
        }
    } else {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

+ (UIWindow *)keyWindow
{
   UIWindow *kw = [[UIApplication sharedApplication]keyWindow];
    return kw;
}

+ (void)showToast:(NSString *)message
{
    NSLog(@"showToast_____:%@",message);
    CGRect frame = [[UIScreen mainScreen]bounds];
    UILabel *labelTips = [CCTool createLabelText:message];
    labelTips.frame = frame;
    labelTips.textAlignment = NSTextAlignmentCenter;
    labelTips.text = message;
    labelTips.backgroundColor = [UIColor blackColor];
    labelTips.textColor = [UIColor whiteColor];
    labelTips.alpha = 0.8;
    
    UIWindow *kw = [CCTool keyWindow];
    [kw addSubview:labelTips];
    
    [UIView animateWithDuration:2.0 animations:^{
        labelTips.alpha = 0;
    } completion:^(BOOL finished) {
        [labelTips removeFromSuperview];
    }];
}

#pragma mark --消息提示框
+ (void)showMessage:(NSString *)msg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"消息" message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
        [alert show];
    });
}

#pragma mark - show error
+ (void)showError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *mes = [NSString stringWithFormat:@"%@\n%@", @(error.code), error.domain];
        [UIAlertView bk_showAlertViewWithTitle:@"" message:mes cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
    });
}



@end
