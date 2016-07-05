//
// Created by BLACKGENE on 2016. 2. 2..
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STProductCatalogView.h"
#import "UIView+STUtil.h"
#import "STStandardButton.h"
#import "STApp+Products.h"
#import "R.h"
#import "STStandardNavigationButton.h"
#import "STProductCatalogContentView.h"
#import "NSObject+STUtil.h"
#import "NSNotificationCenter+STFXNotificationsShortHand.h"
#import "STApp+Logger.h"
#import "M13OrderedDictionary.h"
#import "NSString+STUtil.h"
#import "STStandardUX.h"
#import "STMainControl.h"
#import "UIColor+BFPaperColors.h"

@interface STProductCatalogView()
@end

@implementation STProductCatalogView

- (void)createContent {
    [super createContent];

    CGFloat subControlWidth = [STStandardLayout widthMainSmall];
    CGFloat minDistanceFromCenterX = ([STStandardLayout widthMain] + [STStandardLayout widthSubAssistance]*2 + subControlWidth)/2;
    minDistanceFromCenterX += (self.width/4-minDistanceFromCenterX/2)/2;

    CGFloat needsMainControlHeight = [STMainControl sharedInstance].height;//self.superview.height-(self.superview.width * STStandardLayout.defaultRectSizeRatio4by3);
//    if(needsMainControlHeight < STStandardLayout.minimumHeightOfBottomControlArea){
//        needsMainControlHeight = STStandardLayout.minimumHeightOfBottomControlArea;
//    }

    _closeButton = [[STStandardButton alloc] initWithSizeWidth:subControlWidth];
    _closeButton.centerX = self.centerX - minDistanceFromCenterX;
    _closeButton.centerY = self.superview.bottom - needsMainControlHeight/2;
    [_closeButton saveInitialLayout];
    _closeButton.allowSelectAsTap = YES;
    _closeButton.shadowOffset = 1.8f;

    [_closeButton setButtons:@[[R go_back]] colors:nil style:STStandardButtonStylePTTP];

    _purchaseButton = [STStandardButton mainSmallSize];
    _purchaseButton.centerX = self.centerX;
    _purchaseButton.centerY = _closeButton.centerY;
    [_purchaseButton saveInitialLayout];
    _purchaseButton.allowSelectAsTap = YES;
    _purchaseButton.shadowOffset = 1.8f;
    _purchaseButton.shadowEnabled = YES;
    //TODO: Try Again when accidently failed
    [_purchaseButton setButtons:@[[R ico_cart]] colors:@[UIColorFromRGB(0xa19699)] bgColors:@[UIColorFromRGB(0xe5fefe)]];
    _purchaseButton.titleLabelPositionedGapFromButton = 6;

    _restoreButton = [[STStandardNavigationButton alloc] initWithSizeWidth:subControlWidth];
    _restoreButton.centerX = self.centerX + minDistanceFromCenterX;
    _restoreButton.centerY = _closeButton.centerY;
    [_restoreButton saveInitialLayout];
    _restoreButton.allowSelectAsTap = YES;
//    _restoreButton.shadowOffset = 1.8f;
//    _restoreButton.shadowEnabled = YES;
    _restoreButton.titleText = NSLocalizedString(@"main.appinfo.restore",nil);
    _restoreButton.titleLabelPositionedGapFromButton = 6;
    [_restoreButton setButtons:@[[R set_reset]] colors:nil style:STStandardButtonStylePTTP];

    _contentView = [[STProductCatalogContentView alloc] initWithFrame:self.bounds];
    [self addSubview:_contentView];

    [self addSubview:_closeButton];
    [self addSubview:_purchaseButton];
    [self addSubview:_restoreButton];
}

- (void)setProductItem:(STProductItem *)productItem {
    _productItem = productItem;
    _purchaseButton.titleText = _productItem.localizedPrice;
    _contentView.productItem = _productItem;
}

- (void)setProductIconImages:(M13OrderedDictionary *)productIconImages {
    _productIconImages = productIconImages;
    _contentView.productIconImages = _productIconImages;
}


