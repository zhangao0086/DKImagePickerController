//
// Created by Lee on 14. 7. 10..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <GPUImage/GPUImageFilter.h>
#import <GPUImage/GPUImageView.h>
#import <FXNotifications/FXNotifications.h>
#import <BlocksKit/NSTimer+BlocksKit.h>
#import <BlocksKit/NSObject+BKBlockObservation.h>
#import "STElieCamera.h"
#import "GPUImage.h"
#import "NSArray+BlocksKit.h"
#import "STCaptureRequest.h"
#import "NSObject+STUtil.h"
#import "NSObject+STThreadUtil.h"
#import "NSString+STUtil.h"
#import "STMotionManager.h"
#import "STOrientationItem.h"
#import "STAnimatableCaptureRequest.h"
#import "STCapturedImage.h"
#import "STCapturedImageProcessor.h"
#import "STCaptureResponse.h""
#import "STPostFocusCaptureRequest.h"
#import "M13OrderedDictionary.h"
#import "NSArray+STUtil.h"
#import "STCapturedImageSet.h"
#import "STCapturedImageSetProtected.h"
#import "UIImage+STUtil.h"

#define RequestFocusTimeoutInterval 2.5f
#define IntervalForCheckLensPosition .5f
#define IntervalForCheckAccelometer .5f

@interface STElieCamera (){
    void (^exposureDidAdjustedBlock)(void);
    NSOperationQueue * focusCompleteOperationQueue;
    NSMutableArray * focusCompleteOperations;

    GPUImageMotionDetector *gpuImageMotionDetector;

    CGFloat _preferredOutputVerticalRatio;
    NSObject *_autoCenterSpotExposureObserver;

    BOOL _frameRenderingLocked;
}
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCaptureStillImageOutput * stillImageOutput;
@property (nonatomic, readwrite) GPUImageLuminosity * luminosityDetector;
@property (atomic, readwrite) M13MutableOrderedDictionary *luminosityDetectionBlocks;

- (void)startObserveInputCamera;
- (void)stopObserveInputCamera;
@end

static STElieCamera *_instance = nil;

@implementation STElieCamera

+ (STElieCamera *)sharedInstance {
#if !TARGET_IPHONE_SIMULATOR
    NSAssert(_instance,@"STElieCamera is not initialized yet. Perform initSharedInstanceWithSessionPreset first.");
#endif
    return _instance;
}

+ (instancetype)initSharedInstanceWithSessionPreset:(NSString *)preset position:(AVCaptureDevicePosition)position {
    return [self initSharedInstanceWithSessionPreset:preset position:position preferredOutputRatio:0];
}

+ (instancetype)initSharedInstanceWithSessionPreset:(NSString *)preset position:(AVCaptureDevicePosition)position preferredOutputRatio:(CGFloat)ratio; {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] initWithSessionPreset:preset cameraPosition:position preferredOutputRatio:ratio];
    });
    return _instance;
}

- (instancetype)initWithSessionPreset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)cameraPosition preferredOutputRatio:(CGFloat)ratio; {
    self = [super initWithSessionPreset:sessionPreset cameraPosition:cameraPosition];
    if (self) {
        dispatch_queue_t captureQueue = dispatch_queue_create("com.elie.capturequeue", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(captureQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));

        self.sessionQueue = captureQueue;
        self.stillImageOutput = [self.captureSession.outputs bk_match:^BOOL(id obj) {
            return [obj isKindOfClass:[AVCaptureStillImageOutput class]];
        }];

        [self.captureSession beginConfiguration];
        self.stillImageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
        [self.captureSession commitConfiguration];

        self.outputImageOrientation = UIInterfaceOrientationPortrait;
        self.horizontallyMirrorFrontFacingCamera = YES;

        _preferredIntensityOfMotionDetection = 0.12f;
        _pointNormalizedOfMotionDetected = CGPointZero;

        focusCompleteOperationQueue = [NSOperationQueue mainQueue];
        focusCompleteOperationQueue.qualityOfService = NSQualityOfServiceUserInitiated;

        focusCompleteOperations = [NSMutableArray array];

        if(ratio){
            _preferredOutputVerticalRatio = ratio;
        }else{
            [self setOptimizedDefaultsOutputRatio];
            [self st_observe:@keypath(self.captureSession.sessionPreset) block:^(id value, __weak id _weakSelf) {
                [_weakSelf setOptimizedDefaultsOutputRatio];
            }];
        }
    }
    return self;
}

#pragma Info
static STCameraMode _mode = STCameraModeNotInitialized;
+ (void)setMode:(STCameraMode)mode{
    @synchronized (self) {
        [self willChangeValueForKey:@keypath(self.mode)];
        _mode = mode;
        [self didChangeValueForKey:@keypath(self.mode)];
    }
}

+ (STCameraMode)mode{
    @synchronized (self) {
        return _mode;
    }
}

#pragma Output Geometry - Preferred

- (CGSize)preferredOutputScreenSize; {
    return [self preferredOutputScreenRect].size;
}

- (CGRect)preferredOutputScreenRect {
    return [self preferredOutputRect:[UIScreen mainScreen].bounds];
}

- (CGRect)preferredOutputRect:(CGRect)rect; {
    CGRect newRect = rect;
    newRect.size.height = newRect.size.width* [self preferredOutputVerticalRatio];
    return newRect;
}

- (CGFloat)preferredOutputVerticalRatio; {
    if([STApp isInSimulator]){
        return [self.class outputVerticalRatioDefault];
    }
    return _preferredOutputVerticalRatio ?: self.class.outputVerticalRatioDefault;
}

#pragma Output Geometry - Device
- (CGSize)deviceOutputSize{
    NSDictionary *dict = [self.captureSession.outputs[0] videoSettings];
    return CGSizeMake([dict[@"Width"] floatValue], [dict[@"Height"] floatValue]);
}

- (CGSize)deviceOutputScreenSize; {
    return [self deviceOutputScreenRect].size;
}

- (CGRect)deviceOutputScreenRect {
    return [self deviceOutputRect:[UIScreen mainScreen].bounds];
}

- (CGRect)deviceOutputRect:(CGRect)rect; {
    CGRect newRect = rect;
    newRect.size.height = newRect.size.width* self.deviceOutputVerticalRatio;
    return newRect;
}

- (CGFloat)deviceOutputVerticalRatio {
    CGSize outputSize = self.deviceOutputSize;
    return outputSize.width/outputSize.height;
}

+ (CGFloat)outputVerticalRatioDefault; {
    return 1.331250f;
}

+ (CGFloat)outputVerticalRatioHD; {
    return 1.777777f;
}

- (void)setOptimizedDefaultsOutputRatio{
    //0.002406s
    CGSize outputSize = self.deviceOutputSize;

    if(CGSizeEqualToSize(outputSize, CGSizeZero)){
        _preferredOutputVerticalRatio = [self.class outputVerticalRatioDefault];
    }else{
        _preferredOutputVerticalRatio = outputSize.width/outputSize.height;
    }
}

#pragma boot
- (void)startCameraCapture; {
    //start camera
    if(![[self captureSession] isRunning]){
        [self startObserveInputCamera];
//        [self startImageMotionDetection];
    }
    [super startCameraCapture];
}

- (void)stopCameraCapture:(BOOL)willRestoreWhenNextStart; {
    [self stopCameraCapture];
}

- (void)stopCameraCapture; {
    if([[self captureSession] isRunning]){
        [self stopMotionDetection];
        [self stopObserveInputCamera];
        [self stopMonitoringSubjectAreaDidChanged];
    }
    [super stopCameraCapture];
}

- (void)resumeCameraCapture; {
    if(self->capturePaused){
        [super resumeCameraCapture];
    }
}

- (BOOL)changeFacingCamera:(BOOL)toFront completion:(void(^)(BOOL changed))block{
    if([STApp isInSimulator]){
        !block?:block(YES);
        return YES;
    }

    if(self.captureSession.running && self.isPositionFront != toFront){
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

        [self willChangeValueForKey:@keypath(self.changingFacingCamera)];
        _changingFacingCamera = YES;
        [self didChangeValueForKey:@keypath(self.changingFacingCamera)];

        Weaks
        dispatch_async([self sessionQueue], ^{
            BOOL willRotate = Wself.isPositionFront!=toFront;
            if(willRotate){
                oo(@"------------ rotate camera--------");
                [Wself rotateCamera];
            }

            [Wself st_runAsMainQueueAsync:^{
                Strongs
                [Sself willChangeValueForKey:@keypath(Sself.changingFacingCamera)];
                Sself->_changingFacingCamera = NO;
                [Sself didChangeValueForKey:@keypath(Sself.changingFacingCamera)];

                [[UIApplication sharedApplication] endIgnoringInteractionEvents];

                !block?:block(willRotate);
            }];
        });
        return YES;
    }
    return NO;
}

