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

//角色定义
#define KKEY_CCRole_Teacher         @"presenter"
#define KKEY_CCRole_Student         @"talker"
#define KKEY_CCRole_Watcher         @"audience"
#define KKEY_CCRole_Inspector       @"inspector"
#define KKEY_CCRole_Assistant       @"assistant"

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
    CCRole roleType = [self roleFromRoleString:role];
    
    CCLoginViewController *liveVC = [[CCLoginViewController alloc] init];
    liveVC.needPassword = YES;
    SaveToUserDefaults(LIVE_ROOMID, roomId);
    liveVC.userID = userId;
    liveVC.roomID = roomId;
    liveVC.roleType = roleType;
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

- (IBAction)touchCopu:(id)sender
{
    NSString *url = @"http://class.csslcloud.net/index/talker/?roomid=9370AFFBCE7888939C33DC5901307461&userid=83F203DAC2468694";
    [self parseCodeStrAfter:url];
}


-(void)parseCodeStrAfter:(NSString *)result
{
    NSLog(@"result = %@",result);
    NSURL *url = [NSURL URLWithString:result];
    NSString *host = url.host;
    
    CCStreamerBasic *basC = [CCStreamerBasic sharedStreamer];
    [basC setServerDomain:host area:nil];
    
    NSRange rangeRoomId = [result rangeOfString:@"roomid="];
    NSRange rangeUserId = [result rangeOfString:@"userid="];
    
    WS(ws)
    if (!StrNotEmpty(result) || rangeRoomId.location == NSNotFound || rangeUserId.location == NSNotFound)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"扫描错误" message:@"没有识别到有效的二维码信息" preferredStyle:(UIAlertControllerStyleAlert)];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        }];
        [alertController addAction:okAction];
        
        [ws presentViewController:alertController animated:YES completion:nil];
    } else {
        NSString *roomId = [result substringWithRange:NSMakeRange(rangeRoomId.location + rangeRoomId.length, rangeUserId.location - 1 - (rangeRoomId.location + rangeRoomId.length))];
        NSString *userId = @"";
        NSString *role = @"";
        
        userId = [result substringFromIndex:rangeUserId.location + rangeUserId.length];
        NSArray *slience = [result componentsSeparatedByString:@"/"];
        
        if (slience.count == 6)
        {
            role = slience[4];
        }
        NSLog(@"roomId = %@,userId = %@,slicence = %@",roomId,userId,slience);
        NSLog(@"roomId = %@,userId = %@",roomId,userId);
        SaveToUserDefaults(LIVE_USERID,userId);
        SaveToUserDefaults(LIVE_ROOMID,roomId);
        
        if (![role isEqualToString:@"talker"] && ![role isEqualToString:@"presenter"] && ![role isEqualToString:@"assistant"])
        {
            NSLog(@"CCLoginScanViewController------error!!");
            return;
        }
        
        NSDictionary *userInfo = @{@"userID":userId, @"roomID":roomId, @"role":role, @"authtype":@(0)};
        [ws.navigationController popViewControllerAnimated:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ScanSuccess" object:nil userInfo:userInfo];
    }
}


- (CCRole)roleFromRoleString:(NSString *)roleString
{
    if ([roleString isEqualToString:KKEY_CCRole_Teacher])
    {
        return CCRole_Teacher;
    }
    if ([roleString isEqualToString:KKEY_CCRole_Student])
    {
        return CCRole_Student;
    }
    if ([roleString isEqualToString:KKEY_CCRole_Watcher])
    {
        return CCRole_Watcher;
    }
    if ([roleString isEqualToString:KKEY_CCRole_Inspector])
    {
        return CCRole_Inspector;
    }
    if ([roleString isEqualToString:KKEY_CCRole_Assistant])
    {
        return CCRole_Assistant;
    }
    return 0;
}

@end
