//
//  SPFilterInfoManager.m
//  prism
//
//  Created by Hyojin Mo on 2014. 5. 14..
//  Copyright (c) 2014년 Starpret. All rights reserved.
//

#import <GPUImage/GPUImageOutput.h>
#import <GPUImage/GPUImageFilterGroup.h>
#import "STFilterManager.h"
#import "STFilterGroupItem.h"
#import "UIColor+STColorUtil.h"
#import "UIImage+STUtil.h"
#import "STAppSetting.h"
#import "BFAppLink.h"
#import "NSObject+STUtil.h"
#import "NSNotificationCenter+STFXNotificationsShortHand.h"
#import "NSArray+BlocksKit.h"
#import "NSArray+STUtil.h"
#import "NSString+STUtil.h"
#import "STGPUImageOutputComposeItem.h"
#import "M13OrderedDictionary.h"

@interface STFilterManager ()

@property (nonatomic, strong) NSArray *colorNameList;
@property (nonatomic, strong) NSMutableArray *cachedFilterList;

@end

@implementation STFilterManager {
    STFilterItem * _defaultEmptyFilteredItem;
};

+ (STFilterManager *)sharedManager
{
    static dispatch_once_t pred = 0;
    static STFilterManager *manager = nil;
    
    dispatch_once(&pred, ^{
        manager = [[STFilterManager alloc] init];
    });
    
    return manager;
}

#pragma mark - Public methods

- (void)loadFilterInfoWithCompletion:(void (^)(NSArray *filterInfoList))completion{
    NSArray * colorNameList = [self loadColorNames];
    NSArray * filterList = [self loadCLUTFilters];
    
    self.colorNameList = colorNameList;
    
    [self willChangeValueForKey:@keypath(self.filterGroups)];
    _filterGroups = filterList;
    [self didChangeValueForKey:@keypath(self.filterGroups)];
    
    if (completion) {
        completion(self.filterGroups);
    }
}

- (STFilterItem *)defaultFilterItem; {
    if(!_defaultEmptyFilteredItem){
        _defaultEmptyFilteredItem = [[STFilterItem alloc] init];
    }
    return _defaultEmptyFilteredItem;
}

static NSString * filterCacheKeyPrefix = @"elie.filter.";

- (STFilter *)acquire:(STFilterItem *)item{
    if(!item){
        item = self.defaultFilterItem;
    }

    NSMutableString * key = [filterCacheKeyPrefix mutableCopy];
    [key appendString:item.uid_short];

    STFilter * filter = [[STFilter allocWithZone:NULL] initWith:item];
//    return [self st_cachedObject:key init:^id {
    return filter;
//    }];
}

- (GPUImageOutput *)buildTerminalOutputToComposeMultiSource:(NSArray<STGPUImageOutputComposeItem *> *)items forInput:(id<GPUImageInput>)input{

    //init
    if (items.count) {
        for (STGPUImageOutputComposeItem *currentItem in items) {
            NSParameterAssert(currentItem.source);
            NSUInteger index = [items indexOfObject:currentItem];
            NSAssert(index>0 || !currentItem.composer,@"first item can't provide composer");
            STGPUImageOutputComposeItem *nextItem = [items st_objectOrNilAtIndex:index + 1];

            GPUImageTwoInputFilter * targetComposer = currentItem.composer ?: nextItem.composer;

            //insert blank filter if it hasn't
            if(!currentItem.filters.count){
                currentItem.filters = @[GPUImageFilter.new];
            }

            [self buildOutputChain:currentItem.source filters:currentItem.filters to:targetComposer enhance:NO];

            if (nextItem) {
                [currentItem.composer addTarget:nextItem.composer];

            } else {
                break;
            }
        }

        //process lastest blender
        STGPUImageOutputComposeItem *lastItem = [items lastObject];
        GPUImageOutput * terminalOutput = /*1*/lastItem.composer ?: /*2*/[[lastItem filters] lastObject];
        input ? [terminalOutput addTarget:input] : [terminalOutput useNextFrameForImageCapture];

        //process outputs
        for (STGPUImageOutputComposeItem *currentItem in [items reverse]) {
            if ([currentItem.source isKindOfClass:GPUImagePicture.class]) {
                [(GPUImagePicture *) currentItem.source processImage];
            }
            input?:[currentItem.source useNextFrameForImageCapture];
        }

        return terminalOutput;
    }

    return nil;
}


