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
        //control
        [_displayLayer.imageSet.images eachWithIndex:^(STCapturedImage *frameImage, NSUInteger index) {
            NSAssert(frameImage.thumbnailUrl,@"frameImage.thumbnailUrl");

            UIImageView * thumbnailCellView = [[UIImageView alloc] initWithSize:CGSizeMake(self.minThumbnailWidth, self.squareUnitWidth)];
            thumbnailCellView.tagName = frameImage.uuid;
            thumbnailCellView.tag = TagPrefixThumbImageView+index;
            thumbnailCellView.contentMode = UIViewContentModeCenter;
            thumbnailCellView.clipsToBounds = YES;
            [self addSubview:thumbnailCellView];

            //size : 414(6s plus)
            UIImage * thumbnailImage = [UIImage imageWithContentsOfFile:frameImage.thumbnailUrl.path];
            thumbnailCellView.image = thumbnailImage;
        }];
        [self updateThumbnailsPosition];

        if(!_frameOffsetSlider){
            _frameOffsetSlider = [[STSegmentedSliderView alloc] initWithSize:CGSizeMake(self.width-self.squareUnitWidth, self.squareUnitWidth)];
            _frameOffsetSlider.delegateSlider = self;
            [self addSubview:_frameOffsetSlider];
        }
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
        UIImageView * thumbnailCellView = [self viewWithTag:TagPrefixThumbImageView+index];
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
    UIView * thumbView = [[UIView alloc] initWithSize:CGSizeMake(14, self.height)];
    thumbView.backgroundColor = [UIColor blackColor];
    return thumbView;
}

- (UIView *)createBackgroundView:(CGRect)bounds {
    return nil;
}

- (void)didSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index {
    [self doingSlide:timeSlider withSelectedIndex:index];
}

- (void)doingSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index {

    NSInteger frameIndexOffset = (NSInteger) ((timeSlider.normalizedPosition * self.displayLayer.frameCount) - round((CGFloat)self.displayLayer.frameCount/2));
    if([self _setFrameIndexOffset:frameIndexOffset]){
        [self updateThumbnailsPosition];
    }
}

@end