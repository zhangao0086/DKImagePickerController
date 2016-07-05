//
// Created by BLACKGENE on 4/29/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImageSet.h"
#import "STCapturedImageSetProtected.h"
#import "STCapturedImage.h"
#import "NSArray+STUtil.h"
#import "BlocksKit.h"
#import "STCapturedImageSet+PostFocus.h"

@implementation STCapturedImageSet {
    NSMutableArray<STCapturedImage *> * _images;
    NSUInteger _originalIndexOfDefaultImage;
}

- (void)dealloc {
    _images = nil;
}

- (instancetype)initWithImages:(NSArray<STCapturedImage *> *)images {
    self = [super init];
    if (self) {
        _images = [NSMutableArray<STCapturedImage *> arrayWithArray:images];
#if DEBUG
        for(STCapturedImage * image in _images){
            NSAssert(image.hasSource,@"images of imageSet must have source at least one");
        }
#endif
    }
    return self;
}

- (NSMutableArray<STCapturedImage *> *)images {
    @synchronized (self) {
        return _images ?: (_images = [NSMutableArray<STCapturedImage *> array]);
    }
}

+ (instancetype)setWithImages:(NSArray<STCapturedImage *> *)images {
    return [[self alloc] initWithImages:images];
}

+ (instancetype)setWithImages:(NSArray<STCapturedImage *> *)images transferByOtherSet:(STCapturedImageSet *)otherSet {
    NSParameterAssert(otherSet);
    NSParameterAssert(otherSet.count);

    switch([otherSet postFocusMode]){
        case STPostFocusMode5Points:
        case STPostFocusModeVertical3Points:
            NSParameterAssert(!CGSizeEqualToSize(CGSizeZero,otherSet.outputSizeForFocusPoints));
            break;
        default:
            break;
    }

    STCapturedImageSet * newImageSet = [self setWithImages:images];
    newImageSet.indexOfFocusPointsOfInterestSet = otherSet.indexOfFocusPointsOfInterestSet;
    newImageSet.focusPointsOfInterestSet = [otherSet.focusPointsOfInterestSet copy];
    newImageSet.outputSizeForFocusPoints = otherSet.outputSizeForFocusPoints;
    newImageSet.type = otherSet.type;

    oo(@"--- compacted images ---")
    for(STCapturedImage * itemOfImages in images) {
        NSLog(@"f %d - %f,%f - l %f",itemOfImages.focusAdjusted, itemOfImages.focusPointOfInterestInOutputSize.x,itemOfImages.focusPointOfInterestInOutputSize.y,itemOfImages.lensPosition);
    }

    oo(@"--- transfered from ---")
    for(STCapturedImage * itemOfImages in otherSet.images) {
        NSLog(@"f %d - %f,%f - l %f",itemOfImages.focusAdjusted, itemOfImages.focusPointOfInterestInOutputSize.x,itemOfImages.focusPointOfInterestInOutputSize.y,itemOfImages.lensPosition);
    }
    [newImageSet reindexingDefaultImage];

    return newImageSet;
}

+ (instancetype)setWithCompactedImagesFrom:(STCapturedImageSet *)otherSet {
    return [self setWithImages:[otherSet compactedImagesByLensPosition] transferByOtherSet:otherSet];
}

- (NSUInteger)count {
    return _images.count;
}

- (NSArray<NSURL *>*)urlsOfImages {
    STCapturedImage * firstImage = [self.images firstObject];
    if(firstImage.imageUrl){
        return [self.images mapWithItemsKeyPath:@keypath(firstImage.imageUrl)];
    }
    return nil;
}

- (NSArray<NSData *>*)datasOfImages {
    STCapturedImage * firstImage = [self.images firstObject];
    if(firstImage.imageData){
        return [self.images mapWithItemsKeyPath:@keypath(firstImage.imageData)];
    }
    return nil;
}

- (NSArray<UIImage *>*)imagesOfImages {
    STCapturedImage * firstImage = [self.images firstObject];
    if(firstImage.image){
        return [self.images mapWithItemsKeyPath:@keypath(firstImage.image)];
    }
    return nil;
}

#pragma Indexed Image
- (STCapturedImage *)defaultImage {
    return self.images.count ? [self.images st_objectOrNilAtIndex:self.indexOfDefaultImage] : nil;
}

- (void)setIndexOfDefaultImage:(NSUInteger)indexOfDefaultImage {
    if(!_indexOfDefaultImage){
        _originalIndexOfDefaultImage = indexOfDefaultImage;
    }
    _indexOfDefaultImage = indexOfDefaultImage;
}