- (void)startFaceDetectionWithBlock:(void(^)(NSArray * detectedObjects))block {
    NSAssert([[self captureSession] isRunning], @"Capture session should running before");
    if(_faceDetectionStarted){
        return;
    }
    [self beginDetecting:kFaceMetaData codeTypes:nil withDetectionBlock: ^(SMKDetectionOptions detectionType, NSArray *detectedObjects, CGRect clapOrRectZero) {
        if(detectionType | kFaceMetaData){
            !block ? :block(detectedObjects);
        }
    }];

    [self dispatchFaceDetectionStarted:YES];
}

- (void)startFaceDetection:(id<SMKDetectionDelegate>)target {
    NSAssert([[self captureSession] isRunning], @"Capture session should running before");

    if(_faceDetectionStarted){
        return;
    }

    [self beginDetecting:kFaceMetaData withDelegate:target codeTypes:nil];

    [self dispatchFaceDetectionStarted:YES];
}

- (void)stopFaceDetection {

    [self stopDetectionOfTypes:kFaceMetaData];

    [self dispatchFaceDetectionStarted:NO];
}

- (void)dispatchFaceDetectionStarted:(BOOL)started {
    @synchronized (self) {
        Weaks
        [self st_runAsMainQueueAsyncWithoutDeadlocking:^{
            Strongs
            if(Sself->_faceDetectionStarted==started){
                return;
            }
            [Sself willChangeValueForKey:@keypath(Sself.faceDetectionStarted)];
            Sself->_faceDetectionStarted = started;
            [Sself didChangeValueForKey:@keypath(Sself.faceDetectionStarted)];
        }];
    }
}

- (void)whenChangedRunnigStatus:(void(^)(BOOL running))block{
    [self st_observe:@keypath(self.captureSession.running) block:^(id value, __weak id _weakSelf) {
        !block?:block([value boolValue]);
    }];
}

#pragma mark Output
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    //https://fabric.io/jessi/ios/apps/com.stells.eliew/issues/56da7adcffcdc042508ec8bc
    if([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive){
        return;
    }

//    BlockOnce(^{
//
//        //AVCaptureStillImageOutput;
//    });

    [super captureOutput:captureOutput didOutputSampleBuffer:sampleBuffer fromConnection:connection];
}

#pragma mark Capture
- (BOOL)isCapturing {
    return [STCapturedImageProcessor sharedProcessor].processing || self.stillImageOutput.isCapturingStillImage;
}

- (void)capture:(STCaptureRequest *)request;
{
    NSParameterAssert(request);

    if(self.capturing){
        [[STCaptureResponse responseWithRequest:request] response];
        return;
    }

    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if(error || !imageDataSampleBuffer){
            [[STCaptureResponse responseWithRequest:request] response];
            return;
        }

        //force acquire current orientation
        STMotionManager * motionManager = [STMotionManager sharedManager];
        request.needsOrientationItem = [STOrientationItem itemWith:motionManager.deviceOrientation
                                              interfaceOrientation:motionManager.interfaceOrientation
                                                  imageOrientation:motionManager.imageOrientation];

        [[STCapturedImageProcessor sharedProcessor] requestData:[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer] request:request];
    }];
};

- (UIImage *)currentImageForRequest:(STCaptureRequest *)request{
    /*
     * crop region
     */
    CGRect cropRegion = CGRectNull;
    switch (request.captureOutputAspectTransform){
        case CaptureOutputAspectTransformFillCropAsCenterSquare:
            cropRegion = CGRectCenterSquareNormalizedRegionAspectFill(self.deviceOutputScreenSize);
            break;
        default:
            break;
    }

    return [self currentImage:request.needsFilter maxSideOutputPixelSize:request.captureOutputPixelSize cropRegion:cropRegion];
}

#pragma mark Capture Animatable
- (void)captureAnimatable:(STAnimatableCaptureRequest *)request;{
    NSParameterAssert(request.responseHandler);

    NSTimeInterval totalDuration = request.maxDuration;
    NSTimeInterval frameCount = request.frameCount;

    __block NSUInteger count = 0;
    __block NSTimer * captureDelayTimer = nil;
    __block NSMutableArray<STCapturedImage *> * images = [NSMutableArray arrayWithCapacity:(NSUInteger) frameCount];

    Weaks
    captureDelayTimer = [NSTimer bk_scheduledTimerWithTimeInterval:request.frameCaptureInterval block:^(NSTimer *timer) {
        @autoreleasepool {
            //get image
            UIImage * capturedImage = [Wself currentImageForRequest:request];
            STCapturedImage * responseImage = [STCapturedImage new];
            responseImage.index = count;

            if(request.needsLoadAnimatableImagesToMemory){
                responseImage.image = capturedImage;
                [images addObject:responseImage];

            }else{
                NSURL * fileURL = [[[@(count) stringValue] st_add:@"_animatable_captured"] URLForTemp:@"jpg"];
                if([responseImage save:capturedImage to:fileURL]){
                    responseImage.imageUrl = fileURL;
                    [images addObject:responseImage];
                }
            }

            ++count;

            //progress
            BOOL stop = NO;
            !request.progressHandler?:request.progressHandler(count/frameCount, count, (NSUInteger) frameCount, &stop);

            //finalize
            if(count==frameCount || stop){
                [captureDelayTimer invalidate];
                captureDelayTimer = nil;

                NSAssert(stop || images.count==frameCount, @"images.count is not matched with frameCount");

                NSMutableArray * reverseArray = [NSMutableArray arrayWithArray:[images copy]];

                //autoReverseFrames
//            if(request.autoReverseFrames){
//                [images removeLastObject];
//                [images removeObject:[images firstObject]];
//                while(images.count){
//                    [reverseArray addObject:[images pop]];
//                }
//            }

                images = nil;
                count = 0;

                [Wself st_runAsMainQueueAsyncWithoutDeadlocking:^{
                    STCaptureResponse * response = [STCaptureResponse responseWithRequest:request];
                    response.imageSet = [STCapturedImageSet setWithImages:reverseArray];
                    [response response];
                }];
            }
        }
    } repeats:YES];
}

#pragma mark Capture PostFocusing
- (void)capturePostFocusing:(STPostFocusCaptureRequest *)request {
    NSAssert([STElieCamera sharedInstance].isPositionBack, @"PostFocus mode allowed only BackFacing Camera");

    if(request.focusPointsOfInterestSet){
        [self capturePostFocusingWithFocusPoints:request];
    }else{
        [self capturePostFocusingWithLensPostionRange:request];
    }
}

#pragma mark Post Focus - 0 to 1 lensPosition
- (void)capturePostFocusingWithLensPostionRange:(STPostFocusCaptureRequest *)request;{
    NSParameterAssert(request.responseHandler);

    //TODO: LensPosition 레인지를 설정할 수 있음.
    CGFloat const frameCount = request.frameCount;

    __block NSUInteger count = 0;

    __block NSMutableArray<STCapturedImage *> * images = [NSMutableArray arrayWithCapacity:(NSUInteger) frameCount];

    CGFloat const StartingLensPosition = self.inputCamera.lensPosition;
    CGPoint const StartingFocusPoint = CGPointOfInterestInBound(request.outputSizeForFocusPoints, self.inputCamera.focusPointOfInterest);
    BOOL const LensMovingDirectionReversed = StartingLensPosition>=.5;
    BOOL const NeedsLoadImages = request.needsLoadAnimatableImagesToMemory;
    BOOL const MonitorStopped = [self stopMonitoringSubjectAreaDidChanged];

    __block CGFloat minDistanceFromStartingLensPosition = 1;
    __block NSUInteger pointedIndexOfUrls = 0;

    [self lockRequestFocus];
    [self lockRequestExposure];
    [self lockExposure];

    Weaks
    __block void(^captureImages)(void);
    (captureImages = ^{
        if ([self.inputCamera lockForConfiguration:nil]) {
            //to move shortest distance
            CGFloat nextLensPosition = 0;
            if(LensMovingDirectionReversed){
                nextLensPosition = (CGFloat) (count==0 ? 1 : (
                        count>=frameCount-1 ? 0 : 1-(count/frameCount))
                );
            }else{
                nextLensPosition = (CGFloat) (count>=frameCount-1 ? 1 : count/frameCount);
            }

            [_inputCamera setFocusModeLockedWithLensPosition:nextLensPosition completionHandler:^(CMTime syncTime) {
                @autoreleasepool {
                    STCapturedImage * responseImage = [self createPostFocusingImageFrom:request lensPosition:nextLensPosition focusPointOfInterestInOutputSize:StartingFocusPoint];
                    [responseImage setOrientationsByCurrent];

                    NSLog(@"LensPos : R %f -> A %f",nextLensPosition, self.inputCamera.lensPosition);
                    UIImage * image = [self currentImageForRequest:request];

                    if(NeedsLoadImages){
                        responseImage.image = image;
                        [images addObject:responseImage];

                    }else{
                        NSURL * fileURL = [[[@(count) stringValue] st_add:@"_lensposition_captured"] URLForTemp:@"jpg"];
                        //FIXME: 간헐적으로 image ==nil인 경우가 있음
                        NSAssert(image,@"STElieCamera.currentImage == nil @ capturePostFocusingWithLensPostionRange");
                        if([responseImage save:image to:fileURL]){
                            [images addObject:responseImage];
                        }

                        CGFloat currentDistance = fabs(StartingLensPosition-nextLensPosition);
                        if(currentDistance < minDistanceFromStartingLensPosition){
                            pointedIndexOfUrls = count;
                            minDistanceFromStartingLensPosition = currentDistance;
                        }
                    }

                    ++count;

                    //progress
                    BOOL stop = NO;
                    !request.progressHandler ?: request.progressHandler(count  / frameCount, count, (NSUInteger) frameCount, &stop);

                    //finalize
                    if (count == frameCount || stop) {

                        NSMutableArray<STCapturedImage *>*resultImages = [NSMutableArray arrayWithArray:[images copy]];

                        //autoReverseFrames
                        if (request.autoReverseFrames) {
                            [images removeLastObject];
                            [images removeObject:[images firstObject]];
                            while (images.count) {
                                [resultImages addObject:[images pop]];
                            }
                        }

                        STCaptureResponse * response = [STCaptureResponse responseWithRequest:request];
                        response.imageSet = [STCapturedImageSet setWithImages:LensMovingDirectionReversed ? resultImages : [resultImages reverse]];
                        response.imageSet.indexOfDefaultImage = LensMovingDirectionReversed ? pointedIndexOfUrls : (NSUInteger)(frameCount-1)-pointedIndexOfUrls;
                        NSAssert([NSThread isMainThread], @"capture response should call in main thread");
                        [response response];

                        images = nil;
                        count = 0;
                        captureImages = nil;

                        if(MonitorStopped){
                            [Wself startMonitoringSubjectAreaDidChanged];
                        }
                        [Wself resetFocusExposure];
                    }
                    else {
                        captureImages();
                    }
                }
            }];
            [self.inputCamera unlockForConfiguration];
        }
    })();
}

