//
//  STMotionScrollView
//
//  Original version created by Christian Roman on 06/02/14 : https://github.com/chroman/CRMotionView
//  Recreated by Brian Lee on 20 Nov 2015. : https://github.com/stellarstep/STCodeBundle
//  Copyright (c) 2015 StellarStep, All rights reserved.
//

#import "STMotionScrollView.h"
#import "STZoomScrollView.h"
#import "UIView+STUtil.h"
#import "STLivePhotoView.h"
#import "NSObject+STUtil.h"

@import CoreMotion;

static const CGFloat CRMotionViewRotationMinimumTreshold = 0.3f;
static const CGFloat CRMotionGyroUpdateInterval = 1 / 100;
static const CGFloat CRMotionViewRotationFactor = 4.5f;

@interface STMotionScrollView () <CRZoomScrollViewDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) CGRect viewFrame;

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) STZoomScrollView *zoomScrollView;

@property (nonatomic, strong) UIImageView *contentImageView;

@property (nonatomic, assign) CGFloat motionRate;
@property (nonatomic, assign) CGFloat minimumXOffset;
@property (nonatomic, assign) CGFloat maximumXOffset;

@end

@implementation STMotionScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];

    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [self initWithFrame:frame];
    if (self) {
        [self setImage:image];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame contentView:(UIView *)contentView;
{
    self = [self initWithFrame:frame];
    if (self) {
        [self setContentView:contentView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame; {
    super.frame = frame;
    _viewFrame = CGRectMake(0.0, 0.0, CGRectGetWidth(frame), CGRectGetHeight(frame));
}

- (void)removeFromSuperview; {
    [super removeFromSuperview];

    [self clearMonitoringIfNeeded];
}

- (void)didMoveToSuperview; {
    [super didMoveToSuperview];

    [self startMonitoringIfNeeded];
    [self resetOffsetX];
}

- (void)commonInit
{
    _scrollView = [[UIScrollView alloc] initWithFrame:_viewFrame];
    [_scrollView setScrollEnabled:NO];
    [_scrollView setBounces:NO];
    [_scrollView setContentSize:CGSizeZero];
    [_scrollView setExclusiveTouch:YES];
    [self addSubview:_scrollView];

    _containerView = [[UIView alloc] initWithFrame:_viewFrame];
    [_containerView setClipsToBounds:YES];
    [_scrollView addSubview:_containerView];

    _minimumXOffset = 0;

    _motionEnabled = YES;
    _zoomEnabled   = YES;
    _scrollDragEnabled = NO;
    _scrollBounceEnabled = NO;
}

#pragma mark - ZoomScrollView
- (BOOL)isEnteredZoomScrollMode{
    return self.zoomScrollView!=nil;
}

- (void)enterZoomScrollMode {
    if (self.isZoomEnabled && self.isContentSizeScrollable) {

        //disable motion scroll
        [self stopMonitoring];
        _scrollView.visible = NO;

        // Init and setup the zoomable scroll view
        self.zoomScrollView = [[STZoomScrollView alloc] initWithScrollView:self.scrollView contentView:self.contentView];
        self.zoomScrollView.zoomDelegate = self;
        self.zoomScrollView.opaque = self.opaque;
        Weaks
        [self.zoomScrollView whenValueOf:@"zoomScale" id:@"motionscrollview.zoomscale" changed:^(id value, id _weakSelf) {
            !Wself.whenDidZoomScaleChanged?:Wself.whenDidZoomScaleChanged(Wself, [value floatValue]);
        }];
        [self addSubview:self.zoomScrollView];

        [self resetOffsetX];
    }
}

- (void)dismissZoomScrollMode:(BOOL)animation{
    if(![self isEnteredZoomScrollMode]){
        return;
    }

    @weakify(self)
    [self.zoomScrollView dismiss:^{
        _scrollView.visible = YES;

        [self.zoomScrollView whenValueOf:@"zoomScale" id:@"motionscrollview.zoomscale" changed:nil];
        [self.zoomScrollView removeFromSuperview];
        self.zoomScrollView.zoomDelegate = nil;
        self.zoomScrollView = nil;

        self.contentView = self.contentView;

    } animation:animation];
}

- (void)setZoomScale:(CGFloat)zoomScale {
    if([self isEnteredZoomScrollMode]){
        [self.zoomScrollView setZoomScale:zoomScale animated:YES];
    }
}

- (CGFloat)zoomScale {
    return [self isEnteredZoomScrollMode] ? self.zoomScrollView.zoomScale : 1;
}

#pragma mark - Setters
- (void)setContentView:(UIView *)contentView
{
    if (_contentView) {
        [_contentView removeFromSuperview];
        _contentView = nil;
    }

    if(!contentView){
        [self dismissZoomScrollMode:NO];
        [self clearMonitoringIfNeeded];
        return;
    }

    CGFloat width = _viewFrame.size.height / contentView.frame.size.height * contentView.frame.size.width;
    [contentView setFrame:CGRectMake(0, 0, width, _viewFrame.size.height)];
    [_containerView addSubview:contentView];

    CGRect frame = _containerView.frame;
    frame.size.width = contentView.frame.size.width;
    [_containerView setFrame:frame];

    NSDictionary *view = NSDictionaryOfVariableBindings(contentView);
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:view]];
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:view]];

    _scrollView.contentSize = CGSizeMake(contentView.frame.size.width, _scrollView.frame.size.height);
    _scrollView.contentOffset = CGPointMake((_scrollView.contentSize.width - _scrollView.frame.size.width) / 2, 0);

    _motionRate = contentView.frame.size.width / _viewFrame.size.width * CRMotionViewRotationFactor;
    _maximumXOffset = _scrollView.contentSize.width - _scrollView.frame.size.width;

    _contentView = contentView;

    if([self isPossibleScroll]){
        [self startMonitoringIfNeeded];

    }else{
        _maximumXOffset = 0;
        [self stopMonitoring];
    }
}

