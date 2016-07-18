//
// Created by BLACKGENE on 2014. 9. 30..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import "NSObject+BKBlockObservation.h"
#import "iCarousel.h"
#import "STPreviewCollector.h"
#import "STFilterGroupItem.h"
#import "STFilterPresenterItemView.h"
#import "STThumbnailGridViewCell.h"
#import "UIView+STUtil.h"
#import "STMainControl.h"
#import "STEditor.h"
#import "STTransformEditor.h"
#import "STEditorResult.h"
#import "NSObject+STUtil.h"
#import "STGIFFAppSetting.h"
#import "STEditorCommand.h"
#import "STFilterPresenterBase.h"
#import "STStandardButton.h"
#import "STElieStatusBar.h"
#import "STFilterManager.h"
#import "STCapturedImage.h"
#import "NSArray+STUtil.h"
#import "STCapturedImageSet.h"
#import "NSNotificationCenter+STFXNotificationsShortHand.h"
#import "STCapturedImageSetDisplayLayer.h"
#import "STCapturedImageSetDisplayableProcessor.h"
#import "STAfterImageLayersChromakeyEffect.h"
#import "STGIFFCapturedImageSetAnimatableLayerEditView.h"
#import "STAfterImageLayersColorEffect.h"
#import "NSData+STGIFUtil.h"
#import "NSString+STUtil.h"
#import "UIColor+BFPaperColors.h"
#import "STCapturedImageSetAnimatableLayer.h"

#define kDefaultNumbersOfVisible 5
#define kBlurredImageKey @"_bluredPreviewCapturedImage"

NSString * const STPreviewCollectorNotificationPreviewBeginDragging = @"STPreviewCollectorNotificationPreviewBeginDragging";

#pragma mark Collector
@interface STFilterCollector ()
- (void)finishAllResources;
- (STFilterPresenterItemView *)validateFilterItemView:(NSInteger)index filterItem:(STFilterItem *)filterItem reusingView:(UIView *)view;
@end

#pragma mark Preview
@interface STPreview ()
- (iCarousel *)iCarouselView;
- (void)start:(BOOL)useForCamera;
- (void)finish;
- (void)reset;
@end

#pragma mark Class
@implementation STPreviewCollector {
    id<STEditor> _tool;
    UIImageView *_trasitionImageView;
    UIView *_trasitedTargetCell;
    CGSize _trasitionImageOriginalSize;
    BOOL _transitionEntered;

    //scroll zoom
    CGFloat _previousScrollOffsetForZoom;
    CGFloat _zValueFor3DTransform;
    BOOL _lockUpdateScrollZoomWhileResetScroll;

    UIImageView *_coverImageViewToReloadSmoothly;

    STGIFFCapturedImageSetAnimatableLayerEditView * _afterImageView;

#pragma mark filtertest
    /*
    UILabel * _filterlabel;
     */
#pragma mark filtertest
}

- (instancetype)initWithPreviewFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        if([STApp isInSimulator]){
            _previewView = [[STPreview alloc] initWithFrame:CGRectMakeWithSize_AGK(CGSizeMake(frame.size.width, frame.size.width*[STElieCamera outputVerticalRatioDefault]))];
        }else{
            _previewView = [[STPreview alloc] initWithFrame:[STElieCamera.sharedInstance outputRect:frame]];
        }
        _previewView.contentMode = UIViewContentModeScaleAspectFill;
        _previewView.hidden = YES;

#pragma mark filtertest
        /*
        [[STFilterManager sharedManager] whenNewValueOnceOf:@keypath([STFilterManager sharedManager].filterGroups) id:@"STPreviewCollector.filterloaded" changed:^(id value, id _weakSelf) {
            [_previewView whenSwipedUpDown:^(UISwipeGestureRecognizer *recognizer) {
                if(recognizer.direction == UISwipeGestureRecognizerDirectionDown){

                } else{
                    [_previewView reset:NO];
                    [self reloadGroup:(self.state.currentFocusedGroupIndex + 1) % self.state.numberOfGroups];
                }
            }];

            _filterlabel = [[UILabel alloc] initWithSizeWidth:200];
            [_previewView.superview addSubview:_filterlabel];
            _filterlabel.textColor = [UIColor whiteColor];
            _filterlabel.text = @"  abcdef(abcdef)  ";
            _filterlabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
            [_filterlabel sizeToFit];
            _filterlabel.width = 200;
            [_filterlabel centerToParentHorizontal];

            [self st_performAfterDelay:1 block:^{
                [[STPhotoSelector sharedInstance] doEnterEditByItem:[STPhotoSelector sharedInstance].collectionView.items[0]];
            }];


        }];
         */
#pragma mark filtertest

    }
    return self;
}

- (void)dealloc; {
    [self removeAllObservations];
    [self closeIfStarted];

    _carousel = nil;
    _tool = nil;
}

#pragma mark start procedure
- (void)start:(STPhotoViewType)type {
    if([self isStarted] && self.type == type){
        return;
    }
    _type = type;

    [_previewView start:type == STPhotoViewTypeLivePreview];
    _previewView.scaleXYValue = 1;

    _carousel = _previewView.iCarouselView;
    //for scrollzoom
    _carousel.type = iCarouselTypeCustom;

    if(type== STPhotoViewTypeEdit){
        Weaks
        [self enterTransition:nil];

#pragma mark filtertest
        /*
        if([_previewView.superview viewWithTagName:@"ivvv"]){
            [[_previewView.superview viewWithTagName:@"ivvv"] removeFromSuperview];
        }
        UIImageView * iv = [[UIImageView alloc] initWithImage:self.targetPhotoItem.loadFullScreenImage];
        iv.size = _previewView.size;
        iv.tagName = @"ivvv";
        iv.layer.mask = [CAShapeLayer rect:CGSizeMake(iv.width/2, iv.height)];
        [_previewView.superview addSubview:iv];
         */
#pragma mark filtertest
        
    }else if(type== STPhotoViewTypeEditAfterCapture){
        Weaks

        [self enterAfterImageEditingMode];

        [self enterTransition:nil];

//        [self initFiltersIncludeDefault];
//        [self startForImage:self.targetPhotoItem with:_carousel];
//
//        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

    }else if(type== STPhotoViewTypeReviewAfterAnimatableCapture){
        Weaks
        [[STElieStatusBar sharedInstance] startProgress:nil];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [self enterTransition:^(BOOL transitionFinished) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];

            if(transitionFinished){
                [Wself initItems:[@[[STFilterManager sharedManager].defaultFilterItem] mutableCopy]];

                [Wself startForAnimatableImage:Wself.targetPhotoItem with:Wself.carousel];

                [Wself.presenter whenItemRenderFinished:^(NSInteger i) {
                    Strongs
                    [Sself.presenter whenItemRenderFinished:nil];

                    [Sself _endTransitionEditAfterCapture];

                    [[STElieStatusBar sharedInstance] stopProgress];
                }];
            }
        }];

