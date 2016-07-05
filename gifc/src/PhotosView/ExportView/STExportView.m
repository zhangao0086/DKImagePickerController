//
// Created by BLACKGENE on 2016. 2. 2..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <SafariServices/SafariServices.h>
#import "STMainControl.h"
#import "UIView+STUtil.h"
#import "STStandardButton.h"
#import "STStandardReachableButton.h"
#import "R.h"
#import "STExporter.h"
#import "M13OrderedDictionary.h"
#import "STExportView.h"
#import "STExportContentView.h"
#import "STUIApplication.h"
#import "STExportLoginContentView.h"
#import "STExportPhotosContentView.h"
#import "STStandardNavigationButton.h"
#import "NSArray+STUtil.h"
#import "NSArray+BlocksKit.h"
#import "STExporter+IO.h"

//TODO: Export 패키지, 컴퍼넌트류 외의 모든 외부 디펜던시 제거
@interface STExportView()
@property (nonatomic, readonly) STExporter *exporter;

@property (nonatomic, readonly) M13OrderedDictionary *introIconImages;
@property (nonatomic, readonly) STStandardNavigationButton *cancelButton;
@property (nonatomic, readonly) STStandardButton *restoreButton;
@end

@implementation STExportView

- (void)createContent {
    [super createContent];

    CGFloat subControlWidth = [STStandardLayout widthMainSmall];
    CGFloat minDistanceFromCenterX = ([STStandardLayout widthMain] + [STStandardLayout widthSubAssistance]*2 + subControlWidth)/2;
    minDistanceFromCenterX += (self.width/4-minDistanceFromCenterX/2)/2;

    CGFloat needsMainControlHeight = self.superview.height-(self.superview.width * STStandardLayout.defaultRectSizeRatio4by3);
    if(needsMainControlHeight < STStandardLayout.minimumHeightOfBottomControlArea){
        needsMainControlHeight = STStandardLayout.minimumHeightOfBottomControlArea;
    }

    _cancelButton = [[STStandardNavigationButton alloc] initWithSizeWidth:subControlWidth];
    _cancelButton.centerX = self.centerX - minDistanceFromCenterX;
    _cancelButton.centerY = self.superview.bottom - needsMainControlHeight/2;
    [_cancelButton saveInitialLayout];
    _cancelButton.allowSelectAsTap = YES;
    [_cancelButton setButtons:@[[R go_back]] colors:nil style:STStandardButtonStylePTTP];
    _cancelButton.backgroundViewAsColoredImage = [STStandardUI buttonColorBackgroundOverlay];
    _cancelButton.backgroundView.alpha = [STStandardUI alphaForGlassLikeOverlayButtonBackground];

    _okButton = [STStandardReachableButton mainSize];
    _okButton.centerX = self.centerX;
    _okButton.centerY = self.superview.bottom - needsMainControlHeight/2;
    [_okButton saveInitialLayout];
    _okButton.allowSelectAsTap = YES;
    [_okButton setButtons:@[[R set_done]] colors:nil style:STStandardButtonStylePTTP];
    _okButton.backgroundViewAsColoredImage = [STStandardUI buttonColorBackgroundOverlay];
    _okButton.backgroundView.alpha = [STStandardUI alphaForGlassLikeOverlayButtonBackground];
    //reachable
    _okButton.bindReachedProgressToCurrentIndex = NO;
    _okButton.bindReachedToSelectedState = NO;
    _okButton.animateSelectedViewScaleIfVisibleOutlineProgress = NO;
    _okButton.animateOutlineProgress = NO;

    [self addSubview:_cancelButton];
    [self addSubview:_okButton];
}

- (void)disposeContent{
    [_okButton clearViews];

    [self setCancelButtonOptions:nil selectedCollectable:nil];
    [_cancelButton clearViews];
}

- (void)setExporter:(STExporter *)productItem {
    _exporter = productItem;

    [_contentView setExporter:nil];
    [_contentView clearAllOwnedImagesIfNeededAndRemoveFromSuperview:YES];

    if(_exporter){
        if(_exporter.shouldNeedAuthorize){
            switch(_exporter.authorizationType){
                case STExporterAuthorizationTypeOAuth:
                    break;
                case STExporterAuthorizationTypeInputAccountPassword:
                    _contentView = [[STExportLoginContentView alloc] initWithFrame:self.bounds];
                    break;
                default:
                    break;
            }
        }else{
            _contentView = [[STExportPhotosContentView alloc] initWithFrame:self.bounds];
        }

        if(_contentView){
            [self insertSubview:_contentView belowSubview:_cancelButton];
            [_contentView setExporter:_exporter];
        }
    }
}