- (void)disposeContent {
    if(self.asset){
        self.asset = nil;
    }

    if(self.image){
        self.image = nil;
    }
}

#pragma mark Offset
- (void)setOffsetX:(CGFloat)offsetX{
    [self setOffsetX:offsetX animation:NO];
}

- (void)setOffsetX:(CGFloat)offsetX animation:(BOOL)animation{
    BOOL possibleScroll = [self isPossibleScroll];
    if(!possibleScroll){
        offsetX = 0;
    }
    
    CGPoint offsetPoint = CGPointMake(offsetX, 0);

    if(animation){
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [_scrollView setContentOffset:offsetPoint animated:NO];
                         } completion:nil];
    }else{
        [_scrollView setContentOffset:offsetPoint animated:NO];
    };

    self.zoomScrollView.startOffset = offsetPoint;

    if(possibleScroll){
        !self.whenDidScrollToProgress?:self.whenDidScrollToProgress(self, offsetX/_maximumXOffset);
    }
}

- (void)resetOffsetX{
    [self setOffsetX:(_scrollView.contentSize.width - _scrollView.frame.size.width) / 2];
}

#pragma mark Content - Image
- (void)setImage:(UIImage *)image{
    if(!self.contentImageView && image){
        self.contentImageView = [[UIImageView alloc] initWithImage:image];
    }else{
        self.contentImageView.image = image;
    }

    if(!image){
        [self.contentImageView removeFromSuperview];
        self.contentImageView = nil;
    }

    [self setContentView:self.contentImageView];
}

- (UIImage *)image {
    return self.contentImageView.image;
}


#pragma mark Content - Asset
- (void)setAsset:(PHAsset *)asset {
    _asset = asset;

    if(!_asset){
        self.image = nil;
        return;
    }

    PHImageRequestOptions * options = [PHImageRequestOptions new];
    options.synchronous = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;

    Weaks
    [[PHImageManager defaultManager] requestImageForAsset:_asset targetSize:[self assetsSizeToFitScreen] contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if(!result || [info[PHImageCancelledKey] boolValue] || [info[PHImageErrorKey] boolValue]){
            return;
        }

        Wself.image = result;
    }];
}

