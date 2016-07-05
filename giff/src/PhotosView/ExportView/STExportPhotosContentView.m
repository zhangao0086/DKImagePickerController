//
// Created by BLACKGENE on 2016. 3. 14..
// Copyright (c) 2016 stells. All rights reserved.
//

#import "TTTAttributedLabel.h"
#import "UIView+STUtil.h"
#import "STExportContentView.h"
#import "STExportPhotosContentView.h"
#import "STExporter+IOGIF.h"
#import "STExporter+ConfigGIF.h"
#import "STCarouselController.h"
#import "STPhotoItem.h"
#import "NSObject+STThreadUtil.h"
#import "STExporter+IO.h"
#import "UIImage+STUtil.h"
#import "NSString+STUtil.h"
#import "NSObject+STUtil.h"
#import "NSArray+STUtil.h"
#import "SVGKImage.h"
#import "SVGKImage+STUtil.h"
#import "NSNumber+STUtil.h"
#import "STExporter+Config.h"
#import "DFAnimatedImageView.h"
#import "STQueueManager.h"
#import "DFAnimatedImageView+Loader.h"
#import "STPhotoItem+ExporterIO.h"
#import "CALayer+STUtil.h"
#import "STPhotoItem+UIAccessory.h"
#import "STPhotoItem+STExporterIOGIF.h"

NSString * const RenderedImageCacheKeyPrefix = @"STExportPhotosContentView_RenderedImageCacheKeyPrefix";

@implementation STExportPhotosContentView {
    TTTAttributedLabel * _titleLabel;
    TTTAttributedLabel * _descLabel;
    STCarouselController * _homeFilterCollector;
    UIImageView * _titleImageView;
    DFAnimatedImageView * _previousGIFPresentedItemView;
    BOOL _enabledGIFExport;
}

- (void)loadContents {
    //set tilte image name
    NSString * titleImageName = self.exporter.logoImageName?:self.exporter.iconImageName;
    UIImage * image = [SVGKImage imageNamedNoCache:titleImageName widthSizeWidth:self.width/6].UIImage;
    if(!_titleImageView){
        _titleImageView = [[DFAnimatedImageView alloc] initWithImage:image];
        [self addSubview:_titleImageView];
    }else{
        _titleImageView.image = image;
    }
    [_titleImageView sizeToFit];
}

- (void)unloadContents {
    [super unloadContents];

    [_titleImageView clearAllOwnedImagesIfNeededAndRemoveFromSuperview:NO];
    _titleImageView = nil;
}

- (CGFloat)imageViewWidth{
    return self.width/1.15f;
}

- (void)loadContentsLazily {
    [self uncacheAllImages];

    _homeFilterCollector = [[STCarouselController alloc] initWithCarousel:[[iCarousel alloc] initWithSize:self.size]];
    [_homeFilterCollector initItems:[NSMutableArray arrayWithArray:self.exporter.photoItems]];
    [_homeFilterCollector delegateSelf];
    [self addSubview:_homeFilterCollector.carousel];
    _homeFilterCollector.carousel.type = iCarouselTypeTimeMachine;
    _homeFilterCollector.carousel.vertical = YES;
    _homeFilterCollector.carousel.bounceDistance = .1f;
    _homeFilterCollector.carousel.contentOffset = CGSizeMake(0, -(self.height/30));
    _homeFilterCollector.blockForiCarouselOption = ^CGFloat(iCarouselOption option, CGFloat value) {
        switch (option)
        {
            case iCarouselOptionVisibleItems:
            {
                return 4;
            }
            case iCarouselOptionWrap:
            {
                return NO;
            }
            case iCarouselOptionTilt:
            {
                return value * 1.5f;
            }
            case iCarouselOptionSpacing:
            {
                //add a bit of spacing between the item views
                return value * ([STGIFFApp screenFamily]>STScreenFamily4 ? 1.1f : 1.3f);
            }
            default:
            {
                return value;
            }
        }
    };

    Weaks
    WeakAssign(_homeFilterCollector)

    _homeFilterCollector.blockForItemView = ^UIView *(NSInteger index, UIView *view) {
        STPhotoItem * item = weak__homeFilterCollector.items[(NSUInteger) index];
        DFAnimatedImageView * imageView = (DFAnimatedImageView *) view;
        if(imageView==nil){
            imageView = [[DFAnimatedImageView alloc] init];
        }
        [Wself presentImage:imageView photoItem:item index:index];
        return imageView;
    };


    [_homeFilterCollector.carousel reloadData];

    NSInteger numberOfItems = _homeFilterCollector.carousel.numberOfItems;

    //start
    _homeFilterCollector.carousel.scaleXYValue = 0;
    [STStandardUX setAnimationFeelToRelaxedSpring:_homeFilterCollector.carousel];
    [NSObject animate:^{
        _homeFilterCollector.carousel.spring.scaleXYValue = 1;
    } completion:^(BOOL finished) {
        [_homeFilterCollector.carousel scrollToItemAtIndex:numberOfItems-1 duration:(numberOfItems>=5?.35f:.3f)*numberOfItems];
    }];
}

