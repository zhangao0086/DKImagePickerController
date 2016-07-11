//
// Created by BLACKGENE on 2014. 11. 6..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <BlocksKit/UIGestureRecognizer+BlocksKit.h>
#import <BlocksKit/NSArray+BlocksKit.h>
#import <BlocksKit/NSDictionary+BlocksKit.h>
#import <BlocksKit/NSObject+BKAssociatedObjects.h>
#import "UIView+STUtil.h"
#import "STTimeOperator.h"
#import "UIImage+STUtil.h"
#import "NSArray+STUtil.h"
#import "CAShapeLayer+STUtil.h"
#import "NSObject+STUtil.h"
#import "CALayer+STUtil.h"
#import "UIColor+STUtil.h"
#import "STContinuousForceTouchGestureRecognizer.h"
#import "UITouchLongPressGestureRecognizer.h"
#import "NSString+STUtil.h"
#import "STMotionManager.h"
#import "STStandardButton.h"

@implementation UIView (STUtil)

@dynamic visible, animatableVisible, scaleXYValue, autoOrientationEnabled, autoOrientationAnimationEnabled, originOffsetX, originOffsetY;

#pragma core

BEGIN_DEALLOC_CATEGORY
    [self clearLongTapDelayTimer];

    [[STMotionManager sharedManager] whenInterfaceOrientation:self._autoOrientationObservationId changed:nil];
    [self.class _setGlobalObservedViewsIdentifier:self._autoOrientationObservationId set:NO];
    [self bk_removeAllAssociatedObjects];
END_DEALLOC_CATEGORY

#pragma mark API Wrappers

- (id)initWithSize:(CGSize)size
{
    return [self initWithFrame:(CGRect){CGPointZero, size}];
}

- (id)initWithSizeWidth:(CGFloat)width
{
    return [self initWithSize:(CGSize){width, width}];
}

DEFINE_ASSOCIATOIN_KEY(kInitialFrame);
- (CGRect)initialFrame {
    return [[self bk_associatedValueForKey:kInitialFrame] CGRectValue];
}

DEFINE_ASSOCIATOIN_KEY(kInitialBounds);
- (CGRect)initialBounds {
    return [[self bk_associatedValueForKey:kInitialBounds] CGRectValue];
}

DEFINE_ASSOCIATOIN_KEY(kInitialViewContentMode);
- (UIViewContentMode)initialViewContentMode {
    return (UIViewContentMode) [[self bk_associatedValueForKey:kInitialViewContentMode] integerValue];
}

- (void)saveInitialLayout {
    [self bk_associateValue:[NSValue valueWithCGRect:self.frame] withKey:kInitialFrame];
    [self bk_associateValue:[NSValue valueWithCGRect:self.bounds] withKey:kInitialBounds];
    [self bk_associateValue:@(self.contentMode) withKey:kInitialViewContentMode];
}

- (void)restoreInitialLayout {
    if([self equalToInitialLayout]){
       return;
    }
    [self setFrame:[self initialFrame]];
    [self setBounds:[self initialBounds]];
    self.contentMode = [self initialViewContentMode];
    [self setNeedsLayout];
}

- (BOOL)equalToInitialLayout{
    return CGRectEqualToRect(self.frame, self.initialFrame)
            && CGRectEqualToRect(self.bounds, self.initialBounds)
            && self.contentMode == self.initialViewContentMode;
}

#define kAnimatableVisible @"UIView.animatableVisible"
DEFINE_ASSOCIATOIN_KEY(kPreviousVisible)
DEFINE_ASSOCIATOIN_KEY(kPreviousVisibleLocked)
- (void)setVisible:(BOOL)visible; {
    if([[self bk_associatedValueForKey:kPreviousVisibleLocked] boolValue]){
        return;
    }

    if(self.hidden != !visible){
        [self pop_removeAnimationForKey:kAnimatableVisible];
        self.hidden = !visible;
    }
}

- (BOOL)visible; {
    return !self.hidden;
}

- (void)lockVisibleToHide {
    [self lockVisible:NO];
}

- (void)lockVisibleToHideExcludingSubviews:(NSSet *)subviewsToExclude{
    for(UIView * view in self.subviews){
        if(![subviewsToExclude containsObject:view]){
            [view lockVisibleToHide];
        }
    }
}

- (void)lockVisible:(BOOL)visible {
    [self bk_associateValue:@(self.visible) withKey:kPreviousVisible];
    self.visible = visible;
    [self bk_associateValue:@(YES) withKey:kPreviousVisibleLocked];
}

- (void)unlockVisible {
    [self bk_associateValue:@(NO) withKey:kPreviousVisibleLocked];
    self.visible = [[self bk_associatedValueForKey:kPreviousVisible]?:@(YES) boolValue];
}

- (void)unlockVisibleToAllSubviews {
    for(UIView * view in self.subviews){
        [view unlockVisible];
    }
}

#pragma Tagging
DEFINE_ASSOCIATOIN_KEY(kTagName)
- (NSString *)tagName; {
    return [self bk_associatedValueForKey:kTagName];
}

- (void)setTagName:(NSString *)tagName; {
    [self bk_associateValue:tagName withKey:kTagName];
}

- (void)insertBelowToSuperview:(UIView *)view {
    if(self.superview){
        [self.superview insertSubview:view belowSubview:self];
    }else{
        [self insertSubview:view atIndex:0];
    }
}

- (void)insertAboveToSuperview:(UIView *)view {
    if(self.superview){
        [self.superview insertSubview:view aboveSubview:self];
    }else{
        self.subviews.count ? [self insertSubview:view aboveSubview:self.subviews.last] : [self addSubview:view];
    }
}

- (UIView *)viewWithTagNameFirst:(NSString *)name; {
    return [[self subviews] bk_match:^BOOL(id obj) {
        return [[obj tagName] isEqual:name];
    }];
}

- (UIView *)viewWithTagNameLast:(NSString *)name; {
    return [[[self subviews] reverse] bk_match:^BOOL(id obj) {
        return [[obj tagName] isEqual:name];
    }];
}

- (UIView *)viewWithTagName:(NSString *)name; {
    return [self viewWithTagNameFirst:name];
}

- (NSArray *)viewsWithTagName:(NSString *)name; {
    return [[self subviews] bk_select:^BOOL(id obj) {
        return [[obj tagName] isEqual:name];
    }];
}

- (NSArray *)viewsWithoutTagName:(NSString *)name; {
    return [[self subviews] bk_reject:^BOOL(id obj) {
        return [[obj tagName] isEqual:name];
    }];
}

- (NSArray *)viewsWithTagNameFromAllSubviews:(NSString *)name; {
    return [[self st_allSubviews] bk_select:^BOOL(id obj) {
        return [[obj tagName] isEqual:name];
    }];
}

- (NSArray *)viewsWithClass:(Class)Class; {
    return [[self subviews] bk_select:^BOOL(id obj) {
        return [obj isKindOfClass:Class];
    }];
}

- (UIView *)viewWithClass:(Class)Class; {
    return [self viewsWithClass:Class].first;
}

- (UIView *)viewWithTagName:(NSString *)name create:(UIView *(^)(UIView __weak *weakSelf))block; {
    NSParameterAssert(block);
    UIView * view = [self viewWithTagNameFirst:name];
    if(!view){
        Weaks
        view = block(Wself);
        NSAssert(view, @"Must be avaliables.");
        view.tagName = name;
    }
    return view;
}

- (NSArray *)viewsWithTagFromAllSubviews:(NSInteger)tag; {
    return [[self st_allSubviews] bk_select:^BOOL(UIView * view) {
        return view.tag == tag;
    }];
}

- (UIView *)viewWithTagFromAllSubviews:(NSInteger)tag; {
    return (UIView *) [[self viewsWithTagFromAllSubviews:tag] firstObject];
}

#pragma mark Geometry
- (CGRect)st_subviewsUnionFrame{
    CGRect result = CGRectZero;
    for(UIView *subview in [self subviews]){
        result = CGRectUnion(subview.frame, result);
    }
    return result;
}

- (void)sizeToFitSubviewsUnionSize {
    self.size = [self st_subviewsUnionFrame].size;
}

- (CGRect)st_subviewsUnionFrameWithExcluding:(NSArray *)excludesSubviews{
    CGRect result = CGRectZero;
    for(UIView *subview in [self subviews]){
        if(![excludesSubviews containsObject:subview]){
            result = CGRectUnion(subview.frame, result);
        }
    }
    return result;
}

- (CGFloat)st_maxSubviewWidth {
    CGFloat size = 0;
    for(UIView *subview in [self subviews])
        if(size < subview.frame.size.width) size = subview.frame.size.width;
    return size;
}

- (CGFloat)st_minSubviewWidth {
    CGFloat size = CGFLOAT_MAX;
    for(UIView *subview in [self subviews])
        if(size > subview.frame.size.width) size = subview.frame.size.width;
    return size;
}

- (CGFloat)st_maxSubviewHeight {
    CGFloat size = 0;
    for(UIView *subview in [self subviews])
        if(size < subview.frame.size.height) size = subview.frame.size.height;
    return size;
}

- (CGFloat)st_minSubviewHeight {
    CGFloat size = CGFLOAT_MAX;
    for(UIView *subview in [self subviews])
        if(size > subview.frame.size.height) size = subview.frame.size.height;
    return size;
}

- (CGRect)st_originClearedBounds {
    return (CGRect){CGPointZero, self.bounds.size};
}

