//
// Created by BLACKGENE on 8/17/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "UIImage+DisplayLayerEffect.h"
#import "GPUImage.h"
#import "UIImage+FloodFill.h"

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
#define A(x) ( Mask8(x >> 24) )
#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )

@implementation UIImage (DisplayLayerEffect)

- (UIImage *)removeEdgeMaskedBackground{

    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:self];

    GPUImagePrewittEdgeDetectionFilter *filter = [[GPUImagePrewittEdgeDetectionFilter alloc] init];
    [filter setEdgeStrength:0.04];

    [stillImageSource addTarget:filter];
    [filter useNextFrameForImageCapture];
    [stillImageSource processImage];

    UIImage *resultImage = [filter imageFromCurrentFramebuffer];

    UIImage *processedImage = [resultImage floodFillFromPoint:CGPointMake(0, 0) withColor:[UIColor magentaColor] andTolerance:0];

    CGImageRef inputCGImage=processedImage.CGImage;
    UInt32 * inputPixels;
    NSUInteger inputWidth = CGImageGetWidth(inputCGImage);
    NSUInteger inputHeight = CGImageGetHeight(inputCGImage);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;

    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;

    inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));

    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight, bitsPerComponent, inputBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), inputCGImage);

    for (NSUInteger j = 0; j < inputHeight; j++) {
        for (NSUInteger i = 0; i < inputWidth; i++) {
            UInt32 * currentPixel = inputPixels + (j * inputWidth) + i;
            UInt32 color = *currentPixel;

            if (R(color) == 255 && G(color) == 0 &&   B(color) == 255) {
                *currentPixel = RGBAMake(0, 0, 0, A(0));
            }else{
                *currentPixel = RGBAMake(0, 0, 0, 255);
            }
        }
    }
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage * maskImage = [UIImage imageWithCGImage:newCGImage];
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(inputPixels);

    GPUImagePicture *maskImageSource = [[GPUImagePicture alloc] initWithImage:maskImage];

    GPUImageGaussianBlurFilter *blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    [blurFilter setBlurRadiusInPixels:0.7];
    [maskImageSource addTarget:blurFilter];
    [blurFilter useNextFrameForImageCapture];
    [maskImageSource processImage];

    UIImage *blurMaskImage = [blurFilter imageFromCurrentFramebuffer];
    //return blurMaskImage;
    UIImage *result = [self maskImageWithMask:blurMaskImage];

    return result;
}

- (UIImage*) maskImageWithMask:(UIImage *)maskImage {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    CGImageRef maskImageRef = [maskImage CGImage];

    // create a bitmap graphics context the size of the image
    CGContextRef mainViewContentContext = CGBitmapContextCreate (NULL, (size_t) maskImage.size.width, (size_t) maskImage.size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);

    if (mainViewContentContext==NULL)
        return NULL;

    CGFloat ratio = 0;

    ratio = maskImage.size.width/ self.size.width;

    if(ratio * self.size.height < maskImage.size.height) {
        ratio = maskImage.size.height/ self.size.height;
    }

    CGRect rect1  = { {0, 0}, {maskImage.size.width, maskImage.size.height} };
    CGRect rect2  = { {-((self.size.width*ratio)-maskImage.size.width)/2 , -((self.size.height*ratio)-maskImage.size.height)/2}, {self.size.width*ratio, self.size.height*ratio} };


    CGContextClipToMask(mainViewContentContext, rect1, maskImageRef);
    CGContextDrawImage(mainViewContentContext, rect2, self.CGImage);


    // Create CGImageRef of the main view bitmap content, and then
    // release that bitmap context
    CGImageRef newImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);

    UIImage *theImage = [UIImage imageWithCGImage:newImage];

    CGImageRelease(newImage);

    // return the image
    return theImage;
}

@end