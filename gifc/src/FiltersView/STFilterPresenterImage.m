//
// Created by BLACKGENE on 2014. 9. 30..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <SDWebImage/SDImageCache.h>
#import "STFilterPresenterImage.h"
#import "STPhotoItem.h"
#import "STFilterGroupItem.h"
#import "STFilterPresenterItemView.h"
#import "NSArray+BlocksKit.h"
#import "NSObject+STThreadUtil.h"
#import "STEditorResult.h"
#import "STFilterManager.h"
#import "STFilter.h"
#import "STFilterPresenterProductItemView.h"
#import "STApp+Products.h"
#import "R.h"

@interface STFilterPresenterImage()
@property (nullable, atomic, readwrite) NSMutableSet *filteringOperationKeys;
@property (nullable, atomic, readwrite) NSOperationQueue *filterOperationQueue;
@property (nullable, atomic, readwrite) NSMutableSet *cachedKeys;
@property (atomic, assign) BOOL interrupted;
@end

//#define ST_SHOWLOG

@implementation STFilterPresenterImage {
    UIImage *_sourceImage;
    UIImage *_modifiedSourceImage;
}

- (instancetype)initWithOrganizer:(STFilterCollector *)organizer; {
    self = [super initWithOrganizer:organizer];
    if (self) {
        self.filterOperationQueue = [[NSOperationQueue alloc] init];
        self.filterOperationQueue.qualityOfService = NSQualityOfServiceUserInitiated;
        self.filterOperationQueue.maxConcurrentOperationCount = 1;
        self.filteringOperationKeys = [NSMutableSet set];
        self.cachedKeys = [NSMutableSet set];
    }
    return self;
}

- (void)dealloc; {
    [self finishAllResources];
    [self clearSourceImage];

    self.filterOperationQueue = nil;
    self.filteringOperationKeys = nil;
    self.cachedKeys = nil;
}

#pragma mark delegate
- (void)beforeApplyAndClose; {
    [self clearSourceImage];
}

- (void)beforeClose; {
    [self clearSourceImage];
}

- (void)initialPresentViews:(iCarousel *)carousel; {
    NSAssert(self.organizer.targetPhotoItem !=nil, @"must set target STPhotoSelectorPhotoItem before call 'beforeStartEdit'.");
    NSAssert(!isEmpty(self.organizer.items), @"isEmpty(self.organizer.items) == YES");

    STFilterItem * filterItem = (STFilterItem *) self.organizer.items[(NSUInteger) carousel.currentItemIndex];
    STFilterPresenterItemView * view = (STFilterPresenterItemView *)carousel.currentItemView;

    WeakSelf weakSelf = self;
    [self displayFilter:view item:self.organizer.targetPhotoItem withCLUTFilter:filterItem asyncIfNeeded:YES finished:^{
        if (isEmpty(self.organizer.items)) {
            return;
        }

        NSArray *otherViews = [carousel.visibleItemViews bk_reject:^BOOL(id obj) {
            return [obj isEqual:view];
        }];

        __block NSInteger otherViewsCount = otherViews.count;

        [otherViews eachWithIndex:^(id object, NSUInteger index) {
            STFilterItem *_filterItem = self.organizer.items[(NSUInteger) [carousel indexOfItemView:object]];

            [weakSelf displayFilter:(STFilterPresenterItemView *) object item:self.organizer.targetPhotoItem withCLUTFilter:_filterItem asyncIfNeeded:YES finished:^{
                if ((otherViewsCount--) == 1) {
                    //Initial finished.
                    NSLog(@"== Initial Filter Rendering finished.");
                    _firstRendered = YES;
                }
            }];
        }];
    }];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value; {
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            return YES;
        }
        case iCarouselOptionVisibleItems:
        {
            return 5;
        }
        case iCarouselOptionSpacing:
        {
            return 1.05;
        }
        case iCarouselOptionArc:
        {
            return [[NSNumber numberWithDouble:(2 * M_PI * 0.6)] floatValue];
        }
        default:
        {
            return value;
        }
    }
}

