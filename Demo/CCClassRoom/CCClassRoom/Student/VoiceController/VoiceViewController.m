//
//  VoiceViewController.m
//  CCClassRoom
//
//  Created by cc on 2019/2/24.
//  Copyright © 2019年 cc. All rights reserved.
//

#import "VoiceViewController.h"
#import <CCClassRoomBasic/CCClassRoomBasic.h>

@interface VoiceViewController ()
@property(nonatomic,strong)UILabel *labelVoiceFB;
@property(nonatomic,strong)UILabel *labelVoice;
@property(nonatomic,strong)CALayer *layerVoice;

@property(nonatomic,strong)CCStreamerBasic *client;

@end

@implementation VoiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"音量展示";
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self initUI];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.client cancelListenMicVoice];
}
- (void)initUI
{
    [self.view addSubview:self.labelVoiceFB];
    [self.view addSubview:self.labelVoice];
    
    __weak typeof(self)ws = self;
    [self.client setListenOnMicVoice:^(BOOL result, NSError *error, id info) {
        /* level 范围[0 ~ 1], 转为[0 ~120] 之间 */
        NSInteger fb = [info integerValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            ws.layerVoice.frame = CGRectMake(0, 0, fb, 50);
            ws.labelVoiceFB.text = [NSString stringWithFormat:@"音量:%ld",(long)fb];
        });
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (CCStreamerBasic *)client
{
    return [CCStreamerBasic sharedStreamer];
}
- (UILabel *)labelVoice
{
    if (!_labelVoice)
    {
        _labelVoice = [[UILabel alloc]initWithFrame:CGRectMake(50, 150, 120, 50)];
        _labelVoice.backgroundColor = [UIColor orangeColor];
        
        self.layerVoice = [CALayer layer];
        self.layerVoice.backgroundColor = [[UIColor greenColor]CGColor];
        self.layerVoice.frame = _labelVoice.bounds;
        [_labelVoice.layer addSublayer:_layerVoice];
    }
    return _labelVoice;
}

- (UILabel *)labelVoiceFB
{
    if (!_labelVoiceFB)
    {
        _labelVoiceFB = [[UILabel alloc]initWithFrame:CGRectMake(50, 100, 120, 30)];
        _labelVoiceFB.backgroundColor = [UIColor lightGrayColor];
        _labelVoiceFB.textAlignment = NSTextAlignmentCenter;
    }
    return _labelVoiceFB;
}
@end
