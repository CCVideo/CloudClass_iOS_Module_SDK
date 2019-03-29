//
//  UIView+CCMASShorthandAdditions.h
//  CCMASonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "View+CCMASAdditions.h"

#ifdef CCMAS_SHORTHAND

/**
 *	Shorthand view additions without the 'CCMAS_' prefixes,
 *  only enabled if CCMAS_SHORTHAND is defined
 */
@interface CCMAS_VIEW (CCMASShorthandAdditions)

@property (nonatomic, strong, readonly) CCMASViewAttribute *left;
@property (nonatomic, strong, readonly) CCMASViewAttribute *top;
@property (nonatomic, strong, readonly) CCMASViewAttribute *right;
@property (nonatomic, strong, readonly) CCMASViewAttribute *bottom;
@property (nonatomic, strong, readonly) CCMASViewAttribute *leading;
@property (nonatomic, strong, readonly) CCMASViewAttribute *trailing;
@property (nonatomic, strong, readonly) CCMASViewAttribute *width;
@property (nonatomic, strong, readonly) CCMASViewAttribute *height;
@property (nonatomic, strong, readonly) CCMASViewAttribute *centerX;
@property (nonatomic, strong, readonly) CCMASViewAttribute *centerY;
@property (nonatomic, strong, readonly) CCMASViewAttribute *baseline;
@property (nonatomic, strong, readonly) CCMASViewAttribute *(^attribute)(NSLayoutAttribute attr);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) CCMASViewAttribute *firstBaseline;
@property (nonatomic, strong, readonly) CCMASViewAttribute *lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) CCMASViewAttribute *leftMargin;
@property (nonatomic, strong, readonly) CCMASViewAttribute *rightMargin;
@property (nonatomic, strong, readonly) CCMASViewAttribute *topMargin;
@property (nonatomic, strong, readonly) CCMASViewAttribute *bottomMargin;
@property (nonatomic, strong, readonly) CCMASViewAttribute *leadingMargin;
@property (nonatomic, strong, readonly) CCMASViewAttribute *trailingMargin;
@property (nonatomic, strong, readonly) CCMASViewAttribute *centerXWithinMargins;
@property (nonatomic, strong, readonly) CCMASViewAttribute *centerYWithinMargins;

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

@property (nonatomic, strong, readonly) CCMASViewAttribute *safeAreaLayoutGuideTop API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) CCMASViewAttribute *safeAreaLayoutGuideBottom API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) CCMASViewAttribute *safeAreaLayoutGuideLeft API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) CCMASViewAttribute *safeAreaLayoutGuideRight API_AVAILABLE(ios(11.0),tvos(11.0));

#endif

- (NSArray *)makeConstraints:(void(^)(CCMASConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(CCMASConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void(^)(CCMASConstraintMaker *make))block;

@end

#define CCMAS_ATTR_FORWARD(attr)  \
- (CCMASViewAttribute *)attr {    \
    return [self CCMAS_##attr];   \
}

@implementation CCMAS_VIEW (CCMASShorthandAdditions)

CCMAS_ATTR_FORWARD(top);
CCMAS_ATTR_FORWARD(left);
CCMAS_ATTR_FORWARD(bottom);
CCMAS_ATTR_FORWARD(right);
CCMAS_ATTR_FORWARD(leading);
CCMAS_ATTR_FORWARD(trailing);
CCMAS_ATTR_FORWARD(width);
CCMAS_ATTR_FORWARD(height);
CCMAS_ATTR_FORWARD(centerX);
CCMAS_ATTR_FORWARD(centerY);
CCMAS_ATTR_FORWARD(baseline);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

CCMAS_ATTR_FORWARD(firstBaseline);
CCMAS_ATTR_FORWARD(lastBaseline);

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

CCMAS_ATTR_FORWARD(leftMargin);
CCMAS_ATTR_FORWARD(rightMargin);
CCMAS_ATTR_FORWARD(topMargin);
CCMAS_ATTR_FORWARD(bottomMargin);
CCMAS_ATTR_FORWARD(leadingMargin);
CCMAS_ATTR_FORWARD(trailingMargin);
CCMAS_ATTR_FORWARD(centerXWithinMargins);
CCMAS_ATTR_FORWARD(centerYWithinMargins);

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

CCMAS_ATTR_FORWARD(safeAreaLayoutGuideTop);
CCMAS_ATTR_FORWARD(safeAreaLayoutGuideBottom);
CCMAS_ATTR_FORWARD(safeAreaLayoutGuideLeft);
CCMAS_ATTR_FORWARD(safeAreaLayoutGuideRight);

#endif

- (CCMASViewAttribute *(^)(NSLayoutAttribute))attribute {
    return [self CCMAS_attribute];
}

- (NSArray *)makeConstraints:(void(NS_NOESCAPE ^)(CCMASConstraintMaker *))block {
    return [self CCMAS_makeConstraints:block];
}

- (NSArray *)updateConstraints:(void(NS_NOESCAPE ^)(CCMASConstraintMaker *))block {
    return [self CCMAS_updateConstraints:block];
}

- (NSArray *)remakeConstraints:(void(NS_NOESCAPE ^)(CCMASConstraintMaker *))block {
    return [self CCMAS_remakeConstraints:block];
}

@end

#endif
