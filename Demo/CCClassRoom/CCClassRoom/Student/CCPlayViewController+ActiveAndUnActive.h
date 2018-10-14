//
//  CCStreamer+ActiveAndUnActive.h
//  CCStreamer
//
//  Created by cc on 17/2/7.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCPlayViewController.h"

@interface CCPlayViewController (ActiveAndUnActive)

-(void)addObserver_push;
-(void)removeObserver_push;
- (void)rotateOri1:(BOOL)chaned;
@end