- (CGPoint)st_midXY{
    return CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (CGPoint)st_halfXY{
    return CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

- (void)st_centerToMidSuperview {
    self.center = [[self superview] st_midXY];
}

- (void)st_centerToHalfSuperview {
    self.center = [[self superview] st_halfXY];
}

- (void)st_centerSubview:(UIView *)subview {
    subview.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

- (void)centerToParentHorizontal {
    if(self.superview){
        switch ([UIApplication sharedApplication].statusBarOrientation){
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:{
                self.centerY = self.superview.boundsHeightHalf;
                break;
            }
            case UIInterfaceOrientationUnknown:
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:{
                self.centerX = self.superview.boundsWidthHalf;
                break;
            }
        }
    }
}

- (void)centerToParentVertical {
    NSAssert(self.superview,@"self.superview");

    if(self.superview){
        switch ([UIApplication sharedApplication].statusBarOrientation){
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:{
                self.centerX = self.superview.boundsWidthHalf;
                break;
            }
            case UIInterfaceOrientationUnknown:
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:{
                self.centerY = self.superview.boundsHeightHalf;
                break;
            }
        }
    }
}

- (CGRect)boundsAsSizeWidth {
    CGRect bounds = self.bounds;
    bounds.size.height = self.bounds.size.width;
    return bounds;
}

- (CGRect)boundsAsSizeHeight {
    CGRect bounds = self.bounds;
    bounds.size.width = self.bounds.size.height;
    return bounds;
}

- (CGFloat)scaleXYValue; {
    return MAX(self.scaleXY.x, self.scaleXY.y);
}

- (void)setScaleXYValue:(CGFloat)scaleXYValue; {
    self.scaleXY = CGPointMake(scaleXYValue, scaleXYValue);
}

- (CGRect)boundsWithScale:(CGFloat)sx sy:(CGFloat)sy{
    return CGRectApplyAffineTransform(self.bounds, CGAffineTransformScale(CGAffineTransformIdentity, sx, sy));
}

- (CGRect)boundsWithScaleRatio:(CGFloat)scaleXY{
    return [self boundsWithScale:scaleXY sy:scaleXY];
}

- (CGRect)boundsWithScale:(CGPoint)scaleXY{
    return [self boundsWithScale:scaleXY.x sy:scaleXY.y];
}

- (CGRect)boundsWithScaleX:(CGFloat)sx{
    return [self boundsWithScale:sx sy:1];
}

- (CGRect)boundsWithScaleY:(CGFloat)sy{
    return [self boundsWithScale:1 sy:sy];
}

- (CGRect)frameWithScale:(CGFloat)sx sy:(CGFloat)sy{
    return CGRectApplyAffineTransform(self.frame, CGAffineTransformMakeScale(sx, sy));
//    return CGRectApplyAffineTransform(self.frame, CGAffineTransformScale(CGAffineTransformIdentity, sx, sy));
}

- (CGRect)frameWithScaleRatio:(CGFloat)scaleXY{
    return [self frameWithScale:scaleXY sy:scaleXY];
}

- (CGRect)frameWithScaleX:(CGFloat)sx{
    return [self frameWithScale:sx sy:1];
}

- (CGRect)setFrameWithScaleY:(CGFloat)sy{
    return [self frameWithScale:1 sy:sy];
}

- (CGFloat)st_maxLength {
    return MAX(self.width, self.height);
}

- (CGFloat)st_minLength {
    return MIN(self.width, self.height);
}

- (CGRect)frameToView:(UIView *)destinationBoundsView {
    return [self convertRect:destinationBoundsView.frame toView:destinationBoundsView]; //?destinationBoundsView.superview
}

- (void)setOriginOffsetX:(CGFloat)x{
    self.x = self.initialFrame.origin.x + x;
}

- (CGFloat)originOffsetX {
    return self.x - self.initialFrame.origin.x;
}

- (void)setOriginOffsetY:(CGFloat)y{
    self.y = self.initialFrame.origin.y + y;
}

- (CGFloat)originOffsetY {
    return self.x - self.initialFrame.origin.x;
}

- (void)setOriginOffset:(CGPoint)point{
    self.origin = CGPointAdd_AGK(self.initialFrame.origin, point);
}

#pragma mark Layout
- (void)st_distributeSubviewsAsCenterHorizontally:(CGFloat)spacing {
    //layout toolbar items
    NSUInteger count = self.subviews.count;
    CGFloat subviewWidth = [self st_maxSubviewWidth];
    if(count){
        CGRect newFrame = self.frame;
        CGFloat newWidth = newFrame.size.width = ((subviewWidth+spacing) * count);//+(spacing*count-1);
        self.frame = newFrame;
        [self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger index, BOOL *stop) {
            subview.center = CGPointMake((newWidth/count)*index + (spacing + subviewWidth)/2, subview.center.y);
        }];
    }
}

- (void)st_gridSubviewsAsCenter:(CGFloat)spacing rowHeight:(CGFloat)rowHeight column:(NSUInteger)col {
    //layout toolbar items
    NSUInteger count = self.subviews.count;
    CGFloat subviewWidth = [self st_maxSubviewWidth];
    if(count){
        CGRect newFrame = self.frame;
        newFrame.size.width = ((subviewWidth+spacing) * count);
        self.frame = newFrame;
        __block NSUInteger colIndex = 0;
        __block NSUInteger rowIndex = 0;
        [self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger index, BOOL *stop) {
            colIndex = index % col==0 ? 0 : colIndex+1;
            rowIndex = (NSUInteger) floor(index / col);
            subview.center = CGPointMake((subviewWidth + spacing)*colIndex + subviewWidth/2 , (rowHeight * rowIndex) + rowHeight/2);
        }];
    }

    [self sizeToFitSubviewsUnionSize];
}

#pragma mark Macro & Utils
- (UIView *)st_createNewViewWithBackgroundColor:(UIColor *)color alpha:(CGFloat)alpha{
    UIView * view = [[UIView alloc] initWithFrame:self.bounds];
    view.backgroundColor = color;
    view.alpha = alpha;
    return view;
}

+ (UIView *)st_createViewFromPresentableObject:(id)object{
    NSParameterAssert(object);

    if([object isKindOfClass:UIImage.class]){
        return [[UIImageView alloc] initWithImage:object];

    }else if([object isKindOfClass:NSString.class]){
        return [[UIImageView alloc] initWithImage:[UIImage imageBundled:object]];

    }else if([object isKindOfClass:CALayer.class]){
        CALayer * layer = object;
        CGRect frame = [object bounds];
        if([object isKindOfClass:CAShapeLayer.class] && CGRectIsEmpty(frame)){
            frame = [object pathBound];
        }else{
            NSAssert(!CGRectIsEmpty(frame), @"CALayer must needs valid bounds");
        }
        UIView * view = [[UIView alloc] initWithFrame:frame];
        [view.layer addSublayer:layer];
        return view;

    }else if([object isKindOfClass:UIView.class]){
        return object;

    }else{
        NSAssert(NO, @"must set as drawable types, such as UIImage, NSString(for create UIImage), CALayer, UIView instead of \"%@\"", object);
    }

    return nil;
}

- (void)st_addSubPresentableObject:(id)object{
    NSParameterAssert(object);

    if([object isKindOfClass:UIImage.class] || [object isKindOfClass:NSString.class] || [object isKindOfClass:UIView.class]){
        [self addSubview:[self.class st_createViewFromPresentableObject:object]];

    }else if([object isKindOfClass:CALayer.class]){
        [self.layer addSublayer:object];

    }else{
        NSAssert(NO, @"must set as drawable types, such as UIImage, NSString(for create UIImage), CALayer, UIView instead of \"%@\"", object);
    }
}

- (void)clearAllOwnedImagesIfNeededAndRemoveFromSuperview:(BOOL)recursive {
    [self clearAllOwnedImagesIfNeeded:recursive removeSubViews:YES];
    [self removeFromSuperview];
}

- (void)clearAllOwnedImagesIfNeeded:(BOOL)recursive {
    [self clearAllOwnedImagesIfNeeded:recursive removeSubViews:NO];
}

- (void)clearAllOwnedImagesIfNeeded:(BOOL)recursive removeSubViews:(BOOL)removeSubviews {
    NSArray * targetViews = nil;
    if(self.subviews.count){
        targetViews = recursive ? [self st_allSubviewsContainSelf] : [self.subviews arrayByAddingObjectsFromArray:@[self]];
    }else{
        targetViews = @[self];
    }
    for(UIView * view in targetViews){
        view.layer.mask = nil;
        view.layer.contents = nil;

        if([view isKindOfClass:UIImageView.class]){
            ((UIImageView *)view).image = nil;
        }
        if(removeSubviews && ![view isEqual:self]){
            [view removeFromSuperview];
        }
    }
}

+ (instancetype)allocIfNot:(UIView *)instance frame:(CGRect)frame{
    if(!instance){
        return [[self alloc] initWithFrame:frame];
    }
    instance.frame = frame;
    return instance;
}


- (void)setShadowEnabledForOverlay:(BOOL)enable{
    self.layer.shadowColor = !enable ? nil : [UIColor blackColor].CGColor;
    self.layer.shadowOffset = !enable ? CGSizeZero : CGSizeMake(0, 1);
    self.layer.shadowOpacity = !enable ? 0 : 1;
    self.layer.shadowRadius = !enable ? 0 : 1.f;
    self.layer.rasterizationEnabled = enable;
    self.clipsToBounds = !enable;
}

#pragma mark Blur/Vibrancy
static NSString * TagNameForEffectView = @"com.stells.effectview";
static NSString * TagNameForEffectViewVibrancy = @"com.stells.effectviewVibrancy";

- (UIVisualEffectView *)maskedEffectView:(CALayer *)layer{
    return (UIVisualEffectView *) [self st_matchSubviews:^BOOL(UIView *view, NSUInteger index) {
        return [layer isEqual:view.layer.mask] && [view.tagName isEqualToString:TagNameForEffectView];
    }];
}

- (UIVisualEffectView *)maskedVibrancyEffectView:(UIVisualEffectView *)effectView{
    return (UIVisualEffectView *) [effectView.contentView viewWithTagName:TagNameForEffectViewVibrancy];
}

- (UIVisualEffectView *)addMaskedEffectView:(UIView *)subview subviewsForVibrancy:(NSArray *)subviewsForVibrancy{
    return [self addMaskedEffectView:subview style:UIBlurEffectStyleLight subviewsForVibrancy:subviewsForVibrancy];
}

- (UIVisualEffectView *)addMaskedEffectView:(UIView *)subview style:(UIBlurEffectStyle)style subviewsForVibrancy:(NSArray *)subviewsForVibrancy{
    return [self addMaskedEffectLayer:subview.layer style:style subviewsForVibrancy:subviewsForVibrancy];
}

- (UIVisualEffectView *)addMaskedEffectLayer:(CALayer *)layer style:(UIBlurEffectStyle)style subviewsForVibrancy:(NSArray *)subviewsForVibrancy{
    UIVisualEffectView * effectView = [self maskedEffectView:layer];

    if(!effectView){
        UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:style];
        effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        effectView.tagName = TagNameForEffectView;
//        effectView.frame = layer.frame;
        effectView.frame = CGRectMake(layer.frameOrigin.x+layer.anchorPointX*layer.boundsWidth, layer.frameOrigin.y+layer.anchorPointY*layer.boundsHeight, layer.boundsWidth, layer.boundsHeight);
        effectView.layer.mask = layer;

        [self addSubview:effectView];
    }

    if(subviewsForVibrancy && subviewsForVibrancy.count){
        UIVisualEffectView * vibrancyView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:(UIBlurEffect *) effectView.effect]];
        vibrancyView.tagName = TagNameForEffectViewVibrancy;
        vibrancyView.frame = effectView.bounds;

        [effectView.contentView addSubview:vibrancyView];

        [subviewsForVibrancy eachViewsWithIndex:^(UIView *view, NSUInteger index) {
            [vibrancyView.contentView addSubview:view];
        }];
    }

    return effectView;
}