//        [self initFiltersIncludeDefault];
//        [self startForImage:self.targetPhotoItem with:_carousel];
//
//        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

    }else if(type== STPhotoViewTypeLivePreview){
        _carousel.visible = YES;
        Weaks
        [self enterTransition:nil];

        [self _endTransitionLive];

        [self initFiltersIncludeDefault];
        [self startForLive:_carousel];

        void(^initialRenderCompletionBlock)(void) = ^{
            Strongs
            [Sself.presenter whenItemRenderFinished:nil];

            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        };

        [self st_performOnceAfterDelay:@"live_preview_timeout" interval:.5 block:initialRenderCompletionBlock];

        [self.presenter whenItemRenderFinished:^(NSInteger i) {
            Strongs
            if(i==0) {
                [Sself st_clearPerformOnceAfterDelay:@"live_preview_timeout"];
                initialRenderCompletionBlock();
            }
        }];


#pragma mark Tutorial - FilterSlide
#if DEBUG
//        STGIFFAppSetting.get._confirmedTutorialFilterSlide = NO;
#endif
        if(!STGIFFAppSetting.get._confirmedTutorialFilterSlide){
            STGIFFAppSetting.get._confirmedTutorialFilterSlide = YES;
            [STGIFFAppSetting.get synchronize];

            [[NSNotificationCenter defaultCenter] st_addObserverWithMainQueueOnlyOnce:self forName:STNotificationFilterPresenterItemRenderFinish usingBlock:^(NSNotification *note, id observer) {
                [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                [self st_performOnceAfterDelay:@"_confirmedTutorialFilterSlide_1" interval:.8 block:^{
                    [self.carousel scrollToItemAtIndex:1 duration:2.5];
                    [self st_performOnceAfterDelay:@"_confirmedTutorialFilterSlide_2" interval:3 block:^{
                        [self reset];
                        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                    }];
                }];
            }];
        }

    }else{
        NSAssert(NO, @"must set as FilterTypes");
    }

    [self addObserver];
}

#pragma mark AfterImage Impl.
- (void)enterAfterImageEditingMode{
    Weaks

    STCapturedImageSet * targetImageSet = self.targetPhotoItem.sourceForCapturedImageSet;
    
#if DEBUG
    for(STCapturedImage * image in targetImageSet.images){
        NSLog(@"%d %f %f", image.focusAdjusted, image.lensPosition, image.createdTime);
    }
#endif

    if(targetImageSet.images.count){
        __block NSUInteger selectedIndex = targetImageSet.indexOfDefaultImage;

        NSAssert([targetImageSet.images st_objectOrNilAtIndex:selectedIndex],@"indexOfDefaultImage is wrong.");
        if(![targetImageSet.images st_objectOrNilAtIndex:selectedIndex]){
            selectedIndex = 0;
        }

        selectedIndex = (NSUInteger) floor(targetImageSet.images.count/2);

        [_previewView st_removeKeypathListener:@keypath(_previewView.masterPositionSliderValue) id:@"postFocusSliderValue"];

        _previewView.masterPositionSliderValue = selectedIndex / (targetImageSet.images.count * 1.f) ;
        _previewView.masterPositionSlidingValue = selectedIndex / (targetImageSet.images.count * 1.f) ;
        [_previewView st_addKeypathListener:@keypath(_previewView.masterPositionSliderValue) id:@"postFocusSliderValue" newValueBlock:^(id value, id _weakSelf) {
            @autoreleasepool {
                NSUInteger index = (NSUInteger) nearbyint((targetImageSet.images.count-1) * [value floatValue]);

                if(index!=selectedIndex){
                    [Wself renderAfterImageSetWithFrameAt:index imageSet:targetImageSet];
                    selectedIndex = index;
                }
            }
        }];
        [_previewView st_removeKeypathListener:@keypath(_previewView.masterPositionSliderSliding) id:@"postFocusSliding"];
        [_previewView st_addKeypathListener:@keypath(_previewView.masterPositionSliderSliding) id:@"postFocusSliding" newValueBlock:^(id value, id _weakSelf) {
            if(![value boolValue]){
                [Wself applyNeedsAfterImageSetWithFrameAt];
            }
        }];

        [self renderAfterImageSetWithFrameAt:selectedIndex imageSet:targetImageSet];
    }
}