- (CGSize)assetsSizeToFitScreen{
    return CGSizeMake(_asset.pixelWidth*(_viewFrame.size.height/_asset.pixelHeight),_viewFrame.size.height);
}

#pragma mark Motion
- (void)setMotionEnabled:(BOOL)motionEnabled
{
    _motionEnabled = motionEnabled;
    if (_motionEnabled) {
        NSAssert([self isPossibleScroll], @"can't motion enabled");
        [self startMonitoring];
    } else {
        [self stopMonitoring];
    }
}

#pragma mark Scroll
//FIXME: sometime returning wrong value. should merge with isContentSizeScrollable
- (BOOL)isPossibleScroll{
    return _maximumXOffset>0;
}

- (BOOL)isContentSizeScrollable; {
    return self.contentView ? CGRectGetWidth(_viewFrame) < self.contentView.frame.size.width : NO;
}

- (void)setScrollDragEnabled:(BOOL)scrollDragEnabled
{
    _scrollDragEnabled = scrollDragEnabled;

    if (scrollDragEnabled) {
        [_scrollView setScrollEnabled:YES];
        [_scrollView setDelegate:self];
    } else {
        [_scrollView setScrollEnabled:NO];
        [_scrollView setDelegate:nil];
    }
}

- (void)setScrollBounceEnabled:(BOOL)scrollBounceEnabled
{
    _scrollBounceEnabled = scrollBounceEnabled;

    [_scrollView setBounces:scrollBounceEnabled];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (_motionEnabled) [self stopMonitoring];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (_motionEnabled) [self startMonitoring];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    oo(scrollView);
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    oo(scrollView);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    oo(scrollView);
}


#pragma mark - ZoomScrollView delegate

- (void)zoomScrollViewWillDismiss:(STZoomScrollView *)zoomScrollView
{
    [self startMonitoringIfNeeded];
}

- (void)zoomScrollViewDidDismiss:(STZoomScrollView *)zoomScrollView
{
    [self stopMonitoring];
}

#pragma mark - Motion

- (void)startMonitoring
{
    if (!self.isContentSizeScrollable) {
        return;
    }

    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.gyroUpdateInterval = CRMotionGyroUpdateInterval;
    }

    Weaks
    if (![_motionManager isGyroActive] && [_motionManager isGyroAvailable] ) {

        [_motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                                    withHandler:^(CMGyroData *gyroData, NSError *error) {
                                        dispatch_async(dispatch_get_main_queue(), ^{

                                            CGFloat rotationRate = (CGFloat) gyroData.rotationRate.y;
                                            if (fabs(rotationRate) >= CRMotionViewRotationMinimumTreshold) {
                                                CGFloat offsetX = _scrollView.contentOffset.x - rotationRate * _motionRate;
                                                if (offsetX > _maximumXOffset) {
                                                    offsetX = _maximumXOffset;
                                                } else if (offsetX < _minimumXOffset) {
                                                    offsetX = _minimumXOffset;
                                                }
                                                [Wself setOffsetX:offsetX animation:YES];
                                            }

                                        });
                                    }];
    } else {
        NSLog(@"There is not available gyro.");
    }
}

- (void)startMonitoringIfNeeded{
    if(_motionEnabled){
        [self startMonitoring];
    }
}

- (void)restartMonitoringIfNeeded{
    if(_motionManager && [_motionManager isGyroActive]){
        [self stopMonitoring];
    }

    [self startMonitoringIfNeeded];
}

- (void)stopMonitoring
{
    [_motionManager stopGyroUpdates];
}

- (void)clearMonitoringIfNeeded
{
    if(_motionManager || [_motionManager isGyroActive] || self.motionEnabled || !self.superview){
        [self stopMonitoring];
        _motionManager = nil;
    }

    self.scrollBounceEnabled = NO;
}

- (void)dealloc
{
    self.whenDidScrollToProgress = nil;

    [self clearMonitoringIfNeeded];

    [self dismissZoomScrollMode:NO];

    [self.zoomScrollView removeFromSuperview];
    self.zoomScrollView = nil;

    [[self scrollView] removeFromSuperview];
    self.scrollView = nil;

    self.image = nil;
    self.containerView = nil;
}

@end
