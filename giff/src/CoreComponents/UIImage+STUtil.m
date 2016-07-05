#import <ImageIO/ImageIO.h>
#import "UIImage+STUtil.h"
#import "NSObject+STUtil.h"
#import "NYXImagesKit.h"
#import "NSString+STUtil.h"

@implementation UIImage (STUtil)

#pragma mark - Clip
- (UIImage *)clipAsRoundedRect:(CGSize)sizeToFit  {
    return [self clipAsRoundedRect:sizeToFit cornerRadius:self.size.height/2];
}

- (UIImage *)clipAsRoundedRectWithCornerRadius:(CGFloat)radius{
    return [self clipAsRoundedRect:self.size cornerRadius:radius];
}

- (UIImage *)clipAsRoundedRectWithCornerRadius:(CGFloat)radius cropAsSquare:(BOOL)crop{
    UIImage * image = self;
    if(crop){
        image = [image cropToSize:CGSizeMakeValue(MIN(image.size.width, image.size.height)) usingMode:NYXCropModeCenter];
    }
    return [image clipAsRoundedRect:image.size cornerRadius:radius];
}

- (UIImage *)clipAsRoundedRect:(CGSize)sizeToFit cornerRadius:(CGFloat)radius {
    CGRect rect = (CGRect){0.f, 0.f, sizeToFit};

    UIGraphicsBeginImageContextWithOptions(sizeToFit, NO, UIScreen.mainScreen.scale);
    CGContextAddPath(UIGraphicsGetCurrentContext(), [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius].CGPath);
    CGContextClip(UIGraphicsGetCurrentContext());

    [self drawInRect:rect];
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return output;
}

- (UIImage *)clipAsCenteredCircle{
    return [self clipAsCircle:MIN(self.size.width, self.size.height) scale:UIScreen.mainScreen.scale];
}

- (UIImage *)clipAsCircle:(CGFloat)diameter{
    return [self clipAsCircle:diameter scale:UIScreen.mainScreen.scale];
}

- (UIImage *)clipAsCircle:(CGFloat)diameter scale:(CGFloat)scale{
    CGRect rect = CGRectMakeValue(diameter);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    [self drawInRect:rect];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Color
// 0.000727s
- (UIImage *)maskWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawInRect:rect];

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextSetBlendMode(context, kCGBlendModeSourceAtop);
    CGContextFillRect(context, rect);

    UIImage *maskImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return maskImage;
}

- (UIColor *)averageColor
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }
    else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}

#pragma mark - Orientation
+ (UIImageOrientation)imageOrientationWithExifOrientation:(NSUInteger)exifOrientation
{
    switch (exifOrientation) {
        case kCGImagePropertyOrientationUp: return UIImageOrientationUp;
        case kCGImagePropertyOrientationDown: return UIImageOrientationDown;
        case kCGImagePropertyOrientationLeft: return UIImageOrientationLeft;
        case kCGImagePropertyOrientationRight: return UIImageOrientationRight;
        case kCGImagePropertyOrientationUpMirrored: return UIImageOrientationUpMirrored;
        case kCGImagePropertyOrientationDownMirrored: return UIImageOrientationDownMirrored;
        case kCGImagePropertyOrientationLeftMirrored: return UIImageOrientationLeftMirrored;
        case kCGImagePropertyOrientationRightMirrored: return UIImageOrientationRightMirrored;
        default: return UIImageOrientationUp;
    }
}

+ (NSUInteger)exifOrientation:(UIImageOrientation)imageOrientation{
    switch (imageOrientation) {
        case UIImageOrientationUp: return kCGImagePropertyOrientationUp;
        case UIImageOrientationDown: return kCGImagePropertyOrientationDown;
        case UIImageOrientationLeft: return kCGImagePropertyOrientationLeft;
        case UIImageOrientationRight: return kCGImagePropertyOrientationRight;
        case UIImageOrientationUpMirrored: return kCGImagePropertyOrientationUpMirrored;
        case UIImageOrientationDownMirrored: return kCGImagePropertyOrientationDownMirrored;
        case UIImageOrientationLeftMirrored: return kCGImagePropertyOrientationLeftMirrored;
        case UIImageOrientationRightMirrored: return kCGImagePropertyOrientationRightMirrored;
        default: return kCGImagePropertyOrientationUp;
    }
}