- (void)unloadContentsLazily:(void (^)(BOOL finished))block {
    if(NO){
//    if(_homeFilterCollector.scrolledIndex>0){
        [_homeFilterCollector whenDidEndScroll:^(NSInteger i) {
            //FIXME: memory leak
            [CATransaction setCompletionBlock:^{
                [self _unloadContentsLazily];
                [super unloadContentsLazily:block];
            }];
        }];
        [_homeFilterCollector.carousel scrollToItemAtIndex:0 duration:.6f];
    }else{
        [self _unloadContentsLazily];
        [super unloadContentsLazily:block];
    }
}

- (void)_unloadContentsLazily{
    [self uncacheAllImages];

    [self _unloadAllImageViews:YES];
    _homeFilterCollector.blockForiCarouselOption = nil;
    _homeFilterCollector.blockForItemView = nil;
    [_homeFilterCollector.carousel clearAllOwnedImagesIfNeededAndRemoveFromSuperview:YES];
    _homeFilterCollector.carousel = nil;
    _homeFilterCollector = nil;

    [_previousGIFPresentedItemView cleanImage:YES];
    _previousGIFPresentedItemView = nil;
}

- (void)_unloadAllImageViews:(BOOL)dispose{
    [[_homeFilterCollector.carousel visibleItemViews] eachViewsWithIndex:^(UIView *view, NSUInteger index) {
        STPhotoItem * item = [_homeFilterCollector.items st_objectOrNilAtIndex:index];
        [item disposeIcon:view];
        [((DFAnimatedImageView *) view) cleanImage:dispose];
        [((DFAnimatedImageView *) view) clearAllOwnedImagesIfNeededAndRemoveFromSuperview:YES];
        ((DFAnimatedImageView *) view).imageManager = nil;
    }];
}

- (void)reloadContents {
    [super reloadContents];
}

- (void)enableGIFExport:(BOOL)enable{
    NSAssert(!enable || (enable && self.exporter.photoItemsCanExportGIF), @"photoItemsCanExportAsGif must not be empty.");

    _enabledGIFExport = enable;

    //move to gif item
    NSInteger firstGifItemIndex = [[_homeFilterCollector items] indexOfObject:[self.exporter.photoItemsCanExportGIF firstObject]];
    STPhotoItem * currentScrolledItem = [_homeFilterCollector.items st_objectOrNilAtIndex:[_homeFilterCollector scrolledIndex]];
    BOOL currentItemIsGifItem = currentScrolledItem && [self.exporter.photoItemsCanExportGIF containsObject:currentScrolledItem];

    if(enable && self.exporter.photoItemsCanExportGIF){
        Weaks
        [_homeFilterCollector.carousel reloadData];

        if(!currentItemIsGifItem){
            [_homeFilterCollector.carousel scrollToItemAtIndex:firstGifItemIndex animated:YES];
            [_homeFilterCollector whenDidEndScroll:^(NSInteger i) {
                Strongs
                [Sself presentImagesAll];
            }];
        }else{
            [_homeFilterCollector whenDidEndScroll:^(NSInteger i) {
                [_homeFilterCollector whenDidEndScroll:^(NSInteger i) {
                    Strongs
                    [Sself presentImagesAll];
                }];
            }];
        }

    }else{
        [_homeFilterCollector whenDidEndScroll:nil];
        [_homeFilterCollector.carousel reloadData];
    }
}

- (BOOL)isNeededToPresentGIF:(STPhotoItem *)item{
    BOOL beforeExportGIF = [STExporter canExportGIF:item] && item.exporting;
    BOOL finishedExportGIF = [item isExportedTempFileGIF];
    return _enabledGIFExport && item && (beforeExportGIF || finishedExportGIF);
}

- (void)uncacheAllImages {
    NSAssert(self.exporter.photoItems.count>0,@"uncacheAllImages but items not.");
    for(id index in [@(self.exporter.photoItems.count) st_intArray]){
        [self st_uncacheImage:[self cacheKeyAtIndex:[index integerValue]]];
    }
}

- (NSString *)cacheKeyAtIndex:(NSInteger) index{
    return [RenderedImageCacheKeyPrefix st_add:[@(index) stringValue]];
}

#pragma mark present
- (void)presentImagesAll{
    for(STPhotoItem * item in [_homeFilterCollector items]){
        NSInteger index = [[_homeFilterCollector items] indexOfObject:item];
        [self presentImage:(DFAnimatedImageView *) [_homeFilterCollector.carousel itemViewAtIndex:index] photoItem:item index:index];
    }
}

