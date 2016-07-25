




#import <SVGKit/SVGKImage.h>
#import <SVGKit/SVGKImageView.h>
#import <BlocksKit/NSArray+BlocksKit.h>
#import "iCarousel.h"
#import "STMainControl.h"
#import "STHome.h"
#import "STCarouselHolderController.h"
#import "STPhotoSelector.h"
#import "STUserActor.h"
#import "STFilterItem.h"
#import "STExportManager.h"
#import "STCaptureRequest.h"
#import "STStandardButton.h"
#import "NSObject+STPopAnimatableProperty.h"
#import "STGIFFAppSetting.h"
#import "STStandardCollectableButton.h"
#import "STStandardNavigationButton.h"
#import "NSArray+STUtil.h"
#import "NSObject+STUtil.h"
#import "STFilterPresenterBase.h"
#import "STExporter+Config.h"
#import "STElieStatusBar.h"
#import "SVGKFastImageView.h"
#import "SVGKFastImageView+STUtil.h"
#import "STEditControlView.h"
#import "R.h"


#import "NSObject+STThreadUtil.h"
#import "UIScrollView+AGK+Properties.h"
#import "STPermissionManager.h"
#import "STCapturedImageProcessor.h"
#import "STFilterManager.h"
#import "STFilterGroupItem.h"
#import "STProductCatalogView.h"
#import "M13OrderedDictionary.h"
#import "NSString+STUtil.h"
#import "STApp+Logger.h"
#import "STExporter+View.h"
#import "UIColor+BFPaperColors.h"
#import "ChameleonMacros.h"
#import "STExportSelectView.h"
#import "NSNotificationCenter+STFXNotificationsShortHand.h"
#import "STPostFocusCaptureRequest.h"
#import "STCameraControlView.h"
#import "STEditControlView.h"
#import "STExportControlView.h"

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

    //subcontrolview
    STSelectableView * _controlView;
    STCameraControlView * _cameraControlView;
    STExportControlView * _exportControlView;
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

- (void)enterEdit {
    [self setMode:STControlDisplayModeEdit];
}

- (void)exitEdit {
    [_home setBackgroundCircleColor:nil];
    [self back];
}


- (void)enterEditAfterCapture {
    [self setMode:STControlDisplayModeEditAfterCapture];
}

- (void)exitEditAfterCapture {
    [self back];
}


- (void)enterReviewAfterAnimatableCapture {
    [self setMode:STControlDisplayModeReviewAfterAnimatableCapture];
}

- (void)exitReviewAfterAnimatableCapture {
    [self back];
}


- (void)enterEditTool {
    [self setMode:STControlDisplayModeEditTool];
}

- (void)exitEditTool {
    [self back];
}


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


- (void)export {
    [self setMode:STControlDisplayModeExport reload:self.mode == STControlDisplayModeExport];
}


- (void)home {
    [self setMode:STControlDisplayModeHome];
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


    if([STPhotoSelector sharedInstance].loadingSource){
        interrupt = YES;
    }


    switch(_mode){
        case STControlDisplayModeHome:
            break;

        case STControlDisplayModeHomeSelectable:
            break;

        default:
            interrupt = YES;
            break;
    }


    if(!interrupt && [STPhotoSelector sharedInstance].collectionView.height * [STStandardUX maxMultipleNumberOfFrameHeightByContentHeightToHideControlsWhenScrolling] > [STPhotoSelector sharedInstance].collectionView.contentSizeHeight){
        interrupt = YES;
    }


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


#pragma mark Home Collectable
- (void)setNeededToShowOrHideHomeCollectable {
    switch (self.mode){
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

    _controlView = [[STSelectableView alloc] initWithSize:self.size];
    _controlView.touchInsidePolicy = STUIViewTouchInsidePolicyContentInside;
    _controlView.allowSelectAsSlide = _controlView.allowSelectAsTap = NO;

    _homeFilterCollector = [[STFilterCollector alloc] init];

    [self setMode:STControlDisplayModeHome];


    [self addSubview:_subControl];
    [self addSubview:_controlView];
    [self addSubview:_home];

    /*
     * subControlView
     */
    _cameraControlView = [[STCameraControlView alloc] initWithSize:self.size];
    _editControlView = [[STEditControlView alloc] initWithSize:self.size];
    _exportControlView = [[STExportControlView alloc] initWithSize:self.size];
    [_controlView setViews:@[
            _cameraControlView
            , _editControlView
            , _exportControlView
    ]];
    _controlView.valuesMap = @[
            @(STControlDisplayModeLivePreview),
            @(STControlDisplayModeEditAfterCapture),
            @(STControlDisplayModeExport)
    ];

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

    [[STGIFFAppSetting get] whenValueOf:@keypath([STGIFFAppSetting get].postFocusMode) id:@"postFocusMode_maincontrol" changed:^(id value, id _weakSelf) {
        [self setCaptureSizePreset:(CaptureOutputSizePreset) [[STGIFFAppSetting.get read:@keypath([STGIFFAppSetting get].captureOutputSizePreset)] integerValue] userTapped:NO];
    }];

    [resolutionCollectable whenSelectedWithMappedValue:^(STSelectableView *button, NSInteger index, id value) {
        [self setCaptureSizePreset:(CaptureOutputSizePreset) [value integerValue] userTapped:YES];
    }];

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


        [[STElieStatusBar sharedInstance] show];
        [[STElieStatusBar sharedInstance] lockShowHide];


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


        [[STElieStatusBar sharedInstance] unlockShowHideAndRevert];


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

#pragma mark SetMode, Navigate
- (void)backToHome {
    [[_historyModes reverse] bk_each:^(id obj) {
        STControlDisplayMode mode = (STControlDisplayMode) [obj integerValue];
        switch (mode){
            case STControlDisplayModeHome:break;
            case STControlDisplayModeMain_initial:break;
            case STControlDisplayModeHomeSelectable: break;
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
        _controlView.currentMappedValue = @(_mode);

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
    else if(mode== STControlDisplayModeHomeSelectable){
        NSAssert(NO, @"STControlDisplayModeHomeSelectable");
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

    UIColor * assigningColor = color?:[STStandardUI pointColor];
    if(![_home.backgroundCircleColor isEqual:assigningColor]){
        _home.backgroundCircleColor = assigningColor;
    }


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

    _home.hidden = NO;

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

        [_home whenTapped:^{
            [[STUserActor sharedInstance] act:STUserActionChangeCameraMode object:@(STCameraModeManual)];
        }];
    }

    else if(_mode== STControlDisplayModeHomeSelectable){

        NSAssert(NO,@"STControlDisplayModeHomeFilterSelectable");
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

        }];

        [(STStandardNavigationButton *)_home.selectableButton whenCollectableSelected:^(STStandardButton *collectableButton, NSUInteger index) {

        }];
    }

    else if(_mode== STControlDisplayModeMain){

    }

    else if(_mode== STControlDisplayModeLivePreview){
        Weaks
        [_home whenTapped:^{
            if([STCapturedImageProcessor sharedProcessor].processing){
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


- (void)selectFilterItemFromSelectableItem:(NSString *)productId filterItem:(STFilterItem *)filterItem defaultFilterItem:(STFilterItem *)defaultFilterItem{
    Weaks
    [self selectFilter:productId item:filterItem defaultItem:defaultFilterItem completion:^(STFilterItem * resultValue, BOOL success) {
        Strongs
        Sself->_homeSelectedFilterItem = resultValue;

        if(resultValue.productId && success){

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