NSString * const TagNameOfOptionView = @"optionView";
- (void)setOptionView:(UIView *)view{

    if(view){
        [self addSubview:view];
//        view.size = _cancelButton.size;
        view.tagName = TagNameOfOptionView;
        [view layoutSubviews];
        [view setNeedsDisplay];
        view.centerY = _cancelButton.centerY;
        view.centerX = self.width-_cancelButton.centerX;
    }else{
        [[self viewWithTagName:TagNameOfOptionView] removeFromSuperview];
    }
}

- (void)setCancelButtonOptions:(NSArray *)imageNames selectedCollectable:(void (^)(STStandardButton *button, NSUInteger index))block{
    if(imageNames){
        _cancelButton.synchronizeCollectableSelection = NO;
//        _cancelButton.autoRetractWhenSelectCollectableItem = YES;
        _cancelButton.autoUXLayoutWhenExpanding = YES;
        [_cancelButton setCollectables:imageNames colors:nil bgColors:nil size:[STStandardLayout sizeSubAssistance] style:STStandardButtonStylePTBT backgroundStyle:STStandardButtonStyleSkipImageInvertNormalDimmed];
        [_cancelButton expand:NO];
    }else{
        [_cancelButton clearCollectableViews];
    }

    [_cancelButton whenCollectableSelected:block];
}

- (UIView *)optionView {
    return [self viewWithTagName:TagNameOfOptionView];
}

static STExportView *exporterView;
static STStandardButton *targetButton;
static void(^blockForDidOpen)(STExportView *);
static void(^blockForPurchased)(void);
static void(^blockForCanceled)(void);
static void(^blockForDidClosed)(BOOL);
static void(^blockForWillClose)(BOOL);

#pragma mark Open

+ (void)        open:(STStandardButton *)targetItemButton
              target:(STExporter *)exporter
          optionView:(UIView *)optionView
  cancelOptionsIcons:(NSArray *)cancelOptionIconNames
cancelOptionSelected:(void (^)(STStandardButton *collecableButton, NSUInteger index))cancelOptionSelectedBlock
            willOpen:(void (^)(STExportView *))willOpenBlock
             didOpen:(void (^)(STExportView *))didOpenBlock
               tried:(void (^)(void))tried
            canceled:(void (^)(void))failedBlock
           willClose:(void (^)(BOOL))willCloseBlock
            didClose:(void(^)(BOOL))didClosedBlock {

    NSAssert([STUIApplication sharedApplication].keyWindow.rootViewController, @"rootViewController does not exist yet.");

    blockForDidOpen = didOpenBlock;
    targetButton = targetItemButton;
    blockForCanceled = failedBlock;
    blockForWillClose = willCloseBlock;
    blockForDidClosed = didClosedBlock;

    //create or bind view controller
    UIViewController * viewController = [STUIApplication sharedApplication].keyWindow.rootViewController;
    if(!viewController){
        viewController = [[UIViewController alloc] init];
        [[STUIApplication sharedApplication].keyWindow setRootViewController:viewController];
    }

    //load info view
    if(!exporterView){
        exporterView = [[STExportView alloc] initWithFrame:viewController.view.bounds];
    }
    [viewController.view addSubview:exporterView];
    exporterView.visible = NO;

    //init exporter view
    [exporterView setExporter:exporter];

    Weaks
    //built-in auth가 활성화 된 경우에만 해당
    if([exporterView.contentView isKindOfClass:STExportLoginContentView.class]){
        //needs login
        NSAssert(exporter.shouldNeedAuthorize, @"exporter.shouldNeedAuthorize must be YES before authorize.");
        STExportLoginContentView * loginContentView = (STExportLoginContentView *)exporterView.contentView;
        WeakAssign(loginContentView)

        loginContentView.didReturnInputBlock = ^(NSString *account, NSString *password) {
            [Wself startSpinProgressOfOkButton];

            [exporter authorize:@{STExporterAuthorizationInputDataAccountKey: account, STExporterAuthorizationInputDataPasswordKey :password} result:^(BOOL succeed, id data) {
                [Wself stopSpinProgressOfOkButton];

                if(succeed){
                    //FIXME: 이미 생성된 contentView에 여기서 뭔가 갱신을 해줘야함.
                    //[exporterView setExporter:exporter];

                    //ok
                    [[exporterView okButton] whenSelected:^(STSelectableView *selectedView, NSInteger index) {
                        [Wself startSpinProgressOfOkButton];
                        tried();
                    }];

                }else{
                    [STStandardUX expressDenied:weak_loginContentView];
                }
            }];
        };

        //ok
        [[exporterView okButton] whenSelected:^(STSelectableView *selectedView, NSInteger index) {
            [weak_loginContentView returnInputResults];
        }];

    }else{
        //needs not login
        //ok
        [[exporterView okButton] whenSelected:^(STSelectableView *selectedView, NSInteger index) {
            [Wself startSpinProgressOfOkButton];
            tried();
        }];
    }

    //will open
    !willOpenBlock?:willOpenBlock(exporterView);

    //animation
    if(targetItemButton){
        [targetItemButton coverWithBlur:viewController.view presentingTarget:exporterView comletion:^(STStandardButton *button, BOOL covered) {
            [self _didOpen];
        }];
    }else{
        [self _didOpen];
    }

    //add common user events
    [[exporterView cancelButton] whenSelected:^(STSelectableView *selectedView, NSInteger index) {
        [exporter cancelAllExportJobs];
        [Wself close:NO];
    }];
    [exporterView setCancelButtonOptions:cancelOptionIconNames selectedCollectable:cancelOptionSelectedBlock];

    //set option view
    [exporterView setOptionView:optionView];

//    [introView nextButton].bindReachedProgressToCurrentIndex = NO;
//    [introView nextButton].bindReachedToSelectedState = NO;
//    [introView nextButton].animateSelectedViewScaleIfVisibleOutlineProgress = NO;
//    [introView nextButton].animateOutlineProgress = YES;
}

