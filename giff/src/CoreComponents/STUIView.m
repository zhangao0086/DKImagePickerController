//
// Created by BLACKGENE on 2014. 9. 5..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import "NSDictionary+BlocksKit.h"
#import "NSObject+STThreadUtil.h"
#import "UIView+STUtil.h"
#import "NSObject+STUtil.h"
#import "STQueueManager.h"
#import "PINMemoryCache.h"
#import "STUIView.h"

#pragma mark Category for tagging
@interface STUIView ()
- (PINMemoryCache *)cache;
@end

@implementation STUIView{
    void (^_whenDidCreatedToSuperview)(UIView *);
    NSString *_cacheKeyForObject;
    NSString *_cacheKeyForKeys;
    NSString *_identifier;
    BOOL _rasterizationEnabled;
}

- (id)initWithFrame:(CGRect)frame; {
    self = [super initWithFrame:frame];
    if (self) {
        @synchronized (self) {
            [self saveInitialLayout];
        }
    }
    return self;
}

- (NSString *)identifier {
    if(!_identifier){
        _identifier = [[NSProcessInfo processInfo] globallyUniqueString];
    }
    return _identifier;
}

#pragma mark Content Initialized
- (void)didMoveToSuperview; {
    if(self.lazyCreateContent){
        Weaks
        dispatch_async([STQueueManager sharedQueue].uiProcessing, ^{
            [Wself st_runAsMainQueueAsync:^{
                Strongs
                [Sself _startCreateContent];
            }];
        });
    }else{
        [self _startCreateContent];
    }
}

- (void)_startCreateContent{
    if(!_contentDidCreated){
        BOOL originalAnimationEnabled = [UIView areAnimationsEnabled];
        if(_shouldDisableAnimationWhileCreateContent){
            [UIView setAnimationsEnabled:NO];
        }

        if([self respondsToSelector:@selector(willCreateContent)]){
            [self willCreateContent];
        }

        [self createContent];

        _contentDidCreated = YES;

        if([self respondsToSelector:@selector(didCreateContent)]){
            [self didCreateContent];
        }
        if(_whenDidCreatedToSuperview){
            _whenDidCreatedToSuperview(self);
        }

        if(_shouldDisableAnimationWhileCreateContent){
            [UIView setAnimationsEnabled:originalAnimationEnabled];
        }
    }
}

- (void)willCreateContent; {}

- (void)createContent; {}

- (void)didCreateContent; {}

- (void)disposeContent; {}

- (void)whenCreatedToSuperview:(void (^)(UIView *))block; {
    _whenDidCreatedToSuperview = block;
}

#pragma mark Draw
- (void)setRasterizationEnabled:(BOOL)rasterizationEnabled; {
    _rasterizationEnabled = rasterizationEnabled;
    self.layer.rasterizationScale = rasterizationEnabled ? [[UIScreen mainScreen] scale]*2 : 1;
    self.layer.shouldRasterize = rasterizationEnabled;
}

- (BOOL)rasterizationEnabled{
    return _rasterizationEnabled;
}

#pragma mark Caches
- (PINMemoryCache *) cache{
    if(!_cacheKeyForObject)
        _cacheKeyForObject = [[@(self.hash) stringValue] stringByAppendingString:@"com.stells.uiview_cache_object"];

    if(!_cacheKeyForKeys)
        _cacheKeyForKeys = [[@(self.hash) stringValue] stringByAppendingString:@"com.stells.uiview_cache_keys"];

    static PINMemoryCache * _cache;
    static dispatch_once_t onceToken;
    if(!_cache){
        dispatch_once(&onceToken, ^{
            _cache = [[PINMemoryCache alloc] init];
        });
    }
    return _cache;
}

// Save Object
- (void)saveObject {
    [[self cache] setObject:self forKey:_cacheKeyForObject];
}

- (void)clearSaved {
    [[self cache] removeObjectForKey:_cacheKeyForObject];
}

- (instancetype)savedObject;{
    return [[self cache] objectForKey:_cacheKeyForObject];
}

// Save Object For Keys.
- (void)saveStateForKeys:(NSArray *) keys{
    [[self cache] setObject:[self dictionaryWithValuesForKeys:keys ? keys : [self st_propertyNames]] forKey:_cacheKeyForKeys];
}

- (instancetype)restoreStateForKeys;{
    [[self stateForKeys] bk_each:^(id key, id obj) {
        @try{
            [self setValue:obj forKey:key];
        }
        @catch(NSException *ex){
            NSLog(@"Restore error: %@ %@",obj,key);
            return;
        }
    }];
    return self;
}

- (NSDictionary *)stateForKeys;{
    return [[self cache] objectForKey:_cacheKeyForKeys];
}

#pragma mark Override for Touches

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event; {
    if(_blockForForceTestHit){
        return _blockForForceTestHit(point, event);
    }
    return [super hitTest:point withEvent:event];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if(_blockForForceTestPointInside){
        return _blockForForceTestPointInside(point, event);
    }

    switch (_touchInsidePolicy) {
        case STUIViewTouchInsidePolicyContentInside:
            for(UIView* subview in [self.subviews reverseObjectEnumerator]){
                if(![subview isHidden] && subview.userInteractionEnabled){
                    CGPoint p = [subview convertPoint:point fromView:self];
                    if([subview pointInside:p withEvent:event]){
                        return YES;
                    }
                }
            }
            return NO;
        case STUIViewTouchInsidePolicyCircleShapedBoundInside:
            for(UIView* subview in [[self st_allSubviews] reverseObjectEnumerator]){
                CGPoint p = [subview convertPoint:point fromView:self];
                if(CGPointLengthBetween_AGK(p, subview.boundsCenter) <= MAX(subview.bounds.size.width, subview.bounds.size.height)*.5f && ![subview isHidden]){
                    return YES;
                }
            }
            return NO;
        case STUIViewTouchInsidePolicyForceAll:
            return YES;
        default:
            break;
    }
    return [super pointInside:point withEvent:event];
}

- (void)setBlockForForceHitTestCircleShapedBound:(UIView *(^)(void))blockForForceTestHitAsCircleArea {
    NSParameterAssert(blockForForceTestHitAsCircleArea);
    Weaks
    self.blockForForceTestHit = ^UIView *(CGPoint point, UIEvent *event) {
        Strongs
        if(CGPointLengthBetween_AGK(point, Sself.boundsCenter) <= Sself.boundsWidthHalf){
            return blockForForceTestHitAsCircleArea();
        }
        return nil;
    };
}

- (void)setBlockForForceHitTestCircleShapedBoundToSelf{
    Weaks
    [self setBlockForForceHitTestCircleShapedBound:^UIView * {
        return Wself;
    }];
}

- (__typed_collection(NSArray,UIView *))targetViewsForChangingTransformFromOrientation {
    Weaks
    return @[Wself];
}

@end