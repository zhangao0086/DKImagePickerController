//
// Created by BLACKGENE on 2015. 1. 27..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STTransformEditorResult;

@interface STEditorResult : NSObject
@property (nonatomic, readwrite) BOOL modified;
- (UIImage *)modifiyImage:(UIImage *)inputImage;
@end