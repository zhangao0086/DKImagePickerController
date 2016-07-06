//
// Created by BLACKGENE on 2014. 9. 2..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <MTGeometry/MTGeometry.h>
#import <SVGKit/SVGKImage.h>
#import <SVGKit/SVGKImageView.h>
#import <BlocksKit/NSArray+BlocksKit.h>
#import "iCarousel.h"
#import "STMainControl.h"
#import "STHome.h"
#import "STCarouselHolderController.h"
#import "STPhotoSelector.h"
#import "STSubControl.h"
#import "STUserActor.h"
#import "STFilterItem.h"
#import "CAShapeLayer+STUtil.h"
#import "STFilterPresenterItemView.h"
#import "STExportManager.h"
#import "STCaptureRequest.h"
#import "STStandardButton.h"
#import "NSObject+STPopAnimatableProperty.h"
#import "STGIFFAppSetting.h"
#import "STStandardCollectableButton.h"
#import "STStandardNavigationButton.h"
#import "NSArray+STUtil.h"
#import "CALayer+STUtil.h"
#import "NSObject+STUtil.h"
#import "UIImage+Filtering.h"
#import "STFilterPresenterBase.h"
#import "STExporter+Config.h"
#import "STElieStatusBar.h"
#import "SVGKImage+STUtil.h"
#import "SVGKFastImageView.h"
#import "SVGKFastImageView+STUtil.h"
#import "R.h"


#import "NSObject+STThreadUtil.h"
#import "UIScrollView+AGK+Properties.h"
#import "STPermissionManager.h"
#import "STCaptureProcessor.h"
#import "STFilterManager.h"
#import "STUIApplication.h"
#import "STFilterGroupItem.h"
#import "STProductCatalogView.h"
#import "M13OrderedDictionary.h"
#import "NSString+STUtil.h"
#import "STStandardReachableButton.h"
#import "STFilterPresenterProductItemView.h"
#import "STApp+Logger.h"
#import "STExporter+View.h"
#import "UIColor+BFPaperColors.h"
#import "ChameleonMacros.h"
#import "STExportSelectView.h"
#import "NSNotificationCenter+STFXNotificationsShortHand.h"
#import "STPostFocusCaptureRequest.h"

@interface STMainControl ()
- (void)willModeChanged;

- (void)didAfterModeChanged;

- (void)setNeedsLayoutByMode;

- (void)_setHome;

- (void)_setHomeActive;

- (void)_setExport;
@end

@implementation STMainControl
{
    void (^_whenChangedDisplayMode)(STControlDisplayMode mode, STControlDisplayMode previousMode);

    STControlDisplayMode _previousMode;

    NSMutableArray * _historyModes;

    STHome * _home;

    STFilterCollector *_homeFilterCollector;

    STStandardNavigationButton * _homeCollectable;

    STSubControl *_subControl;
}

static STMainControl *_instance = nil;

+ (STMainControl *)sharedInstance {
    return _instance;
}

+ (STMainControl *)initSharedInstanceWithFrame:(CGRect)frame {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] initWithFrame:frame];
        _instance->_mode = STControlDisplayModeMain_initial;
    });
    return _instance;
}

#pragma mark STMainControl HitTest
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event; {
    UIView * hittedView = [super hitTest:point withEvent:event];

    /*
     * if not initialized elie camera yet.
     */
    if(![[STElieCamera sharedInstance] captureSession].isRunning && STElieCamera.mode == STCameraModeNotInitialized){
        [self st_runAsMainQueueAsyncWithoutDeadlocking:^{
            [STStandardUX expressDenied:hittedView];
        }];
        return nil;
    }

    /*
     * if touch point over half of MainControl's bound / if hit test target is available, test it or return through.
     */
    BOOL testHitOnControl = NO;
    switch (_mode){
        case STControlDisplayModeHome:
        case STControlDisplayModeExport:
            testHitOnControl = point.y < self.height/2;
            break;

        default:
            break;
    }
    if(testHitOnControl){
        return [self hitOnControls:point withEvent:event] ? hittedView : nil;
    }

    /*
     * return default target;
     */
    return hittedView;
}

- (BOOL)hitOnControls:(CGPoint)point withEvent:(UIEvent *)event;{
    return [_subControl.leftButton hitTest:[self convertPoint:point toView:_subControl.leftButton] withEvent:event] ||
            [_subControl.rightButton hitTest:[self convertPoint:point toView:_subControl.rightButton] withEvent:event] ||
            [_home pointInside:[self convertPoint:point toView:_home] withEvent:event];
}

#pragma mark ViewState while app starting
- (void)saveStates {

}

- (void)restoreStatesIfPossible {
    
}

#pragma mark Home

- (STHome *)homeView {
    return _home;
}

- (void)setPreviewVisibility:(CGFloat)visibility; {
    if(!_home.previewQuickCaptureMode){
        _home.previewVisiblity = visibility;
    }
    _home.spinnerVisiblity = visibility==1;
}

- (void)setPreviewCurtain:(BOOL)visibility; {
    BOOL previewWasVisible = _home.previewVisiblity==1;
    if(_home.previewCurtain != visibility && previewWasVisible){
        _home.previewVisiblity = 0;
    }

    _home.previewCurtain = visibility;

    if(previewWasVisible){
        _home.previewVisiblity = 1;
    }
}

- (void)setPhotoSelected:(NSUInteger) count {
    
}

- (void)setDisplayHomeScrolledGridView:(CGFloat)offset withCount:(NSUInteger) count {
    _home.indexProgressDisplayInstantly = YES;
    [_home setIndexNumberOfSegments:count];
    [_home setIndexProgress:offset/count];
}

#pragma mark Home Filters
- (NSUInteger)homeSelectedFilterItemIndex{
    return [self _homeFilterItemIndex:_homeSelectedFilterItem];
}

- (NSUInteger)_homeFilterItemIndex:(STFilterItem *)filterItem{
    NSUInteger selectedFilterIndex = 0;
    if(filterItem){
        NSUInteger index = [_homeFilterCollector.items indexOfObject:filterItem];
        selectedFilterIndex = NSNotFound==index? 0:index;
    }
    return selectedFilterIndex;
}

- (STFilterItem *)_homeFilterItemAt:(NSInteger )index{
    return [_homeFilterCollector.items st_objectOrNilAtIndex:index];
}

#pragma mark Reset by scrolled
- (void)setNeedsDisplayCurrentHomeScrolledFilters{
    STFilterCollectorState * state = [STPhotoSelector sharedInstance].previewState;
    [self setDisplayHomeScrolledFilters:state.currentFocusedFilterIndex withCount:state.numberOfFilters];
}

static BOOL _needsShowCollectables = NO;
- (void)setDisplayHomeScrolledFilters:(NSUInteger)index withCount:(NSUInteger) count {
    _home.indexProgressDisplayInstantly = NO;
    [_home setIndexNumberOfSegments:count];
    [_home setIndexProgress:count ? (CGFloat)(index+1)/count : 0];

    //cart icon
    STFilterItem * currentFilterItem = [STPhotoSelector sharedInstance].previewState.currentFocusedFilterItem;
    if(currentFilterItem.type == STFilterTypeITunesProduct){
        [self __setToHomeStyle:R.ico_cart color:currentFilterItem.representativeColor];
    }else{
        [self __setToHomeStyle:nil color:currentFilterItem.representativeColor];
    }

    [self _showCollectablesFromScrolledIndexIfNeeded:index];
}

- (void)_showCollectablesFromScrolledIndexIfNeeded:(NSUInteger)index{
    if(index == 0){
        if(!_needsShowCollectables){
            _needsShowCollectables = YES;
            [self hideContextNeededResetButton];
        }
    }else{
        if(_needsShowCollectables){
            _needsShowCollectables = NO;

            [self showContextNeededResetButton];
        }
    }
}


// Edit selected
- (void)enterEdit {
    [self setMode:STControlDisplayModeEdit];
}

- (void)exitEdit {
    [_home setBackgroundCircleColor:nil];
    [self back];
}

// Edit Aftercapture
- (void)enterEditAfterCapture {
    [self setMode:STControlDisplayModeEditAfterCapture];
}

- (void)exitEditAfterCapture {
    [self back];
}

// Review AftercaptureAnimatable
- (void)enterReviewAfterAnimatableCapture {
    [self setMode:STControlDisplayModeReviewAfterAnimatableCapture];
}

- (void)exitReviewAfterAnimatableCapture {
    [self back];
}

// Edit Tool
- (void)enterEditTool {
    [self setMode:STControlDisplayModeEditTool];
}

- (void)exitEditTool {
    [self back];
}

// Camera
- (void)enterLivePreview {;
    [self setMode:STControlDisplayModeLivePreview];
}

- (void)exitLivePreview {
    [self back];
}

- (void)main {
    [self setMode:STControlDisplayModeMain];
}

- (void)requestGoMain {
    if(self.mode == STControlDisplayModeMain){
        return;
    }

    if(![STElieCamera sharedInstance].faceDetectionStarted){
        Weaks
        [[STElieCamera sharedInstance] whenNewValueOnceOf:@keypath([STElieCamera sharedInstance].faceDetectionStarted) id:@"STMainControl.requestGoMain" changed:^(id value, id _weakSelf) {
            Strongs
            if([value integerValue] != STCameraModeNotInitialized){
                [Sself requestGoMain];
                [Sself->_home cancelRestoreStateEffect];
            }
        }];
        return;
    }

    [self main];
}