//TODO: 어딘가 팩토리 쪽으로 옮김 : test : funnyman
- (STCapturedImageSet *)createEffectGIFResourcesFromName:(NSString *)presetName{

    NSArray * capturedImagesFromGifData;

    if([@"funnyman" isEqualToString:presetName]){
        NSData * gifData = [NSData dataWithContentsOfFile:[@"chrogif.gif" bundleFilePath]];
        if(!gifData){
            return nil;
        }

        UIImage * gifImages = UIImageWithAnimatedGIFData(gifData);

        NSArray * imagesToCreateImageSet = nil;
        if(gifImages.images.count > self.targetPhotoItem.sourceForCapturedImageSet.images.count){
            NSRange cuttingRange = NSMakeRange(0,self.targetPhotoItem.sourceForCapturedImageSet.images.count);
            imagesToCreateImageSet = [gifImages.images subarrayWithRange:cuttingRange];
        }else{
            //TODO: 이 경우 gif가 imageSet보다 길이 짧은때 정지 화면 아이템을 넣던지 imageSet에서 이미지를 빼던지 보정 처리 필요
        }

        capturedImagesFromGifData = [imagesToCreateImageSet mapWithIndex:^id(UIImage * image, NSInteger number) {
            NSURL * url = [[@(number) stringValue] URLForTemp:@"giff_effect_adding_resource_f" extension:@"png"];
            if([UIImagePNGRepresentation(image) writeToURL:url atomically:YES]){
                return [STCapturedImage imageWithImageUrl:url];
            }
            NSAssert(NO, @"write failed");
            return nil;
        }];
    }

    return [STCapturedImageSet setWithImages: capturedImagesFromGifData];
}

- (void)prepareEffectGIFLayersIfNeeded:(STCapturedImageSetDisplayLayer *)layerItem {
    if([layerItem.effect.uuid isEqualToString:@"funnyman"]){
        STCapturedImageSet * effectAppliedImageSet = [self createEffectGIFResourcesFromName:layerItem.effect.uuid];

        if(effectAppliedImageSet){
            layerItem.sourceImageSets = [layerItem.sourceImageSets arrayByAddingObjectsFromArray:@[effectAppliedImageSet]];
        }
    }
}
//TODO: 어딘가 팩토리 쪽으로 옮김 : test : funnyman

- (void)renderAfterImageSetWithFrameAt:(NSUInteger)index imageSet:(STCapturedImageSet *)imageSet{
    @autoreleasepool {
        if(!_afterImageView){
            _afterImageView = [[STGIFFCapturedImageSetAnimatableLayerEditView alloc] initWithSize:_previewView.size];
        }

        if(![[_previewView subviews] containsObject:_afterImageView]){
            [_previewView insertSubview:_afterImageView aboveSubview:self.previewView.contentView];
            [_afterImageView centerToParent];
        }
        //set default

        if(imageSet.extensionObject){
            //vaild check
            NSAssert([imageSet.extensionObject isKindOfClass:NSArray.class], @"imageSet.extensionObject is not NSArray");

            if(!_afterImageView.layers.count){
                for(STCapturedImageSetDisplayLayer * layerItem in (NSArray *)imageSet.extensionObject){
                    BOOL valid = layerItem
                            && [layerItem isKindOfClass:STCapturedImageSetDisplayLayer.class]
                            && layerItem.sourceImageSets.count;
                    NSAssert(valid, @"elements of imageSet.extensionObject is invalid item");

                    if(valid){
                        //recreate effects
                        if(layerItem.effect){
                            [self prepareEffectGIFLayersIfNeeded:layerItem];
                        }

                        [_afterImageView appendLayer:layerItem];
                    }
                }
                NSAssert(_afterImageView.layers.count, @"after image can't initialize");
            }

        }else{
            STCapturedImageSetAnimatableLayer * layerItem = [STCapturedImageSetAnimatableLayer itemWithSourceImageSets:@[imageSet]];

            if(layerItem.effect){
                [self prepareEffectGIFLayersIfNeeded:layerItem];
            }

            layerItem.frameIndexOffset = 0;
            STAfterImageLayersChromakeyEffect * effect = [[STAfterImageLayersChromakeyEffect alloc] init];
            effect.fitOutputSizeToSourceImage = YES;
            effect.uuid = @"funnyman";
            layerItem.effect = effect;

            STCapturedImageSetAnimatableLayer * layerItem2 = [STCapturedImageSetAnimatableLayer itemWithSourceImageSets:@[imageSet]];
            layerItem2.alpha = .4;
            layerItem2.frameIndexOffset = 0;
            layerItem2.effect = [STAfterImageLayersColorEffect effectWithColor:UIColorFromRGB(0xE2489F)];

            [_afterImageView appendLayer:layerItem];
            [_afterImageView appendLayer:layerItem2];

            imageSet.extensionObject = _afterImageView.layers;
        }

        _afterImageView.currentIndex = index;
    }
}

- (void)applyNeedsAfterImageSetWithFrameAt{
    NSArray <STCapturedImage *> * images = self.targetPhotoItem.sourceForCapturedImageSet.images;
    NSUInteger indexOfSlidingTargetImagesUrls = (NSUInteger) round((images.count-1) * _previewView.masterPositionSliderValue);

    [self.targetPhotoItem setAssigningIndexFromCapturedImageSet:indexOfSlidingTargetImagesUrls];
    [self.presenter beginAndAutomaticallyEndHighQualityContext];
    [self reloadSmoothly];
}

- (void)exitAfterImageEditingMode{

    [_afterImageView removeAllLayers];
}

- (void)reset {
    [self unlockUpdateZoomFromCurrentScrollOffset];
    [self setZoomInRatio:0 animation:NO];
    [self lockUpdateZoomFromCurrentScrollOffset];
    [_previewView reset:YES];
}

- (void)close; {
    [self removeAllObservations];

    [self closeTool];

    [self exitTransition];

    [super close];
}

- (STFilterItem *)applyAndClose; {
    NSAssert([self isCurrentTypeAllowedTool], @"self.isTypeAllowedTool");

    [self removeAllObservations];

    [self applyAndCloseTool];

    [self apply];

    [self exitTransition];

    return [super applyAndClose];
}

- (void)apply {
    self.targetPhotoItem.currentFilterItem = self.state.currentFocusedFilterItem;

    [self.targetPhotoItem loadPreviewImageWithCurrentEdited];
}

- (void)finishAllResources; {
    [self exitAfterImageEditingMode];

    [UIView setAnimationsEnabled:NO];
    [self reset];

    [self removeObserver];
    [_previewView finish];

    [super finishAllResources];

    [UIView setAnimationsEnabled:YES];
}