+ (void)_didOpen{
    exporterView.visible = YES;
    [exporterView.contentView loadContentsLazily];
    !blockForDidOpen?:blockForDidOpen(exporterView);
}

#pragma mark Close
+ (void)close:(BOOL)success {
    [self close:success finshed:nil];
}

+ (void)close:(BOOL)success finshed:(void(^)(void))block{
    if(exporterView.contentView){
        [exporterView.contentView unloadContentsLazily:^(BOOL finished) {
            [self _close:success finshed:block];
        }];
    }else{
        [self _close:success finshed:block];
    }
}

+ (void)_close:(BOOL)success finshed:(void(^)(void))block {
    //remove willclose block
    !blockForWillClose?:blockForWillClose(success);
    blockForWillClose = nil;

    //remove blocks
    blockForDidOpen = nil;
    blockForCanceled = nil;

    //reset catalog view
    [self setProgress:0];
    [self stopSpinProgressOfOkButton];

    //remove user event
    [[exporterView cancelButton] whenSelected:nil];
    [[exporterView okButton] whenSelected:nil];

    //clear
    if([targetButton covered]){
        [targetButton uncoverWithBlur:YES comletion:^(STStandardButton *button, BOOL covered) {
            [self finish:success];
            !block?:block();
        }];
    }else{
        [self finish:success];
    }
}

+ (void)finish:(BOOL)success{
    exporterView.exporter = nil;
    exporterView.optionView = nil;
    [exporterView disposeContent];
    [exporterView clearAllOwnedImagesIfNeeded:YES removeSubViews:YES];
    [exporterView removeFromSuperview];
    exporterView = nil;

    !blockForDidClosed?:blockForDidClosed(success);
    blockForDidClosed = nil;
    targetButton = nil;
}

+ (STExportView *)view {
    return exporterView;
}

+ (void)enableGIFExport:(BOOL)enable {
    if([exporterView.contentView isKindOfClass:STExportPhotosContentView.class]){
        [((STExportPhotosContentView *) exporterView.contentView) enableGIFExport:enable];
    }
}

+ (void)setProgress:(CGFloat)progress {
    [self stopSpinProgressOfOkButton];
    [exporterView okButton].outlineProgress = progress;
    [exporterView okButton].denySelect = progress<1;
}

+ (void)startSpinProgressOfOkButton{
    [exporterView okButton].denySelect = YES;
    [[exporterView okButton] startSpinProgress];
}

+ (void)stopSpinProgressOfOkButton{
    [exporterView okButton].denySelect = NO;
    [[exporterView okButton] stopSpinProgress];
}

@end