#pragma mark Post Focus by Points
#define OptimizeDuplicatedLensPositionToCapturePostFocus NO

- (void)capturePostFocusingWithFocusPoints:(STPostFocusCaptureRequest *)request; {
    NSAssert(request.focusPointsInOutputSize,@"request.focusPointsInOutputSize is nil");
    if(!request.focusPointsInOutputSize){
        [[STCaptureResponse responseWithRequest:request] response];
        return;
    }


    __block STCapturedImageSet * imageSet = [STCapturedImageSet setWithImages:nil];

    NSEnumerator * pointsEnum = [request.focusPointsInOutputSize objectEnumerator];
    __block void(^captureImages)(CGPoint);

    //start listening
    NSString * lensTrackingObserverId = @"lens_tracking";
    [self st_addKeypathListener:@keypath(self.inputCamera.lensPosition) id:lensTrackingObserverId newValueBlock:^(id value, id _weakSelf) {
        [self appendPostFocusingWithFocusPoints:request image:nil to:imageSet adjusted:NO];
    }];
    //lock monitoring
    BOOL monitorStopped = [self stopMonitoringSubjectAreaDidChanged];
    [self lockRequestExposure];
    [self lockExposure];

    CGRect focusRect = (CGRect){CGPointZero, request.outputSizeForFocusPoints};

    __block NSUInteger count = 0;

    Weaks
    (captureImages = ^(CGPoint p){

        [self unlockRequestFocus];

        //progress
        BOOL stop = NO;
        ++count;
        if(count < request.focusPointsInOutputSize.count){
            !request.progressHandler ?: request.progressHandler(count / (CGFloat)request.focusPointsInOutputSize.count, count, (NSUInteger) request.focusPointsInOutputSize.count, &stop);
        }

        [self requestSingleFocus:focusRect pointInRect:p syncWithExposure:NO completion:^{
            STCapturedImage * imageFromCurrent = [self createPostFocusingImageFromCurrent:request];

            NSLog(@"focuse adjusted : %f,%f - l %f",imageFromCurrent.focusPointOfInterestInOutputSize.x,imageFromCurrent.focusPointOfInterestInOutputSize.y,imageFromCurrent.lensPosition);

            STCapturedImage * imageForSameFocusPointExisted = [imageSet firstImageForSameFocusPointOfInterest:imageFromCurrent.focusPointOfInterestInOutputSize];
            if(!imageForSameFocusPointExisted){
                //TODO: 렌즈 포지션 안들어오는 문제 수정
                [self appendPostFocusingWithFocusPoints:request image:imageFromCurrent to:imageSet adjusted:YES];
                oo(@"[!] WARNING : not found focusing point");
            }else{
                STCapturedImage * almostSameLensPositionImage = [imageSet imageForNearestLensPosition:imageFromCurrent.lensPosition equalFocusPointTo:imageForSameFocusPointExisted];

                NSAssert(almostSameLensPositionImage,@"almostSameLensPositionImage is nil why?");
                if(!almostSameLensPositionImage){
                    [self appendPostFocusingWithFocusPoints:request image:imageFromCurrent to:imageSet adjusted:YES];

                }else{

                    if(OptimizeDuplicatedLensPositionToCapturePostFocus){
                        imageFromCurrent = almostSameLensPositionImage;

                    }else{
                        if(imageFromCurrent.lensPosition==almostSameLensPositionImage.lensPosition){
                            imageFromCurrent = almostSameLensPositionImage;
                        }
                        else{
                            NSLog(@"expected : %f / actual %f",imageFromCurrent.lensPosition, almostSameLensPositionImage.lensPosition);
//                            NSParameterAssert(NO);
                            [imageFromCurrent copySourceByImageOfSameLensPosition:almostSameLensPositionImage];
                        }
                    }

                }
            }
            //현재의 렌즈 포지션 + 포커스 포인트에 가장 유사한 걸 찾아 마킹한다.
            imageFromCurrent.focusAdjusted = YES;

            NSAssert(imageFromCurrent,@"imageFromCurrent is nil");
            NSLog(@"Focused : %f, %f / lensPostion : %f / focus : %f %f", p.x, p.y, imageFromCurrent.lensPosition,imageFromCurrent.focusPointOfInterestInOutputSize.x, imageFromCurrent.focusPointOfInterestInOutputSize.y);

            //next
            NSValue * nextPoint = [pointsEnum nextObject];
            if(!stop && nextPoint){
                //next
                captureImages([nextPoint CGPointValue]);
            }else{
                //finishing
                !request.progressHandler ?: request.progressHandler(1, request.focusPointsInOutputSize.count, (NSUInteger) request.focusPointsInOutputSize.count, &stop);

                //end listening
                [Wself st_removeKeypathListener:@keypath(self.inputCamera.lensPosition) id:lensTrackingObserverId];

                STCaptureResponse * response = [STCaptureResponse responseWithRequest:request];
                response.imageSet = [imageSet sortImagesByLensPostion:YES];
                response.imageSet.indexOfDefaultImage = [response.imageSet indexOfImageForNearestFocusPointOfInterest:request.defaultFocusPointsOfInterest];
                response.imageSet.indexOfFocusPointsOfInterestSet = request.indexOfFocusPointsOfInterestSet;

                oo(@"====== RESULT =======");
                for(STCapturedImage * image in response.imageSet.images){
                    NSLog(@"%@ lensPostion : %f / focus : %f %f", image.focusAdjusted?@"[F]":@"", image.lensPosition, image.focusPointOfInterestInOutputSize.x, image.focusPointOfInterestInOutputSize.y);
                }
                [response response];

                imageSet = nil;
                captureImages = nil;

                //restart if needed
                if(monitorStopped){
                    [self startMonitoringSubjectAreaDidChanged];
                }
                [self resetFocusExposure];
                
                oo(@"finished");
            }
        }];

        [self lockRequestFocus];

    })([[pointsEnum nextObject] CGPointValue]);
}

- (STCapturedImage *)createPostFocusingImageFromCurrent:(STPostFocusCaptureRequest *)request{
    return [self createPostFocusingImageFrom:request lensPosition:self.inputCamera.lensPosition focusPointOfInterestInOutputSize:CGPointOfInterestInBound(request.outputSizeForFocusPoints, self.inputCamera.focusPointOfInterest)];
}

