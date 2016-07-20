//
// Created by BLACKGENE on 7/14/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"

@class STCapturedImageSetDisplayLayer;

@interface STCapturedImageSetDisplayableProcessor : STItem
- (UIImage *)processEffect:(NSArray<UIImage *> *__nullable)sourceImages;

- (NSUInteger)supportedNumberOfSourceImages;
@end