static NSString * observerToken = nil;
- (void)addObserver{
    @weakify(self)
    observerToken = [STGIFFAppSetting.get bk_addObserverForKeyPath:@keypath([STGIFFAppSetting get].autoEnhanceEnabledInEdit) task:^(id target) {
        self.targetPhotoItem.needsEnhance = [STGIFFAppSetting get].autoEnhanceEnabledInEdit;
        [self.presenter beginAndAutomaticallyEndHighQualityContext];
        [self reloadSmoothly];
    }];
}

- (void)removeObserver{
    if(observerToken){
        [STGIFFAppSetting.get bk_removeObserverForKeyPath:@keypath([STGIFFAppSetting get].autoEnhanceEnabledInEdit) identifier:observerToken];
    }
}

- (void)reloadSmoothly{
    if(self.type == STPhotoViewTypeLivePreview){
//            [_self reload];

    }else{
        if(![self.carousel.superview.subviews containsObject:_coverImageViewToReloadSmoothly]){
            if(!_coverImageViewToReloadSmoothly){
                _coverImageViewToReloadSmoothly = [[UIImageView alloc] initWithSize:self.previewView.size];
                _coverImageViewToReloadSmoothly.contentMode = UIViewContentModeScaleAspectFit;
            }

            [self clearCoverViewToReloadSmoothly];

            [self.carousel insertAboveToSuperview:_coverImageViewToReloadSmoothly];
            _coverImageViewToReloadSmoothly.image = ((STFilterPresenterItemView *)self.carousel.currentItemView).image;

            [self.presenter whenAllItemRenderFinished:^{
                [NSObject animate:^{
                    _coverImageViewToReloadSmoothly.easeInEaseOut.duration = .25;
                    _coverImageViewToReloadSmoothly.easeInEaseOut.alpha = 0;
                } completion:^(BOOL finished) {
                    [self clearCoverViewToReloadSmoothly];
                }];
            }];
            [self reload];

            //cancellation
            [[STMainControl sharedInstance] whenNewValueOnceOf:@keypath([STMainControl sharedInstance].mode) id:@"STPreview_mode_observer" changed:^(id value, id _weakSelf) {
                [self clearCoverViewToReloadSmoothly];
            }];
        }
    }
}

- (void)clearCoverViewToReloadSmoothly{
    [self.presenter whenAllItemRenderFinished:nil];
    if(_coverImageViewToReloadSmoothly.pop_animationKeys.count){
        [_coverImageViewToReloadSmoothly pop_removeAllAnimations];
    }
    _coverImageViewToReloadSmoothly.alpha = 1;
    _coverImageViewToReloadSmoothly.image = nil;
    [_coverImageViewToReloadSmoothly removeFromSuperview];
}

- (void)reloadOnlyCurrentScrolledViewWithHighQualityContext {
    [self.presenter beginAndAutomaticallyEndHighQualityContext];
    [self validateItemView:self.scrolledIndex reusingView:[self.carousel itemViewAtIndex:self.scrolledIndex]];
}

#pragma mark Tool
- (BOOL)isCurrentTypeAllowedTool {
    return self.type==STPhotoViewTypeEdit || self.type==STPhotoViewTypeEditAfterCapture;
}

- (void)startTool{
    NSAssert([self isCurrentTypeAllowedTool], @"self.isTypeAllowedTool");
    NSAssert(self.targetPhotoItem && self.carousel, @"self.targetPhoto && self.carousel");
    NSAssert(self.carousel.currentItemView, @"self.carousel.currentItemView == nil");
    NSAssert([self.carousel.currentItemView isKindOfClass:STFilterPresenterItemView.class], @"[self.carousel.currentItemView isKindOfClass:STFilterPresenterItemView.class] == NO");

    STFilterPresenterItemView * itemView = (STFilterPresenterItemView *)self.carousel.currentItemView;
    if(!itemView.image){
        Weaks
        [itemView whenNewValueOnceOf:@keypath(itemView.image) id:@"STFilterPresenterItemView.set.image" changed:^(id value, id _weakSelf) {
            if(value){
                [Wself.tool open:itemView.image view:Wself.carousel.superview];
            }
        }];
    }else{
        [self.tool open:itemView.image view:self.carousel.superview];
    }
}

- (STEditorResult *)applyAndCloseTool {
    NSAssert(self.targetPhotoItem, @"self.targetPhoto && self.carousel");
    if(!self.tool.isOpened){
        return nil;
    }

    STEditorResult * result = [self.tool apply];
    self.targetPhotoItem.toolResult = result;

    [self.tool dismiss];

    return result;
}

- (void)closeTool {
    [self.targetPhotoItem clearToolEdited];

    if(self.tool.isOpened){
        [self.tool dismiss];
    }
}

- (void)resetTool {
    [self.targetPhotoItem clearToolEdited];

    [self.tool reset];
}

- (BOOL)commandTool:(STEditorCommand *)command{
    BOOL succeed = NO;
    if(self.tool.isOpened){
        if([self.tool respondsToSelector:@selector(command:)]){
            succeed = [self.tool command:command];
        }
        self.targetPhotoItem.lastToolCommand = command;
    }
    return succeed;
}

- (id<STEditor>) tool{
    Class toolType = nil;
    if(self.type == STPhotoViewTypeEdit || self.type == STPhotoViewTypeEditAfterCapture){
        toolType = STTransformEditor.class;
    }

    if(_tool && [_tool.class isEqual:toolType]){
        return _tool;
    }

    return toolType ? (_tool = (id <STEditor>) [[toolType.class alloc] init]) : nil;
}

#pragma mark update display state

