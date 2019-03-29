//
//  CCMASConstraint.h
//  CCMASonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CCMASUtilities.h"

/**
 *	Enables Constraints to be created with chainable syntax
 *  Constraint can represent single NSLayoutConstraint (CCMASViewConstraint)
 *  or a group of NSLayoutConstraints (MASComposisteConstraint)
 */
@interface CCMASConstraint : NSObject

// Chaining Support

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects CCMASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (CCMASConstraint * (^)(CCMASEdgeInsets insets))insets;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects CCMASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (CCMASConstraint * (^)(CGFloat inset))inset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects CCMASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeWidth, NSLayoutAttributeHeight
 */
- (CCMASConstraint * (^)(CGSize offset))sizeOffset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects CCMASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeCenterX, NSLayoutAttributeCenterY
 */
- (CCMASConstraint * (^)(CGPoint offset))centerOffset;

/**
 *	Modifies the NSLayoutConstraint constant
 */
- (CCMASConstraint * (^)(CGFloat offset))offset;

/**
 *  Modifies the NSLayoutConstraint constant based on a value type
 */
- (CCMASConstraint * (^)(NSValue *value))valueOffset;

/**
 *	Sets the NSLayoutConstraint multiplier property
 */
- (CCMASConstraint * (^)(CGFloat multiplier))multipliedBy;

/**
 *	Sets the NSLayoutConstraint multiplier to 1.0/dividedBy
 */
- (CCMASConstraint * (^)(CGFloat divider))dividedBy;

/**
 *	Sets the NSLayoutConstraint priority to a float or CCMASLayoutPriority
 */
- (CCMASConstraint * (^)(CCMASLayoutPriority priority))priority;

/**
 *	Sets the NSLayoutConstraint priority to CCMASLayoutPriorityLow
 */
- (CCMASConstraint * (^)(void))priorityLow;

/**
 *	Sets the NSLayoutConstraint priority to CCMASLayoutPriorityMedium
 */
- (CCMASConstraint * (^)(void))priorityMedium;

/**
 *	Sets the NSLayoutConstraint priority to CCMASLayoutPriorityHigh
 */
- (CCMASConstraint * (^)(void))priorityHigh;

/**
 *	Sets the constraint relation to NSLayoutRelationEqual
 *  returns a block which accepts one of the following:
 *    CCMASViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (CCMASConstraint * (^)(id attr))equalTo;

/**
 *	Sets the constraint relation to NSLayoutRelationGreaterThanOrEqual
 *  returns a block which accepts one of the following:
 *    CCMASViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (CCMASConstraint * (^)(id attr))greaterThanOrEqualTo;

/**
 *	Sets the constraint relation to NSLayoutRelationLessThanOrEqual
 *  returns a block which accepts one of the following:
 *    CCMASViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (CCMASConstraint * (^)(id attr))lessThanOrEqualTo;

/**
 *	Optional semantic property which has no effect but improves the readability of constraint
 */
- (CCMASConstraint *)with;

/**
 *	Optional semantic property which has no effect but improves the readability of constraint
 */
- (CCMASConstraint *)and;

/**
 *	Creates a new CCMASCompositeConstraint with the called attribute and reciever
 */
- (CCMASConstraint *)left;
- (CCMASConstraint *)top;
- (CCMASConstraint *)right;
- (CCMASConstraint *)bottom;
- (CCMASConstraint *)leading;
- (CCMASConstraint *)trailing;
- (CCMASConstraint *)width;
- (CCMASConstraint *)height;
- (CCMASConstraint *)centerX;
- (CCMASConstraint *)centerY;
- (CCMASConstraint *)baseline;

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

- (CCMASConstraint *)firstBaseline;
- (CCMASConstraint *)lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

- (CCMASConstraint *)leftMargin;
- (CCMASConstraint *)rightMargin;
- (CCMASConstraint *)topMargin;
- (CCMASConstraint *)bottomMargin;
- (CCMASConstraint *)leadingMargin;
- (CCMASConstraint *)trailingMargin;
- (CCMASConstraint *)centerXWithinMargins;
- (CCMASConstraint *)centerYWithinMargins;

#endif


/**
 *	Sets the constraint debug name
 */
- (CCMASConstraint * (^)(id key))key;

// NSLayoutConstraint constant Setters
// for use outside of CCMAS_updateConstraints/CCMAS_makeConstraints blocks

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects CCMASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (void)setInsets:(CCMASEdgeInsets)insets;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects CCMASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (void)setInset:(CGFloat)inset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects CCMASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeWidth, NSLayoutAttributeHeight
 */
- (void)setSizeOffset:(CGSize)sizeOffset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects CCMASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeCenterX, NSLayoutAttributeCenterY
 */
- (void)setCenterOffset:(CGPoint)centerOffset;

/**
 *	Modifies the NSLayoutConstraint constant
 */
- (void)setOffset:(CGFloat)offset;


// NSLayoutConstraint Installation support

#if TARGET_OS_MAC && !(TARGET_OS_IPHONE || TARGET_OS_TV)
/**
 *  Whether or not to go through the animator proxy when modifying the constraint
 */
@property (nonatomic, copy, readonly) CCMASConstraint *animator;
#endif

/**
 *  Activates an NSLayoutConstraint if it's supported by an OS. 
 *  Invokes install otherwise.
 */
- (void)activate;

/**
 *  Deactivates previously installed/activated NSLayoutConstraint.
 */
- (void)deactivate;

/**
 *	Creates a NSLayoutConstraint and adds it to the appropriate view.
 */
- (void)install;

/**
 *	Removes previously installed NSLayoutConstraint
 */
- (void)uninstall;

@end


/**
 *  Convenience auto-boxing macros for CCMASConstraint methods.
 *
 *  Defining CCMAS_SHORTHAND_GLOBALS will turn on auto-boxing for default syntax.
 *  A potential drawback of this is that the unprefixed macros will appear in global scope.
 */
#define CCMAS_equalTo(...)                 equalTo(CCMASBoxValue((__VA_ARGS__)))
#define CCMAS_greaterThanOrEqualTo(...)    greaterThanOrEqualTo(CCMASBoxValue((__VA_ARGS__)))
#define CCMAS_lessThanOrEqualTo(...)       lessThanOrEqualTo(CCMASBoxValue((__VA_ARGS__)))

#define CCMAS_offset(...)                  valueOffset(CCMASBoxValue((__VA_ARGS__)))


#ifdef CCMAS_SHORTHAND_GLOBALS

#define equalTo(...)                     CCMAS_equalTo(__VA_ARGS__)
#define greaterThanOrEqualTo(...)        CCMAS_greaterThanOrEqualTo(__VA_ARGS__)
#define lessThanOrEqualTo(...)           CCMAS_lessThanOrEqualTo(__VA_ARGS__)

#define offset(...)                      CCMAS_offset(__VA_ARGS__)

#endif


@interface CCMASConstraint (AutoboxingSupport)

/**
 *  Aliases to corresponding relation methods (for shorthand macros)
 *  Also needed to aid autocompletion
 */
- (CCMASConstraint * (^)(id attr))CCMAS_equalTo;
- (CCMASConstraint * (^)(id attr))CCMAS_greaterThanOrEqualTo;
- (CCMASConstraint * (^)(id attr))CCMAS_lessThanOrEqualTo;

/**
 *  A dummy method to aid autocompletion
 */
- (CCMASConstraint * (^)(id offset))CCMAS_offset;

@end