- (NSArray *)buildOutputChain:(GPUImageOutput *)sourceOutput filters:(NSArray *)filters to:(id <GPUImageInput>)inputTarget enhance:(BOOL)enhance{
    @synchronized (self) {
        if(!sourceOutput){
            return @[];
        }

        NSMutableArray * chain = [ (enhance ? @[sourceOutput, self.enhanceFilter] : @[sourceOutput] ) mutableCopy];
        if(filters.count){
            [chain addObjectsFromArray:filters];
        }

        /*
         * result to input
         */
        if(inputTarget){
            [chain addObject:inputTarget];
        }

        if(chain.count == 1){
            return nil;
        }else{
            [chain eachWithIndex:^(id object, NSUInteger index) {
                NSParameterAssert(object);

                NSUInteger nextIndex = index + 1;
                if (nextIndex == chain.count) {

                } else {
                    id addingTarget = chain[nextIndex];
                    NSAssert([[addingTarget class] conformsToProtocol:@protocol(GPUImageInput)], @"type must being conformsToProtocol : GPUImageOutput <GPUImageInput>");

                    [object addTarget:addingTarget];
                }
            }];
        }
        return chain;
    }
}

- (void)clearOutputChain:(NSArray *)chain{
    @synchronized (self) {
        for(id object in chain){
            NSParameterAssert(object);

            NSUInteger index = [chain indexOfObject:object];
            NSUInteger nextIndex = index + 1;
            if (nextIndex == chain.count) {

            } else {
                id addingTarget = chain[nextIndex];
                NSAssert([[addingTarget class] conformsToProtocol:@protocol(GPUImageInput)], @"type must being conformsToProtocol : GPUImageOutput <GPUImageInput>");

                [object removeTarget:addingTarget];
            }
        }
    }
}

#pragma mark buildImage
- (UIImage *)buildOutputImageFromItem:(UIImage *)image item:(STFilterItem *)item enhance:(BOOL)enhance{
    return [self buildOutputImage:image enhance:enhance filter:[self acquire:item] extendingFilters:nil];
}

- (UIImage *)buildOutputImage:(UIImage *)image enhance:(BOOL)enhance filter:(STFilter *)currentFilter extendingFilters:(NSArray *)extendingFilters{
    return [self buildOutputImage:image enhance:enhance filter:currentFilter extendingFilters:extendingFilters rotationMode:kGPUImageNoRotation];
}

- (UIImage *)buildOutputImage:(UIImage *)image enhance:(BOOL)enhance filter:(STFilter *)currentFilter extendingFilters:(NSArray *)extendingFilters rotationMode:(GPUImageRotationMode)rotationMode{
    return [self buildOutputImage:image enhance:enhance filter:currentFilter extendingFilters:extendingFilters rotationMode:rotationMode outputScale:1];
}

- (UIImage *)buildOutputImage:(UIImage *)image enhance:(BOOL)enhance filter:(STFilter *)currentFilter extendingFilters:(NSArray *)extendingFilters rotationMode:(GPUImageRotationMode)rotationMode outputScale:(CGFloat)outputScale {
    return [self buildOutputImage:image enhance:enhance filter:currentFilter extendingFilters:extendingFilters rotationMode:rotationMode outputScale:outputScale useCurrentFrameBuffer:NO];
}

- (UIImage *)buildOutputImage:(UIImage *)image enhance:(BOOL)enhance filter:(STFilter *)currentFilter extendingFilters:(NSArray *)extendingFilters rotationMode:(GPUImageRotationMode)rotationMode outputScale:(CGFloat)outputScale useCurrentFrameBuffer:(BOOL)useCurrentFrameBuffer {
    return [self buildOutputImage:image enhance:enhance filter:currentFilter extendingFilters:extendingFilters rotationMode:rotationMode outputScale:outputScale useCurrentFrameBuffer:useCurrentFrameBuffer lockFrameRendering:YES];
}

