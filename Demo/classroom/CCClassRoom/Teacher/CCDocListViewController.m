//
//  CCDocListViewController.m
//  CCClassRoom
//
//  Created by cc on 17/4/21.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCDocListViewController.h"
#import "CCDocTableViewCell.h"
#import <Masonry.h>
#import <UIAlertView+BlocksKit.h>
#import "HDSDocManager.h"

@interface CCDocListViewController ()
@property (strong, nonatomic) NSMutableArray *data;
@end

@implementation CCDocListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"提取文档";
    [self makeData];
}

- (UIView *)footerview
{
    UILabel *label = [UILabel new];
    label.text = @"请通过Web端将文档上传至文档区";
    label.textColor = [UIColor colorWithRed:157/255.f green:157.f/255.f blue:157.f/255.f alpha:1.f];
    label.font = [UIFont systemFontOfSize:FontSizeClass_14];
    label.textAlignment = NSTextAlignmentCenter;
    
    UIView *backView = [UIView new];
    [backView addSubview:label];
    [label mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(backView).offset(0.f);
    }];
    self.tableView.scrollEnabled = YES;
    backView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 40.f);
    return backView;
}

- (void)makeData
{
    if (self.data)
    {
        [self.data removeAllObjects];
        self.data = nil;
    }
    self.data = [NSMutableArray array];
    
    //就是这里的问题，我给出的处理不对
    
    [[self hdsDocView] getRelatedRoomDocs:nil userID:nil docID:nil docName:nil pageNumber:1 pageSize:1000 completion:^(BOOL result, NSError *error, id info) {
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];

                });
            }
            else
            {
                
            }
        }
        else
        {
            self.data = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
    [self.tableView reloadData];
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
    if (!self.data)
    {
        return;
    }
    BOOL hasExist = NO;
    for (CCDoc *docLocal in self.data) {
        if ([doc.docID isEqualToString:docLocal.docID])
        {
            hasExist = YES;
            break;
        }
    }
    if (!hasExist)
    {
        [self.data addObject:doc];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self footerview].bounds.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self footerview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndetifer = @"Cell";
    CCDocTableViewCell * cell;
    cell.backgroundColor = [UIColor whiteColor];
    if (indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"BoardCell" forIndexPath:indexPath];
//        [cell reloadWithInfo:@{@"image":@"board", @"name":@"白板"}];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIndetifer forIndexPath:indexPath];
        [cell reloadWithDoc:self.data[indexPath.row - 1]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 0)
    {
        return UITableViewCellEditingStyleDelete;
    }
    else
    {
        return UITableViewCellEditingStyleNone;
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return nil;
    }
    else
    {
        UITableViewRowAction *action0 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            
            CCDoc *doc = self.data[indexPath.row - 1];
            NSString *msg = [NSString stringWithFormat:@"是否删除文档：%@", doc.docName];
            [UIAlertView bk_showAlertViewWithTitle:@"" message:msg cancelButtonTitle:@"确定" otherButtonTitles:@[@"取消"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 0)
                {
                    if (doc.isReleatedDoc)
                    {
                        [[self hdsDocView]unReleatedDoc:doc.docID roomID:nil userID:nil completion:^(BOOL result, NSError *error, id info) {
                            if (result)
                            {
                                NSString *result = info[@"result"];
                                if ([result isEqualToString:@"OK"])
                                {
                                    [self.data removeObject:doc];
                                    [self.tableView reloadData];
                                    //这个时候假如删除的是当前显示文档，要特殊处理
                                    [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiDelDoc object:nil userInfo:@{@"value":doc}];
                                }
                            }
                        }];
                    }
                }
            }];
            // 收回左滑出现的按钮(退出编辑模式)
            tableView.editing = NO;
        }];
        return @[action0];
    }
}
#pragma mark 点击文档库
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //这里要更新文档
    CCDoc *doc;
    if (indexPath.row == 0)
    {
        doc = [[CCDoc alloc] init];
        doc.docID = @"WhiteBoard";
        doc.docName = @"WhiteBoard";
        doc.pageSize = 0;
        doc.roomID = GetFromUserDefaults(LIVE_ROOMID);
        [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiChangeDoc object:nil userInfo:@{@"value":doc, @"page":@(0)}];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        doc = self.data[indexPath.row - 1];
        if (doc.status != 1)
        {
            [self docIsOnConvert];
            return;
        }
        __weak typeof(self) weakSelf = self;
        NSString *userId = GetFromUserDefaults(LIVE_USERID);
        
        /*
         再此处返回的时候，将获取的数据通知，返回到主界面中，因为在此处无法进行加载。
         这个方法的主要目的在于获取相应的参数，然后用通知传递给主界面，主界面再重新加载。
         但是，为什么在直播的时候，界面就无法加载了呢？  数据没有传递成功吗？  全部打印看看。
         */
        
        NSLog(@"CCDocListViewController~~~~~~~~~~传递的信息userId：%@~~~~~~~~~~~doc.docID:%@",userId,doc.docID);
        [[self hdsDocView] getRelatedRoomDocs:nil userID:userId docID:doc.docID docName:nil pageNumber:1 pageSize:10 completion:^(BOOL result, NSError *error, id info) {
            if (result)
            {
                NSLog(@"CCDocListViewController~~~~~~~~~~~~%s__%@", __func__, info);
                if ([[info objectForKey:@"result"] isEqualToString:@"OK"])
                {
                    NSDictionary *dic = info;
                    NSString *picDomain = [dic objectForKey:@"picDomain"];
                    NSArray *docArr = [dic objectForKey:@"docs"];
                    //初始化文档model，然后将model传递过去，以供加载。
                    NSLog(@"xx1230----");

                    CCDoc *newDoc = [[CCDoc alloc] initWithDic:[docArr  lastObject] picDomain:picDomain];
                    NSLog(@"xx1230-1---");

                    NSLog(@"~~~~~~~~~~~~~~是否在主线程：%@~~~~`picDomain:%@",[NSThread currentThread],picDomain);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"xx1230-2---");

                        [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiChangeDoc object:nil userInfo:@{@"value":newDoc, @"page":@(0)}];
                        NSLog(@"xx1230-3---");

                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    });
                    
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"getProWithDocID" object:nil userInfo:@{@"docID":doc.docID}];

                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiChangeDoc object:nil userInfo:@{@"value":doc, @"page":@(0)}];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiChangeDoc object:nil userInfo:@{@"value":doc, @"page":@(0)}];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}
//正在转换
- (void)docIsOnConvert
{
    [UIAlertView bk_showAlertViewWithTitle:@"" message:@"文档正在转码，请刷新数据" cancelButtonTitle:@"刷新" otherButtonTitles:@[@"取消"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex ==0)
        {
            [self makeData];
        }
    }];
}

- (CCDocVideoView *)hdsDocView
{
    return [[HDSDocManager sharedDoc]hdsDocView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
