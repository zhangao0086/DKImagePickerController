//
// Created by BLACKGENE on 2014. 10. 27..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAsset+STALAsset.h"


@implementation ALAsset (STALAsset)

// For details, see http://mindsea.com/2012/12/18/downscaling-huge-alassets-without-fear-of-sigkill

- (UIImage *)imageByMaxSizedScreenScale:(NSUInteger)size {

    return [self imageBySized:size*(NSUInteger)[UIScreen mainScreen].scale];
}

- (NSData *)fullResolutionData {
    @autoreleasepool {
        long long sizeOfRawDataInBytes = [[self defaultRepresentation] size];

        NSMutableData* rawData = [NSMutableData dataWithLength:(NSUInteger) sizeOfRawDataInBytes];
        void* bufferPointer = [rawData mutableBytes];

        NSError* error=nil;
        [[self defaultRepresentation] getBytes:bufferPointer fromOffset:0 length:(NSUInteger) sizeOfRawDataInBytes error:&error];

        if (error){
            NSLog(@"Getting bytes failed with error at fullResolutionData: %@",error);

            return nil;
        }else{
            return rawData;
        }
    }
}

- (UIImage *)fullResolutionImage{

    return [UIImage imageWithData:[self fullResolutionData]];
}

- (UIImage *)imageBySized:(CGFloat)size {

    UIImage *result = nil;
    NSData *data = [self fullResolutionData];

    if ([data length])
    {
//        CGImageSourceCreateWithURL
        CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        [options setObject:(id)kCFBooleanTrue forKey:(id)kCGImageSourceShouldAllowFloat];
        [options setObject:(id)kCFBooleanTrue forKey:(id)kCGImageSourceCreateThumbnailFromImageAlways];
        [options setObject:(id)[NSNumber numberWithFloat:size] forKey:(id)kCGImageSourceThumbnailMaxPixelSize];

        CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(sourceRef, 0, (__bridge CFDictionaryRef)options);
        if (imageRef) {
            result = [UIImage imageWithCGImage:imageRef scale:[self.defaultRepresentation scale] orientation:(UIImageOrientation)[self.defaultRepresentation orientation]];
            CGImageRelease(imageRef);
        }

        if (sourceRef)
            CFRelease(sourceRef);
    }
    return result;
}

@end