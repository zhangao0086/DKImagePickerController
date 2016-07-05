 //
// Created by BLACKGENE on 2014. 11. 18..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import "NSArray+BlocksKit.h"
#import "STFilterPresenterLive.h"
#import "STFilterPresenterItemView.h"
#import "STFilterItem.h"
#import "STFilterManager.h"
#import "NSObject+STUtil.h"
#import "NSObject+STThreadUtil.h"
#import "STGIFFAppSetting.h"

 @interface STFilterPresenterLive()
 @property (nullable, atomic, readwrite) NSMutableDictionary *filterChains;
 @end

 @implementation STFilterPresenterLive {
    BOOL _finishedAndInterruptFilterThread;

}
- (instancetype)initWithOrganizer:(STFilterCollector *)authorizer; {
    self = [super initWithOrganizer:authorizer];
    if (self) {
        self.filterChains = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)beforeApplyAndClose; {
    [self interruptFilterWorks];
}

- (void)beforeClose; {
    [self interruptFilterWorks];
}

- (void)finishAllResources; {
    oo(@"---- finish ---")

    [self interruptFilterWorks];
    [self clearFilterCaches];

    @synchronized (self) {
        [self.filterChains enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [[STFilterManager sharedManager] clearOutputChain:obj];
        }];
        [self.filterChains removeAllObjects];
        self.filterChains = nil;
    }
}

- (void)interruptFilterWorks{
    @synchronized (self) {
        _finishedAndInterruptFilterThread = YES;
    }
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
            return 3;
        }
        case iCarouselOptionSpacing:
        {
            return 1.05;
        }
        case iCarouselOptionArc:
        {
            return [@(2 * M_PI * 0.6) floatValue];
        }
        default:
        {
            return value;
        }
    }
}

- (void)clearFilterCaches; {
//    @synchronized (self) {
//        [self st_clearAllCachedObjectInDomain:@"STFilterPresenterLive.filters"];
//    }
}

- (STFilterPresenterItemView *)createItemView:(NSInteger)index filterItem:(STFilterItem *)filterItem reusingView:(STFilterPresenterItemView *)view; {
    if (view == nil)
    {
        view = [[STFilterPresenterItemView allocWithZone:NULL] init];
        view.frame = self.organizer.carousel.bounds;
        [view usingGPUImage];
        view.contentMode = UIViewContentModeScaleAspectFit;
    }
    return view;
}

- (void)presentView:(STFilterPresenterItemView *)targetView filter:(STFilterItem *)filterItem carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index1 reused:(BOOL)reused; {
    [self displayFilterLiveCamera:targetView withCLUTFilter:filterItem finished:nil];
}

#define ST_BREAK_PROC if(!Sself.filterChains || Sself->_finishedAndInterruptFilterThread){ [Wself clearFilterCaches]; return; }

- (void)displayFilterLiveCamera:(STFilterPresenterItemView *)targetView withCLUTFilter:(STFilterItem *)filterItem finished:(void(^)(void))block{
    __weak STFilterItem * blockFilterItem = filterItem;
    __weak STFilterPresenterItemView *blockTargetView = targetView;
    __weak void (^blockFinishedBlock)(void) = block;

    Weaks
    //FIXME: 시리얼큐로바꾸는것검토
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        Strongs
        @synchronized (Sself) {
            ST_BREAK_PROC

            STFilterItem *item = blockFilterItem;
            STFilterPresenterItemView *view = blockTargetView;

            STFilter * filter = [Sself st_cachedObject:item.uid_short domain:@"STFilterPresenterLive.filters" init:^id {
                return [[STFilterManager sharedManager] acquire:filterItem];
            }];

            ST_BREAK_PROC

            NSSet * visibleKeys = isEmpty(Sself.organizer.items) ? nil : [NSSet setWithArray: [Sself.organizer.carousel.indexesForVisibleItems bk_map:^id(id obj) {
                return ((STFilterItem *) Sself.organizer.items[[obj unsignedIntegerValue]]).uid_short;
            }]];

            [Sself.filterChains enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if (![visibleKeys containsObject:key]) {
                    [[STFilterManager sharedManager] clearOutputChain:obj];

                    runAsynchronouslyOnVideoProcessingQueue(^{
                        [Sself.filterChains removeObjectForKey:key];
                    });
                }
            }];

            ST_BREAK_PROC

            if(!Sself.filterChains[item.uid_short]){
                BOOL enhance = [[STGIFFAppSetting.get read:@keypath([STGIFFAppSetting get].autoEnhanceEnabled)] boolValue];
                Sself.filterChains[item.uid_short] = [[STFilterManager sharedManager] buildOutputChain:[STElieCamera sharedInstance] filters:@[filter] to:view.gpuView enhance:enhance];
            }

            ST_BREAK_PROC

            BOOL allFinished = Sself.organizer.carousel.numberOfVisibleItems == Sself.filterChains.count;

            [Sself st_runAsMainQueueAsyncWithoutDeadlocking:^{
                !blockFinishedBlock ?: blockFinishedBlock();

                if (allFinished) {
                    [Sself dispatchAllItemRenderFinished];
//                return;

                } else {
                    [Sself dispatchItemRenderFinished:[Sself.organizer.items indexOfObject:item]];
                }
            }];
        }
    });
}
@end