- (UIImage *)buildOutputImage:(UIImage *)image enhance:(BOOL)enhance filter:(STFilter *)currentFilter extendingFilters:(NSArray *)extendingFilters rotationMode:(GPUImageRotationMode)rotationMode outputScale:(CGFloat)outputScale useCurrentFrameBuffer:(BOOL)useCurrentFrameBuffer lockFrameRendering:(BOOL)lockFrameRendering {
    NSParameterAssert(image);

    UIImage * result = nil;
    NSMutableArray * filterChain = [NSMutableArray array];
    if(enhance){
        [filterChain addObject:self.enhanceFilter];
    }
    if(currentFilter){
        [filterChain addObject:currentFilter];
    }
    if(extendingFilters.count){
        [filterChain addObjectsFromArray:extendingFilters];
    }

    //early return if not needed to process
    if(filterChain.count==0){
        return image;
    }

    //lock frame rendering
    if(lockFrameRendering){
        [[STElieCamera sharedInstance] lockRendering];
    }

    STFilter * keyFilter = filterChain[0];

    //set rotation
    if(rotationMode != kGPUImageNoRotation){
        //Reported Crash: https://fabric.io/jessi/ios/apps/com.stells.elie/issues/56498b3ff5d3a7f76b9c69b2
        [keyFilter setInputRotation:rotationMode atIndex:0];
    }

    if(filterChain.count == 1){
        //process image
        result = [self _processImage:image terminalOutput:keyFilter outputScale:outputScale useCurrentFrameBuffer:useCurrentFrameBuffer];

    }else{

        [filterChain eachWithIndex:^(id object, NSUInteger index) {
            @autoreleasepool {
                NSParameterAssert(object);
                NSAssert([object isKindOfClass:GPUImageOutput.class], @"type must being subClass : GPUImageOutput <GPUImageInput>");

                NSUInteger nextIndex = index+1;
                if(nextIndex == filterChain.count){
                    [keyFilter setTerminalFilter:object];
                }else{
                    GPUImageOutput <GPUImageInput> * addingTarget = filterChain[nextIndex];
                    [addingTarget useNextFrameForImageCapture];
                    [object addTarget:addingTarget];
                }
            }
        }];

        //process image
        result = [self _processImage:image terminalOutput:keyFilter outputScale:outputScale useCurrentFrameBuffer:useCurrentFrameBuffer];

        //clear Terminal Filter at Last
        [filterChain removeLastObject];

        //clear Key Filter at 0
        [keyFilter clearChildFilters];
        [filterChain removeObject:keyFilter];

        //clear middle chained Filters And RemoveTargets
        [filterChain eachWithIndex:^(id object, NSUInteger index) {
            if([object targets].count){
                [object removeTarget:[object targets].last];
            }
        }];
    }

    //unlock frame rendering
    if(lockFrameRendering){
        [[STElieCamera sharedInstance] unlockRendering];
    }

    NSParameterAssert(result);
    return result;
}

- (UIImage *)_processImage:(UIImage *)inputImage terminalOutput:(GPUImageOutput<GPUImageInput> *)terminalOutput outputScale:(CGFloat)outputScale useCurrentFrameBuffer:(BOOL)useCurrentFrameBuffer{
    UIImage * resultImage = nil;

    if(useCurrentFrameBuffer){
        /*
         * FullSize Photo(38xx) 0.1~0.2s (3x-4x faster, but presented a problem that process fast by each images)
         */
        GPUImagePicture *source = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:NO];
        //connect terminal filter
        [source addTarget:terminalOutput];

        if(outputScale!=1){
            [terminalOutput forceProcessingAtSizeRespectingAspectRatio:CGSizeByScale(source.outputImageSize, outputScale)];
        }
        //get image
        [terminalOutput useNextFrameForImageCapture];

        //processing
        [source useNextFrameForImageCapture];
        [source processImage];

        resultImage = [terminalOutput imageFromCurrentFramebufferWithOrientation:inputImage.imageOrientation];

    }else{
        /*
         * FullSize Photo(38xx) 0.6~0.5s
         */
        if(outputScale!=1){
            [terminalOutput forceProcessingAtSizeRespectingAspectRatio:CGSizeByScale(inputImage.size, outputScale)];
        }

        resultImage = [terminalOutput imageByFilteringImage:inputImage];
    }

    NSParameterAssert(resultImage);
    return resultImage;
}

