//
// Created by BLACKGENE on 2014. 8. 25..
// Copyright (c) 2014 Eliecam. All rights reserved.
//
#import "NSArray+BlocksKit.h"
#import <Photos/Photos.h>
#import "STPhotoSelector.h"
#import "STFilterItem.h"
#import "NSIndexPath+STIndexPathForSingleSection.h"
#import "STAssetsLibraryManager.h"
#import "NSObject+STThreadUtil.h"
#import "STMainControl.h"
#import "NSNotificationCenter+STFXNotificationsShortHand.h"
#import "UIView+STUtil.h"
#import "STGIFFAppSetting.h"
#import "UIImage+Resizing.h"
#import "NSString+BGStringUtilities.h"
#import "NSArray+STUtil.h"
#import "STExporter+IO.h"
#import "STEditorCommand.h"
#import "NSObject+STUtil.h"
#import "UIAlertController+STGIFFApp.h"
#import "UIScrollView+AGK+Properties.h"
#import "STElieStatusBar.h"
#import "STPhotoItemSource.h"
#import "STStandardButton.h"
#import "PHAsset+Utility.h"
#import "STThumbnailGridViewCell.h"
#import "R.h"
#import "STQueueManager.h"
#import "STPermissionManager.h"
#import "SVGKImage.h"
#import "SVGKFastImageView.h"
#import "SVGKFastImageView+STUtil.h"
#import "STHome.h"
#import "STCapturedImage.h"
#import "STCapturedImageSet.h"
#import "STCapturedImageStorageManager.h"
#import "RLMCapturedImage.h"
#import "NSNumber+STUtil.h"
#import "STFilterPresenterBase.h"
#import "STPhotoItem+STExporterIO.h"
#import "STUIApplication.h"
#import "STApp+Logger.h"
#import "STCapturedImageSetAnimatableLayerSet.h"
#import "STGIFFDisplayLayerLeifEffect.h"
#import "STCapturedImageSetAnimatableLayer.h"
#import "STGIFFDisplayLayerJanneEffect.h"
#import "NSString+STUtil.h"
#import "NSData+STGIFUtil.h"
#import "STGIFFDisplayLayerFrameSwappingColorizeBlendEffect.h"
#import "STGIFFAnimatableLayerPresentingView.h"

@interface STPhotoSelector ()
@property(copy) void (^putItemCompletedCallback)(void);
@property (copy) void (^blockForPuttedPhotosCompletion)(void);
@property(nonatomic, strong) STThumbnailGridView *gridView;
@end

@implementation STPhotoSelector {
    STUIView * _gridViewWrapper;

    STPreviewCollector *_previewCollector;

    STPhotoViewType _type;
    STPhotoViewType _lastPhotoType;

    STGIFFAnimatableLayerPresentingView * _layerSetPresentationView;

}

static STPhotoSelector *_instance = nil;

+ (STPhotoSelector *)sharedInstance {
    return _instance;
}

+ (STPhotoSelector *)initSharedInstanceWithFrame:(CGRect)frame {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] initWithFrame:frame];
    });
    return _instance;
}

- (STPhotoViewType)initialType {
    return STPhotoViewTypeGrid;
}

- (STFilterCollectorState *)previewState {
    return _previewCollector.state;
}

- (STPreview *)previewView {
    return _previewCollector.previewView;
}

- (STPhotoItem *)previewTargetPhotoItem {
    return _previewCollector.targetPhotoItem;
}

#pragma mark Public Macros


- (void)doScrollTop{
    [self.gridView scrollToTop];
}

- (void)doResetZoom{
    [self.gridView scrollToTop];
}

- (void)doChangeSource:(STPhotoSource)source canChange:(void(^)(BOOL))block{
    [self changeSource:source canChange:block];
}

- (void)doChangePhotoViewType:(STPhotoViewType)type {
    [self _setViewType:type];
}

- (void)doPutPhotoItems:(NSArray *)items; {
    if(![self isCurrentTypePhoto]){
        [self _setViewType:_lastPhotoType];
    }

    switch(self.source){
        case STPhotoSourceRoom:
            [self _putPhotoItemsFromRoom:items];
            break;

        case STPhotoSourceAssetLibrary:
            [self _putPhotoItemsFromAssetLibrary:items addToLast:NO];
            break;

        default:
            break;
    }
}

#pragma mark Captured
- (void)doAfterCaptured:(STPhotoItemSource *)photoItemSource; {
    if(!photoItemSource){
        return;
    }

    if(STElieCamera.mode == STCameraModeManual || STElieCamera.mode == STCameraModeManualWithElie){
        NSInteger action = STGIFFAppSetting.get.afterManualCaptureAction;

        if(action == STAfterManualCaptureActionSaveToLocalAndContinue){
            [self doSaveToLocal:photoItemSource];

        }else if(action == STAfterManualCaptureActionEnterEdit){

            [self doEnterEditAfterCapture:photoItemSource transition:STPreviewCollectorEnterTransitionContextDefault];

        }else if(action == STAfterManualCaptureActionEnterAnimatableReview){

            [self doEnterEditAfterCapture:photoItemSource transition:STPreviewCollectorEnterTransitionContextDefault];
//            [self doEnterAnimatableReviewAfterCapture:photoItemSource transition:STPreviewCollectorEnterTransitionContextDefault];
        }
    }
    else if(STElieCamera.mode == STCameraModeElie){
        NSInteger perfMode = STGIFFAppSetting.get.performanceMode;

        if(perfMode==EliePerformanceModeSingle){
            [self doEnterEditAfterCapture:photoItemSource transition:STPreviewCollectorEnterTransitionContextDefault];

        }else{
            [self _writeAndAdd:photoItemSource];
        }
    }
    else if(STCameraModeManualQuick == STElieCamera.mode){
        [self _writeAndAdd:photoItemSource];
    }
    else{

        [self _writeAndAdd:photoItemSource];
    }
}

#pragma mark Selection
- (void)deselectAllCurrentSelected {
    [_gridView deselectAll];
}

- (NSArray *)selectedPhotoItems{
    Weaks
    return [_gridView.indexPathsForSelectedItems bk_map:^id(id obj) {
        Strongs
        return [Sself->_gridView items][(NSUInteger) ((NSIndexPath *)obj).item];
    }];
}

- (NSArray<STPhotoItem *> *)currentFocusedPhotoItems {
    return [_previewCollector isStarted] ? (_previewCollector.targetPhotoItem ? @[_previewCollector.targetPhotoItem] : nil) : self.selectedPhotoItems;
}

- (NSArray<STPhotoItem *> *)allAvailablePhotoItems {
    return [_gridView.items bk_select:^BOOL(STPhotoItem * photoItem) {
        return !photoItem.blanked;
    }];
}

- (void)doRemoveAllCurrentSelected{

}

- (void)doSetTypeToMinimumWithFrameAnimation:(CGRect)frame {
    self.frame = frame;
    [self _setViewType:STPhotoViewTypeMinimum];

}

- (void)doSetTypeToGridWithFrameAnimation:(CGRect)frame {
    self.spring.frame = frame;
    [self _setViewType:STPhotoViewTypeGrid];
}

#pragma mark Filter Preview Mode
- (void)doEnterLivePreview {
    if(self.type == STPhotoViewTypeLivePreview){
        return;
    }

    Weaks
    [self _setViewType:STPhotoViewTypeLivePreview done:^{
        Strongs

    }];

    [[STMainControl sharedInstance] enterLivePreview];
};

- (void)doExitLivePreview {
    if(self.type == STPhotoViewTypeLivePreview){
        [_previewCollector closeIfStarted];

        [self _setViewType:_lastPhotoType done:nil];
        [[STMainControl sharedInstance] home];
    }
}

#pragma mark AfterImagePreview Impl.
- (void)enterAfterImageEditingMode{
    Weaks

    STPreview * _previewView = _previewCollector.previewView;
    STCapturedImageSet * targetImageSet = _previewCollector.targetPhotoItem.sourceForCapturedImageSet;

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
                    [Wself renderAfterImageSetWithFrameAt:index];
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

        [self renderAfterImageSetWithFrameAt:selectedIndex];
    }
}

#pragma mark create Layers / effects
//TODO: 어딘가 팩토리 쪽으로 옮김 : test : funnyman
static NSString * FUNNYMAN = @"funnyman";
static NSString * ONE_DIFF_FRAME = @"basicframe";
static NSString * LEIF = @"leif";
static NSString * JANNE = @"Janne";

- (STCapturedImageSetAnimatableLayerSet *)createLayerSetFromCurrentImageSet{
    NSString * presetName = JANNE;

    //create
    STCapturedImageSet * imageSet = _previewCollector.targetPhotoItem.sourceForCapturedImageSet;


    STCapturedImageSetAnimatableLayerSet * layerSet = [STCapturedImageSetAnimatableLayerSet setWithLayers:@[[STCapturedImageSetAnimatableLayer layerWithImageSet:imageSet]]];
    STMultiSourcingImageProcessor * effect = nil;

    if([LEIF isEqualToString:presetName]){
        effect = [[STGIFFDisplayLayerLeifEffect alloc] init];
    }
    else if([JANNE isEqualToString:presetName]){
        effect = [[STGIFFDisplayLayerJanneEffect alloc] init];
    }

    effect.uuid = presetName;
    layerSet.effect = effect;
    return layerSet;
}

