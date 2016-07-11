#import <UIKit/UIKit.h>
#import "STUIView.h"

@class STSelectableView;
@class STUIView;

@protocol STSeletableViewDelegate <NSObject>
@optional
- (void)didSelected:(STSelectableView *)selectedView index:(NSUInteger)index;

- (void)animateSelect:(STUIView *)view;

@end

@interface STSelectableView : STUIView <UIGestureRecognizerDelegate>{
@protected
    STUIView *_contentView;
}

@property (nonatomic, weak) id <STSeletableViewDelegate> delegate;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, readonly) NSUInteger lastSelectedIndex;
@property (nonatomic, readwrite) id currentMappedValue;
@property (nonatomic, assign) BOOL allowSelectAsTap;
@property (nonatomic, assign) BOOL allowSelectAsSlide;
@property (nonatomic, assign) BOOL fitViewsImageToBounds;
@property (nonatomic, assign) BOOL autoOrientationOnlySelectableViews;
@property (nonatomic, assign) BOOL animationEnabled;
@property (nonatomic, readwrite) NSArray * valuesMap;

- (id)initWithFrame:(CGRect)frame
         frontImage:(UIImage *)image
        behindImage:(UIImage *)behindImage;

- (id)initWithFrame:(CGRect)frame
              views:(NSArray *)presentableObjects;

- (id)initWithFrame:(CGRect)frame views:(NSArray *)presentableObjects whenSelected:(void (^)(STSelectableView *view, NSInteger index))block;

- (id)initWithFrame:(CGRect)frame views:(NSArray *)presentableObjects valuesMap:(NSArray *)values;

- (id)initWithFrame:(CGRect)frame views:(NSArray *)presentableObjects valuesMap:(NSArray *)values whenSelected:(void (^)(STSelectableView *view, NSInteger index, id value))block;

- (id)initWithFrame:(CGRect)frame viewsAsInteractionDisabled:(NSArray *)presentableObjects;

- (void)willSetViews:(NSArray *)presentableObjects;

- (void)didSetViews:(NSArray *)presentableObjects;

- (void)setViews:(NSArray *)presentableObjects;

- (void)clearViews;

- (void)whenSelected:(void (^)(STSelectableView *selectedView, NSInteger index))selected;

- (void)whenSelectedWithMappedValue:(void (^)(STSelectableView *selectedView, NSInteger index, id value))selected;

- (void)willClearViews;

- (void)didClearViews;

- (void)whenBeforeClearViews:(void (^)(void))clearViews;

- (void)dispatchSelected;

- (void)animateTapCurrent;

- (NSUInteger)count;

- (instancetype)next;

- (instancetype)prev;

- (id)presentableObjectAtIndex:(NSUInteger)index;

- (id)currentPresentableObject;
@end
