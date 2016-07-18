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
    if(imageSet.count) {
        BOOL newImageSet = ![imageSet isEqual:_imageSet];
        _imageSet = imageSet;

        //set - heavy cost
        if (newImageSet) {
            NSArray * presentableObjectForImageSet = [self presentableObjectsForImageSet];
            NSAssert(!presentableObjectForImageSet || presentableObjectForImageSet.count==_imageSet.count,@"The count of presentableObjectForImageSet must be matched to its count of imageset");
            [self setViews:presentableObjectForImageSet];
        }
    }else{
        //clear
        [self clearViews];
        _imageSet = nil;
    }
}

- (NSArray *)presentableObjectsForImageSet{
    if(_imageSet.images.count){
        STCapturedImage * anyImage = [_imageSet.images firstObject];
        NSAssert(anyImage.imageUrl, @"STCapturedImage's imageUrl does not exist.");
        return[_imageSet.images mapWithItemsKeyPath:@keypath(anyImage.fullScreenUrl) orDefaultKeypath:@keypath(anyImage.imageUrl)];
    }
    return nil;
}

@end