- (void)prepareLayerEffect:(STCapturedImageSetDisplayLayerSet *)layerSet {
    STCapturedImageSet * sourceSet = _previewCollector.targetPhotoItem.sourceForCapturedImageSet;
    /*
     * chroma key
     */
    if([layerSet.effect.uuid isEqualToString:FUNNYMAN]){
        NSData * gifData = [NSData dataWithContentsOfFile:[@"chrogif.gif" bundleFilePath]];

        UIImage * gifImages = UIImageWithAnimatedGIFData(gifData);

        NSArray * imagesToCreateImageSet = nil;
        if(gifImages.images.count > sourceSet.images.count){
            NSRange cuttingRange = NSMakeRange(0,sourceSet.images.count);
            imagesToCreateImageSet = [gifImages.images subarrayWithRange:cuttingRange];
        }else{
            //TODO: 이 경우 gif가 imageSet보다 길이 짧은때 정지 화면 아이템을 넣던지 imageSet에서 이미지를 빼던지 보정 처리 필요
        }

        NSArray * capturedImagesFromGifData = [imagesToCreateImageSet mapWithIndex:^id(UIImage * image, NSInteger number) {
            NSURL * url = [[@(number) stringValue] URLForTemp:@"giff_effect_adding_resource_f" extension:@"png"];
            if([UIImagePNGRepresentation(image) writeToURL:url atomically:YES]){
                return [STCapturedImage imageWithImageUrl:url];
            }
            NSAssert(NO, @"write failed");
            return nil;
        }];

        STCapturedImageSetDisplayLayer * effectAppliedLayer = [STCapturedImageSetDisplayLayer layerWithImageSet:[STCapturedImageSet setWithImages: capturedImagesFromGifData]];
        if(effectAppliedLayer){
            layerSet.layers = [layerSet.layers arrayByAddingObjectsFromArray:@[effectAppliedLayer]];
        }
    }
    else if([layerSet.effect.uuid isEqualToString:ONE_DIFF_FRAME]){
        NSArray<STCapturedImage *> * preparedImages = nil;
        STGIFFDisplayLayerFrameSwappingColorizeBlendEffect * _effect = (STGIFFDisplayLayerFrameSwappingColorizeBlendEffect *)layerSet.effect;

        if(_effect.frameIndexOffset==0){
            preparedImages = sourceSet.images;

        }else{
            //frame adjust
            NSMutableArray<STCapturedImage *> *copiedSourceImages = [sourceSet.images mutableCopy];
            NSUInteger indexAbsStep = (NSUInteger) ABS(_effect.frameIndexOffset);

            if(_effect.frameIndexOffset>0){
                NSArray * tail = [copiedSourceImages pop:indexAbsStep];
                preparedImages = [tail arrayByAddingObjectsFromArray:copiedSourceImages];

            }else if(_effect.frameIndexOffset<0){
                NSArray * head = [copiedSourceImages shift:indexAbsStep];
                preparedImages = [copiedSourceImages arrayByAddingObjectsFromArray:head];
            }
        }

        layerSet.layers = [layerSet.layers arrayByAddingObjectsFromArray:@[
                [STCapturedImageSetDisplayLayer layerWithImageSet:[STCapturedImageSet setWithImages:preparedImages]]
        ]];

    }
}

#pragma mark render Layers
- (void)renderAfterImageSetWithFrameAt:(NSUInteger)index{
    @autoreleasepool {
        STPreview * _previewView = _previewCollector.previewView;

        STCapturedImageSet * imageSet = _previewCollector.targetPhotoItem.sourceForCapturedImageSet;

        if(!_layerSetPresentationView){
            _layerSetPresentationView = [[STGIFFAnimatableLayerPresentingView alloc] initWithSize:_previewView.size];
        }

        if(![[_previewView subviews] containsObject:_layerSetPresentationView]){
            [_previewView insertSubview:_layerSetPresentationView aboveSubview:self.previewView.contentView];
            [_layerSetPresentationView centerToParent];
        }

        //set default
        //TODO: frameEditor에서 추가를 선택햇을 경우 말그대로 다시 layer를 추가적으로 append후 리 랜더링 해줘야 한다

        if(imageSet.extensionObject){
            //vaild check
            NSAssert([imageSet.extensionObject isKindOfClass:NSArray.class], @"imageSet.extensionObject is not NSArray");

            if(!_layerSetPresentationView.layerSets.count){ //from storage
                for(STCapturedImageSetDisplayLayerSet * layerSet in (NSArray *)imageSet.extensionObject){
                    BOOL valid = layerSet
                            && [layerSet isKindOfClass:STCapturedImageSetDisplayLayerSet.class]
                            && layerSet.layers.count;

                    NSAssert(valid, @"elements of imageSet.extensionObject is invalid item");

                    if(valid){
                        //recreate effects
                        if(layerSet.effect){
                            [self prepareLayerEffect:layerSet];
                        }

                        [_layerSetPresentationView appendLayerSet:layerSet];
                    }
                }
                //FIXME: 여기서 크래시 중
                NSAssert(_layerSetPresentationView.layerSets.count, @"after image can't initialize");
            }

        }else{

            STCapturedImageSetAnimatableLayerSet * layerSet = nil;
            if(!_layerSetPresentationView.layerSets.count){
                //from capture
                layerSet = [self createLayerSetFromCurrentImageSet];
                if(layerSet.effect){
                    [self prepareLayerEffect:layerSet];
                }
                [_layerSetPresentationView appendLayerSet:layerSet];

            }else{
                //add a layer of layerset + update
                layerSet = [_layerSetPresentationView.layerSets firstObject];
                STCapturedImageSetAnimatableLayer * addingLayer = [STCapturedImageSetAnimatableLayer layerWithImageSet:_previewCollector.targetPhotoItem.sourceForCapturedImageSet];
                layerSet.layers = [layerSet.layers arrayByAddingObject:addingLayer];

                [_layerSetPresentationView updateLayerSet:layerSet];
            }

            [STMainControl sharedInstance].editControlView.frameEditView.layerSet = layerSet;

            imageSet.extensionObject = _layerSetPresentationView.layerSets;
        }

        _layerSetPresentationView.currentIndex = index;
    }
}

- (void)applyNeedsAfterImageSetWithFrameAt{
    STPreview * _previewView = _previewCollector.previewView;

    NSArray <STCapturedImage *> * images = _previewCollector.targetPhotoItem.sourceForCapturedImageSet.images;
    NSUInteger indexOfSlidingTargetImagesUrls = (NSUInteger) round((images.count-1) * _previewView.masterPositionSliderValue);

    [_previewCollector.targetPhotoItem setAssigningIndexFromCapturedImageSet:indexOfSlidingTargetImagesUrls];
    [_previewCollector.presenter beginAndAutomaticallyEndHighQualityContext];
    [_previewCollector reloadSmoothly];
}

- (void)suspendAfterImageEditingMode{

//    [_afterImageView removeAllLayersSets];
}

- (void)exitAfterImageEditingMode{

    [_layerSetPresentationView removeAllLayersSets];
    [STMainControl sharedInstance].editControlView.frameEditView.layerSet = nil;
}

#pragma mark Edit
- (BOOL)requestEnterEditLastItemIfPossible {
    //photos not yet loaded
    if(!self.gridView.items.count){
        Weaks
        [[NSNotificationCenter defaultCenter] st_addObserverWithMainQueueOnlyOnce:self.gridView forName:STNotificationPhotosDidLoadedAndCellsInserted usingBlock:^(NSNotification *note, id observer) {
            [Wself requestEnterEditLastItemIfPossible];
        }];
        return NO;
    }
    [[NSNotificationCenter defaultCenter] st_removeObserverWithMainQueue:self.gridView forName:STNotificationPhotosDidLoadedAndCellsInserted];

    switch(self.source){
        case STPhotoSourceAssetLibrary:
            return [self doEnterEdit:0];

        case STPhotoSourceCapturedImageStorage:{
            if([STMainControl sharedInstance].mode!=STControlDisplayModeEditAfterCapture){
                STPhotoItem * firstItem = [self.collectionView.items firstObject];
                if(firstItem && !firstItem.blanked){
                    [self doEnterEditAfterCaptureByItem:firstItem transition:STPreviewCollectorEnterTransitionContextFromCollectionViewItemSelected];
                    return YES;
                }
            }
            return NO;
        }

        case STPhotoSourceRoom:{
            //lastCapturedIndexInRoom or most recent item + check security.
            if(self.gridView.items.count){

                //get lastest room item
                STPhotoItem * lastestRoomItem = [self.gridView.items st_objectOrNilAtIndex:STGIFFAppSetting.get._lastCapturedIndexInRoom];
                if(lastestRoomItem.blanked){
                    NSArray * sortedItems = [[self.gridView.items bk_select:^BOOL(STPhotoItem * item) {
                        return !item.blanked && item.lastTouchedDate;
                    }] sortedArrayUsingComparator:^NSComparisonResult(STPhotoItem * item1, STPhotoItem * item2) {
                        return [item1.lastTouchedDate timeIntervalSinceReferenceDate] < [item2.lastTouchedDate timeIntervalSinceReferenceDate]
                                ? NSOrderedDescending : NSOrderedSame;
                    }];
                    lastestRoomItem = sortedItems.firstObject;
                }

                if(lastestRoomItem){
                    [self doEnterEditByItem:lastestRoomItem];
                }

                return YES;

            }else{
                [STStandardUX expressDenied:self];
            }

            return NO;
        }
        default:
            break;
    }

    return NO;
}

- (void)doDirectlyEnterHome{
    [_previewCollector.targetPhotoItem clearCurrentEditedAndReloadPreviewImage];
    [_previewCollector closeIfStarted];

    [[STMainControl sharedInstance] home];

    [self _setViewType:STPhotoViewTypeGrid];
}

- (BOOL)doEnterEdit:(NSUInteger)targetPhotoIndex {
    if(self.gridView.items && self.gridView.items.count > targetPhotoIndex) {
        STPhotoItem * photoItem = self.gridView.items[targetPhotoIndex];
        if(!photoItem.blanked){
            [self doEnterEditByItem:photoItem];
            return YES;
        }
    }
    return NO;
}

- (void)doEnterEditByItem:(STPhotoItem *)targetItem {
    if(!targetItem){
        return;
    }
    _previewCollector.targetPhotoItem = targetItem;
    _previewCollector.targetPhotoItem.needsEnhance = STGIFFAppSetting.get.autoEnhanceEnabledInEdit;
    [self _setViewType:STPhotoViewTypeEdit];

    [[STMainControl sharedInstance] enterEdit];
}

- (void)doExitEditAndApply:(void(^)(NSURL *))block {
    [self doExitEditAndApplyAndType:_lastPhotoType completion:block];
}

- (void)doExitEditAndApplyAndType:(STPhotoViewType) type completion:(void(^)(NSURL *))block{
    NSAssert(_previewCollector.type == STPhotoViewTypeEdit, @"should filter editor's type was 'STPhotoViewTypeFilter' before call 'doExitFilterAndSetType'");

    if([_previewCollector isStarted]){

        STPhotoItem * photoItem = _previewCollector.targetPhotoItem;

        if(self.source == STPhotoSourceRoom){
            [_previewCollector setExitTransitionContext:STPreviewCollectorExitTransitionContextSaveToLibraryFromEditedPhotoInRoom];
            [_previewCollector applyAndClose];

            [self _setViewType:type done:nil];

            [[STMainControl sharedInstance] exitEdit];

            Weaks
            [self exportItemToAssetLibrary:photoItem completion:block];

        }
        else if(self.source == STPhotoSourceAssetLibrary){

            [_previewCollector apply];

            [self exportItemToSourceAndAdd:STPhotoSourceAssetLibrary item:photoItem completion:^(STPhotoItem *createdItem) {
                !block?:block(createdItem.fullResolutionURL);
            }];

            Weaks
            self.putItemCompletedCallback = ^{
                Strongs
//                STPhotoItem *newAddedPhotoItem = [Sself->_gridView.items first];

                [Sself _setViewType:type done:nil];

//                Sself->_previewCollector.targetPhotoItem = newAddedPhotoItem;

                [Sself->_previewCollector close];

                [[STMainControl sharedInstance] exitEdit];

                Sself.putItemCompletedCallback = nil;
            };

        }else;
    }
}

