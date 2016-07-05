//
// Created by BLACKGENE on 2014. 9. 15..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <BlocksKit/NSArray+BlocksKit.h>
#import "NSObject+STPopAnimatableProperty.h"
#import "POPCGUtils.h"
#import "M13OrderedDictionary.h"


@implementation NSObject (STPopAnimatableProperty)

#pragma mark CGRect
- (POPAnimation *)st_springCGRect:(CGRect)rectTo keypath:(NSString *)keypath {
    return [self st_springCGRect:rectTo keypath:keypath completion:nil];
}

- (POPAnimation *)st_springCGRect:(CGRect)rectTo block:(void(^)(id, CGRect))block {
    return [self st_springCGRect:rectTo block:block completion:nil];
}

- (POPAnimation *)st_springCGRect:(CGRect)rectTo keypath:(NSString *)keypath completion:(void (^)(POPAnimation *anim, BOOL finished))completion;{
    return [self st_spring:[self valueForKeyPath:keypath]
                        to:[NSValue valueWithCGRect:rectTo]
                 withBlock:[self _createWriteBlock:'r' keypath:keypath]
               speedOffset:0
                completion:completion];
}

- (POPAnimation *)st_springCGRect:(CGRect)rectTo block:(void(^)(id, CGRect))block completion:(void (^)(POPAnimation *anim, BOOL finished))completion;{
    return [self st_spring:nil
                        to:[NSValue valueWithCGRect:rectTo]
                 withBlock:^(id target, CGFloat const values[]) {
                     block(target, values_to_rect(values));
                 }
               speedOffset:0
                completion:completion];
}

#pragma mark CGPoint
- (POPAnimation *)st_springCGPoint:(CGPoint)pointTo keypath:(NSString *)keypath {
    return [self st_springCGPoint:pointTo keypath:keypath completion:nil];
}

- (POPAnimation *)st_springCGPoint:(CGPoint)pointTo keypath:(NSString *)keypath completion:(void (^)(POPAnimation *anim, BOOL finished))completion;{
    return [self st_spring:[self valueForKeyPath:keypath]
                        to:[NSValue valueWithCGPoint:pointTo]
                 withBlock:[self _createWriteBlock:'p' keypath:keypath]
               speedOffset:0
                completion:completion];
}

- (POPAnimation *)st_springCGPoint:(CGPoint)pointTo block:(void(^)(id, CGPoint))block {
    return [self st_springCGPoint:pointTo block:block completion:nil];
}

- (POPAnimation *)st_springCGPoint:(CGPoint)pointTo block:(void(^)(id, CGPoint))block completion:(void (^)(POPAnimation *anim, BOOL finished))completion;{
    return [self st_spring:nil
                        to:[NSValue valueWithCGPoint:pointTo]
                 withBlock:^(id target, CGFloat const values[]) {
                     block(target, values_to_point(values));
                 }
               speedOffset:0
                completion:completion];
}

#pragma mark CGSize
- (POPAnimation *)st_springCGSize:(CGSize)sizeTo keypath:(NSString *)keypath {
    return [self st_spring:[self valueForKeyPath:keypath]
                        to:[NSValue valueWithCGSize:sizeTo]
                 withBlock:[self _createWriteBlock:'s' keypath:keypath]
               speedOffset:0
                completion:nil];
}

- (POPAnimation *)st_springUIEdgeInsets:(UIEdgeInsets)edgeInsetsTo keypath:(NSString *)keypath {
    return [self st_spring:[self valueForKeyPath:keypath]
                        to:[NSValue valueWithUIEdgeInsets:edgeInsetsTo]
                 withBlock:[self _createWriteBlock:'e' keypath:keypath]
               speedOffset:0
                completion:nil];
}

#pragma mark CGFloat

- (POPAnimation *)st_springCGFloat:(CGFloat)floatTo keypath:(NSString *)keypath {
    return [self st_springCGFloat:floatTo keypath:keypath completion:nil];
}

- (POPAnimation *)st_springCGFloat:(CGFloat)floatTo keypath:(NSString *)keypath completion:(void (^)(POPAnimation *anim, BOOL finished))completion;{
    return [self st_spring:[self valueForKeyPath:keypath]
                        to:@(floatTo)
                 withBlock:[self _createWriteBlock:'f' keypath:keypath]
               speedOffset:0
                completion:completion];
}

- (POPAnimation *)st_springCGFloat:(CGFloat)floatTo block:(void(^)(id, CGFloat))block {
    return [self st_spring:nil
                        to:@(floatTo)
                 withBlock:^(id target, CGFloat const values[]) {
                     block(target, values[0]);
                 }
               speedOffset:0
                completion:nil];
}

- (POPAnimation *)st_springCGFloat:(CGFloat)floatTo block:(void(^)(id, CGFloat))block completion:(void (^)(POPAnimation *anim, BOOL finished))completion;{
    return [self st_spring:nil
                        to:@(floatTo)
                 withBlock:^(id target, CGFloat const values[]) {
                     block(target, values[0]);
                 }
               speedOffset:0
                completion:completion];
}

