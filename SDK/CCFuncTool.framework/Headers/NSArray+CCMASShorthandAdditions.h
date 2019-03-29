//
//  NSArray+CCMASShorthandAdditions.h
//  CCMASonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "NSArray+CCMASAdditions.h"

#ifdef CCMAS_SHORTHAND

/**
 *	Shorthand array additions without the 'CCMAS_' prefixes,
 *  only enabled if CCMAS_SHORTHAND is defined
 */
@interface NSArray (CCMASShorthandAdditions)

- (NSArray *)makeConstraints:(void(^)(CCMASConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(CCMASConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void(^)(CCMASConstraintMaker *make))block;

@end

@implementation NSArray (CCMASShorthandAdditions)

- (NSArray *)makeConstraints:(void(^)(CCMASConstraintMaker *))block {
    return [self CCMAS_makeConstraints:block];
}

- (NSArray *)updateConstraints:(void(^)(CCMASConstraintMaker *))block {
    return [self CCMAS_updateConstraints:block];
}

- (NSArray *)remakeConstraints:(void(^)(CCMASConstraintMaker *))block {
    return [self CCMAS_remakeConstraints:block];
}

@end

#endif
