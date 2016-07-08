//
// Created by BLACKGENE on 7/8/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCapturedResource.h"

@class STCapturedImageSet;

@interface STCapturedImageSetGroup : STCapturedResource
@property(nonatomic, assign) NSUInteger indexOfDefaultImageSet;
@property(nonatomic, readonly) STCapturedImageSet * defaultImageSet;

@property(nonatomic, readonly) NSMutableArray <STCapturedImageSet *> * imageSets;

- (instancetype)initWithImageSets:(NSMutableArray *)imageSets;

+ (instancetype)groupWithImageSets:(NSMutableArray *)imageSets;

@end