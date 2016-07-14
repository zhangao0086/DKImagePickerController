//
// Created by BLACKGENE on 7/14/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STAfterImageLayersColorEffect.h"
#import "GPUImageContext.h"
#import "STFilterManager.h"
#import "STFilter.h"
#import "Colours.h"


@implementation STAfterImageLayersColorEffect {

}
- (instancetype)initWithColor:(UIColor *)color {
    self = [super init];
    if (self) {
        self.color = color;
    }

    return self;
}

+ (instancetype)effectWithColor:(UIColor *)color {
    return [[self alloc] initWithColor:color];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _intensity = 1;
    }
    return self;
}

- (UIImage *)processEffect:(UIImage *__nullable)sourceImage {
    GPUImageFalseColorFilter * sourceFilter = [[GPUImageFalseColorFilter alloc] init];
//    sourceFilter.intensity = self.intensity;
    NSArray* colors = [self.color rgbaArray];
    [sourceFilter setFirstColorRed:[colors[0] floatValue] green:[colors[1] floatValue] blue:[colors[2] floatValue]];

    STFilter * filter = [[STFilter alloc] initWithFilters:@[sourceFilter]];
    return [[STFilterManager sharedManager]
            buildOutputImage:sourceImage
                     enhance:NO
                      filter:filter
            extendingFilters:nil
                rotationMode:kGPUImageNoRotation
                 outputScale:1
       useCurrentFrameBuffer:YES
          lockFrameRendering:NO];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.intensity = [decoder decodeFloatForKey:@keypath(self.intensity)];
        self.color = [UIColor colorFromRGBAArray:[decoder decodeObjectForKey:@keypath(self.color)]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeFloat:self.intensity forKey:@keypath(self.intensity)];
    [encoder encodeObject:[self.color rgbaArray] forKey:@keypath(self.color)];
}

@end