- (STCapturedImage *)createPostFocusingImageFrom:(STPostFocusCaptureRequest *)request
                                    lensPosition:(CGFloat)lensPosition
                focusPointOfInterestInOutputSize:(CGPoint)point{

    STCapturedImage * responseImage = STCapturedImage.new;
    responseImage.lensPosition = lensPosition;
    responseImage.focusPointOfInterestInOutputSize = point;
    NSAssert(!request.focusPointsOfInterestSet || [request.focusPointsOfInterestSet bk_select:^BOOL(id obj) {
        return CGPointEqualToPointByNearest2Decimal([obj CGPointValue], responseImage.focusPointOfInterestInOutputSize);
    }].count==1, ([@"focusPointsOfInterestSet is empty, OR, focusPointOfInterestInOutputSize is NOT CONTAINED or DUPLICATED in request.focusPointsOfInterestSet" st_add:[NSString stringWithFormat:@"%@ - %@",request.focusPointsOfInterestSet, NSStringFromCGPoint(responseImage.focusPointOfInterestInOutputSize)]]));
    responseImage.createdTime = [NSDate timeIntervalSinceReferenceDate];
    return responseImage;
}

- (STCapturedImage *)appendPostFocusingWithFocusPoints:(STPostFocusCaptureRequest *)request image:(STCapturedImage *)responseImage to:(STCapturedImageSet *)imageSet adjusted:(BOOL)adjusted{
    @autoreleasepool{
        if(!responseImage){
            responseImage = [self createPostFocusingImageFromCurrent:request];
        }

        if(OptimizeDuplicatedLensPositionToCapturePostFocus){
            if(!adjusted){
                STCapturedImage * almostSameLensPosition = [imageSet imageForAlmostSameLensPosition:responseImage.lensPosition];
                if(almostSameLensPosition){
                    return almostSameLensPosition;
                }
            }
        }

        //set orientation
        [responseImage setOrientationsByCurrent];

        //new capture
        UIImage * image = [self currentImageForRequest:request];

        if(request.needsLoadAnimatableImagesToMemory){
            responseImage.image = image;
            [imageSet.images addObject:responseImage];
        }else{
            NSURL * fileURL = [[[@(imageSet.images.count) stringValue] st_add:@"_fp_captured"] URLForTemp:@"jpg"];
            if([responseImage save:image to:fileURL]){
                [imageSet.images addObject:responseImage];
            }
        }
        NSLog(@"Appended post focus image %f",responseImage.lensPosition);
        return responseImage;
    }
}

#pragma mark GPURendering

- (void)lockRendering{
    @synchronized (self) {
        if(!_frameRenderingLocked){
            _frameRenderingLocked = YES;
            dispatch_semaphore_wait(frameRenderingSemaphore, DISPATCH_TIME_FOREVER);
        }
    }
}

- (void)unlockRendering{
    @synchronized (self) {
        if(_frameRenderingLocked){
           _frameRenderingLocked = NO;
            dispatch_semaphore_signal(frameRenderingSemaphore);
        }
    }
}

#pragma mark Orientation
//Reverse from GPUImageVideoCamera.updateOrientationSendToTargets
- (GPUImageRotationMode)GPUImageInputRotation:(UIInterfaceOrientation)orientation{
    if(self.isPositionBack)
    {
        if (self.horizontallyMirrorRearFacingCamera)
        {
            switch(orientation)
            {
                case UIInterfaceOrientationPortrait:return kGPUImageRotateRightFlipVertical;
                case UIInterfaceOrientationPortraitUpsideDown:return kGPUImageRotateRightFlipHorizontal;
                case UIInterfaceOrientationLandscapeLeft:return kGPUImageFlipVertical;
                case UIInterfaceOrientationLandscapeRight:return kGPUImageFlipHorizonal;
                default:return kGPUImageNoRotation;
            }
        }
        else
        {
            switch (orientation){
                case UIInterfaceOrientationPortrait: return kGPUImageRotateRight;
                case UIInterfaceOrientationPortraitUpsideDown: return kGPUImageRotateLeft;
                case UIInterfaceOrientationLandscapeLeft: return kGPUImageNoRotation;
                case UIInterfaceOrientationLandscapeRight: return kGPUImageRotate180;
                default:return kGPUImageNoRotation;
            }
        }
    }
    else if(self.isPositionFront){
        if (self.horizontallyMirrorFrontFacingCamera)
        {
            switch(orientation)
            {
                case UIInterfaceOrientationPortrait:return kGPUImageRotateRightFlipVertical;
                case UIInterfaceOrientationPortraitUpsideDown:return kGPUImageRotateRightFlipHorizontal;
                case UIInterfaceOrientationLandscapeLeft:return kGPUImageFlipVertical;
                case UIInterfaceOrientationLandscapeRight:return kGPUImageFlipHorizonal;
                default:return kGPUImageNoRotation;
            }
        }
        else
        {
            switch(orientation)
            {
                case UIInterfaceOrientationPortrait:return kGPUImageRotateRight;
                case UIInterfaceOrientationPortraitUpsideDown:return kGPUImageRotateLeft;
                case UIInterfaceOrientationLandscapeLeft:return kGPUImageNoRotation;
                case UIInterfaceOrientationLandscapeRight:return kGPUImageRotate180;
                default:return kGPUImageNoRotation;
            }
        }
    }
    return kGPUImageNoRotation;
}

- (UIImageOrientation)imageOrientationFromCurrentOutputOrientation{
    switch(self.outputImageOrientation) {
        case UIInterfaceOrientationUnknown:
        case UIInterfaceOrientationPortrait:
            return UIImageOrientationUp;

        case UIInterfaceOrientationPortraitUpsideDown:
            return UIImageOrientationDown;

        case UIInterfaceOrientationLandscapeLeft:
            return UIImageOrientationLeft;

        case UIInterfaceOrientationLandscapeRight:
            return UIImageOrientationRight;
    }

    return UIImageOrientationUp;
}

#pragma mark Presentation

#if DEBUG
- (void)addTarget:(id <GPUImageInput>)newTarget; {
    [super addTarget:newTarget];

    [self debugTargetIfNeeded];
}

- (void)removeTarget:(id <GPUImageInput>)targetToRemove; {
    [super removeTarget:targetToRemove];

    [self debugTargetIfNeeded];
}

- (void)debugTargetIfNeeded{
//        oo([[STElieCamera sharedInstance] targets]);
//        if([[[STElieCamera sharedInstance] targets].firstObject isKindOfClass:GPUImageLuminosity.class]){
//            NSAssert([[STElieCamera sharedInstance] targets].count>1,@"why??");
//        }else{
//            NSAssert([[STElieCamera sharedInstance] targets].count>0,@"why??");
//        }
    Weaks
    [self st_runAsMainQueueAsyncWithoutDeadlocking:^{
        [Wself st_performOnceAfterDelay:1 block:^{
            oo([[STElieCamera sharedInstance] targets])
        }];
    }];
}
#endif

#pragma mark Start/Stop Observation

- (void)startMotionDetection:(CGFloat)intensity withGyro:(BOOL)withGyro detectionBlock:(void(^)(CGPoint motionCentroid, CGFloat motionIntensity, CMTime frameTime, CMGyroData * gyroData))block {
    // motion detect
    if(!gpuImageMotionDetector){
        Weaks
        gpuImageMotionDetector = [[GPUImageMotionDetector alloc] init];
        [gpuImageMotionDetector setLowPassFilterStrength:intensity];
        [gpuImageMotionDetector setMotionDetectionBlock:^(CGPoint motionCentroid, CGFloat motionIntensity, CMTime frameTime) {
            Strongs
            _intensityOfMotionDetection = motionIntensity;
            _motionIdled = _intensityOfMotionDetection < Wself.preferredIntensityOfMotionDetection;
            _pointNormalizedOfMotionDetected = motionCentroid;

            !block ?: block(motionCentroid, motionIntensity, frameTime, [STMotionManager sharedManager].gyroData);
        }];
        [self addTarget:gpuImageMotionDetector];

        if([[STMotionManager sharedManager] isGyroAvailable]){
            [STMotionManager sharedManager].gyroUpdateInterval = .1;
            [[STMotionManager sharedManager] startGyroUpdatesToQueue:[STMotionManager sharedManager].motionOperationQueue withHandler:nil];
        }
    }
}

- (void)stopMotionDetection {
    // motion detect
    if(gpuImageMotionDetector){
        [self removeTarget:gpuImageMotionDetector];
        _pointNormalizedOfMotionDetected = CGPointZero;
        gpuImageMotionDetector = nil;

        [[STMotionManager sharedManager] stopGyroUpdates];
    }
}


- (void)startLuminosityDetection:(NSString *)id detectionBlock:(void(^)(CGFloat luminosity, CMTime frameTime))block{
    @synchronized (self) {
        if (block) {
            if (!self.luminosityDetectionBlocks) {
                self.luminosityDetectionBlocks = [M13MutableOrderedDictionary orderedDictionary];
            }
            if (![[self.luminosityDetectionBlocks allKeys] includes:id]) {
                [self.luminosityDetectionBlocks addObject:block pairedWithKey:id];
            }

            Weaks
            if (!_luminosityDetector) {
                _luminosityDetector = [[GPUImageLuminosity alloc] init];
                [_luminosityDetector setLuminosityProcessingFinishedBlock:^(CGFloat luminosity, CMTime frameTime) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        @synchronized (Wself) {
                            if(Wself){
                                @autoreleasepool {
                                    for(void(^_block)(CGFloat, CMTime) in [[Wself.luminosityDetectionBlocks copy] allObjects]){
                                        !_block?:block(luminosity, frameTime);
                                    }
                                }
                            }
                        }
                    });
                }];
                [Wself addTarget:_luminosityDetector];
            }

        } else {
            [self stopLuminosityDetection:id];
        }
    }
}