- (void)doCancelEdit{
    [self doCancelEdit:STPhotoViewTypeGrid transition:STPreviewCollectorExitTransitionContextDefault];
}

- (void)doCancelEdit:(STPhotoViewType)needsTypeAfter transition:(STPreviewCollectorExitTransitionContext)context; {
    if([_previewCollector isStarted]){
        [_previewCollector.targetPhotoItem clearCurrentEditedAndReloadPreviewImage];
        _previewCollector.exitTransitionContext = context;
        [_previewCollector close];
        [self _setViewType:needsTypeAfter];

        [[STMainControl sharedInstance] exitEdit];
    }
}

#pragma mark Preview
- (void)doResetPreview{
    [_previewCollector reset];
}

- (void)doLayoutPreviewCollectionViews{
    [_previewCollector layoutVisibleItems:YES];
}


UIImageView * BlurPreviewCoverView;
- (void)doBlurPreviewBegin{
    UIView * blurTarget = _previewCollector.previewView.contentView;
    if(!BlurPreviewCoverView){
        BlurPreviewCoverView = [[UIImageView alloc] initWithSize:blurTarget.size];
    }
    BlurPreviewCoverView.image = [[STElieCamera sharedInstance] currentImage];
    [blurTarget addSubview:BlurPreviewCoverView];
    [blurTarget st_coverBlur:YES styleDark:YES completion:nil];
}

- (void)doBlurPreviewEnd{
    UIView * blurTarget = _previewCollector.previewView.contentView;
    [BlurPreviewCoverView clearAllOwnedImagesIfNeededAndRemoveFromSuperview:NO];
    [blurTarget st_coverRemove:YES promiseIfAnimationFinished:YES];
}

#pragma mark Tool
- (void)doEnterTool {
    NSAssert(_previewCollector.targetPhotoItem , @"_previewPresenter.targetPhoto must not be nil");

    [self doEnterToolByItem:_previewCollector.targetPhotoItem];
}

- (void)doEnterToolByItem:(STPhotoItem *)targetItem {
    if(!_previewCollector.isStarted){
        [self doEnterEditByItem:targetItem];

    }else if(_previewCollector.isStarted && _previewCollector.isCurrentTypeAllowedTool){
        [_previewCollector startTool];

    }else if(_previewCollector.isStarted && !_previewCollector.isCurrentTypeAllowedTool){
        [_previewCollector closeIfStarted];

        [self doEnterEditByItem:targetItem];
        [self doEnterTool];
    }

    [[STMainControl sharedInstance] enterEditTool];
}

- (void)doApplyTool {
    [[STMainControl sharedInstance] exitEditTool];

    [_previewCollector applyAndCloseTool];
    [_previewCollector reload];
}

- (void)doResetTool{
    [_previewCollector resetTool];
}

- (void)doUndoTool{
    [_previewCollector resetTool];
    [_previewCollector reload];
}

- (void)doCancelTool {
    [_previewCollector closeTool];
    [[STMainControl sharedInstance] exitEditTool];
}

- (BOOL)doCommandTool:(STEditorCommand *)command{
    return [_previewCollector commandTool:command];
}

#pragma mark EditAfterCapture
- (void)doEnterEditAfterCapture:(STPhotoItemSource *)result transition:(STPreviewCollectorEnterTransitionContext)context{

    Weaks
    [[STElieStatusBar sharedInstance] startProgress:nil];

    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    [self _writeToTempAndCreateItem:result completion:^(STPhotoItem *item) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

        [self doEnterEditAfterCaptureByItem:item transition:context];

        //enter ai
        [self enterAfterImageEditingMode];

        [[STElieStatusBar sharedInstance] stopProgress];
    }];
}

- (void)doEnterEditAfterCaptureByItem:(STPhotoItem *)item transition:(STPreviewCollectorEnterTransitionContext)context{
    [_previewCollector closeIfStarted];
    _previewCollector.targetPhotoItem = item;
    _previewCollector.targetPhotoItem.needsEnhance = STGIFFAppSetting.get.autoEnhanceEnabledInEdit;
    _previewCollector.enterTransitionContext = context;
    [self _setViewType:STPhotoViewTypeEditAfterCapture];

    [[STMainControl sharedInstance] enterEditAfterCapture];
}

- (void)doExitEditAfterCapture:(BOOL)suspend{
    [_previewCollector.targetPhotoItem clearCurrentEditedAndReloadPreviewImage];
    [_previewCollector closeIfStarted];

    //exit ai
    [[STMainControl sharedInstance] exitEditAfterCapture];

    if(suspend){
        [self suspendAfterImageEditingMode];
    }else{
        [self exitAfterImageEditingMode];
    }

    if([STMainControl sharedInstance].mode == STControlDisplayModeLivePreview){
        [self doEnterLivePreview];
    }else{
        [self _setViewType:STPhotoViewTypeGrid];
    }
}

- (void)doExportAndExitEditAfterCapture:(void(^)(NSURL *url))block{
    NSAssert(_previewCollector.type == STPhotoViewTypeEditAfterCapture, @"should filter editor's type was 'STPhotoViewTypeFilter' before call 'doExitFilterAndSetType'");

    if([_previewCollector isStarted]){

        STPhotoItem * photoItem = _previewCollector.targetPhotoItem;
        photoItem.currentFilterItem = _previewCollector.state.currentFocusedFilterItem;

        Weaks
        [self exportItemToSourceAndAdd:self.source item:photoItem completion:^(STPhotoItem *createdItem) {
            Strongs
            [Sself->_previewCollector.targetPhotoItem clearCurrentEditedAndReloadPreviewImage];
            Sself->_previewCollector.targetPhotoItem = nil;
            !block?:block(createdItem.fullResolutionURL);
        }];

        self.putItemCompletedCallback = ^{
            Strongs
            [Sself->_previewCollector closeIfStarted];

            [[STMainControl sharedInstance] exitEditAfterCapture];

            if([STMainControl sharedInstance].mode == STControlDisplayModeLivePreview){
                [Sself doEnterLivePreview];
            }else{
                [Sself _setViewType:STPhotoViewTypeGrid];
            }

            Sself.putItemCompletedCallback = nil;
        };
    }
}

#pragma mark ReviewAfterCaptureAnimatable
//TODO: 추후 doEnterEditAfterCapture 와 통합 : 사실상 같음
- (void)doEnterAnimatableReviewAfterCapture:(STPhotoItemSource *)result transition:(STPreviewCollectorEnterTransitionContext)context{

    [[STElieStatusBar sharedInstance] startProgress:nil];

    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    [self _writeToTempAndCreateItem:result completion:^(STPhotoItem *item) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

        [_previewCollector closeIfStarted];

        //set orientation
        item.orientationOriginated = result.orientation;

        _previewCollector.targetPhotoItem = item;
//        _previewCollector.targetPhotoItem.needsEnhance = STGIFFAppSetting.get.autoEnhanceEnabledInEdit;
        _previewCollector.enterTransitionContext = context;

        [self _setViewType:STPhotoViewTypeReviewAfterAnimatableCapture];

        [[STMainControl sharedInstance] enterReviewAfterAnimatableCapture];

        [[STElieStatusBar sharedInstance] stopProgress];
    }];
}

- (void)doExitAnimatableReviewAfterCapture{
    [_previewCollector.targetPhotoItem clearCurrentEditedAndReloadPreviewImage];
    [_previewCollector closeIfStarted];

    [[STMainControl sharedInstance] exitReviewAfterAnimatableCapture];

    [self doEnterLivePreview];
}

#pragma mark

- (void)doSaveToLocal:(STPhotoItemSource *)source{
    [[STElieStatusBar sharedInstance] startProgress:nil];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self _writeAndAdd:source completion:^(STPhotoItem *item) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        if(item){
            [[STElieStatusBar sharedInstance] success];
        }else{
            [[STElieStatusBar sharedInstance] fail];
        }
    }];
}

#pragma mark init

- (id)initWithFrame:(CGRect)frame; {
    self = [super initWithFrame:frame];
    if (self) {
        _type = [self initialType];
        
        _previewCollector = [[STPreviewCollector alloc] initWithPreviewFrame:self.bounds];

        _gridViewWrapper = [[STUIView alloc] initWithFrame:self.bounds];

        _gridView = [[STThumbnailGridView alloc] initWithFrame:self.bounds];
    }
    return self;
}

- (void) createContent{
    [self addSubview:_gridViewWrapper];
    [self addSubview:_previewCollector.previewView];

    [_gridViewWrapper addSubview:self.gridView];

    [self _setViewType:[self initialType]];
}

- (void)layoutSubviews; {
    [super layoutSubviews];

    [self.gridView updateViewsByScrolled];
}


#pragma mark Define Actions For ViewType
- (void)_setViewType:(STPhotoViewType) type{
    [self _setViewType:type done:nil];
}

