//
// Created by BLACKGENE on 2014. 10. 13..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import "SVGKFastImageView.h"
#import "STThumbnailGridViewCell.h"
#import "STPhotoItem.h"
#import "STPhotoSelector.h"
#import "UIView+STUtil.h"
#import "SVGKImage+STUtil.h"
#import "CALayer+STUtil.h"
#import "UIImage+STUtil.h"
#import "NSObject+STUtil.h"
#import "STStandardButton.h"
#import "R.h"
#import "STPhotoItem+UIAccessory.h"
#import "STQueueManager.h"

#define kBorderWidth 5
#define kPointBorderWidth 2

@implementation STThumbnailGridViewCell {
    UIImageView * _imageView;
    UIView *_selectionView;

    UIPanGestureRecognizer *_pan;

    BOOL _initilzedSelectedBorderColor;
    BOOL _initilzedPointedBorderColor;

    //blank to room
    CALayer * _blankLayer;
}

- (id)initWithFrame:(CGRect)frame; {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:frame];
        [_imageView setBackgroundColor:[STStandardUI blankBackgroundColor]];
        self.backgroundView = _imageView;

        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.layer.borderWidth = 0;
        self.selectedBackgroundView.layer.shouldRasterize = YES;
        self.selectedBackgroundView.layer.rasterizationScale = TwiceMaxScreenScale();

        self.selected = NO;

        self.multipleTouchEnabled = YES;

//        [self addPanGestures];

    }
    return self;
}

- (void)dealloc; {
    [self st_removeAllGestureRecognizers];
    [self clearItem];
    _pan = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [_selectionView centerToParent];
}

#define NameOfBlank @"cell_blank"
- (void)presentItem:(STPhotoItem *)item{
    [self presentItem:item animation:NO];
}

- (void)presentItem:(STPhotoItem *)item animation:(BOOL)animation{
    _item = item;

    if(self.userInteractionEnabled != !item.blanked){
        self.userInteractionEnabled = !item.blanked;
    }

    //set image or blank
    if(item.blanked){
        dispatch_async([STQueueManager sharedQueue].readingIO, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                _imageView.image = nil;
            });
        });

        [self presentBlank];

    }else{
        [self removeBlank];

        dispatch_async([STQueueManager sharedQueue].readingIO, ^{
            @autoreleasepool {
                UIImage * image = item.previewImage;
                dispatch_async(dispatch_get_main_queue(), ^{
                    _imageView.image = image;
                });
            }
        });
    }

    //selected
    if(item.selected){
        [self presentSelection:animation];

    }else{
        [self unpresentSelection:animation];
    }

    //mark
    if(item.marked && !item.selected){
        [self presentMark];

    }else{
        [self unpresentMark];
    }

    //icon
    if(item.origin != STPhotoItemOriginUndefined){
        [item presentIcon:self.contentView];
    }else{
        [item unpresentIcon:self.contentView];
    }
}

- (void)clearItem {
    [_item disposeIcon:self.contentView];

    [self removeBlank];
    [self unpresentSelection:NO];

    _imageView.image = nil;

    _item = nil;
}

#pragma mark Selection
- (void)presentSelection:(BOOL)animation{
    if(!_selectionView){
        CGFloat selectionWidth = MIN(self.width-4, [STStandardLayout widthSubAssistanceBig]);
        _selectionView = [SVGKImage UIImageViewNamed:[R check_circle] withSizeWidth:selectionWidth];
        _selectionView.alpha = [STStandardUI alphaForDimmingSelection];
        [self.contentView addSubview:_selectionView];
    }

    [_selectionView centerToParent];

    //reset animation
    [_selectionView pop_removeAllAnimations];
    if(!CGAffineTransformEqualToTransform(_selectionView.transform, CGAffineTransformIdentity)){
        _selectionView.transform = CGAffineTransformIdentity;
    }

    if(animation){
        _selectionView.scaleXYValue = 0.1;
        _selectionView.spring.scaleXYValue = 1;

        _imageView.easeInEaseOut.alpha = [STStandardUI alphaForDimmingWeak];

    }else{
        _selectionView.scaleXYValue = 1;
        _imageView.alpha = [STStandardUI alphaForDimmingWeak];
    }
}

- (void)unpresentSelection:(BOOL)animation{
    [_selectionView pop_removeAllAnimations];
    [_imageView pop_removeAllAnimations];

    if(animation){
        [STStandardUX setAnimationFeelsToFastShortSpring:_selectionView];

        _imageView.easeInEaseOut.alpha = 1;

        [NSObject animate:^{
            _selectionView.spring.scaleXYValue = 0;
        } completion:^(BOOL finished) {
            if(finished){
                [_selectionView clearAllOwnedImagesIfNeededAndRemoveFromSuperview:NO];
                _selectionView = nil;
            }
        }];
    }else{
        _imageView.alpha = 1;

        [_selectionView clearAllOwnedImagesIfNeededAndRemoveFromSuperview:NO];
        _selectionView = nil;
    }
}

#pragma mark Blank
- (void)presentBlank {
    if(!_blankLayer){
        _blankLayer = [CALayer layerWithImage:[self st_cachedImage:NameOfBlank init:^UIImage * {
            return [[SVGKImage imageNamed:[R ico_cell_blank] widthSize:[STStandardLayout sizeBlankIcon]].UIImage maskWithColor:[STStandardUI blankObjectColor]];
        }]];
        _blankLayer.name = NameOfBlank;
        [_imageView.layer addSublayer:_blankLayer];
    }
    [_blankLayer centerToParent];
}

