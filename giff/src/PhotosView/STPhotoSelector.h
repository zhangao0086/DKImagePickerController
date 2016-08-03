//
// Created by BLACKGENE on 2014. 8. 25..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"
#import "STThumbnailGridView.h"
#import <Photos/Photos.h>
#import "STPreview.h"
#import "STPreviewCollector.h"
#import "STGIFFApp.h"

@class STPhotoItem;
@class STExporter;
@class STFilterItem;
//@class STPreview;
@class STEditorResult;
@class STEditorCommand;
@class STPhotoItemSource;
@class STPreviewCollector;
@class STFilterCollectorState;

@interface STPhotoSelector : STUIView <STThumbnailGridViewDelegate, PHPhotoLibraryChangeObserver>

@property (nonatomic, readonly) STPhotoSource source;

@property (nonatomic, readonly) BOOL loadingSource;

@property (nonatomic, readonly) STPhotoViewType type;

@property (nonatomic, readonly) STThumbnailGridView * collectionView;

@property (nonatomic, readonly) STPreview *previewView;

@property (nonatomic, readonly) STPhotoItem *previewTargetPhotoItem;

@property (nonatomic, readonly) STFilterCollectorState *previewState;

+ (STPhotoSelector *)initSharedInstanceWithFrame:(CGRect)frame;

+ (STPhotoSelector *)sharedInstance;

- (STPhotoViewType)initialType;

- (void)doChangeSource:(STPhotoSource)source canChange:(void (^)(BOOL))block;

- (void)doChangePhotoViewType:(STPhotoViewType)type;

- (void)doScrollTop;

- (void)doAfterCaptured:(STPhotoItemSource *)photoItemSource;

- (NSArray *)savedPreviewImageFileURLsInRoom;

- (void)exportItemToAssetLibrary:(STPhotoItem *)item completion:(void (^)(BOOL succeed))block;

- (void)exportItemsToAssetLibrary:(NSArray *)photoItems blockForAllFinished:(void (^)(NSArray<STPhotoItem *> *))block;

- (void)deselectAllCurrentSelected;

//- (NSArray *)selectedPhotoItems;

- (NSArray<STPhotoItem *> *)currentFocusedPhotoItems;

- (NSArray<STPhotoItem *> *)allAvailablePhotoItems;

- (void)doSetTypeToMinimumWithFrameAnimation:(CGRect)frame;

- (void)doSetTypeToGridWithFrameAnimation:(CGRect)frame;

- (BOOL)doEnterEdit:(NSUInteger)targetPhotoIndex;

- (void)doEnterLivePreview;

- (void)doExitLivePreview;

- (void)refreshCurrentDisplayImageLayerSet;

- (void)exportDisplayImageLayer:(void (^)(BOOL succeed))completion;

- (BOOL)requestEnterEditLastItemIfPossible;

- (void)doEnterEditByItem:(STPhotoItem *)targetItem;

- (void)doCancelEdit;

- (void)doCancelEdit:(STPhotoViewType)needsTypeAfter transition:(STPreviewCollectorExitTransitionContext)context;

- (void)doResetPreview;

- (void)doLayoutPreviewCollectionViews;

- (void)doBlurPreviewBegin;

- (void)doBlurPreviewEnd;

- (void)doEnterTool;

- (void)doResetTool;

- (void)doUndoTool;

- (void)doCancelTool;

- (BOOL)doCommandTool:(STEditorCommand *)command;

- (void)doApplyTool;

- (void)doExitEditAndApply:(void(^)(STPhotoItem *))block;

- (void)doExitEditAndApplyAndType:(STPhotoViewType)type completion:(void(^)(STPhotoItem *))block;

- (void)doEnterEditAfterCaptureByItem:(STPhotoItem *)item transition:(STPreviewCollectorEnterTransitionContext)context;

- (void)doExitEditAfterCapture:(BOOL)suspend;

- (void)doDirectlyEnterHome;

- (void)doExportAndExitEditAfterCapture:(void(^)(STPhotoItem *item))block;

- (void)doExitAnimatableReviewAfterCapture;

- (void)finishPullingGrid;

- (BOOL)isCurrentTypePhoto;

- (BOOL)isCurrentTypeEdit;

- (BOOL)isCurrentTypePhotoAndHasMoreAppendingPhotos;

- (CGSize)previewImageSizeByType:(STPhotoViewType)type;

- (CGSize)previewImageSize;

- (void)deletePhotos:(NSArray *)photoItems completion:(void (^)(BOOL succeed))completion;

- (void)deleteAllSelectedPhotos:(void (^)(BOOL succeed))completion;

- (void)deleteAllPhotos:(void (^)(BOOL succeed))completion;

- (void)_deleteAllImageFilesInRoom:(void (^)(void))completion;

- (void)deleteAllRoomsImages:(void (^)(void))completion;

- (void)doPutPhotoItems:(NSArray *)item;

- (void)lockOnceObservingPhotoLibraryChange;

- (void)startObservingPhotoLibraryChange;

- (void)stopObservingPhotoLibraryChange;

- (void)clearWhenMemoryWarinig;

- (void)requestOpenAlbumIfPossible;

- (void)initialLoadFromCurrentSource;

- (void)loadFromCurrentSource;

- (void)reloadFromCurrentSourceIfReserved;

- (void)reserveReloadCurrentSource;
@end