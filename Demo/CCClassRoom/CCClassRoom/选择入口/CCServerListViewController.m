//
//  CCServerListViewController.m
//  CCClassRoom
//
//  Created by cc on 17/8/21.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCServerListViewController.h"
#import "LoadingView.h"
#import <UIAlertView+BlocksKit.h>
#import <CCClassRoomBasic/CCClassRoomBasic.h>

@implementation CCServerModel

@end

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
        self.selectedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick"]];
        self.selectedImageView.hidden = YES;
        
        [self addSubview:self.nameLabel];
        [self addSubview:self.statusLabel];
        [self addSubview:self.selectedImageView];
        WS(ws);
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws).offset(15.f);
            make.centerY.mas_equalTo(ws);
            //            make.right.mas_lessThanOrEqualTo(ws.statusLabel.mas_left).offset(-10.f);
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
    NSString *areacode = GetFromUserDefaults(SERVER_DOMAIN_NAME);
    
    if (domain && [areacode isEqualToString:model.area_name])
    {
        seleted = YES;
    }
    self.selectedImageView.hidden = !seleted;
    self.nameLabel.text = model.area_name;
    self.statusLabel.text = [NSString stringWithFormat:@"%@ms", @(floor(model.serverDelay))];
    //    self.statusLabel.textColor = model.statusColor;
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
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    SaveToUserDefaults(SERVER_DOMAIN_NAME, model.area_name);
    [tableView reloadData];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getServerData
{
    NSString *userid = GetFromUserDefaults(LIVE_USERID);
    CCStreamerBasic *ccStreamer = [CCStreamerBasic sharedStreamer];
    [self loading_Add:@"加载中..."];
    WS(ws);
    [ccStreamer getRoomServerWithAccountID:userid completion:^(BOOL result, NSError *error, id infoRes) {
        [self loading_Remove];
        if (result)
        {
            NSArray *data = infoRes;
            NSMutableArray *models = [NSMutableArray arrayWithCapacity:data.count];
            for (NSDictionary *info in data)
            {
                CCServerModel *model = [[CCServerModel alloc] init];
                model.serverDomain = [info objectForKey:@"domain"];
                model.area_name = [info objectForKey:@"loc"];
                model.serverDelay = [info[@"delay"] doubleValue];
                [models addObject:model];
            }
            ws.serverList = [NSArray arrayWithArray:models];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws.tableView reloadData];
            });
        }
        else
        {
            [self showError:infoRes];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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


- (void)loading_Add
{
    [self loading_Add:nil];
}
- (void)loading_Add:(NSString *)message
{
    if (!message || message.length == 0)
    {
        message = @"正在登录...";
    }
    [self loading_Remove];
    dispatch_async(dispatch_get_main_queue(), ^{
        _loadingView = [[LoadingView alloc] initWithLabel:message];
        UIWindow *keyW = [[UIApplication sharedApplication]keyWindow];
        [keyW addSubview:_loadingView];
        
        [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
    });
}
- (void)loading_Remove
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_loadingView removeFromSuperview];
    });
}

#pragma mark - show error
- (void)showError:(NSError *)error
{
    NSString *mes = [NSString stringWithFormat:@"%@\n%@", @(error.code), error.domain];
    [UIAlertView bk_showAlertViewWithTitle:@"" message:mes cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
    }];
}
@end