- (void)removeMaskedEffectView:(UIView *)subview subviewsForVibrancy:(NSArray *)subviewsForVibrancy{
    [self removeMaskedEffectLayer:subview.layer subviewsForVibrancy:subviewsForVibrancy];
}

- (void)removeMaskedEffectLayer:(CALayer *)layer subviewsForVibrancy:(NSArray *)subviewsForVibrancy{
    UIVisualEffectView * effectView = [self maskedEffectView:layer];
    if([effectView.layer.mask isEqual:layer]){
        effectView.layer.mask = nil;
    }

    if(subviewsForVibrancy){
        [[self maskedVibrancyEffectView:effectView].contentView st_eachSubviews:^(UIView *view, NSUInteger index) {
            if([subviewsForVibrancy containsObject:view]){
                [view removeFromSuperview];
            }
        }];
    }else{
        [[self maskedVibrancyEffectView:effectView].contentView st_removeAllSubviews];
    }
}

- (void)removeAllMaskedEffectViews {
    Weaks
    [[self viewsWithTagName:TagNameForEffectView] eachViewsWithIndex:^(UIView *view, NSUInteger index) {
        [Wself removeMaskedEffectView:view subviewsForVibrancy:nil];
        [view removeFromSuperview];
    }];
}

#pragma mark View Hirachy
- (UIViewController *)parentViewController {
    return UIViewParentController(self);
}

- (BOOL)st_isSuperviewsVisible {
    return [[self st_allSuperviewsContainSelf] bk_any:^BOOL(id obj) {
        return [obj visible];
    }];
}

- (NSArray *)st_allSuperviews{
    NSMutableArray * supverviews = [NSMutableArray array];
    UIView * view = self;
    while ((view = [view superview])) {
        [supverviews addObject:view];
    }
    return supverviews;
}

- (NSArray *)st_allSuperviewsContainSelf{
    return [@[self] arrayByAddingObjectsFromArray:[self st_allSuperviews]];
}

- (NSArray *)st_allSubviews{
    NSMutableArray * array = [NSMutableArray array];
    for (UIView *v in self.subviews){
        [array addObject:v];
        if(v.subviews.count){
            array = (NSMutableArray *) [[[v st_allSubviews] arrayByAddingObjectsFromArray:array] mutableCopy];
        }
    }
    return array;
}

- (NSArray *)st_allSubviewsContainSelf{
    return [@[self] arrayByAddingObjectsFromArray:[self st_allSubviews]];
}

- (void)st_eachSubviews:(void (^)(UIView* view, NSUInteger  index))block {
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj, idx);
    }];
}

- (UIView *)firstSubview{
    return (UIView *)self.subviews.firstObject;
}

- (UIView *)lastSubview{
    return (UIView *)self.subviews.lastObject;
}

- (UIView *)st_matchSubviews:(BOOL (^)(UIView* view, NSUInteger index))block {
    __block UIView * matchedView = nil;
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(block(obj, idx)){
            matchedView = obj;
        }
    }];
    return matchedView;
}

- (void)st_removeAllSubviews{
    [self st_eachSubviews:^(UIView *view, NSUInteger index) {
        [view removeFromSuperview];
    }];
}

- (void)st_removeAllSubviewsRecursively {
    [[self st_allSubviews] eachViewsWithIndex:^(UIView *view, NSUInteger index) {
        [view removeFromSuperview];
    }];
}

- (BOOL)isAddedToSuperviewAtIndex:(NSUInteger)index{
    return [self isEqual:[self.superview.subviews st_objectOrNilAtIndex:index]];
}

- (BOOL)isAddedBackToSuperview{
    return [self isAddedToSuperviewAtIndex:0];
}

- (BOOL)isAddedBelowFromOtherview:(UIView *)view{
    if(self.superview && [self.superview isEqual:view.superview]){
        return self.superview.subviews.count ? [self.superview.subviews indexOfObject:self] < [self.superview.subviews indexOfObject:view] : NO;
    }
    return NO;
}

- (BOOL)isAddedFrontToSuperview{
    return self.superview.subviews.count ? [self isAddedToSuperviewAtIndex:self.subviews.count-1] : NO;
}

- (BOOL)isAddedAboveFromOtherview:(UIView *)view{
    if(self.superview && [self.superview isEqual:view.superview]){
        return self.superview.subviews.count ? [self.superview.subviews indexOfObject:self] > [self.superview.subviews indexOfObject:view] : NO;
    }
    return NO;
}

#pragma mark Orientation
- (void)setOrientationToTransform:(UIInterfaceOrientation)orientation{
//    self.transform = CGAffineTransformIdentity;
    self.transform = CGAffineTransformMakeRotation(RadianFromOrientation(orientation));
}

#pragma mark AutoOrientation - Animation
DEFINE_ASSOCIATOIN_KEY(kAutoOrientationAnimation_SpringStyled)
- (BOOL)autoOrientationAnimationSpringStyled {
    return [[self bk_associatedValueForKey:kAutoOrientationAnimation_SpringStyled] boolValue];
}

- (void)setAutoOrientationAnimationSpringStyled:(BOOL)springStyle {
    [self bk_associateValue:@(springStyle) withKey:kAutoOrientationAnimation_SpringStyled];
}

DEFINE_ASSOCIATOIN_KEY(kAutoOrientationAnimation_Duration)
- (CGFloat)autoOrientationAnimationDuration {
    return [[self bk_associatedValueForKey:kAutoOrientationAnimation_Duration] floatValue];
}

- (void)setAutoOrientationAnimationDuration:(CGFloat)duration {
    [self bk_associateValue:@(duration) withKey:kAutoOrientationAnimation_Duration];
}

DEFINE_ASSOCIATOIN_KEY(kAutoOrientationAnimation_Enabled)
- (BOOL)autoOrientationAnimationEnabled {
    return [[self bk_associatedValueForKey:kAutoOrientationAnimation_Enabled] boolValue];
}

- (void)setAutoOrientationAnimationEnabled:(BOOL)enabled {
    [self bk_associateValue:@(enabled) withKey:kAutoOrientationAnimation_Enabled];
}

#pragma mark AutoOrientation - Global Handlers
static BOOL _globalAutoOrientationEnabled = NO;
static __typed_collection(NSMutableSet, NSString *) _globalAutoOrientationEnablingIdentifiers;

+ (void)setGlobalAutoOrientationEnabled:(BOOL)enable{
    @synchronized (UIView.class) {
        if(_globalAutoOrientationEnabled != enable){
            [self.class _fireOrientationToGlobalObservedViews:enable ? [STMotionManager sharedManager].interfaceOrientation : UIInterfaceOrientationPortrait];
        }
        _globalAutoOrientationEnabled = enable;
    }
}

+ (BOOL)globalAutoOrientationEnabled{
    BlockOnce(^{
        _globalAutoOrientationEnabled = YES;
    });
    @synchronized (UIView.class) {
        return _globalAutoOrientationEnabled;
    }
}

+ (void)_fireOrientationToGlobalObservedViews:(UIInterfaceOrientation)interfaceOrientation{
    @synchronized (_globalAutoOrientationEnablingIdentifiers) {
        for(NSString * identifier in [_globalAutoOrientationEnablingIdentifiers objectEnumerator]){
            [[STMotionManager sharedManager] st_fireValueToListenersTask:@keypath([STMotionManager sharedManager].interfaceOrientation)
                                                                      id:identifier
                                                                   value:@(interfaceOrientation)];
        }
    }
}

+ (void)_setGlobalObservedViewsIdentifier:(NSString *)identifier set:(BOOL)set{
    if(!identifier){
        return;
    }

    BlockOnce(^{
        _globalAutoOrientationEnablingIdentifiers = [[NSMutableSet alloc] init];
    });
    @synchronized (_globalAutoOrientationEnablingIdentifiers) {
        if(set){
            [_globalAutoOrientationEnablingIdentifiers addObject:identifier];
        }else{
            [_globalAutoOrientationEnablingIdentifiers removeObject:identifier];
        }
    }
}

#pragma mark AutoOrientation - Main
DEFINE_ASSOCIATOIN_KEY(k_autoOrientationObservationId)
- (void)set_autoOrientationObservationId:(NSString *)id {
    return [self bk_associateValue:id withKey:k_autoOrientationObservationId];
}

- (NSString *)_autoOrientationObservationId {
    return [self bk_associatedValueForKey:k_autoOrientationObservationId];
}

DEFINE_ASSOCIATOIN_KEY(kAutoOrientationEnabled)
- (BOOL)autoOrientationEnabled {
    return [[self bk_associatedValueForKey:kAutoOrientationEnabled] boolValue];
}

- (void)setAutoOrientationEnabled:(BOOL)autoOrientationEnabled {
    if(self.autoOrientationEnabled != autoOrientationEnabled){
        if(autoOrientationEnabled){
            //configure default values
            if(!self._autoOrientationObservationId){
                self._autoOrientationObservationId = [self st_uid];
            }

            if(!self.autoOrientationAnimationDuration){
                self.autoOrientationAnimationDuration = .35f;
            }

            if(!self.autoOrientationEnabled){
                self.autoOrientationAnimationEnabled = YES;
            }

            Weaks
            [[STMotionManager sharedManager] whenInterfaceOrientation:self._autoOrientationObservationId changed:^(UIInterfaceOrientation orientation) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Wself _setAutoOrientation:orientation];
                });
            }];

        }else{
            [[STMotionManager sharedManager] whenInterfaceOrientation:self._autoOrientationObservationId changed:nil];
            [self _setAutoOrientation:UIInterfaceOrientationPortrait];
        }

        //reset
        [self resetAutoOrientedTransformToCurrentIfNeeded];

        //set key
        [self.class _setGlobalObservedViewsIdentifier:self._autoOrientationObservationId set:autoOrientationEnabled];
    }
    [self bk_associateValue:@(autoOrientationEnabled) withKey:kAutoOrientationEnabled];
}

