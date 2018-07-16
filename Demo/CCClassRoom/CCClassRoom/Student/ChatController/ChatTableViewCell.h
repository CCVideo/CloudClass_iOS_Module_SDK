//
//  ChatTableViewCell.h
//  CCClassRoom
//
//  Created by cc on 18/7/13.
//  Copyright © 2018年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,RoleType) {
    RoleType_Teacher,
    RoleType_Student,
    RoleType_Unknow
};

@interface ChatTableViewCell : UITableViewCell
#pragma mark strong
@property(nonatomic,strong)UILabel *labelType;

#pragma mark strong
@property(nonatomic,strong)UILabel *labelName;
#pragma mark strong
@property(nonatomic,strong)UIImageView *imageV;

- (void)setRole:(RoleType)role;

@end