//Export
- (void)export {
    [self setMode:STControlDisplayModeExport reload:self.mode == STControlDisplayModeExport];
}

//home
- (void)home {
    [self setMode:STControlDisplayModeHome];
}


#pragma mark Static Instant Effect
#pragma mark Cover
- (void)showCoverWith:(UIView *)view completion:(void (^)(void))completion{
    [_subControl setVisibleWithEffect:YES effect:STSubControlVisibleEffectCover relationView:view completion:^(POPAnimation *anim, BOOL finished) {
        !completion ?: completion();
    }];
}

- (void)hideCoverWith:(UIView *)view completion:(void (^)(void))completion{
    [_subControl setVisibleWithEffect:NO effect:STSubControlVisibleEffectCover relationView:view completion:^(POPAnimation *anim, BOOL finished) {
        !completion ?: completion();
    }];
}

#pragma mark Show/Hide
static BOOL _controlsShowen = YES;
- (void)showControls {
    if(_controlsShowen){
        return;
    }
    _controlsShowen = YES;

    [_home st_springCGFloat:_home.initialFrame.origin.y keypath:@"y"];
    [_subControl setVisibleWithEffect:YES effect:STSubControlVisibleEffectOutside];
}

- (void)hideControls {
    if(!_controlsShowen){
        return;
    }
    _controlsShowen = NO;

    [_home st_springCGFloat:self.height+10 keypath:@"y"];

    [_subControl setVisibleWithEffect:NO effect:STSubControlVisibleEffectOutside];
}

#pragma mark Show/HideScrolling
- (BOOL)interruptShowHideControlsWhenScrolling {
    BOOL interrupt = NO;

    //while loading current source
    if([STPhotoSelector sharedInstance].loadingSource){
        interrupt = YES;
    }

    //by mode
    switch(_mode){
        case STControlDisplayModeHome:
            break;

        case STControlDisplayModeHomeFilterSelectable:
            [self backToHome];
            interrupt = YES;
            break;

        default:
            interrupt = YES;
            break;
    }

    //Control can only perform show/hide when collection view's height X 3 is smaller than content height.
    if(!interrupt && [STPhotoSelector sharedInstance].collectionView.height * [STStandardUX maxMultipleNumberOfFrameHeightByContentHeightToHideControlsWhenScrolling] > [STPhotoSelector sharedInstance].collectionView.contentSizeHeight){
        interrupt = YES;
    }

    //show controls if interrupt
    if(interrupt){
        [self showControlsWhenStopScrolling];
    }

    return interrupt;
}

BOOL _scrollStopped = YES;
- (void)showControlsWhenStopScrolling {
    if(_scrollStopped){
        return;
    }
    _scrollStopped = YES;

    if([self interruptShowHideControlsWhenScrolling]){
        return;
    }

    [self setMode:_mode reload:YES];
//    [_subControl setVisibleWithEffect:YES effect:STSubControlVisibleEffectEnterCenter];
}

- (void)hideControlsWhenStartScrolling {
    if(!_scrollStopped){
        return;
    }
    _scrollStopped = NO;

    if([self interruptShowHideControlsWhenScrolling]){
        return;
    }

    Weaks
    [_home setDisplayToDefault];
    STStandardButton * button = [_home setDisplayScrollTop];
    [button whenSelected:^(STSelectableView *selectedView, NSInteger index) {
        [[STPhotoSelector sharedInstance] doScrollTop];
        [Wself showControlsWhenStopScrolling];
    }];

//    [_subControl setVisibleWithEffect:NO effect:STSubControlVisibleEffectEnterCenter relationView:_home completion:^(POPAnimation *anim, BOOL finished) {
//        if(finished){
//            Strongs
//            button.spring.bottom = button.superview.bottom-8;
//        }
//    }];
}

#pragma mark ParallaxEffect
- (void)startParallaxEffect{
    Weaks
    [self st_performOnceAfterDelay:@"lazyApplyParallax" interval:TIMEINTERVAL_LAZY block:^{
        Strongs
        [STStandardUX startParallaxToViews:@[Sself->_home, @[Sself->_subControl]]];
    }];
}

- (void)stopParallaxEffect{
    [self st_clearPerformOnceAfterDelay:@"lazyApplyParallax"];
    [STStandardUX stopParallaxToViews:@[_home, _subControl]];
}

// show/hide top collectables
#pragma mark Home Collectable
- (void)setNeededToShowOrHideHomeCollectable {
    switch (self.mode){
//        case STControlDisplayModeEditAfterCapture:{
//            if(_previousMode!=STControlDisplayModeHome){
//                _homeCollectable.visible = YES;
//                [_homeCollectable expand];
//            }else{
//                _homeCollectable.visible = NO;
//                [_homeCollectable retract:NO];
//            }
//        }
//            break;
        case STControlDisplayModeLivePreview:{
            _homeCollectable.visible = YES;
            [_homeCollectable expand];
        }
            break;
        default:
            _homeCollectable.visible = NO;
            [_homeCollectable retract:NO];
            break;
    }
}

#pragma mark Home Reset
- (BOOL)showContextNeededResetButton {
    switch (self.mode){
        case STControlDisplayModeEdit:
        case STControlDisplayModeEditAfterCapture:
        case STControlDisplayModeReviewAfterAnimatableCapture:
        case STControlDisplayModeEditTool:
        case STControlDisplayModeLivePreview:
            [[self subControl] expandCollectablesContextNeeded];
            return YES;
        default:
            return NO;
    }
}

- (BOOL)hideContextNeededResetButton {
    switch (self.mode){
        case STControlDisplayModeEdit:
        case STControlDisplayModeEditAfterCapture:
        case STControlDisplayModeReviewAfterAnimatableCapture:
        case STControlDisplayModeEditTool:
        case STControlDisplayModeLivePreview:
            [[self subControl] retractCollectablesContextNeeded];
            return YES;
        default:
            return NO;
    }
}

//Quick Capture

#pragma mark internal inits
- (id)initWithFrame:(CGRect)frame; {
    self = [super initWithFrame:frame];
    if (self) {
        self.touchInsidePolicy = STUIViewTouchInsidePolicyContentInside;
        _historyModes = [NSMutableArray array];
    }
    return self;
}

