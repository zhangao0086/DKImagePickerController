//
// Created by BLACKGENE on 7/26/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"

@class STCapturedImageSet;


@interface STCapturedImageSetDisplayLayer : STItem
@property (nonatomic, readonly) STCapturedImageSet * imageSet;

- (instancetype)initWithImageSet:(STCapturedImageSet *)imageSet;

+ (instancetype)layerWithImageSet:(STCapturedImageSet *)imageSet;

@end
