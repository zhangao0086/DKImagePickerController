//
// Created by BLACKGENE on 8/3/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STPhotoItem;
@class STPhotoItemSource;


@interface STPhotosManager : NSObject
+ (STPhotosManager *)sharedManager;

- (STPhotoItem *)generatePhotoItem:(STPhotoItemSource *)photoSource;

- (CGSize)previewImageSizeByType:(STPhotoViewType)type ratio:(CGFloat)ratio;

- (CGSize)previewImageSizeByType:(STPhotoViewType)type originalSize:(CGSize)size;

- (void)saveImageToUrl:(UIImage *)image fileUrl:(NSURL *)url quality:(CGFloat)quality;

- (void)saveImageToUrl:(UIImage *)image fileUrl:(NSURL *)url quality:(CGFloat)quality background:(BOOL)background;

- (void)deleteImageToUrl:(NSURL *)url;

- (NSURL *)makeTempImageSaveUrl:(NSString *)prefixName;

- (NSURL *)makeImagesSaveUrl:(NSString *)prefixName index:(NSInteger)index;

- (NSURL *)makeImagesSaveUrl:(NSString *)dirPath prefix:(NSString *)prefix index:(NSInteger)index;

- (NSURL *)makeSavedImageUrlFromOtherPreifx:(NSURL *)url prefix:(NSString *)prefix prefixConvertTo:(NSString *)prefixConvertTo;

- (NSInteger)indexFromSaveUrl:(NSURL *)url prefix:(NSString *)prefix;

- (NSString *)saveTargetDir;

- (NSArray *)savedPreviewImageFileURLsInRoom;
@end