- (BOOL)reindexingDefaultImage{
    switch(self.postFocusMode){
        case STPostFocusModeVertical3Points:
        case STPostFocusMode5Points:{
            id defaultFocusPointOfInterest = [self.focusPointsOfInterestSet st_objectOrNilAtIndex:self.indexOfFocusPointsOfInterestSet];
            if(defaultFocusPointOfInterest){
                self.indexOfDefaultImage = [self indexOfImageForNearestFocusPointOfInterest:[defaultFocusPointOfInterest CGPointValue]];
                return YES;
            }
        }
        case STPostFocusModeFullRange:
            if([self.images st_objectOrNilAtIndex:_originalIndexOfDefaultImage]){
                _indexOfDefaultImage = _originalIndexOfDefaultImage;
                return YES;
            }else{
                NSArray<STCapturedImage *>* sortedImages = [self sortedImagesByLensPosition:NO];
                if(sortedImages.count){
                    NSUInteger halfIndex = (NSUInteger)(sortedImages.count/2);
                    _indexOfDefaultImage = halfIndex ? [[self images] indexOfObject:sortedImages[halfIndex]] : 0;
                    return YES;
                }
            }
            return NO;

        default:
            return NO;
    }
}

#pragma mark Sort

// sort by created time
- (NSArray<STCapturedImage *>*)sortedImagesByCreatedTime:(BOOL)recentImageFirst {
    return [self.class sortedImagesByCreatedTime:self.images recentImageFirst:recentImageFirst];
}

+ (NSArray<STCapturedImage *>*)sortedImagesByCreatedTime:(NSArray<STCapturedImage *> *)images recentImageFirst:(BOOL)recentImagesAreFirst{
    NSArray<STCapturedImage *> * sorted = [images sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(STCapturedImage * image1, STCapturedImage * image2) {
        return image1.createdTime > image2.createdTime ? NSOrderedDescending : NSOrderedAscending;
    }];
    return recentImagesAreFirst ? [sorted reverse] : sorted;
}

// sort by lens position
- (NSArray<STCapturedImage *>*)sortedImagesByLensPosition:(BOOL)oneToZero{
    return [self.class sortedImagesByLensPosition:self.images oneToZero:oneToZero];
}

+ (NSArray<STCapturedImage *>*)sortedImagesByLensPosition:(NSArray<STCapturedImage *>*)images oneToZero:(BOOL)oneToZero{
    NSArray<STCapturedImage *> * sorted = [images sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(STCapturedImage * image1, STCapturedImage * image2) {
        return image1.lensPosition > image2.lensPosition ? NSOrderedDescending : NSOrderedAscending;
    }];
    return oneToZero ? [sorted reverse] : sorted;
}

- (instancetype)sortImagesByLensPostion:(BOOL)oneToZero{
    _images = [[self sortedImagesByLensPosition:oneToZero] mutableCopy];
    [self reindexingDefaultImage];
    return self;
}

// sort by lens position
- (NSArray<STCapturedImage *>*)sortedImagesByFocusAdjusted:(BOOL)toLast{
    return [self.class sortedImagesByFocusAdjusted:self.images toLast:toLast];
}

+ (NSArray<STCapturedImage *>*)sortedImagesByFocusAdjusted:(NSArray<STCapturedImage *>*)images toLast:(BOOL)toLast{
    NSArray<STCapturedImage *> * sorted = [images sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(STCapturedImage * image1, STCapturedImage * image2) {
        return image1.focusAdjusted < image2.focusAdjusted ? NSOrderedDescending : NSOrderedSame;
    }];
    return toLast ? [sorted reverse] : sorted;
}

#pragma mark Compact

- (NSArray<STCapturedImage *>*)compactedImagesByLensPosition{
    return [self compactedImagesByLensPosition:NO];
}

- (NSArray<STCapturedImage *>*)compactedImagesByLensPosition:(BOOL)sortRecentImagePriority {
    return [self compactedImagesByLensPosition:sortRecentImagePriority minimizeByFlooredInteger:NO];
}

