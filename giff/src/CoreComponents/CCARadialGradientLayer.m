//
//  CCARadialGradientLayer.m
//  CCARadialGradientLayer
//
//  Created by Jean-Luc Dagon on 19/01/2014.
//
//  Copyright (c) 2014 Cocoapps.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "CCARadialGradientLayer.h"

struct CCARadialGradientLayerProperties
{
    __unsafe_unretained NSString *gradientOrigin;
    __unsafe_unretained NSString *gradientRadius;
    __unsafe_unretained NSString *colors;
    __unsafe_unretained NSString *locations;
};

const struct CCARadialGradientLayerProperties CCARadialGradientLayerProperties = {
	.gradientOrigin = @"gradientOrigin",
    .gradientRadius = @"gradientRadius",
    .colors = @"colors",
    .locations = @"locations",
};

@implementation CCARadialGradientLayer

@dynamic gradientOrigin;
@dynamic gradientRadius;
@dynamic colors;
@dynamic locations;

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:CCARadialGradientLayerProperties.gradientOrigin]
        || [key isEqualToString:CCARadialGradientLayerProperties.gradientRadius]
        || [key isEqualToString:CCARadialGradientLayerProperties.colors]
        || [key isEqualToString:CCARadialGradientLayerProperties.locations])
    {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (id)actionForKey:(NSString *) key
{
    if ([key isEqualToString:CCARadialGradientLayerProperties.gradientOrigin]
        || [key isEqualToString:CCARadialGradientLayerProperties.gradientRadius]
        || [key isEqualToString:CCARadialGradientLayerProperties.colors]
        || [key isEqualToString:CCARadialGradientLayerProperties.locations])
    {
         CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:key];
        theAnimation.fromValue = [self.presentationLayer valueForKey:key];
        return theAnimation;
    }
    return [super actionForKey:key];
}

- (void)drawInContext:(CGContextRef)theContext
{
    NSInteger numberOfLocations = self.locations.count;
    NSInteger numbOfComponents = 0;
    CGColorSpaceRef colorSpace = NULL;
    
    if (self.colors.count) {
        CGColorRef colorRef = (__bridge CGColorRef)[self.colors objectAtIndex:0];
        numbOfComponents = CGColorGetNumberOfComponents(colorRef);
        colorSpace = CGColorGetColorSpace(colorRef);
    }
    
    CGFloat gradientLocations[numberOfLocations];
    CGFloat gradientComponents[numberOfLocations * numbOfComponents];
    
    for (NSInteger locationIndex = 0; locationIndex < numberOfLocations; locationIndex++) {

        gradientLocations[locationIndex] = [self.locations[locationIndex] floatValue];
        const CGFloat *colorComponents = CGColorGetComponents((__bridge CGColorRef)self.colors[locationIndex]);

        for (NSInteger componentIndex = 0; componentIndex < numbOfComponents; componentIndex++) {
            gradientComponents[numbOfComponents * locationIndex + componentIndex] = colorComponents[componentIndex];
        }
    }
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradientComponents, gradientLocations, numberOfLocations);
    CGContextDrawRadialGradient(theContext, gradient, self.gradientOrigin, 0, self.gradientOrigin, self.gradientRadius, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
}

@end
