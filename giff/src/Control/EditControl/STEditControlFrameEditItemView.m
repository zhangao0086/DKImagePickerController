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
    UIView * _thumbnailCellContainerView;
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

- (void)setDisplayLayer:(STCapturedImageSetAnimatableLayer *)displayLayer {
    _displayLayer = displayLayer;

    if(_displayLayer.imageSet.count){
        CGFloat squareWidth = self.height;
        CGFloat maxThumbnailWidth = (self.width-squareWidth)/_displayLayer.imageSet.count;

        [_displayLayer.imageSet.images eachWithIndex:^(STCapturedImage *frameImage, NSUInteger index) {
            NSAssert(frameImage.thumbnailUrl,@"frameImage.thumbnailUrl");
            UIImageView * thumbnailCellView = [[UIImageView alloc] initWithSizeWidth:squareWidth];
            [self addSubview:thumbnailCellView];
            //size : 414(6s plus)
            UIImage * thumbnailImage = [UIImage imageWithContentsOfFile:frameImage.thumbnailUrl.path];
            thumbnailCellView.image = thumbnailImage;
            thumbnailCellView.x = maxThumbnailWidth * index;
        }];

        //control
        CGSize sliderControlSize = CGSizeMake(self.width-squareWidth, squareWidth);
        STSegmentedSliderView * offsetSlider = [[STSegmentedSliderView alloc] initWithSize:sliderControlSize];
        offsetSlider.normalizedPosition = .5;
        [self addSubview:offsetSlider];
        _frameOffsetSlider = offsetSlider;

        [self bringSubviewToFront:_removeButton];

    }else{
        [self disposeContent];
    }
}


- (void)disposeContent {
    _displayLayer = nil;

    [self clearAllOwnedImagesIfNeeded:NO removeSubViews:YES];

    _frameOffsetSlider = nil;
    _removeButton = nil;

    [super disposeContent];
}

@end