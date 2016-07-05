//
// Created by BLACKGENE on 2015. 2. 27..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STTransformEditorResult.h"


@implementation STTransformEditorResult {

}

- (instancetype)initWithRect:(CGRect)rect orientation:(UIImageOrientation)orientation imageSize:(CGSize)imageSize translateOffset:(CGPoint)translateOffset rotationAngle:(CGFloat)rotationAngle; {
    self = [super init];
    if (self) {
        _rect = rect;
        _orientation = orientation;
        _imageSize = imageSize;
        _translateOffset = translateOffset;
        _rotationAngle = rotationAngle;
    }
    return self;
}

- (UIImage *)modifiyImage:(UIImage *)inputImage; {

    inputImage = [UIImage imageWithCGImage:inputImage.CGImage scale:inputImage.scale orientation:self.orientation];

    CGFloat factor = inputImage.size.width / self.imageSize.width;
    CGRect rect = CGRectApplyAffineTransform(self.rect, CGAffineTransformMakeScale(factor,factor));
    CGPoint offset = CGPointApplyAffineTransform(self.translateOffset, CGAffineTransformMakeScale(factor,factor));

    UIGraphicsBeginImageContextWithOptions(rect.size, YES, inputImage.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] setFill];
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height));

    CGContextTranslateCTM(context, rect.size.width/2.0f, rect.size.height/2.0f);
    CGContextTranslateCTM(context, offset.x, offset.y);
    CGContextRotateCTM(context, self.rotationAngle);
    CGContextTranslateCTM(context, -inputImage.size.width/2.0f, -inputImage.size.height/2.0f);

    [inputImage drawAtPoint:CGPointZero];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return image;
}


@end