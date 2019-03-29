//
//  UIViewController+CCMASAdditions.h
//  CCMASonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "CCMASUtilities.h"
#import "CCMASConstraintMaker.h"
#import "CCMASViewAttribute.h"

#ifdef CCMAS_VIEW_CONTROLLER

@interface CCMAS_VIEW_CONTROLLER (CCMASAdditions)

/**
 *	following properties return a new CCMASViewAttribute with appropriate UILayoutGuide and NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_topLayoutGuide;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_bottomLayoutGuide;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_topLayoutGuideTop;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_topLayoutGuideBottom;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_bottomLayoutGuideTop;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_bottomLayoutGuideBottom;


@end

#endif
