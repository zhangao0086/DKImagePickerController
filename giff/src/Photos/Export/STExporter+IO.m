//
// Created by BLACKGENE on 2015. 2. 12..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STExporter+IO.h"
#import "STPhotoItem.h"
#import "NSObject+STThreadUtil.h"
#import "STGIFFAppSetting.h"
#import "STReachabilityManager.h"
#import "STEditorResult.h"
#import "STFilterItem.h"
#import "STFilterManager.h"
#import "STPhotoItemSource.h"
#import "STQueueManager.h"
#import "NSGIF.h"
#import "STPhotoItem+ExporterIO.h"
#import "STCapturedImageSet.h"
#import "STExporter+ConfigGIF.h"
#import "STPhotoItem+ExporterIOGIF.h"
#import "STCapturedImage.h"

@implementation STExporter (IO)

#pragma mark MakeImage
+ (UIImage *)buildFilteredImageFrom:(UIImage *)inputImage filter:(STFilterItem *)filterItem enhance:(BOOL)enhance{
    //TODO move this method into STFilterManager
    //FIXME Someday begin : why image loads with not matched orientation from photos library's when take a photo using default camera app.
    GPUImageRotationMode GPUImageRotation = kGPUImageNoRotation;
    switch (inputImage.imageOrientation){
        case UIImageOrientationUp: break;
        case UIImageOrientationDown: GPUImageRotation = kGPUImageRotate180; break;
        case UIImageOrientationLeft: GPUImageRotation = kGPUImageRotateLeft; break;
        case UIImageOrientationRight: GPUImageRotation = kGPUImageRotateRight; break;

        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            NSAssert(NO, @"Did not defined at ImageOrientationToGPUImageRotationMode");
            break;
    }
    return [[STFilterManager sharedManager] buildOutputImage:inputImage
                                                     enhance:enhance
                                                      filter: filterItem ? [[STFilterManager sharedManager] acquire:filterItem] : nil
                                            extendingFilters:nil
                                                rotationMode:GPUImageRotation
                                                 outputScale:1
                                       useCurrentFrameBuffer:YES];
}

+ (UIImage *)buildImage:(STPhotoItem *)item inputImage:(UIImage *)inputImage enhance:(BOOL)enhance{
    UIImage * resultImage = [self buildFilteredImageFrom:inputImage filter:item.isFilterApplied ? item.currentFilterItem : nil enhance:enhance];

    //TODO: tool 동작중 GPUImageFiler에서 처리할수 있는건 이렇게 하지 말고, chain으로 처리 할수 없을까
    if(item.isModifiedByTool){
        resultImage = [item.toolResult modifiyImage:resultImage];
    }

    return resultImage;
}

+ (UIImage *)buildImage:(STPhotoItem *)item fullResolution:(BOOL)fullResolution enhance:(BOOL)enhance{
    return [self buildImage:item
                 inputImage:fullResolution ? [item loadFullResolutionImage] : [item loadFullScreenImage]
                    enhance:enhance];
}

#pragma mark MakeImage (STPhotoItem -> STExporter)
+ (STPhotoItemSource *)createPhotoItemSourceToExport:(STPhotoItem *)item {

    // sourceForCapturedImageSet
    if(item.sourceForCapturedImageSet){
        STCapturedImageSet * targetSet = item.sourceForCapturedImageSet;

        //export only default image
        if(item.exportAsOnlyDefaultImageOfImageSet){
            targetSet = [STCapturedImageSet setWithImages:@[item.sourceForCapturedImageSet.defaultImage]];
        }

        if(item.isEdited){
            for(STCapturedImage * image in targetSet.images){
                NSAssert(image.imageUrl, @"buildNewSource : Supported Only NSURL type for Filtering CapturedImageSet.");
                @autoreleasepool {
                    UIImage * resultImage = [self buildImage:item
                                                  inputImage:image.UIImage
                                                     enhance:item.needsEnhance];

                    BOOL success = [UIImageJPEGRepresentation(resultImage, .8) writeToURL:image.imageUrl atomically:NO];
                    NSAssert(success, @"buildNewSource : STCapturedImage's file writing not succedd");
                }
            }
        }

        return [STPhotoItemSource sourceWithImageSet:targetSet];

    }else{
        // single images

        //TODO: 로컬 저장시 F, M, S 선택가능하게 하는 것이 좋을 듯
        STPhotoItemSource * source = [STPhotoItemSource sourceWithImage:[self buildImage:item fullResolution:YES enhance:item.needsEnhance]];
        item.needsEnhance = NO;
        return source;
    }
}

