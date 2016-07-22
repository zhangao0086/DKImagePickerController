//
// Created by BLACKGENE on 2015. 11. 19..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import "STCapturedImageProcessor.h"
#import "STOrientationItem.h"
#import "STCaptureRequest.h"
#import "M13OrderedDictionary.h"
#import "NSNotificationCenter+STFXNotificationsShortHand.h"
#import "NSString+STUtil.h"
#import "FCFileManager.h"
#import "FCFileManager+STUtil.h"
#import "STFilterManager.h"
#import "STCapturedImage.h"
#import "NSObject+STThreadUtil.h"
#import "STQueueManager.h"
#import "STFilter.h"
#import "STCaptureResponse.h"
#import "STCapturedImageSet.h"

@interface STCapturedImageProcessor ()
@property(nonatomic, strong) DirectoryWatcher *watcher;
@property(nonatomic, strong) TABFileMonitor *watcher2;
@property(atomic, strong) M13MutableOrderedDictionary *requestsQueue;
@property(atomic, strong) NSMutableSet *processingRequests;
@property(atomic, assign) BOOL receivedMemoryWarning;
@end

@implementation STCapturedImageProcessor

static NSString * const PREFIX_CAPTURED_FILE = @"elie_captured_temp";
static NSUInteger const MAX_CONCURRENT_PROCESSING_COUNT = 3;

static NSTimeInterval const DELAY_FOR_PROCESSING_DEFAULT = .5;
static NSTimeInterval const DELAY_FOR_PROCESSING_HIGH = .2;
static NSTimeInterval const DELAY_FOR_PROCESSING_LOW = 1.5;
static NSTimeInterval const DELAY_FOR_PROCESSING_IDLE = 3;

static NSString * TEMP_PATH_CAPTURED_FILE;

