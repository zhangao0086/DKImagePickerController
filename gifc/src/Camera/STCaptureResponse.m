//
// Created by BLACKGENE on 4/22/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCaptureResponse.h"
#import "STCaptureRequest.h"
#import "STCapturedImage.h"
#import "STAnimatableCaptureRequest.h"
#import "NSArray+STUtil.h"

#import "STPostFocusCaptureRequest.h"
#import "STCapturedImageSet.h"
#import "STCapturedImageSetProtected.h"

@implementation STCaptureResponse {

}

- (void)dealloc {
    [self dispose];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSAssert(_request, @"STCaptureRequest is nil. use initWithRequest or STCaptureResponse.responseWithRequest instead.");
    }
    return self;
}


- (instancetype)initWithRequest:(STCaptureRequest *)request {
    _request = request;
    [self setImageSetProperty];

    self = [self init];
    return self;
}

+ (instancetype)responseWithRequest:(STCaptureRequest *)request {
    return [[self alloc] initWithRequest:request];
}


- (void)setImageSet:(STCapturedImageSet *)imageSet {
    _imageSet = imageSet;
#if DEBUG
    for(STCapturedImage *image in _imageSet.images){
        NSMutableSet * assertionSet = NSMutableSet.new;
        !image.image?:[assertionSet addObject:image.image];
        !image.imageUrl?:[assertionSet addObject:image.imageUrl];
        !image.imageData?:[assertionSet addObject:image.imageData];
        NSAssert(assertionSet.count==1,@"STCaptureResponseImage only allows single source at STAnimatableCaptureResponse");
        if(self.request
                && [self.request isKindOfClass:STAnimatableCaptureRequest.class]
                && !(((STAnimatableCaptureRequest *)self.request).needsLoadAnimatableImagesToMemory)){
            NSAssert(!image.image && !image.imageData,@"STCaptureResponseImage only allows NSURL type if STAnimatableCaptureRequest's needsLoadAnimatableImagesToMemory setted YES");
        }
    }
#endif

    [self setImageSetProperty];
}

#pragma mark make STCapturedImageSet
- (void)setImageSetProperty{
    if([self.request isKindOfClass:[STPostFocusCaptureRequest class]]){
        /*
         * post focus
         */
        self.imageSet.type = STCapturedImageSetTypePostFocus;

        if(!self.imageSet.focusPointsOfInterestSet){
            self.imageSet.focusPointsOfInterestSet = ((STPostFocusCaptureRequest *)self.request).focusPointsOfInterestSet;
        }
        if(CGSizeEqualToSize(CGSizeZero, self.imageSet.outputSizeForFocusPoints)){
            self.imageSet.outputSizeForFocusPoints = ((STPostFocusCaptureRequest *)self.request).outputSizeForFocusPoints;
        }

    }else if([self.request isKindOfClass:[STAnimatableCaptureRequest class]]){
        /*
         * animatable
         */
        self.imageSet.type = STCapturedImageSetTypeAnimatable;
    }
    self.imageSet.createdTime = [NSDate timeIntervalSinceReferenceDate];
}

- (UIImage *)createNeededImageFromRequest {
    //TODO: STCapturedImageSet 자체가 이 행동을 소유하게 변경

    BOOL isAnimatable = [self.request isKindOfClass:STAnimatableCaptureRequest.class];
    STCapturedImage const *defaultImage = [self.imageSet defaultImage];

    if(isAnimatable){
        STAnimatableCaptureRequest * request = (STAnimatableCaptureRequest *)self.request;

        if(request.needsLoadAnimatableImagesToMemory){
            if(self.imageSet.images.count>1){
                //animation images
                NSTimeInterval duration = request.maxDuration * (self.imageSet.images.count / request.frameCount);
                return [UIImage animatedImageWithImages:[self.imageSet.images mapWithIndex:^id(STCapturedImage * image, NSInteger index) {
                    @autoreleasepool {
                        return [image UIImage];
                    }
                }] duration:duration];

            }else{
                //single image
                return [defaultImage UIImage];
            }
        }else{
            NSAssert(defaultImage.imageUrl,@"image URL is essential if request.needsLoadAnimatableImagesToMemory == NO");
            return [defaultImage UIImage];
        }
    }

    return [defaultImage UIImage];
}

- (void)response{
    NSAssert(self.imageSet,@"images empty");
    !self.request.responseHandler ?:self.request.responseHandler(self.imageSet ? self : nil);
    self.request.responseHandler = nil;
}

- (void)dispose {
    [_request dispose];
    _request = nil;
    self.metaData = nil;
    self.imageSet = nil;
}


@end