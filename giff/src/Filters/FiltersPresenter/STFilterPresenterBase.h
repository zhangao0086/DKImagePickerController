//
// Created by BLACKGENE on 2015. 2. 6..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STFilterCollector.h"


extern NSString * const STNotificationFilterPresenterItemRenderFinish;
extern NSString * const STNotificationFilterPresenterAllItemsRenderFinish;

@class STFilterCollector;
@class STFilterPresenterItemView;
@class STFilterItem;
@class STFilterPresenterBase;
@class STPhotoItem;

@protocol STFilterPresenterDelegate <NSObject>
@required
- (STFilterPresenterBase *)initWithOrganizer:(STFilterCollector *)authorizer;

- (void)beforeStart;

- (void)afterStart;

- (void)beforeApplyAndClose;

- (void)beforeClose;

- (void)finishAllResources;

- (void)clearFilterCaches;

- (void)initialPresentViews:(iCarousel *)carousel;

- (STFilterPresenterItemView *)createItemView:(NSInteger)index filterItem:(STFilterItem *)filterItem reusingView:(STFilterPresenterItemView *)view;

- (void)presentView:(STFilterPresenterItemView *)targetView filter:(STFilterItem *)filterItem carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reused:(BOOL)reused;

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value;

- (void)currentSelectedFilterItem:(STFilterItem *) filterItem;

- (void)whenAllItemRenderFinished:(void(^)(void))block;

- (void)whenItemRenderFinished:(void(^)(NSInteger))block;
@end

@interface STFilterPresenterBase : NSObject <STFilterPresenterDelegate>{
@protected
    BOOL _firstRendered;
    BOOL _highQualityContextHasBegan;
}
@property(nonatomic, readonly) STFilterCollector *organizer;
@property(nonatomic, readonly) BOOL firstRendered;
@property(atomic, readonly) BOOL highQualityContextHasBegan;

- (instancetype)initWithOrganizer:(STFilterCollector *)organizer;

- (void)dispatchAllItemRenderFinished;

- (void)dispatchItemRenderFinished:(NSInteger)index;

- (void)whenAllItemRenderFinished:(void (^)(void))block;

- (void)whenItemRenderFinished:(void (^)(NSInteger index))block;

- (void)beginAndAutomaticallyEndHighQualityContext;

- (void)endHighQualityContext;
@end