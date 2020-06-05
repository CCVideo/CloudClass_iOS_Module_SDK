//
//  CCServerListViewController.m
//  CCClassRoom
//
//  Created by cc on 17/8/21.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCServerListViewController.h"
#import "CCLoginViewController.h"
#import "LoadingView.h"
#import "STDPingServices.h"
#import <UIAlertView+BlocksKit.h>

@interface CCServerTableViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UIImageView *selectedImageView;
- (void)reloadWithModel:(CCServerModel *)model;
@end

@implementation CCServerTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.nameLabel = [UILabel new];
        self.statusLabel = [UILabel new];
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
        self.statusLabel.hidden = YES;
        self.selectedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick"]];
        self.selectedImageView.hidden = YES;
        
        [self addSubview:self.nameLabel];
        [self addSubview:self.statusLabel];
        [self addSubview:self.selectedImageView];
        WS(ws);
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws).offset(15.f);
            make.centerY.mas_equalTo(ws);
            //                        make.right.mas_lessThanOrEqualTo(ws.statusLabel.mas_left).offset(-10.f);
        }];
        
        [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(ws);
        }];
        
        [self.selectedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws).offset(-10.f);
            make.centerY.mas_equalTo(ws);
        }];
    }
    return self;
}

- (void)reloadWithModel:(CCServerModel *)model
{
    BOOL  seleted = NO;
    NSString *domain = GetFromUserDefaults(SERVER_DOMAIN);
    NSString *domainName = GetFromUserDefaults(SERVER_DOMAIN_NAME);
    
    if (domain && [domain isEqualToString:model.serverDomain] && [domainName isEqualToString:model.serverName])
    {
        seleted = YES;
    }
    self.selectedImageView.hidden = !seleted;
    self.nameLabel.text = model.serverName;
    //    self.statusLabel.text = [NSString stringWithFormat:@"%@ms延时", @(floor(model.serverDelay))];
    self.statusLabel.textColor = model.statusColor;
}

@end

@interface CCServerListViewController ()
@property(nonatomic,strong)LoadingView          *loadingView;
@end

@implementation CCServerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView registerClass:[CCServerTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20.f)];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = view;
    self.title = @"线路切换";
    
    //    self.tableView.tableHeaderView = [self headerView];
    [self getServerData];
}

