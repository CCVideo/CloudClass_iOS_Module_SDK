//
//  CCPublicImgTableViewCell.h
//  CCClassRoom
//
//  Created by 刘强强 on 2020/3/23.
//  Copyright © 2020 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dialogue.h"
#import "CCPublicTableViewCell.h"


NS_ASSUME_NONNULL_BEGIN


@interface CCPublicImgTableViewCell : UITableViewCell
-(void)reloadWithDialogue:(Dialogue *)dialogue antesomeone:(AnteSomeone)atsoBlock;
@end

NS_ASSUME_NONNULL_END
