//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STEditControlFrameEditItemView.h"
#import "STCapturedImageSet.h"
#import "STCapturedImageSetDisplayLayer.h"
#import "STCapturedImage.h"
#import "UIView+STUtil.h"
#import "STSelectableView.h"
#import "STStandardButton.h"
#import "R.h"


@implementation STEditControlFrameEditItemView {
    UIView * _thumbnailCellContainerView;

    STStandardButton * _removeButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _removeButton = [[STStandardButton alloc] initWithSizeWidth:self.height];
        [self addSubview:_removeButton];
        [_removeButton setButtons:@[R.go_remove] colors:nil style:STStandardButtonStylePTBT];
        _removeButton.right = self.right;
    }

    return self;
}


- (void)setImageSet:(STCapturedImageSet *)imageSet {
    _imageSet = imageSet;

    if(_imageSet.count){
        CGFloat squareWidth = self.height;
        CGFloat maxThumbnailWidth = (self.width-squareWidth)/_imageSet.count;

        [_imageSet.images eachWithIndex:^(STCapturedImage *frameImage, NSUInteger index) {
            NSAssert(frameImage.thumbnailUrl,@"frameImage.thumbnailUrl");
            UIImageView * thumbnailCellView = [[UIImageView alloc] initWithSizeWidth:squareWidth];
            [self addSubview:thumbnailCellView];
            //size : 414(6s plus)
            UIImage * thumbnailImage = [UIImage imageWithContentsOfFile:frameImage.thumbnailUrl.path];
            thumbnailCellView.image = thumbnailImage;
            thumbnailCellView.x = maxThumbnailWidth * index;
        }];

        [self bringSubviewToFront:_removeButton];
        
    }else{
        [self disposeContent];
    }
}

- (void)disposeContent {
    _imageSet = nil;

    [self clearAllOwnedImagesIfNeeded:NO removeSubViews:YES];

    [super disposeContent];
}


@end