//
// Created by BLACKGENE on 2014. 10. 27..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAsset (STALAsset)

- (UIImage *)imageByMaxSized:(NSUInteger)size;

- (UIImage *)imageByMaxSizedScreenScale:(NSUInteger)size;

- (NSData *)fullResolutionData;

- (UIImage *)fullResolutionImage;

- (UIImage *)imageBySized:(CGFloat)size;
@end