- (void)removeBlank {
    [_blankLayer removeFromSuperlayer];
    _blankLayer = nil;
}

#pragma mark Mark
- (void)presentMark{
    if(!_initilzedPointedBorderColor){
        self.backgroundView.layer.borderColor = [STStandardUI.strokeColorPoint CGColor];
        _initilzedPointedBorderColor = YES;
    }
    self.backgroundView.layer.borderWidth = kPointBorderWidth;
}

- (void)unpresentMark{
    if(self.backgroundView.layer.borderWidth > 0){
        self.backgroundView.layer.borderWidth = 0;
    }
}

#pragma mark pan gesture
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
{
    if([recognizer isEqual:_pan]){
        CGPoint translation =[_pan translationInView:self];
        BOOL flag = (translation.x * translation.x > translation.y * translation.y);
        return flag;
    }
    return NO;
}

- (void)addPanGestures {

    __block UIVisualEffectView *_panView;
    __block UIVisualEffectView *_vibView;
    __block STStandardButton *_iconimgview;
    __block BOOL _panToRight;

    @weakify(self)

    void(^addPanViews)(void) = ^{
        @strongify(self)
        [self st_coverBlur:NO styleDark:![self.item isDark] completion:nil];

        _panView = (UIVisualEffectView *)[self st_coveredView];

        _vibView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:(UIBlurEffect *) _panView.effect]];
        _vibView.size = _panView.size;

        _iconimgview = [STStandardButton buttonWithSize:[STStandardLayout sizeEditIcon]];
        _iconimgview.autoAdjustVectorIconImagePaddingIfNeeded = YES;
        _iconimgview.preferredIconImagePadding = [STStandardLayout sizeEditIcon].width/4.5f;
        _iconimgview.renderingMode = STStandardButtonRenderingModeAddIntoUIVisualEffectView;
        [_iconimgview setButtons:@[[R go_edit]] colors:@[[STStandardUI vibrancyColorFront]] bgColors:@[[STStandardUI vibrancyColorBack]] style:STStandardButtonStylePTTP];
        _iconimgview.toggleEnabled = YES;

        [_panView.contentView addSubview:_vibView];
        [_vibView.contentView addSubview:_iconimgview];
        [self addSubview:_panView];
    };

    void(^clearPanViews)(void) = ^{
        @strongify(self)

        [_iconimgview removeFromSuperview];
        _iconimgview = nil;

        [_vibView removeFromSuperview];
        _vibView = nil;

        [self st_coverRemove:NO];
        _panView = nil;
    };

    _pan = [self whenPan:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf) {
        @strongify(self)
        CGFloat pointX = CLAMP(locationInSelf.x, 0, self.width);

        _panToRight = [sender translationInView:self].x > 0;

        addPanViews();

        _panView.frame = _panToRight ? CGRectMake(0, 0, pointX, _panView.height) : CGRectMake(pointX, 0, self.width-pointX, _panView.height);

        _iconimgview.centerX = _panView.width*.5f;
        _iconimgview.centerY = self.height*.5f;
        _iconimgview.visible = _iconimgview.width < _panView.width;

    } changed:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf) {
        @strongify(self)
        CGFloat pointX = CLAMP(locationInSelf.x, 0, self.width);

        _panView.frame = _panToRight ? CGRectMake(0, 0, pointX, _panView.height) : CGRectMake(pointX, 0, self.width-pointX, _panView.height);

        BOOL reached = _panToRight ? pointX >= self.width/1.5 : pointX <= self.width/2.5;

        _iconimgview.selectedState = reached;

        _iconimgview.centerX = _panView.width*.5f;
        _iconimgview.visible = _iconimgview.width < _panView.width;

    } ended:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf) {
        @strongify(self)
        CGFloat pointX = CLAMP(locationInSelf.x, 0, self.width);
        BOOL reached = _panToRight ? pointX >= self.width/1.5 : pointX <= self.width/2.5;

        if(reached){
            NSLog(@"ok.");

            _iconimgview.easeInEaseOut.centerX = self.width*.5f;

            [_panView pop_removeAllAnimations];

            __weak UIView * panView = _panView;
            [NSObject animate:^{
                panView.duration = .15;
                panView.easeInEaseOut.frame = CGRectMake(0, 0, self.width, _panView.height);

            } completion:^(BOOL finished) {
                panView.visible = NO;

                clearPanViews();

                if(finished){
                    [[STPhotoSelector sharedInstance] doEnterEditByItem:self->_item];
                }
            }];

        }else{
            NSLog(@"cancel.");
            if(_panToRight){
                _iconimgview.easeInEaseOut.right = 0;
            }else{
                _iconimgview.easeInEaseOut.left = 0;
            }

            [_panView pop_removeAllAnimations];

            __weak UIView * panView = _panView;
            [NSObject animate:^{
                panView.easeInEaseOut.frame = _panToRight ? CGRectMake(0, 0, 0, panView.height) : CGRectMake(self.width, 0, 0, panView.height);

            } completion:^(BOOL finished) {
                clearPanViews();
            }];
        }


    }];
    _pan.delegate = self;
    _pan.delaysTouchesBegan = YES;
    _pan.cancelsTouchesInView = YES;
}
@end