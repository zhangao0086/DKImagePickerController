//
// Created by BLACKGENE on 7/14/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STAfterImageLayerEffect.h"
#import "STAfterImageLayerItem.h"

@implementation STAfterImageLayerEffect{
}

#pragma mark Process

- (UIImage *)processEffect:(NSArray<UIImage *> *__nullable)sourceImages {
    return [sourceImages firstObject];
}

@end