- (void) createContent;{
    _home = [[STHome alloc] initWithFrame:[self centeredHomeFrame]];
    _home.userInteractionEnabled = STPermissionManager.camera.isAuthorized;
    _home.touchInsidePolicy = STUIViewTouchInsidePolicyContentInside;

    _subControl = [[STSubControl alloc] initWithFrame:[self bounds]];

    _homeFilterCollector = [[STFilterCollector alloc] init];

    [self setMode:STControlDisplayModeHome];

    /*
        adds
     */

////    [self st_setShadow:UIRectEdgeBottom size:-self.height shadowColor:UIColorFromRGB(0xd2d2d2) clearColor:[STStandardUI.blankObjectColor colorWithAlphaComponent:0] rasterize:YES strong:NO atIndex:0];
//    [self st_setShadow:UIRectEdgeBottom size:-self.height shadowColor:nil clearColor:nil rasterize:NO strong:YES atIndex:0];
//    [self st_shadow].y += 1;
//
//    UIVisualEffectView * effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
//    effectView.size = self.size;
//
//    effectView.maskView = self.st_shadow;
////    effectView.bottom = self.bottom;
//    [self addSubview:effectView];

//    effectView.maskView = self.st_shadow;

    [self addSubview:_subControl];
    [self addSubview:_home];

    /*
     * home collectable
     */
    STStandardButton *manualAfterCaptureCollectable = [STStandardButton subAssistanceSize];
    manualAfterCaptureCollectable.allowSelectedStateFromTouchingOutside = YES;
    [manualAfterCaptureCollectable setButtons:@[[R set_manual_continue], [R set_manual_single]] colors:@[[UIColor whiteColor],[UIColor whiteColor]] bgColors:@[[STStandardUI pointColor],[STStandardUI pointColor]] style:STStandardButtonStylePTBT];
    manualAfterCaptureCollectable.valuesMap = @[@(STAfterManualCaptureActionSaveToLocalAndContinue), @(STAfterManualCaptureActionEnterEdit)];
    manualAfterCaptureCollectable.currentMappedValue = @(STGIFFAppSetting.get.afterManualCaptureAction);
    [manualAfterCaptureCollectable whenSelectedWithMappedValue:^(STSelectableView *button, NSInteger index, id value) {
        _homeCollectable.alpha = 1;
        [UIView animateWithDuration:.4 delay:1 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            _homeCollectable.alpha = [STStandardUI alphaForDimmingWeak];
        } completion:nil];

        switch ([STGIFFAppSetting get].afterManualCaptureAction = [value integerValue]){
            case STAfterManualCaptureActionSaveToLocalAndContinue:
                [[STElieStatusBar sharedInstance] message:NSLocalizedString(@"Shoot And Autosave",nil)];
                break;
            case STAfterManualCaptureActionEnterEdit:
                [[STElieStatusBar sharedInstance] message:NSLocalizedString(@"Shoot And Review",nil)];
                break;
            default:
                break;
        }
    }];

    /*
     * resolution
     */

    NSArray * const supportedPresets = [STCaptureRequest supportedPresets];

    STStandardButton *resolutionCollectable = [STStandardButton subAssistanceSize];
    resolutionCollectable.allowSelectedStateFromTouchingOutside = YES;
    [resolutionCollectable setButtons:[supportedPresets mapWithIndex:^id(id object, NSInteger index) {
        switch((CaptureOutputSizePreset)[object integerValue]){
            case CaptureOutputSizePresetSmall: return [R set_resolution_small];
            case CaptureOutputSizePresetMedium: return [R set_resolution_medium];
            case CaptureOutputSizePresetLarge: return [R set_resolution_full];
            case CaptureOutputSizePreset4K: return [R set_resolution_4k];
            default:
                return [NSNull null];
        }
        return nil;
    }] colors:[supportedPresets mapWithIndex:^id(id object, NSInteger index) {
        switch((CaptureOutputSizePreset)[object integerValue]){
            case CaptureOutputSizePreset4K:
                return [STStandardUI pointColor];
            default:
                return [UIColor whiteColor];
        }
    }] bgColors:nil style:STStandardButtonStylePTBT];

    resolutionCollectable.valuesMap = supportedPresets;
    resolutionCollectable.currentMappedValue = @([self setCaptureSizePreset:(CaptureOutputSizePreset) [[STGIFFAppSetting.get read:@keypath([STGIFFAppSetting get].captureOutputSizePreset)] integerValue] userTapped:NO]);
    //postFocusMode -> captureOutputSizePreset -> currentMappedValue
    [[STGIFFAppSetting get] whenValueOf:@keypath([STGIFFAppSetting get].postFocusMode) id:@"postFocusMode_maincontrol" changed:^(id value, id _weakSelf) {
        [self setCaptureSizePreset:(CaptureOutputSizePreset) [[STGIFFAppSetting.get read:@keypath([STGIFFAppSetting get].captureOutputSizePreset)] integerValue] userTapped:NO];
    }];
    //user click -> captureOutputSizePreset -> currentMappedValue
    [resolutionCollectable whenSelectedWithMappedValue:^(STSelectableView *button, NSInteger index, id value) {
        [self setCaptureSizePreset:(CaptureOutputSizePreset) [value integerValue] userTapped:YES];
    }];
    //captureOutputSizePreset -> collectable
    [[STGIFFAppSetting get] whenValueOf:@keypath([STGIFFAppSetting get].captureOutputSizePreset) id:@"captureOutputSizePreset_maincontrol" changed:^(id value, id _weakSelf) {
        resolutionCollectable.currentMappedValue = value;
    }];

    /*
     * config home collectable
     */
    _homeCollectable = [[STStandardNavigationButton alloc] initWithSizeWidth:[STStandardLayout widthMainSmall]+6];
    _homeCollectable.synchronizeCollectableSelection = NO;
    _homeCollectable.autoRetractWhenSelectCollectableItem = NO;
    _homeCollectable.autoUXLayoutWhenExpanding = YES;
    _homeCollectable.invertMaskInButtonAreaForCollectableBackground = YES;
    // as a collectable
    _homeCollectable.collectablesSelectAsIndependent = NO;
    _homeCollectable.collectableToggleEnabled = YES;
    [_homeCollectable setCollectablesAsButtons:@[manualAfterCaptureCollectable,resolutionCollectable] backgroundStyle:STStandardButtonStylePTBT];
    _homeCollectable.collectableView.startDegree = 90;
    [_homeCollectable setCollectablesUserInteractionEnabled:YES];
    [self insertSubview:_homeCollectable belowSubview:_home];
    [_homeCollectable centerToParent];
    [_homeCollectable expand:NO];

    [UIView animateWithDuration:.4 delay:1 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        _homeCollectable.alpha = [STStandardUI alphaForDimmingWeak];
    } completion:nil];

    [[NSNotificationCenter get] st_addObserverWithMainQueue:self forName:STNotificationPhotosDidLocalSaved usingBlock:^(NSNotification *note, id observer) {
        [self setNeededToShowOrHideHomeCollectable];
    }];
}

- (CaptureOutputSizePreset)setCaptureSizePreset:(CaptureOutputSizePreset)preset userTapped:(BOOL)userTapped {
    _homeCollectable.alpha = 1;
    [UIView animateWithDuration:.4 delay:1 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        _homeCollectable.alpha = [STStandardUI alphaForDimmingWeak];
    } completion:nil];

    [STGIFFAppSetting get].captureOutputSizePreset = [STPostFocusCaptureRequest restrictCaptureOutputSizePresetByPostFocusMode:(STPostFocusMode) [STGIFFAppSetting get].postFocusMode
                                                                                                                  targetPreset:preset
                                                                                                                     circulate:userTapped];

    if(userTapped){
        switch (preset){
            case CaptureOutputSizePresetMedium:
                [[STElieStatusBar sharedInstance] message:[NSString stringWithFormat:NSLocalizedString(@"Image Size: ",nil),NSLocalizedString(@"Medium",nil)]];
                break;
            case CaptureOutputSizePresetSmall:
                [[STElieStatusBar sharedInstance] message:[NSString stringWithFormat:NSLocalizedString(@"Image Size: ",nil),NSLocalizedString(@"Small",nil)]];
                break;
            case CaptureOutputSizePresetLarge:
                [[STElieStatusBar sharedInstance] message:[NSString stringWithFormat:NSLocalizedString(@"Image Size: ",nil),NSLocalizedString(@"Large",nil)]];
                break;
            case CaptureOutputSizePreset4K:
                [[STElieStatusBar sharedInstance] message:[NSString stringWithFormat:NSLocalizedString(@"Image Size: ",nil),@"4K"]];
                break;
            default:
                break;
        }
    }
    return preset;
}

- (void)didCreateContent; {
    [super didCreateContent];

    [self setMode:_mode reload:YES];
}

#pragma mark  Export
STExportSelectView * exportSelectView;

- (void)loadExportItems{
    NSArray * targetItems = [STPhotoSelector sharedInstance].currentFocusedPhotoItems;
    if(!targetItems.count){
        [self clearExportItemsIfNeeded];
        return;
    }

    if(targetItems.count > MAX_ALLOWED_EXPORT_COUNT){
        return;
    }

    Weaks
    NSArray *exportTypes = [[STExportManager sharedManager] acquire:[STPhotoSelector sharedInstance].currentFocusedPhotoItems];

    if(!exportSelectView){
        exportSelectView = [[STExportSelectView alloc] initWithSize:[STPhotoSelector sharedInstance].previewView.size];
    }

    [[STPhotoSelector sharedInstance].previewView addSubview:exportSelectView];
    exportSelectView.exporterTypes = exportTypes;

    [self whenNewValueOnceOf:@keypath(self.mode) changed:^(id value, id _weakSelf) {
        [exportSelectView removeFromSuperview];
    }];
}

- (void)tryExportByType:(STExportType)exportType{
    Weaks

#pragma mark Product - Save
    if(exportType==STExportTypeSaveToLibrary){
        if(![STGIFFApp tryProductSavePostFocus:^(BOOL purchased) {
            if(purchased){
                [self tryExportByType:exportType];
            }
        } interactionButton:nil]){
            return;
        }
    }


    [exportSelectView removeFromSuperview];

    //display icon
    [self displayExporterIcon:exportType attach:YES];

    /*
     * isMustBackToHomeAfterFinished NO : export -> back -> processing
     *
     * isMustBackToHomeAfterFinished YES : export -> waiting user determine -> processing -> back
     */
    BOOL backToHomeAfterFinished = [self isMustBackToHomeAfterFinished:exportType];
    if(!backToHomeAfterFinished){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self back];
        });

        //force show status bar
        [[STElieStatusBar sharedInstance] show];
        [[STElieStatusBar sharedInstance] lockShowHide];

        //lock user interactions
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    }

    /*
     * start and monitoring
     */
    BOOL statusBarShowen = [STElieStatusBar sharedInstance].showen;
    [[STExportManager sharedManager] export:exportType will:^(STExporter *exporter) {

        exporter.viewOption.relatedButton = ((STHome *)self.homeView).selectableButton;
        exporter.hashtags = @[[STGIFFApp primaryHashtag]];

    } processing:^(BOOL processing) {

        if(processing){
            if(![STExportManager sharedManager].currentExporter.shouldNeedViewWhenExport){
                [[STElieStatusBar sharedInstance] show];
                [[STElieStatusBar sharedInstance] startProgress:nil];
            }

            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        }else{
            if(![STExportManager sharedManager].currentExporter.shouldNeedViewWhenExport){
                [[STElieStatusBar sharedInstance] stopProgress];
                if(!statusBarShowen){
                    [[STElieStatusBar sharedInstance] hide];
                }
            }

            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }

    } finished:^(STExportResult result) {

        [self displayExporterIcon:exportType attach:NO];

        if(result == STExportResultSucceed){
            STGIFFAppSetting.get.exportedType = exportType;
        }

        if([Wself isExpressResultAfterFinished:exportType]){
            [Wself expressExportResult:result];
        }

        if(backToHomeAfterFinished){
            dispatch_async(dispatch_get_main_queue(), ^{
                [Wself back];
            });
        }

        //unlock force showed statusbar if needed.
        [[STElieStatusBar sharedInstance] unlockShowHideAndRevert];

        //unlock user interations
        if([[UIApplication sharedApplication] isIgnoringInteractionEvents]){
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }

        [STGIFFApp logEvent:@"ExportFinishResult" key:[@(result) stringValue]];
    }];

    [STGIFFApp logEvent:@"ExportTryType" key:[@(exportType) stringValue]];
}

