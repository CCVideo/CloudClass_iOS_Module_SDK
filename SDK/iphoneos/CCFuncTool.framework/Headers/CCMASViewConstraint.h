//
//  CCMASViewConstraint.h
//  CCMASonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CCMASViewAttribute.h"
#import "CCMASConstraint.h"
#import "CCMASLayoutConstraint.h"
#import "CCMASUtilities.h"

/**
 *  A single constraint.
 *  Contains the attributes neccessary for creating a NSLayoutConstraint and adding it to the appropriate view
 */
@interface CCMASViewConstraint : CCMASConstraint <NSCopying>

/**
 *	First item/view and first attribute of the NSLayoutConstraint
 */
@property (nonatomic, strong, readonly) CCMASViewAttribute *firstViewAttribute;

/**
 *	Second item/view and second attribute of the NSLayoutConstraint
 */
@property (nonatomic, strong, readonly) CCMASViewAttribute *secondViewAttribute;

/**
 *	initialises the CCMASViewConstraint with the first part of the equation
 *
 *	@param	firstViewAttribute	view.CCMAS_left, view.CCMAS_width etc.
 *
 *	@return	a new view constraint
 */
- (id)initWithFirstViewAttribute:(CCMASViewAttribute *)firstViewAttribute;

/**
 *  Returns all CCMASViewConstraints installed with this view as a first item.
 *
 *  @param  view  A view to retrieve constraints for.
 *
 *  @return An array of CCMASViewConstraints.
 */
+ (NSArray *)installedConstraintsForView:(CCMAS_VIEW *)view;

@end