- (void)updateDisplayState; {
    [super updateDisplayState];

    STFilterItem * filterItem = self.items[self.scrolledIndex];
    [[STMainControl sharedInstance] setDisplayHomeScrolledFilters:self.scrolledIndex withCount:self.items.count];

    //change current selected filter in image edit mode
    if(_type == STPhotoViewTypeEdit || _type == STPhotoViewTypeEditAfterCapture){
        self.targetPhotoItem.currentFilterItem = filterItem;
    }

    [self updateZoomFromCurrentScrollOffset];
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel; {
    CGSize size = [self thumbnailImageSize];
    return carousel.isVertical ? size.height : size.width;
}

- (CGSize)thumbnailImageSizeByType:(STPhotoViewType) type {
    CGFloat sizeWidth = 0;
    if(type == STPhotoViewTypeGrid || type == STPhotoViewTypeMinimum){
        sizeWidth = _previewView.boundsWidth / kSTBuffPhotosGridCol;
    }else {
        sizeWidth = _previewView.boundsWidth;
    }
    return CGSizeMake(sizeWidth, sizeWidth * [[STElieCamera sharedInstance] outputVerticalRatio]);
}

- (CGSize)thumbnailImageSize {
    return [self thumbnailImageSizeByType:self.type];
}

#pragma mark Transition Edit
- (void)_dropTransitionView {
    if(_trasitionImageView){
        [_trasitionImageView st_coverRemove:NO];
        [_trasitionImageView removeFromSuperview];
        _trasitionImageView.image = nil;
        _trasitionImageView = nil;
    }
}

- (void)enterTransition:(void (^)(BOOL transitionFinished))completion {
    _transitionEntered = YES;

    switch (_type){
        case STPhotoViewTypeEdit:{
            Weaks
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            [self _beginTransitionEdit:^(BOOL transitionFinished) {
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];

                if(transitionFinished){
                    [Wself initFiltersIncludeDefault];
                    [Wself startForImage:Wself.targetPhotoItem with:Wself.carousel];
                    [Wself.presenter whenItemRenderFinished:^(NSInteger i) {
                        Strongs
                        [Sself.presenter whenItemRenderFinished:nil];
                        [Sself _endTransitionEdit];
                    }];
                }
            }];
        }
            break;
        case STPhotoViewTypeEditAfterCapture:{

            if(self.enterTransitionContext==STPreviewCollectorEnterTransitionContextFromCollectionViewItemSelected){
                Weaks

                [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                [self _beginTransitionEdit:^(BOOL transitionFinished) {
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];

                    if(transitionFinished){
                        [Wself initFiltersIncludeDefault];
                        [Wself startForImage:Wself.targetPhotoItem with:Wself.carousel];
                        [Wself.presenter whenItemRenderFinished:^(NSInteger i) {
                            Strongs
                            [Sself.presenter whenItemRenderFinished:nil];
                            [Sself _endTransitionEdit];
                        }];
                    }
                }];

            }else{
                Weaks

                [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                [self _beginTransitionEditAfterCapture:^(BOOL transitionFinished) {
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];

                    if(transitionFinished){
                        [Wself initFiltersIncludeDefault];
                        [Wself startForImage:Wself.targetPhotoItem with:Wself.carousel];

                        [Wself.presenter whenItemRenderFinished:^(NSInteger i) {
                            Strongs
                            [Sself.presenter whenItemRenderFinished:nil];

                            [Sself _endTransitionEditAfterCapture];

                            [[STElieStatusBar sharedInstance] stopProgress];
                        }];
                    }
                }];
            }
        }
            break;
        case STPhotoViewTypeReviewAfterAnimatableCapture:
            [self _beginTransitionReviewAfterAnimatableCapture:completion];
            break;
        case STPhotoViewTypeLivePreview:
            [self _beginTransitionLive:completion];
        default:
            break;
    }


}

#pragma mark enter - Edit
- (void)_beginTransitionEdit:(void (^)(BOOL finished))completion {
    [self _dropTransitionView];

    self.carousel.visible = NO;
    self.previewView.visibleControl = NO;
    
    STThumbnailGridViewCell * cell = [[STPhotoSelector sharedInstance].collectionView cellForPhotoItem:self.targetPhotoItem];
    NSAssert(cell, @"this transition context need collection view and its actual cell views");
    cell.visible = NO;

    _trasitedTargetCell = cell;

    UIView * preview = _previewView;
    _trasitionImageView = [[UIImageView alloc] initWithFrame:[[STPhotoSelector sharedInstance] convertRect:cell.frame fromView:[STPhotoSelector sharedInstance].collectionView]];
    _trasitionImageView.contentMode = UIViewContentModeScaleAspectFit;
    _trasitionImageView.image = self.targetPhotoItem.previewImage;
    _trasitionImageOriginalSize = _trasitionImageView.image.size;
    [[STPhotoSelector sharedInstance] addSubview:_trasitionImageView];
//    [self.carousel insertAboveToSuperview:_trasitionImageView];
    _trasitionImageView.easeInEaseOut.duration = .3;

    Weaks
    [NSObject animate:^{
        _trasitionImageView.easeInEaseOut.frame = preview.frame;
//        _trasitionImageView.easeInEaseOut.frame = [[STPhotoSelector sharedInstance] convertRect:preview.frame toView:self.carousel];
    } completion:completion];
}

- (void)_endTransitionEdit {
    self.carousel.visible = YES;
    self.previewView.visibleControl = YES;

    _trasitionImageView.visible = NO;
    _trasitionImageView.image = nil;
}

#pragma mark enter - EditAfterCapture
- (void)_beginTransitionEditAfterCapture:(void (^)(BOOL finished))completion {
    [self _dropTransitionView];

    self.carousel.visible = NO;
    self.previewView.visibleControl = NO;

    if(!_trasitionImageView){
        _trasitionImageView = [[UIImageView alloc] initWithFrame:_previewView.initialFrame];
    }
    _trasitionImageView.contentMode = UIViewContentModeScaleAspectFit;
    _trasitionImageView.image = self.targetPhotoItem.previewImage;
    _trasitionImageOriginalSize = _trasitionImageView.image.size;

    [self.carousel insertAboveToSuperview:_trasitionImageView];

    NSTimeInterval const enteringEffectDuration = .7;

    [_trasitionImageView st_coverBlur:NO styleDark:NO completion:nil];
    [_trasitionImageView st_coverRemove:YES promiseIfAnimationFinished:YES duration:enteringEffectDuration finished:^{
        !completion?:completion(YES);
    }];

//    _trasitionImageView.scaleXYValue = 1.025;
//    _trasitionImageView.pop_duration = enteringEffectDuration;
//    [NSObject animate:^{
//        _trasitionImageView.easeInEaseOut.scaleXYValue = 1;
//    } completion:nil];
}

