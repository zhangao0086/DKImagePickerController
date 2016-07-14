//
// Created by BLACKGENE on 7/14/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"
#import "GPUImage.h"
#import "STFilter.h"
#import "STFilterManager.h"

@interface STAfterImageLayerEffect : STItem
- (UIImage *)processEffect:(UIImage * __nullable)sourceImage;
@end