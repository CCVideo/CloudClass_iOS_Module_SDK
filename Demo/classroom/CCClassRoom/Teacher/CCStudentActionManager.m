//
//  CCStudentActionManager.m
//  CCClassRoom
//
//  Created by cc on 17/4/28.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCStudentActionManager.h"
#import <BlocksKit+UIKit.h>
#import "LCActionSheet.h"
#import "CCRewardView.h"
#import "HDSTool.h"

#define ACTIONSHEETTAGONE 1001
#define ACTIONSHEETTAGTWO 1002
#define ACTIONSHEETTAGTHTREE 1003
#define ACTIONSHEETTAGFOUR 1004
#define ACTIONSHEETTAGFIVE 1005
#define ACTIONSHEETTAGSIX 1006
#define ACTIONSHEETTAGSEVEN 1007
//学生用tag
#define ACTIONSHEETTAGEIGHT 1008

@interface CCStudentActionManager()<UIActionSheetDelegate>
{
    CCStudentActionManagerBlock block;
}
@property (strong, nonatomic) CCMemberModel *showModel;
@property (strong, nonatomic) HDSTool *hdsTool;


@end

@implementation CCStudentActionManager
- (HDSTool *)hdsTool
{
    if (!_hdsTool) {
        _hdsTool = [[HDSTool  alloc]init];
    }
    return _hdsTool;
}