- (STFilter *)enhanceFilter{
//    return [self st_cachedObject:@"elie.filter.enhance" init:^id {
        return [[STFilter allocWithZone:NULL] initWithLookupImage:[UIImage imageBundledCache:@"lookup_enhance1.png"]];
//    }];
}

- (GPUImageFilterGroup *)tiltShiftFilterForFace:(CGSize)sourceImageSize normalizedFaceRect:(CGRect)faceRect{
    CGPoint point = CGRectGetMid_AGK(faceRect);

    CGFloat width = (CGFloat) fmax(faceRect.size.width, faceRect.size.height);
    GPUImageFilterGroup * filter = [self tiltShiftFilter:sourceImageSize location:point normalizedWidth:width];

    return filter;
}


- (GPUImageFilterGroup *)tiltShiftFilter:(CGSize)sourceImageSize location:(CGPoint)point normalizedWidth:(CGFloat)width {

    GPUImageGaussianSelectiveBlurFilter *filter = [[GPUImageGaussianSelectiveBlurFilter allocWithZone:NULL] init];

    CGFloat ratio = (CGFloat) (sourceImageSize.height / sourceImageSize.width);
    CGFloat extent = sourceImageSize.height * sourceImageSize.width;

    filter.excludeCirclePoint = CGPointEqualToPoint(CGPointZero, point) ? CGPointMake(.5, .5) : point;
    filter.excludeBlurSize = AGKRemap(width, 0, 1, .5f, .15f);
    filter.blurRadiusInPixels = AGKRemap(width, 0, 1, 0, AGKRemapAndClamp(extent,0,constantImageExtent,0, constantBlurRadiusInPixels));

    width += (filter.excludeBlurSize * AGKRemap(width, 0, 1, 1.8, 1.2));
    filter.excludeCircleRadius = (width*.5f);//(CGFloat) (width *.5f) + ((width *.5f)*.5f);

    filter.aspectRatio = 0.6;

    return filter;
}

//exclude entire vertical
- (GPUImageFilterGroup *)tiltShiftFilterStep1:(CGSize)sourceImageSize location:(CGPoint)point width:(CGFloat)width {

    //TODO: cache
    GPUImageGaussianSelectiveBlurFilter *filter = [[GPUImageGaussianSelectiveBlurFilter allocWithZone:NULL] init];
    CGFloat ratio = (CGFloat) (sourceImageSize.height / sourceImageSize.width);

    filter.excludeCirclePoint = CGPointEqualToPoint(CGPointZero, point) ? CGPointMake(.5, .5) : point;
    filter.excludeBlurSize = 0;

    width = width + ((1-width)*.5f);
    width += filter.excludeBlurSize;
    filter.excludeCircleRadius = width*.5f;//(CGFloat) (width *.5) + ((width *.5f)*1.5f);

    filter.aspectRatio = 0;

    filter.blurRadiusInPixels = 3;

    return filter;
}

static const CGFloat constantImageExtent = 7990272;//iphone6
static const CGFloat constantBlurRadiusInPixels = 40;