- (void)stopLuminosityDetection:(NSString *)id{
    @synchronized (self) {
        if([[self.luminosityDetectionBlocks allKeys] includes:id]){
            [self.luminosityDetectionBlocks removeObjectForKey:id];

            if(!self.luminosityDetectionBlocks.count){
                [self removeTarget:_luminosityDetector];

                [self.luminosityDetectionBlocks removeAllObjects];
                self.luminosityDetectionBlocks = nil;
                _luminosityDetector = nil;
            }
        }
    }
}

- (BOOL)isRunningLuminosityDetection:(NSString *)id{
    return self.luminosityDetectionBlocks && [[self.luminosityDetectionBlocks allKeys] includes:id];
}

#pragma mark KVO
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key; {
    if([@"focusAdjusted" isEqual:key]){
        return NO;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}

- (void)_setFocusAdjusted:(BOOL)adjusted{
    if(_focusAdjusted==adjusted){
        return;
    }

    [self willChangeValueForKey:@keypath(self.focusAdjusted)];
    _focusAdjusted = adjusted;
    [self didChangeValueForKey:@keypath(self.focusAdjusted)];
}


- (void)startObserveInputCamera {
    Weaks
    /*
        check focusing status when only AVCaptureFocusModeAutoFocus
     */
    [self observeProperty:@keypath(self.inputCamera.adjustingFocus) withBlock:^(__weak id _self, id old, id new) {
        //WARN : AVCaptureFocusModeContinuousAutoFocus 일때는 들어오지 않는다.

        BOOL adjusted = [old boolValue] && ![new boolValue];
        [_self _setFocusAdjusted:adjusted];

        if(adjusted){
            [_self flushRequestFocusCompletions];
        }
    }];

    /*
        check focusing status when AVCaptureFocusModeContinuousAutoFocus
     */
//    __block CGFloat _lensPosition = -1;
//    NSString * idCheckMovingLens = @"moving_lens";
//    [self observeProperty:@keypath(self.inputCamera.lensPosition) withBlock:^(__weak id _self, id old, id new) {
//        if(self.inputCamera.focusMode != AVCaptureFocusModeContinuousAutoFocus){
//            _lensPosition = -1;
//            [self st_clearPerformOnceAfterDelay:idCheckMovingLens];
//            return;
//        }
//
//        _lensPosition = Wself.inputCamera.lensPosition;
//        [self _setFocusAdjusted:NO];
//        [self st_performOnceAfterDelay:idCheckMovingLens interval:IntervalForCheckLensPosition block:^{
//            if (self.inputCamera.lensPosition != _lensPosition) {
//                return;
//            }
//            [self _setFocusAdjusted:YES];
//            [self flushRequestFocusCompletions];
//            _lensPosition = -1;
//        }];
//    }];

        /*
            check exposure status when AVCaptureFocusModeAutoFocus || AVCaptureFocusModeContinuousAutoFocus
         */
    [self observeProperty:@keypath(self.inputCamera.adjustingExposure) withBlock:^(__weak id _self, id old, id new) {
        Strongs
        BOOL adjusted = [old boolValue] && ![new boolValue];

        Sself->_exposureAdjusted = adjusted;
        if(adjusted){
            //TODO: 1개의 블럭이 아니라 다수의 operations 로 관리 (lock이 없으면 호출이 되지 않을 수도있음)
            !Sself->exposureDidAdjustedBlock?:Sself->exposureDidAdjustedBlock();
        }
    }];
}

- (void)stopObserveInputCamera {
    [[self inputCamera] removeObserver:self forKeyPath:@keypath(self.inputCamera.adjustingFocus) context:nil];
    [[self inputCamera] removeObserver:self forKeyPath:@keypath(self.inputCamera.lensPosition) context:nil];
    [[self inputCamera] removeObserver:self forKeyPath:@keypath(self.inputCamera.adjustingExposure) context:nil];
}

#pragma mark subject area
- (BOOL)startMonitoringSubjectAreaDidChanged {
    if([_inputCamera isSubjectAreaChangeMonitoringEnabled]){
        return NO;
    }
    if([_inputCamera lockForConfiguration:nil]){
        [_inputCamera setSubjectAreaChangeMonitoringEnabled:YES];
        [_inputCamera unlockForConfiguration];
    }
    return YES;
}

- (BOOL)stopMonitoringSubjectAreaDidChanged {
    if(![_inputCamera isSubjectAreaChangeMonitoringEnabled]){
        return NO;
    }
    if([_inputCamera lockForConfiguration:nil]){
        [_inputCamera setSubjectAreaChangeMonitoringEnabled:NO];
        [_inputCamera unlockForConfiguration];
    }
    return YES;
}

- (void)addSubjectAreaChangeMonitor:(id)target block:(void (^)(void))block {
    void (^_block)(void) = [block copy];
    [[NSNotificationCenter defaultCenter] addObserver:target forName:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note, id observer) {
        _block();
    }];
}

- (void)removeSubjectAreaChangeMonitor:(id)target{
    [[NSNotificationCenter defaultCenter] removeObserver:target name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
}

#pragma mark ISO
-(void)activateLLBoostMode
{
    AVCaptureDevice *device = [videoInput device];
    if([device isLowLightBoostSupported] && ![device isLowLightBoostEnabled]){
        if([device lockForConfiguration:nil]){
            [device setAutomaticallyEnablesLowLightBoostWhenAvailable:YES];
            [device unlockForConfiguration];
        }
    }
}

-(void)deactivateLLBoostMode
{
    AVCaptureDevice *device = [videoInput device];
    if([device isLowLightBoostSupported] && [device isLowLightBoostEnabled]){
        if([device lockForConfiguration:nil]){
            [device setAutomaticallyEnablesLowLightBoostWhenAvailable:NO];
            [device unlockForConfiguration];
        }
    }
}

- (BOOL)isPositionBack; {
    return self.cameraPosition==AVCaptureDevicePositionBack;
}

- (BOOL)isPositionFront; {
    return self.cameraPosition==AVCaptureDevicePositionFront;

}

#pragma mark Focus
// focus complete operations
- (void)cancelRequestFocus{
    [self st_runAsMainQueueWithoutDeadlocking:^{
        for(NSOperation * op in focusCompleteOperations){
            [self st_clearPerformOnceAfterDelay:[op st_uid]];
        }
        [focusCompleteOperationQueue cancelAllOperations];
        [focusCompleteOperations removeAllObjects];
    }];
}

- (void)flushRequestFocusCompletions{
    for(NSOperation * op in focusCompleteOperations){
        [self st_clearPerformOnceAfterDelay:[op st_uid]];
        [focusCompleteOperationQueue addOperation:op];
    }
    [focusCompleteOperations removeAllObjects];
}

- (void)addOperationFocusCompletions:(void (^)(void))block{
    Weaks
    [self st_runAsMainQueueWithoutDeadlocking:^{
        NSOperation * operation = [NSBlockOperation blockOperationWithBlock:block];
        [focusCompleteOperations addObject:operation];

        [self st_performOnceAfterDelay:[operation st_uid] interval:RequestFocusTimeoutInterval block:^{
            Strongs
            NSLog(@"---------------- focus request timedout ----------------", [operation st_uid]);
            [Sself flushRequestFocusCompletions];
        }];
    }];
}

#pragma mark Focus-Reset
- (BOOL)resetFocusExposure {
    if(self.enabledBacklightCare){
        return [self _resetFocusExposureToContinuousOptimizedForFace];
    }else{
        return [self _resetFocusExposureToContinuous];
    }
}

- (BOOL)_resetFocusExposureToContinuous {
    [self cancelRequestFocus];
    [self unlockRequestFocus];

    [self unlockRequestExposure];

    [self _stopAutoCenterSpotExposureForFaceBacklightCare];

    return [self requestContinuousFocusWithCenter:YES completion:nil];
}

- (BOOL)_resetFocusExposureToContinuousOptimizedForFace {
    [self cancelRequestFocus];
    [self unlockRequestFocus];

    [self unlockRequestExposure];

    [self _startAutoCenterSpotExposureForFaceBacklightCare];

    BOOL focused = [self _requestFocus:DefaultCenterPointOfInterest continuous:YES syncWithExposure:NO completion:nil];
    BOOL exposed = [self _requestExposure:DefaultCenterPointOfInterest continuous:YES completion:nil];
    return focused && exposed;
}

#pragma mark CenterSpot Exposure
//start auto center
static BOOL _startedAutoCenterSpotExposure;
- (void)_startAutoCenterSpotExposureForFaceBacklightCare {
    if(_startedAutoCenterSpotExposure){
        return;
    }
    _startedAutoCenterSpotExposure = YES;

    [self _startCenterSpotExposureViaSubjectArea];
    [self _startCenterSpotExposureViaLuminosity];
//    [self _startCenterSpotExposureViaTimer];
    //TODO: 아마 이정도만필요하지싶은데
    [self _startCenterSpotExposureViaOrientation];

    [self startMonitoringSubjectAreaDidChanged];
}

- (void)_startCenterSpotExposureViaSubjectArea{
    if(_autoCenterSpotExposureObserver){
        return;
    }

    _autoCenterSpotExposureObserver = [[NSObject alloc] init];
    Weaks
    [self addSubjectAreaChangeMonitor:_autoCenterSpotExposureObserver block:^{
        if (Wself.exposureAdjusted) {
            [Wself requestExposureToVirtualCenterFace:YES completion:nil];
        }
    }];
}

NSString *ID_CENTER_SPOT = @"centerpotexposure";
static CGFloat _prevluminosity;
- (void)_startCenterSpotExposureViaLuminosity{
    Weaks
    [[STElieCamera sharedInstance] startLuminosityDetection:ID_CENTER_SPOT detectionBlock:^(CGFloat luminosity, CMTime frameTime) {
        if(fabs(_prevluminosity-luminosity)>0.07){
            [Wself st_runAsMainQueueAsync:^{
                Strongs
                if (Sself.exposureAdjusted) {
                    [Sself requestExposureToVirtualCenterFace:YES completion:nil];
                }
            }];
        }
        _prevluminosity = luminosity;
    }];
}

static NSTimer *_timerForAutoCenterSpotExposure;
- (void)_startCenterSpotExposureViaTimer{
    Weaks
    _timerForAutoCenterSpotExposure = [NSTimer bk_scheduledTimerWithTimeInterval:1 block:^(NSTimer *timer) {
        if (Wself.exposureAdjusted) {
            [Wself requestExposureToVirtualCenterFace:YES completion:nil];
        }
    } repeats:YES];
}

NSString *ObserveOrientationId = @"_startCenterSpotExposureViaOrientation";
- (void)_startCenterSpotExposureViaOrientation{
    Weaks
    [[STMotionManager sharedManager] bk_addObserverForKeyPath:@keypath([STMotionManager sharedManager].interfaceOrientation) identifier:ObserveOrientationId options:NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
        [Wself requestExposureToVirtualCenterFace:YES completion:nil];
    }];
}