- (void)_setViewType:(STPhotoViewType)type done:(void(^)(void))block;{
    if(self.contentDidCreated && _type == type){
        return;
    }

    STPhotoViewType previousType = _type;

    // set type
    _type = type;

    // clear delegate
    _gridView.gridViewDelegate = nil;

    // clear previewEditer
    [_previewCollector st_clearPerformOnceAfterDelay];

    // pause camera
    [[STElieCamera sharedInstance] pauseCameraCapture];

    CGFloat previewCollectorY = 0;

    if([self isTypePhoto:type]){
        [self setTouchInsidePolicy:STUIViewTouchInsidePolicyNone];

        /*
            filter
         */
        _previewCollector.previewView.visible = NO;
        [_previewCollector closeIfStarted];

        /*
            grid
         */
        _gridView.gridViewDelegate = self;
        _gridView.bounces = YES;
        self.gridView.userInteractionEnabled = YES;
        self.gridView.animatableVisible = YES;
        self.gridView.type = type;

        /*
            self
         */
        _lastPhotoType = type;

        if(self.y==0){
            !block?:block();

        }else{
            Weaks
            [NSObject animate:^{
                Wself.spring.y = 0;
            } completion:^(BOOL finished) {
                if(finished){
                    !block?:block();
                }
            }];
        }

    }else if(type == STPhotoViewTypeEdit){
        [self setTouchInsidePolicy:STUIViewTouchInsidePolicyContentInside];

        _previewCollector.previewView.visible = YES;
        [_previewCollector start:type];

        self.gridView.animatableVisible = NO;

        if(self.y != 0){
            self.y = 0;
        }

        !block?:block();

    }else if(type == STPhotoViewTypeEditAfterCapture){
        [self setTouchInsidePolicy:STUIViewTouchInsidePolicyContentInside];

        _previewCollector.previewView.visible = YES;
        [_previewCollector start:type];

        self.gridView.animatableVisible = NO;

        !block?:block();

    }
    else if(type == STPhotoViewTypeReviewAfterAnimatableCapture){
        [self setTouchInsidePolicy:STUIViewTouchInsidePolicyContentInside];

        _previewCollector.previewView.visible = YES;
        [_previewCollector start:type];

        self.gridView.animatableVisible = NO;

        !block?:block();
    }
    else if(type == STPhotoViewTypeLivePreview){
        Weaks
        [self setTouchInsidePolicy:STUIViewTouchInsidePolicyContentInside];

        /*
            filter
         */

        _previewCollector.previewView.visible = YES;

        /*
            grid
         */
        [self.gridView setContentOffset:CGPointZero animated:YES];
        self.gridView.userInteractionEnabled = NO;
        self.gridView.visible = NO;

        /*
            self
         */
        [[STPhotoSelector sharedInstance].previewView st_coverBlur:NO styleDark:YES completion:nil];
        [[NSNotificationCenter defaultCenter] st_addObserverWithMainQueueOnlyOnce:self forName:STNotificationFilterPresenterItemRenderFinish usingBlock:^(NSNotification *note, id observer) {
            [[STPhotoSelector sharedInstance].previewView st_coverRemove:YES promiseIfAnimationFinished:YES duration:.6 finished:nil];
            [[STElieCamera sharedInstance] resumeCameraCapture];
        }];
        [_previewCollector start:type];

        !block?:block();
    }
}

#pragma mark PhotoSource
- (STPhotoSource)source; {
    return (STPhotoSource) [[[STGIFFAppSetting get] read:@keypath([STGIFFAppSetting get].photoSource)] integerValue];
}

- (void)changeSource:(STPhotoSource)source canChange:(void(^)(BOOL))block{
    if(self.contentDidCreated && self.source == source){
        return;
    }

    [self willChangeSource:source];

    if (source == STPhotoSourceRoom) {
        !block ?: block(YES);
        [self _changeSource:source effect:YES];

    }
    else {
        if(STPermissionManager.photos.isAuthorized){
            !block ?: block(YES);
            [self _changeSource:source effect:YES];

        }else{
            [STPermissionManager.photos alertNeeded:^(BOOL confirm) {
                !block ?: block(confirm);
                if(STPermissionManager.photos.isAuthorized){
                    [self _changeSource:source effect:YES];
                }
            }];
        }
    }
}

- (void)_changeSource:(STPhotoSource)source effect:(BOOL)effect{
    /*
     * change source
     */
    Weaks
    void(^loadSource)(void) = ^{
        STGIFFAppSetting.get.photoSource = source;

        [Wself.gridView scrollTo:0 animated:NO];
        [Wself loadFromCurrentSource];
    };


    /*
     * Define Effect to change source
     */
    STStandardButton * rightButton = [[STMainControl sharedInstance] subControl].rightButton;
    rightButton.userInteractionEnabled = NO;

    if(effect){
        if([STGIFFApp isCurrentDeviceInLowRenderingPerformanceFamily]){
            Weaks
            _blockForPuttedPhotosCompletion = ^{
                [Wself st_coverBlurRemoveIfShowen];

                rightButton.userInteractionEnabled = YES;
                [Wself didChangedSource:source];
            };

            [self st_coverBlur:YES styleDark:YES completion:^{
                loadSource();
            }];
        }
        else{
            UIView * rootView = [self st_rootUVC].view;
            UIView * targetView = [STPhotoSelector sharedInstance];
            UIImageView * coveredView = [rightButton coverAndUncoverBegin:rootView presentingTarget:targetView];
            Weaks
            _blockForPuttedPhotosCompletion = ^{
                Strongs
                [Wself st_performOnceAfterDelay:@"coverend" interval:.05 block:^{
                    [rightButton coverAndUncoverEnd:rootView presentingTarget:targetView beforeCoverView:coveredView comletion:^(STStandardButton *button, BOOL covered) {
                        rightButton.userInteractionEnabled = YES;
                        [Sself didChangedSource:source];
                    }];
                }];
            };

            loadSource();
        }
    }else{
        Weaks
        _blockForPuttedPhotosCompletion = ^{
            rightButton.userInteractionEnabled = YES;
            [Wself didChangedSource:source];
        };

        loadSource();
    }
}

- (void)willChangeSource:(STPhotoSource)source {
}

- (void)didChangedSource:(STPhotoSource)source {
    [self loadExportedStateIfNeededWhenChangedSource];
    [self displayStatusBarWhenChangedSourceIfNeeded];
}

#pragma mark Room
- (void)requestOpenAlbumIfPossible {
    if([STPhotoSelector sharedInstance].source == STPhotoSourceRoom){
        return;
    }

    Weaks
    if(!self.gridView.items.count){
        [[NSNotificationCenter defaultCenter] st_addObserverWithMainQueueOnlyOnce:self forName:STNotificationPhotosDidLoaded usingBlock:^(NSNotification *note, id _observer) {
            [Wself requestOpenAlbumIfPossible];
        }];
        return;
    }

    if([STGIFFApp afterCameraInitialized:@"STPhotoSelector.quickaction.openalbum" perform:^{
        [Wself requestOpenAlbumIfPossible];
    }]){
        return;
    }

    [[STMainControl sharedInstance] backToHome];
    [[STElieStatusBar sharedInstance].rightButton dispatchSelected];
}

#pragma mark Load
- (void)initialLoadFromCurrentSource{
    BlockOnce(^{
//        [self initialShowing];

        [self loadFromCurrentSource];
        [self loadExportedStateIfNeededWhenChangedSource];
    });
}

- (void)initialShowing{
    /*
     * after-launch screen off.
     */
    UIColor * defaultBackgroundColor = self.superview.backgroundColor;
    self.superview.backgroundColor = [STGIFFApp launchScreenBackgroundColor];

    NSString * iconViewTagName = @"initialLaunchIcon";
    UIImageView * launchIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LaunchScreenIcon"]];
    launchIconView.tagName = iconViewTagName;
    [self.superview addSubview:launchIconView];
    [launchIconView centerToParent];

    self.alpha = 0;
    Weaks
    _blockForPuttedPhotosCompletion = ^{
        __block UIImageView * _launchIconView = (UIImageView *) [Wself.superview viewWithTagName:iconViewTagName];
        if([STPermissionManager camera].status == STPermissionStatusAuthorized){
            [UIView animateWithDuration:.5 animations:^{
                _launchIconView.alpha = 0;
                _launchIconView.center = [[STMainControl sharedInstance] convertPoint:[STMainControl sharedInstance].homeView.center toView:Wself];
                _launchIconView.scaleXYValue = .5;
            } completion:^(BOOL finished) {
                _launchIconView.image = nil;
                [_launchIconView removeFromSuperview];
                _launchIconView = nil;
            }];
        }else{
            _launchIconView.image = nil;
            [_launchIconView removeFromSuperview];
            _launchIconView = nil;
        }

        [UIView animateWithDuration:1.5 animations:^{
            Wself.alpha = 1;
        } completion:^(BOOL finished) {
            Wself.superview.backgroundColor = defaultBackgroundColor;
        }];
    };
}

- (void)setLoadingCurrentSource:(BOOL)loading{
    BOOL change = _loadingSource != loading;
    if(change){
        [self willChangeValueForKey:@keypath(self.loadingSource)];
        _loadingSource = loading;
        [self didChangeValueForKey:@keypath(self.loadingSource)];
    }
}

- (void)loadFromCurrentSource {
    STPhotoSource source = (STPhotoSource) STGIFFAppSetting.get.photoSource;
    NSAssert(self.source==source, @"STGIFFAppSetting.get.photoSource == [STPhotoSelector sharedInstance].source");

    [self setLoadingCurrentSource:YES];

    [[self.gridView items] removeAllObjects];
    [[STMainControl sharedInstance] setPhotoSelected:0];

    if(source==STPhotoSourceRoom){
        [self loadAndPutThumbnails];

    }else if(source==STPhotoSourceAssetLibrary){
        [STAssetsLibraryManager resetPhotosEnumerater];

        [self loadAndPutThumbnails];
    }else if(source==STPhotoSourceCapturedImageStorage){

        [self loadAndPutThumbnails];
    }
}

#pragma mark Observing external photos change
static  BOOL _reservationReload;
- (void)reserveReloadCurrentSource {
    @synchronized (self) {
        _reservationReload = YES;
    }
}