- (void)_setAutoOrientation:(UIInterfaceOrientation)orientation{
    if(!self.autoOrientationEnabled){
        return;
    }

    if(!self.superview){
        return;
    }

    Weaks
    NSArray * targetViews = [self targetViewsForChangingTransformFromOrientation];
    if(!targetViews){
        return;
    }

    BOOL shouldSetToDefault = NO;

    if(![self.class globalAutoOrientationEnabled]){
        shouldSetToDefault = YES;
    }

    [self willChangeOrientation:orientation];

    //init perform
    void (^performChange)(void) = ^{
        if(shouldSetToDefault){
            [Wself changeTransformFromOrientation:targetViews orientation:UIInterfaceOrientationPortrait];
        }else{
            [Wself changeTransformFromOrientation:targetViews orientation:orientation];
        }
    };
    void (^completion)(BOOL) = ^(BOOL finshed){
        if(finshed){
            [Wself didChangedOrientation:orientation];
        }
    };

    //perform
    if(self.autoOrientationAnimationEnabled){
        CGFloat duration = self.autoOrientationAnimationDuration;
        if(self.autoOrientationAnimationSpringStyled){
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:.7f initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:performChange completion:completion];

        }else{
            [UIView animateWithDuration:duration animations:performChange completion:completion];
        }

    }else{
        performChange();
        completion(YES);
    }
}

- (void)willChangeOrientation:(UIInterfaceOrientation)orientation{}

- (void)changeTransformFromOrientation:(__typed_collection(NSArray,UIView *))targetViews orientation:(UIInterfaceOrientation)orientation;{
    [targetViews each:^(UIView *view) {
        [view setOrientationToTransform:orientation];
    }];
}

- (__typed_collection(NSArray,UIView *))targetViewsForChangingTransformFromOrientation {
    Weaks
    return @[Wself];
}

- (void)didChangedOrientation:(UIInterfaceOrientation)orientation{}

- (void)resetAutoOrientedTransformToDefaultIfNeeded {
    [self _setAutoOrientation:UIInterfaceOrientationPortrait];
}

- (void)resetAutoOrientedTransformToCurrentIfNeeded {
    [self _setAutoOrientation:[STMotionManager sharedManager].interfaceOrientation];
}

#pragma mark Snapshot
- (UIImage*)st_takeSnapshot {
    return [self st_takeSnapshot:[self st_originClearedBounds] afterScreenUpdates:YES];
}

- (UIImage*)st_takeSnapshot:(CGRect) frame afterScreenUpdates:(BOOL)afterScreenUpdates{
    return [self st_takeSnapshot:frame afterScreenUpdates:afterScreenUpdates useTransparent:NO maxTwiceScale:NO];
}

- (UIImage*)st_takeSnapshot:(CGRect) frame afterScreenUpdates:(BOOL)afterScreenUpdates useTransparent:(BOOL)useTransparent{
    return [self st_takeSnapshot:frame afterScreenUpdates:afterScreenUpdates useTransparent:useTransparent maxTwiceScale:NO];
}

- (UIImage*)st_takeSnapshot:(CGRect) frame afterScreenUpdates:(BOOL)afterScreenUpdates useTransparent:(BOOL)useTransparent maxTwiceScale:(BOOL)maxTwiceScale{
    @autoreleasepool {
        BOOL invisible = !self.visible;
        CGPoint initialScaleXY = self.scaleXY;
        self.scaleXY = CGPointMake(0,0);
        if(invisible){
            self.visible = YES;
        }

        UIGraphicsBeginImageContextWithOptions(frame.size, !useTransparent, maxTwiceScale ? TwiceMaxScreenScale() : [[UIScreen mainScreen] scale]);
        if(afterScreenUpdates){
            [self drawViewHierarchyInRect:frame afterScreenUpdates:YES]; // view is the view you are grabbing the screen shot of. The view that is to be blurred.
        }else{
            //no way.
            [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        }
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        if(invisible){
            self.visible = NO;
        }
        self.scaleXY = initialScaleXY;

        return image;
    }
}

- (UIImage*)st_takeSnapshotExcludingAllSubviewsBoundsOrigin:(CGRect) frame {
    NSArray * views = [self st_allSubviewsContainSelf];
    __block NSMutableDictionary * originalBounds = [NSMutableDictionary dictionary];

    [views bk_each:^(id obj) {
        UIView *v = obj;
        if(!CGPointEqualToPoint(v.bounds.origin, CGPointZero)){
            [originalBounds setObject:v forKey:[NSValue valueWithCGRect:v.bounds]];
            [v setBounds:[v st_originClearedBounds]];
        }
    }];

    UIImage *image = [self st_takeSnapshot:frame afterScreenUpdates:YES];

    [originalBounds bk_each:^(id key, id obj) {
        [obj setBounds:[key CGRectValue]];
    }];

    originalBounds = nil;
    return image;
}

- (UIImage *)st_takeSnapshotWithBlurredOverlayView:(BOOL)bestQuality dark:(BOOL)dark {
    return [self st_takeSnapshotWithBlurredOverlayView:bestQuality dark:dark alpha:1];
}

- (UIImage *)st_takeSnapshotWithBlurredOverlayView:(BOOL)bestQuality dark:(BOOL)dark alpha:(CGFloat)alpha{
    return [self st_takeSnapshotWithBlurredOverlayView:bestQuality dark:dark alpha:alpha useTransparent:NO maxTwiceScale:YES];
}

- (UIImage *)st_takeSnapshotWithBlurredOverlayView:(BOOL)bestQuality dark:(BOOL)dark alpha:(CGFloat)alpha useTransparent:(BOOL)useTransparent maxTwiceScale:(BOOL)maxTwiceScale{
    return [self st_takeSnapshotWithBlurredOverlayView:bestQuality dark:dark alpha:alpha useTransparent:useTransparent maxTwiceScale:maxTwiceScale afterScreenUpdates:YES];
}

- (UIImage *)st_takeSnapshotWithBlurredOverlayView:(BOOL)bestQuality dark:(BOOL)dark alpha:(CGFloat)alpha useTransparent:(BOOL)useTransparent maxTwiceScale:(BOOL)maxTwiceScale afterScreenUpdates:(BOOL)afterScreenUpdates{
    UIVisualEffectView * blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:dark ? UIBlurEffectStyleDark : UIBlurEffectStyleLight]];
    blurView.frame = [self st_originClearedBounds];
    blurView.alpha = alpha;

    [self addSubview:blurView];

    UIImage * snapShot = [self st_takeSnapshot:[self st_originClearedBounds] afterScreenUpdates:afterScreenUpdates useTransparent:useTransparent maxTwiceScale:maxTwiceScale];

    blurView.visible = NO;
    [blurView removeFromSuperview];

    return snapShot;
}

- (UIView *)st_setUserInteractionEnabledToSubviews:(BOOL)userInteractionEnabledToSubviews; {
    for(UIView * subView in [[self subviews] reverseObjectEnumerator]){
        if(subView.userInteractionEnabled != userInteractionEnabledToSubviews){
            subView.userInteractionEnabled =  userInteractionEnabledToSubviews;
        }
    }
    return self;
}

#pragma mark Cover
- (UIVisualEffectView *)st_createBlurView:(UIBlurEffectStyle)style{
    UIVisualEffectView * blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:style]];
    blurView.tagName = TagForCoverView;
    blurView.frame = self.bounds;
    return blurView;
}

static NSString * TagForCoverView = @"STTagForCoverView";

- (BOOL)st_isCoverShowen; {
    return [self _st_isCoverShowen:[self viewWithTagName:TagForCoverView]];
}

- (UIView *)st_coveredView {
    return [self viewWithTagName:TagForCoverView];
}

- (BOOL)_st_isCoverShowen:(UIView *)view; {
    return view && view.visible && view.superview;
}

- (void)st_coverBlurIfNotShown {
    if(![self st_isCoverShowen]){
        [self st_coverBlur:YES styleDark:YES completion:nil];
    }
}

- (void)st_coverBlur {
    [self st_coverBlur:YES styleDark:YES completion:nil];
}

- (void)st_coverBlur:(BOOL)animation styleDark:(BOOL)dark completion:(void(^)(void))block{
    [self _present_cover_blur:animation style:dark ? UIBlurEffectStyleDark : UIBlurEffectStyleLight completion:block];
}

- (void)_present_cover_blur:(BOOL)animation style:(UIBlurEffectStyle)style completion:(void(^)(void))block{
    UIView *blurView = [self viewWithTagName:TagForCoverView];

    BOOL shown = [self _st_isCoverShowen:blurView];

    if(blurView){
        if(blurView.hidden){
            blurView.hidden = NO;
        }
        [self bringSubviewToFront:blurView];
    }else{
        blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:style]];
        blurView.tagName = TagForCoverView;
        blurView.frame = self.bounds;
        [self addSubview:blurView];
    }

    if(animation){
        if(!shown){
            blurView.alpha = 0;
        }
        [NSObject animate:^{
            blurView.easeInEaseOut.duration = .15;
            blurView.easeInEaseOut.alpha = 1;
        } completion:^(BOOL finished) {
            if(finished){
                !block?: block();
            }
        }];
    }else{
        blurView.alpha = 1;
        !block?: block();
    }
}

- (UIImageView *)st_coverBlurSnapshot:(BOOL)animation styleDark:(BOOL)dark completion:(void(^)(void))block{
    return [self st_coverBlurSnapshot:animation styleDark:dark useTransparent:NO maxTwiceScale:YES completion:block];
}

- (UIImageView *)st_coverBlurSnapshot:(BOOL)animation
                            styleDark:(BOOL)dark
                       useTransparent:(BOOL)useTransparent
                        maxTwiceScale:(BOOL)maxTwiceScale
                           completion:(void(^)(void))block{

    return [self st_coverBlurSnapshot:animation styleDark:dark useTransparent:useTransparent maxTwiceScale:maxTwiceScale afterScreenUpdates:YES completion:block];
}


- (UIImageView *)st_coverBlurSnapshot:(BOOL)animation
                            styleDark:(BOOL)dark
                       useTransparent:(BOOL)useTransparent
                        maxTwiceScale:(BOOL)maxTwiceScale
                   afterScreenUpdates:(BOOL)afterScreenUpdates
                           completion:(void(^)(void))block{

    return [self _present_cover_image:[self st_takeSnapshotWithBlurredOverlayView:YES dark:dark alpha:1 useTransparent:useTransparent maxTwiceScale:maxTwiceScale afterScreenUpdates:afterScreenUpdates] animation:animation completion:block];
}

- (UIImageView *)st_coverSnapshot:(BOOL)animation completion:(void(^)(void))block{
    return [self st_coverSnapshot:animation useTransparent:NO maxTwiceScale:YES completion:block];
}

- (UIImageView *)st_coverSnapshot:(BOOL)animation useTransparent:(BOOL)useTransparent maxTwiceScale:(BOOL)maxTwiceScale completion:(void(^)(void))block{
    return [self _present_cover_image:[self st_takeSnapshot:[self st_originClearedBounds] afterScreenUpdates:YES useTransparent:useTransparent maxTwiceScale:maxTwiceScale] animation:animation completion:block];
}

