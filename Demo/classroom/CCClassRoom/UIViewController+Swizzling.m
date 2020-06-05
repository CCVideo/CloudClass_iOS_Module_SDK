//
//  UIViewController+Swizzling.m
//  ChineseClass
//
//  Created by 张凯 on 2018/8/2.
//  Copyright © 2018年 jiulong zhou. All rights reserved.
//

#import "UIViewController+Swizzling.h"
#import <objc/runtime.h>//导入运行时库
#import "CCLoginViewController.h"
#import "CCPlayViewController.h"
@implementation UIViewController (Swizzling)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self methodSwizzlingWithOriginalSelector:@selector(viewWillAppear:) bySwizzledSelector:@selector(swizzledViewWillAppear:)];
     
    });
}

+ (void)methodSwizzlingWithOriginalSelector:(SEL)originalSelector bySwizzledSelector:(SEL)swizzledSelector{
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod = class_addMethod(class,originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
  
    if (didAddMethod) {
        class_replaceMethod(class,swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


#pragma mnark 这里是hook的方法
- (void)swizzledViewWillAppear:(BOOL)animated{
    [self swizzledViewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToLoginVC) name:NONETWORK object:nil];
}


#pragma mark 处理返回登录
- (void)backToLoginVC
{
    [self leaveTalkRoomCCPlayClearData];
}
- (void)leaveTalkRoomCCPlayClearData
{
    NSArray *temArray = [self currentViewController].navigationController.viewControllers;
    
    for(UIViewController *temVC in temArray)
    {
        if ([temVC isKindOfClass:[CCPlayViewController class]])
        {
            [[CCSpeaker shareSpeakerHDS] speakerDestory];
            [CCStreamerBasic sharedStreamer].localStreamID = @"";
            CCPlayViewController *playVC = (CCPlayViewController *)temVC;
            [playVC loginOutWithBack:NO];
            break;
        }
    }
    [self leaveTalkRoomBackToLoginVC];
}
- (void)leaveTalkRoomBackToLoginVC
{
    NSArray *temArray = [self currentViewController].navigationController.viewControllers;
    for(UIViewController *temVC in temArray)
    {
        if ([temVC isKindOfClass:[CCLoginViewController class]])
        {
            [[CCSpeaker shareSpeakerHDS] speakerDestory];
            [CCStreamerBasic sharedStreamer].localStreamID = @"";
            [self.navigationController popToViewController:temVC animated:YES];
            break;
        }
    }
}

-(UIViewController *)currentViewController{
    
    UIViewController * currVC = nil;
    UIViewController * Rootvc = [UIApplication sharedApplication].keyWindow.rootViewController ;
    do {
        if ([Rootvc isKindOfClass:[UINavigationController class]]) {
            UINavigationController * nav = (UINavigationController *)Rootvc;
            UIViewController * v = [nav.viewControllers lastObject];
            currVC = v;
            Rootvc = v.presentedViewController;
            continue;
        }else if([Rootvc isKindOfClass:[UITabBarController class]]){
            UITabBarController * tabVC = (UITabBarController *)Rootvc;
            currVC = tabVC;
            Rootvc = [tabVC.viewControllers objectAtIndex:tabVC.selectedIndex];
            continue;
        }
    } while (Rootvc!=nil);
    
    return currVC;
}


@end