- (UIView *)headerView
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    backView.backgroundColor = [UIColor clearColor];
    UILabel *oneLabel = [UILabel new];
    oneLabel.text = @"线路";
    
    UILabel *twoLabel = [UILabel new];
    twoLabel.text = @"ping耗时";
    
    [backView addSubview:oneLabel];
    [oneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backView).offset(15.f);
        make.centerY.mas_equalTo(backView);
    }];
    [backView addSubview:twoLabel];
    [twoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(backView);
    }];
    return backView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.serverList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCServerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell reloadWithModel:self.serverList[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCServerModel *model = self.serverList[indexPath.row];
    SaveToUserDefaults(SERVER_DOMAIN, model.serverDomain);
    SaveToUserDefaults(SERVER_DOMAIN_NAME, model.serverName);
    SaveToUserDefaults(SERVER_AREA_NAME, model.area_name);
    
    [tableView reloadData];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getServerData
{
    NSString *userid = GetFromUserDefaults(LIVE_USERID);
    CCStreamerBasic *streamer= [CCStreamerBasic sharedStreamer];
    WS(ws);
    [streamer getRoomServerWithAccountID:userid completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            if(info != nil)
            {
                NSArray *data = info[@"data"];
                NSMutableArray *models = [NSMutableArray arrayWithCapacity:data.count];
                CCServerModel *model_local = nil;
                
                for (NSDictionary *info in data)
                {
                    CCServerModel *model = [[CCServerModel alloc] init];
                    model.serverDomain = [info objectForKey:@"domain"];
                    model.area_name = [info objectForKey:@"area_code"];
                    model.serverName = [info objectForKey:@"loc"];
                    //                    model.serverDelay = [info objectForKey:@""];
                    if (model.serverDomain && model.serverName && ![model.serverDomain isKindOfClass:[NSNull class]])
                    {
                        [models addObject:model];
                        model_local = model;
                    }
                }
                //Last ADD..ping
//                [models addObject:model_local];
                ws.serverList = [NSArray arrayWithArray:models];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }else{
            [CCTool showMessageError:error];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

static BOOL gl_cc_ping_return_mark = YES;

#pragma mark 正在探测节点,在子线程里进行UI操作导致加载过慢。
- (void)testNetwork:(NSArray *)domains
{
    gl_cc_ping_return_mark = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        _loadingView = [[LoadingView alloc] initWithLabel:@"正在探测节点..."];
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow addSubview:_loadingView];
    });
    
    WS(ws);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t source1 = dispatch_semaphore_create(1);
        NSMutableDictionary *allResult = [NSMutableDictionary dictionaryWithCapacity:15];
        NSInteger delCount = 3;
        for (; delCount > 0; delCount--)
        {
            dispatch_semaphore_wait(source1, DISPATCH_TIME_FOREVER);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:domains.count];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    dispatch_semaphore_t source = dispatch_semaphore_create(1);
                    __block STDPingServices *pingServers = nil;
                    for (CCServerModel *model in domains)
                    {
                        NSLog(@"%s__%d__%@", __func__, __LINE__, model.serverDomain);
                        NSString *domain = model.serverDomain;
                        dispatch_semaphore_wait(source, DISPATCH_TIME_FOREVER);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            __block double delayTime = 0;
                            NSInteger allReceiveCount = 2;
                            __block NSInteger count = 2;
                            pingServers = nil;
                            NSLog(@"%s__%d__%@", __func__, __LINE__, domain);
                            pingServers = [STDPingServices startPingAddress:domain callbackHandler:^(STDPingItem *pingItem, NSArray *pingItems) {
                                if (pingItem.status == STDPingStatusDidReceivePacket)
                                {
                                    delayTime = ((allReceiveCount - count)*delayTime + pingItem.timeMilliseconds)/(allReceiveCount - count + 1);
                                    count--;
                                    NSLog(@"delay:%f__%@__%@", delayTime, domain, model.area_name);
                                    
                                    [dic setObject:@(delayTime) forKey:domain];
                                }
                                else if(pingItem.status == STDPingStatusFinished)
                                {
                                    sleep(0.5);
                                    dispatch_semaphore_signal(source);
                                    NSLog(@"%s__%d__%@", __func__, __LINE__, domain);
                                }
                                NSLog(@"%s__%d__%@", __func__, __LINE__, domain);
                            }];
                            pingServers.maximumPingTimes = count;
                        });
                    }
                    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                        NSDictionary *info = [allResult objectForKey:key];
                        if (!info)
                        {
                            info = @{@"time":obj, @"count":@(1)};
                        }
                        else
                        {
                            double time = [info[@"time"]doubleValue];
                            NSInteger count = [info[@"count"] integerValue];
                            double nowTime = [obj doubleValue];
                            time = (time*count + nowTime)/(float)(count+1);
                            count++;
                            info = @{@"time":@(time), @"count":@(count)};
                        }
                        [allResult setObject:info forKey:key];
                    }];
                    pingServers = nil;
                    dispatch_semaphore_signal(source);
                    dispatch_semaphore_signal(source1);
                });
            });
            dispatch_semaphore_wait(source1, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_signal(source1);
        }
        //Last Remove
        NSMutableArray *arr = [NSMutableArray arrayWithArray:ws.serverList];
        [arr removeLastObject];
        ws.serverList = arr;
        //回复维护的状态
        gl_cc_ping_return_mark = YES;
        [self cancelccPingCallBack];
        
        [allResult enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            for (CCServerModel *model in ws.serverList)
            {
                if ([model.serverDomain isEqualToString:key])
                {
                    model.serverDelay = [obj[@"time"] doubleValue];
                    model.serverStatus = [CCServerListViewController getStatusWithDelay:model.serverDelay];
                    model.statusColor = [CCServerListViewController getColorWithDelay:model.serverDelay];
                }
            }
        }];
        
        ws.serverList = [ws.serverList sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            CCServerModel *model1 = (CCServerModel *)obj1;
            CCServerModel *model2 = (CCServerModel *)obj2;
            if (model1.serverDelay > model2.serverDelay)
            {
                return NSOrderedDescending;
            }
            else
            {
                return NSOrderedAscending;
            }
        }];
        //        CCServerModel *selectedModel = [ws.serverList firstObject];
        //        SaveToUserDefaults(SERVER_DOMAIN, selectedModel.serverDomain);
        //        [[CCStreamerBasic sharedStreamer] setServerDomain:selectedModel.serverDomain area:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_loadingView removeFromSuperview];
            _loadingView = nil;
            [ws.tableView reloadData];
        });
        dispatch_semaphore_signal(source1);
    });
    [self performSelector:@selector(ccPingCallBack) withObject:nil afterDelay:5];
    
}
- (void)ccPingCallBack
{
    if (gl_cc_ping_return_mark)
    {
        return;
    }
    gl_cc_ping_return_mark = NO;
    [UIAlertView bk_showAlertViewWithTitle:@"提示" message:@"节点测试异常" cancelButtonTitle:nil otherButtonTitles:@[@"确认"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
    }];
    [_loadingView removeFromSuperview];
    _loadingView = nil;
}

- (void)cancelccPingCallBack
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ccPingCallBack) object:nil];
    });
}

+ (NSString *)getStatusWithDelay:(double)delay
{
    if (delay <= 50.f)
    {
        return @"极佳";
    }
    else if (delay <= 100)
    {
        return @"较好";
    }
    else
    {
        return @"欠佳";
    }
}

+ (UIColor *)getColorWithDelay:(double)delay
{
    if (delay <= 50.f)
    {
        return CCRGBColor(5, 152, 50);
    }
    else if (delay <= 100)
    {
        return CCRGBColor(242, 124, 25);
    }
    else
    {
        return CCRGBColor(230, 37, 28);
    }
}

@end