//blur as circle
- (GPUImageFilterGroup *)tiltShiftFilterStep2:(CGSize)sourceImageSize location:(CGPoint)point width:(CGFloat)width {

    GPUImageGaussianSelectiveBlurFilter *filter = [[GPUImageGaussianSelectiveBlurFilter allocWithZone:NULL] init];

    CGFloat ratio = (CGFloat) (sourceImageSize.height / sourceImageSize.width);
    CGFloat extent = sourceImageSize.height * sourceImageSize.width;

    filter.excludeCirclePoint = CGPointEqualToPoint(CGPointZero, point) ? CGPointMake(.5, .5) : point;
    filter.excludeBlurSize = AGKRemap(width, 0, 1, .5f, .15f);
    filter.blurRadiusInPixels = AGKRemap(width, 0, 1, 0, AGKRemapAndClamp(extent,0,constantImageExtent,0, constantBlurRadiusInPixels));

    width += (filter.excludeBlurSize * AGKRemap(width, 0, 1, 1.8, 1.2));
    filter.excludeCircleRadius = (width*.5f);//(CGFloat) (width *.5f) + ((width *.5f)*.5f);

    filter.aspectRatio = 0.6;
    return filter;
}


#pragma mark - Color data

- (NSArray *)loadColorNames
{
    NSString *nameOfColorFilePath = [[NSBundle mainBundle] pathForResource:@"color_names" ofType:@"json"];
    NSDictionary *nameOfColorMetaInfo = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:nameOfColorFilePath] options:NSJSONReadingMutableContainers error:nil];
    NSArray *colorNameMetaList = nameOfColorMetaInfo[@"names"];
    
    NSMutableArray *colorNameList = [NSMutableArray array];
    
    for (NSArray *colorMetaInfo in colorNameMetaList) {
        NSString *colorHexCode = [NSString stringWithFormat:@"#%@", colorMetaInfo[0]];
        NSDictionary *colorInfo = @{@"color": [UIColor colorWithRGBHexString:colorHexCode], @"name": colorMetaInfo[1]};
        [colorNameList addObject:colorInfo];
    }
    
    return colorNameList;
}

- (NSString *)colorNameWithColor:(UIColor *)color
{
    //http://www.color-blindness.com/color-name-hue/
    
    CGFloat r, g, b, h, s, v;
    [color getRed:&r green:&g blue:&b alpha:nil];
    [color getHue:&h saturation:&s brightness:&v alpha:nil];
    
    CGFloat ndf1 = 0, ndf2 = 0, ndf = 0, df = -1;
    NSInteger cl = -1;
    
    for (NSUInteger i = 0, l = [self.colorNameList count]; i < l; i++) {
        NSDictionary *colorInfo = self.colorNameList[i];
        UIColor *thisColor = colorInfo[@"color"];
        
        CGFloat thisR, thisG, thisB, thisH, thisS, thisV;
        
        [thisColor getRed:&thisR green:&thisG blue:&thisB alpha:nil];
        [thisColor getHue:&thisH saturation:&thisS brightness:&thisV alpha:nil];
        
        ndf1 = powf(r - thisR, 2.f) + powf(g - thisG, 2.f) + powf(b - thisB, 2.f);
        ndf2 = powf(h - thisH, 2.f) + powf(s - thisS, 2.f) + powf(v - thisV, 2.f);
        
        ndf = ndf1 + ndf2 * 2;
        
        if(df < 0 || df > ndf) {
            df = ndf;
            cl = i;
        }
    }
    
    NSString *name;
    if (cl < 0) {
        name = nil;
    }
    else {
        NSDictionary *colorInfo = self.colorNameList[cl];
        name = colorInfo[@"name"];
    }
    
    return name;
}

#pragma mark - Filter Data

