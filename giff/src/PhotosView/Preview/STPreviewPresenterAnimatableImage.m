//
// Created by BLACKGENE on 4/20/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STPreviewPresenterAnimatableImage.h"
#import "STFilterGroupItem.h"
#import "STFilterPresenterItemView.h"
#import "NSData+STGIFUtil.h"
#import "NSArray+STUtil.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"
#import "UIView+STUtil.h"

@implementation STPreviewPresenterAnimatableImage {
    FLAnimatedImage *_sourceImageData;
}

- (instancetype)initWithOrganizer:(STFilterCollector *)organizer; {
    self = [super initWithOrganizer:organizer];
    if (self) {

    }
    return self;
}

- (void)dealloc; {
    [self finishAllResources];
}

#pragma mark delegate
- (void)beforeApplyAndClose; {
}

- (void)beforeClose; {
}

- (void)initialPresentViews:(iCarousel *)carousel; {
    NSAssert(self.organizer.targetPhotoItem !=nil, @"must set target STPhotoSelectorPhotoItem before call 'beforeStartEdit'.");
    NSAssert(!isEmpty(self.organizer.items), @"isEmpty(self.organizer.items) == YES");

    STFilterItem * filterItem = (STFilterItem *) self.organizer.items[(NSUInteger) carousel.currentItemIndex];
    STFilterPresenterItemView * view = (STFilterPresenterItemView *)carousel.currentItemView;

//    [self presentView:view filter:filterItem carousel:self.organizer.carousel viewForItemAtIndex:9 reused:NO];

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
            return 1;
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
    [UIView setAnimationsEnabled:NO];
    [[self.organizer.carousel visibleItemViews] eachViewsWithIndex:^(UIView *view, NSUInteger index) {
        oo(((UIImageView *)view));
        [view.layer removeAllAnimations];
        ((UIImageView *)view).image = nil;
        ((UIImageView *)view).animationImages = nil;
        ((FLAnimatedImageView *)[view viewWithTagName:@"dd"]).animatedImage = nil;

        oo(@"xx - dispose");
    }];
    _sourceImageData = nil;
    [UIView setAnimationsEnabled:YES];

    [super finishAllResources];
}

static NSString * const GIFImageViewTagName = @"GIFImageViewTagName";
- (STFilterPresenterItemView *)createItemView:(NSInteger)index filterItem:(STFilterItem *)filterItem reusingView:(STFilterPresenterItemView *)view; {
    if (view == nil)
    {
        view = [[STFilterPresenterItemView allocWithZone:NULL] init];
        view.frame = self.organizer.carousel.bounds;
        view.layer.masksToBounds = NO;
        view.contentMode = UIViewContentModeScaleAspectFit;
        FLAnimatedImageView * imageView = [[FLAnimatedImageView alloc] initWithSize:view.size];
        imageView.tagName = GIFImageViewTagName;
        [view addSubview:imageView];

    }else{
//        view.image = nil;
    }

    return view;
}

- (void)presentView:(STFilterPresenterItemView *)targetView filter:(STFilterItem *)filter carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reused:(BOOL)reusing; {
    @autoreleasepool {
        if(!_sourceImageData){
//            _sourceImageData = [[FLAnimatedImage alloc] initWithAnimatedGIFData:[NSData dataWithContentsOfFile:self.organizer.targetPhotoItem.fullResolutionURL.path options:NSDataReadingUncached error:NULL] optimalFrameCacheSize:10000 predrawingEnabled:YES];
            _sourceImageData = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:self.organizer.targetPhotoItem.fullResolutionURL.path options:NSDataReadingUncached error:NULL]];
        }
        ((FLAnimatedImageView *)[targetView viewWithTagName:GIFImageViewTagName]).animatedImage = _sourceImageData;
    }


    [self dispatchAllItemRenderFinished];
    [self dispatchItemRenderFinished:[self.organizer.items indexOfObject:filter]];
}

@end