//stop auto center
- (void)_stopAutoCenterSpotExposureForFaceBacklightCare {
    _startedAutoCenterSpotExposure = NO;

    [self _stopCenterSpotExposureViaSubjectArea];
    [self _stopCenterSpotExposureViaLuminosity];
    [self _stopCenterSpotExposureViaTimer];
    [self _stopCenterSpotExposureViaOrientation];
}

- (void)_stopCenterSpotExposureViaSubjectArea{
    if(!_autoCenterSpotExposureObserver){
        return;
    }
    [self removeSubjectAreaChangeMonitor:_autoCenterSpotExposureObserver];
    _autoCenterSpotExposureObserver = nil;
}

- (void)_stopCenterSpotExposureViaLuminosity{
    [[STElieCamera sharedInstance] stopLuminosityDetection:ID_CENTER_SPOT];
    _prevluminosity = 0;
}

- (void)_stopCenterSpotExposureViaTimer{
    [_timerForAutoCenterSpotExposure invalidate];
    _timerForAutoCenterSpotExposure = nil;
}

- (void)_stopCenterSpotExposureViaOrientation{
    [self bk_removeObserversWithIdentifier:ObserveOrientationId];
}

#pragma mark single
- (BOOL)requestSingleFocus:(CGRect)previewRect pointInRect:(CGPoint)point completion:(void (^)(void))block
{
    return [self requestFocus:previewRect pointInRect:point continuous:NO syncWithExposure:YES completion:block];
}

- (BOOL)requestSingleFocus:(CGRect)previewRect pointInRect:(CGPoint)point syncWithExposure:(BOOL)sync completion:(void (^)(void))block{
    return [self requestFocus:previewRect pointInRect:point continuous:NO syncWithExposure:sync completion:block];
}

#pragma mark continuous
- (BOOL)requestContinuousFocus:(CGRect)previewRect pointInRect:(CGPoint)point completion:(void (^)(void))block
{
    return [self requestFocus:previewRect pointInRect:point continuous:YES syncWithExposure:YES completion:block];
}

- (BOOL)requestContinuousFocus:(CGRect)previewRect pointInRect:(CGPoint)point syncWithExposure:(BOOL)sync completion:(void (^)(void))block{
    return [self requestFocus:previewRect pointInRect:point continuous:YES syncWithExposure:sync completion:block];
}

//FIXME: completion이 continuas 모드 때문에 들어오지 않음 (lensPosition base focusAdjusted와 관련 - 계속 timeout이 발생하는 이유)
- (BOOL)requestContinuousFocusWithCenter:(BOOL)syncWithExposure completion:(void (^)(void))block{
    return [self _requestFocus:DefaultCenterPointOfInterest continuous:YES syncWithExposure:syncWithExposure completion:block];
}

- (BOOL)requestFocus:(CGRect)previewRect pointInRect:(CGPoint)point continuous:(BOOL)continuous syncWithExposure:(BOOL)sync completion:(void (^)(void))block{
    CGPoint pointOfInterest = CGPointOfInterest(previewRect.size, point);

    oo([[[@"Request Focus" st_add:NSStringFromCGPoint(point)] st_add:@"->"] st_add:NSStringFromCGPoint(CGPointOfInterestInBound(previewRect.size,pointOfInterest))]);
    return [self _requestFocus:pointOfInterest continuous:continuous syncWithExposure:sync completion:block];
}

#pragma mark RequestFocus

- (BOOL)_requestFocus:(CGPoint)pointOfInterest continuous:(BOOL)continuous syncWithExposure:(BOOL)sync completion:(void (^)(void))block{
    if(_focusRequestLocked){
        return NO;
    }

    AVCaptureDevice *device = [self inputCamera];
    if(block){
        [self addOperationFocusCompletions:block];
    }

    AVCaptureFocusMode focusMode = continuous ? AVCaptureFocusModeContinuousAutoFocus : AVCaptureFocusModeAutoFocus;
    AVCaptureExposureMode exposureMode = continuous ? AVCaptureExposureModeContinuousAutoExposure : AVCaptureExposureModeAutoExpose;

    NSAssert(!continuous || (continuous && CGPointEqualToPoint(pointOfInterest,DefaultCenterPointOfInterest)),@"WARNING : use DefaultCenterPointOfInterest in continuous focus.");
    if(continuous && !CGPointEqualToPoint(pointOfInterest,DefaultCenterPointOfInterest)){
        oo(@"[!] WARNING : use DefaultCenterPointOfInterest in continuous focus.");
    }

    NSError *error;
    if ([device lockForConfiguration:&error]) {

        if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode]) {
            if(AVCaptureFocusModeContinuousAutoFocus==device.focusMode){
                //at the continuousMode, no needed perform same focus point
                if(!CGPointEqualToPoint(device.focusPointOfInterest, pointOfInterest)){
                    [device setFocusPointOfInterest:pointOfInterest];
                    [device setFocusMode:focusMode];
                }
            }else{
                [device setFocusPointOfInterest:pointOfInterest];
                [device setFocusMode:focusMode];
            }
        }

        if (sync && [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode]) {
            if(AVCaptureExposureModeContinuousAutoExposure!=exposureMode){
                _exposureAdjusted = NO;
            }
            [device setExposurePointOfInterest:pointOfInterest];
            [device setExposureMode:exposureMode];
        }

        [device unlockForConfiguration];

//        //NSLog(@" - REQUEST %@FOCUS %@- ", continuous ? @"C-" : @"" , sync ? @"SYNC WITH FOCUS" : @"");
        return YES;

    } else {
//        //NSLog(@"ERROR when FOCUS -- %@", [error description]);
    }

    return NO;
}

- (void)lockRequestFocus
{
    if(_focusRequestLocked){
        return;
    }
    _focusRequestLocked = YES;
}

- (void)lockRequestFocusAndUnlockAfterTime:(NSTimeInterval) seconds
{
    if(_focusRequestLocked){
        return;
    }
    [self lockRequestFocus];
    [self performSelector:@selector(unlockRequestFocus) withObject:nil afterDelay:seconds];
}

- (void)unlockRequestFocus
{
    if(!_focusRequestLocked){
        return;
    }
    _focusRequestLocked = NO;
}