+ (STCapturedImageProcessor *)sharedProcessor {
    static STCapturedImageProcessor *_instance = nil;
    BlockOnce(^{
        _instance = [[self alloc] init];
        TEMP_PATH_CAPTURED_FILE = NSTemporaryDirectory();
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestsQueue = [M13MutableOrderedDictionary orderedDictionary];
        self.processingRequests = [NSMutableSet set];

        [[NSNotificationCenter defaultCenter] st_addObserverWithMainQueue:self forName:UIApplicationDidReceiveMemoryWarningNotification usingBlock:^(NSNotification *note, id observer) {
            @synchronized (observer) {
                ((STCapturedImageProcessor *)observer).receivedMemoryWarning = YES;
            }
        }];

        [[NSNotificationCenter defaultCenter] st_addObserverWithMainQueue:self forName:UIApplicationDidEnterBackgroundNotification usingBlock:^(NSNotification *note, id observer) {
            @synchronized (observer) {
                ((STCapturedImageProcessor *)observer).receivedMemoryWarning = NO;
            }
        }];

        [[NSNotificationCenter defaultCenter] st_addObserverWithMainQueue:self forName:UIApplicationWillResignActiveNotification usingBlock:^(NSNotification *note, id observer) {
            @synchronized (observer) {
                ((STCapturedImageProcessor *)observer).receivedMemoryWarning = NO;
            }
        }];
    }
    return self;
}

#pragma mark defines
- (NSString *)pathForTempImageFileWith:(STCaptureRequest *)request {
    return [[self URLForTempImageFile:request.uid] path];
}

- (NSURL *)URLForTempImageFileWith:(STCaptureRequest *)request {
    return [self URLForTempImageFile:request.uid];
}

- (NSURL *)URLForTempImageFile:(NSString *)id{
    return [[NSURL fileURLWithPath:[TEMP_PATH_CAPTURED_FILE stringByAppendingPathComponent:[PREFIX_CAPTURED_FILE st_add:id]]] URLByAppendingPathExtension:@"jpg"];
}

- (void)clean {
    @synchronized (self) {
        [self.requestsQueue removeAllObjects];

        @try {
            [FCFileManager removeFilesInDirectoryAtPath:TEMP_PATH_CAPTURED_FILE withFilePrefix:PREFIX_CAPTURED_FILE];
        }@finally {}
    }
}

#pragma mark watch files
- (void)fileMonitor:(TABFileMonitor *)fileMonitor didSeeChange:(TABFileMonitorChangeType)changeType {
    [self didWatchingTargetChanged];
}

- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher {
    [self didWatchingTargetChanged];
}

- (void)startWatching{
    @synchronized (self) {
        if(!self.watcher){
            self.watcher = [DirectoryWatcher watchFolderWithPath:TEMP_PATH_CAPTURED_FILE delegate:self];
        }
        _watchingStarted = self.watcher != nil;

        //성능은 비슷비슷 한듯..
//        self.watcher2 = [[TABFileMonitor alloc] initWithURL:[NSURL fileURLWithPath:TEMP_PATH_CAPTURED_FILE isDirectory:YES]];
//        self.watcher2.delegate = self;
//        _watchingStarted = YES;
    }
}

- (void)stopWatching{
    @synchronized (self) {
        [self clean];

        if(_watchingStarted){
            self.watcher = nil;
            _watchingStarted = NO;
        }
    }
}

- (void)didWatchingTargetChanged{
    [self receivingProcessingRequest];
}

#pragma mark processing
- (BOOL)processing {
    @synchronized (self) {
        return self.processingRequests.count >= MAX_CONCURRENT_PROCESSING_COUNT;
    }
}

- (void)requestData:(NSData *)capturedImageData request:(STCaptureRequest *)request{
    @synchronized (self) {
        NSString * path = [self pathForTempImageFileWith:request];

        [self.requestsQueue addObject:request pairedWithKey:path];

        if(![[NSFileManager defaultManager] createFileAtPath:path contents:capturedImageData attributes:nil]){
            [self.requestsQueue removeObjectForKey:path];
        }

        /*TODO:
         * 여기서 들어오는 rate를 보고 딜레이를 최적화해도 좋을듯,
         * 빨리 들어올수록 넓은 간격 늦게 들어올수록 좁은 간격 (일정 임계치 이하인 경우 0에 수렴)
         */
    }
}

- (void)receivingProcessingRequest {
    @synchronized (self) {
        if(self.requestsQueue.count==0){
            return;
        }

        if(self.processing){
            return;
        }

        Weaks
        for(NSString * path in [self.requestsQueue reverseKeyEnumerator]){
            //if already processing, pass.
            if([self.processingRequests containsObject:path]){
                continue;
            }

            //check file exist
            if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                continue;
            }

            //add job
            [self addProcessingJob:path request:self.requestsQueue[path]];

            //remove request from queue
            [self.requestsQueue removeObjectForKey:path];
        }
    }
}

// NSData * readedData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:NULL];
- (void)addProcessingJob:(NSString *)path request:(STCaptureRequest *)request {
    @synchronized (self) {
        [self.processingRequests addObject:path];
    }

    //get delay
    NSTimeInterval delayForProcessing = DELAY_FOR_PROCESSING_DEFAULT;
    switch(request.afterCaptureProcessingPriority){
        case AfterCaptureProcessingPriorityIdle:
            delayForProcessing = DELAY_FOR_PROCESSING_IDLE;
            break;
        case AfterCaptureProcessingPriorityLow:
            delayForProcessing = DELAY_FOR_PROCESSING_LOW;
            break;
        case AfterCaptureProcessingPriorityHigh:
            delayForProcessing = DELAY_FOR_PROCESSING_HIGH;
            break;
        case AfterCaptureProcessingPriorityFirst:
            delayForProcessing = 0;
            break;
        default:
            break;
    }

    Weaks
    void(^capture_processing_block)(void) = ^(void){
        @autoreleasepool {
            //FIXME: [FCFileManager metadataOfImageAtPath:path];  exifDataOfImageAtPath 는 'metadata'가 아니라 하위 엘레먼트이다.(지금까지 exif가 안들어가고 있었음)
            NSDictionary * metadata = [FCFileManager metadataOfImageAtPath:path];
            STCaptureResponse * result = [Wself processImage:[FCFileManager readFileAtPathAsImage:path] data:[metadata mutableCopy] param:request];

            [Wself st_runAsMainQueueAsync:^{
                Strongs
                @synchronized (Sself) {
                    [result response];

                    [Sself.processingRequests removeObject:path];
                }
            }];
        }
    };

    if(delayForProcessing==0){
        dispatch_async([STQueueManager sharedQueue].afterCaptureProcessing, capture_processing_block);
    }else{
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delayForProcessing * NSEC_PER_SEC));
        dispatch_after(delay, [STQueueManager sharedQueue].afterCaptureProcessing, capture_processing_block);
    }
}

