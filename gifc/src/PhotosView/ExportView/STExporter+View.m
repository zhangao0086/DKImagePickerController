//
// Created by BLACKGENE on 2016. 4. 5..
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STExporter+View.h"
#import "STPhotoItem+UIAccessory.h"
#import "NSGIF.h"
#import "STPhotoItem+ExporterIO.h"
#import "STExporter+IO.h"
#import "STExportView.h"
#import "STStandardReachableButton.h"
#import "STHome.h"
#import "R.h"
#import "TTTAttributedLabel.h"
#import "STStandardNavigationButton.h"
#import "BlocksKit.h"
#import "UIImageView+WebCache.h"
#import "STExportContentView.h"
#import "NSArray+STUtil.h"
#import "NSNumber+STUtil.h"
#import "UIImage+STUtil.h"
#import "STExporter+ConfigGIF.h"
#import "STExporter+IOGIF.h"
#import "STPhotoItem+STExporterIOGIF.h"

@implementation STExporterViewOption
@end

@implementation STExporterViewSelectionOptionItem
@end

@implementation STExporter (View)

DEFINE_ASSOCIATOIN_KEY(kSelectedOptionItem)
- (STExporterViewSelectionOptionItem *)selectedOptionItem {
    return [self bk_associatedValueForKey:kSelectedOptionItem];
}

- (void)setSelectedOptionItem:(STExporterViewSelectionOptionItem *)optionItem {
    [self willChangeValueForKey:@keypath(self.selectedOptionItem)];
    [self bk_associateValue:optionItem withKey:kSelectedOptionItem];
    [self didChangeValueForKey:@keypath(self.selectedOptionItem)];
}

- (id)createPresentableObjectByOptionItem:(STExporterViewSelectionOptionItem *)item sizeIfNeeded:(CGSize)size{
    if (item.thumbnailAsURL) {
        UIImageView *view = [[UIImageView alloc] initWithSize:size];
        view.contentMode = UIViewContentModeScaleAspectFit;
        [view sd_setImageWithURL:item.thumbnailAsURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            view.image = [image clipAsCircle:image.size.width];
        }];
        return view;
    }
    else if (item.thumbnailAsImage) {
        return item.thumbnailAsImage;

    }else if (item.thumbnailAsImageName) {
        return item.thumbnailAsImageName;
    }

    NSAssert(NO, @"given STExporterViewSelectionOptionItem is empty or not supported.");
    return nil;
}

- (void)openExporterView:(void (^)(void))tryExportBlock {
    [self openExporterView:self.viewOption tryExport:tryExportBlock];
}

