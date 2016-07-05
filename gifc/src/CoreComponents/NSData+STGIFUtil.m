//
// Created by BLACKGENE on 2016. 4. 7..
// Copyright (c) 2016 stells. All rights reserved.
//

#import "NSData+STGIFUtil.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

#if TARGET_OS_WATCH
#import <WatchKit/WatchKit.h>
#endif

NSString * const AnimatedGIFImageErrorDomain = @"com.compuserve.gif.image.error";

__attribute__((overloadable)) UIImage * UIImageWithAnimatedGIFData(NSData *data) {
#if TARGET_OS_WATCH
    CGFloat screenScale = [[WKInterfaceDevice currentDevice] screenScale];
#else
    CGFloat screenScale = [[UIScreen mainScreen] scale];
#endif
    return UIImageWithAnimatedGIFData(data, screenScale, 0.0f, nil);
}

__attribute__((overloadable)) UIImage * UIImageWithAnimatedGIFData(NSData *data, CGFloat scale, NSTimeInterval duration, NSError * __autoreleasing *error) {
    if (!data) {
        return nil;
    }

    {
        NSMutableDictionary *mutableOptions = [NSMutableDictionary dictionary];
        [mutableOptions setObject:@(YES) forKey:(NSString *)kCGImageSourceShouldCache];
        [mutableOptions setObject:(NSString *)kUTTypeGIF forKey:(NSString *)kCGImageSourceTypeIdentifierHint];

        CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, (__bridge CFDictionaryRef)mutableOptions);

        size_t numberOfFrames = CGImageSourceGetCount(imageSource);
        NSMutableArray *mutableImages = [NSMutableArray arrayWithCapacity:numberOfFrames];

        NSTimeInterval calculatedDuration = 0.0f;
        for (size_t idx = 0; idx < numberOfFrames; idx++) {
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSource, idx, (__bridge CFDictionaryRef)mutableOptions);

            NSDictionary *properties = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imageSource, idx, NULL);
            calculatedDuration += [[[properties objectForKey:(__bridge NSString *)kCGImagePropertyGIFDictionary] objectForKey:(__bridge  NSString *)kCGImagePropertyGIFDelayTime] doubleValue];

            [mutableImages addObject:[UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp]];

            CGImageRelease(imageRef);
        }

        CFRelease(imageSource);

        if (numberOfFrames == 1) {
            return [mutableImages firstObject];
        } else {
            return [UIImage animatedImageWithImages:mutableImages duration:(duration <= 0.0f ? calculatedDuration : duration)];
        }
    }
}

__attribute__((overloadable)) NSData * UIImageAnimatedGIFRepresentation(UIImage *image) {
    return UIImageAnimatedGIFRepresentation(image, 0.0f, 0, nil);
}

__attribute__((overloadable)) NSData * UIImageAnimatedGIFRepresentation(UIImage *image, NSTimeInterval duration, NSUInteger loopCount, NSError * __autoreleasing *error) {
    return UIImagesAnimatedGIFRepresentation(image.images, duration ?: image.duration, loopCount, error);
}

__attribute__((overloadable)) NSData * _UIImagesAnimatedGIFRepresentation(NSArray *images, NSTimeInterval duration, NSUInteger loopCount, NSError * __autoreleasing *error) {
    if (!images) {
        return nil;
    }

    NSDictionary *userInfo = nil;

    if(duration<=0){
        userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Duration must be higher than 0.", nil) };
        goto _error;
    }

    {
        size_t frameCount = images.count;
        NSTimeInterval frameDuration = duration / frameCount;
        NSDictionary *frameProperties = @{
                (__bridge NSString *)kCGImagePropertyGIFDictionary: @{
                        (__bridge NSString *)kCGImagePropertyGIFDelayTime: @(frameDuration)
                }
        };

        NSMutableData *mutableData = [NSMutableData data];
        CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)mutableData, kUTTypeGIF, frameCount, NULL);

        NSDictionary *imageProperties = @{ (__bridge NSString *)kCGImagePropertyGIFDictionary: @{
                (__bridge NSString *)kCGImagePropertyGIFLoopCount: @(loopCount)
        }
        };
        CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)imageProperties);

        for (size_t idx = 0; idx < images.count; idx++) {
            @autoreleasepool {
                id imageObj = images[idx];

                UIImage * image = nil;
                if([imageObj isKindOfClass:NSString.class]){
                    image = [UIImage imageWithContentsOfFile:imageObj];

                } else if([imageObj isKindOfClass:UIImage.class]){
                    image = imageObj;

                }else{
                    userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(([@"Not supported object type." stringByAppendingFormat:@"%@", NSStringFromClass([imageObj class])]), nil) };
                    goto _error;
                }

                CGImageDestinationAddImage(destination, [image CGImage], (__bridge CFDictionaryRef)frameProperties);
            }
        }

        BOOL success = CGImageDestinationFinalize(destination);
        CFRelease(destination);

        if (!success) {
            userInfo = @{
                    NSLocalizedDescriptionKey: NSLocalizedString(@"Could not finalize image destination", nil)
            };

            goto _error;
        }

        return [NSData dataWithData:mutableData];
    }
    _error: {
        if (error) {
            *error = [[NSError alloc] initWithDomain:AnimatedGIFImageErrorDomain code:-1 userInfo:userInfo];
        }

        return nil;
    }
}

__attribute__((overloadable)) NSData * UIImageFilesAnimatedGIFRepresentation(NSArray<NSString *> *filePaths, NSTimeInterval duration, NSUInteger loopCount, NSError * __autoreleasing *error) {
    return _UIImagesAnimatedGIFRepresentation(filePaths, duration, loopCount, error);
}

__attribute__((overloadable)) NSData * UIImagesAnimatedGIFRepresentation(NSArray<UIImage *> *images, NSTimeInterval duration, NSUInteger loopCount, NSError * __autoreleasing *error) {
    return _UIImagesAnimatedGIFRepresentation(images, duration, loopCount, error);
}

@implementation NSData (STGIFUtil)

- (BOOL)isGIF{
    if (self.length > 4) {
        const unsigned char * bytes = [self bytes];
        return bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46;
    }
    return NO;
}

@end