- (void)reloadFromCurrentSourceIfReserved {
    if(!_reservationReload){
        return;
    }

    _reservationReload = NO;

    if(self.source==STPhotoSourceRoom){

    }else if(self.source==STPhotoSourceAssetLibrary){

        [self loadFromCurrentSource];
    }
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance; {
    Weaks
    [self st_runAsMainQueueWithoutDeadlocking:^{
        [Wself reserveReloadCurrentSource];
    }];
}

static BOOL _lockedRegisteredChangeObserver;
- (void)lockOnceObservingPhotoLibraryChange {
    _lockedRegisteredChangeObserver = YES;
}

- (void)startObservingPhotoLibraryChange{
    @synchronized (self) {
        if(_lockedRegisteredChangeObserver){
            _lockedRegisteredChangeObserver = NO;
            return;
        }
        if(self.source != STPhotoSourceAssetLibrary){
            return;
        }
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
}

- (void)stopObservingPhotoLibraryChange{
    @synchronized (self) {
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    }
}

#pragma clear
- (void)clearWhenMemoryWarinig; {
    [_previewCollector clearFilterCaches];

    //reload visible items, dispose unvisible items
    [[self collectionView] representPhotoItemOfAllVisibleCells:YES];
}


- (STThumbnailGridView *)collectionView; {
    return self.gridView;
}

#pragma mark Add Chunk Photos
- (void)didScrolledToLastPosition:(STThumbnailGridView *)scrollView; {
    if([self isCurrentTypePhotoAndHasMoreAppendingPhotos]){
        [[STElieStatusBar sharedInstance] startProgress:nil];

        //WARN Not-Recommend no main thread.
        Weaks
        dispatch_async([STQueueManager sharedQueue].readingIO, ^{
            [Wself _loadAndAddThumbnailsFromAssetLibrary];
        });
    }else{

    }
}

#pragma mark Pull To Refresh
- (void)beganPerformedPullToRefresh:(UIScrollView *)scrollView; {
//    [self beganPullingGrid];
}

- (void)performmingPullToRefresh:(UIScrollView *)scrollView; {
//    [self performPullingGrid:scrollView.contentOffset.y*-1];
}

- (void)didPerformedPullToRefresh:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate; {
//    [[STUserActor sharedInstance] act:STUserActionChangeCameraMode object:@(STCameraModeManual)];
//
//    [self finishPullingGrid];
}

- (void) didCancelPullToRefresh:(UIScrollView *)scrollView; {
//    [self cancelPullingGrid];
}

- (void)finishPullingGrid {
    [_previewCollector.previewView st_removeShadow];
}

#pragma mark Current State
- (BOOL)isCurrentTypePhoto {
    return [self isTypePhoto:_type];
}

- (BOOL)isTypePhoto:(STPhotoViewType) type {
    return type == STPhotoViewTypeGrid || type == STPhotoViewTypeDetail || type == STPhotoViewTypeMinimum || type == STPhotoViewTypeGridHigh;
}

- (BOOL)isCurrentTypeEdit {
    return [self isTypeEdit:_type];
}

- (BOOL)isTypeEdit:(STPhotoViewType) type {
    return type == STPhotoViewTypeEdit || type == STPhotoViewTypeLivePreview || type == STPhotoViewTypeEditAfterCapture;
}

- (BOOL)isCurrentTypePhotoAndHasMoreAppendingPhotos; {
    return [self isCurrentTypePhoto] && [[STPhotoSelector sharedInstance] source] == STPhotoSourceAssetLibrary && [STAssetsLibraryManager hasNextPhotos];
}

#pragma mark Thumbnail and Image putting
- (CGSize)previewImageSizeByType:(STPhotoViewType) type {

    CGFloat sizeWidth = 0;
    if(type == STPhotoViewTypeGrid){
        sizeWidth = self.bounds.size.width / 3.3f;
    }
    else if(type == STPhotoViewTypeGridHigh){
        sizeWidth = self.bounds.size.width / 1.5f;
    }
    else if(type == STPhotoViewTypeMinimum){
        sizeWidth = self.bounds.size.width / kSTBuffPhotosGridCol / 1.9f;
    }else{
        sizeWidth = self.bounds.size.width;
    }
    return CGSizeMake(sizeWidth, sizeWidth * [[STElieCamera sharedInstance] outputVerticalRatio]);
}

- (CGSize)previewImageSize {
    return [self previewImageSizeByType:_type];
}

#pragma mark GridView Handler
- (void)dispatchPuttedPhotosComplete {
    !_blockForPuttedPhotosCompletion ?: _blockForPuttedPhotosCompletion();
    _blockForPuttedPhotosCompletion = nil;
}

static SVGKFastImageView *_nophotoView;
- (void)displayWhenNoItemsIfNeeded{
    if(self.gridView.items.count==0){
        _nophotoView = [SVGKFastImageView viewWithImageNamedNoCache:[R ico_no_photo] sizeValue:self.width/3];
        _nophotoView.alpha = [STStandardUI alphaForDimmingGlass];
        _nophotoView.size = CGSizeMakeValue(self.width/3);
        [self addSubview:_nophotoView];
        [_nophotoView centerToParent];
        _nophotoView.y -= self.centerY/6;

    }else{
        if(_nophotoView){
            [_nophotoView removeFromSuperview];
            _nophotoView = nil;
        }
    }
}

- (void)_putPhotoItemsComplete{
    BOOL itemsArePutted = self.userInteractionEnabled = self.gridView.items.count > 0;

    [self displayWhenNoItemsIfNeeded];

    !self.putItemCompletedCallback ?: self.putItemCompletedCallback();

    Weaks
    [self st_performOnceAfterDelay:0 block:^{
        [Wself dispatchPuttedPhotosComplete];

        if(itemsArePutted){
            [[NSNotificationCenter defaultCenter] postNotificationName:STNotificationPhotosDidLoadedAndCellsInserted object:nil];
        }

        [Wself setLoadingCurrentSource:NO];
    }];
}

#pragma putPhotoItemsFromCapturedImageStorage
- (void)_putPhotoItemsFromCapturedImageStorage:(NSArray *)items addToLast:(BOOL)addToLast {

    BOOL initialPuts = self.gridView.items.count==0;

    STPhotoItem *indexItemForAutoScroll = addToLast ? [self.gridView.items last] : [self.gridView.items first];

    for(STPhotoItem * item in items){
        addToLast || initialPuts ? [self.gridView.items addObject:item] : [self.gridView.items insertObject:item atIndex:0];
    }

    NSUInteger scrollIndexWhenAfterUpdates = [self.gridView.items indexOfObject:indexItemForAutoScroll];

    if(initialPuts){
        [self.gridView reloadData];

        [self _putPhotoItemsComplete];


    }else{
        !addToLast ?: [UIView lockAnimation];
        Weaks
        [self.gridView performBatchUpdates:^{
            [Wself.gridView insertItemsAtIndexPaths:[items map:^id(id object) {
                NSIndexPath *indexPath = [NSIndexPath itemPath:[items indexOfObject:object]];
                return indexPath;
            }]];
        } completion:^(BOOL finished) {
            [UIView unlockAnimation];

//            [self.gridView representPhotoItemOfAllVisibleCells:NO];

            [self.gridView scrollToItemAtIndexPath:[NSIndexPath itemPath:scrollIndexWhenAfterUpdates] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];

            [self _putPhotoItemsComplete];
        }];
    }
}

#pragma putPhotoItemsFromAssetLibrary
- (void)_putPhotoItemsFromAssetLibrary:(NSArray *)items addToLast:(BOOL)addToLast {
    BOOL initialPuts = self.gridView.items.count==0;

    STPhotoItem *indexItemForAutoScroll = addToLast ? [self.gridView.items last] : [self.gridView.items first];

    for(STPhotoItem * item in items){
        addToLast || initialPuts ? [self.gridView.items addObject:item] : [self.gridView.items insertObject:item atIndex:0];
    }

    NSUInteger scrollIndexWhenAfterUpdates = [self.gridView.items indexOfObject:indexItemForAutoScroll];

    if(initialPuts){
        [self.gridView reloadData];

        [self _putPhotoItemsComplete];

    }else{
        !addToLast ?: [UIView lockAnimation];
        Weaks
        [self.gridView performBatchUpdates:^{
            [Wself.gridView insertItemsAtIndexPaths:[items map:^id(id object) {
                NSIndexPath *indexPath = [NSIndexPath itemPath:[items indexOfObject:object]];
                return indexPath;
            }]];
        } completion:^(BOOL finished) {
            [UIView unlockAnimation];

            [self.gridView scrollToItemAtIndexPath:[NSIndexPath itemPath:scrollIndexWhenAfterUpdates] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];

            [self _putPhotoItemsComplete];
        }];
    }
}

#pragma putPhotoItemsFromRoom
- (void)_putPhotoItemsFromRoom:(NSArray *)items{
    BOOL initialPuts = self.gridView.items.count==0;

    NSInteger preferedIndex = STGIFFAppSetting.get._lastCapturedIndexInRoom;

    __block NSInteger putIndex = initialPuts ? 0 : preferedIndex;

    // fill data
    NSMutableArray *_toInserts = [NSMutableArray array];
    NSMutableArray *_toReloads = [NSMutableArray array];
    for(STPhotoItem * item in items){
        if(self.gridView.items.count < STGIFFAppSetting.get.currentRoomSize){
            [self.gridView.items addObject:item];
            [_toInserts addObject:[NSIndexPath itemPath:self.gridView.items.count-1]];

            putIndex = [self nextRoomIndex:self.gridView.items.count - 1];

        }else{
            NSAssert(putIndex<self.gridView.items.count,@"putIndex<self.gridView.items.count at _putPhotoItemsFromRoom");
            //https://fabric.io/jessi/ios/apps/com.stells.eliew/issues/57070c52ffcdc04250851ba1
            if(putIndex>=self.gridView.items.count){
                putIndex = 0;
            }
            self.gridView.items[putIndex] = item;
            [_toReloads addObject:[NSIndexPath itemPath:putIndex]];

            putIndex = [self nextRoomIndex:putIndex];
        }
    }

    if(self.gridView.items.count==0){
        [self.gridView reloadData];
        [self.gridView scrollTo:0];

    }else{
        //clear pointed
        [self.gridView.items bk_each:^(id obj) {
            if([obj marked]){
                [obj setMarked:NO];
                [_toReloads addObject:[NSIndexPath itemPath:[self.gridView.items indexOfObject:obj]]];
            }
        }];

        // safety inbound index
        preferedIndex = [self.gridView.items st_boundSafetyIndex:preferedIndex];

        // point
        if(preferedIndex != NSNotFound){
            [self.gridView.items[preferedIndex] setMarked:YES];
        }

        // display
        if(initialPuts){
            [self.gridView reloadData];
            [self.gridView scrollTo:preferedIndex animated:NO];

            [self _putPhotoItemsComplete];
        }else{
            @weakify(self)
            [self.gridView performBatchUpdates:^{
                if ([_toInserts count]) {
                    [self.gridView insertItemsAtIndexPaths:_toInserts];
                }
                if ([_toReloads count]) {
                    [self.gridView reloadItemsAtIndexPaths:_toReloads];
                }
            } completion:^(BOOL finished) {
                if (finished) {
                    [self.gridView scrollTo:preferedIndex];

                    [self _putPhotoItemsComplete];
                }

            }];
        }
    }
}

- (NSUInteger)nextRoomIndex:(NSUInteger)currentPuttedIndex{
    return currentPuttedIndex<0 || currentPuttedIndex >= STGIFFAppSetting.get.currentRoomSize -1 ? 0 : currentPuttedIndex +1;
}

- (NSUInteger)nextLastCaptureIndexInRoom {
    NSUInteger index = self.gridView.items.count < STGIFFAppSetting.get.currentRoomSize ? self.gridView.items.count : [self nextRoomIndex:(NSUInteger) STGIFFAppSetting.get._lastCapturedIndexInRoom];

    [self saveLastCapturedIndex:index];

    return index;
}

- (void)saveLastCapturedIndex:(NSInteger) index{
     STGIFFAppSetting.get._lastCapturedIndexInRoom = index;
     if(![STGIFFAppSetting.get shouldAutomaticallySynchronize]){
         [STGIFFAppSetting.get synchronize];
     }
}

- (void)_removePhotoItems:(NSArray *)items completion:(void (^)(BOOL finished))block{
     Weaks
     [self.gridView performBatchUpdates:^{
         [Wself.gridView deleteItemsAtIndexPaths:[Wself.gridView indexPathsForPhotoItems:items]];

     } completion:block];
}

- (void)_reloadPhotoItems:(NSArray *)items{
    Weaks
    [UIView beginAnimations:nil context:NULL];
    [self.gridView performBatchUpdates:^{
        [Wself.gridView reloadItemsAtIndexPaths:[Wself.gridView indexPathsForPhotoItems:items]];

    } completion:^(BOOL finished) {
        if(finished){
            [UIView commitAnimations];
        }
    }];
}

- (void)_reloadAllBlankPhotoItems{
    [self _reloadPhotoItems:[self.gridView.items bk_select:^BOOL(STPhotoItem * photoItem) {
        return photoItem.blanked;
    }]];
}

# pragma mark I/O Operations Handler
- (void)loadAndPutThumbnails{
    switch(self.source){
        case STPhotoSourceRoom:
            [self _loadAndPutThumbnailsFromRoom];
            break;

        case STPhotoSourceAssetLibrary:
            [self _loadAndAddThumbnailsFromAssetLibrary];
            break;

        case STPhotoSourceCapturedImageStorage:
            [self _loadAndAddThumbnailsFromCapturedImageStorage];
            break;

        default:
            NSAssert(NO, @"not supported current type of photosource.");
            break;
    }
}

- (void)_writeAndAdd:(STPhotoItemSource *)photo{
    [self _writeAndAdd:photo completion:nil];
}

- (void)_writeAndAdd:(STPhotoItemSource *)photo completion:(void(^)(STPhotoItem *))block{
    [self _writeAndAdd:self.source image:photo completion:block];
}

- (void)_writeAndAdd:(STPhotoSource)source image:(STPhotoItemSource *)photoSource completion:(void(^)(STPhotoItem *))block{
    dispatch_queue_t const DefaultWritingIOQueue = [STQueueManager sharedQueue].writingIO;

    Weaks
    switch(source){
        case STPhotoSourceAssetLibrary:
        {
            [self _writeToAssetLibrary:photoSource completion:^(NSURL *url) {
                if(!url){
                    !block?:block(nil);
                    return;
                }
                //to save current photo origin
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [[STAssetsLibraryManager sharedManager] assetForURL:url resultBlock:^(ALAsset *asset) {
                    [Wself st_runAsMainQueueAsyncWithoutDeadlocking:^{
                        Strongs
                        STPhotoItem *item = [[STPhotoItem alloc] init];
                        item.sourceForALAsset = asset;
                        //[item loadPreviewImage];

                        if(photoSource.metaData && [photoSource.metaData count]>0){
                            item.metadataFromCamera = photoSource.metaData;
                        }
                        item.origin = photoSource.origin;
                        [Sself _putPhotoItemsFromAssetLibrary:@[item] addToLast:NO];

                        [photoSource dispose];

                        if(block){
                            block(item);
                        }

                        [[NSNotificationCenter get] st_postNotificationName:STNotificationPhotosDidLocalSaved];
                    }];
                } failureBlock:^(NSError *error) {
                    if(block){
                        block(nil);
                    }
                }];
#pragma clang diagnostic pop
            }];

        }
            break;

        case STPhotoSourceRoom:
        {
            __weak STPhotoSelector *weakSelf = self;

            //https://fabric.io/jessi/ios/apps/com.stells.eliew/issues/56d64204f5d3a7f76b3bcf06
            NSUInteger index = [self nextLastCaptureIndexInRoom];

            dispatch_async(DefaultWritingIOQueue, ^{
                STPhotoSelector *_self = weakSelf;
                UIImage * photo = photoSource.image;
                NSDictionary * data = photoSource.metaData;

                NSURL *originalUrl = [_self makeImagesSaveUrl:kSTImageFilePrefix_OrigianlImage index:index];
                NSURL *fullscreenUrl = [_self makeImagesSaveUrl:kSTImageFilePrefix_Fullscreen index:index];
                NSURL *previewUrl = [_self makeImagesSaveUrl:kSTImageFilePrefix_PreviewImage index:index];
                UIImage * previewImage = [photo scaleToFitSize:CGSizeByScale([_self previewImageSizeByType:STPhotoViewTypeGridHigh], TwiceMaxScreenScale())];
                [_self saveImageToUrl:previewImage fileUrl:previewUrl quality:.7];

                __block WeakObject(previewImage) weakPreviewImage = previewImage;
                [_self st_runAsMainQueueAsyncWithSelf:^(id selfObject) {
                    STPhotoItem *item = [STPhotoItem itemWithIndex:index];
                    item.sourceForFullResolutionFromURL = originalUrl;
                    item.sourceForFullScreenFromURL = fullscreenUrl;
                    item.sourceForPreviewFromURL = previewUrl;
                    if(data && [data count]>0){
                        item.metadataFromCamera = data;
                    }
                    item.origin = photoSource.origin;
                    [item initializePreviewImage:weakPreviewImage];
                    weakPreviewImage = nil;

                    [selfObject _putPhotoItemsFromRoom:@[item]];

                    [photoSource dispose];

                    if(block){
                        block(item);
                    }

                    //expire memory
                    [item initializePreviewImage:nil];

                    [[NSNotificationCenter get] st_postNotificationName:STNotificationPhotosDidLocalSaved];
                }];
                [_self saveImageToUrl:[photo scaleToFitSize:[STGIFFApp memorySafetyRasterSize:[_self previewImageSizeByType:STPhotoViewTypeDetail]]] fileUrl:fullscreenUrl quality:.8];
                [_self saveImageToUrl:photo fileUrl:originalUrl quality:1.0];
            });

        }
            break;

        case STPhotoSourceCapturedImageStorage:
        {
            //fallback if photoSource not supported STPhotoSourceCapturedImageStorage.
            if(!photoSource.imageSet){
                oo(@"[!] WARNING : photoSource.imageSet == nil, So this target source that is not supported STPhotoSourceCapturedImageStorage, \n will be automatically assigned to STPhotoSourceAssetLibrary");
                [self _writeAndAdd:STPhotoSourceAssetLibrary image:photoSource completion:block];
                return;
            }

            Weaks
            dispatch_async(DefaultWritingIOQueue, ^{

                NSString * uuid = photoSource.imageSet.uuid;
                STPhotoItem * newItemToAdd = nil;

                //reset index to defaults before save
                [photoSource.imageSet reindexingDefaultImage];

                if([[STCapturedImageStorageManager sharedManager] saveSet:photoSource.imageSet]){
                    newItemToAdd = STPhotoItem.new;
                    newItemToAdd.sourceForCapturedImageSet = photoSource.imageSet;
#if DEBUG
                    STCapturedImageSet * savedAndLoadedImageSet = [[STCapturedImageStorageManager sharedManager] loadSet:uuid];
                    NSAssert(savedAndLoadedImageSet, @"load failed - STCapturedImageSet");
#endif
                }else{
                    NSAssert(NO, @"saving failed - STCapturedImageSet");
                }

                dispatch_async(dispatch_get_main_queue(), ^{

                    if(newItemToAdd){
                        [Wself _putPhotoItemsFromCapturedImageStorage:@[newItemToAdd] addToLast:NO];
                    }

                    [photoSource dispose];

                    !block ?: block(newItemToAdd);

                    [[NSNotificationCenter get] st_postNotificationName:STNotificationPhotosDidLocalSaved];
                });
            });
        }
            break;

        default:
            NSAssert(NO,@"Not supported");
            break;
    }
}

- (void)deletePhotos:(NSArray *)photoItems completion:(void(^)(BOOL succeed))completion{
    Weaks
    if(self.source==STPhotoSourceAssetLibrary){

        [self _deleteToAssetLibrary:photoItems completion:^(BOOL success, NSError *error) {
            !completion?:completion(success && error==nil);
        }];

    }else if(self.source==STPhotoSourceRoom){

        [UIAlertController alertToDeleteSelectedPhotos:^(__weak UIAlertController *alertController) {
            [self _deleteAllImagesWithBlankPreviewInRoom:photoItems completion:^{
                !completion ?: completion(YES);
            }];

        } cancel:^(__weak UIAlertController *alertController) {
            !completion ?: completion(NO);
        }];

    }else if(self.source==STPhotoSourceCapturedImageStorage){

        [UIAlertController alertToDeleteSelectedPhotos:^(__weak UIAlertController *alertController) {
            [self _deleteFromCapturedImageStorage:photoItems completion:completion];

        } cancel:^(__weak UIAlertController *alertController) {
            !completion ?: completion(NO);
        }];

    }
}

- (void)deleteAllSelectedPhotos:(void(^)(BOOL succeed))completion{
    Weaks
    [self deletePhotos:[self selectedPhotoItems] completion:^(BOOL succeed) {
        [Wself deselectAllCurrentSelected];
//            [[STMainControl sharedInstance] home];
        [[STMainControl sharedInstance] backToHome];

        !completion?:completion(succeed);
    }];
}

- (void)deleteAllPhotos:(void(^)(BOOL succeed))completion{
    Weaks
    NSArray * photos = [self allAvailablePhotoItems];
    if(photos.count){
        [self deletePhotos:photos completion:^(BOOL succeed) {
            !completion?:completion(succeed);

            [Wself loadFromCurrentSource];
        }];
    }else{
        !completion?:completion(NO);
    }
}

# pragma mark AssetLibrary's I/O Operations
- (void)_deleteToAssetLibrary:(NSArray *)photoItems completion:(void(^)(BOOL success, NSError *error))block{
    NSParameterAssert(photoItems.count);
    
    //pause observing
    Weaks
    //TODO FIXME: didBecomeActive를 홈버튼클릭 해서 온 건지 내 앱내에서 uiviewcontroller를 통해 온건지 식별하는게 가장 완벽
    [self lockOnceObservingPhotoLibraryChange];

    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        NSMutableArray *deleteTargetALAssetUrls = [NSMutableArray array];
        for(STPhotoItem * photoItem in photoItems){
            id value = [[photoItem sourceForALAsset] valueForProperty:ALAssetPropertyAssetURL];
            if(value && ![value isEqual:[NSNull null]]){
                [deleteTargetALAssetUrls addObject:value];
            }
        }
        PHFetchResult * fecthResult = [PHAsset fetchAssetsWithALAssetURLs:deleteTargetALAssetUrls options:nil];
        [PHAssetChangeRequest deleteAssets:fecthResult];

    } completionHandler:^(BOOL success, NSError *error) {
        [Wself st_runAsMainQueueAsync:^{
            Strongs
            NSAssert(photoItems && photoItems.count,@"photoitems why nil?");

            if(success){
                [Sself _removePhotoItems:photoItems completion:nil];
            }
            !block?:block(success, error);
        }];
    }];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)_writeToAssetLibrary:(STPhotoItemSource *)photo completion:(void(^)(NSURL *))block;{

    Weaks
//    if([STApp osVersion].majorVersion>=9){
    //TODO: fixed after iOS9 beta5
    if(NO){
        //TODO: Add Exif
        //using photokit
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            Strongs
            [PHAsset saveImageToCameraRoll:photo.image location:nil completionBlock:^(PHAsset *asset, BOOL success) {
                /*IMPORTANT: exclude '/L0/001'*/NSString * id = [[asset localIdentifier] substringToIndex:36];
                NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"assets-library://asset/asset.JPG?id=%@&ext=JPG",id]];
                runOnMainQueueWithoutDeadlocking(^{
                    !block?:block(success && asset ? url : nil);
                });
            }];
            //ios9 PHAssetCreationRequest
        });
    }else{

        if(photo.imageSet){
            for(STCapturedImage * image in [photo.imageSet images]){
                @autoreleasepool {
                    if(image.image){
                        [PHAsset saveImageToCameraRoll:image.image location:nil completionBlock:nil];
                    }else{
                        [PHAsset saveImageToCameraRollAtURL:[image NSURL] location:nil completionBlock:nil];
                    }
                }
            }

            [Wself st_runAsMainQueueAsync:^{
                !block ?: block(photo.imageSet.defaultImage.imageUrl);
            }];

        }else{

            //legacy
            [[STAssetsLibraryManager sharedManager] writeImageToSavedPhotosAlbum:photo.image.CGImage metadata:photo.metaData completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error) {
                    NSLog(@"ERROR: the image failed to be written");
                }else {
                    oo(([NSString stringWithFormat:@"PHOTO SAVED - assetURL: %@", assetURL]));
                }
                [Wself st_runAsMainQueueAsync:^{
                    !block?:block(error ? nil : assetURL);
                }];
            }];
        }

    }
}
#pragma clang diagnostic pop

