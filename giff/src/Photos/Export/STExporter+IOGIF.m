//
// Created by BLACKGENE on 5/11/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STExporter+IOGIF.h"
#import "STExporter+IO.h"
#import "STPhotoItem.h"
#import "STQueueManager.h"
#import "NSGIF.h"
#import "BlocksKit.h"
#import "FCFileManager.h"
#import "NSArray+STUtil.h"
#import "STPhotoItem+ExporterIO.h"
#import "STPhotoItem+ExporterIOGIF.h"
#import "NSData+STGIFUtil.h"
#import "STCapturedImageSet.h"
#import "STCapturedImageSet+PostFocus.h"
#import "STCapturedImage.h"
#import "STExporter+ConfigGIF.h"
#import "STExporter+Config.h"
#import "PHAsset+STUtil.h"
#import "STCapturedImage+STExporterIOGIF.h"

@implementation STExporter (IOGIF)

#pragma mark Gif

+ (void)exportGIFsFromPhotoItems:(BOOL)export photoItems:(NSArray<STPhotoItem *> *)items progress:(void (^)(CGFloat))progressBlock completion:(void(^)(NSArray *gifURLs, NSArray *succeedItems, NSArray *errorItems))completionBlock {
    NSParameterAssert(items.count);

    STExporter * exporter = [STExporter exporterBlank];
    exporter.photoItems = items;

    NSParameterAssert(exporter.photoItemsCanExportGIF.count);

    BOOL enableGIFExport = export && exporter.photoItemsCanExportGIF.count > 0;
    if (!enableGIFExport) {
        !completionBlock ?: completionBlock(nil, nil, exporter.photoItems);
        return;
    }

    //set progresshandler
    NSUInteger totalCount = exporter.photoItemsCanExportGIF.count;

    //set a option to create gif
    Weaks
    for (STPhotoItem * item in exporter.photoItemsCanExportGIF){
        WeakAssign(item)
        NSAssert(item.exportGIFRequest,@"item.exportGIFRequest is nil");

        item.exportGIFRequest.progressHandler = ^(double progress, NSUInteger offset, NSUInteger length, CMTime time, BOOL *stop, NSDictionary *frameProperties) {
            //TODO: interrupt if exporter has been finished
            dispatch_async(dispatch_get_main_queue(),^{
                CGFloat blockSize = 1/(CGFloat)totalCount;
                CGFloat _progress = (blockSize * (CGFloat)[exporter.photoItemsCanExportGIF indexOfObject:weak_item]) + (CGFloat) (blockSize * progress);

                !progressBlock?:progressBlock(_progress);
            });
        };
    }

    BOOL forceReload = NO;
#if DEBUG
    forceReload = YES;
#endif
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    [exporter exportGIFs:exporter.photoItemsCanExportGIF processChunk:1 forceReload:forceReload progress:^(NSURL *gifURL, STPhotoItem * item, NSUInteger count, NSUInteger total) {

    } completion:^(NSArray *gifURLs, NSArray *succeedItems, NSArray *errorItems) {

        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

        !completionBlock?:completionBlock(gifURLs, succeedItems, errorItems);
    }];
}


- (void)exportGIF:(STPhotoItem *)photo completion:(void(^)(NSURL * gifURL))block{
    [self exportGIF:photo forceReload:NO completion:block];
}

- (void)exportGIF:(STPhotoItem *)photo forceReload:(BOOL)reload completion:(void(^)(NSURL * gifURL))block{
    if(![self.class canExportGIF:photo]){
        block(nil);
        return;
    }

    if(photo.sourceForAsset){
        [self _exportGIFFromSourceAsset:photo forceReload:reload completion:block];

    }else if(photo.sourceForCapturedImageSet){
        [self _exportGIFFromSourceCapturedImageSet:photo forceReload:reload completion:block];

    }else{
        NSAssert(NO, @"Not supported this photo item. check content source of PhotoItem");
        block(nil);
    }
}

