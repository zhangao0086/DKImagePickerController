//
// Created by BLACKGENE on 2016. 4. 7..
// Copyright (c) 2016 stells. All rights reserved.
//

// imported from : https://github.com/pilot34/AnimatedGIFImageSerialization

#import <Foundation/Foundation.h>

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)

extern NSString * const AnimatedGIFImageErrorDomain;

#import <UIKit/UIKit.h>

/**

 */
extern __attribute__((overloadable)) UIImage * UIImageWithAnimatedGIFData(NSData *data);

/**

 */
extern __attribute__((overloadable)) UIImage * UIImageWithAnimatedGIFData(NSData *data, CGFloat scale, NSTimeInterval duration, NSError * __autoreleasing *error);

#pragma mark -

/**

 */
extern __attribute__((overloadable)) NSData * UIImageAnimatedGIFRepresentation(UIImage *image);

/**

 */
extern __attribute__((overloadable)) NSData * UIImageAnimatedGIFRepresentation(UIImage *image, NSTimeInterval duration, NSUInteger loopCount, NSError * __autoreleasing *error);

/**

 */
extern __attribute__((overloadable)) NSData * UIImagesAnimatedGIFRepresentation(NSArray<UIImage *> *, NSTimeInterval duration, NSUInteger loopCount, NSError * __autoreleasing *error);

extern __attribute__((overloadable)) NSData * UIImageFilesAnimatedGIFRepresentation(NSArray<NSString *> *, NSTimeInterval duration, NSUInteger loopCount, NSError * __autoreleasing *error);

#pragma mark -
#endif

@interface NSData (STGIFUtil)
- (BOOL)isGIF;
@end