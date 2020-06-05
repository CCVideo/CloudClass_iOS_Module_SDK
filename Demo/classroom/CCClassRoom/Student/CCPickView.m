
//
//  CCPickView.m
//  CCClassRoom
//
//  Created by Mac on 2019/8/10.
//  Copyright © 2019 cc. All rights reserved.
//

#import "CCPickView.h"
#import "CCTool.h"
#import "HDSTool.h"

@interface CCPickView ()
@property(nonatomic,copy)NSString *title;


@property(nonatomic,strong)NSArray *resolutionsRevert;
@property(nonatomic,strong)UIView *allView;
@property(nonatomic,strong)UIPickerView *pickView;
@property(nonatomic,strong)HDSTool *hdstool;

@end

@implementation CCPickView

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self loadPickView];
}

- (HDSTool *)hdstool
{
    return [HDSTool sharedTool];
}

- (NSArray *)loadPickerViewData:(NSInteger)resolutionCount
{
    NSArray *arrResolutions = @[];
    if (resolutionCount == 1) {
        arrResolutions = [[NSArray alloc]initWithObjects:@"240P", nil];
    }
    else if (resolutionCount == 2) {
        arrResolutions = [[NSArray alloc]initWithObjects:@"480P",@"240P", nil];
    }
    else if (resolutionCount == 3) {
        arrResolutions = [[NSArray alloc]initWithObjects:@"720P",@"480P",@"240P", nil];
    }
    return arrResolutions;
}

- (NSArray *)loadResolutionDatas
{
    NSArray *arr = [self.stremer resolutionsSupport];
    //倒叙排序m，与上面数列匹配
    NSArray *arrRevert = [[arr reverseObjectEnumerator]allObjects];
    return arrRevert;
}


- (void)loadPickView
{
    UIView *backView = [UIView new];
    backView.frame = [UIScreen mainScreen].bounds;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFenBian:)];
    [backView addGestureRecognizer:tap1];
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    pickerView.showsSelectionIndicator = YES;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    
    self.pickView = pickerView;
    
    pickerView.backgroundColor = [UIColor blackColor];
    [backView addSubview:pickerView];
    [pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(backView);
        make.height.mas_equalTo(200.f);
    }];
    
    UIView *topView = [UIView new];
    topView.backgroundColor = CCRGBColor(68, 68, 68);
    [backView addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(backView);
        make.bottom.mas_equalTo(pickerView.mas_top).offset(0.f);
        //        make.height.mas_equalTo(50.f);
    }];
    
    UILabel *label = [UILabel new];
    label.text = _title ? _title : @"标题";
    label.textColor = CCRGBColor(204, 204, 204);
    label.font = [UIFont systemFontOfSize:FontSizeClass_22];
    [topView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(topView);
    }];
    
    UIButton *cacleBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cacleBtn setTitle:@"取消" forState:UIControlStateNormal];
    cacleBtn.titleLabel.font = [UIFont systemFontOfSize:FontSizeClass_20];
    [cacleBtn setTitleColor:MainColor forState:UIControlStateNormal];
    [cacleBtn addTarget:self action:@selector(cancleBtn:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:cacleBtn];
    [cacleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(topView).offset(10.f);
        make.bottom.top.mas_equalTo(topView);
    }];
    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn setTitleColor:MainColor forState:UIControlStateNormal];
    sureBtn.titleLabel.font = [UIFont systemFontOfSize:FontSizeClass_20];
    [sureBtn addTarget:self action:@selector(sureBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:sureBtn];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(topView).offset(-10.f);
        make.bottom.top.mas_equalTo(topView);
    }];
    
    self.allView = backView;
}

- (void)showPickView
{
    if (_picktype == HSPickerType_resolution) {
        [self showPickView_resolution];
    }
    if (_picktype == HSPickerType_mirror) {
        [self showPickView_mirror];
    }
}

- (void)showPickView_resolution
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //要根据存储的值判定选择的分辨率，返回上个页面的时候清空存储。
        NSString *selectedResolution = [self.hdstool userdefaultSelectedResolutionHeight];
        if (selectedResolution == nil) {
            [self.pickView selectRow:1 inComponent:0 animated:NO];
        }else{
            NSString *pstring = [NSString stringWithFormat:@"%@P",selectedResolution];
            int index = (int)[self.pickerViewData indexOfObject:pstring];

            self.pickerViewSelectedIndex = index;
            [self.pickView selectRow:index inComponent:0 animated:NO];
        }
    });
    [self addSubview:self.allView];
}

- (void)showPickView_mirror
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          //要根据存储的值判定选择的分辨率，返回上个页面的时候清空存储。
        NSInteger index = self.hdstool.mirrorType;
        self.pickerViewSelectedIndex = index;
        [self.pickView selectRow:index inComponent:0 animated:NO];
    });
    [self addSubview:self.allView];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *arrRevert = [self loadResolutionDatas];
    self.resolutionsRevert = arrRevert;
    NSInteger numb = [arrRevert count];

    return [self.pickerViewData count];
}

- (NSArray *)pickerViewData
{
    if (_picktype == HSPickerType_resolution) {
        NSArray *arrRevert = [self loadResolutionDatas];
        self.resolutionsRevert = arrRevert;
        NSInteger numb = [arrRevert count];
        NSArray *arrayResolution = [self loadPickerViewData:numb];
        return arrayResolution;
    }
    if (_picktype == HSPickerType_mirror) {
        return [self arrayMirrorType];
    }
    return @[];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [self.pickerViewData objectAtIndex:row];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:title];
    [str addAttribute:NSForegroundColorAttributeName value:CCRGBColor(204,204,204) range:NSMakeRange(0, title.length)];
    return str;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.pickerViewSelectedIndex = row;
}

- (void)cancleBtn:(UIButton *)btn
{
    if (self.CCPickViewCancle) {
        self.CCPickViewCancle(self);
    }
}

- (void)tapFenBian:(UITapGestureRecognizer *)ges
{
    if (self.CCPickViewCancle) {
        self.CCPickViewCancle(self);
    }
}

#pragma mark 修改房间老师和学生推流码率
- (void)sureBtnClicked:(UIButton *)btn
{
    [btn.superview.superview removeFromSuperview];
    if (_picktype == HSPickerType_resolution) {
        [self sureBtnClicked_resolution];
    }
    if (_picktype == HSPickerType_mirror) {
        [self sureBtnClicked_mirror];
    }
}

- (void)sureBtnClicked_resolution
{
    NSInteger index = self.pickerViewSelectedIndex;
     
     NSString *titleResolution = self.pickerViewData[index];
     NSString *titleShow = [NSString stringWithFormat:@"选择了%@",titleResolution];
     int type = [self.resolutionsRevert[index] intValue];
     
     NSString *resolutionString = [titleResolution stringByReplacingOccurrencesOfString:@"P" withString:@""];
     
     CCResolution resoluton = [self.hdstool resolutionEnumFromInt:type];

     [self.stremer setResolution:resoluton];
     [self.hdstool userdefaultSetSelectedResolution:resolutionString];
     
     [CCTool showMessage:titleShow];

     if (self.CCPickViewSuccess) {
         self.CCPickViewSuccess(self,resoluton,titleResolution);
     };
}

- (void)sureBtnClicked_mirror
{
    NSInteger index = self.pickerViewSelectedIndex;
    NSString *text = self.pickerViewData[index];
    if (self.CCPickViewSuccess) {
        self.CCPickViewSuccess(self,index,text);
    };
}

#pragma mark -- Mirror
- (NSArray *)arrayMirrorType
{
    return [self.hdstool mirrorTypeArray];
}



@end
