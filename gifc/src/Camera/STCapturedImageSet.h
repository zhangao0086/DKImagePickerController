//
// Created by BLACKGENE on 4/29/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"
#import "STCapturedResource.h"

@class STCapturedImage;

typedef NS_ENUM(NSInteger, STCapturedImageSetType) {
    STCapturedImageSetTypeUnspecified,
    STCapturedImageSetTypeAnimatable,
    STCapturedImageSetTypePostFocus
};

@interface STCapturedImageSet : STCapturedResource

@property(nonatomic, readonly) NSUInteger indexOfDefaultImage;
@property(nonatomic, readonly) NSUInteger indexOfFocusPointsOfInterestSet;
@property(nonatomic, readonly) NSArray * focusPointsOfInterestSet;
@property(nonatomic, readonly) CGSize outputSizeForFocusPoints;

@property(nonatomic, readonly) NSMutableArray <STCapturedImage *> * images;
@property(nonatomic, readonly) NSUInteger count;
@property(nonatomic, readonly) STCapturedImageSetType type;

- (instancetype)initWithImages:(NSArray <STCapturedImage *>*)images;

+ (instancetype)setWithImages:(NSArray <STCapturedImage *>*)images;

+ (instancetype)setWithImages:(NSArray<STCapturedImage *> *)images transferByOtherSet:(STCapturedImageSet *)otherSet;

+ (instancetype)setWithCompactedImagesFrom:(STCapturedImageSet *)otherSet;

- (STCapturedImage *)defaultImage;

- (BOOL)reindexingDefaultImage;

- (NSArray<STCapturedImage *> *)sortedImagesByCreatedTime:(BOOL)recentImageFirst;

+ (NSArray<STCapturedImage *> *)sortedImagesByCreatedTime:(NSArray<STCapturedImage *> *)images recentImageFirst:(BOOL)recentImagesAreFirst;

- (NSArray<STCapturedImage *>*)sortedImagesByLensPosition:(BOOL)oneToZero;

- (instancetype)sortImagesByLensPostion:(BOOL)oneToZero;

- (NSArray<STCapturedImage *> *)sortedImagesByFocusAdjusted:(BOOL)toLast;

+ (NSArray<STCapturedImage *> *)sortedImagesByFocusAdjusted:(NSArray<STCapturedImage *> *)images toLast:(BOOL)toLast;

+ (NSArray<STCapturedImage *> *)sortedImagesByLensPosition:(NSArray<STCapturedImage *> *)images oneToZero:(BOOL)oneToZero;

- (NSArray<STCapturedImage *>*)compactedImagesByLensPosition;

- (NSArray<STCapturedImage *> *)compactedImagesByLensPosition:(BOOL)sortRecentImagePriority;

- (NSArray<STCapturedImage *> *)compactedImagesByLensPosition:(BOOL)sortRecentImagePriority minimizeByFlooredInteger:(BOOL)minimizeByFlooredInteger;

- (STCapturedImage *)imageForAlmostSameLensPosition:(float)lensPosition;

- (STCapturedImage *)imageForAlmostSameLensPosition:(float)lensPosition equalFocusPointTo:(STCapturedImage *)imageToDiffFocusPoint;

- (NSUInteger)indexOfNearestLensPosition:(float)lensPosition;

- (NSUInteger)indexOfNearestLensPosition:(float)lensPosition equalFocusPointTo:(STCapturedImage *)imageToDiffFocusPoint;

- (STCapturedImage *)imageForNearestLensPosition:(float)lensPosition;

- (STCapturedImage *)imageForNearestLensPosition:(float)lensPosition equalFocusPointTo:(STCapturedImage *)imageToDiffFocusPoint;

- (NSArray<STCapturedImage *>*)imagesForSameLensPosition:(float)lensPosition;

- (NSUInteger)indexOfImageForNearestFocusPointOfInterest:(CGPoint)pointOfInterestInOutputSize;

- (STCapturedImage *)imageForNearestFocusPointOfInterest:(CGPoint)pointOfInterestInOutputSize;

- (STCapturedImage *)imageForNearestFocusPointOfInterest:(CGPoint)pointOfInterestInOutputSize normalizedDistanceOfArea:(CGFloat)distanceOfArea;

- (NSArray<STCapturedImage *>*)imagesForSameFocusPointOfInterest:(CGPoint)pointOfInterestInOutputSize;

- (STCapturedImage *)firstImageForSameFocusPointOfInterest:(CGPoint)pointOfInterestInOutputSize;

- (NSArray<STCapturedImage *>*)imagesForIndexOfFocusPointsOfInterestSet;

- (void)setIndexOfFocusPointsInterestSetFromImage:(STCapturedImage *)image;

@end