- (NSArray<STCapturedImage *>*)compactedImagesByLensPosition:(BOOL)sortRecentImagePriority minimizeByFlooredInteger:(BOOL)minimizeByFlooredInteger {
    NSMutableArray<STCapturedImage *> * imagesToRemoveDuplicatedLensPosition = [NSMutableArray<STCapturedImage *> arrayWithArray: sortRecentImagePriority ? [self sortedImagesByCreatedTime:YES] : self.images];
    NSMutableSet * existedLensPositions = [NSMutableSet set];
    // priority : focusAdjusted > lensPostion > createdTime
    NSArray<STCapturedImage *> * sortedImagesToCompareLensPosition = [self sortedImagesByFocusAdjusted:NO];
    for(STCapturedImage * image in sortedImagesToCompareLensPosition){
        NSString * lensPosKey = [@(image.lensPosition) stringValue];

        if([existedLensPositions containsObject:lensPosKey]
                && !image.focusAdjusted){
            [imagesToRemoveDuplicatedLensPosition removeObject:image];
        }else{
            [existedLensPositions addObject:lensPosKey];
        }
    }
    //sort by lens position 1(far) -> 0(near)
    NSArray<STCapturedImage *> * sortedImagesByLensPosition = [self.class sortedImagesByLensPosition:imagesToRemoveDuplicatedLensPosition oneToZero:YES];

    if(minimizeByFlooredInteger){
        __block float flooredLensPosition = -1;
        return [sortedImagesByLensPosition bk_select:^BOOL(STCapturedImage * obj) {
            CGFloat floored = floor(obj.lensPosition*10);
            BOOL exist = flooredLensPosition == floored;
            if(!exist){
                flooredLensPosition = floored;
            }
            return !exist;
        }];
    }

    return sortedImagesByLensPosition;
}

#pragma mark Image by LensPosition
- (NSUInteger)indexOfNearestLensPosition:(float)lensPosition{
    return [self indexOfNearestLensPosition:lensPosition equalFocusPointTo:nil];
}

- (NSUInteger)indexOfNearestLensPosition:(float)lensPosition equalFocusPointTo:(STCapturedImage *)imageToDiffFocusPoint{
    return [self.images indexOfObject:[self imageForNearestLensPosition:lensPosition equalFocusPointTo:imageToDiffFocusPoint]];\
}

- (STCapturedImage *)imageForNearestLensPosition:(float)lensPosition{
    return [self imageForNearestLensPosition:lensPosition equalFocusPointTo:nil];
}

- (STCapturedImage *)imageForNearestLensPosition:(float)lensPosition equalFocusPointTo:(STCapturedImage *)imageToDiffFocusPoint{
    return [self imageForLensPosition:lensPosition equalFocusPointTo:imageToDiffFocusPoint maxDistance:1];
}

- (STCapturedImage *)imageForAlmostSameLensPosition:(float)lensPosition{
    return [self imageForAlmostSameLensPosition:lensPosition equalFocusPointTo:nil];
}

- (STCapturedImage *)imageForAlmostSameLensPosition:(float)lensPosition equalFocusPointTo:(STCapturedImage *)imageToDiffFocusPoint{
    return [self imageForLensPosition:lensPosition equalFocusPointTo:imageToDiffFocusPoint maxDistance:0.05f];
}

- (STCapturedImage *)imageForLensPosition:(float)lensPosition equalFocusPointTo:(STCapturedImage *)imageToDiffFocusPoint maxDistance:(CGFloat)dist{
    NSAssert(dist>0 && dist<=1,@"max distance must be 0 > distance && distance <= 1");

    CGFloat minDistanceLensPosition = 1;
    STCapturedImage * imageForMinDistanceLensPosition = nil;

    for(STCapturedImage * itemOfImages in self.images){
        if(imageToDiffFocusPoint && !CGPointEqualToPointByNearest2Decimal(itemOfImages.focusPointOfInterestInOutputSize, imageToDiffFocusPoint.focusPointOfInterestInOutputSize)){
            //filtering only same focusPointed images
            continue;
        }

        //if found matched lensPostion
        if(itemOfImages.lensPosition==lensPosition){
            return itemOfImages;
        }

        //if found min distance lensPosition
        CGFloat distanceLensPosition = fabs(itemOfImages.lensPosition-lensPosition);
        if(dist > distanceLensPosition && distanceLensPosition < minDistanceLensPosition){
            minDistanceLensPosition = distanceLensPosition;
            imageForMinDistanceLensPosition = itemOfImages;
        }
    }

    return imageForMinDistanceLensPosition;
}

