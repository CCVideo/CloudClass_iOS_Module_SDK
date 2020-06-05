//
//  UIView+CCMASAdditions.h
//  CCMASonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CCMASUtilities.h"
#import "CCMASConstraintMaker.h"
#import "CCMASViewAttribute.h"

/**
 *	Provides constraint maker block
 *  and convience methods for creating CCMASViewAttribute which are view + NSLayoutAttribute pairs
 */
@interface CCMAS_VIEW (CCMASAdditions)

/**
 *	following properties return a new CCMASViewAttribute with current view and appropriate NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_left;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_top;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_right;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_bottom;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_leading;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_trailing;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_width;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_height;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_centerX;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_centerY;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_baseline;
@property (nonatomic, strong, readonly) CCMASViewAttribute *(^CCMAS_attribute)(NSLayoutAttribute attr);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_firstBaseline;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_leftMargin;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_rightMargin;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_topMargin;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_bottomMargin;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_leadingMargin;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_trailingMargin;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_centerXWithinMargins;
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_centerYWithinMargins;

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_safeAreaLayoutGuide API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_safeAreaLayoutGuideTop API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_safeAreaLayoutGuideBottom API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_safeAreaLayoutGuideLeft API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) CCMASViewAttribute *CCMAS_safeAreaLayoutGuideRight API_AVAILABLE(ios(11.0),tvos(11.0));

#endif

/**
 *	a key to associate with this view
 */
@property (nonatomic, strong) id CCMAS_key;

/**
 *	Finds the closest common superview between this view and another view
 *
 *	@param	view	other view
 *
 *	@return	returns nil if common superview could not be found
 */
- (instancetype)CCMAS_closestCommonSuperview:(CCMAS_VIEW *)view;

/**
 *  Creates a CCMASConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created CCMASConstraints
 */
- (NSArray *)CCMAS_makeConstraints:(void(NS_NOESCAPE ^)(CCMASConstraintMaker *make))block;

/**
 *  Creates a CCMASConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  If an existing constraint exists then it will be updated instead.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated CCMASConstraints
 */
- (NSArray *)CCMAS_updateConstraints:(void(NS_NOESCAPE ^)(CCMASConstraintMaker *make))block;

/**
 *  Creates a CCMASConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  All constraints previously installed for the view will be removed.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated CCMASConstraints
 */
- (NSArray *)CCMAS_remakeConstraints:(void(NS_NOESCAPE ^)(CCMASConstraintMaker *make))block;

@end