- (void)_endTransitionEditAfterCapture {
    self.carousel.visible = YES;
    self.previewView.visibleControl = YES;

    _trasitionImageView.visible = NO;
    _trasitionImageView.image = nil;
}

#pragma mark enter - ReviewAfterAnimatableCapture

- (void)_beginTransitionReviewAfterAnimatableCapture:(void (^)(BOOL finished))completion {
    [self _dropTransitionView];

    self.carousel.visible = NO;

    _trasitionImageView = [[UIImageView alloc] initWithFrame:_previewView.initialFrame];
    _trasitionImageView.contentMode = UIViewContentModeScaleAspectFit;
    _trasitionImageView.image = self.targetPhotoItem.previewImage;
    _trasitionImageOriginalSize = _trasitionImageView.image.size;

//    [[STPhotoSelector sharedInstance] addSubview:_trasitionImageView];
    [[self st_rootUVC].view addSubview:_trasitionImageView];

    _trasitionImageView.scaleXYValue = 0;
    [STStandardUX setAnimationFeelToRelaxedSpring:_trasitionImageView];
    Weaks
    [NSObject animate:^{
        _trasitionImageView.spring.scaleXYValue = 1;
    } completion:completion];
}

- (void)_endTransitionReviewAfterAnimatableCapture {
    self.carousel.visible = YES;

    _trasitionImageView.visible = NO;
    _trasitionImageView.image = nil;
}

#pragma mark enter - Live
- (void)willEnterTransitionLive {
    if(!_trasitionImageView){

        _trasitionImageView = [[UIImageView alloc] initWithFrame:_previewView.bounds];
        _trasitionImageView.contentMode = UIViewContentModeScaleToFill;
    }

    Weaks
//    dispatch_async([STQueueManager sharedQueue].uiProcessing, ^{
//        UIImage * currentImage = [Wself st_cachedImage:kBlurredImageKey useDisk:YES storeWhenLoad:NO init:^UIImage * {
//            return [[STElieCamera sharedInstance] currentImageAsThumbnailPreview];
//        }];
//
//        [Wself st_runAsMainQueueAsync: ^{
//            Strongs
//            Sself->_trasitionImageView.image = currentImage;
//        }];
//    });

    [_previewView addSubview:_trasitionImageView];
    [_trasitionImageView st_coverBlur:NO styleDark:YES completion:nil];
}

- (void)cancelPreTransitionLive {
    [self _dropTransitionView];
}

- (void)_beginTransitionLive:(void (^)(BOOL finished))completion {
    [self willEnterTransitionLive];
    !completion?:completion(YES);
}

- (void)_endTransitionLive {
    Weaks
    if(!_trasitionImageView){
        return;
    }

    [_trasitionImageView pop_removeAllAnimations];
    _trasitionImageView.easeInEaseOut.duration = .3;
    [NSObject animate:^{
        _trasitionImageView.easeInEaseOut.alpha = 0;
    } completion:^(BOOL finished) {
        [Wself _dropTransitionView];
    }];
}

#pragma mark exit
- (void)exitTransition {
    if(!_transitionEntered){
        return;
    }

    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    void(^completion)(BOOL) = ^(BOOL finished) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    };

    switch (_type){
        case STPhotoViewTypeEdit:
            switch (self.exitTransitionContext){
                case STPreviewCollectorExitTransitionContextSaveToLibraryFromEditedPhotoInRoom:
                    [self _exitTransitionEditContextSaveToLibraryFromEditedPhotoInRoom:completion];
                    break;
                case STPreviewCollectorExitTransitionContextDeletingInExport:
                    [self _exitTransitionEditContextDeletingInExport:completion];
                    break;
                default:
                    [self _exitTransitionEdit:completion];
                    break;
            }
            break;

        case STPhotoViewTypeEditAfterCapture:
            switch (self.exitTransitionContext){
                case STPreviewCollectorExitTransitionContextSaveToLibraryFromEditedPhotoInRoom:
                    [self _exitTransitionEditAfterCaptureContextSaveToLibraryFromEditedPhotoInRoom:completion];
                    break;
                case STPreviewCollectorExitTransitionContextCancelInEdit:
                    [self _exitTransitionEditAfterCaptureContextCancelInEdit:completion];
                    break;
                default:{
                    if(self.enterTransitionContext==STPreviewCollectorEnterTransitionContextFromCollectionViewItemSelected){
                        [self _exitTransitionEdit:completion];
                    }else{
                        completion(YES);
                    }
                }
                    break;
            }
            break;

        case STPhotoViewTypeLivePreview:
            [self _exitTransitionLive:completion];
            break;

        default:
            completion(YES);
            break;
    }

    self.exitTransitionContext = STPreviewCollectorExitTransitionContextDefault;
    self.enterTransitionContext = STPreviewCollectorEnterTransitionContextDefault;

    _transitionEntered = NO;
}

