@protocol CRZoomScrollViewDelegate;

#import <UIKit/UIKit.h>

@interface STZoomScrollView : UIScrollView

@property (nonatomic, assign) id <CRZoomScrollViewDelegate> zoomDelegate;

/**
 *  image
 *
 *  The image zoomable
 */
@property (nonatomic) UIView *contentView;


/**
 *  startOffset
 *
 *  The offset position from where to start and dismiss the zoom view for seamless transition
 */
@property CGPoint startOffset;


/**
 *  Custom init method to work with the motion view or any scrollView
 *
 *  @param scrollView The reference scrollView for transition animation
 *  @param image      The image to display
 *
 *  @return An instance of CRZoomScrollView
 */
- (id)initWithScrollView:(UIScrollView *)scrollView image:(UIImage *)image;

- (id)initWithScrollView:(UIScrollView *)scrollView contentView:(UIView *)contentView;

- (void)dismiss:(void (^)(void))completion;

- (void)dismiss:(void (^)(void))completion animation:(BOOL)animation;

- (void)setImage:(UIImage *)image;
@end


@protocol CRZoomScrollViewDelegate <NSObject>

@optional
/**
 *  Delegate method to handle when view will be dismissed
 *
 *  @param zoomScrollView An instance of CRZoomScrollView - Optional
 */
- (void)zoomScrollViewWillDismiss:(STZoomScrollView *)zoomScrollView;

/**
 *  Delegate method to handle when view has been dismissed
 *
 *  @param zoomScrollView An instance of CRZoomScrollView - Optional
 */
- (void)zoomScrollViewDidDismiss:(STZoomScrollView *)zoomScrollView;

@end
