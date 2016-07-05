//
// Created by BLACKGENE on 2014. 9. 5..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, STUIViewTouchInsidePolicy) {
    STUIViewTouchInsidePolicyNone,
    STUIViewTouchInsidePolicyContentInside,
    STUIViewTouchInsidePolicyCircleShapedBoundInside,
    STUIViewTouchInsidePolicyForceAll
};

@protocol STUIViewPersistantState
- (void)saveStates;
- (void)restoreStatesIfPossible;
@end

@interface STUIView : UIView

@property(atomic, readonly) NSString *identifier;
@property(nonatomic, readwrite) STUIViewTouchInsidePolicy touchInsidePolicy;
@property (nonatomic, assign) BOOL contentDidCreated;
@property (nonatomic, assign) BOOL rasterizationEnabled;
@property (nonatomic, assign) BOOL lazyCreateContent;
@property (nonatomic, readwrite) BOOL shouldDisableAnimationWhileCreateContent;
/*
 * User events
 */
@property (copy) BOOL (^blockForForceTestPointInside)(CGPoint point, UIEvent *);
@property (copy) UIView * (^blockForForceTestHit)(CGPoint point, UIEvent *);

- (void)disposeContent;

- (void)whenCreatedToSuperview:(void (^)(UIView *))block;

- (void)saveObject;

- (void)clearSaved;

- (instancetype)savedObject;

- (void)saveStateForKeys:(NSArray *)keys;

- (instancetype)restoreStateForKeys;

- (NSDictionary *)stateForKeys;

- (void)setBlockForForceHitTestCircleShapedBound:(UIView *(^)(void))blockForForceTestHitAsCircleArea;

- (void)setBlockForForceHitTestCircleShapedBoundToSelf;

- (__typed_collection(NSArray,UIView *))targetViewsForChangingTransformFromOrientation;

- (void)willCreateContent;

- (void)createContent;

- (void)didCreateContent;
@end