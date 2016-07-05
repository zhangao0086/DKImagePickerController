//
// Created by BLACKGENE on 2016. 3. 4..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFAnimatedImageView.h"

@interface DFAnimatedImageView (Loader)
- (void)displayImageFromBundleName:(NSString *)imageName;

- (void)displayImageFromURL:(NSURL *)url;

- (void)cleanImage:(BOOL)dispose;
@end