- (STCaptureResponse *)processImage:(UIImage *)inputImage data:(NSMutableDictionary *)metaData param:(STCaptureRequest *)request {
    @autoreleasepool {
        /*
         * Make Metadata
         */
        //put geo
        if(request.geoTagMedataData){
            [metaData addEntriesFromDictionary:request.geoTagMedataData];
        }

        /*
         * resolve Orientation
         */
        UIImage * resultImage = [UIImage imageWithCGImage:inputImage.CGImage scale:inputImage.scale orientation: UIImageOrientationUp];
        UIInterfaceOrientation const orientation = request.needsOrientationItem.interfaceOrientation;
        CGSize const orientationalImageSize = UIInterfaceOrientationIsLandscape(orientation) ? resultImage.size : CGSizeSwitchAxis_AGK(resultImage.size);

        //metaData - clear exif orientation
        [metaData removeObjectForKey:(__bridge NSString *) kCGImagePropertyOrientation];
        if(!metaData[(__bridge NSString *) kCGImagePropertyOrientation]){
            //metaData - clear tiff orientation
            [metaData[(__bridge NSString *) kCGImagePropertyTIFFDictionary] removeObjectForKey:(__bridge NSString *)kCGImagePropertyTIFFOrientation];
            //metaData - resolve width/height
            metaData[(__bridge NSString *) kCGImagePropertyPixelWidth] = [@(orientationalImageSize.width) stringValue];
            metaData[(__bridge NSString *) kCGImagePropertyPixelHeight] = [@(orientationalImageSize.height) stringValue];
            //metaData - resolve width/height - exif
            metaData[(__bridge NSString *) kCGImagePropertyExifDictionary][(__bridge NSString *) kCGImagePropertyExifPixelXDimension] = [@(orientationalImageSize.width) stringValue];
            metaData[(__bridge NSString *) kCGImagePropertyExifDictionary][(__bridge NSString *) kCGImagePropertyExifPixelYDimension] = [@(orientationalImageSize.height) stringValue];
            //metaData - resolve width/height - exifAux
            metaData[(__bridge NSString *) kCGImagePropertyExifAuxDictionary][@"Regions"][@"WidthAppliedTo"] = [@(orientationalImageSize.width) stringValue];
            metaData[(__bridge NSString *) kCGImagePropertyExifAuxDictionary][@"Regions"][@"HeightAppliedTo"] = [@(orientationalImageSize.height) stringValue];
        }

        //metaData - clear MakerApple
        [metaData removeObjectForKey:(__bridge NSString *) kCGImagePropertyMakerAppleDictionary];

        /*
         * metaData - clear privacy data if needed
         */
        //TODO - exif 정보 보안 모드
        if(request.privacyRestriction){
            //exif AUX - Face
            [metaData removeObjectForKey:(__bridge NSString *) kCGImagePropertyExifAuxDictionary];
            //exif - lens
            [metaData[(__bridge NSString *) kCGImagePropertyExifDictionary] removeObjectForKey:(__bridge NSString *) kCGImagePropertyExifLensMake];
            [metaData[(__bridge NSString *) kCGImagePropertyExifDictionary] removeObjectForKey:(__bridge NSString *) kCGImagePropertyExifLensModel];
            [metaData[(__bridge NSString *) kCGImagePropertyExifDictionary] removeObjectForKey:(__bridge NSString *) kCGImagePropertyExifLensSerialNumber];
            [metaData[(__bridge NSString *) kCGImagePropertyExifDictionary] removeObjectForKey:(__bridge NSString *) kCGImagePropertyExifLensSpecification];
            //exif - date
            [metaData[(__bridge NSString *) kCGImagePropertyExifDictionary] removeObjectForKey:(__bridge NSString *) kCGImagePropertyExifDateTimeDigitized];
            [metaData[(__bridge NSString *) kCGImagePropertyExifDictionary] removeObjectForKey:(__bridge NSString *) kCGImagePropertyExifDateTimeOriginal];
            [metaData[(__bridge NSString *) kCGImagePropertyExifDictionary] removeObjectForKey:(__bridge NSString *) kCGImagePropertyExifCameraOwnerName];
            [metaData[(__bridge NSString *) kCGImagePropertyExifDictionary] removeObjectForKey:(__bridge NSString *) kCGImagePropertyExifMakerNote];
        }

        //resolve GPUImageRotation
        STFilter *keyFiler = [request.needsFilter isKindOfClass:STFilter.class] ? (STFilter *)request.needsFilter : [[STFilter alloc] initWithFilters:@[request.needsFilter]];

        [keyFiler setInputRotation:[[STElieCamera sharedInstance] GPUImageInputRotation:request.needsOrientationItem.interfaceOrientation] atIndex:0];

        /*
         * Get Build Config
         */
        //enhance
        BOOL enhance = request.autoEnhanceEnabled;

        //extended
        NSMutableArray * extendedFilters = [NSMutableArray array];

        //tiltShift
        BOOL tiltShift = NO;
        if(request){
            //VDOF
            tiltShift = request.tiltShiftEnabled
                    && !CGRectIsEmpty(request.faceRect)
                    && !CGRectIsEmpty(request.faceRectBounds);

            if(tiltShift){

                CGSize faceRectBoundSize = request.faceRectBounds.size;
                CGRect faceRect = request.faceRect;

                //resolve orientation
                faceRect = CGRectResolveOrientation(faceRect, orientation, faceRectBoundSize.width, faceRectBoundSize.height);
                //normalization
                CGSize orientationalBoundsSize = UIInterfaceOrientationIsLandscape(orientation) ? CGSizeSwitchAxis_AGK(faceRectBoundSize) : faceRectBoundSize;
                faceRect = CGRectApplyAffineTransform(faceRect, CGAffineTransformMakeScale(1.0f / orientationalBoundsSize.width, 1.0f / orientationalBoundsSize.height));

                GPUImageFilterGroup * tiltShitFilter = [[STFilterManager sharedManager] tiltShiftFilterForFace:orientationalImageSize normalizedFaceRect:faceRect];
                [extendedFilters addObject:tiltShitFilter];
            }
        }

        /*
         * Should process with half
         */
        BOOL forceReduceScale = self.receivedMemoryWarning || (tiltShift && (STDeviceModelFamilyIPhone6s > [STApp deviceModelFamily]));

        /*
         * Process filter
         */
        //TODO: 임시로 한번 해봄
        //https://fabric.io/jessi/ios/apps/com.stells.eliew/issues/56d606a1f5d3a7f76b3ac63f
        @synchronized (self) {
            @autoreleasepool {
                resultImage = [[STFilterManager sharedManager]
                        buildOutputImage:resultImage
                                 enhance:enhance
                                  filter:keyFiler
                        extendingFilters:extendedFilters
                            rotationMode:kGPUImageNoRotation
                             outputScale:(CGFloat) (forceReduceScale ? .5 : 1)
                   useCurrentFrameBuffer:YES
                      lockFrameRendering:request.origin != STPhotoItemOriginManualCamera];
            }
        }

        BOOL success = resultImage && resultImage.size.width>0;

        NSAssert(success, @"[!!]CRITICAL: resultImage is nil while perform capturing");

        /*
         * Complete or Fail
         */
        STCaptureResponse * response = [STCaptureResponse responseWithRequest:request];
        response.imageSet = [STCapturedImageSet setWithImages:@[[STCapturedImage imageWithImage:resultImage]]];
        response.metaData = metaData;
        response.orientation = [STOrientationItem itemWith:request.needsOrientationItem.deviceOrientation
                                      interfaceOrientation:request.needsOrientationItem.interfaceOrientation
                                          imageOrientation:resultImage.imageOrientation];

        return !success ? nil : response;
    }
}






@end