- (NSUInteger)exifOrientation
{
    return [self.class exifOrientation:self.imageOrientation];
}



- (CGSize) sizeWithRasterizationScale{
    return CGSizeByScale(self.size, self.scale);
}

#pragma mark image I/O
+ (UIImage *)imageBundled:(NSString*)aFileName {
    NSString* stringPath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], aFileName];
    UIImage * image = [UIImage imageWithContentsOfFile:stringPath];
    NSAssert(image && !CGSizeEqualToSize(image.size, CGSizeZero), ([NSString stringWithFormat:@"Error : empty image : '%@'", stringPath]));
    return image;
}


+ (NSArray *)imageArrayBundled:(NSArray*)fileNames {
    NSAssert(fileNames && ![fileNames containsObject:[NSNull null]], @"'fileNames' must be fully not-null values.");

    NSMutableArray * array = [NSMutableArray arrayWithCapacity:fileNames.count];
    for(NSString *name in fileNames){
        @autoreleasepool {
            [array addObject:[self imageBundled:name]];
        }
    }
    return array;
}

+ (UIImage *)imageBundledCache:(NSString*)aFileName {
    NSString* stringPath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], aFileName];
    Weaks
    return [self st_cachedImage:stringPath init:^UIImage * {
        return [Wself imageBundled:aFileName];
    }];
}

+ (NSArray *)imageArrayBundledCache:(NSArray*)fileNames {
    NSAssert(fileNames && ![fileNames containsObject:[NSNull null]], @"'fileNames' must be fully not-null values.");

    NSMutableArray * array = [NSMutableArray arrayWithCapacity:fileNames.count];
    for(NSString *name in fileNames){
        @autoreleasepool {
            [array addObject:[self imageBundledCache:name]];
        }
    }
    return array;
}

+ (UIImage *)imageWithDocument:(NSString *)relativeFilePath{
    return [UIImage imageWithContentsOfFile:[relativeFilePath absolutePathFromDocument]];
}

+ (UIImage *)imageWithURL:(NSURL *)url
{
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
}

