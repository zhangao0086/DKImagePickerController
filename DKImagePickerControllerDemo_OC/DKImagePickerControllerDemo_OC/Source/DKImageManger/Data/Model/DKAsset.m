//
//  DKAsset.m
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/6/23.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKAsset.h"
#import "DKImageManager.h"
@implementation DKAsset
- (instancetype)initWithOriginalAsset:(PHAsset *)asset{
    self = [super init];
    if (self) {
        self.localIdentifier = asset.localIdentifier;
        self.location = asset.location;
        self.originalAsset = asset;
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            self.isVideo = true;
            self.duration = asset.duration;
        }
        
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image{
    self = [super init];
    if (self) {
        self.localIdentifier = [NSString stringWithFormat:@"%lu", (unsigned long)image.hash];
        self.image = image;
        
    }
    return self;
}

- (BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[DKAsset class]]) {
        return [self.localIdentifier isEqualToString:((DKAsset *)object).localIdentifier];
    }else{
        return NO;
    }
}


#pragma mark -- Fetch Image
- (void)fetchImageWithSize:(CGSize)size
             completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock{
    [self fetchImageWithSize:size options:nil completeBlock:completeBlock];
}

- (void)fetchImageWithSize:(CGSize)size
                   options:(PHImageRequestOptions *)options
             completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock
{
    [self fetchImageWithSize:size options:options contentMode:PHImageContentModeAspectFit completeBlock:completeBlock];
}

- (void)fetchImageWithSize:(CGSize)size
                   options:(PHImageRequestOptions *)options
               contentMode:(PHImageContentMode)contentMode
             completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock
{
    if (self.originalAsset) {
        [[DKImageManager shareInstance] fetchImageForAssetWith:self size:size options:options completeBlock:completeBlock];
    } else{
        completeBlock(self.image, nil);
    }
}

- (void)fetchOriginalImageIsSynchronous:(BOOL)isSynchronous
                          completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock{
    
    [self fetchImageDataForAssetIsSynchronous:isSynchronous completeBlock:^(NSData *imageData, NSDictionary *info) {
        UIImage * image;
        if (imageData) {
            image = [UIImage imageWithData:imageData];
        }
        completeBlock(image, info);

    }];
    
}

- (void)fetchImageDataForAssetIsSynchronous:(BOOL)isSynchronous
                              completeBlock:(void(^)(NSData  * imageData, NSDictionary * info))completeBlock{
    PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.synchronous = isSynchronous;
    
    [[DKImageManager shareInstance] fetchImageDataForAsset:self options:options completeBlock:completeBlock];
}


- (void)fetchAVAsset:(PHVideoRequestOptions *)options
       completeBlock:(void(^)(AVAsset * avAsset, NSDictionary * info))completeBlock
{
    [[DKImageManager shareInstance] fetchAVAsset:self options:options completeBlock:completeBlock];
}

- (void)fetchAVAssetWithCompleteBlock:(void(^)(AVAsset * avAsset, NSDictionary * info))completeBlock{
    [self fetchAVAsset:nil completeBlock:completeBlock];
}

- (void)fetchAVAssetIsSynchronous:(BOOL)IsSynchronous
             options:(PHVideoRequestOptions *)options
       completeBlock:(void(^)(AVAsset * avAsset, NSDictionary * info))completeBlock
{
    if (IsSynchronous) {
       dispatch_semaphore_t sem = dispatch_semaphore_create(0);
       
       [self fetchAVAsset:options completeBlock:^(AVAsset *avAsset, NSDictionary *info) {
           completeBlock(avAsset, info);
           dispatch_semaphore_signal(sem);
       }];
       dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }else{
        [self fetchAVAsset:options completeBlock:completeBlock];
    }
}

@end