- (void)openExporterView:(STExporterViewOption *)option tryExport:(void (^)(void))tryExportBlock {
    NSParameterAssert(tryExportBlock);

    //set options
    STStandardButton * button = option.relatedButton;
    NSArray * exportOptionItems = option.exportOptionItems;
    NSUInteger selectedExportOptionIndex = option.selectedExportOptionIndex;
    NSArray * cancelIconImageNames = option.cancelIconImageNames;
    STExporterViewOptionCancelHandler canceledBlock = option.cancelHandler;

    Weaks
    STExporterViewSelectionOptionItem * selectedOptionItem = [exportOptionItems st_objectOrNilAtIndex:selectedExportOptionIndex];

    const BOOL exportOptionSelectRequired = exportOptionItems.count>0;
    /*
     * create view to GIF export
     */
    STStandardNavigationButton * gifExportSelectButton;

    if(!option.exportingGIFButtonDisabled && [self photoItemsCanExportGIF]){

        gifExportSelectButton = [STStandardNavigationButton mainSmallSize];
        gifExportSelectButton.synchronizeCollectableSelection = NO;
        gifExportSelectButton.autoRetractWhenSelectCollectableItem = NO;
        gifExportSelectButton.autoUXLayoutWhenExpanding = YES;

        if(exportOptionSelectRequired){
            // as a collectable
            [gifExportSelectButton setCollectables:@[[R ico_animatable]] colors:nil bgColors:nil size:[STStandardLayout sizeSubAssistance] style:STStandardButtonStylePTBT backgroundStyle:STStandardButtonStyleSkipImageInvertNormalDimmed];
            [gifExportSelectButton setCollectablesUserInteractionEnabled:YES];
            gifExportSelectButton.collectableToggleEnabled = YES;
            WeakAssign(gifExportSelectButton)
            [gifExportSelectButton whenCollectableSelected:^(STStandardButton *collectaleButton, NSUInteger index) {
                BOOL tryExport = gifExportSelectButton.collectableSelectedState;
                if(tryExport){
                    gifExportSelectButton.collectableSelectedState = NO;
                    [gifExportSelectButton.currentCollectableButton startAlert];
                }

                [Wself exportAndPresentGIFsInView:tryExport progress:^(CGFloat progress) {
                    weak_gifExportSelectButton.progressCollectableBackground = progress;

                } completion:^(NSArray *gifURLs, NSArray *succeedItems, NSArray *errorItems) {
                    if(gifURLs.count){
                        weak_gifExportSelectButton.collectableSelectedState = YES;
                    }else{
                        weak_gifExportSelectButton.collectableSelectedState = NO;
                        [STStandardUX expressDenied:weak_gifExportSelectButton];
                    }
                    weak_gifExportSelectButton.progressCollectableBackground = 0;
                    [weak_gifExportSelectButton.currentCollectableButton stopAlert];
                }];
            }];
            [gifExportSelectButton expand:NO];

        }else{
            // as a button
            [gifExportSelectButton setButtons:@[[R ico_animatable]] colors:@[[STStandardUI pointColor]] style:STStandardButtonStylePTTP];
            gifExportSelectButton.backgroundViewAsColoredImage = [STStandardUI buttonColorBackgroundOverlay];
            gifExportSelectButton.backgroundView.alpha = [STStandardUI alphaForGlassLikeOverlayButtonBackground];
            gifExportSelectButton.toggleEnabled = YES;
            [gifExportSelectButton whenToggled:^(STStandardButton *selectedView, BOOL selected) {

#pragma mark Export GIF
                BOOL tryExport = selected;
                if(tryExport){
                    gifExportSelectButton.selectedState = NO;
                    [gifExportSelectButton startAlert];
                }

                [Wself exportAndPresentGIFsInView:tryExport progress:^(CGFloat progress) {
                    gifExportSelectButton.pieProgress = progress;

                } completion:^(NSArray *gifURLs, NSArray *succeedItems, NSArray *errorItems) {
                    [gifExportSelectButton stopAlert];

                    gifExportSelectButton.pieProgress = 0;
                    if(gifURLs.count){
                        gifExportSelectButton.selectedState = YES;
                    }else{
                        gifExportSelectButton.selectedState = NO;
                        [STStandardUX expressDenied:gifExportSelectButton];
                    }
                }];
            }];
        }
        gifExportSelectButton.titleLabelPositionedGapFromButton = [STStandardLayout gapForButtonBottomToTitleLabel]/1.5f;
        gifExportSelectButton.titleText = @"GIF";
    }

    /*
     * create option view to if user provide option items
     */
    STCollectableView *exportOptionSelectButton;
    TTTAttributedLabel * blogNameLabel;
    WeakAssign(blogNameLabel)
    if(exportOptionSelectRequired){
        //create option view
        exportOptionSelectButton = [[STCollectableView alloc] initWithSize:[STStandardLayout sizeMainSmall]];
        exportOptionSelectButton.fitViewsImageToBounds = YES;
        exportOptionSelectButton.excludeCurrentSelectedCollectableWhenExpand = YES;
        if ([exportOptionItems respondsToSelector:@selector(bk_map:)]) {
            [exportOptionSelectButton setViews:[exportOptionItems bk_map:^id(STExporterViewSelectionOptionItem * optionItem) {
                return [self createPresentableObjectByOptionItem:optionItem sizeIfNeeded:[STStandardLayout sizeMainSmall]];

            }] radialItemPresentableObjects:[exportOptionItems bk_map:^id(STExporterViewSelectionOptionItem * optionItem) {
                id presentableObject = [self createPresentableObjectByOptionItem:optionItem sizeIfNeeded:[STStandardLayout sizeSub]];

                if([presentableObject isKindOfClass:UIImageView.class]){
                    UIImageView * view = (UIImageView *)presentableObject;

                    TTTAttributedLabel * _titleLabel = [[TTTAttributedLabel alloc] initWithSizeWidth:0];
                    _titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:14.0f];
                    _titleLabel.textColor = [STStandardUI textColorLighten];
                    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                    _titleLabel.userInteractionEnabled = NO;
                    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    _titleLabel.textAlignment = NSTextAlignmentRight;
                    _titleLabel.numberOfLines = 1;
                    [view addSubview:_titleLabel];
                    _titleLabel.text = optionItem.label;
                    [_titleLabel sizeToFit];
                    _titleLabel.right = view.left - view.width/3;
                    [_titleLabel centerToParentVertical];
                }

                return presentableObject;
            }]];
        }
        [exportOptionSelectButton setValuesMap:exportOptionItems];
        exportOptionSelectButton.currentMappedValue = selectedOptionItem;
        exportOptionSelectButton.allowSelectCollectableAsBubblingTapGesture = YES;
        [exportOptionSelectButton setUserInteractionToSelectCollectables];
        exportOptionSelectButton.collectableView.blockForCustomTransformToEachCenterPoint = ^CGAffineTransform(UIView *_view, NSUInteger index) {
            CGFloat height = _view.height;
            return CGAffineTransformMakeTranslation(0, -(height+((index==0?exportOptionSelectButton.height:height)/4)) * (index+1));
        };

        //create blog name label
        blogNameLabel = [[TTTAttributedLabel alloc] initWithSizeWidth:exportOptionSelectButton.width*1.5f];
        blogNameLabel.visible = !gifExportSelectButton;
        blogNameLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:14.0f];
        blogNameLabel.textColor = [STStandardUI textColorLighten];
        blogNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        blogNameLabel.userInteractionEnabled = NO;
        blogNameLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        blogNameLabel.textAlignment = NSTextAlignmentCenter;
        blogNameLabel.numberOfLines = 1;
        [exportOptionSelectButton addSubview:blogNameLabel];
        blogNameLabel.text = selectedOptionItem.label;
        CGSize size = blogNameLabel.size;
        [blogNameLabel sizeToFit];
        size.height = blogNameLabel.height;
        blogNameLabel.size = size;
        blogNameLabel.bottom = exportOptionSelectButton.height + exportOptionSelectButton.height/2.5f;
        [blogNameLabel centerToParentHorizontal];

        //add event
        [exportOptionSelectButton whenSelected:^(STSelectableView *selectedView, NSInteger index) {
            [self setSelectedOptionItem:selectedView.currentMappedValue];

            weak_blogNameLabel.text = self.selectedOptionItem.label;
        }];
        exportOptionSelectButton.collectableView.blockForWillExpand = ^(BOOL animation) {
            [[STExportView view].contentView st_coverBlur:animation styleDark:YES completion:nil];

            [gifExportSelectButton retract:NO];

            [[STExportView view] whenLongTapAsTapDownUp:^(UILongPressGestureRecognizer *sender, CGPoint location) {
                [[STExportView view] whenLongTapped:nil];
                [exportOptionSelectButton retract];
            } changed:nil ended:nil];
        };
        exportOptionSelectButton.collectableView.blockForWillRetract = ^(BOOL animation) {
            [[STExportView view].contentView st_coverRemove:animation];

            [gifExportSelectButton expand:NO];
        };
    }

    //create optionview wrapper
    STUIView * optionView;
    if(gifExportSelectButton){
        if(exportOptionSelectButton){
            optionView = [[STUIView alloc] initWithSizeWidth:[STStandardLayout widthMainSmall]+[STStandardLayout widthSubAssistance]*2];
            optionView.touchInsidePolicy = STUIViewTouchInsidePolicyContentInside;
            [optionView addSubview:gifExportSelectButton];
            [gifExportSelectButton centerToParent];

            [optionView addSubview:exportOptionSelectButton];
            [exportOptionSelectButton centerToParent];
        }else{
            optionView = gifExportSelectButton;
        }
    }else{
        optionView = exportOptionSelectButton;
    }

    /*
     * open share view
     */
    [STExportView open:button
                target:self
            optionView:optionView
    cancelOptionsIcons:cancelIconImageNames
  cancelOptionSelected:^(STStandardButton *collecableButton, NSUInteger index) {

      !canceledBlock?: canceledBlock(index);

  } willOpen:^(STExportView *view) {
                [exportOptionSelectButton setNeedsDisplay];

            } didOpen:^(STExportView *view) {

                /*
                 * gif button enable if it already exported.
                 */
                if([self shouldExportGIF]){
                    if(gifExportSelectButton.collectableView.count){
                        gifExportSelectButton.collectableSelectedState = YES;
                    }else{
                        gifExportSelectButton.selectedState = YES;
                    }
                    [STExportView enableGIFExport:YES];
                }

            } tried:^{

                !tryExportBlock?:tryExportBlock();

            } canceled:^{
                [Wself dispatchFinshed:STExportResultCanceled];

            } willClose:^(BOOL _i) {

                //clean presentables and cancel load operations
                if(exportOptionSelectButton){
                    for(id index in [@(exportOptionSelectButton.count) st_intArray]){
                        NSInteger i = [index integerValue];
                        id presentableObject = [exportOptionSelectButton presentableObjectAtIndex:i];
                        if([presentableObject isKindOfClass:UIImageView.class]){
                            UIImageView * imageView = (UIImageView *)presentableObject;
                            [imageView sd_cancelCurrentImageLoad];
                        }
                        UIView * imageViewCollectableView = [exportOptionSelectButton.collectableView itemViewAtIndex:i];
                        if([imageViewCollectableView isKindOfClass:UIImageView.class]){
                            [(UIImageView *)imageViewCollectableView sd_cancelCurrentImageLoad];
                        }
                    }
                }

                //remove selecableviews
                if([optionView isKindOfClass:STSelectableView.class]){
                    [(STSelectableView *)optionView clearViews];
                }else{
                    for(UIView * view in optionView.subviews){
                        if([view isKindOfClass:STSelectableView.class]){
                            [(STSelectableView *)view clearViews];
                        }
                        [view removeFromSuperview];
                    }
                }

            } didClose:^(BOOL success) {

                [Wself dispatchFinshed:success ? STExportResultSucceed : STExportResultFailed];
            }];
}