- (UIImageView *)st_coverSnapshot:(BOOL)animation useTransparent:(BOOL)useTransparent maxTwiceScale:(BOOL)maxTwiceScale afterScreenUpdates:(BOOL)afterScreenUpdates completion:(void(^)(void))block{
    return [self _present_cover_image:[self st_takeSnapshot:[self st_originClearedBounds] afterScreenUpdates:afterScreenUpdates useTransparent:useTransparent maxTwiceScale:maxTwiceScale] animation:animation completion:block];
}

- (UIImageView *)st_coverImage:(UIImage *)image animation:(BOOL)animation completion:(void(^)(void))block{
    return [self _present_cover_image:image animation:animation completion:block];
}

- (UIImageView *)_present_cover_image:(UIImage *)resultImage animation:(BOOL)animation completion:(void(^)(void))block{
    if(!resultImage){
        !block?: block();
    }

    UIView *view = [self viewWithTagName:TagForCoverView];
    BOOL shown = [self _st_isCoverShowen:view];

    UIImageView * imageView = nil;
    if([view isKindOfClass:UIImageView.class]){
        imageView = (UIImageView *)view;

    }else{
        [self st_coverRemove:NO];
        shown = NO;
    }

    if(imageView){
        if(imageView.hidden){
            imageView.hidden = NO;
        }
        [self bringSubviewToFront:imageView];
    }else{
        imageView = [[UIImageView alloc] initWithFrame:[self st_originClearedBounds]];
        imageView.tagName = TagForCoverView;
        [self addSubview:imageView];
    }

    imageView.userInteractionEnabled = YES;
    imageView.image = resultImage;

    if(animation){
        if(!shown){
            imageView.alpha = 0;
        }
        [NSObject animate:^{
            imageView.easeInEaseOut.duration = .15;
            imageView.easeInEaseOut.alpha = 1;
        } completion:^(BOOL finished) {
            if(finished){
                !block?: block();
            }
        }];
    }else{
        imageView.alpha = 1;
        !block?: block();
    }

    return imageView;
}


- (void)_unpresent_cover_view:(UIView *)view{
    if([view isKindOfClass:UIImageView.class]){
        [(UIImageView *)view setImage:nil];
    }
}

- (void)st_coverBlurRemoveIfShowen {
    if([self st_isCoverShowen]){
        [self st_coverRemove:YES];
    }
}

- (void)st_coverRemove {
    [self st_coverRemove:YES];
}

- (void)st_coverRemove:(BOOL)animation{
    [self st_coverRemove:animation promiseIfAnimationFinished:YES];
}

- (void)st_coverRemove:(BOOL)animation promiseIfAnimationFinished:(BOOL)promise{
    [self st_coverRemove:animation promiseIfAnimationFinished:promise finished:nil];
}

- (void)st_coverRemove:(BOOL)animation promiseIfAnimationFinished:(BOOL)promise finished:(void(^)(void))block{
    [self st_coverRemove:animation promiseIfAnimationFinished:promise duration:.4 finished:nil];
}

- (void)st_coverRemove:(BOOL)animation promiseIfAnimationFinished:(BOOL)promise duration:(NSTimeInterval)duration finished:(void(^)(void))block{
    UIView *view = [self viewWithTagName:TagForCoverView];

    Weaks
    if(view){
        if(animation){
            [NSObject animate:^{
                view.easeInEaseOut.duration = duration;
                view.easeInEaseOut.alpha = 0;

            } completion:^(BOOL finished) {
                if(/*finished &&*/ (promise || [view pop_animationKeys].count==0)){
                    [Wself _unpresent_cover_view:view];
                    [view removeFromSuperview];

                    !block?:block();
                }
            }];
        }else{
            [Wself _unpresent_cover_view:view];
            [view removeFromSuperview];
        }
    }
}

- (void)st_coverHide {
    [self st_coverHide:YES];
}

- (void)st_coverHide:(BOOL)animation{
    UIView *view = [self viewWithTagName:TagForCoverView];
    if(view && view.visible){
        Weaks
        if(animation){
            [NSObject animate:^{
                view.easeInEaseOut.duration = .4;
                view.easeInEaseOut.alpha = 0;

            } completion:^(BOOL finished) {
                if(finished && [view pop_animationKeys].count==0){
                    view.hidden = YES;
                    [Wself _unpresent_cover_view:view];
                }
            }];
        }else{
            view.hidden = YES;
            [Wself _unpresent_cover_view:view];
        }
    }
}

#pragma mark DropShadow As Gradient
NSString * ShadowViewTagName = @"UIView+STUtil.shadowImageView";

- (UIImageView *)st_setShadowToBack:(UIRectEdge)edge size:(CGFloat)size shadowColor:(UIColor *)color {
    return [self st_setShadow:edge size:size shadowColor:color rasterize:YES strong:NO atIndex:0];
}

- (UIImageView *)st_setShadowToFront:(UIRectEdge)edge size:(CGFloat)size shadowColor:(UIColor *)color {
    return [self st_setShadow:edge size:size shadowColor:color rasterize:YES strong:NO atIndex:NSUIntegerMax];
}

- (UIImageView *)st_setShadow:(UIRectEdge)edge
                         size:(CGFloat)size
                  shadowColor:(UIColor *)color
                    rasterize:(BOOL)rasterize
                       strong:(BOOL)strong
                      atIndex:(NSUInteger)index{

    [self st_removeShadow];

    /*
     * Gradient
     */
    BOOL invertDirection = size<0;
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    UIColor * shadowPrimaryColor = [UIColor colorIf:color or:[UIColor blackColor]];
    if(strong){
        gradientLayer.colors = @[(id)[shadowPrimaryColor CGColor], (id)[[UIColor clearColor] CGColor]];
    }else{
        gradientLayer.colors = @[(id)[shadowPrimaryColor CGColor], (id)[[shadowPrimaryColor colorWithAlphaComponent:.4f] CGColor], (id)[[shadowPrimaryColor colorWithAlphaComponent:.1f] CGColor], (id)[[UIColor clearColor] CGColor]];
    }

    gradientLayer.type = kCAGradientLayerAxial;
    CGSize frameSize = self.bounds.size;
    switch (edge){
        case UIRectEdgeNone:
        case UIRectEdgeBottom:
            gradientLayer.startPoint = CGPointMake(0,invertDirection ? 1 : 0);
            gradientLayer.endPoint = CGPointMake(0,invertDirection ? 0 : 1);
            gradientLayer.frame = CGRectMake(0, invertDirection ? frameSize.height+size : frameSize.height, frameSize.width, fabsf(size));
            break;
        case UIRectEdgeTop:
            gradientLayer.startPoint = CGPointMake(0,invertDirection ? 0 : 1);
            gradientLayer.endPoint = CGPointMake(0,invertDirection ? 1 : 0);
            gradientLayer.frame = CGRectMake(0, invertDirection ? 0 : -size, frameSize.width, fabsf(size));
            break;
        case UIRectEdgeLeft:
            gradientLayer.startPoint = CGPointMake(invertDirection ? 0 : 1, 0);
            gradientLayer.endPoint = CGPointMake(invertDirection ? 1 : 0, 0);
            gradientLayer.frame = CGRectMake(invertDirection ? 0 : -size, 0, fabsf(size), frameSize.height);
            break;
        case UIRectEdgeRight:
            gradientLayer.startPoint = CGPointMake(invertDirection ? 1 : 0, 0);
            gradientLayer.endPoint = CGPointMake(invertDirection ? 0 : 1, 0);
            gradientLayer.frame = CGRectMake(invertDirection ? frameSize.width-fabsf(size) : frameSize.width, 0, fabsf(size), frameSize.height);
            break;
        case UIRectEdgeAll:
            NSAssert(NO, @"not supported UIRectEdgeAll yet.");
            break;
    }

    /*
     * RasterLayer IfNeeded
     */
    UIImageView *shadowImageView = [self st_shadow];
    if(!shadowImageView){
        shadowImageView = [[UIImageView alloc] initWithFrame:gradientLayer.frame];
        shadowImageView.tagName = ShadowViewTagName;
    }else{
        shadowImageView.frame = gradientLayer.frame;
    }

    if(rasterize){
        shadowImageView.image = gradientLayer.UIImage;
    }else{
        gradientLayer.frameOrigin = CGPointZero;
        [shadowImageView.layer addSublayer:gradientLayer];
    }

    /*
     * Common
     */
    if(index>=self.subviews.count){
        [self addSubview:shadowImageView];
    }else{
        [self insertSubview:shadowImageView atIndex:index];
    }

    return shadowImageView;
}

- (UIImageView *)st_shadow {
    return (UIImageView *) [self viewWithTagName:ShadowViewTagName];
}

- (void)st_removeShadow {
    UIImageView * imageView = [self st_shadow];
    [imageView removeFromSuperview];
    imageView.image = nil;
}

#pragma mark Animations
const NSTimeInterval UICollectionViewCellAnimationDefaultDuration = 0.1;

CGFloat CGFloatSign(CGFloat value) {
    if (value < 0) {
        return -1.0f;
    }
    return 1.0f;
}

typedef NSTimeInterval (^STUIViewSpecialAnimationBlock)(CALayer * layer, float speed);

STUIViewSpecialAnimationBlock _animationBlock = ^(CALayer * layer, float speed){
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DTranslate(transform, 0.0f, CGFloatSign(speed) * layer.bounds.size.height/2.0f, 0.0f);
    transform = CATransform3DRotate(transform, CGFloatSign(speed) * M_PI_2, 1.0f, 0.0f, 0.0f);
    layer.transform = CATransform3DTranslate(transform, 0.0f, -CGFloatSign(speed) * layer.bounds.size.height/2.0f, 0.0f);
    layer.opacity = 1.0f - fabs(speed);
    return 2 * UICollectionViewCellAnimationDefaultDuration;
};

- (UIView *)animateSpecial:(CGFloat)speed{
    float normalizedSpeed = MAX(-1.0f, MIN(1.0f, speed/20.0f));

    BOOL shouldAnimate = YES;

    if (_animationBlock && shouldAnimate) {
        NSTimeInterval animationDuration = _animationBlock(self.layer, normalizedSpeed);
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
    }
    self.layer.transform = CATransform3DIdentity;
    self.layer.opacity = 1.0f;
    if (_animationBlock) {
        [UIView commitAnimations];
    }
    return self;
}

