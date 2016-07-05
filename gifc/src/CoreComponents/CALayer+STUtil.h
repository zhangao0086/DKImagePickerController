//
// Created by BLACKGENE on 2014. 10. 30..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface CALayer (STUtil)
@property (nonatomic, assign) BOOL rasterizationEnabled;
@property (nonatomic, assign) CGFloat scaleXYValue;

- (UIImage *)UIImage;

- (UIImage *)UIImage:(BOOL)opaque;

+ (instancetype)layerWithSize:(CGSize)size;

+ (CALayer *)layerWithMaskedImage:(UIImage *)image size:(CGSize)size color:(UIColor *)color;

+ (CALayer *)layerWithColorMaskWrapped:(CALayer *)targetLayer color:(UIColor *)color;

+ (CALayer *)layerWithImage:(UIImage *)image centerInSize:(CGSize)size;

+ (CALayer *)layerWithImage:(UIImage *)image centerInSizeAndFitScaleIfOversized:(CGSize)size;

+ (CALayer *)layerWithImage:(UIImage *)image;

+ (CALayer *)circleRaster:(CGFloat)diameter inset:(CGPoint)point color:(UIColor *)color;

+ (CALayer *)circleRaster:(CGFloat)diameter;

+ (CALayer *)circleRaster:(CGFloat)diameter inset:(CGPoint)point color:(UIColor *)color name:(NSString *)name;

- (void)st_removeAllSublayers;

- (void)st_removeAllSublayersRecursively;

- (NSArray *)st_allSublayersRecursively;

- (CALayer *)setImage:(UIImage *)image;

- (void)setVisible:(BOOL)visible;

- (BOOL)isVisible;

- (CALayer *)layerWithName:(NSString *)name;

- (CALayer *)setRasterize;

- (CALayer *)setRasterizeDoubleScaled;

- (void)centerToParent;

- (void)centerToSize:(CGSize)size;
@end