- (void)_loadAndAddThumbnailsFromAssetLibrary; {
    WeakSelf weakSelf = self;
    __block NSMutableArray *_photos = [NSMutableArray array];

    [STAssetsLibraryManager enumerateNextGroupSavedPhotos:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        STPhotoItem *photoItem = [[STPhotoItem alloc] init];
        photoItem.sourceForALAsset = result;
        [_photos addObject:photoItem];

    } completion:^{

        [weakSelf st_runAsMainQueueAsync:^{
            [weakSelf _putPhotoItemsFromAssetLibrary:_photos addToLast:YES];

            [[NSNotificationCenter get] postNotificationName:STNotificationPhotosDidLoaded object:@(STPhotoSourceAssetLibrary)];

            [[STElieStatusBar sharedInstance] stopProgress];

            _photos = nil;
        }];

    }];
}

#pragma mark STPhotoSourceCapturedImageStorage

- (void)_loadAndAddThumbnailsFromCapturedImageStorage{
    dispatch_async([STQueueManager sharedQueue].readingIO, ^{
        NSArray<STCapturedImageSet *> * images = [[STCapturedImageStorageManager sharedManager] loadAllSets];
        images = [[[images copy] mapWithIndex:^id(RLMCapturedImageSet *imageSet, NSInteger index) {
            return [imageSet fetchImageSet];
        }] reverse];

        dispatch_async(dispatch_get_main_queue(),^{
            //convert STCapturedImageSet -> STPhotoItem
            NSArray * loadedPhotoItems = [images mapWithIndex:^id(STCapturedImageSet * imageSet, NSInteger index) {
                STPhotoItem *photoItem = [STPhotoItem itemWithIndex:index];
                photoItem.sourceForCapturedImageSet = imageSet;
                return photoItem;
            }];

            //add blank Items if needed
            if(loadedPhotoItems.count<18){
                loadedPhotoItems = [loadedPhotoItems arrayByAddingObjectsFromArray:[[@(20 - loadedPhotoItems.count) st_intArray] mapWithIndex:^id(id object, NSInteger index) {
                    STPhotoItem * blankItem = STPhotoItem.new;
                    blankItem.blanked = YES;
                    return blankItem;
                }]];
            }

            [self _putPhotoItemsFromCapturedImageStorage:loadedPhotoItems addToLast:NO];

            [[NSNotificationCenter get] postNotificationName:STNotificationPhotosDidLoaded object:@(STPhotoSourceCapturedImageStorage)];
        });
    });
}

