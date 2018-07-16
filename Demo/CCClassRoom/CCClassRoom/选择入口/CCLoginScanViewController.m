//
//  CCScanViewController.m
//  CCClassRoom
//
//  Created by cc on 17/1/22.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCLoginScanViewController.h"
#import "CCScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CCLoginViewController.h"

@interface CCLoginScanViewController ()
@property (strong, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation CCLoginScanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ScanSuccess:) name:@"ScanSuccess" object:nil];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    CFShow((__bridge CFTypeRef)(infoDictionary));
    NSString *app_build = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"V%@", app_build];
    
//    [self ScanSuccess:nil];
}

- (void)ScanSuccess:(NSNotification *)noti
{
    NSString *userId = noti.userInfo[@"userID"];
    NSString *roomId = noti.userInfo[@"roomID"];
    NSString *role = noti.userInfo[@"role"];
    
//    userId = @"83F203DAC2468694";
//    roomId = @"23804F8EBD3BB1F59C33DC5901307461";
        CCLoginViewController *liveVC = [[CCLoginViewController alloc] init];
        liveVC.needPassword = YES;
        SaveToUserDefaults(LIVE_ROOMID, roomId);
        liveVC.userID = userId;
        liveVC.roomID = roomId;
        [self.navigationController pushViewController:liveVC animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchScan:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
            case AVAuthorizationStatusNotDetermined:{
                // 许可对话没有出现，发起授权许可
                
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (granted) {
                            CCScanViewController *scanViewController = [[CCScanViewController alloc] initWithType:1];
                            [weakSelf.navigationController pushViewController:scanViewController animated:YES];
                        }else{
                            //用户拒绝
                            CCScanViewController *scanViewController = [[CCScanViewController alloc] initWithType:1];
                            [weakSelf.navigationController pushViewController:scanViewController animated:YES];
                        }
                    });
                }];
            }
            break;
            case AVAuthorizationStatusAuthorized:{
                // 已经开启授权，可继续
                dispatch_async(dispatch_get_main_queue(), ^{
                    CCScanViewController *scanViewController = [[CCScanViewController alloc] initWithType:1];
                    [weakSelf.navigationController pushViewController:scanViewController animated:YES];
                });
            }
            break;
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted: {
                // 用户明确地拒绝授权，或者相机设备无法访问
                dispatch_async(dispatch_get_main_queue(), ^{
                    CCScanViewController *scanViewController = [[CCScanViewController alloc] initWithType:1];
                    [weakSelf.navigationController pushViewController:scanViewController animated:YES];
                });
            }
            break;
        default:
            break;
    }
}

- (IBAction)touchCopu:(id)sender {
}
@end
