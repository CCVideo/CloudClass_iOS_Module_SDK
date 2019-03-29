//
//  CCServerListViewController.h
//  CCClassRoom
//
//  Created by cc on 17/8/21.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCBaseTableViewController.h"

@interface CCServerListViewController : CCBaseTableViewController
@property (strong, nonatomic) NSArray *serverList;
@property (strong, nonatomic) NSString *accountID;
@end

@interface CCServerModel : NSObject
@property (strong, nonatomic) NSString *serverName;//名称
@property (strong, nonatomic) NSString *serverStatus;//网络状态
@property (assign, nonatomic) double serverDelay;//延迟
@property (strong, nonatomic) NSString *serverDomain;//域名
@property (strong, nonatomic) UIColor *statusColor;
@property (assign, nonatomic) float serverScale;
@property (strong, nonatomic) NSString *area_name;//节点地域
@end