- (void)_deleteFromCapturedImageStorage:(NSArray *)photoItems completion:(void(^)(BOOL success))block{
    NSParameterAssert(photoItems.count);

    if([[STCapturedImageStorageManager sharedManager] removeSets:[photoItems mapWithIndex:^id(STPhotoItem * photoItem, NSInteger index) {
        NSAssert(photoItem.sourceForCapturedImageSet, @"not found sourceForCapturedImageSet");
        return photoItem.sourceForCapturedImageSet;
    }]]){
        NSAssert(photoItems && photoItems.count,@"photoitems why nil?");
        [self _removePhotoItems:photoItems completion:^(BOOL finished) {
            !block?:block(YES);

            //reload blank items
            [self _reloadAllBlankPhotoItems];

        }];
    }else{
        !block?:block(NO);
    }
}

#pragma mark Elie Room's Image I/O Operations

#pragma mark Delete - Elie Room's Image I/O Operations
- (void)deleteAllRoomsImages:(void(^)(void))completion{
    if(self.source==STPhotoSourceRoom){
        [self _deleteAllImagesWithBlankPreviewInRoom:self.gridView.items completion:completion];
    }else{
        [self _deleteAllImageFilesInRoom:completion];
    }
}

- (void)_deleteAllImagesWithBlankPreviewInRoom:(NSArray *)photoItems completion:(void(^)(void))block{
    NSAssert(self.source==STPhotoSourceRoom, @"_deleteWithBlankPreviewToRoom can only at STPhotoSourceRoom");

    Weaks
    dispatch_async([STQueueManager sharedQueue].writingIO, ^{
        for(STPhotoItem * photoItem in photoItems){
            photoItem.blanked = YES;
            [Wself deleteImageToUrl:photoItem.sourceForFullScreenFromURL];
            [Wself deleteImageToUrl:photoItem.sourceForFullResolutionFromURL];
            [Wself deleteImageToUrl:photoItem.sourceForPreviewFromURL];
        }

        runOnMainQueueWithoutDeadlocking(^{
            Strongs
            [Sself _reloadPhotoItems:photoItems];

            !block?:block();
        });
    });
}

- (void)_deleteAllImageFilesInRoom:(void(^)(void))completion{
    Weaks
    dispatch_async([STQueueManager sharedQueue].writingIO, ^{
        for(NSURL *previewUrl in [Wself savedPreviewImageFileURLsInRoom]){
            [Wself deleteImageToUrl:[Wself makeSavedImageUrlFromOtherPreifx:previewUrl prefix:kSTImageFilePrefix_PreviewImage prefixConvertTo:kSTImageFilePrefix_OrigianlImage]];
            [Wself deleteImageToUrl:[Wself makeSavedImageUrlFromOtherPreifx:previewUrl prefix:kSTImageFilePrefix_PreviewImage prefixConvertTo:kSTImageFilePrefix_Fullscreen]];
            [Wself deleteImageToUrl:previewUrl];
        }
        [Wself st_runAsMainQueueAsync:^{
            !completion?:completion();
        }];
    });
}

#pragma mark Temp
- (void)_writeToTempAndCreateItem:(STPhotoItemSource *)photoSource completion:(void(^)(STPhotoItem *))block{
    __weak STPhotoSelector *weakSelf = self;

    /*
     * new - preheated image set
     */
    STPhotoItem *item = [STPhotoItem itemWithIndex:self.gridView.items.count];
    item.orientationOriginated = photoSource.orientation;

    //TODO: 현재는 imageSet전용이지만 추후 전체를 통합
    if(photoSource.imageSet.defaultImage){
        item.sourceForCapturedImageSet = photoSource.imageSet;
        item.metadataFromCamera = photoSource.metaData;

        [photoSource dispose];

        dispatch_async([STQueueManager sharedQueue].writingIO, ^{
            for(STCapturedImage * image in item.sourceForCapturedImageSet.images){
                [image createThumbnail:nil];
                [image createFullScreenImage:nil];
            }

            dispatch_async(dispatch_get_main_queue(),^{
                !block?:block(item);
            });

        });
        return;
    }

    /*
     * legacy
     */
    dispatch_async([STQueueManager sharedQueue].writingIO, ^{
        STPhotoSelector *_self = weakSelf;

        UIImage *defaultImage = photoSource.image;

        NSURL *originalUrl = [_self makeTempImageSaveUrl:kSTImageFilePrefix_TempToEdit_OrigianlImage];
        NSURL *fullscreenUrl = [_self makeTempImageSaveUrl:kSTImageFilePrefix_TempToEdit_Fullscreen];
        [_self saveImageToUrl:[defaultImage scaleToFitSize:[STGIFFApp memorySafetyRasterSize:[_self previewImageSizeByType:STPhotoViewTypeDetail]]] fileUrl:fullscreenUrl quality:.8 background:NO];

        NSURL *previewUrl = [_self makeTempImageSaveUrl:kSTImageFilePrefix_TempToEdit_PreviewImage];
        UIImage *previewImage = [defaultImage scaleToFitSize:[STGIFFApp memorySafetyRasterSize:[_self previewImageSizeByType:STPhotoViewTypeGridHigh]]];
        [item initializePreviewImage:previewImage];

        item.sourceForFullResolutionFromURL = originalUrl;
        item.sourceForFullScreenFromURL = fullscreenUrl;
        item.sourceForPreviewFromURL = previewUrl;

        runOnMainQueueWithoutDeadlocking(^{
            //metadata
            item.metadataFromCamera = photoSource.metaData;
            item.origin = photoSource.origin;

            [photoSource dispose];

            if(block){
                block(item);
            }
        });

        [_self saveImageToUrl:previewImage fileUrl:previewUrl quality:.7];
        [_self saveImageToUrl:defaultImage fileUrl:originalUrl quality:1.0];
    });
}

