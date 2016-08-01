//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STEditControlFrameEditItemView.h"
#import "STCapturedImageSet.h"
#import "STCapturedImage.h"
#import "UIView+STUtil.h"
#import "STCapturedImageSetAnimatableLayer.h"
#import "STStandardButton.h"
#import "R.h"
#import "NSArray+STUtil.h"


@implementation STEditControlFrameEditItemView {
    STSegmentedSliderView * _frameOffsetSlider;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _removeButton = [[STStandardButton alloc] initWithSizeWidth:self.height];
        [self addSubview:_removeButton];
        _removeButton.backgroundColor = [UIColor grayColor];
        _removeButton.fitIconImageSizeToCenterSquare = YES;
        [_removeButton setButtons:@[R.go_remove] colors:nil style:STStandardButtonStylePTBT];
        _removeButton.right = self.right;
    }

    return self;
}

- (void)setFrameIndexOffset:(NSInteger)frameIndexOffset {
    if([self _setFrameIndexOffset:frameIndexOffset]){
        [self updateThumbnailsPosition];
        [self updateSliderPosition];
    }
}

- (BOOL)_setFrameIndexOffset:(NSInteger)frameIndexOffset {
    BOOL changed = _displayLayer.frameIndexOffset!=frameIndexOffset;
    if(changed){
        [self willChangeValueForKey:@keypath(self.frameIndexOffset)];
        _displayLayer.frameIndexOffset = frameIndexOffset;
        [self didChangeValueForKey:@keypath(self.frameIndexOffset)];
    }
    return changed;
}

- (NSInteger)frameIndexOffset {
    return _displayLayer.frameIndexOffset;
}

- (CGFloat)squareUnitWidth{
    return self.height;
}

- (CGFloat)minThumbnailWidth{
    return (self.width-self.squareUnitWidth)/_displayLayer.imageSet.count;
}

static NSUInteger const TagPrefixThumbImageView = 1000;

- (void)setDisplayLayer:(STCapturedImageSetAnimatableLayer *)displayLayer {
    _displayLayer = displayLayer;

    if(_displayLayer.frameCount){
        if(!_frameOffsetSlider){
            _frameOffsetSlider = [[STSegmentedSliderView alloc] initWithSize:CGSizeMake(self.width-self.squareUnitWidth, self.squareUnitWidth)];
            _frameOffsetSlider.delegateSlider = self;
            [self addSubview:_frameOffsetSlider];
        }

        [_frameOffsetSlider setSegmentationViewAsPresentableObject:[_displayLayer.imageSet.images mapWithIndex:^(STCapturedImage *frameImage, NSInteger index) {
            @autoreleasepool {
                NSAssert(frameImage.thumbnailUrl,@"frameImage.thumbnailUrl");
                return [UIImage imageWithContentsOfFile:frameImage.thumbnailUrl.path];
            }
        }]];

        [_frameOffsetSlider.segmentationViews eachViewsWithIndex:^(UIView *view, NSUInteger index) {
            view.tag = TagPrefixThumbImageView+index;
            view.contentMode = UIViewContentModeScaleAspectFill;
            view.clipsToBounds = YES;
        }];

        [self updateThumbnailsPosition];

        [self updateSliderPosition];

    }else{
        [self disposeContent];
    }
}

- (void)disposeContent {
    _displayLayer = nil;

    [_frameOffsetSlider clearViews];
    [self clearAllOwnedImagesIfNeeded:NO removeSubViews:YES];

    _frameOffsetSlider = nil;
    _removeButton = nil;

    [super disposeContent];
}

- (void)updateThumbnailsPosition{
    [_displayLayer.imageSet.images eachWithIndex:^(STCapturedImage *frameImage, NSUInteger index) {
        UIImageView * thumbnailCellView = [_frameOffsetSlider viewWithTag:TagPrefixThumbImageView+index];
        NSInteger const offset = self.displayLayer.frameIndexOffset;
        NSInteger const count = self.displayLayer.frameCount;

        NSUInteger indexOfDisplay = index;
        if(offset>0){
            indexOfDisplay = index >= offset ? (index - offset) : count - (offset - index);
        }else if(offset<0) {
            indexOfDisplay = index >= (count + offset) ? (index - offset) - count : (NSUInteger) -(offset - index);
        }

        NSAssert(indexOfDisplay<self.displayLayer.frameCount,@"indexOfDisplay is wrong.");
        thumbnailCellView.x = self.minThumbnailWidth * indexOfDisplay;
    }];
}

- (void)updateSliderPosition{
    _frameOffsetSlider.normalizedPosition = CLAMP((self.displayLayer.frameIndexOffset+((CGFloat)self.displayLayer.frameCount/2))/self.displayLayer.frameCount,0,1);
}

#pragma mark Slider Delegator
- (UIView *)createThumbView {
    UIView * thumbView = [[UIView alloc] initWithSize:CGSizeMake(self.minThumbnailWidth, self.squareUnitWidth)];
    thumbView.backgroundColor = [UIColor blackColor];
    return thumbView;
}

- (UIView *)createBackgroundView:(CGRect)bounds {
    return nil;
}

- (void)didSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index {
    [self _setFrameIndexOffsetHasChanging:NO];
}

- (void)doingSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index {
    //TODO:normalizedPosition 말고 index로 대체하는게 좋을 듯
    NSInteger frameIndexOffset = (NSInteger) ((timeSlider.normalizedPosition * self.displayLayer.frameCount) - round((CGFloat)self.displayLayer.frameCount/2));
    if([self _setFrameIndexOffset:frameIndexOffset]){
        [self updateThumbnailsPosition];
    }
    [self _setFrameIndexOffsetHasChanging:YES];
}

- (void)_setFrameIndexOffsetHasChanging:(BOOL)frameIndexOffsetHasChanging {
    if(_frameIndexOffsetHasChanging != frameIndexOffsetHasChanging){
        [self willChangeValueForKey:@keypath(self.frameIndexOffsetHasChanging)];
        _frameIndexOffsetHasChanging = frameIndexOffsetHasChanging;
        [self didChangeValueForKey:@keypath(self.frameIndexOffsetHasChanging)];
    }
}


@end