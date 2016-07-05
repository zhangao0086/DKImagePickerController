//
// Created by BLACKGENE on 2015. 2. 27..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STEditorCommand.h"


@interface STTransformEditorCommand : STEditorCommand

@property (nonatomic, readwrite) CGFloat rotation;
@property (nonatomic, readwrite) BOOL rotationLeft;
@property (nonatomic, readwrite) CGFloat aspectRatio;
@property (nonatomic, readwrite) BOOL aspectRatioAsSquare;
@property (nonatomic, readwrite) BOOL aspectRatioAsDefault;
@property (nonatomic, readwrite) BOOL shouldReset;

- (instancetype)rotateLeft;

- (instancetype)square;

- (instancetype)defaultAspectRatio;

- (instancetype)reset;
@end