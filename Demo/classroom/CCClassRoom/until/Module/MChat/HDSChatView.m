//
//  HDSChatView.m
//  CCClassRoom
//
//  Created by Chenfy on 2019/12/24.
//  Copyright © 2019 cc. All rights reserved.
//

#import "HDSChatView.h"
#import "CCPublicImgTableViewCell.h"

static NSString *CellIdentifier = @"CellPush";
static NSString *CellIdentifier_img = @"CellPush_img";

@interface HDSChatView ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *tableArray;

@end

@implementation HDSChatView

- (instancetype)initWithDataArray:(NSArray *)array
{
    if (self = [super init])
    {
        _tableArray = [NSMutableArray arrayWithArray:array];
        self.backgroundColor = [UIColor clearColor];
        
        _currentIsInBottom = YES;
        [self initUI];
    }
    return self;
}

- (instancetype)initWithDataArray:(NSArray *)array landspace:(BOOL)isLandSpace
{
    _isLandSpace = isLandSpace;
    _hasMessage = NO;
    return [self initWithDataArray:array];
}

- (instancetype)initWithArray:(NSArray *)array landspace:(BOOL)isLandSpace viewid:(NSString *)vid
{
    _isLandSpace = isLandSpace;
    _viewerId = vid;
    return [self initWithDataArray:array];
}

- (void)initUI
{
    WS(weakSelf);
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf);
    }];
}

- (void)hiddenChatView:(BOOL)hidden
{
    self.hidden = hidden;
}

#pragma mark --
#pragma mark -- tableView
- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.layer.cornerRadius = 5.0;
        _tableView.clipsToBounds = YES;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.estimatedRowHeight = 120;
    }
    return _tableView;
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Dialogue *dialogue = [_tableArray objectAtIndex:indexPath.row];
    if (dialogue.type == DialogueType_Pic) {
        CCPublicImgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_img];
        
        if (!cell) {
            cell = [[CCPublicImgTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_img];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell reloadWithDialogue:dialogue antesomeone:^(NSString *antename, NSString *anteid) {
            
        }];
        
        return cell;
    }else {
        
        CCPublicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[CCPublicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell reloadWithDialogue:dialogue antesomeone:^(NSString *antename, NSString *anteid) {
            
        }];
        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CCGetRealFromPt(26);
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, CCGetRealFromPt(26))];
    view.backgroundColor = CCClearColor;
    return view;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    Dialogue *dialogue = [self.tableArray objectAtIndex:indexPath.row];
//    CGFloat height = dialogue.msgSize.height + 10 + 8;
//    return height;
//}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat height = scrollView.frame.size.height;
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat bottomOffset = scrollView.contentSize.height - contentOffsetY;
    CGFloat del = bottomOffset - height;
    if (del <= 25)
    {
        //在最底部
        self.currentIsInBottom = YES;
    }
    else
    {
        self.currentIsInBottom = NO;
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
/** 处理聊天区域的背景色 */
- (void)tableview_bgColorOndirectPor:(BOOL)isPortrait
{
    if (_hasMessage)
    {
        return;
    }
    _hasMessage = YES;
    //解决聊天文字显示不清问题
    if (!self.isLandSpace)
    {
        _tableView.backgroundColor = [UIColor clearColor];
    }
    else
    {
        _tableView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
}

- (void)chatReceiveMediaMessage:(NSDictionary *)dic
{
    [self tableview_bgColorOndirectPor:NO];
    Dialogue *dialogue = [[Dialogue alloc] init];
    dialogue.userid = dic[@"userid"];
    dialogue.username = [dic[@"username"] stringByAppendingString:@": "];
    dialogue.userrole = dic[@"userrole"];
    NSString *msg = dic[@"msg"];
    if ([msg isKindOfClass:[NSString class]] || [msg isKindOfClass:[NSMutableString class]])
    {
        dialogue.msg = [Dialogue removeLinkTag:msg];
        dialogue.type = DialogueType_Text;
    }
    else
    {
        dialogue.picInfo = (NSDictionary *)msg;
        dialogue.type = DialogueType_Pic;
    }
    dialogue.time = dic[@"time"];
    dialogue.myViwerId = self.viewerId;
    dialogue.fromuserid = dialogue.userid;
    
    WS(weakSelf);
    [dialogue calcMsgSize:_tableView.frame.size.width font:[UIFont systemFontOfSize:FontSizeClass_16] block:^{
        [_tableArray addObject:dialogue];
        if([_tableArray count] >= 1){
            [_tableView reloadData];
            if (weakSelf.currentIsInBottom)
            {
                //在最底部
                NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:([_tableArray count]-1) inSection:0];
                [_tableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
    }];
}
- (void)chatReceiveChatMessage:(NSDictionary *)dic
{
    [self tableview_bgColorOndirectPor:NO];
    Dialogue *dialogue = [[Dialogue alloc] init];
    dialogue.userid = dic[@"userid"];
    dialogue.username = [dic[@"username"] stringByAppendingString:@": "];
    dialogue.userrole = dic[@"userrole"];
    NSString *msg = dic[@"msg"];
    NSString *type = dic[@"isMessage"];
    if ([type isEqualToString:@"1"])
    {
        dialogue.msg = [Dialogue removeLinkTag:msg];
        dialogue.type = DialogueType_Text;
    }
    else
    {
        NSDictionary *dicPic = @{@"content":msg};
        dialogue.picInfo = dicPic;
        dialogue.picUrl = msg;
        dialogue.type = DialogueType_Pic;
    }
    dialogue.time = dic[@"time"];
    dialogue.myViwerId = self.viewerId;
    dialogue.fromuserid = dialogue.userid;
    //计算聊天内容的size
    WS(weakSelf);
    [dialogue calcMsgSize:_tableView.frame.size.width font:[UIFont systemFontOfSize:FontSizeClass_16] block:^{
        [_tableArray addObject:dialogue];
        if([_tableArray count] >= 1){
            [weakSelf.tableView reloadData];
            
            if (weakSelf.currentIsInBottom)
            {
                //在最底部
                NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:([_tableArray count]-1) inSection:0];
                [_tableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
    }];
    
}

@end
