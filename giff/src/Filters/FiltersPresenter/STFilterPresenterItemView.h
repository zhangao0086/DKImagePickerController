//
// Created by BLACKGENE on 2014. 10. 3..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"

@class STPhotoItem;
@class STFilterItem;

@interface STFilterPresenterItemView : UIImageView
@property (nonatomic, readonly) GPUImageView * gpuView;
@property (nonatomic, weak) STFilterItem * targetFilterItem;

+ (GPUImageFillModeType)fillMode;

- (void)usingGPUImage;

- (void)describeFilterInfoForDebug:(STFilterItem *)filterItem;
@end