- (void)displayExporterIcon:(STExportType)exportType attach:(BOOL)attach{
    NSString * TagNameForExporterIcon = @"TagNameForExporterIcon";
    if(attach){
        SVGKFastImageView * iconView = [SVGKFastImageView viewWithImageNamed:[STExporter iconImageName:exportType] sizeWidth:[STStandardLayout widthMainSmall]];
        iconView.tagName = TagNameForExporterIcon;
        [self addSubview:iconView];
        [iconView centerToParent];

        self.backgroundColor = [UIColor clearColor];
        [UIView animateWithDuration:.3 animations:^{
            self.backgroundColor = [[STExporter iconImageBackgroundColor:exportType] colorWithAlphaComponent:.6];
        }];
    }else{

        [[self viewWithTagName:TagNameForExporterIcon] removeFromSuperview];
        self.backgroundColor =nil;
    }
}

- (STExportType)targetExportType{
    NSArray * types = [STExportManager sharedManager].acquiredTypes;
    NSAssert(types.count>0,@"can't load acquired types");

    STExportType type = (STExportType) [STGIFFAppSetting get].exportedType;
    if(![[STExportManager sharedManager] ready:type]){
        type = (STExportType) [types.firstObject integerValue];
    }
    return type;
}

- (void)clearExportItemsIfNeeded {
    if(![STExportManager sharedManager].currentExporter){
        [[STExportManager sharedManager] finish];
    }
}

- (BOOL)isMustBackToHomeAfterFinished:(STExportType)exportType{
    switch (exportType){
//        case STExportTypeSavedPhotos:
//            return NO;
        default:
            return YES;
    }
}

- (BOOL)isExpressResultAfterFinished:(STExportType)exportType{
    switch (exportType){
        default:
            return YES;
    }
}

- (void)expressExportResult:(STExportResult)result{
    switch(result){
        case STExportResultSucceed:
            [[STElieStatusBar sharedInstance] success];
            break;
        case STExportResultCanceled:
        case STExportResultFailedAndTriedFallback:
            break;

        case STExportResultFailed:
            [[STElieStatusBar sharedInstance] fail];
            break;
        case STExportResultImpossible:
            [[STElieStatusBar sharedInstance] fatal];
            break;
    }
}

- (CGRect)centeredHomeFrame {
    return ST_CENTER_R_SWH(STStandardLayout.widthMainSmall, ST_FW(self), ST_FH(self));
}

- (void)didSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index1; {

}

- (void)whenChangedDisplayMode:(void (^)(STControlDisplayMode mode, STControlDisplayMode previousMode))block{
    _whenChangedDisplayMode = block;
}


- (void)requestQuickPostFocusCaptureIfPossible:(STPostFocusMode)mode{
    Weaks
    if([STGIFFApp afterCameraInitialized:@"STMainControl.quickaction.requestQuickPostFocusCaptureIfPossible" perform:^{
        Strongs
        [Sself requestQuickPostFocusCaptureIfPossible:mode];
    }]){
        return;
    }

    if(self.mode != STControlDisplayModeLivePreview){
        [[NSNotificationCenter defaultCenter] st_addObserverWithMainQueueOnlyOnce:self forName:STNotificationFilterPresenterItemRenderFinish usingBlock:^(NSNotification *note, id observer) {
            Strongs
            [Sself requestQuickPostFocusCaptureIfPossible:mode];
        }];

        [[STUserActor sharedInstance] act:STUserActionChangeCameraMode object:@(STCameraModeManual)];
        return;
    }


    self.subControl.rightButton.currentMappedValue = @(mode);
    [self.subControl.rightButton dispatchSelected];

    [[STUserActor sharedInstance] act:STUserActionManualAnimatableCapture object:nil];
}

#pragma mark QuickCapture

static STStandardButton *_quickCaptureButtonCancel;
static STStandardButton *_quickCaptureButtonFrontCamera;
static STStandardButton *_quickCaptureButtonRearCamera;
static UIImageView *_currentQuickCaptureModeView;
static UIView *_quickCaptureButtonContainer;

- (void)requestQuickCaptureIfPossible {
    Weaks
    if([STGIFFApp afterCameraInitialized:@"STMainControl.quickaction.quickcapture" perform:^{
        Strongs
        [Sself->_home cancelRestoreStateEffect];
        [Sself requestQuickCaptureIfPossible];
    }]){
        return;
    }

    [STUIApplication st_performOnceAfterDelay:@"quick_capture_at_launch_phase0" interval:.5 block:^{
        [[STMainControl sharedInstance] readyToStartQuickCapture];

        [STUIApplication st_performOnceAfterDelay:@"quick_capture_at_launch_phase1" interval:.5 block:^{
            [[STMainControl sharedInstance] readyToRearQuickCapture];

            [STUIApplication st_performOnceAfterDelay:@"quick_capture_at_launch_phase2" interval:.5 block:^{
                [[STMainControl sharedInstance] quickCaptureAndClose];
            }];
        }];
    }];
}

- (void)initQuickcapture {
    Weaks
    UILongPressGestureRecognizer * longPressGestureRecognizer = [_home whenLongTapAsTapDownUp:^(UILongPressGestureRecognizer *sender, CGPoint location) {
        [Wself readyToStartQuickCapture];

    } changed:^(UILongPressGestureRecognizer *sender, CGPoint location) {

        Strongs
        CGPoint loc = [sender locationInView:Sself];
        if (Sself.width/3 < loc.x && loc.x < Sself.width*2/3) {
            [Sself readyToRearQuickCapture];

        } else if (location.x > sender.view.boundsWidthHalf) {
            [Sself readyToFrontQuickCapture];

        } else if (location.x < sender.view.boundsWidthHalf) {
            [Sself readyToCancelQuickCapture];
        }

    } ended:^(UILongPressGestureRecognizer *sender, CGPoint location) {
        Strongs
        CGPoint loc = [sender locationInView:Sself];
        if (Sself.width/3 < loc.x && loc.x < Sself.width*2/3) {
            [Sself quickCaptureAndClose];

        } else if (location.x > sender.view.boundsWidthHalf) {
            [Sself quickCaptureAndClose];

        } else if (location.x < sender.view.boundsWidthHalf) {
            [Sself closeQuickCapture];
            [Sself waitAndReturnFromQuickCaptureToElie];
        }
    }];

    [STStandardUX resolveLongTapDelay:longPressGestureRecognizer];
    longPressGestureRecognizer.minimumPressDuration = .25;
}

- (void)quickCaptureAndClose {
    [self closeQuickCapture];

    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    Weaks
    [self st_performOnceAfterDelay:@"quickcapture_delay" interval:.1 block:^{
        STCaptureRequest * request = [STCaptureRequest request];
        request.responseHandler = ^(STCaptureResponse *result) {
            Strongs
            [Sself waitAndReturnFromQuickCaptureToElie];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            [[STElieStatusBar sharedInstance] stopProgress];

            if(!result){
                [[STElieStatusBar sharedInstance] fail];
            }
        };

        request.needsFilterItem = Wself.homeSelectedFilterItem;
        request.origin = STPhotoItemOriginQuickCamera;
        [[STUserActor sharedInstance] act:STUserActionManualCapture object:request];

        [[STElieStatusBar sharedInstance] startProgress:nil];
        [[STElieStatusBar sharedInstance] show];
    }];
}