- (NSArray *)loadCLUTFilters
{
    NSString *prismetaFilePath = [[NSBundle mainBundle] pathForResource:@"prismeta" ofType:@"json"];
    NSArray *groupMetadataList = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:prismetaFilePath] options:NSJSONReadingMutableContainers error:nil];
    
    NSString *directoryName = @"lookups";
    
    // metadata 필터 그룹
    __weak STFilterManager *weakSelf = self;
    
    NSMutableArray *filterInfoList = [NSMutableArray array];
    
    for (NSDictionary *filterGroupInfo in groupMetadataList) {
        [filterGroupInfo enumerateKeysAndObjectsUsingBlock:^(NSString *filterGroupFileName, NSArray *filterFileList, BOOL *stop) {
            NSString *groupFileName = [directoryName stringByAppendingPathComponent:filterGroupFileName];

            STFilterGroupItem *groupItem = [[STFilterGroupItem alloc] initWithCLUTFilePath:groupFileName];

            groupItem.label = [weakSelf colorNameWithColor:groupItem.representativeColor];
            [filterInfoList addObject:groupItem];
            
            NSMutableArray *filterItemList = [NSMutableArray array];
            
            for (NSString *filterFileName in filterFileList) {
                NSString *filterFilePath = [groupFileName stringByAppendingPathComponent:filterFileName];

                STFilterItem *filterItem = [[STFilterItem alloc] initWithCLUTFilePath:filterFilePath];
                filterItem.index = [filterFileList indexOfObject:filterFileName];
                filterItem.id = filterItem.hash;
                filterItem.label = [weakSelf colorNameWithColor:filterItem.representativeColor];
                filterItem.deprecated = groupItem.deprecated;
                filterItem.type = [STApp isPurchasedProduct:filterItem.productId] ? STFilterTypeDefault : STFilterTypeITunesProduct;

                [filterItemList addObject:filterItem];
            }

            groupItem.filters = filterItemList;
        }];
    }

#ifdef STEWProduct_filter_basic
    [[NSNotificationCenter defaultCenter] st_addObserverWithMainQueueOnlyOnce:self forName:STNotificationAppProductRestoreAllSucceed usingBlock:^(NSNotification *note, id observer) {
        NSString * productId = STEWProduct_filter_basic;
        if([STApp isPurchasedProduct:productId]){
            STFilterGroupItem * purchasedGroup = self.filterGroups.firstObject;
            [[purchasedGroup.filters bk_select:^BOOL(STFilterItem *filterItem) {
                return [productId isEqualToString:filterItem.productId];
            }] bk_each:^(STFilterItem *filterItem) {
                filterItem.type = STFilterTypeDefault;
            }];
        }
    }];
#endif
    
    return filterInfoList;
}


#pragma mark - Products

NSString * const SampleFilterImageName = @"sample50.jpg";
CGFloat const SampleFilterImageSizeValue = 50;

- (M13OrderedDictionary *)getSampleFilteredImages:(NSUInteger)groupIndex productId:(NSString *)productId{
    UIImage * sampleImage = [UIImage imageBundled:SampleFilterImageName];
    if(!sampleImage){
        return nil;
    }

    M13MutableOrderedDictionary * dictionary = [M13MutableOrderedDictionary orderedDictionary];

    for(STFilterItem *filterItem in ((STFilterGroupItem *)[[self filterGroups] st_objectOrNilAtIndex:groupIndex]).filters){
        @autoreleasepool {
            if([productId isEqualToString:filterItem.productId]){
                NSString * cacheKey = [@"filter_sample_created_image_" st_add:filterItem.uid_short];
                //expire when first launch
                if([[STAppSetting get] isFirstLaunchSinceLastBuild]){
                    [self st_uncacheImage:cacheKey fromDisk:YES];
                }

                WeakAssign(sampleImage)
                UIImage *(^createImage)(void) = ^UIImage * {
                    @autoreleasepool {
                        /*
                        * build image
                        */
                        UIImage * imageToUseAsSample = [[STFilterManager sharedManager] buildOutputImage:weak_sampleImage
                                                                                                 enhance:NO
                                                                                                  filter:[[STFilterManager sharedManager] acquire:filterItem]
                                                                                        extendingFilters:nil
                                                                                            rotationMode:kGPUImageNoRotation
                                                                                             outputScale:1
                                                                                   useCurrentFrameBuffer:YES
                                                                                      lockFrameRendering:YES];

                        return [imageToUseAsSample clipAsCircle:SampleFilterImageSizeValue];
                    }
                };

                [dictionary addObject:[STApp isDebugMode] ? createImage() : [self st_cachedImage:cacheKey useDisk:YES init:createImage] pairedWithKey:filterItem.uid_short];

                [self st_uncacheImage:cacheKey];
            }
        }
    }

    return dictionary;
}

@end
