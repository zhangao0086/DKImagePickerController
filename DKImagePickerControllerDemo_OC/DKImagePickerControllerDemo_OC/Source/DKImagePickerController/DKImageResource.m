//
//  DKImageResource.m
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/6/26.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKImageResource.h"

@implementation NSBundle (DKExtension)

+ (NSBundle *)imagePickerControllerBundle{
    NSString * path = [NSBundle bundleForClass:[DKImageResource class]].resourcePath;
    return [NSBundle bundleWithPath:[path stringByAppendingPathComponent:@"DKImagePickerController.bundle"]];
}

@end

@implementation DKImageResource
+ (UIImage *)imageForResource:(NSString *)name{
    NSBundle * bundle = [NSBundle imagePickerControllerBundle];
    NSString * path = [bundle pathForResource:name ofType:@"png" inDirectory:@"Images"];
    UIImage * image = [UIImage imageWithContentsOfFile:path];
    return  image;
}

+ (UIImage *)stretchImgFromMiddle:(UIImage *)image{
    CGFloat centerX = image.size.width / 2;
    CGFloat centerY = image.size.height / 2;
    UIImage * newImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(centerY, centerX, centerY, centerX)];
    return newImage;
}

+ (UIImage *)checkedImage{
    return [self stretchImgFromMiddle:[self imageForResource:@"checked_background"]];
}

+ (UIImage *)blueTickImage{
    return  [self imageForResource:@"tick_blue"];
}

+ (UIImage *)cameraImage{
    return [self imageForResource:@"camera"];
}

+ (UIImage *)videoCameraIcon{
    return [self imageForResource:@"video_camera"];
}

+ (UIImage *)emptyAlbumIcon{
    return [self stretchImgFromMiddle:[self imageForResource:@"empty_album"]];
}

@end

@implementation DKImageLocalizedString

+ (NSString *)localizedStringForKey:(NSString *)key{
    NSString * s = NSLocalizedStringWithDefaultValue(key, @"DKImagePickerController", [NSBundle imagePickerControllerBundle], @"", @"");
    return s;
}

@end
