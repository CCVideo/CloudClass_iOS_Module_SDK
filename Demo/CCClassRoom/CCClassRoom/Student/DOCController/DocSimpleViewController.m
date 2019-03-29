//
//  DocSimpleViewController.m
//  CCClassRoom
//
//  Created by cc on 18/7/13.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "DocSimpleViewController.h"

#pragma mark-屏幕尺寸
#define SCREEN_HEIGHT   ([[UIScreen mainScreen]bounds].size.height)
/*******************************/
/** 用户自定义 */
#define Func_DOC_Normal     1
//画板竖屏
#define DOC_FRAME_POR_BIG    (CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT))
/*******************************/

#define V_TAG   1000

typedef NS_ENUM(NSInteger,CCDocFunc) {
    CCDocFuncDocList,
    CCDocFuncDocChange,
    CCDocFuncDocBack,
    CCDocFuncDocFront,
    CCDocFuncWhiteBoard,
    CCDocFuncGetDoc
};

@interface DocSimpleViewController ()<CCStreamerBasicDelegate>
@property(nonatomic,strong)UIButton   *drawButton;
@property(nonatomic,strong)UIButton   *eraserButton;
@property(nonatomic,strong)UIButton   *gestureButton;
@property(nonatomic,strong)UIButton   *revokeDrawButton;

@property(nonatomic,strong)UIView   *controlView;//功能视图
@property (nonatomic, strong) UIButton *fullScreenDocViewButton;//文档全屏

@property(nonatomic,assign)BOOL isDocBig;
#pragma mark - array
@property(nonatomic,strong)NSMutableArray   *arrayDoc;

@end

@implementation DocSimpleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self initUI];
    [self createButtonDocFunc];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //加载展示数据
        [self.ccVideoView setOnDpCompleteListener:^(CCDocLoadType type, CGFloat w, CGFloat h) {
            NSLog(@"DpListener---type-<%ld>--w-:%f--h-:%f",(long)type,w,h);
        }];
        [self.ccVideoView initDocEnvironment];
//        [self.ccVideoView setDocPortrait:YES];
//        [self.ccVideoView setDocBackGroundColor:[UIColor purpleColor]];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.ccVideoView startDocView];
    });
}

- (void)initUI
{
    UIView *v = [self.view viewWithTag:V_TAG];
    if (v)
    {
        [v removeFromSuperview];
    }
    //view 添加展示
    [self.view addSubview:self.ccVideoView];
    
    [self.view addSubview:self.controlView];
    [self.controlView addSubview:self.drawButton];
    [self.controlView addSubview:self.eraserButton];
    [self.controlView addSubview:self.gestureButton];
    [self.controlView addSubview:self.revokeDrawButton];
    [self.view addSubview:self.fullScreenDocViewButton];
    
    WS(weakSelf);
    [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).offset(10);
        make.size.mas_equalTo(CGSizeMake(50 * 4, 50));
        make.centerX.equalTo(weakSelf.view);
    }];
    [self.drawButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.controlView);
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.left.equalTo(weakSelf.controlView);
    }];
    [self.eraserButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.controlView);
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.left.equalTo(weakSelf.drawButton.mas_right);
    }];
    [self.gestureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.controlView);
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.left.mas_equalTo(weakSelf.eraserButton.mas_right);
    }];
    [self.revokeDrawButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.controlView);
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.left.mas_equalTo(weakSelf.gestureButton.mas_right);
        make.right.equalTo(weakSelf.controlView);
    }];
    [self.fullScreenDocViewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.and.right.equalTo(weakSelf.ccVideoView).offset(-10);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addObserver];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeObserver];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self change_forward_toUp];
}

#pragma mark -- 接收
-(void)addObserver
{
    [self.stremer addObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveSocketEvent object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];

}
-(void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];

    [self.stremer removeObserver:self];
}

- (void)receiveSocketEvent:(NSNotification *)noti
{
    NSLog(@"___%s___%@___",__func__,noti);
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    NSLog(@"___%s___%d___",__func__,event);
    if(event == CCSocketEvent_PublishStart)
    {
        [self.ccVideoView startDocView];
    }
    else if(event == CCSocketEvent_PublishEnd)
    {
        
    }
}

- (void)changeRotate:(NSNotification*)noti {
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait
        || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown) {
        //竖屏
        NSLog(@"竖屏");
        [self.ccVideoView setDocFrame:CGRectMake(0, 0, SCREEN_WIDTH, (9/16.0)*(SCREEN_WIDTH))];
//        [self.ccVideoView setDocPortrait:YES];
//        [self.ccVideoView setDocFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT)];
//        [self.navigationController setNavigationBarHidden:NO animated:YES];

    } else {
        //横屏
        NSLog(@"横屏");
        NSLog(@"%f , %f",SCREENH_HEIGHT,SCREEN_WIDTH);
        [self.ccVideoView setDocPortrait:NO];
        [self.ccVideoView setDocFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT)];
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }

    self.fullScreenDocViewButton.selected = !self.fullScreenDocViewButton.selected;
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

