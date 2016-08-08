//
// Created by BLACKGENE on 8/8/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCapturedImage.h"

@interface STCapturedImage (Extension)
@property (nonatomic, readonly) NSURL * tempImageUrl;

- (BOOL)createTempImage:(CGSize)sizeToResize caching:(BOOL)caching;
@end