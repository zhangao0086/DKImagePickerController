//
// Created by BLACKGENE on 2015. 2. 6..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STFilterPresenterBase.h"
#import "STFilterPresenterItemView.h"
#import "STFilterItem.h"
#import "NSNotificationCenter+STFXNotificationsShortHand.h"


NSString * const STNotificationFilterPresenterItemRenderFinish = @"STFilterPresenterNotificationItemRenderFinish";
NSString * const STNotificationFilterPresenterAllItemsRenderFinish = @"STNotificationFilterPresenterAllItemsRenderFinish";

@interface STFilterPresenterBase ()
@end

@implementation STFilterPresenterBase {
    void (^_whenAllItemRenderFinished)(void);
    void (^_whenItemRenderFinished)(NSInteger index);
}

- (instancetype)initWithOrganizer:(STFilterCollector *)organizer; {
    self = [super init];
    if (self) {
        _organizer = organizer;
    }
    return self;
}

- (void)beforeStart; {
    _firstRendered = NO;
}

- (void)afterStart; {

}

- (void)beforeApplyAndClose; {

}

- (void)beforeClose; {

}

- (void)finishAllResources; {

}

- (void)clearFilterCaches; {

}

- (void)initialPresentViews:(iCarousel *)carousel; {

}

- (STFilterPresenterItemView *)createItemView:(NSInteger)index filterItem:(STFilterItem *)filterItem reusingView:(UIView *)view; {
    SUBCLASSES_MUST_OVERRIDE

    return nil;
}

- (void)presentView:(STFilterPresenterItemView *)targetView filter:(STFilterItem *)filterItem carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reused:(BOOL)reused; {

}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value; {
    return value;
}

- (void)currentSelectedFilterItem:(STFilterItem *)filterItem; {

}

- (void)dispatchAllItemRenderFinished {
    !_whenAllItemRenderFinished?:_whenAllItemRenderFinished();

    [[NSNotificationCenter defaultCenter] st_postNotificationName:STNotificationFilterPresenterAllItemsRenderFinish];
}

- (void)dispatchItemRenderFinished:(NSInteger) index {
    if(!_firstRendered){
        _firstRendered = YES;
    }
    !_whenItemRenderFinished?:_whenItemRenderFinished(index);

    [[NSNotificationCenter defaultCenter] st_postNotificationName:STNotificationFilterPresenterItemRenderFinish];
}

- (void)whenAllItemRenderFinished:(void (^)(void))block; {
    _whenAllItemRenderFinished = block;
}

- (void)whenItemRenderFinished:(void (^)(NSInteger index))block; {
    _whenItemRenderFinished = block;
}

- (void)beginAndAutomaticallyEndHighQualityContext {
    @synchronized (self) {
        _highQualityContextHasBegan = YES;
    }
}

- (void)endHighQualityContext {
    @synchronized (self) {
        _highQualityContextHasBegan = NO;
    }
}


@end