- (void)exportAndPresentGIFsInView:(BOOL)export progress:(void (^)(CGFloat))progressBlock completion:(void(^)(NSArray *gifURLs, NSArray *succeedItems, NSArray *errorItems))completionBlock{
    BOOL enableGIFExport = export && self.photoItemsCanExportGIF.count>0;
    if(enableGIFExport){

        [STExportView view].okButton.userInteractionEnabled = NO;

        NSArray <STPhotoItem *> * photoItems = self.photoItemsCanExportGIF;

        //set progresshandler
        NSUInteger totalCount = photoItems.count;

        //set a option to create gif
        Weaks
        for (STPhotoItem * item in photoItems){
            WeakAssign(item)
            item.exportGIFRequest = [STExporter createRequestExportGIF:item];
            item.exportGIFRequest.progressHandler = ^(double progress, NSUInteger offset, NSUInteger length, CMTime time, BOOL *stop, NSDictionary *frameProperties) {
                //TODO: interrupt if exporter has been finished
                dispatch_async(dispatch_get_main_queue(),^{
                    CGFloat blockSize = 1/(CGFloat)totalCount;
                    CGFloat _progress = (blockSize * (CGFloat)[Wself.photoItemsCanExportGIF indexOfObject:weak_item]) + (CGFloat) (blockSize * progress);

                    !progressBlock?:progressBlock(_progress);
                });
            };
        }

        BOOL forceReload = NO;
#if DEBUG
        forceReload = YES;
#endif
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

        [self exportGIFs:photoItems processChunk:1 forceReload:forceReload progress:^(NSURL *gifURL, STPhotoItem * item, NSUInteger count, NSUInteger total) {

        } completion:^(NSArray *gifURLs, NSArray *succeedItems, NSArray *errorItems) {

            [[UIApplication sharedApplication] endIgnoringInteractionEvents];

            !completionBlock?:completionBlock(gifURLs, succeedItems, errorItems);

            [STExportView view].okButton.userInteractionEnabled = YES;

            [STExportView enableGIFExport:YES];
        }];
    }else{
        [self cleanAllExportedResults];
        [STExportView enableGIFExport:NO];
    };
}

@end