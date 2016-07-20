//
// Created by BLACKGENE on 7/14/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImageSetDisplayableProcessor.h"

@implementation STCapturedImageSetDisplayableProcessor{
}

#pragma mark Process

- (UIImage *)processEffect:(NSArray<UIImage *> *__nullable)sourceImages {
    return [sourceImages firstObject];
}

- (NSUInteger)supportedNumberOfSourceImages {
    return 1;
}
@end