- (void)_exportGIFFromSourceAsset:(STPhotoItem *)photo forceReload:(BOOL)reload completion:(void(^)(NSURL * gifURL))block{
    NSParameterAssert(photo.sourceForAsset);
    photo.exporting = YES;
    [photo.sourceForAsset exportFileByResourceType:[self.class primaryAssetResourceTypeByPhotoItem:photo]
                                                to:nil
                                       forceReload:reload
                                        completion:^(NSURL *tempFileURL) {
                                            if (tempFileURL) {
                                                NSURL *gifFileURL = [STPhotoItem exportingTempFileGIF:tempFileURL extension:self.preferedExtensionOfTempFile];
                                                BOOL gifExists = [FCFileManager existsItemAtPath:gifFileURL.path];

                                                //return gif file already exists or do not perform reloading
                                                if (!reload && gifExists) {
                                                    photo.exportedTempFileURL = gifFileURL;
                                                    block(gifFileURL);

                                                } else {
                                                    //new create gif
                                                    photo.exportGIFRequest = [STExporter createRequestExportGIF:photo];
                                                    photo.exportGIFRequest.sourceVideoFile = tempFileURL;
                                                    photo.exportGIFRequest.destinationVideoFile = gifFileURL;

                                                    [NSGIF create:photo.exportGIFRequest completion:^(NSURL *GifURL) {
                                                        NSAssert(GifURL, ([NSString stringWithFormat:@"Something wrong. Can't generate gif file for %@", gifFileURL.path]));
                                                        photo.exportedTempFileURL = gifFileURL;
                                                        !block?:block(GifURL);
                                                        photo.exportGIFRequest = nil;
                                                    }];
                                                }
                                            } else {
                                                block(nil);
                                            }
                                        }];
}


- (void)_exportGIFFromSourceCapturedImageSet:(STPhotoItem *)photo forceReload:(BOOL)reload completion:(void(^)(NSURL * gifURL))block{
    NSParameterAssert(photo.sourceForCapturedImageSet);
    if(!reload && photo.isExportedTempFileGIF && [FCFileManager existsItemAtPath:photo.exportedTempFileURL.path]){
        block(photo.exportedTempFileURL);
        return;
    }

    NSParameterAssert(photo.exportGIFRequest);
    NSParameterAssert(photo.exportGIFRequest.destinationVideoFile);
    NSParameterAssert(photo.exportGIFRequest.maxDuration>0);

    NSArray<STCapturedImage *> * targetImages = nil;
    if(STPostFocusModeNone != [photo.sourceForCapturedImageSet postFocusMode]){
        targetImages = [photo.sourceForCapturedImageSet compactedImagesByLensPosition:YES minimizeByFlooredInteger:YES];
    }else{
        targetImages = photo.sourceForCapturedImageSet.images;
    };

    NSArray * sources = [[targetImages bk_select:^BOOL(STCapturedImage * image) {
        NSAssert(image.hasSource, @"STCapturedImage has not its source");
        return image.hasSource;

    }] mapWithIndex:^id(STCapturedImage * image, NSInteger index) {
        @autoreleasepool {
            if(image.frameImageURLToExportGIF){
                return image.frameImageURLToExportGIF.path;
            }

            if(image.fullScreenUrl){
                return [image fullScreenUrl].path;
            }

            if(image.thumbnailUrl){
                return [image thumbnailUrl].path;
            }

            if(image.imageUrl){
                return [image imageUrl].path;
            }

            if(image.image){
                return [image image];
            }

            return [image NSURL].path;
        }
    }];

    //add revered
    NSMutableArray * reversedImages = [[sources reverse] mutableCopy];
    [reversedImages removeObjectsInRange:NSMakeRange(0, 1)];
    [reversedImages removeLastObject];
    sources = [sources arrayByAddingObjectsFromArray:reversedImages];

    if(sources.count){
        photo.exporting = YES;
        dispatch_async([STQueueManager sharedQueue].writingIO, ^{
            @autoreleasepool {
                NSData *gifData = nil;
                if ([[sources firstObject] isKindOfClass:NSString.class]) {
                    gifData = UIImageFilesAnimatedGIFRepresentation(sources, photo.exportGIFRequest.maxDuration, 0, NULL);

                } else if ([[sources firstObject] isKindOfClass:UIImage.class]) {
                    gifData = UIImagesAnimatedGIFRepresentation(sources, photo.exportGIFRequest.maxDuration, 0, NULL);

                } else {
                    NSAssert(NO, @"not supported source object type");
                }

                NSAssert(gifData, @"gif data failed");
                NSURL * gifFileURL = [STPhotoItem exportingTempFileGIF:photo.exportGIFRequest.destinationVideoFile extension:self.preferedExtensionOfTempFile];
                if (gifData && [gifData writeToFile:gifFileURL.path atomically:NO]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        photo.exportedTempFileURL = gifFileURL;
                        block(photo.exportedTempFileURL);
                        photo.exportGIFRequest = nil;
                    });

                } else {
                    NSAssert(gifData, @"gif file writing failed");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil);
                    });
                }
            }
        });
    }else{
        block(nil);
    }

}