- (NSArray<STCapturedImage *>*)imagesForSameLensPosition:(float)lensPosition{
    NSMutableArray<STCapturedImage *> * images = [NSMutableArray<STCapturedImage *> array];
    for(STCapturedImage * itemOfImages in self.images){
        if(itemOfImages.lensPosition==lensPosition){
            [images addObject:itemOfImages];
        }
    }
    if(images.count>1){
        oo(@"[!] WARNING : 2 or higher same lensPosition found");
    }
    return images.count ? images : nil;
}

#pragma mark Image by FocusPoint
- (NSUInteger)indexOfImageForNearestFocusPointOfInterest:(CGPoint)pointOfInterestInOutputSize{
    return [self.images indexOfObject:[self imageForNearestFocusPointOfInterest:pointOfInterestInOutputSize]];
}

- (STCapturedImage *)imageForNearestFocusPointOfInterest:(CGPoint)pointOfInterestInOutputSize{
    switch(self.postFocusMode){
        case STPostFocusModeVertical3Points:
            return [self imageForNearestFocusPointOfInterest:pointOfInterestInOutputSize normalizedDistanceOfArea:.2];
        default:
            return [self imageForNearestFocusPointOfInterest:pointOfInterestInOutputSize normalizedDistanceOfArea:.25];
    }
}

- (STCapturedImage *)imageForNearestFocusPointOfInterest:(CGPoint)pointOfInterestInOutputSize normalizedDistanceOfArea:(CGFloat)distanceOfArea {
    NSParameterAssert(distanceOfArea>0 && distanceOfArea<1);
    CGPoint testTargetPointOfInterest = CGPointHalf;

    /*
     * first, find nearest point in Center (diameter < distanceOfArea)
     */
    BOOL findInCenterPoint = [self.focusPointsOfInterestSet bk_match:^BOOL(id obj) {
        return CGPointEqualToPointByNearest2Decimal(CGPointHalf,[obj CGPointValue]);
    }] && CGPointLengthBetween(CGPointHalf, pointOfInterestInOutputSize) < distanceOfArea;

    if(findInCenterPoint){
        STCapturedImage * foundImageInCenter = [self imageForSameFocusPointOfInterestAndFocusAdjusted:testTargetPointOfInterest];
        NSAssert(foundImageInCenter, @"not found adjusted point in center area");
        return foundImageInCenter;
    }

    // else, find minimum distance for axis
    NSArray const * FocusPointsOfInterestSetExcludingCenter = [self.focusPointsOfInterestSet bk_reject:^BOOL(id obj) {
        return CGPointEqualToPointByNearest2Decimal(CGPointHalf,[obj CGPointValue]);
    }];

    BOOL currentAxisDistanceOfPointIsOutsideFromCenter = NO;
    UIInterfaceOrientation const orientation = [self defaultImage].capturedInterfaceOrientation;
    BOOL const FindInAxisVertical = UIInterfaceOrientationIsPortrait(orientation);

    if(orientation != UIInterfaceOrientationUnknown){
        CGFloat const DivideRatioForAxis = 2.f;

        CGFloat minDistanceFromAxis = 1;
        CGFloat thresholdDistanceFromCenter = 0;
        for(id pointValue in FocusPointsOfInterestSetExcludingCenter){
            CGPoint point = [pointValue CGPointValue];
            CGFloat distanceFromAxis = fabsf(
                    FindInAxisVertical
                            ? point.x - CGPointHalf.x
                            : point.y - CGPointHalf.y
            );
            if(distanceFromAxis < minDistanceFromAxis){
                thresholdDistanceFromCenter = CGPointLengthBetween(point, CGPointHalf)/DivideRatioForAxis;
                minDistanceFromAxis = distanceFromAxis;

            }
        }

        // is outside from found axis?
        currentAxisDistanceOfPointIsOutsideFromCenter = thresholdDistanceFromCenter && fabsf(
                FindInAxisVertical
                        ? CGPointHalf.y - pointOfInterestInOutputSize.y
                        : CGPointHalf.x - pointOfInterestInOutputSize.x
        ) > thresholdDistanceFromCenter;
    }

    if(currentAxisDistanceOfPointIsOutsideFromCenter){
        /*
         * optimized by orientation : find nearest point in specific Axis
         */
        CGFloat minDistanceFromAxisOneSide = 1;
        for(id pointValue in FocusPointsOfInterestSetExcludingCenter){
            CGPoint point = [pointValue CGPointValue];

            CGFloat distanceFromAxis = fabsf(FindInAxisVertical
                    ? point.y - pointOfInterestInOutputSize.y
                    : point.x - pointOfInterestInOutputSize.x
            );

            if(distanceFromAxis < minDistanceFromAxisOneSide){
                minDistanceFromAxisOneSide = distanceFromAxis;
                testTargetPointOfInterest = point;
            }
        }

    }else{
        /*
         * default logic : find nearest point in side
         */
        CGFloat minDistanceFromEachPointsAbsoluteDistances = 1;
        for(id pointValue in FocusPointsOfInterestSetExcludingCenter){
            CGPoint point = [pointValue CGPointValue];
            CGFloat distanceFromInterestPoint = CGPointLengthBetween(point, pointOfInterestInOutputSize);
            NSAssert(distanceFromInterestPoint<=1, @"normalized distance of pointOfInterestInOutputSize is same or smaller than 1.");

            if(distanceFromInterestPoint < minDistanceFromEachPointsAbsoluteDistances){
                testTargetPointOfInterest = point;
                minDistanceFromEachPointsAbsoluteDistances = distanceFromInterestPoint;
            }
        }
    }

    //focus adjusted
    return [self imageForSameFocusPointOfInterestAndFocusAdjusted:testTargetPointOfInterest];
}