- (void)transitionZeroScaleTo:(UIView *)toView
                 presentImage:(UIImage *)image
                   completion:(void (^)(UIView *trasitionView, BOOL finished))block{

    [self transitionTo:toView presentImage:image animations:^(UIView *trasitionView) {

        CGFloat maxDuration = 1.3f;
        CGFloat minDuration = .6f;
        CGFloat distance = CGPointLengthBetween_AGK(trasitionView.center, toView.center);
        CGFloat maxDistance = CGPointLengthBetween_AGK(CGPointZero, CGPointMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height));

        trasitionView.easeInEaseOut.duration = CLAMP(maxDuration * AGKRemapToZeroOneAndClamp(distance, 0, maxDistance), minDuration, maxDuration);
        trasitionView.easeInEaseOut.center = toView.center;
        trasitionView.easeInEaseOut.scaleXYValue = 0;

    } completion:block];
}

- (void)transitionFrameTo:(UIView *)toView
             presentImage:(UIImage *)image
               completion:(void (^)(UIView *trasitionView, BOOL finished))block{

    [self transitionTo:toView presentImage:image animations:^(UIView *trasitionView) {

        CGFloat maxDuration = 1.3f;
        CGFloat minDuration = .6f;
        CGFloat distance = CGPointLengthBetween_AGK(trasitionView.center, toView.center);
        CGFloat maxDistance = CGPointLengthBetween_AGK(CGPointZero, CGPointMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height));

        trasitionView.easeInEaseOut.duration = CLAMP(maxDuration * AGKRemapToZeroOneAndClamp(distance, 0, maxDistance), minDuration, maxDuration);
        trasitionView.easeInEaseOut.frame = toView.frame;

    } completion:block];
}

- (void)transitionTo:(UIView *)toView
        presentImage:(UIImage *)image
          animations:(void (^)(UIView *trasitionView))animationsBlock
          completion:(void (^)(UIView *trasitionView, BOOL finished))completionBlock {

    NSAssert([toView superview], @"toView must have its superview.");
    //TODO: copy image가아니라스스로에니메이션되는기능
    if(self){
        UIView *trasitionView = nil;
        CGPoint originTo = [self frameToView:toView.superview].origin;
        if(image){
            trasitionView = [[UIImageView alloc] initWithImage:image];
            trasitionView.origin = originTo;
            trasitionView.size = self.size;
        }else{
            trasitionView = self;
            trasitionView.origin = originTo;
        }

        [toView.superview addSubview:trasitionView];

        [NSObject animate:^{
            animationsBlock(trasitionView);

        } completion:^(BOOL finished) {
            if(completionBlock){
                completionBlock(trasitionView, finished);
            }else{
                [trasitionView removeFromSuperview];
            }
        }];
    }
}

- (BOOL)animatableVisible; {
    return self.visible;
}

- (void)setAnimatableVisible:(BOOL)animatableVisible; {
    [self pop_removeAnimationForKey:kAnimatableVisible];

    POPBasicAnimation * animation = [POPBasicAnimation easeInEaseOutAnimation];
    animation.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
//    animation.duration = .3;

    if(animatableVisible){
        self.visible = YES;
        animation.toValue = @(1);
        animation.completionBlock = nil;
    }else{
        Weaks
        animation.toValue = @(0);
        animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            if(finished && Wself.alpha<1){
                Wself.visible = NO;
            }
        };
    }
    [self pop_addAnimation:animation forKey:kAnimatableVisible];
}

+ (void)st_removeDelayedToggleAlpha:(NSArray *)views{
    NSAssert([views.first isKindOfClass:UIView.class], @"st_unsetDelayedToggleAlpha :: [views.first isKindOfClass:UIView.class]");
    [views eachViewsWithIndex:^(UIView *view, NSUInteger index) {
        if(view.alpha!=1){
            view.alpha = 1;
        }
    }];
    [STTimeOperator st_clearPerformOnceAfterDelay:@"st_setDelayedToggleAlpha"];
}

+ (CGFloat)st_setDelayedToggleAlpha:(NSArray *)views delay:(NSTimeInterval)delay{
    [self.class st_setDelayedToggleAlpha:views delay:delay duration:.5 minAlpha:0 maxAlpha:1];
    return [views.first alpha];
}

+ (CGFloat)st_setDelayedToggleAlpha:(NSArray *)views delay:(NSTimeInterval)delay duration:(CGFloat)duration minAlpha:(CGFloat)minAlpha maxAlpha:(CGFloat)maxAlpha{
    NSAssert([views.first isKindOfClass:UIView.class], @"st_setDelayedToggleAlpha :: [views.first isKindOfClass:UIView.class]");
    Weaks
    if([views.first alpha]==1){
        [STTimeOperator st_performOnceAfterDelay:@"st_setDelayedToggleAlpha" interval:delay block:^{
            [UIView animateWithDuration:duration animations:^{
                Strongs
                [views eachViewsWithIndex:^(UIView *view, NSUInteger index) {
                    view.alpha = minAlpha;
                }];
            }];
        }];
    }else{
        if([views.first alpha]==0){
            [UIView animateWithDuration:duration animations:^{
                [views eachViewsWithIndex:^(UIView *view, NSUInteger index) {
                    view.alpha = maxAlpha;
                }];
            }];
        }
    }
    return [views.first alpha];
}

- (void)visibleAlphaFromZero {
    self.alpha = 0;
    self.visible = YES;
    self.easeInEaseOut.alpha = 1;
}

#pragma mark AlertEffect
DEFINE_ASSOCIATOIN_KEY(kAlphaBeforeStartBlinking)

- (void)startAlphaBlinking{
    [self startAlphaBlinking:NSUIntegerMax];
}

- (void)startAlphaBlinking:(NSUInteger)repeatCount{
    [self startAlphaBlinking:.6 repeatCount:NSUIntegerMax];
}

- (void)startAlphaBlinking:(NSTimeInterval)animationDuration repeatCount:(NSUInteger)repeatCount{
    [self startAlphaBlinking:.6 maxAlpha:1 repeatCount:NSUIntegerMax];
}

- (void)startAlphaBlinking:(NSTimeInterval)animationDuration maxAlpha:(CGFloat)alpha repeatCount:(NSUInteger)repeatCount{
    [self bk_associateValue:@(self.alpha) withKey:kAlphaBeforeStartBlinking];

    self.alpha = 0;
    [UIView animateWithDuration:animationDuration delay:0.1 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        [UIView setAnimationRepeatCount:repeatCount==NSUIntegerMax ? CGFLOAT_MAX : (CGFloat)repeatCount];
        self.alpha = alpha;
    } completion:nil];
}

- (void)stopAlphaBlinking{
    [self.layer removeAllAnimations];
//    self.alpha = [[self bk_associatedValueForKey:kAlphaBeforeStartBlinking] floatValue];
}

- (void)animateWithReverse:(NSString *)keypath to:(CGFloat)value completion:(void(^)(BOOL finished))block{
    [self animateWithReverse:keypath to:value repeat:NO completion:block];
}

- (void)animateWithReverse:(NSString *)keypath to:(CGFloat)value repeat:(BOOL)repeat completion:(void(^)(BOOL finished))block{
    [self animateWithReverse:keypath to:value repeat:NO duration:.1 durationReverse:.1 completion:block];
}

- (void)animateWithReverse:(NSString *)keypath to:(CGFloat)value duration:(CGFloat)duration delay:(NSTimeInterval)delay completion:(void(^)(BOOL finished))block{
    [self animateWithReverse:keypath to:value repeat:NO duration:duration durationReverse:duration springDamping:0 delay:delay completion:block];
}

- (void)animateWithReverse:(NSString *)keypath to:(CGFloat)value repeat:(BOOL)repeat duration:(CGFloat)duration delay:(NSTimeInterval)delay completion:(void(^)(BOOL finished))block{
    [self animateWithReverse:keypath to:value repeat:repeat duration:duration durationReverse:duration springDamping:0 delay:delay completion:block];
}

- (void)animateWithReverse:(NSString *)keypath to:(CGFloat)value repeat:(BOOL)repeat duration:(CGFloat)duration durationReverse:(CGFloat)durationReverse completion:(void(^)(BOOL finished))block{
    [self animateWithReverse:keypath to:value repeat:NO duration:.1 durationReverse:.1 springDamping:0 completion:block];
}

- (void)animateWithReverse:(NSString *)keypath to:(CGFloat)value repeat:(BOOL)repeat duration:(CGFloat)duration durationReverse:(CGFloat)durationReverse springDamping:(CGFloat)damping completion:(void(^)(BOOL finished))block{
    [self animateWithReverse:keypath to:value repeat:NO duration:.1 durationReverse:.1 springDamping:0 delay:0 completion:block];
}

- (void)animateWithReverse:(NSString *)keypath to:(CGFloat)value repeat:(BOOL)repeat duration:(CGFloat)duration durationReverse:(CGFloat)durationReverse springDamping:(CGFloat)damping delay:(NSTimeInterval)delay completion:(void(^)(BOOL finished))block{
    UIViewAnimationOptions options = UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction;
    if(repeat){
        options |= (UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse);
    }

    id originalValue = [self valueForKeyPath:keypath];

    Weaks
    void(^animationIn)(void) = ^{
        [Wself setValue:@(value) forKeyPath:keypath];
    };

    void(^animationOut)(BOOL) = ^(BOOL finished) {
        if(repeat){
            [Wself setValue:originalValue forKeyPath:keypath];
        }else{
            [UIView animateWithDuration:durationReverse animations:^{
                [Wself setValue:originalValue forKeyPath:keypath];
            } completion:block];
        }
    };

    if(damping){
        [UIView animateWithDuration:duration delay:delay usingSpringWithDamping:damping initialSpringVelocity:0 options:options animations:animationIn completion:animationOut];
    }else{
        [UIView animateWithDuration:duration delay:delay options:options animations:animationIn completion:animationOut];
    }
}

#pragma mark GestureRecognizer
DEFINE_ASSOCIATOIN_KEY(kPreviousUserInteractionEnabled);
- (void)disableUserInteraction{
    [self bk_associateValue:@(self.userInteractionEnabled) withKey:kPreviousUserInteractionEnabled];
    self.userInteractionEnabled = NO;
}

- (void)restoreUserInteractionEnabled{
    self.userInteractionEnabled = [[self bk_associatedValueForKey:kPreviousUserInteractionEnabled] boolValue];
}

/*
    !! BlockKit Based
 */
