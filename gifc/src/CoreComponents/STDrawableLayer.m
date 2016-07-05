//
// Created by BLACKGENE on 15. 5. 11..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STDrawableLayer.h"


@implementation STDrawableLayer

#pragma mark Overrided.

- (instancetype)init; {
    self = [super init];
    if (self) {
        self.opaque = NO;
        self.contentsScale = [UIScreen mainScreen].scale;
    }
    return self;
}

+ (instancetype)layer; {
    NSAssert(NO, @"Use STDrawableLayer.layerWithSize instead.");
    return nil;
}

- (void)setNeedsDisplay; {
    NSAssert(!CGRectIsNull(self.frame) && !CGRectIsEmpty(self.frame), @"self.frame must be filled.");
    [super setNeedsDisplay];
}

- (void)drawInContext:(CGContextRef)ctx; {
    [super drawInContext:ctx];

    UIGraphicsPushContext(ctx);

    if(self.blockForDraw){
        self.blockForDraw(ctx);
    }else{
        [self st_drawInContext:ctx];
    }

    UIGraphicsPopContext();
}

#pragma mark Impl.

+ (instancetype)layerWithSize:(CGSize)size{
    STDrawableLayer * layer = [[self alloc] init];
    layer.frame = (CGRect){CGPointZero, size};
    [layer setNeedsDisplay];
    return layer;
}

- (void)setBlockForDraw:(void (^)(CGContextRef))blockForDraw; {
    if(blockForDraw){
        _blockForDraw = blockForDraw;
        [self setNeedsDisplay];
    }
}

- (void)st_drawInContext:(CGContextRef)ctx; {
    SUBCLASSES_MUST_OVERRIDE
}
@end