+ (UIImage *)imageAsColor:(UIColor *)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)imageAsColor:(UIColor *)color withSize:(CGSize)size
{
    if(!color){
        color = [UIColor whiteColor];
    }

    CGRect rect = (CGRect){CGPointZero, size};
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


+ (CGAffineTransform)fixingTransformForOrientation:(UIImageOrientation)orientation size:(CGSize)size {
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (orientation) {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, size.width, size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;

        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }

    switch (orientation) {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }

    return transform;
}

+ (UIImageOrientation)imageOrientationFromCurrentDeviceOrientation; {
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    UIImageOrientation imageOrientation = UIImageOrientationUp;
    switch (deviceOrientation)
    {
        case UIDeviceOrientationPortrait:
            imageOrientation = UIImageOrientationUp;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            imageOrientation = UIImageOrientationDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            imageOrientation = UIImageOrientationLeft;
            break;
        case UIDeviceOrientationLandscapeRight:
            imageOrientation = UIImageOrientationRight;
            break;
        default:
            imageOrientation = UIImageOrientationUp;
            break;
    }
    return imageOrientation;
}

#pragma mark Text
- (UIImage*)addText:(NSString*)text {
    return [self addText:text size:self.size backgroundColor:[UIColor whiteColor] fontSize:9 fontColor:[UIColor blackColor]];
}

- (UIImage*)addText:(NSString*)text size:(CGSize)size backgroundColor:(UIColor*)backgroundColor fontSize:(CGFloat)fontSize fontColor:(UIColor*)fontColor {
    backgroundColor?:(backgroundColor = [UIColor whiteColor]);

    UIGraphicsBeginImageContext(size);

    CGContextRef context = UIGraphicsGetCurrentContext();

// the image should have a white background
    [[UIColor clearColor] set];
    CGRect myRect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIRectFill(myRect);

    [backgroundColor set];

// Drawing code
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:14]};
// NSString class method: boundingRectWithSize:options:attributes:context is
// available only on ios7.0 sdk.
    CGRect rect = [text boundingRectWithSize:CGSizeMake(size.width, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
    CGSize textSize = rect.size;

    double capDiameter = textSize.height;
    double capRadius = capDiameter / 2.0;
    double capPadding = capDiameter / 4.0;
    double textWidth = MAX( capDiameter, textSize.width ) ;

    CGRect textBounds = CGRectMake(capPadding, 0.0, textWidth, textSize.height);

    CGRect badgeBounds = CGRectMake(0.0, 0.0, textWidth + (2.0 * capPadding), textSize.height);

    double offsetX = (CGRectGetMaxX(myRect) - CGRectGetMaxX(badgeBounds)) / 2.0;
    double offsetY = (CGRectGetMaxY(myRect) - CGRectGetMaxY(badgeBounds)) / 2.0;
    badgeBounds = CGRectOffset(badgeBounds, offsetX, offsetY);
    textBounds = CGRectOffset(textBounds, offsetX, offsetY);

    CGContextFillEllipseInRect(context,
            CGRectMake(badgeBounds.origin.x, badgeBounds.origin.y, capDiameter, capDiameter));

    CGContextFillEllipseInRect(context,
            CGRectMake(badgeBounds.origin.x + badgeBounds.size.width - capDiameter, badgeBounds.origin.y,
                    capDiameter, capDiameter));

    CGContextFillRect(context, CGRectMake(badgeBounds.origin.x + capRadius, badgeBounds.origin.y,
            badgeBounds.size.width - capDiameter, capDiameter));

    if(fontColor != nil) {
        const CGFloat* colors = CGColorGetComponents(fontColor.CGColor);
        CGColorSpaceRef space = CGColorGetColorSpace(fontColor.CGColor);
        CGColorSpaceModel model = CGColorSpaceGetModel(space);

        if(model == kCGColorSpaceModelMonochrome)
            // monochrome color space has one grayscale value and one alpha
            CGContextSetRGBFillColor(context, *(colors + 0), *(colors + 0), *(colors + 0), *(colors + 1));
        else
            // else a R,G,B,A scheme is assumed.
            CGContextSetRGBFillColor(context, *(colors + 0), *(colors + 1), *(colors + 2), *(colors + 3));
    } else
        // else use plain white
        CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);

    [text drawInRect:textBounds withAttributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:[UIFont systemFontSize]]}];

    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (UIImage *)negative
{
    // get width and height as integers, since we'll be using them as
    // array subscripts, etc, and this'll save a whole lot of casting
    CGSize size = self.size;
    int width = (int) size.width * self.scale;
    int height = (int) size.height * self.scale;

    // Create a suitable RGB+alpha bitmap context in BGRA colour space
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *memoryPool = (unsigned char *)calloc(width*height*4, 1);
    CGContextRef context = CGBitmapContextCreate(memoryPool, width, height, 8, width * 4, colourSpace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colourSpace);

    // draw the current image to the newly created context
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);

    // run through every pixel, a scan line at a time...
    for(int y = 0; y < height; y++)
    {
        // get a pointer to the start of this scan line
        unsigned char *linePointer = &memoryPool[y * width * 4];

        // step through the pixels one by one...
        for(int x = 0; x < width; x++)
        {
            // get RGB values. We're dealing with premultiplied alpha
            // here, so we need to divide by the alpha channel (if it
            // isn't zero, of course) to get uninflected RGB. We
            // multiply by 255 to keep precision while still using
            // integers
            int r, g, b;
            if(linePointer[3])
            {
                r = linePointer[0] * 255 / linePointer[3];
                g = linePointer[1] * 255 / linePointer[3];
                b = linePointer[2] * 255 / linePointer[3];
            }
            else
                r = g = b = 0;

            // perform the colour inversion
            r = 255 - r;
            g = 255 - g;
            b = 255 - b;

            // multiply by alpha again, divide by 255 to undo the
            // scaling before, store the new values and advance
            // the pointer we're reading pixel data from
            linePointer[0] = r * linePointer[3] / 255;
            linePointer[1] = g * linePointer[3] / 255;
            linePointer[2] = b * linePointer[3] / 255;
            linePointer += 4;
        }
    }

    // get a CG image from the context, wrap that into a
    // UIImage
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage scale:self.scale orientation:self.imageOrientation];

    // clean up
    CGImageRelease(cgImage);
    CGContextRelease(context);
    free(memoryPool);

    // and return
    return returnImage;
}

