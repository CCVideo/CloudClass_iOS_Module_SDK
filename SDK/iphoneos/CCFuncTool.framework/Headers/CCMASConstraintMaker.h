//
//  CCMASConstraintMaker.h
//  CCMASonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CCMASConstraint.h"
#import "CCMASUtilities.h"

typedef NS_OPTIONS(NSInteger, CCMASAttribute) {
    CCMASAttributeLeft = 1 << NSLayoutAttributeLeft,
    CCMASAttributeRight = 1 << NSLayoutAttributeRight,
    CCMASAttributeTop = 1 << NSLayoutAttributeTop,
    CCMASAttributeBottom = 1 << NSLayoutAttributeBottom,
    CCMASAttributeLeading = 1 << NSLayoutAttributeLeading,
    CCMASAttributeTrailing = 1 << NSLayoutAttributeTrailing,
    CCMASAttributeWidth = 1 << NSLayoutAttributeWidth,
    CCMASAttributeHeight = 1 << NSLayoutAttributeHeight,
    CCMASAttributeCenterX = 1 << NSLayoutAttributeCenterX,
    CCMASAttributeCenterY = 1 << NSLayoutAttributeCenterY,
    CCMASAttributeBaseline = 1 << NSLayoutAttributeBaseline,
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    
    CCMASAttributeFirstBaseline = 1 << NSLayoutAttributeFirstBaseline,
    CCMASAttributeLastBaseline = 1 << NSLayoutAttributeLastBaseline,
    
#endif
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)
    
    CCMASAttributeLeftMargin = 1 << NSLayoutAttributeLeftMargin,
    CCMASAttributeRightMargin = 1 << NSLayoutAttributeRightMargin,
    CCMASAttributeTopMargin = 1 << NSLayoutAttributeTopMargin,
    CCMASAttributeBottomMargin = 1 << NSLayoutAttributeBottomMargin,
    CCMASAttributeLeadingMargin = 1 << NSLayoutAttributeLeadingMargin,
    CCMASAttributeTrailingMargin = 1 << NSLayoutAttributeTrailingMargin,
    CCMASAttributeCenterXWithinMargins = 1 << NSLayoutAttributeCenterXWithinMargins,
    CCMASAttributeCenterYWithinMargins = 1 << NSLayoutAttributeCenterYWithinMargins,

#endif
    
};

/**
 *  Provides factory methods for creating CCMASConstraints.
 *  Constraints are collected until they are ready to be installed
 *
 */
@interface CCMASConstraintMaker : NSObject

/**
 *	The following properties return a new CCMASViewConstraint
 *  with the first item set to the makers associated view and the appropriate CCMASViewAttribute
 */
@property (nonatomic, strong, readonly) CCMASConstraint *left;
@property (nonatomic, strong, readonly) CCMASConstraint *top;
@property (nonatomic, strong, readonly) CCMASConstraint *right;
@property (nonatomic, strong, readonly) CCMASConstraint *bottom;
@property (nonatomic, strong, readonly) CCMASConstraint *leading;
@property (nonatomic, strong, readonly) CCMASConstraint *trailing;
@property (nonatomic, strong, readonly) CCMASConstraint *width;
@property (nonatomic, strong, readonly) CCMASConstraint *height;
@property (nonatomic, strong, readonly) CCMASConstraint *centerX;
@property (nonatomic, strong, readonly) CCMASConstraint *centerY;
@property (nonatomic, strong, readonly) CCMASConstraint *baseline;

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) CCMASConstraint *firstBaseline;
@property (nonatomic, strong, readonly) CCMASConstraint *lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) CCMASConstraint *leftMargin;
@property (nonatomic, strong, readonly) CCMASConstraint *rightMargin;
@property (nonatomic, strong, readonly) CCMASConstraint *topMargin;
@property (nonatomic, strong, readonly) CCMASConstraint *bottomMargin;
@property (nonatomic, strong, readonly) CCMASConstraint *leadingMargin;
@property (nonatomic, strong, readonly) CCMASConstraint *trailingMargin;
@property (nonatomic, strong, readonly) CCMASConstraint *centerXWithinMargins;
@property (nonatomic, strong, readonly) CCMASConstraint *centerYWithinMargins;

#endif

/**
 *  Returns a block which creates a new CCMASCompositeConstraint with the first item set
 *  to the makers associated view and children corresponding to the set bits in the
 *  CCMASAttribute parameter. Combine multiple attributes via binary-or.
 */
@property (nonatomic, strong, readonly) CCMASConstraint *(^attributes)(CCMASAttribute attrs);

/**
 *	Creates a CCMASCompositeConstraint with type CCMASCompositeConstraintTypeEdges
 *  which generates the appropriate CCMASViewConstraint children (top, left, bottom, right)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) CCMASConstraint *edges;

/**
 *	Creates a CCMASCompositeConstraint with type CCMASCompositeConstraintTypeSize
 *  which generates the appropriate CCMASViewConstraint children (width, height)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) CCMASConstraint *size;

/**
 *	Creates a CCMASCompositeConstraint with type CCMASCompositeConstraintTypeCenter
 *  which generates the appropriate CCMASViewConstraint children (centerX, centerY)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) CCMASConstraint *center;

/**
 *  Whether or not to check for an existing constraint instead of adding constraint
 */
@property (nonatomic, assign) BOOL updateExisting;

/**
 *  Whether or not to remove existing constraints prior to installing
 */
@property (nonatomic, assign) BOOL removeExisting;

/**
 *	initialises the maker with a default view
 *
 *	@param	view	any CCMASConstraint are created with this view as the first item
 *
 *	@return	a new CCMASConstraintMaker
 */
- (id)initWithView:(CCMAS_VIEW *)view;

/**
 *	Calls install method on any CCMASConstraints which have been created by this maker
 *
 *	@return	an array of all the installed CCMASConstraints
 */
- (NSArray *)install;

- (CCMASConstraint * (^)(dispatch_block_t))group;

@end
