//
//  CCLiveStudentSetController.m
//  CCClassRoom
//
//  Created by Chenfy on 2020/4/20.
//  Copyright © 2020 cc. All rights reserved.
//

#import "CCLiveStudentSetController.h"
#import "CCPickView.h"
#import "HDSTool.h"

//SCREEN_SIZE 屏幕尺寸
#define KSCREEN_WIDTH   ([UIScreen mainScreen].bounds.size.width)
#define KSCREEN_HEIGTH  ([UIScreen mainScreen].bounds.size.height)

@interface CCLiveStudentSetController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)HDSTool *hdsTool;

@property(nonatomic,strong)CCPickView *selectPicker;

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSArray *arrayCellList;

@property(nonatomic,copy)NSString *resolutionText;
@property(nonatomic,copy)NSString *mirrorText;
@end

@implementation CCLiveStudentSetController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    _resolutionText = @"240P";
    _mirrorText = @"";
    self.view.backgroundColor = [UIColor greenColor];
    
    [self.view  addSubview:self.tableView];
    // Do any additional setup after loading the view.
}
- (HDSTool *)hdsTool
{
    return [HDSTool sharedTool];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (NSArray *)arrayCellList
{
    return @[@"学生视频分辨率",
             @"视频镜像",];
}

#pragma mark --
#pragma mark -- tableView
- (UITableView *)tableView
{
    if (!_tableView)
    {
        CGRect fm = CGRectMake(0, 0, KSCREEN_WIDTH, KSCREEN_HEIGTH);
        _tableView = [[UITableView alloc]initWithFrame:fm style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 60;
        _tableView.tableFooterView = [UIView new];
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayCellList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
    }
    NSString *text = self.arrayCellList[indexPath.row];
    cell.textLabel.text = text;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if (indexPath.row == 0) {
        NSString *selectedResolution = [self.hdsTool userdefaultSelectedResolutionHeight];
        if (selectedResolution == nil) {
            cell.detailTextLabel.text = _resolutionText;
        } else {
            cell.detailTextLabel.text = selectedResolution;
            _resolutionText = selectedResolution;
        }
    }
    if (indexPath.row == 1) {
        cell.detailTextLabel.text = [self.hdsTool mirrorText];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self functionRowFirst];
            break;
        case 1:
            [self functionRowSecond];
            break;
            
        default:
            break;
    }
}

- (void)functionRowFirst
{
    CCPickView *picker = [[CCPickView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    picker.picktype = HSPickerType_resolution;
    [picker setTitle:@"视频分辨率"];
    self.selectPicker = picker;
    picker.stremer = [CCStreamerBasic sharedStreamer];
    __weak CCPickView *weakPicker = picker;
    picker.CCPickViewCancle = ^(CCPickView * _Nonnull removeView) {
        __strong CCPickView *strongPicker = weakPicker;
        [strongPicker removeFromSuperview];
    };
    picker.CCPickViewSuccess = ^(CCPickView * _Nonnull removeView, NSInteger index, NSString * _Nonnull text) {
        __strong CCPickView *strongPicker = weakPicker;
        [strongPicker removeFromSuperview];
        
        [self.tableView reloadData];
    };
    [self.view addSubview:picker];
    [picker showPickView];
}
- (void)functionRowSecond
{
    CCPickView *picker = [[CCPickView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    picker.picktype = HSPickerType_mirror;
    [picker setTitle:@"视频镜像"];
    self.selectPicker = picker;
    picker.stremer = [CCStreamerBasic sharedStreamer];
    __weak CCPickView *weakPicker = picker;
    picker.CCPickViewCancle = ^(CCPickView * _Nonnull removeView) {
        __strong CCPickView *strongPicker = weakPicker;
        [strongPicker removeFromSuperview];
        
    };
    picker.CCPickViewSuccess = ^(CCPickView * _Nonnull removeView, NSInteger index, NSString * _Nonnull text) {
        __strong CCPickView *strongPicker = weakPicker;
        [strongPicker removeFromSuperview];
        
        self.mirrorText = text;
        self.hdsTool.mirrorType = (HSMirrorType)index;
        [self.tableView reloadData];
    };
    [self.view addSubview:picker];
    [picker showPickView];
}

@end
