//
// Created by BLACKGENE on 6/20/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface PHImageRequestOptions (STUtil)
+ (PHImageRequestOptions *)synchronousOptions;

+ (PHImageRequestOptions *)fullResolutionOptions:(BOOL)synchronous;

+ (PHImageRequestOptions *)fullScreenOptions:(BOOL)synchronous;
@end