- (void)showWithUserID:(NSString *)userID inView:(UIView *)view dismiss:(CCStudentActionManagerBlock)completion
{
    CCRole roleNow = [[CCStreamerBasic sharedStreamer]getRoomInfo].user_role;
    if (roleNow != CCRole_Teacher && roleNow != CCRole_Assistant)
    {
        return;
    }
    CCMemberModel *model = [self modelWithUserID:userID];
    [self showWithModel:model inView:view dismiss:completion];
}
///弹出框展示内容
- (void)showWithModel:(CCMemberModel *)model inView:(UIView *)view dismiss:(CCStudentActionManagerBlock)completion
{
    self.showModel = model;
    block = completion;
#define CC_Cup  @"奖励奖杯"
    __weak typeof(self) weakSelf = self;
    NSArray *titleArray;
    NSInteger tag = 0;
    if (model.type == CCMemberType_Audience)
    {
        //旁听   获取旁听的禁言状态(YES表示禁言中)
        //        BOOL mute = [[CCStreamerBasic sharedStreamer] getAudienceChatStatus:model.userID];
        //此处不需要传参用户ID
        BOOL mute = [[CCChatManager sharedChat] isUserGag];
        NSString *title = mute ? @"解除禁言" : @"禁言";
        titleArray = @[title, @"踢出房间"];
        tag = ACTIONSHEETTAGSIX;
    }
    else if (model.type == CCMemberType_Teacher || model.type == CCMemberType_Assistant)
    {
        return;
    }
    else
    {
        NSString *drawtitle = [self getDrawTitleWithModel:model];
        if (model.micType == CCUserMicStatus_Connected || model.micType == CCUserMicStatus_Connecting)
        {
            //踢下麦，禁言，取消
            NSString *title = @"";
            BOOL audioOpened = YES;
            if (model.streamID)
            {
                for (CCUser *user in [[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList)
                {
                    if ([user.user_id isEqualToString:model.userID])
                    {
                        audioOpened = user.user_audioState;
                        title = user.user_chatState ? @"禁言" : @"解除禁言";
                        break;
                    }
                }
            }
            titleArray = @[CC_Cup,drawtitle, @"踢下麦", title, @"踢出房间"];
            tag = ACTIONSHEETTAGONE;
        }
        else
        {
            CCClassType mode = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_class_type;
            if (mode == CCClassType_Auto)
            {
                NSString *title = model.isMute ? @"解除禁言" : @"禁言";
                titleArray = @[CC_Cup, drawtitle, title, @"踢出房间"];
                tag = ACTIONSHEETTAGFIVE;
            }
            else if(mode == CCClassType_Named)
            {
                if(model.micType == CCUserMicStatus_None)
                {
                    //邀请上麦
                    //禁言,取消
                    NSString *title = model.isMute ? @"解除禁言" : @"禁言";
                    titleArray = @[CC_Cup,drawtitle, @"邀请上麦", title, @"踢出房间"];
                    tag = ACTIONSHEETTAGTWO;
                }
                else if (model.micType == CCUserMicStatus_Wait)
                {
                    //同意上麦
                    //禁言,取消
                    NSString *title = model.isMute ? @"解除禁言" : @"禁言";
                    titleArray = @[CC_Cup,drawtitle, @"同意上麦", title, @"踢出房间"];
                    tag = ACTIONSHEETTAGTHTREE;
                }
                else if (model.micType == CCUserMicStatus_Inviteing)
                {
                    //取消邀请 禁言 取消
                    NSString *title = model.isMute ? @"解除禁言" : @"禁言";
                    titleArray = @[CC_Cup,drawtitle, @"取消邀请", title, @"踢出房间"];
                    tag = ACTIONSHEETTAGFOUR;
                }
            }
            else if (mode == CCClassType_Rotate)
            {
                //邀请上麦
                //禁言,取消
                NSString *title = model.isMute ? @"解除禁言" : @"禁言";
                titleArray = @[CC_Cup,drawtitle, @"拉上麦", title, @"踢出房间"];
                tag = ACTIONSHEETTAGSEVEN;
            }
        }
    }
    
    if (model.streamID)
    {
        for (CCUser *user in [[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList)
        {
            if ([user.user_id isEqualToString:model.userID])
            {
                NSString *assistant = user.user_AssistantState ? @"取消设为讲师" : @"设为讲师";
                NSMutableArray *titles = [NSMutableArray arrayWithArray:titleArray];
                [titles addObject:assistant];
                titleArray = [NSArray arrayWithArray:titles];
            }
        }
    }
    if (titleArray.count > 0)
    {
        [LCActionSheetConfig shared].buttonColor = CCRGBColor(242, 124, 25);
        [LCActionSheetConfig shared].cancleBtnColor = [UIColor blackColor];
        [LCActionSheetConfig shared].buttonFont = [UIFont systemFontOfSize:FontSizeClass_16];
        LCActionSheet *actionSheet = [LCActionSheet sheetWithTitle:nil cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
            buttonIndex--;
            [weakSelf actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
        } otherButtonTitleArray:titleArray];
        actionSheet.tag = tag;
        actionSheet.scrolling          = YES;
        actionSheet.visibleButtonCount = 3.6f;
        [actionSheet show];
    }
}

//数据偏移
#define Index_Offset    1

- (void)actionSheet:(LCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    CCMemberModel *model = self.showModel;
    CCRole roleNow = [[CCStreamerBasic sharedStreamer]getRoomInfo].user_role;
    //助教事件
    if (model.type == CCMemberType_Assistant || model.type == CCMemberType_Teacher)
    {
        [self assistantEvent:actionSheet index:buttonIndex];
        return;
    }
    
    //学生事件
    if (roleNow != CCRole_Teacher && roleNow != CCRole_Assistant)
    {
        if (buttonIndex == 0)
        {
            [self student_reward];
        }
        return;
    }
    //防止学生下线取数据失败或者错误
    CCMemberModel *nowModel = [self selectedModelIsOnLine];
    CCUser *user = [self.hdsTool toolGetUserFromUserID:nowModel.userID];
    if (nowModel)
    {
        CCMemberModel *model = self.showModel;
        if (actionSheet.tag == ACTIONSHEETTAGONE)
        {
            if (buttonIndex == (-1 + Index_Offset))
            {
                [self rewardCup];
            }
            else if (buttonIndex == (0 + Index_Offset))
            {
                for (CCUser *user in [[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList)
                {
                    if ([model.userID isEqualToString:user.user_id])
                    {
                        /*
                         传过来的ccVideoView是空的，所以也就无法调用事件
                         */ NSLog(@"~~~~~user.user_id:%@~~~~user_uid:%@~~~~~model.userID:%@~~~~~~self.ccVideoView:%@",user.user_id,user.user_uid,model.userID,self.ccVideoView);
                        if (user.user_drawState)
                        {
                            //取消对某个学生的标注功能
                            [self.ccVideoView cancleAuthUserDraw:user.user_id];
                            
                        }
                        else
                        {
                            //对某个学生授权标注
                            [self.ccVideoView authUserDraw:user.user_id];
                        }
                    }
                }
            }
            else if (buttonIndex == (1 + Index_Offset))
            {
                if (nowModel.micType == CCUserMicStatus_Connected || nowModel.micType == CCUserMicStatus_Connecting)
                {
                    
                    [[CCBarleyManager sharedBarley] kickUserFromSpeak:model.userID completion:^(BOOL result, NSError *error, id info) {
                        
                        if (result)
                        {
                            NSLog(@"kickUser:%@ success", model.userID);
                        }
                        else
                        {
                            NSLog(@"kickUser Fail:%@", error);
                        }
                    }];
                    
                }
                else
                {
                    //学生已不在麦上
                    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"" message:@"学生已经下麦" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                    [view show];
                }
            }
            else if(buttonIndex == (2 + Index_Offset))
            {
                if (model.isMute)
                {
                    //取消对某个学生禁言
                    [[CCChatManager sharedChat] recoveGagUser:model.userID];
                }
                else
                {
                    //对某个学生禁言
                    [[CCChatManager sharedChat] gagUser:model.userID];
                    
                }
            }
            else if (buttonIndex == (3 + + Index_Offset))
            {
                [[CCStreamerBasic sharedStreamer] kickUserFromRoom:model.userID];
            }
            else if (buttonIndex == (4+ Index_Offset))
            {
                if (user.user_AssistantState)
                {
                    //取消对某个学生的设为讲师
                    [self.ccVideoView cancleAuthUserAsTeacher:nowModel.userID];
                    
                }
                else
                {
                    //对某个学生的设为讲师
                    [self.ccVideoView authUserAsTeacher:nowModel.userID];
                    
                }
            }
        }
        else if (actionSheet.tag == ACTIONSHEETTAGTWO)
        {
            if (buttonIndex == (-1 + Index_Offset))
            {
                [self rewardCup];
            }
            else if (buttonIndex == (0+ Index_Offset))
            {
                for (CCUser *user in [[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList)
                {
                    if ([model.userID isEqualToString:user.user_id])
                    {
                        if (user.user_drawState)
                        {
                            //取消对某个学生的标注功能
                            [self.ccVideoView cancleAuthUserDraw:user.user_id];
                        }
                        else
                        {
                            //对某个学生授权标注功能
                            [self.ccVideoView authUserDraw:user.user_id];
                            
                            
                        }
                    }
                }
            }
            else if (buttonIndex == (1+ Index_Offset))
            {
                if (nowModel.micType == CCUserMicStatus_None)
                {
                    //老师邀请没有举手学生连麦(只对老师有效)
                    [[CCBarleyManager sharedBarley] inviteUserSpeak:model.userID completion:^(BOOL result, NSError *error, id info) {
                        NSLog(@"%s__%@__%@__%@", __func__, @(result), error, info);
                        if (!result)
                        {
                            NSString *message = [CCTool toolErrorMessage:error];
                            [UIAlertView bk_showAlertViewWithTitle:@"" message:message cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                
                            }];
                        }
                    }];
                }
                else
                {
                    [[CCBarleyManager sharedBarley] certainHandup:model.userID completion:^(BOOL result, NSError *error, id info) {
                        NSLog(@"%s__%@__%@__%@", __func__, @(result), error, info);
                        if (!result)
                        {
                            NSString *message = [CCTool toolErrorMessage:error];
                            [UIAlertView bk_showAlertViewWithTitle:@"" message:message cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                
                            }];
                        }
                    }];
                    
                }
            }
            else if (buttonIndex == (2+ Index_Offset))
            {
                if (model.isMute)
                {
                    //取消对某个学生禁言
                    [[CCChatManager sharedChat] recoveGagUser:model.userID];
                }
                else
                {
                    //对某个学生禁言
                    BOOL isSuccess = [[CCChatManager sharedChat] gagUser:model.userID];
                    NSLog(@"isSuccess == %d", isSuccess);
                }
            }
            else if (buttonIndex == (3+ Index_Offset))
            {
                [[CCStreamerBasic sharedStreamer] kickUserFromRoom:model.userID];
            }
            else if (buttonIndex == (4+ Index_Offset))
            {
                if (user.user_AssistantState)
                {
                    //取消对某个学生的设为讲师
                    [self.ccVideoView cancleAuthUserAsTeacher:nowModel.userID];
                }
                else
                {
                    //对某个学生设为讲师
                    [self.ccVideoView authUserAsTeacher:nowModel.userID];
                }
            }
        }
        else if (actionSheet.tag == ACTIONSHEETTAGTHTREE)
        {
            if (buttonIndex == (-1 + Index_Offset))
            {
                [self rewardCup];
            }
            else if (buttonIndex == (0+ Index_Offset))
            {
                for (CCUser *user in [[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList)
                {
                    if ([model.userID isEqualToString:user.user_id])
                    {
                        if (user.user_drawState)
                        {
                            //取消授权标注
                            [self.ccVideoView cancleAuthUserDraw:user.user_id];
                        }
                        else
                        {
                            //添加授权标注
                            [self.ccVideoView authUserDraw:user.user_id];
                        }
                    }
                }
            }
            else if (buttonIndex == (1+ Index_Offset))
            {
                if (nowModel.micType == CCUserMicStatus_Wait)
                {
                    //同意举手学生连麦
                    [[CCBarleyManager sharedBarley] certainHandup:model.userID completion:^(BOOL result, NSError *error, id info) {
                        NSLog(@"%s__%@__%@__%@", __func__, @(result), error, info);
                        if (!result)
                        {
                            NSString *message = [CCTool toolErrorMessage:error];
                            [UIAlertView bk_showAlertViewWithTitle:@"" message:message cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                            }];
                        }
                    }];
                }
                else
                {
                    //学生已取消举手
                    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"" message:@"学生已经取消排麦" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                    [view show];
                }
            }
            else if (buttonIndex == (2+ Index_Offset))
            {
                if (model.isMute)
                {
                    [[CCChatManager sharedChat] recoveGagUser:model.userID];
                }
                else
                {
                    [[CCChatManager sharedChat] gagUser:model.userID];
                }
            }
            else if (buttonIndex == (3+ Index_Offset))
            {
                [[CCStreamerBasic sharedStreamer] kickUserFromRoom:model.userID];
            }
            else if (buttonIndex == (4+ Index_Offset))
            {
                if (user.user_AssistantState)
                {
                    [self.ccVideoView cancleAuthUserAsTeacher:nowModel.userID];
                }
                else
                {
                    [self.ccVideoView authUserAsTeacher:nowModel.userID];
                }
            }
        }
        else if (actionSheet.tag == ACTIONSHEETTAGFOUR)
        {
            if (buttonIndex == (-1 + Index_Offset))
            {
                [self rewardCup];
            }
            else if (buttonIndex == (0+ Index_Offset))
            {
                for (CCUser *user in [[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList)
                {
                    if ([model.userID isEqualToString:user.user_id])
                    {
                        if (user.user_drawState)
                        {
                            [self.ccVideoView cancleAuthUserDraw:nowModel.userID];
                            
                        }
                        else
                        {
                            [self.ccVideoView authUserDraw:nowModel.userID];
                        }
                    }
                }
            }
            else if (buttonIndex == (1+ Index_Offset))
            {
                if (nowModel.micType == CCUserMicStatus_Inviteing)
                {
                    //老师取消对学生的上麦邀请
                    [[CCBarleyManager sharedBarley] cancleInviteUserSpeak:model.userID completion:^(BOOL result, NSError *error, id info) {
                        NSLog(@"%s__%@__%@__%@", __func__, @(result), error, info);
                    }];
                }
                else
                {
                    //学生已经不是邀请中
                    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"" message:@"学生已经不是邀请中" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                    [view show];
                }
            }
            else if (buttonIndex == (2+ Index_Offset))
            {
                if (model.isMute)
                {
                    [[CCChatManager sharedChat] recoveGagUser:model.userID];
                }
                else
                {
                    [[CCChatManager sharedChat] gagUser:model.userID];
                }
            }
            else if (buttonIndex == (3+ Index_Offset))
            {
                [[CCStreamerBasic sharedStreamer] kickUserFromRoom:model.userID];
            }
            else if (buttonIndex == (4+ Index_Offset))
            {
                if (user.user_AssistantState)
                {
                    [self.ccVideoView cancleAuthUserAsTeacher:nowModel.userID];
                }
                else
                {
                    [self.ccVideoView authUserAsTeacher:nowModel.userID];
                }
            }
        }
        else if (actionSheet.tag == ACTIONSHEETTAGFIVE)
        {
            if (buttonIndex == (-1 + Index_Offset))
            {
                [self rewardCup];
            }
            else if (buttonIndex == (0+ Index_Offset))
            {
                for (CCUser *user in [[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList)
                {
                    if ([model.userID isEqualToString:user.user_id])
                    {
                        if (user.user_drawState)
                        {
                            [self.ccVideoView cancleAuthUserDraw:user.user_id];
                        }
                        else
                        {
                            [self.ccVideoView authUserDraw:user.user_id];
                        }
                    }
                }
            }
            else if (buttonIndex == (1+ Index_Offset))
            {
                //                BOOL mute = [[CCStreamerBasic sharedStreamer] getAudienceChatStatus:model.userID];
                //                BOOL mute = [[CCChatManager sharedChat] isUserGag];
                if (model.isMute)
                {
                    [[CCChatManager sharedChat] recoveGagUser:model.userID];
                }
                else
                {
                    [[CCChatManager sharedChat] gagUser:model.userID];
                }
            }
            else if (buttonIndex == (2+ Index_Offset))
            {
                [[CCStreamerBasic sharedStreamer] kickUserFromRoom:model.userID];
            }
            else if (buttonIndex == (3+ Index_Offset))
            {
                if (user.user_AssistantState)
                {
                    [self.ccVideoView cancleAuthUserAsTeacher:nowModel.userID];
                }
                else
                {
                    [self.ccVideoView authUserAsTeacher:nowModel.userID];
                }
            }
        }
        else if (actionSheet.tag == ACTIONSHEETTAGSIX)
        {
            if (buttonIndex == 0)
            {
                //                BOOL mute = [[CCStreamerBasic sharedStreamer] getAudienceChatStatus:model.userID];
                //                BOOL mute = [[CCChatManager sharedChat] isUserGag];
                
                if (model.isMute)
                {
                    [[CCChatManager sharedChat] recoveGagUser:model.userID];
                }
                else
                {
                    [[CCChatManager sharedChat] gagUser:model.userID];
                }
            }
            else if (buttonIndex == 1)
            {
                [[CCStreamerBasic sharedStreamer] kickUserFromRoom:model.userID];
            }
            else if (buttonIndex == 2)
            {
                if (user.user_AssistantState)
                {
                    [self.ccVideoView cancleAuthUserAsTeacher:nowModel.userID];
                }
                else
                {
                    [self.ccVideoView authUserAsTeacher:nowModel.userID];
                }
            }
        }
        else if (actionSheet.tag == ACTIONSHEETTAGSEVEN)
        {
            if (buttonIndex == (-1 + Index_Offset))
            {
                [self rewardCup];
            }
            else if (buttonIndex == (0+ Index_Offset))
            {
                for (CCUser *user in [[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList)
                {
                    if ([model.userID isEqualToString:user.user_id])
                    {
                        if (user.user_drawState)
                        {
                            [self.ccVideoView cancleAuthUserDraw:user.user_id];
                        }
                        else
                        {
                            [self.ccVideoView authUserDraw:user.user_id];
                        }
                    }
                }
            }
            else if (buttonIndex == (1+ Index_Offset))
            {
                [[CCBarleyManager sharedBarley] certainHandup:model.userID completion:^(BOOL result, NSError *error, id info) {
                    NSLog(@"%s__%@__%@__%@", __func__, @(result), error, info);
                    if (!result)
                    {
                        NSString *message = [CCTool toolErrorMessage:error];
                        [UIAlertView bk_showAlertViewWithTitle:@"" message:message cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                            
                        }];
                    }
                }];
            }
            else if (buttonIndex == (2+ Index_Offset))
            {
                if (model.isMute)
                {
                    [[CCChatManager sharedChat] recoveGagUser:model.userID];
                }
                else
                {
                    [[CCChatManager sharedChat] gagUser:model.userID];
                }
            }
            else if (buttonIndex == (3+ Index_Offset))
            {
                [[CCStreamerBasic sharedStreamer] kickUserFromRoom:model.userID];
            }
            else if (buttonIndex == (4+ Index_Offset))
            {
                if (user.user_AssistantState)
                {
                    [self.ccVideoView cancleAuthUserAsTeacher:nowModel.userID];
                }
                else
                {
                    [self.ccVideoView authUserAsTeacher:nowModel.userID];
                }
            }
        }
        
        if (block)
        {
            block(YES, nil);
        }
    }
    else
    {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"" message:@"学生已经下线" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [view show];
    }
}

//发送奖杯
- (void)rewardCup
{
    CCMemberModel *nowModel = [self selectedModelIsOnLine];
    CCUser *user = [self.hdsTool toolGetUserFromUserID:nowModel.userID];
    
    NSString *uid = user.user_id;
    NSString *uname = user.user_name;
    NSString *type = @"cup";
    NSString *sid = [[CCStreamerBasic sharedStreamer]getRoomInfo].user_id;
    //鲜花奖杯接口找不到
    [[CCStreamerBasic sharedStreamer]rewardUid:uid uName:uname type:type sender:sid];
}

- (NSString *)getDrawTitleWithModel:(CCMemberModel *)model
{
    NSString *title = @"授权标注";
    for (CCUser *user in [[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList)
    {
        if ([user.user_id isEqualToString:model.userID])
        {
            title = user.user_drawState ? @"取消授权标注" : @"授权标注";
            break;
        }
    }
    return title;
}

- (CCMemberModel *)selectedModelIsOnLine
{
    NSArray *list = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList;
    for (CCUser *model in list)
    {
        if ([model.user_id isEqualToString:self.showModel.userID])
        {
            CCMemberModel *newModel = [[CCMemberModel alloc] initWithUser:model];
            return newModel;
        }
    }
    if (self.showModel.type == CCMemberType_Audience)
    {
        return self.showModel;
    }
    return nil;
}

- (CCMemberModel *)modelWithUserID:(NSString *)userID
{
    NSArray *list = [[CCStreamerBasic sharedStreamer] getRoomInfo].room_userList;
    for (CCUser *model in list)
    {
        if ([model.user_id isEqualToString:userID])
        {
            CCMemberModel *newModel = [[CCMemberModel alloc] initWithUser:model];
            return newModel;
        }
    }
    CCMemberModel *model = [[CCMemberModel alloc] init];
    model.type = CCMemberType_Audience;
    model.userID = userID;
    return model;
}

//========
/*处理老师的actionsheet操作*/
- (void)studentCallWithUserID:(NSString *)userID inView:(UIView *)view dismiss:(CCStudentActionManagerBlock)completion
{
    if ([[CCStreamerBasic sharedStreamer] getRoomInfo].user_role == CCRole_Teacher)
    {
        return;
    }
    CCMemberModel *model = [self modelWithUserID:userID];
    if (model.type != CCMemberType_Teacher)
    {
        return;
    }
    [self studentCallWithModel:model inView:view dismiss:completion];
}
- (void)studentCallWithModel:(CCMemberModel *)model inView:(UIView *)view dismiss:(CCStudentActionManagerBlock)completion
{
    self.showModel = model;
    block = completion;
#define CC_Flower  @"赠送鲜花"
    __weak typeof(self) weakSelf = self;
    NSArray *titleArray;
    titleArray = @[CC_Flower];
    
    if (titleArray.count > 0)
    {
        [LCActionSheetConfig shared].buttonColor = CCRGBColor(242, 124, 25);
        [LCActionSheetConfig shared].cancleBtnColor = [UIColor blackColor];
        [LCActionSheetConfig shared].buttonFont = [UIFont systemFontOfSize:FontSizeClass_16];
        LCActionSheet *actionSheet = [LCActionSheet sheetWithTitle:nil cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
            buttonIndex--;
            [weakSelf actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
        } otherButtonTitleArray:titleArray];
        actionSheet.tag = ACTIONSHEETTAGEIGHT;
        actionSheet.scrolling          = YES;
        actionSheet.visibleButtonCount = 3.6f;
        [actionSheet show];
    }
}
//学生发送鲜花
- (void)student_reward
{
    /*
     CCRoom *room = [[CCStreamerBasic sharedStreamer]getRoomInfo];
     if (room.user_role != CCRole_Student || room.live_status != CCLiveStatus_Start)
     {
     return;
     }
     CCMemberModel *nowModel = [self selectedModelIsOnLine];
     CCUser *user = [self.hdsTool toolGetUserFromUserID:nowModel.userID];

     NSString *uid = user.user_id;
     NSString *uname = user.user_name;
     NSString *type = @"flower";
     NSString *sid = room.user_id;
     //找不到方法
     [[CCStreamerBasic sharedStreamer]rewardUid:uid uName:uname type:type sender:sid];
     [CCRewardView addTimeLimit];
     */
}

#pragma mark -- 助教响应事件
/* 处理助教的actionsheet操作 */
- (void)assistant:(BOOL)published call:(NSString *)userID inView:(UIView *)view dismiss:(CCStudentActionManagerBlock)completion
{
    CCMemberModel *model = [self modelWithUserID:userID];
    [self assistant:published callModel:model inView:view dismiss:completion];
}
- (void)assistant:(BOOL)published callModel:(CCMemberModel *)model inView:(UIView *)view dismiss:(CCStudentActionManagerBlock)completion
{
    self.showModel = model;
    block = completion;
    __weak typeof(self) weakSelf = self;
    NSArray *titleArray;
    //暂时弃用
    //    if (published)
    //    {
    //        titleArray = @[@"下麦"];
    //    }
    //    else
    //    {
    //        titleArray = @[@"上麦"];
    //    }
    NSString *title = model.isMute ? @"解除禁言" : @"禁言";
    titleArray = @[title,@"踢出房间"];
    
    if (titleArray.count > 0)
    {
        [LCActionSheetConfig shared].buttonColor = CCRGBColor(242, 124, 25);
        [LCActionSheetConfig shared].cancleBtnColor = [UIColor blackColor];
        [LCActionSheetConfig shared].buttonFont = [UIFont systemFontOfSize:FontSizeClass_16];
        LCActionSheet *actionSheet = [LCActionSheet sheetWithTitle:nil cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
            buttonIndex--;
            [weakSelf actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
        } otherButtonTitleArray:titleArray];
        actionSheet.tag = ACTIONSHEETTAGEIGHT;
        actionSheet.scrolling          = YES;
        actionSheet.visibleButtonCount = 3.6f;
        [actionSheet show];
    }
}
//助教响应事件
- (void)assistantEvent:(LCActionSheet *)actionSheet index:(NSInteger)index
{
    CCMemberModel *model = self.showModel;
    NSLog(@"assistantEvent__index__%ld",(long)index);
    //禁言、解除禁言
    if (index == 0)
    {
        if (model.isMute)
        {
            [[CCChatManager sharedChat] recoveGagUser:model.userID];
        }
        else
        {
            [[CCChatManager sharedChat] gagUser:model.userID];
        }
    }
    //踢出房间
    if (index == 1)
    {
        [[CCStreamerBasic sharedStreamer] kickUserFromRoom:model.userID];
    }
}

@end
