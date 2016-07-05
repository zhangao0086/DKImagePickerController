#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

static float const kTransitionAnimationDuration = .4;
static float const kAnimationDumping            = .8;

#import "STZoomScrollView.h"
#import "UIScrollView+STUtil.h"

@interface STZoomScrollView () <UIScrollViewDelegate>

@property BOOL allowCentering;

// The zoom scale required to show image with full height
@property CGRect motionFrame;

@end

@implementation STZoomScrollView


- (id)init
{
    self = [super init];
    if (self) {
        [self initialization];
    }
    
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialization];
    }
    
    return self;
}


- (id)initWithScrollView:(UIScrollView *)scrollView image:(UIImage *)image;
{
    self = [self initWithFrame:scrollView.frame];
    if (self) {
        self.startOffset = scrollView.contentOffset;
        self.image = image;
    }
    
    return self;
}

- (id)initWithScrollView:(UIScrollView *)scrollView contentView:(UIView *)contentView;
{
    self = [self initWithFrame:scrollView.frame];
    if (self) {
        self.startOffset = scrollView.contentOffset;
        self.contentView = contentView;
    }

    return self;
}

- (void)dealloc {
    self.delegate = nil;
    self.contentView = nil;
}

- (void)initialization
{
    self.delegate = self;
}

#pragma mark - UI actions
- (void)dismiss:(void(^)(void))completion{
    [self dismiss:completion animation:YES];
}

- (void)dismiss:(void (^)(void))completion animation:(BOOL)animation {
    if ([self.zoomDelegate respondsToSelector:@selector(zoomScrollViewWillDismiss:)]) {
        [self.zoomDelegate zoomScrollViewWillDismiss:self];
    }

    self.allowCentering = NO;

    if(animation){
        @weakify(self)
        [UIView animateWithDuration:kTransitionAnimationDuration delay:0 usingSpringWithDamping:kAnimationDumping initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.zoomScale = 1;
            [self contentOffsetsToCenter];
            self.contentView.frame = self.motionFrame;

        } completion:^(BOOL finished) {

            if ([self.zoomDelegate respondsToSelector:@selector(zoomScrollViewDidDismiss:)]) {
                [self.zoomDelegate zoomScrollViewDidDismiss:self];
            }

            self.contentView = nil;

            !completion?:completion();
        }];
    }else{
        [self setZoomScale:1 animated:NO];
        [self contentOffsetsToCenter];
        self.contentView.frame = self.motionFrame;

        if ([self.zoomDelegate respondsToSelector:@selector(zoomScrollViewDidDismiss:)]) {
            [self.zoomDelegate zoomScrollViewDidDismiss:self];
        }

        self.contentView = nil;

        !completion?:completion();
    }

}


#pragma mark - Zoom mechanics


- (void)prepareZoomScrollView
{
    CGRect scrollViewFrame = self.frame;
    CGFloat scaleWidth     = scrollViewFrame.size.width / self.contentSize.width;
    CGFloat scaleHeight    = scrollViewFrame.size.height / self.contentSize.height;
    CGFloat minScale       = MIN(scaleWidth, scaleHeight);
    
    self.minimumZoomScale    = minScale;
    self.maximumZoomScale = 1.0f;
    
    // Setup the scrollview to be exactly like the motion view (zoom scale and position)
    self.zoomScale     = (minScale * CGRectGetHeight(self.bounds)) / (minScale * self.contentView.size.height);
    self.contentOffset = self.startOffset;
    self.motionFrame   = self.contentView.frame;
    
    // Animate to init state
    @weakify(self)
    [UIView animateWithDuration:kTransitionAnimationDuration delay:0 usingSpringWithDamping:kAnimationDumping initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.zoomScale = minScale;
    } completion:^(BOOL finished) {
        self.allowCentering = YES;
    }];
    
    [self centerScrollViewContents];
}

- (void)centerScrollViewContents
{
    CGSize boundsSize    = self.bounds.size;
    CGRect contentsFrame = self.contentView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.contentView.frame = contentsFrame;
}


#pragma mark - Scrollview delegate for zooming


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.contentView;
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (self.allowCentering || SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [self centerScrollViewContents];
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    [self willChangeValueForKey:@keypath(self.zoomScale)];
    [self didChangeValueForKey:@keypath(self.zoomScale)];
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self willChangeValueForKey:@keypath(self.zoomScale)];
    [self didChangeValueForKey:@keypath(self.zoomScale)];
}


#pragma mark - Setters
- (void)setImage:(UIImage *)image
{
    [self setContentView: image ? [[UIImageView alloc] initWithImage:image] : nil];
}

- (void)setContentView:(UIView *)view{
    if(_contentView){
        [_contentView removeFromSuperview];
    }

    _contentView = view;
    
    if(_contentView){
        _contentView.origin = CGPointZero;
        [self addSubview:_contentView];

        self.contentSize = _contentView.size;
        [self prepareZoomScrollView];
    }
}
@end