- (void)exportGIFs:(NSArray *)items
          progress:(void (^)(NSURL *gifURL, STPhotoItem * item, NSUInteger count, NSUInteger total))progressblock
        completion:(void(^)(NSArray * gifURLs, NSArray * succeedItems, NSArray * errorItems))block{
    [self exportGIFs:items processChunk:3 forceReload:NO progress:progressblock completion:block];
}

- (void)exportGIFs:(NSArray *)items
      processChunk:(NSUInteger)chunkSize
       forceReload:(BOOL)reload
          progress:(void (^)(NSURL *gifURL, STPhotoItem * item, NSUInteger count, NSUInteger total))progressblock
        completion:(void(^)(NSArray * gifURLs, NSArray * succeedItems, NSArray * errorItems))block{

    NSParameterAssert(items && items.count);
    NSParameterAssert(block);
    Weaks

    //good serial process pattern.
    NSMutableArray * succeedGifURLs = [@[] mutableCopy];
    NSMutableArray * succeedItems = [@[] mutableCopy];
    NSMutableArray * errorItems = [@[] mutableCopy];
    NSUInteger totalCount = items.count;
    __block NSUInteger currentCount = 0;
    __block void (^processItems)(NSArray *);
    NSArray * chunckedItems = [items chunkifyWithMaxSize:chunkSize];
    NSEnumerator * chuckedEnumerator = [chunckedItems objectEnumerator];

    (processItems = ^(NSArray * chunckedPhotoItems) {
        NSMutableArray * succeedItemsInCurrentChunk = [NSMutableArray arrayWithArray:chunckedPhotoItems];

        for(STPhotoItem * item in chunckedPhotoItems){
            @autoreleasepool {
                [Wself exportGIF:item forceReload:reload completion:^(NSURL *gifURL) {
                    currentCount++;

                    if (!gifURL) {
                        //error
                        [succeedItemsInCurrentChunk removeObject:item];
                        [errorItems addObject:item];

                    } else {
                        //succeed
                        [succeedGifURLs addObject:gifURL];
                        [succeedItems addObject:item];
                    }

                    !progressblock ?: progressblock(gifURL, item, currentCount, totalCount);

                    if (currentCount == totalCount) {
                        //total complete
                        NSAssert(succeedGifURLs.count==succeedItems.count, @"succeedGifURLs and succeedItems must be same");
                        NSAssert(totalCount==(succeedGifURLs.count+errorItems.count), @"totalCount must be same with succeedGifURLs + errorItems");
                        block([succeedGifURLs copy], [succeedItems copy], [errorItems copy]);
                        processItems = nil;

                    } else if (succeedItemsInCurrentChunk.count == 0 || [item isEqual:[succeedItemsInCurrentChunk lastObject]]) {
                        //finish chunk
                        processItems([chuckedEnumerator nextObject]);
                    }

                }];
            }
        }

    })([chuckedEnumerator nextObject]);
}
@end