#pragma mark Exposure
- (BOOL)requestExposureToVirtualCenterFace:(BOOL)continuous completion:(void (^)(void))block{
    CGRect totalBound = [self preferredOutputScreenRect];
    CGFloat virtualFaceFrameWidth = totalBound.size.width/3.5f;
    CGRect virtualFaceFrame = CGRectInset(CGRectMake(CGRectGetMid_AGK(totalBound).x, CGRectGetMid_AGK(totalBound).y, 0, 0), -virtualFaceFrameWidth/2, -virtualFaceFrameWidth/2);
    CGPoint virtualFacePoint = CGRectGetMid_AGK(virtualFaceFrame);
    return [self requestExposureToFace:totalBound faceFrame:virtualFaceFrame facePoint:virtualFacePoint continuous:continuous completion:block];
}

- (BOOL)requestExposureToFace:(CGRect)previewRect faceFrame:(CGRect)faceRect facePoint:(CGPoint)facePoint continuous:(BOOL)continuous completion:(void (^)(void))block{
    return [self requestExposure:previewRect pointInRect:[self calculateChestPointFromFace:facePoint faceFrame:faceRect inBounds:previewRect] continuous:continuous completion:block];
}

- (BOOL)requestExposure:(CGRect)previewRect pointInRect:(CGPoint)point continuous:(BOOL)continuous completion:(void (^)(void))block{
    CGPoint pointOfInterest = CGPointOfInterest(previewRect.size, point);

    oo([[[@"Request Exposure" st_add:NSStringFromCGPoint(point)] st_add:@"->"] st_add:NSStringFromCGPoint(CGPointOfInterestInBound(previewRect.size,pointOfInterest))]);
    return [self _requestExposure:pointOfInterest continuous:continuous completion:block];
}

- (BOOL)_requestExposure:(CGPoint)pointOfInterest continuous:(BOOL)continuous completion:(void (^)(void))block{
    if(_exposureRequestLocked){
        return NO;
    }

    exposureDidAdjustedBlock = block;

    AVCaptureExposureMode exposureMode = continuous ? AVCaptureExposureModeContinuousAutoExposure : AVCaptureExposureModeAutoExpose;

    NSAssert(!continuous || (continuous && CGPointEqualToPoint(pointOfInterest,DefaultCenterPointOfInterest)),@"WARNING : use DefaultCenterPointOfInterest in continuous exposure.");
    if(continuous && !CGPointEqualToPoint(pointOfInterest,DefaultCenterPointOfInterest)){
        oo(@"[!] WARNING : use DefaultCenterPointOfInterest in continuous exposure.");
    }

    AVCaptureDevice *device = [self inputCamera];
    if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            if(AVCaptureExposureModeContinuousAutoExposure!=exposureMode){
                _exposureAdjusted = NO;
            }
            [device setExposurePointOfInterest:pointOfInterest];
            [device setExposureMode:exposureMode];
            [device unlockForConfiguration];
            //NSLog(@" - REQUEST EXPOSURE - %d %d %d %d", [device isExposurePointOfInterestSupported], [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure], [device isExposureModeSupported:AVCaptureExposureModeLocked], [device isExposureModeSupported:AVCaptureExposureModeAutoExpose]);
            return YES;

        } else {
            //NSLog(@"ERROR when EXPOSURE -- %@", [error description]);
        }
    }
    return NO;
}

- (void)lockRequestExposure
{
    if(_exposureRequestLocked){
        return;
    }
    _exposureRequestLocked = YES;
}

- (void)lockRequestExposureAndUnlockAfterTime:(NSTimeInterval) seconds
{
    if(_exposureRequestLocked){
        return;
    }
    [self lockRequestExposure];
    [self st_performOnceAfterDelay:seconds block:^{
        [self unlockRequestExposure];
    }];
}

- (void)unlockRequestExposure
{
    if(!_exposureRequestLocked){
        return;
    }
    _exposureRequestLocked = NO;
}

#pragma mark Physical Exposure Lock
static AVCaptureExposureMode _exposureModeBeforeLocked = AVCaptureExposureModeLocked;
- (void)lockExposure{
    AVCaptureDevice *device = [self inputCamera];
    _exposureModeBeforeLocked = device.exposureMode;
    if ([device lockForConfiguration:NULL]) {
        [device setExposureMode:AVCaptureExposureModeLocked];
        [device unlockForConfiguration];
    }
}

- (void)unlockExposure{
    AVCaptureDevice *device = [self inputCamera];
    BOOL previousLocked = device.exposureMode==AVCaptureExposureModeLocked && _exposureModeBeforeLocked != AVCaptureExposureModeLocked;
    NSAssert(previousLocked, @"Invaild called unlockExposure");

    if (previousLocked && [device lockForConfiguration:NULL]) {
        [device setExposureMode:_exposureModeBeforeLocked];
        [device unlockForConfiguration];
    }
}

- (CGPoint)calculateChestPointFromFace:(CGPoint)facePoint faceFrame:(CGRect)faceFrame inBounds:(CGRect)bounds{
    //define
    UIInterfaceOrientation currentOrientation = [STMotionManager sharedManager].interfaceOrientation;
    CGPoint focusPointHeadBottomToBody = facePoint;
    CGFloat totalLengthVertical = UIInterfaceOrientationIsPortrait(currentOrientation) ? bounds.size.height : bounds.size.width;
    CGFloat faceLengthVertical = UIInterfaceOrientationIsPortrait(currentOrientation) ? faceFrame.size.height : faceFrame.size.width;

    //calc focus point ~ bottom
    CGFloat perToHeadToTotalLength = 1.5f;
    CGFloat addedLengthHeadToTotalLength = 0;
    CGFloat addedLengthHeadToFaceBottomWeight = faceLengthVertical * 2;

    switch (currentOrientation){
        case UIInterfaceOrientationUnknown:
            break;
        case UIInterfaceOrientationPortrait:
            addedLengthHeadToTotalLength = totalLengthVertical - facePoint.y;
            addedLengthHeadToTotalLength /= perToHeadToTotalLength;

            focusPointHeadBottomToBody = CGPointMake(facePoint.x, CLAMP(facePoint.y+ addedLengthHeadToTotalLength, 0, totalLengthVertical));
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            addedLengthHeadToTotalLength = facePoint.y;
            addedLengthHeadToTotalLength /= perToHeadToTotalLength;

            focusPointHeadBottomToBody = CGPointMake(facePoint.x, CLAMP(facePoint.y- addedLengthHeadToTotalLength, 0, totalLengthVertical));
            break;
        case UIInterfaceOrientationLandscapeLeft:
            addedLengthHeadToTotalLength = facePoint.x;
            addedLengthHeadToTotalLength /= perToHeadToTotalLength;

            focusPointHeadBottomToBody = CGPointMake(CLAMP(facePoint.x- addedLengthHeadToTotalLength, 0, totalLengthVertical), facePoint.y);
            break;
        case UIInterfaceOrientationLandscapeRight:
            addedLengthHeadToTotalLength = totalLengthVertical - facePoint.x;
            addedLengthHeadToTotalLength /= perToHeadToTotalLength;

            focusPointHeadBottomToBody = CGPointMake(CLAMP(facePoint.x+ addedLengthHeadToTotalLength, 0, totalLengthVertical), facePoint.y);
            break;
    }

    return focusPointHeadBottomToBody;
}

#pragma mark Bias
- (void)setExposureBias:(CGFloat)exposureBias; {
    exposureBias = CLAMP(exposureBias, [self minAdjustingExposureBias], [self maxAdjustingExposureBias]);

    NSError *error = nil;
    AVCaptureDevice *device = [self inputCamera];
    if ([device lockForConfiguration:&error]){
        [device setExposureTargetBias:exposureBias completionHandler:nil];
        [device unlockForConfiguration];
    }else{
    }
}

- (CGFloat)exposureBias; {
    return [self inputCamera].exposureTargetBias;
}

- (CGFloat)minAdjustingExposureBias; {
    return -6;
}

- (CGFloat)maxAdjustingExposureBias; {
    return 4;
}

- (void) setFlashMode:(AVCaptureFlashMode) mode{

    if (self.inputCamera.hasFlash && [self.inputCamera isFlashModeSupported:mode]) {
        [self.inputCamera lockForConfiguration:nil];
        [self.inputCamera setFlashMode:mode];
        [self.inputCamera unlockForConfiguration];
    }
}

- (void)setZoomFactor:(CGFloat)factor; {
    if (factor >= 1.0 && self.maxZoomFactor >=factor && self.inputCamera.activeFormat.videoMaxZoomFactor >= factor) {
        if ([self.inputCamera lockForConfiguration:nil]) {
            self.inputCamera.videoZoomFactor = factor;
            [self.inputCamera unlockForConfiguration];
        }
    }
}