#pragma mark - CLUT filter operations
- (void)finishAllResources; {
    if(self.interrupted){
        return;
    }
    self.interrupted = YES;

    [self clearFilterCaches];
    [self clearOrInterruptFilteringOperations];
}

- (void)clearOrInterruptFilteringOperations {
    [self.filterOperationQueue cancelAllOperations];
    [self.filterOperationQueue.operations bk_each:^(id obj) {
        [obj setCompletionBlock:nil];
    }];
    [self.filteringOperationKeys removeAllObjects];
}

- (void)_clearFilterCaches:(NSArray *)exceptKeys {
    if(exceptKeys){
        for(id key in self.cachedKeys){
            if([exceptKeys containsObject:key]){
                continue;
            }
            [[SDImageCache sharedImageCache] removeImageForKey:key fromDisk:NO];
            [self.cachedKeys removeObject:key];
        }
    }else{
        for(id key in self.cachedKeys){

            [[SDImageCache sharedImageCache] removeImageForKey:key fromDisk:NO];
        }
        [self.cachedKeys removeAllObjects];
    }
}

- (void)clearFilterCaches {
    [self _clearFilterCaches:nil];
}

- (UIImage *)getSourceImage:(STPhotoItem *)item filterItem:(STFilterItem *)filterItem{
    //get image from current scrolled index
    NSUInteger filterItemIndex = [self.organizer.items indexOfObject:filterItem];
    if(self.highQualityContextHasBegan && filterItemIndex==[self.organizer.carousel currentItemIndex]){
        _sourceImage = [item loadFullScreenImage];
        @synchronized (self) {
            _highQualityContextHasBegan = NO;
        }
    }else if(filterItemIndex==0){
        _sourceImage = [item loadFullScreenImage];
    }else{
        _sourceImage = item.previewImage;
    }

    if(item.isModifiedByTool){
        if(_modifiedSourceImage){
            return _modifiedSourceImage;
        }else{
            UIImage * modifiedImage = [item.toolResult modifiyImage:_sourceImage];
            return _modifiedSourceImage = modifiedImage ? modifiedImage :  _sourceImage;
        }
    }else{
        _modifiedSourceImage = nil;
        return _sourceImage;
    }
}

- (void)clearSourceImage{
    _sourceImage = nil;
    _modifiedSourceImage = nil;
}

- (STFilterPresenterItemView *)createItemView:(NSInteger)index filterItem:(STFilterItem *)filterItem reusingView:(STFilterPresenterItemView *)view; {
    if (view == nil)
    {
        view = [[STFilterPresenterProductItemView allocWithZone:NULL] init];
        view.frame = self.organizer.carousel.bounds;
        view.layer.masksToBounds = NO;
        view.contentMode = UIViewContentModeScaleAspectFit;
    }else{
//        view.image = nil;
    }

    return view;
}

- (void)presentView:(STFilterPresenterItemView *)targetView filter:(STFilterItem *)filter carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reused:(BOOL)reusing; {
    if(_firstRendered){
        [self displayFilter:targetView item:self.organizer.targetPhotoItem withCLUTFilter:filter asyncIfNeeded:YES];
    }
}

- (void)displayFilter:(STFilterPresenterItemView *)targetView item:(STPhotoItem *)item{
    [self displayFilter:targetView item:item withCLUTFilter:item.currentFilterItem];
}

- (void)displayFilter:(STFilterPresenterItemView *)targetView item:(STPhotoItem *)item withCLUTFilter:(STFilterItem *)filterItem{
    [self displayFilter:targetView item:item withCLUTFilter:filterItem asyncIfNeeded:YES];
}