- (void)st_dispatchGestureHandlerToViews:(NSArray *)targetViews from:(UIGestureRecognizer *)bindingFrom classOfGestureRecognizer:(Class)Class state:(UIGestureRecognizerState)state{
    [targetViews eachViewsWithIndex:^(UIView *view, NSUInteger index) {
        [view.gestureRecognizers bk_each:^(id obj) {
            if(!Class || [obj isKindOfClass:Class]){
                UIGestureRecognizer * r = obj;
                ![r bk_handler]?:[r bk_handler](obj, state, [bindingFrom locationInView:view]);
            }
        }];
    }];
}

- (void)st_dispatchGestureHandlerToViews:(NSArray *)targetViews from:(UIGestureRecognizer *)bindingFrom{
    [self st_dispatchGestureHandlerToViews:targetViews from:bindingFrom classOfGestureRecognizer:bindingFrom.class state:bindingFrom.state];
}

- (void)st_dispatchGestureHandlerToAll:(UIGestureRecognizer *)bindingFrom{
    [self st_dispatchGestureHandlerToViews:[self st_allSuperviews] from:bindingFrom classOfGestureRecognizer:bindingFrom.class state:bindingFrom.state];
}

- (void)st_removeAllGestureRecognizers{
    for(UIGestureRecognizer * recognizer in [self gestureRecognizers]){
        [self removeGestureRecognizer:recognizer];
    }
}

- (void) _addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer; {
    if(![[self gestureRecognizers] containsObject:gestureRecognizer]){
        [self addGestureRecognizer:gestureRecognizer];
    }
}

- (void) _removeGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer; {
    if([[self gestureRecognizers] containsObject:gestureRecognizer]){
        [self removeGestureRecognizer:gestureRecognizer];
    }
}

- (void)removeGestureRecognizersByClass:(Class) class {
    __weak UIView * blockSelf = self;
    [[self gestureRecognizers] bk_each:^(id obj) {
        if ([obj isKindOfClass: class]){
            [blockSelf _removeGestureRecognizer:obj];
        }
    }];
}

static BOOL st_areAnimationEnabled;
+ (void)lockAnimation{
    st_areAnimationEnabled = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:NO];
}

+ (void)unlockAnimation{
    !st_areAnimationEnabled?:[UIView setAnimationsEnabled:st_areAnimationEnabled];
}

#pragma mark Pan
#define kPannigTimerId @"whenPan.UIGestureRecognizerStateChanged"

- (UIPanGestureRecognizer *)whenPanning:(void (^)(UIPanGestureRecognizer *))block; {
    return [self whenPan:!block ? nil : ^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if(state==UIGestureRecognizerStateChanged) block(sender);
    }];
}

- (UIPanGestureRecognizer *)whenPan:(void (^)(UIPanGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block; {
    [self removeGestureRecognizersByClass:[UIPanGestureRecognizer class]];
    [STTimeOperator st_clearPerformOnceAfterDelay:kPannigTimerId];

    if(block){
        UIPanGestureRecognizer *r = [UIPanGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            block((UIPanGestureRecognizer *) sender, state, location);
        }];
        [self _addGestureRecognizer:r];

        return r;
    }
    return nil;
}

- (UIPanGestureRecognizer *)whenPan:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panStart
                            changed:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panChanging
                              ended:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panEnded{

    return [self whenPan:panStart changed:panChanging ended:panEnded delayPanChanged:0];
}

- (UIPanGestureRecognizer *)whenPan:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panStart
                            changed:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panChanging
                              ended:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panEnded
                    delayPanChanged:(NSTimeInterval)delayPanChanged; {

    UIPanGestureRecognizer * _pan = [self whenPan:^(UIPanGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        switch (sender.state) {
            case UIGestureRecognizerStatePossible:
                break;
            case UIGestureRecognizerStateBegan:
                !panStart ?: panStart(sender, location);
                break;

            case UIGestureRecognizerStateChanged:
                !panChanging ?: panChanging(sender, location);

                if(delayPanChanged > 0){
                    [STTimeOperator st_performOnceAfterDelay:kPannigTimerId interval:delayPanChanged block:^{
                        !panChanging ?: panChanging(sender, location);
                    }];
                }else{
                    [STTimeOperator st_clearPerformOnceAfterDelay:kPannigTimerId];
                    !panChanging ?: panChanging(sender, location);
                }
                break;

            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
                !panEnded ?: panEnded(sender, location);
                break;
        }
    }];

    if(!_pan){
        [STTimeOperator st_clearPerformOnceAfterDelay:kPannigTimerId];
    }

    return _pan;
}

- (UIPanGestureRecognizer *)whenPanAsSlideVerticalSelf:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panStart
                                               changed:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf, CGFloat distance, CGPoint movedOffset, CGFloat distanceReachRatio, STSlideDirection direction, BOOL confirmed))panChanging
                                                 ended:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf, STSlideDirection direction, BOOL confirmed))panEnded; {

    return [self whenPanAsSlideVertical:self started:panStart changed:panChanging ended:panEnded];
}

- (UIPanGestureRecognizer *)whenPanAsSlideVertical:(UIView *)slideTargetView
                                           started:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panStart
                                           changed:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf, CGFloat distance, CGPoint movedOffset, CGFloat distanceReachRatio, STSlideDirection direction, BOOL confirmed))panChanging
                                             ended:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf, STSlideDirection direction, BOOL confirmed))panEnded; {

   return [self whenPanAsSlide:slideTargetView direction:STSlideAllowedDirectionVertical started:panStart changed:panChanging ended:panEnded];
}

- (UIPanGestureRecognizer *)whenPanAsSlideHorizontalSelf:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panStart
                                               changed:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf, CGFloat distance, CGPoint movedOffset, CGFloat distanceReachRatio, STSlideDirection direction, BOOL confirmed))panChanging
                                                 ended:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf, STSlideDirection direction, BOOL confirmed))panEnded; {

    return [self whenPanAsSlideVertical:self started:panStart changed:panChanging ended:panEnded];
}

- (UIPanGestureRecognizer *)whenPanAsSlideHorizontal:(UIView *)slideTargetView
                                           started:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panStart
                                           changed:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf, CGFloat distance, CGPoint movedOffset, CGFloat distanceReachRatio, STSlideDirection direction, BOOL confirmed))panChanging
                                             ended:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf, STSlideDirection direction, BOOL confirmed))panEnded; {

    return [self whenPanAsSlide:slideTargetView direction:STSlideAllowedDirectionHorizontal started:panStart changed:panChanging ended:panEnded];
}

- (UIPanGestureRecognizer *)whenPanAsSlide:(UIView *)slideTargetView
                                 direction:(STSlideAllowedDirection)direction
                                   started:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panStart
                                   changed:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf, CGFloat distance, CGPoint movedOffset, CGFloat distanceReachRatio, STSlideDirection direction, BOOL confirmed))panChanging
                                     ended:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf, STSlideDirection direction, BOOL confirmed))panEnded; {

    //config max distance
    __block CGFloat _maxDistance = 0;
    if(direction==STSlideAllowedDirectionVertical){
        _maxDistance = self.boundsHeight;
    }else if(direction== STSlideAllowedDirectionHorizontal){
        _maxDistance = self.boundsWidth;
    }else{
        _maxDistance = MAX(self.boundsWidth, self.boundsHeight);
    }

    //initialize values
    __block CGPoint _startPoint = CGPointZero;
    __block CGPoint _startGesturePoint = CGPointZero;
    __block STSlideDirection _direction = STSlideDirectionNone;
    __block CGPoint _movedPoint = CGPointZero;
    __block BOOL _confirmed = NO;

    Weaks
    return [self whenPan:^(UIPanGestureRecognizer *recognizer, CGPoint locationInSelf) {
        if(slideTargetView){
            _startPoint = slideTargetView.center;
        }

        _startGesturePoint = [recognizer translationInView:Wself];
        _movedPoint = CGPointZero;

        !panStart ?: panStart(recognizer, locationInSelf);

    } changed:^(UIPanGestureRecognizer *recognizer, CGPoint locationInSelf) {
        CGPoint movedPoint = [recognizer translationInView:Wself];
        /*
            calc position
         */
        CGFloat distanceFromCenter = sqrtf(movedPoint.x * movedPoint.x + movedPoint.y * movedPoint.y);
        CGPoint movedOffset = CGPointMake(movedPoint.x - _movedPoint.x, movedPoint.y-_movedPoint.y);
        _movedPoint = movedPoint;
        CGFloat distanceReachRatio = distanceFromCenter /_maxDistance;
        CGPoint viewCenterPoint;

        //lock only vertical
        if(direction==STSlideAllowedDirectionVertical){
            movedPoint.x = 0;
        }else if(direction== STSlideAllowedDirectionHorizontal){
            movedPoint.y = 0;
        }else;

        //confirm?
        if (distanceFromCenter < _maxDistance)
        {
            viewCenterPoint = CGPointMake(_startPoint.x + movedPoint.x, _startPoint.y + movedPoint.y);

            _confirmed = NO;
        }
        else
        {
            float x = (movedPoint.x / distanceFromCenter) * _maxDistance;
            float y = (movedPoint.y / distanceFromCenter) * _maxDistance;

            viewCenterPoint = CGPointMake(_startPoint.x + x, _startPoint.y + y);

            _confirmed = YES;

            distanceReachRatio = 1;
        }

        slideTargetView.center = viewCenterPoint;

        //direction
        if(direction== STSlideAllowedDirectionBoth){
            _direction = viewCenterPoint.y<0 ? STSlideDirectionUp : STSlideDirectionDown;
            _direction |= viewCenterPoint.x<0 ? STSlideDirectionLeft : STSlideDirectionRight;

        }else if(direction==STSlideAllowedDirectionVertical){
            _direction = viewCenterPoint.y<0 ? STSlideDirectionUp : STSlideDirectionDown;

        }else if(direction== STSlideAllowedDirectionHorizontal){
            _direction = viewCenterPoint.x<0 ? STSlideDirectionLeft : STSlideDirectionRight;
        }else;

        !panChanging ?: panChanging(recognizer, locationInSelf, distanceFromCenter, movedOffset, distanceReachRatio, _direction, _confirmed);

    } ended:^(UIPanGestureRecognizer *recognizer, CGPoint locationInSelf) {
//        slideTargetView.center = _startPoint;

        !panEnded ?: panEnded(recognizer, locationInSelf, _direction, _confirmed);
    }];

}
#pragma mark Swipe
- (void)whenSwiped:(void (^)(UISwipeGestureRecognizer *))block; {
    [self whenSwiped:block withUISwipeGestureRecognizerDirections:
            @[@(UISwipeGestureRecognizerDirectionRight),
                    @(UISwipeGestureRecognizerDirectionLeft),
                    @(UISwipeGestureRecognizerDirectionUp),
                    @(UISwipeGestureRecognizerDirectionDown)]
    ];
}