#pragma mark Catalog
//TODO: 추후 이걸 static 페이지로 구조화
static STProductCatalogView *catalogView;
static STStandardButton *targetButton;
static NSString *currentProductId;
static void(^blockForPurchased)(NSString *);
static void(^blockForPurchasedFailed)(NSString *);
static void(^blockForClosed)(BOOL);
static void(^blockForWillClose)(BOOL);

+ (void)openWith:(STStandardButton *)targetItemButton
       productId:(NSString *)productId
      iconImages:(M13OrderedDictionary *)images
        willOpen:(void (^)(STProductCatalogView *, STProductItem *))willOpenBlock
         didOpen:(void (^)(STProductCatalogView *, STProductItem *))didOpenBlock
           tried:(void (^)(void))tried
       purchased:(void (^)(NSString *purchasedProductId))purchasedBlock
          failed:(void (^)(NSString *failedProductId))failedBlock
       willClose:(void (^)(BOOL))willCloseBlock
        didClose:(void(^)(BOOL))closedBlock{

    Weaks
    if(targetButton){
        return;
    }
    targetButton = targetItemButton;
    currentProductId = productId;
    blockForPurchased = purchasedBlock;
    blockForPurchasedFailed = failedBlock;
    blockForWillClose = willCloseBlock;
    blockForClosed = closedBlock;

    //add notification
    [[NSNotificationCenter defaultCenter] st_addObserverWithMainQueue:self forName:STNotificationAppProductPurchasingSucceed usingBlock:^(NSNotification *note, id observer) {
        NSDictionary *dict = note.object;
        NSParameterAssert(dict && dict[STNotificationAppProductIdentificationKey]);
        [Wself didControlItemCompletelyPurchased:dict[STNotificationAppProductIdentificationKey]];
    }];
    [[NSNotificationCenter defaultCenter] st_addObserverWithMainQueue:self forName:STNotificationAppProductPurchasingFailed usingBlock:^(NSNotification *note, id observer) {
        NSDictionary *dict = note.object;
        NSParameterAssert(dict && dict[STNotificationAppProductIdentificationKey]);
        [Wself didControlItemFailed:dict[STNotificationAppProductIdentificationKey]];

        if([dict hasKey:STNotificationAppProductTimeoutIdKey]){
            [[STApp defaultAppClass] logEvent:[STNotificationAppProductPurchasingFailed st_add:@"_timout"] key:dict[STNotificationAppProductIdentificationKey] value:dict[STNotificationAppProductTimeoutIdKey]];
        }else{
            [[STApp defaultAppClass] logEvent:STNotificationAppProductPurchasingFailed key:dict[STNotificationAppProductIdentificationKey]];
        }
    }];


    //load info view
    UIView *presentingTargetView = [self st_rootUVC].view;
    if(!catalogView){
        catalogView = [[STProductCatalogView alloc] initWithFrame:presentingTargetView.bounds];
    }
    [presentingTargetView addSubview:catalogView];
    catalogView.visible = NO;

    //fetch data and attach view
    WeakObject(catalogView) weak_catalogView = catalogView;
    WeakObject(targetItemButton) weak_targetItemButton = targetItemButton;
    WeakObject(presentingTargetView) weak_presentingTargetView = presentingTargetView;

    if(![[STApp defaultAppClass] getProductItemIfNeeded:productId reload:YES fetchedBlock:^(STProductItem *productItem) {
        [weak_targetItemButton stopSpinProgress];

        if(productItem){
            /*
             * success
             */
            weak_catalogView.visible = YES;

            !willOpenBlock?:willOpenBlock(weak_catalogView, productItem);

            [productItem setMetadataAsValuesForKey:[STProductItem localMetadataForProductContentsBy:productItem.productIdentifier]];

            weak_catalogView.productItem = productItem;
            weak_catalogView.productIconImages = images;

            [weak_targetItemButton coverWithBlur:weak_presentingTargetView presentingTarget:catalogView blurStyle:UIBlurEffectStyleLight comletion:^(STStandardButton *button, BOOL covered) {
                StrongsAssign(weak_catalogView);
                !didOpenBlock?:didOpenBlock(strong_weak_catalogView, productItem);
            }];
        }
        else {
            /*
             * failed
             */
            [Wself didControlItemFailed:productId];
            [Wself closeProductCatalog:NO];
            [STStandardUX expressDenied:weak_targetItemButton];

            [[STApp defaultAppClass] logError:@"CatalogFetchProductInfo"];
        }
    }]){
        [targetItemButton startSpinProgress:[UIColor whiteColor]];
    };

    //close
    [[catalogView closeButton] whenSelected:^(STSelectableView *selectedView, NSInteger index) {
        [[STApp defaultAppClass] logEvent:@"CatalogClick_Close" key:productId];

        [Wself closeProductCatalog:NO];
    }];

    //purchase
    [[catalogView purchaseButton] whenSelected:^(STSelectableView *selectedView, NSInteger index) {
        [[STApp defaultAppClass] logEvent:@"CatalogClick_Purchase" key:productId];

        tried();

        [[catalogView purchaseButton] startSpinProgress];
    }];

    //restore
    void(^restoreFinishedBlock)(BOOL) = ^(BOOL restored){
        [[catalogView restoreButton] stopSpinProgress];

        if(restored){
            [Wself didControlItemCompletelyPurchased:productId];
        }else{
            [Wself didControlItemFailed:productId];

            [[STApp defaultAppClass] logError:@"CatalogRestoreAll"];
        }
    };

    [[catalogView restoreButton] whenSelected:^(STSelectableView *selectedView, NSInteger index) {
        [[catalogView restoreButton] startSpinProgress];

        [[STApp defaultAppClass] restoreAllProductIfNeeded:^(NSArray *transactions) {
            restoreFinishedBlock(transactions.count > 0);

        } failure:^(NSError *error) {
            restoreFinishedBlock(NO);
        }];

        [[STApp defaultAppClass] logEvent:@"CatalogClick_Restore" key:productId];
    }];

    [[STApp defaultAppClass] logEvent:@"CatalogOpen" key:productId];
}