- (void)cleanAllExportedResults{
    for(STPhotoItem * photoItem in self.photoItems){
        photoItem.exportGIFRequest = nil;
        photoItem.exportedTempFileURL = nil;
    }
}

- (void)cancelAllExportJobs{
    //gif
    for(STPhotoItem * gifExportingItem in self.photoItemsCanExportGIF){
        gifExportingItem.exportGIFRequest = nil;
    }
}

#pragma mark Image
- (UIImage *)exportImage:(STPhotoItem *)item{
    return [self exportImage:item fullResolution:self.isRequiredFullResolution];
}

- (UIImage *)exportImage:(STPhotoItem *)item fullResolution:(BOOL)fullResolution {
    @synchronized (item) {
        if(item.exportedTempFileURL) {
            //1 : data from exportFile
            return [UIImage imageWithContentsOfFile:item.exportedTempFileURL.path];

        }else if([item isEdited]){
            //2 : edited
            return [self.class buildImage:item fullResolution:fullResolution enhance:item.needsEnhance];

        }else{
            //3 : raw image
            return fullResolution ? [item loadFullResolutionImage] : [item loadFullScreenImage];
        }
    }
}

- (void)exportAllImages:(void(^)(NSArray * images))completion{
    [self exportAllImages:self.isRequiredFullResolution completion:completion];
}

- (void)exportAllImages:(BOOL)fullResolution completion:(void(^)(NSArray * images))block{
    [self exportImages:self.photoItems fullResolution:fullResolution completion:block];
}

- (void)exportImages:(NSArray *)items completion:(void(^)(NSArray * images))block{
    [self exportImages:self.photoItems fullResolution:self.isRequiredFullResolution completion:block];
}

- (void)exportImages:(NSArray *)items fullResolution:(BOOL)fullResolution completion:(void(^)(NSArray * images))block{
    NSParameterAssert(items.count);
    NSParameterAssert(block);

    Weaks
    dispatch_async([STQueueManager sharedQueue].readingIO, ^{
        @autoreleasepool {
            Strongs
            NSMutableArray * results = [NSMutableArray array];
            for (STPhotoItem * item in items){
                UIImage * image = [Wself exportImage:item fullResolution:fullResolution];
                if(image){
                    [results addObject:image];
                }
            }
            [Sself st_runAsMainQueueAsync:^{
                block(results);
            }];
        }
    });
}

#pragma mark Data
- (NSData *)exportData:(STPhotoItem *)item{
    return [self exportData:item fullResolution:self.isRequiredFullResolution];
}

- (NSData *)exportData:(STPhotoItem *)item fullResolution:(BOOL)fullResolution{
    @synchronized (item) {
        NSData * data = nil;
        if(item.exportedTempFileURL){
            //1 : data from exportFile
            data = [NSData dataWithContentsOfURL:item.exportedTempFileURL];

        }else if([item isEdited]){
            //2
            data = UIImageJPEGRepresentation([self exportImage:item fullResolution:fullResolution], 0.8);

        }else{
            //3
            data = fullResolution ? [item loadFullResolutionData] : [item loadFullScreenData];
        }
        return data;
    }
}

- (void)exportAllDatas:(void(^)(NSArray * datas))completion{
    [self exportAllDatas:self.isRequiredFullResolution completion:completion];
}

- (void)exportAllDatas:(BOOL)fullResolution completion:(void(^)(NSArray * datas))block{
    [self exportDatas:self.photoItems fullResolution:fullResolution completion:block];
}