- (void)whenSwipedUpDown:(void (^)(UISwipeGestureRecognizer *))block; {
    [self whenSwiped:block withUISwipeGestureRecognizerDirections:
            @[@(UISwipeGestureRecognizerDirectionUp),
                    @(UISwipeGestureRecognizerDirectionDown)]
    ];
}

- (void)whenSwipedLeftRight:(void (^)(UISwipeGestureRecognizer *))block; {
    [self whenSwiped:block withUISwipeGestureRecognizerDirections:
            @[@(UISwipeGestureRecognizerDirectionRight),
                    @(UISwipeGestureRecognizerDirectionLeft)]
    ];
}

- (void)whenSwiped:(void (^)(UISwipeGestureRecognizer *))block withUISwipeGestureRecognizerDirections:(NSArray *)directions; {
    NSAssert(directions!=nil, @"must assign Directions");

    [self removeGestureRecognizersByClass:[UISwipeGestureRecognizer class]];

    if(block){
        __weak UIView * blockSelf = self;
        [directions bk_each:^(id direction) {

            UISwipeGestureRecognizer * r = [UISwipeGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
                if(state == UIGestureRecognizerStateRecognized){
                    block(sender);
                }
            }];
            r.direction = (UISwipeGestureRecognizerDirection) [direction integerValue];

            [blockSelf _addGestureRecognizer:r];
        }];
    }
}
#pragma mark Tap
- (void)st_dispatchTapGestureHandlerToViews:(NSArray *)targetViews from:(UIGestureRecognizer *)bindingFrom{
    [self st_dispatchGestureHandlerToViews:targetViews from:bindingFrom classOfGestureRecognizer:[UITapGestureRecognizer class] state:UIGestureRecognizerStateRecognized];
}

- (UITapGestureRecognizer *)whenTouches:(NSUInteger)numberOfTouches
                                 tapped:(NSUInteger)numberOfTaps
                                handler:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block
{
    UITapGestureRecognizer *gesture = nil;
    if(block){
        gesture = [UITapGestureRecognizer bk_recognizerWithHandler:block];
        gesture.numberOfTouchesRequired = numberOfTouches;
        gesture.numberOfTapsRequired = numberOfTaps;
        [self _addGestureRecognizer:gesture];

    }else{
        Weaks
        for(id obj in [self gestureRecognizers]){
            if([obj isKindOfClass:UITapGestureRecognizer.class] && ((UITapGestureRecognizer *) obj).numberOfTapsRequired == numberOfTaps){
                [Wself _removeGestureRecognizer:obj];
            }
        }
    }
    return gesture;
}

- (UITapGestureRecognizer *)whenTap:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block{
    return [self whenTouches:1 tapped:1 handler:block];
}

- (UITapGestureRecognizer *)whenTapped:(void (^)(void))block
{
    return [self whenTouches:1 tapped:1 handler:block ? ^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (state == UIGestureRecognizerStateRecognized) !block ?: block();
    } : nil];
}

- (UITapGestureRecognizer *)whenTappedParams:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block
{
    return [self whenTouches:1 tapped:1 handler:block ? ^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (state == UIGestureRecognizerStateRecognized) block(sender, state, location);
    } : nil];
}

- (UITapGestureRecognizer *)whenDoubleTapped:(void (^)(void))block
{
    return [self whenTouches:1 tapped:2 handler:block ? ^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (state == UIGestureRecognizerStateRecognized) !block ?: block();
    } : nil];
}

- (UITapGestureRecognizer *)whenDoubleTappedParams:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block
{
    return [self whenTouches:1 tapped:2 handler:block ? ^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (state == UIGestureRecognizerStateRecognized) block(sender, state, location);
    } : nil];
}

- (NSArray *)whenTapped:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))blockForSingleTapped
         orDoubleTapped:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))blockForDoubleTapped
{
    UITapGestureRecognizer * singleTapRecog = nil;
    UITapGestureRecognizer * doubleTapRecog = nil;
    [(singleTapRecog = [self whenTappedParams:blockForSingleTapped])
            requireGestureRecognizerToFail:(doubleTapRecog = [self whenDoubleTappedParams:blockForDoubleTapped])];

    return @[singleTapRecog, doubleTapRecog];
}


#pragma mark Long-Tap
#define kLongtapTimerIdPrefix @"whenLongTap.UIGestureRecognizerStateChanged"

- (UITouchLongPressGestureRecognizer *)whenLongTouchAsTapDownUp:(void (^)(UITouchLongPressGestureRecognizer *sender, CGPoint location))tapDown
                                                        changed:(void (^)(UITouchLongPressGestureRecognizer *sender, CGPoint location))tapChange
                                                          ended:(void (^)(UITouchLongPressGestureRecognizer *sender, CGPoint location))tapUp {

    return (UITouchLongPressGestureRecognizer *) [self whenLongTapAsTapDownUp:(void (^)(UILongPressGestureRecognizer *, CGPoint)) tapDown
                                                                      changed:(void (^)(UILongPressGestureRecognizer *, CGPoint)) tapChange
                                                                        ended:(void (^)(UILongPressGestureRecognizer *, CGPoint)) tapUp];

}

- (UILongPressGestureRecognizer *)whenLongTapAsTapDown:(void (^)(UITouchLongPressGestureRecognizer *sender, CGPoint location))tapDown
                                                 andUp:(void (^)(UITouchLongPressGestureRecognizer *sender, CGPoint location))tapUp {

    return [self whenLongTapAsTapDownUp:(void (^)(UILongPressGestureRecognizer *, CGPoint)) tapDown
                                changed:nil
                                  ended:(void (^)(UILongPressGestureRecognizer *, CGPoint)) tapUp];

}

- (UILongPressGestureRecognizer *)whenLongTapAsTapDownUp:(void (^)(UILongPressGestureRecognizer *sender, CGPoint location))tapDown
                                                 changed:(void (^)(UILongPressGestureRecognizer *sender, CGPoint location))tapChange
                                                   ended:(void (^)(UILongPressGestureRecognizer *sender, CGPoint location))tapUp {

    NSString * timerKey = [self longTapDelayTimerKey];
    UILongPressGestureRecognizer * recognizer = [self whenLongTap:!tapDown && !tapChange && !tapUp ? nil : ^(UILongPressGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        //FIXME: will drop as UIGestureRecognizerStateFailed, UIGestureRecognizerStatePossible that called via st_dispatchGestureHandlerToViews
        switch(sender.state){
            case UIGestureRecognizerStateFailed:
            case UIGestureRecognizerStateBegan:
                !tapDown?:tapDown(sender, location);
                break;

            case UIGestureRecognizerStateChanged:{
                !tapChange?:tapChange(sender, location);
            };
                break;
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStatePossible:
                !tapUp?:tapUp(sender, location);
                break;
        }

        if(sender.state==UIGestureRecognizerStateChanged){
            [STTimeOperator st_performOnceAfterDelay:timerKey interval:.3 block:^{
                if(sender){
                    !tapChange ?: tapChange(sender, location);
                }
            }];
        }else{
            [STTimeOperator st_clearPerformOnceAfterDelay:timerKey];
        }

    } minimumPressDuration:0];

    recognizer.cancelsTouchesInView = NO;

    if(!recognizer){
        [STTimeOperator st_clearPerformOnceAfterDelay:timerKey];
    }

    return recognizer;
}

- (NSString *)longTapDelayTimerKey{
    return [kLongtapTimerIdPrefix st_add:[self st_uid]];
}

- (void)clearLongTapDelayTimer{
    [STTimeOperator st_clearPerformOnceAfterDelay:[self longTapDelayTimerKey]];
}

- (UILongPressGestureRecognizer *)whenLongTapped:(void (^)(void))block{
    return [self whenLongTappedParams:!block ? nil : ^(UILongPressGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        block();
    }];
}

- (UILongPressGestureRecognizer *)whenLongTappedParams:(void (^)(UILongPressGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block{
    return [self whenLongTap:!block ? nil : ^(UILongPressGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (state == UIGestureRecognizerStateBegan) block(sender, state, location);
    } minimumPressDuration:.5];
}

- (UILongPressGestureRecognizer *)whenLongTap:(void (^)(UILongPressGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block minimumPressDuration:(NSTimeInterval)minimumPressDuration{
    [self removeGestureRecognizersByClass:[UILongPressGestureRecognizer class]];

    if(block){
        UITouchLongPressGestureRecognizer *longPressGestureRecognizer = [UITouchLongPressGestureRecognizer bk_recognizerWithHandler:(void (^)(UIGestureRecognizer *, UIGestureRecognizerState, CGPoint)) block];
        longPressGestureRecognizer.numberOfTapsRequired = 0;
        longPressGestureRecognizer.minimumPressDuration = minimumPressDuration;
        longPressGestureRecognizer.delaysTouchesBegan = YES;

        [self _addGestureRecognizer:longPressGestureRecognizer];

        return longPressGestureRecognizer;
    }

    return nil;
}

#pragma mark Pinch
- (UIPinchGestureRecognizer *)whenPinch:(void (^)(UIPinchGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block{
    [self removeGestureRecognizersByClass:[UIPinchGestureRecognizer class]];

    if(block){
        UIPinchGestureRecognizer * pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            block((UIPinchGestureRecognizer *) sender,state,location);
        }];

        [self _addGestureRecognizer:pinchGestureRecognizer];

        return pinchGestureRecognizer;
    }
    return nil;
}

#pragma mark Force Touch
- (STContinuousForceTouchGestureRecognizer *)whenForceTouched:(void (^)(STContinuousForceTouchGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block{
    return [self whenForceTouched:block minimumPressDuration:.5f];
}

- (STContinuousForceTouchGestureRecognizer *)whenForceTouched:(void (^)(STContinuousForceTouchGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block minimumPressDuration:(NSTimeInterval)minimumPressDuration{
    [self removeGestureRecognizersByClass:[STContinuousForceTouchGestureRecognizer class]];

    if(block){
        STContinuousForceTouchGestureRecognizer *longPressGestureRecognizer = [STContinuousForceTouchGestureRecognizer bk_recognizerWithHandler:(void (^)(UIGestureRecognizer *, UIGestureRecognizerState, CGPoint)) block];
        longPressGestureRecognizer.numberOfTapsRequired = 0;
        longPressGestureRecognizer.minimumPressDuration = minimumPressDuration;
        longPressGestureRecognizer.delaysTouchesBegan = YES;

        [self _addGestureRecognizer:longPressGestureRecognizer];

        return longPressGestureRecognizer;
    }

    return nil;
}
@end