+ (void)resetProductCatalog {
    [targetButton stopSpinProgress];
    [[catalogView purchaseButton] stopSpinProgress];
}

+ (void)closeProductCatalog:(BOOL)purchaseSuccess {
    [[STApp defaultAppClass] logEvent:purchaseSuccess ? @"CatalogClose_Purchase" : @"CatalogClose_Cancel" key:currentProductId];

    //remove notification
    [[NSNotificationCenter defaultCenter] st_removeObserverWithMainQueue:self forName:STNotificationAppProductPurchasingSucceed];
    [[NSNotificationCenter defaultCenter] st_removeObserverWithMainQueue:self forName:STNotificationAppProductPurchasingFailed];

    //remove willclose block
    !blockForWillClose?:blockForWillClose(purchaseSuccess);
    blockForWillClose = nil;

    //remove blocks
    blockForPurchased = nil;
    blockForPurchasedFailed = nil;

    //reset catalog view
    [self resetProductCatalog];

    //remove user event
    [[catalogView closeButton] whenSelected:nil];
    [[catalogView purchaseButton] whenSelected:nil];
    [[catalogView restoreButton] whenSelected:nil];

    //clear
    void(^clearBlock)(STStandardButton *, BOOL) = ^(STStandardButton *button, BOOL covered) {
        catalogView.productItem = nil;
        catalogView.productIconImages = nil;
        [catalogView clearAllOwnedImagesIfNeeded:YES removeSubViews:YES];
        [catalogView removeFromSuperview];
        catalogView = nil;

        targetButton = nil;
        !blockForClosed?:blockForClosed(purchaseSuccess);
        blockForClosed = nil;
    };
    if([targetButton covered]){
        [targetButton uncoverWithBlur:YES comletion:clearBlock];
    }else{
        clearBlock(targetButton, NO);
    }

    currentProductId = nil;
}

+ (void)didControlItemCompletelyPurchased:(NSString *)productId{
    if(![[STApp defaultAppClass] isPurchasedProduct:productId]){
        NSAssert(NO,@"didControlItemCompletelyPurchased, but actually NOT purchased. why?");
        return;
    }

    !blockForPurchased?:blockForPurchased(productId);

    [self closeProductCatalog:YES];
}

+ (void)didControlItemFailed:(NSString *)productId{
    [self resetProductCatalog];

    oo([@"***** failed ******  " st_add:productId]);

    !blockForPurchasedFailed?:blockForPurchasedFailed(productId);
}


@end