//ready
- (void)readyToStartQuickCapture {
    if(_home.previewQuickCaptureMode){
        return;
    }

    self.st_shadow.visible = NO;

    _home.previewQuickCaptureMode = YES;

    [[STUserActor sharedInstance] act:STUserActionChangeCameraMode object:@(STCameraModeManualQuick)];

    //bottom control button
    _home.spinnerVisiblity = 0;
//    _home.backgroundCircleColor = [UIColor clearColor];
    [_subControl setVisibleWithEffect:NO effect:STSubControlVisibleEffectNone];

    if (![[STPhotoSelector sharedInstance] st_isCoverShowen]) {

        [[STPhotoSelector sharedInstance] st_coverBlur:NO styleDark:NO completion:nil];

        UIVisualEffectView *bgBlurView = (UIVisualEffectView *) [[STPhotoSelector sharedInstance] st_coveredView];

        UIVisualEffectView *vibView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:(UIBlurEffect *) bgBlurView.effect]];
        vibView.frame = bgBlurView.bounds;
        [bgBlurView.contentView addSubview:vibView];

        CGPoint centerPosition = CGRectGetMid_AGK([self convertRect:_home.frame toView:bgBlurView]);

        //left : cancel
        STStandardButton *left = [STStandardButton subSize];
        left.preferredIconImagePadding = left.width*.23f;

        [left setButtons:@[[R go_x]] colors:@[[UIColor whiteColor]] style:STStandardButtonStylePTTP];
        left.userInteractionEnabled = NO;
        left.center = centerPosition;
        left.centerX = bgBlurView.width / 5;
        [vibView.contentView addSubview:left];
        _quickCaptureButtonCancel = left;

        //center
        STStandardButton *center = [[STStandardButton subSize] setButtons:@[[R camera_rear]] colors:@[[UIColor whiteColor]] style:STStandardButtonStylePTTP];
        center.userInteractionEnabled = NO;
        center.center = centerPosition;
        [vibView.contentView addSubview:center];
        _quickCaptureButtonRearCamera = center;

        //right
        STStandardButton *right = [[STStandardButton subSize] setButtons:@[[R camera_front]] colors:@[[UIColor whiteColor]] style:STStandardButtonStylePTTP];
        right.userInteractionEnabled = NO;
        right.center = centerPosition;
        right.centerX = bgBlurView.width * 4 / 5;
        [vibView.contentView addSubview:right];
        _quickCaptureButtonFrontCamera = right;

        //current mode view
        if(!_currentQuickCaptureModeView){
            _currentQuickCaptureModeView = [[UIImageView alloc] initWithSize:[STStandardLayout sizeSub]];
        }
        _currentQuickCaptureModeView.center = centerPosition;
        _currentQuickCaptureModeView.centerY = [self boundsHeightHalf];

        [vibView.contentView addSubview:_currentQuickCaptureModeView];

        //dot dot dot
        SVGKFastImageView *lddd = [SVGKFastImageView viewWithImageNamed:[R dotdotdot] sizeWidth:[STStandardLayout widthSub]];
        lddd.center = centerPosition;
        lddd.centerX -= CGPointDistance(right.center, centerPosition)/2;
        [vibView.contentView addSubview:lddd];

        SVGKFastImageView *rddd = [SVGKFastImageView viewWithImageNamed:[R dotdotdot] sizeWidth:[STStandardLayout widthSub]];
        rddd.center = centerPosition;
        rddd.centerX += CGPointDistance(right.center, centerPosition)/2;
        [vibView.contentView addSubview:rddd];

        _quickCaptureButtonContainer = vibView.contentView;

        [self readyToRearQuickCapture];

        //enable auto rrotation
        _currentQuickCaptureModeView.autoOrientationEnabled = YES;
        _quickCaptureButtonCancel.autoOrientationEnabled = YES;
        _quickCaptureButtonFrontCamera.autoOrientationEnabled = YES;
        _quickCaptureButtonRearCamera.autoOrientationEnabled = YES;
    }
}

- (void)setQuickCaptureModeTitleIcon:(STStandardButton *)button{
    _currentQuickCaptureModeView.image = [SVGKImage UIImageNamed:button.iconSourceImageNames[0] withSizeWidth:[STStandardLayout widthSub]];
}

//cancel
- (void)readyToCancelQuickCapture {
    _quickCaptureButtonCancel.selectedState = YES;
    _quickCaptureButtonFrontCamera.selectedState = NO;
    _quickCaptureButtonRearCamera.selectedState = NO;

    [self setQuickCaptureModeTitleIcon:_quickCaptureButtonCancel];

    _home.previewSuspending = YES;

    [[STElieCamera sharedInstance] changeFacingCamera:NO completion:nil];
}

//front
- (void)readyToFrontQuickCapture {
    _quickCaptureButtonCancel.selectedState = NO;
    _quickCaptureButtonFrontCamera.selectedState = YES;
    _quickCaptureButtonRearCamera.selectedState = NO;

    [self setQuickCaptureModeTitleIcon:_quickCaptureButtonFrontCamera];

    if([STGIFFApp isInSimulator]){
        _home.previewSuspending = NO;
    }else{
        _home.previewSuspending = [[STElieCamera sharedInstance] changeFacingCamera:YES completion:^(BOOL changed){
            _home.previewSuspending = NO;
        }];
    }
}

//rear
- (void)readyToRearQuickCapture {
    _quickCaptureButtonCancel.selectedState = NO;
    _quickCaptureButtonFrontCamera.selectedState = NO;
    _quickCaptureButtonRearCamera.selectedState = YES;

    if([STGIFFApp isInSimulator]){
        _home.previewSuspending = NO;
    }else{
        _home.previewSuspending = [[STElieCamera sharedInstance] changeFacingCamera:NO completion:^(BOOL changed){
            _home.previewSuspending = NO;
        }];
    }

    [self setQuickCaptureModeTitleIcon:_quickCaptureButtonRearCamera];
}

//close quick capture
- (void)closeQuickCapture:(void(^)(void))completion{
    if(!_home.previewQuickCaptureMode){
        return;
    }

    self.st_shadow.visible = YES;

    //clear autorotation
    //https://fabric.io/jessi/ios/apps/com.stells.eliew/issues/56d63d9af5d3a7f76b3bbc0f
    _currentQuickCaptureModeView.autoOrientationAnimationEnabled = NO;
    _quickCaptureButtonCancel.autoOrientationAnimationEnabled = NO;
    _quickCaptureButtonFrontCamera.autoOrientationAnimationEnabled = NO;
    _quickCaptureButtonRearCamera.autoOrientationAnimationEnabled = NO;

    _currentQuickCaptureModeView.autoOrientationEnabled = NO;
    _quickCaptureButtonCancel.autoOrientationEnabled = NO;
    _quickCaptureButtonFrontCamera.autoOrientationEnabled = NO;
    _quickCaptureButtonRearCamera.autoOrientationEnabled = NO;

    //remove
    [_quickCaptureButtonContainer st_removeAllSubviews];
    _quickCaptureButtonContainer = nil;
    _quickCaptureButtonCancel = nil;
    _quickCaptureButtonFrontCamera = nil;
    _quickCaptureButtonRearCamera = nil;
    [_currentQuickCaptureModeView clearAllOwnedImagesIfNeeded:NO];

    //reset home
    _home.previewQuickCaptureMode = NO;
    _home.spinnerVisiblity = 1;
    [_subControl setVisibleWithEffect:YES effect:STSubControlVisibleEffectNone];

    Weaks
    _home.userInteractionEnabled = NO;
    [[STPhotoSelector sharedInstance] st_coverRemove:YES promiseIfAnimationFinished:YES finished:^{
        _home.userInteractionEnabled = YES;

        !completion?:completion();
    }];
}
- (void)closeQuickCapture{
    [self closeQuickCapture:nil];
}

- (void)waitAndReturnFromQuickCaptureToElie{
    [[STElieStatusBar sharedInstance] lockShowHide];

    [STStandardUX resetAndRevertStateAfterShortDelay:@"waitAndReturnFromQuickCaptureToElie" block:^{
        [[STUserActor sharedInstance] act:STUserActionChangeCameraMode object:@(STCameraModeElie)];

        [[STElieStatusBar sharedInstance] unlockShowHideAndRevert];
    }];
}



#pragma mark SetMode, Navigate
- (void)backToHome {
    [[_historyModes reverse] bk_each:^(id obj) {
        STControlDisplayMode mode = (STControlDisplayMode) [obj integerValue];
        switch (mode){
            case STControlDisplayModeHome:break;
            case STControlDisplayModeMain_initial:break;
            case STControlDisplayModeHomeFilterSelectable:
                [[_home selectableButton] dispatchSelected];
                break;
            case STControlDisplayModeLivePreview:
                [[STUserActor sharedInstance] act:STUserActionChangeCameraMode object:@(STCameraModeElie)];
                break;
            case STControlDisplayModeEdit:
            case STControlDisplayModeEditAfterCapture:
            case STControlDisplayModeReviewAfterAnimatableCapture:
            case STControlDisplayModeEditTool:
            case STControlDisplayModeExport:
            case STControlDisplayModeMain:
                [[self subControl].leftButton dispatchSelected];
                break;
        }
    }];
}

- (void)setMode:(STControlDisplayMode)mode {
    [self setMode:mode reload:NO];
}

- (void)back{
    [_historyModes pop];
    if(_historyModes.count){
        [self setMode:(STControlDisplayMode) [[_historyModes last] integerValue] reload:YES];
    }else{
        [self home];
    }
}

- (void)setMode:(STControlDisplayMode)mode reload:(BOOL)reload; {
    _previousMode = _mode;
    BOOL changed = _previousMode != mode || reload;

    if(changed) [self willChangeValueForKey:@keypath(self.mode)];
    _mode = mode;
    if(changed) [self didChangeValueForKey:@keypath(self.mode)];

    if(mode == STControlDisplayModeHome){
        [_historyModes removeAllObjects];
    }else{
        if(!reload){
            [_historyModes addObject:@(mode)];
        }
    }

    if(self.contentDidCreated && changed){
        [self willModeChanged];
        [self setNeedsLayoutByMode];
        [self setActionsByMode];
        [_subControl layoutSubviewsByMode:_mode previousMode:_previousMode];
        if(_whenChangedDisplayMode){
            _whenChangedDisplayMode(_mode, _previousMode);
        }
        [self didAfterModeChanged];
    }
}

