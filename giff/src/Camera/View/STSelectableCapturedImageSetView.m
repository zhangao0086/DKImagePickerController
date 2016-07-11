//
// Created by BLACKGENE on 7/11/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STSelectableCapturedImageSetView.h"
#import "STCapturedImageSet.h"
#import "STCapturedImage.h"
#import "NSArray+STUtil.h"
#import "STCapturedImageProtected.h"

@implementation STSelectableCapturedImageSetView

- (void)dealloc {
    self.imageSet = nil;
}

- (void)setImageSet:(STCapturedImageSet *)imageSet {
    //sub set
    if(imageSet) {
        BOOL newImageSet = ![imageSet isEqual:_imageSet];
        _imageSet = imageSet;

        //set - heavy cost
        if (newImageSet) {
            STCapturedImage * anyImage = [_imageSet.images firstObject];
            NSAssert(anyImage.imageUrl, @"STCapturedImage's imageUrl does not exist.");
            NSArray<NSURL *>* imageUrls = [_imageSet.images mapWithItemsKeyPath:@keypath(anyImage.fullScreenUrl) orDefaultKeypath:@keypath(anyImage.imageUrl)];

            [self setViews:imageUrls];
        }
    }else{
        //clear
        [self clearViews];
        _imageSet = nil;
    }
}

@end