- (STCapturedImage *)imageForSameFocusPointOfInterestAndFocusAdjusted:(CGPoint)pointOfInterestInOutputSize{
    STCapturedImage * foundImage = nil;
    for(STCapturedImage * itemOfImage in [self imagesForSameFocusPointOfInterest:pointOfInterestInOutputSize]){
        if(itemOfImage.focusAdjusted){
            NSAssert(!foundImage,@"numbers focusAdjusted image must unique.");
            foundImage = itemOfImage;
        }
    }
    NSAssert(foundImage,@"focusAdjusted image not found.");
    return foundImage;
}

- (NSArray<STCapturedImage *>*)imagesForSameFocusPointOfInterest:(CGPoint)pointOfInterestInOutputSize{
    NSMutableArray<STCapturedImage *> * images = [NSMutableArray<STCapturedImage *> array];
    for(STCapturedImage * itemOfImages in self.images){
        if(CGPointEqualToPointByNearest2Decimal(itemOfImages.focusPointOfInterestInOutputSize, pointOfInterestInOutputSize)){
            [images addObject:itemOfImages];
        }
    }
    pp(pointOfInterestInOutputSize);
    NSAssert(images.count>0,@"imagesForSameFocusPointOfInterest image not found.");
    return images.count ? images : nil;
}

- (STCapturedImage *)firstImageForSameFocusPointOfInterest:(CGPoint)pointOfInterestInOutputSize{
    for(STCapturedImage * itemOfImages in self.images){
        if(CGPointEqualToPointByNearest2Decimal(itemOfImages.focusPointOfInterestInOutputSize, pointOfInterestInOutputSize)){
            return itemOfImages;
        }
    }
    return nil;
}

#pragma mark FocusPointsInterestSet
- (NSArray<STCapturedImage *>*)imagesForIndexOfFocusPointsOfInterestSet{
    if([self focusPointsOfInterestSet].count){
        NSArray<NSValue *>* focusPoints = [self focusPointsOfInterestSet];
        NSValue * pointObj = [focusPoints st_objectOrNilAtIndex:self.indexOfFocusPointsOfInterestSet];
        if(!pointObj){
            pointObj = [focusPoints firstObject];
        }
        return [self imagesForSameFocusPointOfInterest:[pointObj CGPointValue]];

    }else{
        return self.images;
    }
}

- (NSUInteger)indexOfFocusPointsInterestSet:(CGPoint)pointOfInterestInOutputSize{
    NSArray<NSValue *>* focusPoints = [self focusPointsOfInterestSet];
    for(NSValue * pointObj in focusPoints){
        if(CGPointEqualToPointByNearest2Decimal([pointObj CGPointValue], pointOfInterestInOutputSize)){
            return [focusPoints indexOfObject:pointObj];
        }
    }
    NSAssert(NO,@"indexOfFocusPointsInterestSet not found.");
    return 0;
}

- (NSUInteger)indexOfFocusPointsInterestSetForImage:(STCapturedImage *)image{
    return [self indexOfFocusPointsInterestSet:image.focusPointOfInterestInOutputSize];
}

- (void)setIndexOfFocusPointsInterestSetFromImage:(STCapturedImage *)image{
    self.indexOfFocusPointsOfInterestSet = [self indexOfFocusPointsInterestSetForImage:image];
}
@end