//
// Created by BLACKGENE on 7/26/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"
#import "STCapturedImageSetDisplayObject.h"

@class STCapturedImageSet;


@interface STCapturedImageSetDisplayLayer : STCapturedImageSetDisplayObject
@property (nonatomic, readonly) STCapturedImageSet * imageSet;

- (instancetype)initWithImageSet:(STCapturedImageSet *)imageSet;

+ (instancetype)layerWithImageSet:(STCapturedImageSet *)imageSet;

@end
