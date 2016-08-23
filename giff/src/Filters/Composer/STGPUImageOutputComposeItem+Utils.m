//
// Created by BLACKGENE on 8/23/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGPUImageOutputComposeItem+Utils.h"
#import "GPUImageMaskFilter.h"
#import "STRasterizingImageSourceItem.h"


@implementation STGPUImageOutputComposeItem (Utils)


+ (instancetype)itemForComposerMask:(STRasterizingImageSourceItem *)imageSourceItem size:(CGSize)imageSize{
    UIImage * rasterizedImage = [imageSourceItem rasterize:imageSize];
    STGPUImageOutputComposeItem * imageOutputComposeItem = [STGPUImageOutputComposeItem itemWithSourceImage:rasterizedImage
                                            composer:[[GPUImageMaskFilter alloc] init]];
    imageOutputComposeItem.category = STGPUImageOutputComposeItemCategoryMask;
    return imageOutputComposeItem;
}
@end