- (void)displayFilter:(STFilterPresenterItemView *)targetView item:(STPhotoItem *)item withCLUTFilter:(STFilterItem *)filterItem asyncIfNeeded:(BOOL)async{
    [self displayFilter:targetView item:item withCLUTFilter:filterItem asyncIfNeeded:async finished:nil];
}

- (void)displayFilter:(STFilterPresenterItemView *)targetView item:(STPhotoItem *)item withCLUTFilter:(STFilterItem *)filterItem asyncIfNeeded:(BOOL)async finished:(void(^)(void))block{
    NSAssert(targetView, @"targetView is must not null");
    NSAssert(item.previewImage, @"STPhotoSelectorItem.previewImage must be not empty before displayFilter");

    STPhotoItem * photoItem = item;

    //super fast.
//    [self displayFilter:targetView item:item withCLUTFilter:filterItem finished:block];
//    return;

#if DEBUG
    [targetView describeFilterInfoForDebug:filterItem];
#endif
    //present product icon if filterItem purchasing target.
    //disabled.
//    targetView.targetFilterItem = filterItem;
//    if(STFilterTypeITunesProduct == filterItem.type){
//        ((STFilterPresenterProductItemView *)targetView).productIconImageName = R.logo;
//        ((STFilterPresenterProductItemView *)targetView).productIconView.alpha = [STStandardUI alphaForDimmingGhostly];
//    }
//    [targetView layoutSubviews];

    // apply filter
    if(filterItem){

        NSString * cacheKey = [filterItem makeFilterCacheKey:item];
        self.interrupted = NO;

        if(self.highQualityContextHasBegan){
            [self.filteringOperationKeys removeObject:cacheKey];
            [[SDImageCache sharedImageCache] removeImageForKey:cacheKey];
        }

        [self __filteringExe:targetView
                       image:[[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:cacheKey]
                        item:photoItem filterItem:filterItem finished:block];
    }
}

- (void)__filteringExe:(STFilterPresenterItemView *)targetView image:(UIImage * )image item:(STPhotoItem *)item filterItem:(STFilterItem *)filterItem finished:(void(^)(void))block{
    NSString * cacheKey = [filterItem makeFilterCacheKey:item];

    if(image){
#ifdef ST_SHOWLOG
        NSLog(@"-- start_image [%@] --", filterItem.uid_short);
#endif

        targetView.image = image;

        [self __filteringFinished:targetView item:item filterItem:filterItem finished:block];

    }else{
#ifdef ST_SHOWLOG
        NSLog(@"-- start [%@] --", filterItem.uid_short);
#endif
        NSAssert([NSThread isMainThread], @"must main thread.");

        if([self.filteringOperationKeys containsObject:cacheKey]){
            return;
        }
        [self.filteringOperationKeys addObject:cacheKey];

        // do filter operation
        STFilterPresenterItemView * __weak blockImageView = targetView;
        Weaks
        NSBlockOperation * operation = [NSBlockOperation blockOperationWithBlock:^{
            Strongs
            UIImage * blockImage = [Sself getSourceImage:item filterItem:filterItem];

            if(Sself.interrupted || !blockImage) { //cancel block
                [Sself __filteringRemoveCacheKey:cacheKey];
                return;
            }

            UIImage * resultImage = nil;
            //https://fabric.io/jessi/ios/apps/com.stells.eliew/issues/5706ed68ffcdc04250848a07
            @synchronized (self) {
                @autoreleasepool {
                    STFilter * filter = [[STFilterManager sharedManager] acquire:filterItem];

                    resultImage = [[STFilterManager sharedManager]
                            buildOutputImage:blockImage
                                     enhance:item.needsEnhance
                                      filter:filter
                            extendingFilters:nil
                                rotationMode:kGPUImageNoRotation
                                 outputScale:1
                       useCurrentFrameBuffer:YES
                          lockFrameRendering:YES];
                }
            }

            if(!resultImage || Sself.interrupted) { //cancel block
                [Sself __filteringRemoveCacheKey:cacheKey];
                return;
            }

            // apply to view
            UIImage * __weak applyImage = resultImage;
            [Wself st_runAsMainQueueAsyncWithoutDeadlocking:^{
                blockImageView.image = applyImage;
            }];

            if(Sself.interrupted) { //cancel block
                [Sself __filteringRemoveCacheKey:cacheKey];
                return;
            }

            // save cache
            [[SDImageCache sharedImageCache] storeImage:resultImage forKey:cacheKey toDisk:NO];

            if(![Sself.cachedKeys containsObject:cacheKey]){
                [Sself.cachedKeys addObject:cacheKey];
            }
#ifdef ST_SHOWLOG
            NSLog(@"-- finish [%@] %@ --", filterItem.uid_short, cacheKey);
#endif
            [Sself __filteringRemoveCacheKey:cacheKey];
        }];

        [operation setCompletionBlock:^{
            [Wself __filteringFinished:targetView item:item filterItem:filterItem finished:block];
        }];

        [self.filterOperationQueue addOperation:operation];
    }
}

- (void)__filteringFinished:(STFilterPresenterItemView *)targetView item:(STPhotoItem *)item filterItem:(STFilterItem *)filterItem finished:(void(^)(void))block{
    Weaks
    [self st_runAsMainQueueWithoutDeadlocking:^{
        Strongs
#ifdef ST_SHOWLOG
        NSLog(@"finished: [%@] remain:%d %d", filterItem.uid_short, Sself.filteringOperationKeys.count, Sself.filterOperationQueue.operationCount);
#endif
        if(block){
            block();
        }

        [Sself dispatchItemRenderFinished:[[Sself organizer].items indexOfObject:filterItem]];

        if (_firstRendered && Sself.filteringOperationKeys.count == 0) {
            [Sself dispatchAllItemRenderFinished];
        }
    }];
}

- (void)__filteringRemoveCacheKey:(NSString *)cacheKey{
    //STFilterPresenterImage : line 346 / eliew(6843,0x16e3a7000) malloc: *** error for object 0x1409458b0: double free *** set a breakpoint in malloc_error_break to debug
    @synchronized (self) {
        [self.filteringOperationKeys removeObject:cacheKey];
    }
}

#if DEBUG
//TODO: prototyped method 역시 훨씬 빠름.
- (void)displayFilter:(STFilterPresenterItemView *)targetView item:(STPhotoItem *)item withCLUTFilter:(STFilterItem *)filterItem finished:(void(^)(void))block {
    NSAssert(targetView, @"targetView is must not null");
    NSAssert(item.previewImage, @"STPhotoSelectorItem.previewImage must be not empty before displayFilter");

    STPhotoItem *photoItem = item;

    targetView.targetFilterItem = filterItem;

    if (filterItem) {
        NSString *cacheKey = [filterItem makeFilterCacheKey:item];

        if ([self.filteringOperationKeys containsObject:cacheKey]) {
            return;
        }
        [self.filteringOperationKeys addObject:cacheKey];

        [targetView usingGPUImage];

        Weaks
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @synchronized (self) {
                GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:[Wself getSourceImage:item filterItem:filterItem] smoothlyScaleOutput:YES];
                STFilter *filter = [[STFilterManager sharedManager] acquire:filterItem];
                [filter useNextFrameForImageCapture];

                [[STFilterManager sharedManager] buildOutputChain:picture filters:@[filter] to:targetView.gpuView enhance:item.needsEnhance];

                [picture useNextFrameForImageCapture];
                [picture processImage];

                [Wself st_runAsMainQueueAsync:^{
                    Strongs
                    if (block) {
                        block();
                    }

                    [Sself dispatchItemRenderFinished:[[Sself organizer].items indexOfObject:filterItem]];

                    if (Sself->_firstRendered && Sself.filteringOperationKeys.count == 0) {
                        [Sself dispatchAllItemRenderFinished];
                    }
                }];
            }

        });
    }
}
#endif

@end