- (void)_loadAndPutThumbnailsFromRoom {
//    if([Elie isInSimulator]){
//        [self _test_loadAndPutThumbnailsFromRoom];
//        return;
//    }

    Weaks
    dispatch_async([STQueueManager sharedQueue].readingIO, ^{
        NSArray * savedPreviewImageFileURLs = [self savedPreviewImageFileURLsInRoom];
        NSMutableDictionary * availablePreviewImageURLs = [NSMutableDictionary dictionaryWithCapacity:savedPreviewImageFileURLs.count];
        for(NSURL * url in savedPreviewImageFileURLs){
            availablePreviewImageURLs[@([self indexFromSaveUrl:url prefix:kSTImageFilePrefix_PreviewImage])] = url;
        }

        //make photo items
        NSMutableArray *photoItems = [NSMutableArray array];
        [@(0) upto:STGIFFAppSetting.get.currentRoomSize -1 do:^(NSInteger index) {
            STPhotoItem *photoItem = [[STPhotoItem alloc] initWithIndex:index];

            if([availablePreviewImageURLs hasKey:@(index)]){
            // available
                NSURL * previewURL = availablePreviewImageURLs[@(index)];
                photoItem.sourceForFullResolutionFromURL = [Wself makeSavedImageUrlFromOtherPreifx:previewURL prefix:kSTImageFilePrefix_PreviewImage prefixConvertTo:kSTImageFilePrefix_OrigianlImage];
                photoItem.sourceForFullScreenFromURL = [Wself makeSavedImageUrlFromOtherPreifx:previewURL prefix:kSTImageFilePrefix_PreviewImage prefixConvertTo:kSTImageFilePrefix_Fullscreen];
                photoItem.sourceForPreviewFromURL = previewURL;

                //check file
                if(![[NSFileManager defaultManager] fileExistsAtPath:[photoItem.sourceForFullResolutionFromURL path]]){
                    photoItem.blanked = YES;
                }
            }else{
            //blanked
                photoItem.blanked = YES;
            }
            [photoItems addObject:photoItem];
        }];

        [Wself st_runAsMainQueueAsyncWithSelf:^(id selfObject) {
            [selfObject doPutPhotoItems:photoItems];

            [[NSNotificationCenter get] postNotificationName:STNotificationPhotosDidLoaded object:@(STPhotoSourceRoom)];
        }];
    });
}

- (void)_test_loadAndPutThumbnailsFromRoom{
    NSMutableArray * items = [NSMutableArray array];

    for(NSInteger i=0; i< STGIFFAppSetting.get.currentRoomSize; i++){
        CGSize size = ST_XSIZE(CGSizeMake(319, 426) ,0.25);
        NSString *fileName = NSStringWithFormat(@"sample_img%d.jpg",i);

        NSURL * url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath],fileName]];

        STPhotoItem *photoItem = [[STPhotoItem alloc] initWithIndex:i];
        [photoItem setSourceForFullResolutionFromURL:url];
        [photoItem setSourceForFullScreenFromURL:url];
        [photoItem setSourceForPreviewFromURL:url];

//        [photoItem loadPreviewImage];

        [items addObject:photoItem];
    }
    [self doPutPhotoItems:items];
}

#pragma mark Common - Elie Room's Image I/O Operations
- (void)saveImageToUrl:(UIImage *)image fileUrl:(NSURL *)url quality:(CGFloat)quality {
    [self saveImageToUrl:image fileUrl:url quality:quality background:YES];
}

- (void)saveImageToUrl:(UIImage *)image fileUrl:(NSURL *)url quality:(CGFloat)quality background:(BOOL)background{
    if(background){
        dispatch_async([STQueueManager sharedQueue].writingIO, ^{
            [[NSFileManager defaultManager] createFileAtPath:[url path] contents:UIImageJPEGRepresentation(image, quality ? quality : 1.f) attributes:nil];
        });
    }else{
        [[NSFileManager defaultManager] createFileAtPath:[url path] contents:UIImageJPEGRepresentation(image, quality ? quality : 1.f) attributes:nil];
    }
}

- (void)deleteImageToUrl:(NSURL *)url{
    if([[NSFileManager defaultManager] fileExistsAtPath:[url path]] && [[NSFileManager defaultManager] isDeletableFileAtPath:[url path]]){
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    }
}

- (NSURL *)makeTempImageSaveUrl:(NSString *)prefixName {
    return [[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:prefixName]] URLByAppendingPathExtension:@"jpg"];
}

- (NSURL *)makeImagesSaveUrl:(NSString *)prefixName index:(NSInteger)index {
    return [self makeImagesSaveUrl:[self saveTargetDir] prefix:prefixName index:index];
}

- (NSURL *)makeImagesSaveUrl:(NSString *)dirPath prefix:(NSString *)prefix index:(NSInteger)index {
    NSString *fileName = [prefix stringByAppendingFormat:@"%d", index];
    return [[NSURL fileURLWithPath:[dirPath stringByAppendingPathComponent:fileName]] URLByAppendingPathExtension:@"jpg"];
}

- (NSURL *)makeSavedImageUrlFromOtherPreifx:(NSURL *)url prefix:(NSString *)prefix prefixConvertTo:(NSString *)prefixConvertTo {
    return [self makeImagesSaveUrl:prefixConvertTo index:[self indexFromSaveUrl:url prefix:prefix]];
}

- (NSInteger)indexFromSaveUrl:(NSURL *)url prefix:(NSString *)prefix {
    NSString *filename = [[url URLByDeletingPathExtension] lastPathComponent];

    if(![filename matchesRegex:[prefix stringByAppendingString:@"[0-9]{1,}$"]]){
        NSLog(@"* WARN : filename must be match with prefix");
        return 0;
    }

    return [[[filename split:prefix] lastObject] integerValue];
}

- (NSString *)saveTargetDir{
    NSString *dir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    if(!dir){
        dir = NSTemporaryDirectory();
    }
    return dir;
}

- (NSArray *)savedPreviewImageFileURLsInRoom {
    NSURL *fileDir = [NSURL fileURLWithPath:[self saveTargetDir] isDirectory:YES];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:fileDir
                                                      includingPropertiesForKeys:@[]
                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                           error:nil];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == 'jpg' AND lastPathComponent CONTAINS %@", kSTImageFilePrefix_PreviewImage];
    return [contents filteredArrayUsingPredicate:predicate];
}

#pragma mark Export
//TODO: export original 계열들은 인터럽트 구현
- (void)exportItemToSourceAndAdd:(STPhotoSource)source item:(STPhotoItem *)item completion:(void(^)(STPhotoItem *))block {
    Weaks

    [[STElieStatusBar sharedInstance] startProgress:nil];

    void(^completionBlock)(STPhotoItem *) = ^(STPhotoItem *createdItem) {
        [[STElieStatusBar sharedInstance] stopProgress];

        if(createdItem){
            createdItem.currentFilterItem = item.currentFilterItem;

            // clear already edited preview image
            item.currentFilterItem = nil;
            [item loadPreviewImage];

            [Wself updateExportedStateIfNeeded:[createdItem fullResolutionURL]];
        }

        !block?:block(createdItem);
    };

    STPhotoItemSource * imageSource = [STExporter createPhotoItemSourceToExport:item];
    [self _writeAndAdd:source image:imageSource completion:completionBlock];
}

- (void)exportItemToAssetLibrary:(STPhotoItem *)item completion:(void(^)(NSURL *))block {
    Weaks

    [[STElieStatusBar sharedInstance] startProgress:nil];

    //TODO: filter 와 tool 수정이 없을 경우 direct copy
    dispatch_async([STQueueManager sharedQueue].writingIOHigh, ^{
        STPhotoItemSource * photoItemSource = [STExporter createPhotoItemSourceToExport:item];
        
        [Wself _writeToAssetLibrary:photoItemSource completion:^(NSURL *_url) {
            Strongs
            [[STElieStatusBar sharedInstance] stopProgress];

            [Sself updateExportedStateIfNeeded:_url];

            !block?:block(_url);
        }];
    });
}

static BOOL test = NO;
- (void)exportItemsToAssetLibrary:(NSArray *)photoItems blockForAllFinished:(void(^)(NSArray *))block {
    //check photos permission
    if(!STPermissionManager.photos.isAuthorized){
        NSArray * targetPhotoItems = [photoItems copy];
        [STPermissionManager.photos promptOrStatusIfNeeded:^(STPermissionStatus _status) {
            if (_status == STPermissionStatusAuthorized) {
                [self exportItemsToAssetLibrary:targetPhotoItems blockForAllFinished:block];

            }else{
                [STApp logUnique:@"PhotosPermissionUserDenied"];
                !block?:block(nil);
            }
        }];
        return;
    }

    __block NSUInteger progressCount = 0;
    __block NSMutableArray * succeedUrls = [NSMutableArray array];

    for(STPhotoItem * photoItem in photoItems){
        Weaks
        [self exportItemToAssetLibrary:photoItem completion:^(NSURL *url) {
            progressCount++;
            NSAssert(progressCount <= photoItems.count, @"doExportAllCurrentSelectedToPhotoLibrary : must export target's count and finished count are same.");

            if (url) {
                [succeedUrls addObject:url];
            }

            if (progressCount == photoItems.count) {

                if (block) {
                    block(succeedUrls);
                }
                succeedUrls = nil;

                // all complete
            }
        }];
    }
}


#pragma mark Room Export state

//FIXME: SaveToLocal + Room Export 의 경우, 성공이 아니더라도 뱃지 카운트가 중가한다.
//FIXME: (Export상태와 연동이 되지 않는다.추후 사진 저장부분을 Export에 통합)

- (void)updateExportedStateIfNeeded:(NSURL *)assetUrl{
    NSParameterAssert(assetUrl);
    if(!assetUrl){
        return;
    }

    if(STPhotoSourceRoom==self.source){
        [[STGIFFAppSetting get] savePhotosOrigin:assetUrl origin:STPhotoItemOriginExportedFromRoom];
        [[STMainControl sharedInstance].subControl incrementBadgeNumberToRight:STControlDisplayModeHome];
    }
}

- (void)loadExportedStateIfNeededWhenChangedSource {
    if(STPhotoSourceRoom==self.source){
        NSArray * photoUrls = [[STGIFFAppSetting get] photoUrlsByOrigin:STPhotoItemOriginExportedFromRoom];
        if(photoUrls.count){
            [[STMainControl sharedInstance].subControl setBadgeToRight:[@(photoUrls.count) stringValue] mode:STControlDisplayModeHome];
        }

    }else if(STPhotoSourceAssetLibrary==self.source){
        [[STMainControl sharedInstance].subControl resetBadgeNumberToRight];
        [[STGIFFAppSetting get] clearPhotosOrigins];
    }
}

- (void)displayStatusBarWhenChangedSourceIfNeeded{
    /*
     * status bar message
     */
    switch (self.source){
        case STPhotoSourceAssetLibrary:
            [[STElieStatusBar sharedInstance] message:NSLocalizedString(@"Camera_Roll",nil)];
            break;
        case STPhotoSourceRoom:
            [[STElieStatusBar sharedInstance] message:NSLocalizedString(@"Room",nil)];
            break;
        default:
            break;
    }
}
@end