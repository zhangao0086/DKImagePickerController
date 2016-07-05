//
//  BCMutableMeshTransform+BasicTransforms.h
//  BCMeshTransformView
//
//  Copyright (c) 2014 Bartosz Ciechanowski. All rights reserved.
//

#import "BCMeshTransform.h"

@interface BCMeshTransform (BasicTransforms)

+ (instancetype)curtainMeshTransformAtPoint:(CGPoint)point
                                 boundsSize:(CGSize)boundsSize;

+ (instancetype)buldgeMeshTransformAtPoint:(CGPoint)point
                                withRadius:(CGFloat)radius
                                boundsSize:(CGSize)size;

+ (instancetype)shiverTransformWithPhase:(CGFloat)phase magnitude:(CGFloat)magnitude;

+ (instancetype)ellipseMeshTransform;

+ (instancetype)rippleMeshTransform;

@end