- (UIImage *)fixOrientation {

    return [self fixOrientation:self.imageOrientation];
}

- (UIImage *)fixOrientation:(UIImageOrientation)orientation {

    // No-op if the orientation is already correct
    if (orientation == UIImageOrientationUp) return self;

    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (orientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;

        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }

    switch (orientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }

    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
            CGImageGetBitsPerComponent(self.CGImage), 0,
            CGImageGetColorSpace(self.CGImage),
            CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (orientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;

        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }

    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage *)invertAlpha
{
    // scale is needed for retina devices
    CGFloat scale = [self scale];
    CGSize size = self.size;
    int width = size.width * scale;
    int height = size.height * scale;

    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();

    unsigned char *memoryPool = (unsigned char *)calloc(width*height*4, 1);

    CGContextRef context = CGBitmapContextCreate(memoryPool, width, height, 8, width * 4, colourSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast);

    CGColorSpaceRelease(colourSpace);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);

    for(int y = 0; y < height; y++)
    {
        unsigned char *linePointer = &memoryPool[y * width * 4];

        for(int x = 0; x < width; x++)
        {
            linePointer[3] = 255-linePointer[3];
            linePointer += 4;
        }
    }

    // get a CG image from the context, wrap that into a
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage scale:scale orientation:UIImageOrientationUp];

    // clean up
    CGImageRelease(cgImage);
    CGContextRelease(context);
    free(memoryPool);

    // and return
    return returnImage;
}

-(BOOL)isDarkImage:(CGFloat)pixelAmountRatio{
    UIImage* inputImage = self;

    BOOL isDark = FALSE;

    CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider(inputImage.CGImage));
    const UInt8 *pixels = CFDataGetBytePtr(imageData);

    NSUInteger darkPixels = 0;

    CFIndex length = CFDataGetLength(imageData);
    CGFloat darkPixelThreshold = (inputImage.size.width*inputImage.size.height)*pixelAmountRatio;

    for(NSUInteger i=0; i<length; i+=4)
    {
        NSUInteger r = pixels[i];
        NSUInteger g = pixels[i+1];
        NSUInteger b = pixels[i+2];

        //luminance calculation gives more weight to r and b for human eyes
        CGFloat luminance = (0.299f*r + 0.587f*g + 0.114f*b);
        if (luminance<150) darkPixels ++;
    }

    if (darkPixels >= darkPixelThreshold)
        isDark = YES;

    CFRelease(imageData);

    return isDark;

}

#pragma mark Animable
- (UIImage *)animatedImageWithAppendingReverse:(NSTimeInterval)newDuration{
    NSMutableArray * reverseImages = [NSMutableArray arrayWithArray:self.images];
    for(UIImage * image in [[reverseImages copy] reverseObjectEnumerator]){
        [reverseImages addObject:image];
    }
    return [UIImage animatedImageWithImages:reverseImages duration:newDuration?:self.duration*2];
}

#pragma mark overlay
- (UIImage*)drawOver:(UIImage *)targetImage atPosition:(CGPoint)origin{
    return [self drawOver:targetImage atPosition:origin alpha:1];
}

- (UIImage*)drawOver:(UIImage *)targetImage atPosition:(CGPoint)origin alpha:(float)alpha{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:CGRectMake( 0, 0, self.size.width, self.size.height)];
    CGRect imageRect = CGRectMake(origin.x, origin.y, targetImage.size.width, targetImage.size.height);
    if(alpha < 1){
        [targetImage drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:alpha];
    }else{
        [targetImage drawInRect:imageRect];
    }
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end