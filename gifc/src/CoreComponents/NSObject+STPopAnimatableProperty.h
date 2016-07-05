//
// Created by BLACKGENE on 2014. 9. 15..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NSObject (STPopAnimatableProperty)
+ (void)addPopAnimationPropertiesAsCGFloat:(NSArray *)propertiesAsCGFloat;

- (POPAnimation *)st_springCGRect:(CGRect)rectTo keypath:(NSString *)keypath;

- (POPAnimation *)st_springCGRect:(CGRect)rectTo block:(void (^)(id target, CGRect rect))block;

- (POPAnimation *)st_springCGRect:(CGRect)rectTo keypath:(NSString *)keypath3 completion:(void (^)(POPAnimation *anim, BOOL finished))completion;

- (POPAnimation *)st_springCGRect:(CGRect)rectTo block:(void (^)(id, CGRect))block completion:(void (^)(POPAnimation *anim, BOOL finished))completion;

- (POPAnimation *)st_springCGPoint:(CGPoint)pointTo keypath:(NSString *)keypath;

- (POPAnimation *)st_springCGPoint:(CGPoint)pointTo keypath:(NSString *)keypath3 completion:(void (^)(POPAnimation *anim, BOOL finished))completion;

- (POPAnimation *)st_springCGPoint:(CGPoint)pointTo block:(void (^)(id, CGPoint))block;

- (POPAnimation *)st_springCGPoint:(CGPoint)pointTo block:(void (^)(id, CGPoint))block completion:(void (^)(POPAnimation *anim, BOOL finished))completion;

- (POPAnimation *)st_spring:(id)valueFrom to:(id)valueTo keypath:(NSString *)keypath speedOffset:(CGFloat)offset completion:(void (^)(POPAnimation *anim, BOOL finished))completion;

- (POPAnimation *)st_springCGSize:(CGSize)sizeTo keypath:(NSString *)keypath;

- (POPAnimation *)st_springUIEdgeInsets:(UIEdgeInsets)edgeInsetsTo keypath:(NSString *)keypath;

- (POPAnimation *)st_springCGFloat:(CGFloat)floatTo keypath:(NSString *)keypath;

- (POPAnimation *)st_springCGFloat:(CGFloat)floatTo keypath:(NSString *)keypath3 completion:(void (^)(POPAnimation *anim, BOOL finished))completion;

- (POPAnimation *)st_springCGFloat:(CGFloat)floatTo block:(void (^)(id target, CGFloat value))block;

- (POPAnimation *)st_springCGFloat:(CGFloat)floatTo block:(void (^)(id target, CGFloat value))block completion:(void (^)(POPAnimation *anim, BOOL finished))completion;

- (POPAnimation *)st_springCGFloat:(CGFloat)floatFrom to:(CGFloat)floatTo block:(void (^)(id target, CGFloat value))block completion:(void (^)(POPAnimation *anim, BOOL finished))completion;

- (POPAnimation *)st_spring:(id)valueFrom to:(id)valueTo withBlock:(void (^)(id target, const CGFloat values[]))block speedOffset:(CGFloat)offset completion:(void (^)(POPAnimation *anim, BOOL finished))completion;

- (POPAnimation *)st_animateWith:(POPPropertyAnimation *)animation withBlock:(void (^)(id target, const CGFloat values[]))block completion:(void (^)(POPAnimation *anim, BOOL finished))completion;

- (POPBasicAnimation *)st_basic:(NSString *)property value:(CGFloat)value;

- (POPBasicAnimation *)st_basic:(NSString *)property value:(CGFloat)value duration:(CFTimeInterval)duration;

- (POPBasicAnimation *)st_basic:(NSString *)property value:(CGFloat)value duration:(CFTimeInterval)duration completion:(void (^)(POPAnimation *, BOOL))block;
@end