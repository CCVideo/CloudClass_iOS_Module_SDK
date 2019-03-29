//
//  CCTool.m
//  CCClassRoom
//
//  Created by cc on 18/6/15.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "CCTool.h"
#import "AppDelegate.h"
@implementation CCTool
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

@end
