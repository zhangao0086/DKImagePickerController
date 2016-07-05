//
// Created by BLACKGENE on 2015. 2. 27..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "STEditorResult.h"


@interface STTransformEditorResult : STEditorResult

@property (nonatomic, readonly) CGRect rect;
@property (nonatomic, readonly) UIImageOrientation orientation;
@property (nonatomic, readonly) CGSize imageSize;
@property (nonatomic, readonly) CGPoint translateOffset;
@property (nonatomic, readonly) CGFloat rotationAngle;

- (instancetype)initWithRect:(CGRect)rect orientation:(UIImageOrientation)orientation imageSize:(CGSize)imageSize translateOffset:(CGPoint)translateOffset rotationAngle:(CGFloat)rotationAngle;

@end