- (void)presentImage:(DFAnimatedImageView *)imageView photoItem:(STPhotoItem *)item index:(NSInteger)index{
    Weaks
    NSString * cacheKey = [self cacheKeyAtIndex:index];
    BOOL square = _homeFilterCollector.items.count>1;

    //animation
    if(!imageView.image){
//        imageView.alpha = 0;
//        imageView.easeInEaseOut.alpha = 1;
    }

    //clean previous
    [imageView cleanImage:NO];

    //size
    CGFloat ratio = (CGFloat)CGSizeAspectRatio_AGK(item.previewImage.size);
    CGFloat width = self.imageViewWidth;
    if(imageView.contentMode!=UIViewContentModeScaleAspectFit){
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    if(ratio==1){
        imageView.size = CGSizeMakeValue(width);
    }else if(ratio<1){
        //height >
        if(square){
            imageView.size = CGSizeMake(width, width/ratio);
        }else{
            imageView.size = CGSizeMake(width*ratio, width);
        }
    }else if(ratio>1){
        //width >
        if(square){
            imageView.size = CGSizeMake(width*ratio, width);
        }else{
            imageView.size = CGSizeMake(width, width/ratio);
        }
    }

    //set mask
    if(square){
        UIImageView * maskView = [[UIImageView alloc] initWithSize:CGSizeMakeValue(width)];
        maskView.backgroundColor = [UIColor blackColor];
        maskView.layer.cornerRadius = self.imageViewWidth/24;
        [maskView.layer setRasterizationEnabled:YES];
        [imageView addSubview:maskView];
        [maskView centerToParent];
        imageView.layer.masksToBounds = YES;
        imageView.clipsToBounds = YES;
        imageView.maskView = maskView;
    }else{
        imageView.layer.cornerRadius = self.imageViewWidth/24;
        [imageView.layer setRasterizationEnabled:YES];
    }

    //apply image
    if([self isNeededToPresentGIF:item] && _homeFilterCollector.scrolledIndex == index){
        [self presentImageAsGifIfNeeded:imageView photoItem:item cacheKey:cacheKey];

    }else{
        [self presentImageAsImage:imageView photoItem:item cacheKey:cacheKey];
    }

    //present icon
    UIView * iconView = [item presentIcon:imageView];
    CGFloat offset = (iconView.width*3)/2;
    if(square){
        iconView.center = CGPointMake((imageView.boundsCenter.x - width/2)+offset, (imageView.boundsCenter.y - width/2)+offset);
    }else{
        iconView.origin = CGPointMake(offset/2,offset/2);
    }
}

- (void)presentImageAsImage:(DFAnimatedImageView *)imageView photoItem:(STPhotoItem *)item cacheKey:(NSString *)cacheKey{
    UIImage * cachedImage = [self st_cachedImage:cacheKey];
    if(cachedImage){
        imageView.image = cachedImage;
    }else{
        imageView.image = item.previewImage;
        Weaks
        dispatch_async([[STQueueManager sharedQueue] afterCaptureProcessing], ^{
            UIImage * image = [Wself.exporter exportImage:item fullResolution:NO];
            NSParameterAssert(image);
            [Wself st_cacheImage:image key:cacheKey useDisk:NO];
            [imageView st_runAsMainQueueAsyncWithSelf:^(DFAnimatedImageView *_imageView) {
                _imageView.image = image;
            }];
        });
    }
}

- (void)presentImageAsGifIfNeeded:(DFAnimatedImageView *)imageView photoItem:(STPhotoItem *)item cacheKey:(NSString *)cacheKey{
    if(![self isNeededToPresentGIF:item]){
        return;
    }

    //clean and represent previous gif view
    if(_previousGIFPresentedItemView){
        [_previousGIFPresentedItemView cleanImage:NO];

        for(STPhotoItem * _item in _homeFilterCollector.items){
            NSInteger _index = [_homeFilterCollector.items indexOfObject:_item];
            if([_previousGIFPresentedItemView isEqual:[_homeFilterCollector.carousel itemViewAtIndex:_index]]){
                [self presentImageAsImage:_previousGIFPresentedItemView photoItem:_item cacheKey:[self cacheKeyAtIndex:_index]];
                break;
            }
        }
    }

    //play gif
    if([item isExportedTempFileGIF]){
        [imageView displayImageFromURL:item.exportedTempFileURL];
        _previousGIFPresentedItemView = imageView;
    }else{
        Weaks
        [item whenNewValueOnceOf:@keypath(item.exportedTempFileURL) id:[item st_uid] changed:^(id value, id _weakSelf) {
            if(value && [item isExportedTempFileGIF]){
                [Wself st_runAsMainQueueWithoutDeadlocking:^{
                    imageView.image = nil;
                    [imageView displayImageFromURL:item.exportedTempFileURL];
                    _previousGIFPresentedItemView = imageView;

                }];
            }
        }];
    }
}

- (UIImage *)roundMaskImage:(UIImage *)image cropCenter:(BOOL)crop{
    NSParameterAssert(image);
    return [image clipAsRoundedRectWithCornerRadius:image.size.width/24 cropAsSquare:crop];
}

- (CGFloat)st_maxSubviewWidth {
    return self.width-60*2;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [_titleImageView centerToParentHorizontal];
    _titleImageView.y = (self.height/24) + _titleImageView.height/24;

    [_homeFilterCollector.carousel layoutSubviews];

    [_titleLabel centerToParentHorizontal];
    _titleLabel.y = self.height/14;

    UIView * titleView = _titleLabel;

    [_descLabel centerToParentHorizontal];

    _descLabel.y = titleView.bottom + titleView.y/1.5f;
}

@end