#pragma mark willMode changed
- (void)willModeChanged {
    [_home setDisplayToDefault];

    switch (_previousMode){
        case STControlDisplayModeExport:
            [self clearExportItemsIfNeeded];
            break;

        default:
            break;
    }

    switch (_mode){
        case STControlDisplayModeExport:
            [self loadExportItems];
            break;

        case STControlDisplayModeHome:
            [[STPhotoSelector sharedInstance] deselectAllCurrentSelected];
            break;

        default:
            break;
    }
}

- (void)didAfterModeChanged {
    switch (_mode){
        case STControlDisplayModeHome:
            [self startParallaxEffect];
            break;

        case STControlDisplayModeEdit:
        case STControlDisplayModeEditAfterCapture:
        case STControlDisplayModeReviewAfterAnimatableCapture:
        case STControlDisplayModeLivePreview:
            _needsShowCollectables = YES;
            [self setNeedsDisplayCurrentHomeScrolledFilters];
            break;

        default:
            [self stopParallaxEffect];
            break;
    }

    [self setNeededToShowOrHideHomeCollectable];
}

#pragma mark layouts/views
- (void)setNeedsLayoutByMode{
    STControlDisplayMode mode = _mode;
    if(mode== STControlDisplayModeHome){
        [self _setHome];
    }
    else if(mode== STControlDisplayModeHomeFilterSelectable){
        [self _setHomeFilterSelectable];
    }
    else if(mode== STControlDisplayModeExport){
        [self _setExport];
    }
    else if(mode== STControlDisplayModeEdit){
        [self _setEdit];
    }
    else if(mode== STControlDisplayModeEditAfterCapture){
        [self _setEditAfterCaptured];
    }
    else if(mode== STControlDisplayModeReviewAfterAnimatableCapture){
        [self _setReviewAfterAnimatableCaptured];
    }
    else if(mode== STControlDisplayModeEditTool){
        [self _setEditTool];
    }
    else if(mode== STControlDisplayModeMain){
        [self _setMain];
    }
    else if(mode== STControlDisplayModeLivePreview){
        [self _setLivePreview];
    }
}

#pragma mark Meta setlayout
- (void)__setToHomeStyle:(NSString *)iconImageName color:(UIColor*)color {
    //color
    UIColor * assigningColor = color?:[STStandardUI pointColor];
    if(![_home.backgroundCircleColor isEqual:assigningColor]){
        _home.backgroundCircleColor = assigningColor;
    }

    //home icon image
    if(!iconImageName){
        switch(_mode){
            case STControlDisplayModeHome:
                iconImageName = [R ico_camera];
                break;
            case STControlDisplayModeEditTool:
                iconImageName = [R set_done];
                break;
            case STControlDisplayModeLivePreview:
                iconImageName = [R go_take];
                break;
            default:
                iconImageName = [R set_done];
                break;
        }
    }

    if(![_home.backgroundCircleIconImageName isEqualToString:iconImageName]){
        _home.backgroundCircleIconImageName = iconImageName;

        switch(_mode){
            case STControlDisplayModeHome:{
                static UIColor * HomeButtonIconBackgroundColor;
                if(!HomeButtonIconBackgroundColor){
                    //TODO: colorWithGradientStyle 메모리 체크
                    HomeButtonIconBackgroundColor = [UIColor colorWithGradientStyle:UIGradientStyleTopToBottom
                                                                          withFrame:_home.containerButton.bounds
                                                                          andColors:@[UIColorFromRGB(0xa19699), UIColorFromRGB(0x8a8d92)]];
                }

                _home.indexProgressColor = [STStandardUI pointColorDarken];
                _home.containerButton.preferredIconImagePadding = _home.containerButton.width/3.8f;
                [_home.containerButton setButtons:@[iconImageName]
                                           colors:@[HomeButtonIconBackgroundColor]
                                         bgColors:nil
                                            style:STStandardButtonStylePTTP
                     blockForCreateBackgroundView:nil];
            }
                break;
            default:
                _home.indexProgressColor = [STStandardUI pointColor];
                _home.containerButton.preferredIconImagePadding = 0;
                [_home.containerButton setButtons:@[iconImageName]
                                           colors:@[[STStandardUI buttonColorFront]]
                                         bgColors:@[[STStandardUI buttonColorBack]]
                                            style:STStandardButtonStylePTTP
                     blockForCreateBackgroundView:nil];
                break;
        }
    }

    //background
    switch(_mode){
        case STControlDisplayModeHome:{
            static UIColor * HomeButtonPointColor;
            if(!HomeButtonPointColor){
                HomeButtonPointColor = [UIColor colorWithGradientStyle:UIGradientStyleRadial
                                                             withFrame:_home.containerButton.bounds
                                                             andColors:@[UIColorFromRGB(0xe5fefe),UIColorFromRGB(0xebecff)]];
            }

            if(![_home.containerButton.backgroundViewAsColoredImage isEqual:HomeButtonPointColor]){
                _home.containerButton.backgroundViewAsColoredImage = HomeButtonPointColor;
            }
            _home.containerButton.backgroundView.alpha = [STStandardUI alphaForDimmingSelection];
        }
            break;
        default:
            _home.containerButton.backgroundViewAsColoredImage = [STStandardUI buttonColorBackgroundOverlay];
            _home.containerButton.backgroundView.alpha = [STStandardUI alphaForGlassLikeOverlayButtonBackground];
            break;
    }

    //shadow
    if(!_home.containerButton.shadowEnabled){
        _home.containerButton.shadowEnabled = YES;
    }
    switch(_mode){
        case STControlDisplayModeHome:
            _home.containerButton.shadowAlpha = .2;
            break;
        default:
            _home.containerButton.shadowAlpha = 0;
            break;
    }

    _home.containerButton.selectedState = NO;
}

- (void)__setToDefaultWithAnimation:(BOOL)animation{
    // Home
    _home.hidden = NO;
    // Home Icon
    [self __setToHomeStyle:nil color:nil];

    [_home pop_removeAllAnimations];
    [NSObject animate:^{
        if(_home.scaleXY.x != 1){
            if(animation){
                _home.spring.scaleXY = CGPointMake(1, 1);
            }else{
                _home.scaleXY = CGPointMake(1, 1);
            }
        }
        if(!CGRectEqualToRect(_home.frame, [self centeredHomeFrame])){
            if(animation){
                _home.spring.frame = [self centeredHomeFrame];
            }else{
                _home.frame = [self centeredHomeFrame];
            }
        }
    } completion:nil];


    //subcontrol
    _subControl.hidden = NO;
    _subControl.center = CGRectGetMid_AGK([self centeredHomeFrame]);

    [_homeFilterCollector closeIfStarted];
}

#pragma mark setlayout by mode
- (void)_setHome {
    [self __setToDefaultWithAnimation:YES];
}

- (void)_setHomeActive {
    [self __setToDefaultWithAnimation:NO];
}

