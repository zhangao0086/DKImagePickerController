//
//  DKAsset.h
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/6/23.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>




@interface DKAsset : NSObject
@property (nonatomic, assign) BOOL isVideo;
@property (nonatomic, strong) CLLocation * location;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong) PHAsset * originalAsset;
@property (nonatomic, copy) NSString * localIdentifier;
@property (nonatomic, strong) UIImage * image;


- (instancetype)initWithOriginalAsset:(PHAsset *)asset;
- (instancetype)initWithImage:(UIImage *)image;


- (void)fetchImageWithSize:(CGSize)size
             completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock;

- (void)fetchImageWithSize:(CGSize)size
                   options:(PHImageRequestOptions *)options
             completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock;

- (void)fetchImageWithSize:(CGSize)size
                   options:(PHImageRequestOptions *)options
               contentMode:(PHImageContentMode)contentMode
             completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock;

/**
 Fetch an image with the original size.

 @param isSynchronous If true, the method blocks the calling thread until image is ready or an error occurs.
 @param completeBlock The block is executed when the image download is complete.
 */
- (void)fetchOriginalImageIsSynchronous:(BOOL)isSynchronous
                          completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock;

/**
 Fetch an image data with the original size.

 @param isSynchronous If true, the method blocks the calling thread until image is ready or an error occurs.
 @param completeBlock The block is executed when the image download is complete.
 */
- (void)fetchImageDataForAssetIsSynchronous:(BOOL)isSynchronous
                              completeBlock:(void(^)(NSData  * imageData, NSDictionary * info))completeBlock;

- (void)fetchAVAsset:(PHVideoRequestOptions *)options
       completeBlock:(void(^)(AVAsset * avAsset, NSDictionary * info))completeBlock;

- (void)fetchAVAssetWithCompleteBlock:(void(^)(AVAsset * avAsset, NSDictionary * info))completeBlock;

- (void)fetchAVAssetIsSynchronous:(BOOL)IsSynchronous
                          options:(PHVideoRequestOptions *)options
                    completeBlock:(void(^)(AVAsset * avAsset, NSDictionary * info))completeBlock;


@end