#pragma mark exit Edit
- (void)_exitTransitionEdit:(void (^)(BOOL finished))completion {
    UIImage * itemViewedImage = ((STFilterPresenterItemView *)self.carousel.currentItemView).image;
    if(itemViewedImage){
        _trasitionImageView.image = itemViewedImage;
    }else{
        _trasitionImageView.image = self.targetPhotoItem.previewImage;
    }

    CGSize resultImageSize = _trasitionImageView.image.size;
    BOOL imageSizeChanged = !CGSizeEqualToSize(_trasitionImageOriginalSize, resultImageSize);

    _trasitionImageView.visible = YES;
    _trasitionImageView.alpha = 1;

    Weaks

    /*
     * start exit
     */
    [[STPhotoSelector sharedInstance].collectionView performBatchUpdates:^{
        //imageSizeChanged
        if(Wself.targetPhotoItem.edited){
            [[STPhotoSelector sharedInstance].collectionView reloadItemsAtIndexPaths:@[[[STPhotoSelector sharedInstance].collectionView indexPathForPhotoItem:Wself.targetPhotoItem]]];
        }

    } completion:^(BOOL finished) {
        Strongs
        if(finished){
            /*
            * revert cell
            */
            UIView *destCell = [[STPhotoSelector sharedInstance].collectionView cellForPhotoItem:Sself.targetPhotoItem];
            destCell.visible = NO;

            //if new cell
            if(![Sself->_trasitedTargetCell isEqual:destCell]){
                Sself->_trasitedTargetCell.visible = YES;
                Sself->_trasitedTargetCell = nil;
            }

            [NSObject animate:^{
                if(destCell){
                    _trasitionImageView.easeInEaseOut.frame = [[STPhotoSelector sharedInstance] convertRect:destCell.frame fromView:[STPhotoSelector sharedInstance].collectionView];
                }else {
                    _trasitionImageView.easeInEaseOut.scaleXYValue = .4;
                    _trasitionImageView.easeInEaseOut.alpha = 0;
                }

            } completion:^(BOOL _finished) {
                if(_finished){
                    [Wself _dropTransitionView];
                }
                UIView *_destCell = [[STPhotoSelector sharedInstance].collectionView cellForPhotoItem:Wself.targetPhotoItem];
                _destCell.visible = YES;
            }];
            !completion?:completion(YES);
        }
    }];
}

