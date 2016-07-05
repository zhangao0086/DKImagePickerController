//
// Created by BLACKGENE on 2016. 3. 4..
// Copyright (c) 2016 stells. All rights reserved.
//

#import "DFImageTask.h"
#import "DFAnimatedImageView+Loader.h"
#import "DFAnimatedImageDecoder.h"
#import "NSString+STUtil.h"
#import "UIImage+STUtil.h"
#import "DFImageManagerKit+UI.h"
#import "UIView+STUtil.h"


@implementation DFAnimatedImageView (Loader)

- (void)displayImageFromBundleName:(NSString *)imageName{
    if(imageName){
        UIImage * image = [[DFAnimatedImageDecoder alloc] imageWithData:[NSData dataWithContentsOfFile:[imageName bundleFilePath]] partial:NO];
        if(!image){
            image = [UIImage imageBundled:imageName];
        }
        [self displayImage:image];
    }
}

- (void)displayImageFromURL:(NSURL *)url{
    [self setImageWithRequest:[DFImageRequest requestWithResource:url]];
}

- (void)cleanImage:(BOOL)dispose{
    [self.imageTask cancel];
    [self displayImage:nil];

    if(!dispose){
        [self prepareForReuse];
    }

    if(dispose){
        [self.imageManager stopPreheatingImagesForAllRequests];
        [self.imageManager removeAllCachedImages];
        [self clearAllOwnedImagesIfNeededAndRemoveFromSuperview:NO];
    }
}
@end