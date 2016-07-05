//
//  UIColor+LEColorPicker.m
//  LEColorPicker
//
//  Created by Luis Enrique Espinoza Severino on 03-12-12.
//  Copyright (c) 2012 Luis Espinoza. All rights reserved.
//

#import "UIColor+YUVSpace.h"
#import <float.h>

@implementation UIColor (YUVSpace)

+ (float)yComponentFromColor:(UIColor *)color
{
    float red = 0.0;
    float green = 0.0;
    float blue = 0.0;
    float alpha = 0.0;
    float y = 0.0;
    
    if (color) {
        size_t numComponents = CGColorGetNumberOfComponents(color.CGColor);
        
        if (numComponents == 4) {
            const CGFloat *components = CGColorGetComponents(color.CGColor);
            red = components[0];
            green = components[1];
            blue = components[2];
            alpha = components[3];
        }
        
        y = 0.299*red + 0.587*green+ 0.114*blue;
        
    }
    
    return y;
}

+ (float)uComponentFromColor:(UIColor *)color
{
    float red = 0.0;
    float green = 0.0;
    float blue = 0.0;
    float alpha = 0.0;
    float u = 0.0;
    
    if (color) {
        size_t numComponents = CGColorGetNumberOfComponents(color.CGColor);
        
        if (numComponents == 4) {
            const CGFloat *components = CGColorGetComponents(color.CGColor);
            red = components[0];
            green = components[1];
            blue = components[2];
            alpha = components[3];
        }
        
        u = (-0.14713)*red + (-0.28886)*green + (0.436)*blue;
    }
    
    return u;
}

+ (float)vComponentFromColor:(UIColor *)color
{
    float red = 0.0;
    float green = 0.0;
    float blue = 0.0;
    float alpha = 0.0;
    float v = 0.0;
    
    if (color) {
        size_t numComponents = CGColorGetNumberOfComponents(color.CGColor);
        
        if (numComponents == 4) {
            const CGFloat *components = CGColorGetComponents(color.CGColor);
            red = components[0];
            green = components[1];
            blue = components[2];
            alpha = components[3];
        }
        
        v = 0.615*red + (-0.51499)*green + (-0.10001)*blue;
    }
    
    return v;
}

+ (float)YUVSpaceDistanceToColor:(UIColor *)toColor fromColor:(UIColor *)fromColor
{
    float YToColor = [UIColor yComponentFromColor:toColor];
    float UToColor = [UIColor uComponentFromColor:toColor];
    float VToColor = [UIColor vComponentFromColor:toColor];
    
    float YFromColor = [UIColor yComponentFromColor:fromColor];
    float UFromColor = [UIColor uComponentFromColor:fromColor];
    float VFromColor = [UIColor vComponentFromColor:fromColor];
    
    float deltaY = YToColor - YFromColor;
    float deltaU = UToColor - UFromColor;
    float deltaV = VToColor - VFromColor;
    
    float distance = sqrtf(deltaY*deltaY + deltaU*deltaU + deltaV*deltaV);
    
    return distance;
}

+ (float)YUVSpaceSquareDistanceToColor:(UIColor *)toColor fromColor:(UIColor *)fromColor
{
    float YToColor = [UIColor yComponentFromColor:toColor];
    float UToColor = [UIColor uComponentFromColor:toColor];
    float VToColor = [UIColor vComponentFromColor:toColor];
    
    float YFromColor = [UIColor yComponentFromColor:fromColor];
    float UFromColor = [UIColor uComponentFromColor:fromColor];
    float VFromColor = [UIColor vComponentFromColor:fromColor];
    
    float deltaY = YToColor - YFromColor;
    float deltaU = UToColor - UFromColor;
    float deltaV = VToColor - VFromColor;
    
    float distance = deltaY*deltaY + deltaU*deltaU + deltaV*deltaV;
    
    return distance;
}



@end
