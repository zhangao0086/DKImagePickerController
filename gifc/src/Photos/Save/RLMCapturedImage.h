//
// Created by BLACKGENE on 4/29/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLMObject.h"
#import "RLMArray.h"
#import "STRLMFileWritable.h"

/*
 *  BOOL, bool, int, NSInteger, long, long long, float, double, NSString, NSData.
 *
 *  NSDate truncated to the second : https://realm.io/docs/objc/latest/#nsdate-is-truncated-to-the-second
 *  NSNumber tagged with a specific type : https://realm.io/docs/objc/latest/#optional-properties
 */

@class RLMCapturedImageSet;
@class STCapturedImage;
@class STCapturedImageSet;

#pragma mark RLMCGPoint
@interface RLMCGPoint : RLMObject
@property NSString *CGPointString;

- (instancetype)initWithCGPoint:(CGPoint)point;

+ (instancetype)pointWithCGPoint:(CGPoint)point;

@end
RLM_ARRAY_TYPE(RLMCGPoint)

#pragma mark RLMCapturedResource

@interface RLMCapturedResource : RLMObject
@property NSString * uuid;
@property NSTimeInterval createdTime;
@property NSTimeInterval savedTime;
@end
RLM_ARRAY_TYPE(RLMCapturedResource)

#pragma mark CapturedImage
@interface RLMCapturedImage : RLMCapturedResource <STRLMFileWritable>

@property RLMCapturedImageSet * parentSet;

@property NSString * imagePathForDocument;
@property NSString * thumbnailPathForDocument;
@property NSString * fullScreenPathForDocument;
@property NSString * pixelSize;

@property NSString * focusPointOfInterestInOutputSize;
@property float lensPosition;
@property BOOL focusAdjusted;

@property NSInteger capturedImageOrientation;
@property NSInteger capturedInterfaceOrientation;
@property NSInteger capturedDeviceOrientation;

- (instancetype)initWithCapturedImage:(STCapturedImage *)capturedImage parentSet:(RLMCapturedImageSet *)imageSet;

- (STCapturedImage *)fetchImage;

+ (instancetype)imageWithCapturedImage:(STCapturedImage *)capturedImage parentSet:(RLMCapturedImageSet *)imageSet;

@end
RLM_ARRAY_TYPE(RLMCapturedImage)

#pragma mark CapturedImageset
@interface RLMCapturedImageSet : RLMCapturedResource <STRLMFileWritable>

@property RLMArray<RLMCapturedImage *><RLMCapturedImage> *images;

@property NSString * imageSetPathForDocument;

@property NSInteger count;
@property NSInteger type;

@property NSInteger indexOfDefaultImage;
@property NSInteger indexOfFocusPointsOfInterestSet;
@property RLMArray<RLMCGPoint *><RLMCGPoint> * focusPointsOfInterestSet;
@property NSString * outputSizeForFocusPoints;

- (instancetype)initWithCapturedImageSet:(STCapturedImageSet *)capturedImageSet;

- (STCapturedImageSet *)fetchImageSet;

+ (instancetype)setWithCapturedImageSet:(STCapturedImageSet *)capturedImageSet;

@end
RLM_ARRAY_TYPE(RLMCapturedImageSet)