- (void)_exitTransitionEditContextSaveToLibraryFromEditedPhotoInRoom:(void (^)(BOOL finished))completion {
    _trasitionImageView.image = self.targetPhotoItem.previewImage;
    _trasitionImageView.visible = YES;
    _trasitionImageView.alpha = 1;

    [[STPhotoSelector sharedInstance].collectionView cellForPhotoItem:self.targetPhotoItem].visible = YES;

    Weaks
    [[STPhotoSelector sharedInstance].collectionView performBatchUpdates:^{
        //imageSizeChanged
        if(Wself.targetPhotoItem.edited){
            //https://fabric.io/jessi/ios/apps/com.stells.eliew/issues/56e5cb98ffcdc04250cee5ab
            NSIndexPath * indexPath = [[STPhotoSelector sharedInstance].collectionView indexPathForPhotoItem:Wself.targetPhotoItem];
            if(indexPath){
                [[STPhotoSelector sharedInstance].collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        }

    } completion:^(BOOL finished) {
        Strongs
        if(finished){
            [Sself->_trasitionImageView transitionZeroScaleTo:[STMainControl sharedInstance].subControl.rightButton presentImage:nil completion:^(UIView *trasitionView, BOOL _finished) {
                [Sself _dropTransitionView];

                !completion?:completion(YES);
            }];
        }
    }];
}

- (void)_exitTransitionEditContextDeletingInExport:(void (^)(BOOL finished))completion {
    _trasitionImageView.image = self.targetPhotoItem.previewImage;
    _trasitionImageView.visible = YES;
    _trasitionImageView.alpha = 1;

    Weaks
    [_trasitionImageView transitionZeroScaleTo:[STElieStatusBar sharedInstance] presentImage:nil completion:^(UIView *trasitionView, BOOL _finished) {
        [Wself _dropTransitionView];

        !completion?:completion(YES);
    }];
}

#pragma mark exit EditAfterCapture
- (void)_exitTransitionEditAfterCaptureContextCancelInEdit:(void (^)(BOOL finished))completion {
    !completion?:completion(YES);

//    _trasitionImageView.image = self.targetPhotoItem.previewImage;
//    _trasitionImageView.visible = YES;
//    _trasitionImageView.alpha = 1;
//
//    _trasitionImageView.scaleXYValue =1;
//
//    [NSObject animate:^{
//        _trasitionImageView.easeInEaseOut.scaleXYValue = 0;
//    } completion:completion];
}

- (void)_exitTransitionEditAfterCaptureContextSaveToLibraryFromEditedPhotoInRoom:(void (^)(BOOL finished))completion {
    !completion?:completion(YES);

    //TODO doCancelEdit 을 실행시에 에니메이션이 끝날떄까지 기다리지 읺으면 어차피 보이지 않음
//    _trasitionImageView.image = self.targetPhotoItem.previewImage;
//    _trasitionImageView.visible = YES;
//    _trasitionImageView.alpha = 1;
//
//    [_trasitionImageView transitionZeroScaleTo:[STMainControl sharedInstance].subControl.rightButton presentImage:nil completion:^(UIView *trasitionView, BOOL _finished) {
//        [self _dropTransitionView];
//
//        !completion?:completion(YES);
//    }];
}

#pragma mark exit Live
- (void)_exitTransitionLive:(void (^)(BOOL finished))completion {
    [self _dropTransitionView];

//    [self st_cachedImage:kBlurredImageKey useDisk:YES init:^UIImage * {
//        return [STElieCamera sharedInstance].currentImageAsThumbnailPreview;
//    }];

    !completion?:completion(YES);
}

#pragma mark BEGIN ScrollZoomEffect
- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform {
    /*
     * iCarouselTypeLinear + Zoom
     *
     * CGFloat distance = 1150.0f; //number of pixels to move the items away from camera
     * CGFloat z = - fminf(1.0f, fabs(offset)) * distance;
     */
    CGFloat spacing = [carousel.delegate carousel:carousel valueForOption:iCarouselOptionSpacing withDefault:1.0];
    if (carousel.vertical)
    {
        return CATransform3DTranslate(transform, 0.0, offset * carousel.itemWidth * spacing, _zValueFor3DTransform);
    }
    else
    {
        return CATransform3DTranslate(transform, offset * carousel.itemWidth * spacing, 0.0, _zValueFor3DTransform);
    }
}

static CGFloat const MAX_SCROLL_OFFSET_CONSTANT = .5;
static CGFloat const ZOOM_ACCELATION_WALL_CONSTANT = 40;
static CGFloat const DELAY_FOR_ALLOWING_FASTSCROLL = .3;
static CGFloat const MAX_SCROLL_SPEED_BY_ZOOMIN = 2;

- (void)lockUpdateZoomFromCurrentScrollOffset{
    [self willBeginUpdateZoom];
    _lockUpdateScrollZoomWhileResetScroll = YES;
}

- (void)unlockUpdateZoomFromCurrentScrollOffset{
    _lockUpdateScrollZoomWhileResetScroll = NO;
}

- (void)updateZoomFromCurrentScrollOffset{
    if(_lockUpdateScrollZoomWhileResetScroll){
        if(self.scrolledIndex==0){
//            [self willEndUpdateZoom:YES];
        }
        return;
    }

    CGFloat currentScrollOffset = self.carousel.scrollOffset;
    currentScrollOffset *= currentScrollOffset/ZOOM_ACCELATION_WALL_CONSTANT;//AGKEaseInWithBezier(currentScrollOffset/ZOOM_ACCELATION_WALL_CONSTANT);
    CGFloat offsetRatio = fabsf(_previousScrollOffsetForZoom - currentScrollOffset);
    CGFloat zoomProgress = AGKRemapToZeroOneAndClamp(offsetRatio, 0, MAX_SCROLL_OFFSET_CONSTANT);

    if(userNeedsFastScrolling){
        if(_previousScrollOffsetForZoom >0 && self.zoomInRatio < zoomProgress){
            [self setZoomInRatio:zoomProgress animation:YES];
        }
    }

    _previousScrollOffsetForZoom = currentScrollOffset;
}

- (void)setZoomInRatio:(CGFloat)progress animation:(BOOL)animation{
    CGFloat zValueForZoom = self.zConstantValueForZoom * progress;
    BOOL zoomIn = -zValueForZoom > self.zoomInRatio;
    _zValueFor3DTransform = zValueForZoom;

    Weaks
    if([self.carousel respondsToSelector:@selector(transformItemViews)]){
        if(animation){

            [UIView animateWithDuration:zoomIn ? .5 :.3
                                  delay:0
                 usingSpringWithDamping:1
                  initialSpringVelocity:0
                                options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowAnimatedContent
                             animations:^{
                [Wself.carousel performSelector:@selector(transformItemViews)];
            } completion:^(BOOL finished) {

            }];

        }else{
            [self.carousel performSelector:@selector(transformItemViews)];
        }
    }

    self.carousel.scrollSpeed = 1 + AGKRemap(self.zoomInRatio,0,1,0,MAX_SCROLL_SPEED_BY_ZOOMIN);
}

- (CGFloat)zoomInRatio {
    return _zValueFor3DTransform/self.zConstantValueForZoom;
}

- (CGFloat)zConstantValueForZoom{
    return -1600 * ([self carousel:self.carousel valueForOption:iCarouselOptionVisibleItems withDefault:5]/5);
}

- (void)willBeginUpdateZoom {
    [self st_clearPerformOnceAfterDelay:@"setzoom.delay"];

    self.previewView.visibleControl = NO;
}

- (void)willEndUpdateZoom:(BOOL)delay {
    [self st_performOnceAfterDelay:@"setzoom.delay" interval: delay ? AGKEaseOutWithBezier(AGKRemap(self.zoomInRatio, 0, 1, 0, 1.4)) : 0 block:^{
        [self didEndUpdateZoomAndReset];
    }];
    _previousScrollOffsetForZoom = 0;
}

- (void)didEndUpdateZoomAndReset{
    [self reloadOnlyCurrentScrolledViewWithHighQualityContext];
    [self setZoomInRatio:0 animation:YES];
    [self unlockUpdateZoomFromCurrentScrollOffset];

    self.previewView.visibleControl = YES;
}

static CGFloat beginDragginOffset;
static BOOL userNeedsFastScrolling;

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel; {
    [super carouselDidEndScrollingAnimation:carousel];
    [self willEndUpdateZoom:YES];

#pragma mark fastscrolling
    [self st_performOnceAfterDelay:@"previewcollection.fastscrolling" interval:DELAY_FOR_ALLOWING_FASTSCROLL block:^{
        userNeedsFastScrolling = NO;
    }];
#pragma mark fastscrolling
}

- (void)carouselWillBeginDragging:(iCarousel *)carousel; {
    [super carouselWillBeginDragging:carousel];

    [self willBeginUpdateZoom];

    [[NSNotificationCenter defaultCenter] postNotificationName:STPreviewCollectorNotificationPreviewBeginDragging object:nil];

#pragma mark fastscrolling
    beginDragginOffset = carousel.scrollOffset;

    [self st_clearPerformOnceAfterDelay:@"previewcollection.fastscrolling"];
#pragma mark fastscrolling
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate {
    [super carouselDidEndDragging:carousel willDecelerate:decelerate];
}

- (void)carouselWillBeginDecelerating:(iCarousel *)carousel {
    [super carouselWillBeginDecelerating:carousel];

#pragma mark fastscrolling
    CGFloat velocity = carousel.scrollOffset-beginDragginOffset;
    if(fabsf(velocity) > 1){
        return;
    }

    if(!userNeedsFastScrolling){
        [self lockUpdateZoomFromCurrentScrollOffset];
//        [carousel scrollToOffset:velocity>=0 ? ceilf(carousel.scrollOffset) : floorf(carousel.scrollOffset) duration:0];
        [carousel scrollToItemAtIndex:(NSInteger) (velocity >= 0 ? ceilf(carousel.scrollOffset) : floorf(carousel.scrollOffset)) animated:YES];

    }else{
        [self unlockUpdateZoomFromCurrentScrollOffset];
    }

    userNeedsFastScrolling = YES;
#pragma mark fastscrolling
}

- (void)carouselDidEndDecelerating:(iCarousel *)carousel {
    [super carouselDidEndDecelerating:carousel];
}

#pragma mark END ScrollZoomEffect

@end