- (POPAnimation *)st_springCGFloat:(CGFloat)floatFrom to:(CGFloat)floatTo block:(void(^)(id, CGFloat))block completion:(void (^)(POPAnimation *anim, BOOL finished))completion;{
    return [self st_spring:@(floatFrom)
                        to:@(floatTo)
                 withBlock:^(id target, CGFloat const values[]) {
                     block(target, values[0]);
                 }
               speedOffset:0
                completion:completion];
}

- (POPAnimation *)st_spring:(id)valueFrom to:(id)valueTo withBlock:(void (^)(id target, const CGFloat values[]))block speedOffset:(CGFloat)offset completion:(void (^)(POPAnimation *anim, BOOL finished))completion;{
    return [self st_animateWith:[self _createSpringAnimation:valueFrom to:valueTo speedOffset:offset completion:completion] withBlock:block completion:nil];
}

- (void (^)(id target, const CGFloat values[]))_createWriteBlock:(char)typeName keypath:(NSString *)keypath{
    return ^(id target, CGFloat const values[]) {
        switch (typeName){
            case 'r' :
                [target setValue:[NSValue valueWithCGRect:values_to_rect(values)] forKey:keypath];
                break;
            case 'p' :
                [target setValue:[NSValue valueWithCGPoint:values_to_point(values)] forKey:keypath];
                break;
            case 's' :
                [target setValue:[NSValue valueWithCGSize:values_to_size(values)] forKey:keypath];
                break;
            case 'e' :
                [target setValue:[NSValue valueWithUIEdgeInsets:values_to_edge_insets(values)] forKey:keypath];
                break;
            case 'f' :
                [target setValue:@(values[0]) forKey:keypath];
                break;

            default:
                NSAssert(NO, @"not support type");
                break;
        }
    };
}

- (POPSpringAnimation *)_createSpringAnimation:(id)valueFrom to:(id)valueTo speedOffset:(CGFloat)offset completion:(void (^)(POPAnimation *anim, BOOL finished))completion;{
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:[NSUUID UUID].UUIDString];
    anim.fromValue = valueFrom;
    anim.toValue = valueTo;
    anim.springBounciness = 6;
    anim.springSpeed = MIN(12 + offset, 20);
    anim.completionBlock = completion;
    return anim;
}

- (POPAnimation *)st_animateWith:(POPPropertyAnimation *)animation withBlock:(void (^)(id target, const CGFloat values[]))block completion:(void (^)(POPAnimation *anim, BOOL finished))completion;{
    NSAssert(block!=nil, @"Must call with block");

    if(!block){ return nil; }

    POPAnimatableProperty * prop = [POPAnimatableProperty propertyWithName:animation.property.name initializer:^(POPMutableAnimatableProperty *p) {
        p.writeBlock = ^(id obj, const CGFloat values[]) {
            block(obj, values);
        };
        p.threshold = 0.01;
    }];
    animation.property = prop;
    if(!animation.completionBlock && completion){
        animation.completionBlock = completion;
    }
    [self pop_addAnimation:animation forKey:animation.property.name];

    return animation;
}

- (POPBasicAnimation *)st_basic:(NSString *)property value:(CGFloat)value{
    return [self st_basic:property value:value duration:.5];
}

- (POPBasicAnimation *)st_basic:(NSString *)property value:(CGFloat)value duration:(CFTimeInterval)duration{
    return [self st_basic:property value:value duration:duration completion:nil];
}

- (POPBasicAnimation *)st_basic:(NSString *)property value:(CGFloat)value duration:(CFTimeInterval)duration completion:(void (^)(POPAnimation *, BOOL))block {
    static CAMediaTimingFunction * easingFunction;
    if(!easingFunction){
        easingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    }

    POPBasicAnimation *anim = [POPBasicAnimation animation];
    anim.timingFunction = easingFunction;
    [anim setToValue:[NSNumber numberWithFloat:value]];
    [anim setDuration:duration];
    [anim setCompletionBlock:block];

    __weak NSObject * blockSelf = self;
    [anim setProperty:[POPAnimatableProperty propertyWithName:property initializer:^(POPMutableAnimatableProperty *prop) {
        prop.readBlock = ^(id obj, CGFloat values[]) {
            values[0] = [[blockSelf valueForKey:property] floatValue];
        };
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            [blockSelf setValue:@(values[0]) forKey:property];
        };
        prop.threshold = 0.01;
    }]];

    [self pop_addAnimation:anim forKey:property];

    return anim;
}

+ (void)addPopAnimationPropertiesAsCGFloat:(NSArray *)properties{
    [properties bk_each:^(id obj) {
        [self.class registerAnimatablePropertyWithName:obj readBlock:^(id target, CGFloat values[]) {
            values[0] = [[target valueForKey:obj] floatValue];

        } writeBlock:^(id target, const CGFloat values[]) {

            [target setValue:@(values[0]) forKey:obj];
        } threshold:0.01];
    }];
}

@end