#pragma mark QuickFilter
- (void)__setHomeFilterSelectable_home_position:(BOOL)apply animation:(BOOL)animation{
    CGFloat collectionBoundsHeight = self.height;

    [_home pop_removeAllAnimations];

    id target = animation ? _home.spring : _home;
    if(apply){
        [target setScaleXYValue:.7];
        [target setBottom:collectionBoundsHeight - (collectionBoundsHeight/11)];
    }else{
        [target setScaleXYValue:1];
        [target setFrame:[self centeredHomeFrame]];
    }

}
- (void)_setHomeFilterSelectable{
    Weaks

    //home
    NSString * lineLayerName = @"line";

    CGFloat const collectionWidth = [STApp screenFamily]==STScreenFamily55 ? 82 : 78;
    CGFloat collectionBoundsHeight = self.height;

    //FIXME: memory leak.
    UIImage * homeImage = [[[_home snapshotCurrent] grayscale] brightenWithValue:60];//gaussianBlurWithBias:255];

    NSUInteger selectedFilterIndex = self.homeSelectedFilterItemIndex;

    STStandardReachableButton * reachableButton = [STStandardReachableButton mainSize];
    reachableButton.bindReachedProgressToCurrentIndex = YES;
    reachableButton.bindReachedToSelectedState = NO;
    reachableButton.reachedProgressCirclePadding = 4;
    reachableButton.animateSelectedViewScaleIfVisibleOutlineProgress = YES;
    reachableButton.animateBackgroundViewWhenStateChange = YES;

    STStandardButton * button = [_home setDisplayOnlyButton:reachableButton];
    button.backgroundViewAutoClear = YES;
    if(selectedFilterIndex != 0){
        [button setButtons:@[[R go_x], [R set_reset]] colors:@[[STStandardUI buttonColorFront], [STStandardUI buttonColorFront]] style:STStandardButtonStylePTBP];
    }else{
        [button setButtons:@[[R go_x]] colors:@[[STStandardUI buttonColorFront]] style:STStandardButtonStylePTBP];
    }

    _home.visible = YES;
    [self __setHomeFilterSelectable_home_position:YES animation:YES];

    //subcontrol
    _subControl.hidden = YES;

    //collectable
    //TODO: _homeFilterCollector.carousel 소거되는지 확인
    _homeFilterCollector.carousel = [[iCarousel alloc] initWithFrame:CGRectMakeWithSize_AGK((CGSize){self.width, collectionBoundsHeight})];
    [self insertSubview:_homeFilterCollector.carousel aboveSubview:_subControl];

    _homeFilterCollector.carousel.contentOffset = CGSizeMake(0, -collectionWidth/2);
    _homeFilterCollector.carousel.type = iCarouselTypeWheel;
    _homeFilterCollector.itemWidth = collectionWidth;
    _homeFilterCollector.blockForiCarouselOption = ^CGFloat(iCarouselOption option, CGFloat value) {
        switch (option)
        {
            case iCarouselOptionVisibleItems:
            {
                return 5;
            }
            case iCarouselOptionWrap:
            {
                return YES;
            }
            case iCarouselOptionAngle:{
                return 0.514703;
            }
            case iCarouselOptionRadius:{
                return 165.7;
            }
            case iCarouselOptionSpacing:
            {
                return (CGFloat) (value * 1.1); //0-2
            }
            default:
            {
                return value;
            }
        }
    };

    WeakAssign(button)
    _homeFilterCollector.blockForFilterItemView = ^STFilterPresenterItemView *(NSInteger index, STFilterItem * filterItem, UIView *view) {
        Strongs
        STFilterPresenterItemView * itemView;

         if(view==nil){
            itemView = [[STFilterPresenterProductItemView alloc] initWithFrame:[STElieCamera.sharedInstance outputRect:CGRectMakeValue(collectionWidth)]];
            [itemView usingGPUImage];

            itemView.gpuView.contentMode = UIViewContentModeScaleAspectFill;
            itemView.centerY = itemView.height/2;
            itemView.image = homeImage;

            [itemView st_takeSnapshotWithBlurredOverlayView:YES dark:NO];
            itemView.gpuView.alpha = 0;

            CAShapeLayer *mask = [CAShapeLayer circle:collectionWidth];
            mask.contentsGravity = kCAGravityCenter;
            mask.lineWidth = 0;
            mask.positionY = (CGFloat) ((itemView.height-mask.pathHeight)*.5);
            itemView.layer.mask = mask;

            CAShapeLayer *line = [CAShapeLayer circle:collectionWidth];
            line.fillColor = nil;
            line.positionY = mask.positionY;
            line.strokeColor = [[STStandardUI strokeColorPoint] CGColor];
            line.lineWidth = 2;
            line.rasterizationEnabled = YES;
            line.name = lineLayerName;

            [itemView.layer addSublayer:line];

        }else{
             itemView = (STFilterPresenterItemView *) view;
         }

        itemView.targetFilterItem = filterItem;
        [itemView layoutSubviews];

        return itemView;
    };

    [_homeFilterCollector initFiltersIncludeDefault];
    [_homeFilterCollector startForLive:_homeFilterCollector.carousel];

    [STStandardUX setAnimationFeelToRelaxedSpring:_homeFilterCollector.carousel];
    _homeFilterCollector.carousel.visible = YES;
    _homeFilterCollector.carousel.scaleXY = CGPointMake(.6, .6);
    _homeFilterCollector.carousel.pop_duration = .2;
    _homeFilterCollector.carousel.spring.scaleXY = CGPointMake(1, 1);

    @weakify(self)
    __block BOOL rendered = NO;
    [_homeFilterCollector.presenter whenAllItemRenderFinished:^{
        if(!rendered){
            rendered = YES;

            [[_homeFilterCollector.carousel visibleItemViews] eachViewsWithIndex:^(UIView *view, NSUInteger index) {
                STFilterPresenterItemView * _view = (STFilterPresenterItemView *) view;

                _view.gpuView.easeInEaseOut.duration = .3;
                [NSObject animate:^{
                    _view.gpuView.easeInEaseOut.alpha = 1;
                } completion:^(BOOL finished) {
                    _view.image = nil;
                }];
            }];

            [self st_performOnceAfterDelay:.25 block:^{
                [_homeFilterCollector.carousel scrollToItemAtIndex:selectedFilterIndex animated:YES];
            }];
        }
    }];
}

- (void)_setEdit {
    [self __setToDefaultWithAnimation:YES];
}

- (void)_setEditAfterCaptured {
    [self __setToDefaultWithAnimation:YES];
}

- (void)_setReviewAfterAnimatableCaptured {
    [self __setToDefaultWithAnimation:YES];
}

- (void)_setEditTool {
    [self __setToDefaultWithAnimation:YES];
}

- (void)_setExport {
    [self __setToDefaultWithAnimation:YES];

    STStandardNavigationButton *target = [_home setDisplayWithCollectables:YES visibleHome:NO];

    if(_previousMode != STControlDisplayModeExport){
        [target.collectableView expand:YES];
        target.collectableView.layer.pop_duration = .6;
        target.collectableView.layer.spring.rotation = (CGFloat) (M_PI * 2);
    }else{
        [target.collectableView expand:NO];
    }
}

- (void)_setMain {
}

- (void)_setLivePreview {
    [self __setToDefaultWithAnimation:YES];
}

#pragma mark actions
- (void)clearAllActions{
    [_home whenTapped:nil];
    [_home whenSlided:nil];
    [_home whenSlidingChange:nil];
    [_home whenSwiped:nil];
    [_home whenLongTapped:nil];
    [_homeFilterCollector whenDidEndScroll:nil];
    [_homeFilterCollector whenDidSelected:nil];
    [_homeFilterCollector whenChangedScrolledIndex:nil];
}

- (void)setActionsByMode {
    [self clearAllActions];

    if(_mode== STControlDisplayModeHome){

        Weaks
//        [_home whenSlided:^(BOOL confirmed, STSlideDirection direction) {
//            if(confirmed){
//                if (direction == STSlideDirectionUp) {
//
//                } else if (direction == STSlideDirectionDown) {
//                    [[STUserActor sharedInstance] act:STUserActionChangeCameraMode object:@(STCameraModeManual)];
//                }
//
//                [STPhotoSelector sharedInstance].collectionView.y = 0;
//                [[STPhotoSelector sharedInstance] finishPullingGrid];
//
//            }else{
//                [STPhotoSelector sharedInstance].collectionView.spring.y = 0;
//                [[STPhotoSelector sharedInstance] cancelPullingGrid];
//
//                [[STElieStatusBar sharedInstance] show];
//            }
//        }];
//
//        [_home whenSlidingChange:^(CGFloat reachRatio, BOOL confirmed, STSlideDirection direction) {
//
//            CGFloat scrollY = [STStandardUX maxOffsetForPullToGridView]*2*reachRatio;
//            [[STPhotoSelector sharedInstance] performPullingGrid:scrollY];
//            [STPhotoSelector sharedInstance].collectionView.y = scrollY;
//
//            if(reachRatio>.8){
//                [[STElieStatusBar sharedInstance] hide];
//            }else{
//                [[STElieStatusBar sharedInstance] show];
//            }
//        }];

        [_home whenTapped:^{

//            UIImageView * coveredView = [_home.containerButton coverAndUncoverBegin:self.st_rootUVC.view presentingTarget:[STPhotoSelector sharedInstance]];
            [[STUserActor sharedInstance] act:STUserActionChangeCameraMode object:@(STCameraModeManual)];
//            [_home.containerButton coverAndUncoverEnd:self.st_rootUVC.view presentingTarget:[STPhotoSelector sharedInstance] beforeCoverView:coveredView comletion:nil];

//            if([STFilterManager sharedManager].filterGroups){
//                [Wself setMode:STControlDisplayModeHomeFilterSelectable];
//
//            }else{
//                [STStandardUX expressDenied:_home];
//            }
        }];

//        [self initQuickcapture];
    }

    else if(_mode== STControlDisplayModeHomeFilterSelectable){
        Weaks
        [[_home selectableButton] whenSelected:^(STSelectableView *selectedView, NSInteger index) {
            if(_homeFilterCollector.carousel.currentItemIndex==0){
                [Wself back];
            }else{
                [_homeFilterCollector.carousel scrollToItemAtIndex:0 animated:YES];
                [_homeFilterCollector carousel:_homeFilterCollector.carousel didSelectItemAtIndex:0];
            }
        }];

        [_homeFilterCollector whenDidEndScroll:nil];
        [_homeFilterCollector whenDidSelected:^(NSInteger selectedIndex) {
            Strongs
            WeakAssign(Sself)
            [Sself->_homeFilterCollector whenDidEndScroll:^(NSInteger ix) {
                [weak_Sself selectFilterItemFromSelectableItemAt:ix];
            }];
        }];

        [_homeFilterCollector whenChangedScrolledIndex:^(NSInteger i) {
            Strongs
            STStandardReachableButton * reachableButton = (STStandardReachableButton *) [Sself->_home selectableButton];
            reachableButton.reachedProgress = i==0 ? 0 : 1;
            reachableButton.outlineProgress = AGKRemapToZeroOne(i, 0, Sself->_homeFilterCollector.items.count-1);
            reachableButton.backgroundViewAsOwnBackgroundColorWithShapeMask = [Wself _homeFilterItemAt:i].representativeColor;
        }];
        _home.selectableButton.backgroundViewAsOwnBackgroundColorWithShapeMask = _homeFilterCollector.state.currentFocusedFilterItem.representativeColor;
    }

    else if(_mode== STControlDisplayModeEdit){
        Weaks
        [_home whenTapped:^{
            if([Wself selectFilterItemFromHomeButton:^(id resultValue, BOOL success) {
                Strongs
                if (success) {
                    [Sself setMode:STControlDisplayModeExport];
                } else {
                    [[STPhotoSelector sharedInstance] doResetPreview];
                }
            }]){

            };
        }];
    }

    else if(_mode== STControlDisplayModeEditAfterCapture){
        Weaks
        [_home whenTapped:^{
            if([Wself selectFilterItemFromHomeButton:^(id resultValue, BOOL success) {
                Strongs
                if (success) {
                    [Sself setMode:STControlDisplayModeExport];
                } else {
                    [[STPhotoSelector sharedInstance] doResetPreview];
                }
            }]){

            };
        }];
    }

    else if(_mode== STControlDisplayModeReviewAfterAnimatableCapture){
        Weaks
        [_home whenTapped:^{
            if([Wself selectFilterItemFromHomeButton:^(id resultValue, BOOL success) {
                Strongs
                if (success) {
                    [Sself setMode:STControlDisplayModeExport];
                } else {
                    [[STPhotoSelector sharedInstance] doResetPreview];
                }
            }]){

            };
        }];
    }

    else if(_mode== STControlDisplayModeEditTool){
        Weaks
        [_home whenTapped:^{
            [[STPhotoSelector sharedInstance] doApplyTool];
        }];
    }

    else if(_mode== STControlDisplayModeExport){
        Weaks

        [_home.selectableButton whenSelected:^(STSelectableView *selectedView, NSInteger index) {
//            [Wself tryExportByType:[self targetExportType]];
        }];

        [(STStandardNavigationButton *)_home.selectableButton whenCollectableSelected:^(STStandardButton *collectableButton, NSUInteger index) {
//            [Wself tryExportByType:(STExportType) [collectableButton.valuesMap.first integerValue]];
        }];
    }

    else if(_mode== STControlDisplayModeMain){

    }

    else if(_mode== STControlDisplayModeLivePreview){
        Weaks
        [_home whenTapped:^{
            if([STCaptureProcessor sharedProcessor].processing){
                [STStandardUX expressDenied:_home];

            }else{
                if([Wself selectFilterItemFromHomeButton:^(id resultValue, BOOL success) {
                    if (success) {

                    } else {
                        [[STPhotoSelector sharedInstance] doResetPreview];
                    }
                }]){

                    [_homeCollectable retract:YES];

                    [[STUserActor sharedInstance] act:STUserActionManualAnimatableCapture object:nil];
                };
            }
        }];

        [_home whenSlidedAsConfirmed:^(STSlideDirection direction) {
            if (direction == STSlideDirectionUp) {
//                [[STUserActor sharedInstance] act:STUserActionChangeCameraMode];
                [[STUserActor sharedInstance] act:STUserActionChangeCameraMode object:@(STCameraModeElie)];
            }
        }];
    }
}