#pragma mark - UIButton click  Method
- (void)ruleBtnClick:(UIButton *)sender
{
    [self.ccVideoView setCurrentIsEraser:YES];
}

- (void)drawBtnClick:(UIButton *)sender
{
    [self.ccVideoView setCurrentIsEraser:NO];
    [self.ccVideoView setGestureOpen:NO];
    [self.ccVideoView setDocEditable:YES];
}

//独立全屏按钮
- (void)fullScreenDocViewButton:(UIButton *)sender
{
    //    默认显示去放大  选中显示去缩小
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (sender.selected)
    {
        appDelegate.shouldNeedLandscape = NO;
        [appDelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
        
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
        
        [UIApplication sharedApplication].statusBarHidden = NO;
        
    } else {
        appDelegate.shouldNeedLandscape = YES;
        [appDelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
        [UIApplication sharedApplication].statusBarHidden = YES;
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Getter and Setter Method
-  (UIView *)controlView {
    if (!_controlView) {
        _controlView = [[UIView alloc]init];
        _controlView.frame = CGRectMake(100, 100, 100, 50);
        _controlView.layer.cornerRadius = 25;
        _controlView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _controlView;
}

-  (UIButton *)drawButton {
    if (!_drawButton) {
        _drawButton = [UIButton new];
        [_drawButton setBackgroundImage:[UIImage imageNamed:@"pencil"] forState:UIControlStateNormal];
        [_drawButton setBackgroundImage:[UIImage imageNamed:@"pencil_touch"] forState:UIControlStateHighlighted];
        [_drawButton addTarget:self action:@selector(drawBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _drawButton;
}
-  (UIButton *)eraserButton {
    if (!_eraserButton) {
        _eraserButton = [UIButton new];
        [_eraserButton setBackgroundImage:[UIImage imageNamed:@"rule"] forState:UIControlStateNormal];
        [_eraserButton setBackgroundImage:[UIImage imageNamed:@"rule_touch"] forState:UIControlStateHighlighted];
        [_eraserButton addTarget:self action:@selector(ruleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _eraserButton;
}
//手势按钮
-  (UIButton *)gestureButton
{
    if (!_gestureButton) {
        _gestureButton = [UIButton new];
        [_gestureButton setBackgroundImage:[UIImage imageNamed:@"drag"] forState:UIControlStateNormal];
        [_gestureButton setBackgroundImage:[UIImage imageNamed:@"drag"] forState:UIControlStateHighlighted];
        [_gestureButton addTarget:self action:@selector(gestureButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _gestureButton;
}
- (void)gestureButtonClicked:(UIButton *)sender
{
    sender.selected = !sender.selected;
    //保持拖拽与编辑相反状态
    [self.ccVideoView setGestureOpen:sender.selected];
    [self.ccVideoView setDocEditable:!sender.selected];
}

//画笔撤销
- (UIButton *)revokeDrawButton
{
    if (!_revokeDrawButton)
    {
        _revokeDrawButton = [UIButton new];
        [_revokeDrawButton setBackgroundImage:[UIImage imageNamed:@"back1"] forState:UIControlStateNormal];
        [_revokeDrawButton addTarget:self action:@selector(revokeClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _revokeDrawButton;
}
- (void)revokeClicked
{
    [self.ccVideoView revokeLastDraw];
}

- (UIButton *)fullScreenDocViewButton {
    if (!_fullScreenDocViewButton) {
        _fullScreenDocViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenDocViewButton setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
        [_fullScreenDocViewButton setImage:[UIImage imageNamed:@"exitfullscreen"] forState:UIControlStateSelected];
        
        [_fullScreenDocViewButton addTarget:self action:@selector(fullScreenDocViewButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenDocViewButton;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

//修改设备方向
- (void)change_forward_toUp
{
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.shouldNeedLandscape = NO;
    [appDelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
}

#pragma mark --
#pragma mark -- 文档测试
- (NSMutableArray *)arrayDoc
{
    if (!_arrayDoc)
    {
        _arrayDoc = [NSMutableArray arrayWithCapacity:2];
    }
    return _arrayDoc;
}

- (void)createButtonDocFunc
{
    if (Func_DOC_Normal == 1)
    {
        return;
    }
    for (int i = 0; i < CCDocFuncGetDoc+1; i++)
    {
        int per_num = 2;
        int x_p = i%per_num;
        int y_p = i/per_num;
        
        int w_btn = 100;
        
        int x = 50 + (w_btn + 20) * x_p;
        int y = 400 + 50 * y_p;
        int w = w_btn , h = 35;
        CGRect frame = CGRectMake(x, y, w, h);
        UIButton *btn = [self createBtn:frame tag:i];
        [self.view addSubview:btn];
    }
}
- (UIButton *)createBtn:(CGRect)frame tag:(NSInteger)tag
{
    NSString *name = @"";
    switch (tag) {
        case CCDocFuncDocList:
            name = @"文档列表";
            break;
        case CCDocFuncDocChange:
            name = @"文档切换";
            break;
        case CCDocFuncDocBack:
            name = @"<-文档";
            break;
        case CCDocFuncDocFront:
            name = @"文档->";
            break;
        case CCDocFuncWhiteBoard:
            name = @"白板";
            break;
        case CCDocFuncGetDoc:
            name = @"get_docid";
    }
#pragma mark ButtonCreate
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor cyanColor];
    btn.tag = tag;
    btn.frame = frame;
    [btn setBackgroundColor:[UIColor orangeColor]];
    [btn setTitle:name forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)buttonClick:(UIButton *)sender
{
    int tag = (int)sender.tag;
    if (tag == 0)
    {
        [self btn_0_get_doc];
    }
    if (tag == 1)
    {
        [self btn_1_get_doc];
    }
    if (tag == 2)
    {
        [self btn_2_get_doc_left];
    }
    if (tag == 3)
    {
        [self btn_3_get_doc_right];
    }
    if (tag == 4)
    {
        [self btn_4_doc_whiteBoard];
    }
    if (tag == 5)
    {
        [self btn_5_doc_GetCurrent];
    }
}

- (void)btn_0_get_doc
{
    [self.ccVideoView getRelatedRoomDocs:nil userID:nil docID:nil docName:nil pageNumber:1 pageSize:1000 completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSDictionary *dic = info;
            NSLog(@"%s_%@", __func__, info);
            NSString *result = dic[@"result"];
            if ([result isEqualToString:@"OK"])
            {
                NSString *picDomain = [dic objectForKey:@"picDomain"];
                NSArray *docs = [dic objectForKey:@"docs"];
                for (NSDictionary *doc in docs)
                {
                    CCDoc *newDoc = [[CCDoc alloc] initWithDic:doc picDomain:picDomain];
                    newDoc.isReleatedDoc = YES;
                    if ([self docStatusIsOk:newDoc])
                    {
                        [self dataSourceAddDoc:newDoc];
                    }
                }
            }
            else
            {
                
            }
        }
    }];
}
//判断文档状态是否OK ：0、1、2
//-2: 未上传  -1:上传失败 0: 上传成功 1: 转换成功 2: 转换中 3: 转换失败
- (BOOL)docStatusIsOk:(CCDoc *)doc
{
    if (doc.status == 0 || doc.status == 1 || doc.status == 2)
    {
        return YES;
    }
    return NO;
}
//去重方法
- (void)dataSourceAddDoc:(CCDoc *)doc
{
    if (!self.arrayDoc)
    {
        return;
    }
    BOOL hasExist = NO;
    for (CCDoc *docLocal in self.arrayDoc) {
        if ([doc.docID isEqualToString:docLocal.docID])
        {
            hasExist = YES;
            break;
        }
    }
    if (!hasExist)
    {
        [self.arrayDoc addObject:doc];
    }
}

int gl_doc_num = 0;

- (void)btn_1_get_doc
{
    gl_doc_num++;
    int count = (int)[self.arrayDoc count];
    NSLog(@"count__%d",count);
    
    if (count == 0)
    {
        return;
    }
    //防止越界
    if (gl_doc_num > count - 1)
    {
        gl_doc_num = 0;
    }
    CCDoc *doc = self.arrayDoc[gl_doc_num];
    
    [self.ccVideoView docChangeTo:doc];
}

- (void)btn_2_get_doc_left
{
    [self.ccVideoView docPageToBack];
}

- (void)btn_3_get_doc_right
{
    [self.ccVideoView docPageToFront];
}

- (void)btn_4_doc_whiteBoard
{
//    [self.ccVideoView docPageToWhiteBoard];
    [self.ccVideoView setDocBackGroundColor:[UIColor cyanColor]];
}

- (void)btn_5_doc_GetCurrent
{
    NSString *doc = [self.ccVideoView docCurrentDocId];
    NSLog(@"btn_5_doc_GetCurrent___%@",doc);
}

@end