- (void)setZoomFactorSmoothly:(CGFloat)factor; {
    CGFloat zoomRate = 7.0f;

//    [self st_basic:@keypath(self.zoomFactor) value:factor duration:.5];
    if (factor >= 1.0 && self.maxZoomFactor >=factor && self.inputCamera.activeFormat.videoMaxZoomFactor >= factor) {
        if ([self.inputCamera lockForConfiguration:nil]) {
            [self.inputCamera rampToVideoZoomFactor:factor withRate:zoomRate];
            [self.inputCamera unlockForConfiguration];
        }
    }
}

- (CGFloat)zoomFactor; {
    return self.inputCamera.videoZoomFactor;
}

- (CGFloat)zoomFactorNormalized {
    return (self.zoomFactor-1.f)/(self.maxZoomFactor-1.f);
}

- (CGFloat)maxZoomFactor; {
    return 10;//self.inputCamera.activeFormat.videoMaxZoomFactor;
}

- (void)setupCornerDetectionFilter:(CGRect) cameraFrame
{

    GPUImageNobleCornerDetectionFilter *cornerFilter = [[GPUImageNobleCornerDetectionFilter alloc] init];
    [cornerFilter setThreshold:0.15];

    GPUImageGammaFilter *gammaFilter = [[GPUImageGammaFilter alloc] init];

    GPUImageCrosshairGenerator *crosshairGenerator = [[GPUImageCrosshairGenerator alloc] init];
    crosshairGenerator.crosshairWidth = 15.0;
    [crosshairGenerator forceProcessingAtSize:cameraFrame.size];

    [cornerFilter setCornersDetectedBlock:^(GLfloat *cornerArray, NSUInteger cornersDetected, CMTime frameTime) {
        [crosshairGenerator renderCrosshairsFromArray:cornerArray count:cornersDetected frameTime:frameTime];
    }];

    GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    [blendFilter forceProcessingAtSize:cameraFrame.size];

    [gammaFilter addTarget:blendFilter];
    [crosshairGenerator addTarget:blendFilter];
    [blendFilter addTarget:(GPUImageView *)[[self targets] bk_match:^BOOL(id obj) {
        return [obj isKindOfClass:[GPUImageView class]];
    }]];

    [self addTarget:cornerFilter];
    [self addTarget:gammaFilter];
}

#pragma mark Measure Image From Current FrameBuffer
CGFloat const CaptureOutputPixelSizeConstFullDimension = 4032.5; // 4032를 넣을 경우 실제 이미지는 4031로 나옴.
CGFloat const CaptureOutputPixelSizeConstOptimalFullScreen = 1440;
CGFloat const CaptureOutputPixelSizeConstSmallPreview = 800;

- (UIImage *)currentImage{
    return [self currentImage:nil];
}

- (UIImage *)currentImage:(GPUImageOutput <GPUImageInput> *)needsOutput{
    return [self currentImage:needsOutput maxSideOutputPixelSize:CaptureOutputPixelSizeConstOptimalFullScreen];
}

- (UIImage *)currentImage:(GPUImageOutput <GPUImageInput> *)needsOutput maxSideOutputPixelSize:(CGFloat)maxSidePixelSizeOfOutput{
    return [self currentImage:needsOutput maxSideOutputPixelSize:maxSidePixelSizeOfOutput cropRegion:CGRectNull];
}

- (UIImage *)currentImage:(GPUImageOutput <GPUImageInput> *)needsOutput maxSideOutputPixelSize:(CGFloat)maxSidePixelSizeOfOutput cropRegion:(CGRect)cropRegion{
    @synchronized (self) {
        UIImage * image = nil;
        if(self.targets.count){
            //FIXME: needsOutput에 다중 필터가 들어올 수 없음 -> 이것도 언제 정리.
            GPUImageOutput<GPUImageInput> *imageOutput = !needsOutput ? nil : [[self.targets reverse] bk_match:^BOOL(id obj) {
                return [obj isKindOfClass:GPUImageOutput.class]
                        && [obj conformsToProtocol:@protocol(GPUImageInput)]
                        && [obj isEqual:needsOutput];
            }];

            UIImageOrientation currentOutputImageOrientation = [self imageOrientationFromCurrentOutputOrientation];

            //measure max output size
            CGSize maxOutputSizeRespectingAspectRatio = CGSizeZero;
            switch (currentOutputImageOrientation){
                case UIImageOrientationUp:
                case UIImageOrientationDown:
                case UIImageOrientationUpMirrored:
                case UIImageOrientationDownMirrored:
                    maxOutputSizeRespectingAspectRatio = CGSizeMake(maxSidePixelSizeOfOutput/self.preferredOutputVerticalRatio, maxSidePixelSizeOfOutput);
                    break;
                case UIImageOrientationLeft:
                case UIImageOrientationRight:
                case UIImageOrientationLeftMirrored:
                case UIImageOrientationRightMirrored:
                    maxOutputSizeRespectingAspectRatio = CGSizeMake(maxSidePixelSizeOfOutput, maxSidePixelSizeOfOutput/self.preferredOutputVerticalRatio);
                    break;
            }

            if(imageOutput){
                //crop
                if(!CGRectIsEmpty(cropRegion)){
                    GPUImageCropFilter * imageCropOutput = [[GPUImageCropFilter alloc] initWithCropRegion:cropRegion];
                    [imageOutput addTarget:imageCropOutput];
                    imageOutput = imageCropOutput;
                }

                [self _setMaxOutputFrameSize:imageOutput maxSizeRespectingAspectRatio:maxOutputSizeRespectingAspectRatio];

                [imageOutput useNextFrameForImageCapture];
                image = [imageOutput imageFromCurrentFramebufferWithOrientation:currentOutputImageOrientation];

                //reset size
                [self _setMaxOutputFrameSize:imageOutput maxSizeRespectingAspectRatio:CGSizeZero];

            }else{
                //insert -> get image -> remove
                GPUImageOutput <GPUImageInput> * targetOutput = needsOutput ?:[[GPUImageFilter alloc] init];

                //crop
                if(!CGRectIsEmpty(cropRegion)){
                    GPUImageCropFilter * imageCropOutput = [[GPUImageCropFilter alloc] initWithCropRegion:cropRegion];
                    [targetOutput addTarget:imageCropOutput];
                    targetOutput = imageCropOutput;
                }

                [self _setMaxOutputFrameSize:targetOutput maxSizeRespectingAspectRatio:maxOutputSizeRespectingAspectRatio];

                [targetOutput useNextFrameForImageCapture];
                [self addTarget:targetOutput];
                image = [targetOutput imageFromCurrentFramebufferWithOrientation:currentOutputImageOrientation];
                [self removeTarget:targetOutput];

                //reset size
                [self _setMaxOutputFrameSize:targetOutput maxSizeRespectingAspectRatio:CGSizeZero];
            }
        }
        return image;
    }
}

- (void)_setMaxOutputFrameSize:(GPUImageOutput <GPUImageInput> *)targetOutput maxSizeRespectingAspectRatio:(CGSize)size{
    if([targetOutput isKindOfClass:GPUImageFilterGroup.class]){
        [((GPUImageFilterGroup *)targetOutput).terminalFilter forceProcessingAtSizeRespectingAspectRatio:size];
    }else{
        [targetOutput forceProcessingAtSizeRespectingAspectRatio:size];
    }
}

#pragma mark TorchLight
- (void)setTorchLight:(float)torchLight{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device isTorchAvailable] && [device isTorchModeSupported:AVCaptureTorchModeOn]) {
        _torchLight = MIN(AVCaptureMaxAvailableTorchLevel, MAX(0, torchLight));

        [device lockForConfiguration:nil];
        if (_torchLight==0) {
            [device setTorchMode:AVCaptureTorchModeOff];
        } else {
            [device setTorchMode:AVCaptureTorchModeOn];
            [device setTorchModeOnWithLevel:_torchLight error:nil];
        }
        [device unlockForConfiguration];
    }else{
        _torchLight = 0;
    }
}

#pragma mark Orientation
- (NSInteger)exifOrientation
{
    UIDeviceOrientation deviceOrientation = [STMotionManager sharedManager].deviceOrientation;
    NSInteger exifOrientation;

    enum {
        PHOTOS_EXIF_0ROW_TOP_0COL_LEFT          = 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
        PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT         = 2, //   2  =  0th row is at the top, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
        PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
        PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
    };

    BOOL isUsingFrontFacingCamera = FALSE;
    AVCaptureDevicePosition currentCameraPosition = [self cameraPosition];

    if (currentCameraPosition != AVCaptureDevicePositionBack) {
        isUsingFrontFacingCamera = TRUE;
    }

    switch (deviceOrientation) {
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
            break;

        case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
            if (isUsingFrontFacingCamera) {
                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            } else {
                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            }
            break;

        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            if (isUsingFrontFacingCamera) {
                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            } else {
                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            }
            break;

        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
        default:
            exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
            break;
    }

    return exifOrientation;
}
@end