#pragma mark Filter Purchasing
- (void)setFilterGroupPurchasedSuccessAt:(NSUInteger)groupIndex productId:(NSString *)productId{
    for(STFilterItem *filterItem in ((STFilterGroupItem *)[[[STFilterManager sharedManager] filterGroups] st_objectOrNilAtIndex:groupIndex]).filters){
        if([productId isEqualToString:filterItem.productId]){
            filterItem.type = STFilterTypeDefault;
        }
    }
    //reload purchased state if needed
    [[STPhotoSelector sharedInstance] doLayoutPreviewCollectionViews];
}

- (BOOL)selectFilter:(NSString *)productId
                item:(STFilterItem *)filterItem
         defaultItem:(STFilterItem *)defaultFilterItem
          completion:(void (^)(id resultValue, BOOL success))completionBlock{

    return [STGIFFApp selectByValue:productId
               selectedValue:filterItem
                defaultValue:defaultFilterItem
                     compare:^BOOL(STFilterItem * selectedValue, id defaultValue) {
                         return selectedValue.type==STFilterTypeITunesProduct;
                     } completion:completionBlock];
}

#pragma mark Filter Purchasing - Selectable
- (void)selectFilterItemFromSelectableItemAt:(NSInteger)selectedIndex{
    STFilterItem *  defaultFilterItem = self.homeSelectedFilterItem?: [self _homeFilterItemAt:0];
    STFilterItem * filterItem = [self _homeFilterItemAt:selectedIndex];
    NSString * productId = filterItem.type == STFilterTypeITunesProduct ? filterItem.productId: nil;
    STStandardButton * button = [_home selectableButton];

    if([STGIFFApp isPurchasedProduct:productId]){
        [self selectFilterItemFromSelectableItem:productId filterItem:filterItem defaultFilterItem:defaultFilterItem];
        [self back];

    }else{
        Weaks
        WeakAssign(button);
        [STProductCatalogView openWith:button
                             productId:productId
                            iconImages:[[STFilterManager sharedManager] getSampleFilteredImages:_homeFilterCollector.state.currentFocusedGroupIndex productId:productId]
                              willOpen:^(STProductCatalogView *view, STProductItem * item) {
                                  //position of home
                                  [Wself __setHomeFilterSelectable_home_position:NO animation:NO];
                              }
                               didOpen:nil
                                 tried:^{

                                     [Wself selectFilterItemFromSelectableItem:productId filterItem:filterItem defaultFilterItem:defaultFilterItem];

                                 } purchased:^(NSString *_success_productId) {


                } failed:^(NSString *_failed_productId) {

                } willClose:^(BOOL afterPurchased) {
                    //reset position of home
                    if(!afterPurchased){
                        [Wself __setHomeFilterSelectable_home_position:YES animation:NO];
                    }

                } didClose:^(BOOL afterPurchased) {
                    if (afterPurchased) {
                        [Wself selectFilterItemFromSelectableItem:productId filterItem:filterItem defaultFilterItem:defaultFilterItem];
                        [Wself back];

                    }else{
                        [weak_button dispatchSelected];
                    }
                }];
    }

    [STGIFFApp logClick:@"FilterSelectByHomeSelectable" key:filterItem.uid_short];
}

- (void)selectFilterItemFromSelectableItem:(NSString *)productId filterItem:(STFilterItem *)filterItem defaultFilterItem:(STFilterItem *)defaultFilterItem{
    Weaks
    [self selectFilter:productId item:filterItem defaultItem:defaultFilterItem completion:^(STFilterItem * resultValue, BOOL success) {
        Strongs
        Sself->_homeSelectedFilterItem = resultValue;

        if(resultValue.productId && success){
            //update type of filter items.
            Sself->_homeSelectedFilterItem.type = STFilterTypeDefault;

            [Sself setFilterGroupPurchasedSuccessAt:Sself->_homeFilterCollector.state.currentFocusedGroupIndex productId:resultValue.productId];
        }
    }];
}

#pragma mark Filter Purchasing - Previewing
- (BOOL)selectFilterItemFromHomeButton:(void (^)(id resultValue, BOOL success))completionBlock{
    Weaks
    STFilterItem * filterItem = [STPhotoSelector sharedInstance].previewState.currentFocusedFilterItem;
    STFilterItem * defaultFilterItem = [STPhotoSelector sharedInstance].previewState.defaultFilterItem;
    NSString * productId = filterItem.type == STFilterTypeITunesProduct ? filterItem.productId : nil;
    //selectableButton or containerButton
    STStandardButton * button = _home.selectableButton?:_home.containerButton;

    if([STGIFFApp isPurchasedProduct:productId]){
        return [self selectFilter:productId item:filterItem defaultItem:defaultFilterItem completion:completionBlock];

    }else{
        WeakAssign(button)
        [self st_performOnceAfterDelay:.2 block:^{
            [STProductCatalogView openWith:weak_button
                                 productId:productId
                                iconImages:[[STFilterManager sharedManager] getSampleFilteredImages:_homeFilterCollector.state.currentFocusedGroupIndex productId:productId]
                                  willOpen:nil
                                   didOpen:nil
                                     tried:^{
                                         [Wself selectFilter:productId item:filterItem defaultItem:defaultFilterItem completion:nil];

                                     } purchased:^(NSString *_success_productId) {

                        [Wself setFilterGroupPurchasedSuccessAt:[STPhotoSelector sharedInstance].previewState.currentFocusedGroupIndex productId:_success_productId];
                        [Wself setNeedsDisplayCurrentHomeScrolledFilters];

                    } failed:^(NSString *_failed_productId) {

                    } willClose:^(BOOL afterPurchased) {

                    } didClose:^(BOOL afterPurchased) {

                        completionBlock(afterPurchased ? filterItem : defaultFilterItem, afterPurchased);
                    }];

        }];
    }

    [STGIFFApp logClick:[@"FilterSelectByHomeButtonAtMode" st_add:[@(_mode) stringValue]] key:filterItem.uid_short];

    return NO;
}
@end