- (void)exportDatas:(NSArray *)items completion:(void(^)(NSArray * datas))block{
    [self exportDatas:self.photoItems fullResolution:self.isRequiredFullResolution completion:block];
}

- (void)exportDatas:(NSArray *)items fullResolution:(BOOL)fullResolution completion:(void(^)(NSArray * datas))block{
    NSParameterAssert(items.count);
    NSParameterAssert(block);

    Weaks
    dispatch_async([STQueueManager sharedQueue].readingIO, ^{
        @autoreleasepool {
            Strongs
            NSMutableArray * results = [NSMutableArray array];
            for (STPhotoItem * item in items){
                NSData * data = [Wself exportData:item fullResolution:fullResolution];
                if(data){
                    [results addObject:data];
                }
            }
            [Sself st_runAsMainQueueAsync:^{
                block(results);
            }];
        }
    });
}

- (CGFloat)checkDataTotalMegaBytes:(NSArray *)photoItems{
    __block CGFloat totalByteLength = 0;
    Weaks
    [photoItems eachWithIndex:^(id object, NSUInteger index) {
        @autoreleasepool {
            totalByteLength += [Wself exportData:object].length;
        }
    }];
    return totalByteLength/1024/1024;
}

- (BOOL)isRequiredFullResolution {
    NSInteger q = [[[STGIFFAppSetting get] read:@keypath([STGIFFAppSetting get].exportQuality)] integerValue];
    return self.allowedFullResolution && (q == STExportQualityOriginal || (q == STExportQualityAuto && [STReachabilityManager sharedInstance].isConnectedWifi));
}

#pragma mark File
- (NSURL *)exportFile:(STPhotoItem *)photo id:(NSString *)id{
    @autoreleasepool {
        photo.exporting = !photo.exportedTempFileURL;
        //already exported
        if(photo.exportedTempFileURL){
            return photo.exportedTempFileURL;
        }

        NSURL * url = nil;
        NSURL * tempUrl = [self tempURL:id];
//        if([[NSFileManager defaultManager] fileExistsAtPath:tempUrl.path]){
//            NSAssert([[NSFileManager defaultManager] removeItemAtURL:tempUrl error:NULL],@"remove file failed - when perform exportFile");
//        }
        NSData * data = [self exportData:photo];
        BOOL createdTempFile = [[NSFileManager defaultManager] createFileAtPath:tempUrl.path contents:data attributes:nil];
        NSAssert([data length],@"exportData's length is 0");
        NSAssert(createdTempFile,([NSString stringWithFormat:@"tempfile creation incompleted - %@",tempUrl.path]));
        if([data length] && createdTempFile){
            url = tempUrl;
        }
        photo.exportedTempFileURL = url;
        return url;
    }
}

- (void)exportFiles:(NSArray *)items completion:(void(^)(NSArray * imageURLs))block{
    NSParameterAssert(items && items.count);
    NSParameterAssert(block);
    Weaks
    dispatch_async([STQueueManager sharedQueue].readingIO, ^{
        @autoreleasepool {
            NSMutableArray * results = [@[] mutableCopy];

            for(STPhotoItem * photo in items){
                NSURL * url = [self exportFile:photo id:[@([items indexOfObject:photo]) stringValue]];
                if(url){
                    [results addObject:url];
                }
            }

            if(block){
                [Wself st_runAsMainQueueAsyncWithSelf:^(id _selfObject) {
                    block(results);
                }];
            }
        }
    });
}

- (void)exportAllFiles:(void(^)(NSArray * imageURLs))block{
    [self exportFiles:self.photoItems completion:block];
}

#pragma mark Temp
- (NSString *)preferedExtensionOfTempFile{
    return nil;
}

- (NSURL *)tempURL:(NSString *)id {
    return [self tempURL:id extension:[self preferedExtensionOfTempFile]?:@"jpg"];
}

- (NSURL *)tempURL:(NSString *)id extension:(NSString *)extension{
    NSString * fileName = [[NSString stringWithFormat:@"elie_share_tmp_%@_%@", [@(self.type) stringValue], id ?: @"n"] stringByAppendingPathExtension:extension];
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
}

@end