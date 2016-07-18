//
// Created by BLACKGENE on 7/14/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STAfterImageLayersColorEffect.h"
#import "Colours.h"


@implementation STAfterImageLayersColorEffect {

}
- (instancetype)init {
    self = [super init];
    if (self) {
        _intensity = 1;
    }
    return self;
}

- (instancetype)initWithColor:(UIColor *)color {
    self = [self init];
    self.color = color;
    return self;
}

+ (instancetype)effectWithColor:(UIColor *)color {
    return [[self alloc] initWithColor:color];
}

- (UIImage *)processEffect:(NSArray<UIImage *> *__nullable)sourceImages {
    NSAssert(sourceImages.count==1, @"Single sourceImage supported");

    GPUImageMonochromeFilter * sourceFilter = [[GPUImageMonochromeFilter alloc] init];
    sourceFilter.intensity = self.intensity;
    NSArray* colors = [self.color rgbaArray];
    [sourceFilter setColorRed:[colors[0] floatValue] green:[colors[1] floatValue] blue:[colors[2] floatValue]];

    STFilter * filter = [[STFilter alloc] initWithFilters:@[sourceFilter]];
    UIImage * result = [[STFilterManager sharedManager]
            buildOutputImage:[sourceImages firstObject]
                     enhance:NO
                      filter:filter
            extendingFilters:nil
                rotationMode:kGPUImageNoRotation
                 outputScale:1
       useCurrentFrameBuffer:YES
          lockFrameRendering:NO];
    return result;
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