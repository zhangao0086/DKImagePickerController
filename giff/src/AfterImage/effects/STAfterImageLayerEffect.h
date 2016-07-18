//
// Created by BLACKGENE on 7/14/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"
#import "GPUImage.h"
#import "STFilter.h"
#import "STFilterManager.h"

@class STAfterImageLayerItem;

@interface STAfterImageLayerEffect : STItem
- (UIImage *)processEffect:(NSArray<UIImage *> *__nullable)sourceImages;
@end