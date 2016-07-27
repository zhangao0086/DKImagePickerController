#import "UIView+STUtil.h"
#import "UIImage+STUtil.h"
#import "NSArray+STUtil.h"
#import "STSelectableView.h"

@interface STSelectableView ()

@property (nonatomic, strong) NSArray *viewsPresentableObjects;
@property (nonatomic, assign) BOOL flipped;
@property (nonatomic, assign) CGPoint startPoint;

@property (nonatomic, readwrite) UIImageView *front;
@property (nonatomic, readwrite) UIImageView *back;

@end

@implementation STSelectableView {
    void (^_whenSelected)(STSelectableView * view, NSInteger index);
    void (^_whenSelectedWithMappedValue)(STSelectableView * view, NSInteger index, id value);
    void (^_whenBeforeClearViews)(void);
}


#pragma mark init
- (id)initWithFrame:(CGRect)frame frontImage:(UIImage *)frontImage behindImage:(UIImage *)behindImage
{
    return [self initWithFrame:frame views:@[frontImage, behindImage]];
}

- (id)initWithFrame:(CGRect)frame; {
    self = [super initWithFrame:frame];
    if (self) {
        _allowSelectAsSlide = NO;
        _allowSelectAsTap = YES;
        _animationEnabled = NO;
        _contentView = [[STUIView alloc] initWithFrame:self.bounds];
        [self addSubview:_contentView];

        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame views:(NSArray *)presentableObjects
{
    if ([self initWithFrame:frame])
    {
        [self setViews:presentableObjects];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame views:(NSArray *)drawableOrReferenceObjects whenSelected:(void (^)(STSelectableView * view, NSInteger indori))block
{
    if ([self initWithFrame:frame])
    {
        [self setViews:drawableOrReferenceObjects];
        [self whenSelected:block];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame views:(NSArray *)drawableOrReferenceObjects valuesMap:(NSArray *)values
{
    if ([self initWithFrame:frame])
    {
        [self setViews:drawableOrReferenceObjects];
        [self setValuesMap:values];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame views:(NSArray *)drawableOrReferenceObjects valuesMap:(NSArray *)values whenSelected:(void (^)(STSelectableView * view, NSInteger index, id value))block
{
    if ([self initWithFrame:frame])
    {
        [self setViews:drawableOrReferenceObjects];
        [self setValuesMap:values];
        [self whenSelectedWithMappedValue:block];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame viewsAsInteractionDisabled:(NSArray *)drawableOrReferenceObjects
{
    if ([self initWithFrame:frame])
    {
        self.userInteractionEnabled = NO;
        [self setViews:drawableOrReferenceObjects];
    }
    return self;
}

- (void)dealloc; {
    [self clearViews];

    [_contentView clearAllOwnedImagesIfNeededAndRemoveFromSuperview:NO];
    _contentView = nil;
    _front = nil;
    _back = nil;
}

#pragma mark Views - Set
- (void)willSetViews:(NSArray *)presentableObjects{}

- (void)didSetViews:(NSArray *)presentableObjects{}

- (void)setViews:(NSArray *)presentableObjects {
    [self willSetViews:presentableObjects];

    [self clearViews];

    if(presentableObjects){
        self.viewsPresentableObjects = presentableObjects;

        if(self.viewsPresentableObjects.count > 1){
            _front = [UIImageView allocIfNot:_front frame:_contentView.bounds];
            _front.contentMode = UIViewContentModeCenter;
            _front.userInteractionEnabled = YES;

            _back = [UIImageView allocIfNot:_back frame:_contentView.bounds];
            _back.contentMode = UIViewContentModeCenter;
            _back.userInteractionEnabled = YES;

            [_contentView addSubview:_back];
            [_contentView addSubview:_front];

        }else{

            _front = [UIImageView allocIfNot:_front frame:_contentView.bounds];
            _front.contentMode = UIViewContentModeCenter;
            [_contentView addSubview:_front];
            _front.userInteractionEnabled = YES;
        }

        for(UIView * subviewInContentView in _contentView.subviews){
            [subviewInContentView saveInitialLayout];
        }

        if(self.userInteractionEnabled){
            [self setGestureViewsRecognizers];
        }
        [self setViewsDisplay];
    }

    [self didSetViews:presentableObjects];
}

#pragma mark Views - Clear
- (void)willClearViews{}

- (void)didClearViews{}

- (void)whenBeforeClearViews:(void (^)(void))clearViews; {
    _whenBeforeClearViews = clearViews;
}

- (void)clearViews {
    [self willClearViews];

    !_whenBeforeClearViews?:_whenBeforeClearViews();
    _whenBeforeClearViews = nil;

    for(UIImageView *itemView in [_contentView subviews]){
        [self clearButtonDrawable:itemView];
        [itemView st_removeAllGestureRecognizers];
        [itemView removeFromSuperview];
    }
    self.viewsPresentableObjects = nil;
    [self resetIndex];

    [self didClearViews];
}

- (void)setAllowSelectAsTap:(BOOL)allowSelectAsTap; {
    BOOL changed = _allowSelectAsTap!=allowSelectAsTap;

    _allowSelectAsTap = allowSelectAsTap;

    if(changed){
        [self setViewsDisplay];
        [self setGestureViewsRecognizers];
    }
}

- (void)setAllowSelectAsSlide:(BOOL)allowSelectAsSlide; {
    BOOL changed = _allowSelectAsSlide!=allowSelectAsSlide;

    _allowSelectAsSlide = allowSelectAsSlide;

    if(changed){
        [self setViewsDisplay];
        [self setGestureViewsRecognizers];
    }
}

#pragma mark gesture
- (void)setGestureViewsRecognizers {
    WeakSelf weakSelf = self;

    if([_contentView subviews].count==1){
        [[_contentView subviews].first whenTappedParams:!_allowSelectAsTap ? nil : ^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            [weakSelf tappedForSingle:sender];
        }];
    }
    else if([_contentView subviews].count>1){

        for(UIImageView * view in [_contentView subviews]){
            [view whenTappedParams:!_allowSelectAsTap ? nil : ^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
                [weakSelf tappedForMulti:sender];
            }];

            [view whenPan:!_allowSelectAsSlide ? nil :^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
                [weakSelf panned:sender];
            }];
        }
    }
}

- (void)removeGestureViewsRecognizers {
    [[_contentView subviews] makeObjectsPerformSelector:@selector(st_removeAllGestureRecognizers)];
}

- (void)whenSelected:(void (^)(STSelectableView *view, NSInteger index))selected{
    if(!selected && _whenSelectedWithMappedValue){
        _whenSelectedWithMappedValue = nil;
    }
    _whenSelected = selected;
}

- (void)whenSelectedWithMappedValue:(void (^)(STSelectableView *view, NSInteger index, id value))selected{
    NSAssert(_valuesMap, @"whenSelectedWithMappedValue : must define valuesMap before.");
    _whenSelectedWithMappedValue = selected;
}

- (void)setValuesMap:(NSArray *)valuesMap; {
    if(valuesMap){
        NSAssert(self.count == [valuesMap count], @"must be same valuemap and views count. views : %d / valuesMap : %d", self.count, valuesMap.count);
    }else{
        _whenSelectedWithMappedValue = nil;
    }
    _valuesMap = valuesMap;
}

- (NSUInteger)count{
    return [[self viewsPresentableObjects] count];
}

- (instancetype)next {
    self.currentIndex = [self indexByNext];
    return self;
}

- (instancetype)prev{
    self.currentIndex = [self indexByPrev];
    return self;
}

- (void)setCurrentIndex:(NSUInteger)currentIndex; {
    if(!self.count || currentIndex==NSUIntegerMax){
        return;
    }

    if(currentIndex >= self.count){
        NSAssert(NO, @"setCurrentIndex : index must define lower than entire view's count.");
        return;
    }

    if(_currentIndex==currentIndex){
        return;
    }
    [self setIndex:currentIndex];
    [self setViewsDisplay];
}

- (void)setCurrentMappedValue:(id)value; {
    NSAssert(_valuesMap, @"setCurrentMappedValue : must define valuesMap before.");

    NSInteger index = [_valuesMap indexOfObject:value];
    if(NSNotFound==index){
        return;
    }
    self.currentIndex = (NSUInteger) index;
}

- (id)currentMappedValue; {
    NSAssert(_valuesMap, @"currentValue : must define valuesMap before.");
    return [_valuesMap st_objectOrNilAtIndex:self.currentIndex];
}

- (id)presentableObjectAtIndex:(NSUInteger)index {
    return [self.viewsPresentableObjects st_objectOrNilAtIndex:index];
}

- (id)currentPresentableObject {
    return [self presentableObjectAtIndex:self.currentIndex];
}

- (void)setViewsDisplay {
    if(!self.viewsPresentableObjects || !self.viewsPresentableObjects.count){
        return;
    }

    UIImageView *frontView = self.frontView;
    frontView.visible = YES;

    [self setButtonDrawable:frontView set:[self.viewsPresentableObjects st_objectOrNilAtIndex:_currentIndex]];

    if([_contentView subviews].count < 2){
        return;
    }

    UIImageView *behindView = self.behindView;
    behindView.visible = NO;

    if(_allowSelectAsSlide){
        [self setButtonDrawable:behindView set:[self.viewsPresentableObjects st_objectOrNilAtIndex:[self indexByNext]]];
    }
}

- (UIImageView *)setNextViewsDisplay {
    [self setNextIndex];

    UIImageView *behindView = (UIImageView *) [[_contentView subviews] firstObject];
    behindView.hidden = NO;
    [_contentView bringSubviewToFront:behindView];

    return behindView;
}

- (void) setButtonDrawable:(UIImageView *)view set:(id)object{
    @autoreleasepool {
        NSParameterAssert(object);

        if([object isKindOfClass:UIImage.class]){
            [self clearButtonDrawable:view disposeContents:YES];

            view.image = object;
            //TODO: detailed code review required for legacies - in this case setLayout needed?
//        [self setNeedsLayoutOfContentViewsToFit:view];

        }else if([object isKindOfClass:NSString.class]){
            [self clearButtonDrawable:view disposeContents:YES];

            view.image = [UIImage imageBundledCache:object];
            //TODO: detailed code review required for legacies - in this case setLayout needed?
//        [self setNeedsLayoutOfContentViewsToFit:view];

        }else if([object isKindOfClass:NSURL.class]){
            [self clearButtonDrawable:view disposeContents:YES];

            view.image = [UIImage imageWithContentsOfFile:((NSURL *)object).path];

            [self setNeedsLayoutOfContentViewsToFit:view];

        }else if([object isKindOfClass:CALayer.class]){
//            view.layer.sublayers = nil;
            [self clearButtonDrawable:view disposeContents:YES];

            CALayer * layerObject = object;
            [view.layer addSublayer:layerObject];

            //fit size
            if(self.fitViewsImageToBounds && !CGSizeEqualToSize(layerObject.size, self.size)){
                layerObject.size = self.size;
            }

        }else if([object isKindOfClass:UIView.class]){
            UIView * viewObject = object;
            if([[view subviews] containsObject:viewObject]){
                if(![[[view subviews] lastObject] isEqual:viewObject]){
                    [view bringSubviewToFront:viewObject];
                }
            }else{
                [self clearButtonDrawable:view disposeContents:YES];
                [view addSubview:viewObject];
            }

            [self setNeedsLayoutOfContentViewsToFit:viewObject];

        }else{
            NSAssert(NO, @"must set as drawable types, such as UIImage, NSString(for create UIImage), CALayer, UIView instead of \"%@\"", object);
        }
    }
}

- (void)clearButtonDrawable:(UIImageView *)view{
    [self clearButtonDrawable:view disposeContents:YES];
}

- (void)clearButtonDrawable:(UIImageView *)view disposeContents:(BOOL)dispose{
    if(dispose){
        [view clearAllOwnedImagesIfNeeded:NO removeSubViews:YES];
    }else{
        [view st_removeAllSubviews];
    }
}

- (void)setNeedsLayoutOfContentViewsToFit:(UIView *)targetView{
    if(self.fitViewsImageToBounds){
        if(targetView.contentMode != UIViewContentModeScaleAspectFit){
            targetView.contentMode = UIViewContentModeScaleAspectFit;
        }
        if(!CGSizeEqualToSize(targetView.size, self.size)){
            targetView.size = self.size;
        }
    }else{
        [targetView restoreInitialLayout];
    }
}

- (NSUInteger)setNextIndex
{
    return [self setIndex:[self indexByNext]];
}

- (NSUInteger)indexByNext
{
    NSUInteger index = _currentIndex + 1;
    return (index < self.viewsPresentableObjects.count) ? index : 0;
}

- (NSUInteger)indexByPrev
{
    return _currentIndex == 0 ? self.viewsPresentableObjects.count-1 : _currentIndex -1;
}

- (NSUInteger)setIndex:(NSUInteger)index{
    _lastSelectedIndex = _currentIndex;
    return (_currentIndex = index);
}

- (void)resetIndex{
    _lastSelectedIndex = 0;
    _currentIndex = 0;
}

- (UIImageView *)frontView{
    return [[_contentView subviews] last];
}

- (UIImageView *)behindView {
    return [[_contentView subviews] first];
}

- (void)setVisibleContentView:(BOOL)visibleContentView {
    _contentView.visible = visibleContentView;
}

- (BOOL)visibleContentView {
    return _contentView.visible;
}

- (void)dispatchSelected {

    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelected:index:)])
    {
        [self.delegate didSelected:self index:_currentIndex];
    }

    if(_whenSelectedWithMappedValue && _valuesMap){
        _whenSelectedWithMappedValue(self, _currentIndex, _valuesMap[_currentIndex]);

    }else if(_whenSelected){
        _whenSelected(self, _currentIndex);
    }
}

- (void)tappedForSingle:(UITapGestureRecognizer *)tapGesture
{
    [self animateTapCurrent];
    [self dispatchSelected];
}

- (void)tappedForMulti:(UITapGestureRecognizer *)tapGesture
{
    if(!_allowSelectAsTap){
        return;
    }

    [self next];
    [self animateTapCurrent];
    [self dispatchSelected];
}

- (void)panned:(UIPanGestureRecognizer *)panGesture
{
    if(!_allowSelectAsSlide){
        return;
    }

    UIView *pannedView = panGesture.view;
    CGPoint point = [panGesture translationInView:self];
    CGFloat distance = sqrtf(point.x * point.x + point.y * point.y);
    CGFloat maxDistance = MIN(pannedView.bounds.size.width,pannedView.bounds.size.height);
    BOOL reachChangableDistance = distance > maxDistance*.8;

    if (panGesture.state == UIGestureRecognizerStateBegan)
    {
        _startPoint = panGesture.view.center;
        _flipped = NO;
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged)
    {
        // control the position of the panned view
        if (distance < maxDistance){
            // move the current selected view with the touched point
            pannedView.center = CGPointMake(_startPoint.x + point.x, _startPoint.y + point.y);

        }else{
            float x = (point.x / distance) * maxDistance;
            float y = (point.y / distance) * maxDistance;

            pannedView.center = CGPointMake(_startPoint.x + x, _startPoint.y + y);
        }

        self.behindView.animatableVisible = distance>0;

        if (reachChangableDistance && !_flipped)
        {
            _flipped = YES;
            [self animateView:self.behindView];
        }
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded)
    {
        if (reachChangableDistance){
            [self setNextViewsDisplay];
            [self dispatchSelected];
        }else{

        }

        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             panGesture.view.center = _startPoint;
                         }
                         completion:^(BOOL finished) {

                             [self setViewsDisplay];

                         }];
    }
}

- (void)animateView:(UIView *)view
{
    if(!_animationEnabled){
        return;
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(animateSelect:)]){
        [self.delegate animateSelect:view];
        return;
    }

    [self animateTap:view completion:nil];
}

- (void)animateTap:(UIView *)view completion:(void(^)(BOOL finished))blockForFinished{
    [view animateWithReverse:@keypath(view.scaleXYValue) to:1.2 completion:blockForFinished];
}

- (void)animateTapCurrent {
    [self animateView:self.frontView];
}

- (__typed_collection(NSArray,UIView *))targetViewsForChangingTransformFromOrientation {
    Weaks
    return self.autoOrientationOnlySelectableViews ? @[_contentView] : @[Wself];
}

@end
