//
// Created by BLACKGENE on 7/21/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"

@class GPUImageTwoInputFilter;
@class GPUImageOutput;
@protocol GPUImageInput;

typedef NS_ENUM(NSInteger, STGPUImageOutputComposeItemCategory) {
    STGPUImageOutputComposeItemCategoryUndefined,
    STGPUImageOutputComposeItemCategorySourceImage,
    STGPUImageOutputComposeItemCategoryMask
};

@interface STGPUImageOutputComposeItem : STItem
@property (nonatomic, readwrite) NSArray<GPUImageOutput <GPUImageInput> *> *filters;
@property (nonatomic, readwrite) GPUImageOutput *source;
@property (nonatomic, readwrite) GPUImageTwoInputFilter *composer;
@property (nonatomic, assign) STGPUImageOutputComposeItemCategory category;

- (instancetype)initWithSourceImage:(UIImage *)sourceImage;

+ (instancetype)itemWithSourceImage:(UIImage *)sourceImage;

- (instancetype)initWithSource:(GPUImageOutput *)source;

+ (instancetype)itemWithSource:(GPUImageOutput *)source;

- (instancetype)initWithSource:(GPUImageOutput *)source composer:(GPUImageTwoInputFilter *)composer;

+ (instancetype)itemWithSource:(GPUImageOutput *)source composer:(GPUImageTwoInputFilter *)composer;

- (instancetype)setSourceAsImage:(UIImage *)image;

- (instancetype)initWithSourceImage:(UIImage *)sourceImage composer:(GPUImageTwoInputFilter *)composer;

+ (instancetype)itemWithSourceImage:(UIImage *)sourceImage composer:(GPUImageTwoInputFilter *)composer;

- (instancetype)addFilters:(NSArray<GPUImageOutput <GPUImageInput> *> *)filters;

@end