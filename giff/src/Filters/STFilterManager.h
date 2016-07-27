//
//  SPFilterInfoManager.h
//  prism
//
//  Created by Hyojin Mo on 2014. 5. 14..
//  Copyright (c) 2014년 Starpret. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class STFilterItem;
@class STFilter;
@class GPUImageOutput;
@class GPUImageFilterGroup;
@protocol GPUImageInput;
@class M13OrderedDictionary;
@class STGPUImageOutputComposeItem;

@interface STFilterManager : NSObject

@property (atomic, readonly) NSArray *filterGroups;
@property (nonatomic, readonly) STFilterItem *defaultFilterItem;

+ (STFilterManager *)sharedManager;

- (void)loadFilterInfoWithCompletion:(void (^)(NSArray *filterInfoList))completion;

- (STFilter *)acquire:(STFilterItem *)item;

- (GPUImageOutput *)buildTerminalOutputToComposeMultiSource:(NSArray<STGPUImageOutputComposeItem *> *)items forInput:(id<GPUImageInput>)input;

- (NSArray *)buildOutputChain:(GPUImageOutput *)sourceOutput filters:(NSArray *)filters to:(id <GPUImageInput>)inputTarget enhance:(BOOL)enhance;

- (void)clearOutputChain:(NSArray *)chain;

- (UIImage *)buildOutputImageFromItem:(UIImage *)image item:(STFilterItem *)item enhance:(BOOL)enhance;

- (UIImage *)buildOutputImage:(UIImage *)image enhance:(BOOL)enhance filter:(STFilter *)currentFilter extendingFilters:(NSArray *)extendingFilters;

- (UIImage *)buildOutputImage:(UIImage *)image enhance:(BOOL)enhance filter:(STFilter *)currentFilter extendingFilters:(NSArray *)extendingFilters rotationMode:(GPUImageRotationMode)rotationMode;

- (UIImage *)buildOutputImage:(UIImage *)image enhance:(BOOL)enhance filter:(STFilter *)currentFilter extendingFilters:(NSArray *)extendingFilters rotationMode:(GPUImageRotationMode)rotationMode outputScale:(CGFloat)outputScale;

- (UIImage *)buildOutputImage:(UIImage *)image enhance:(BOOL)enhance filter:(STFilter *)currentFilter extendingFilters:(NSArray *)extendingFilters rotationMode:(GPUImageRotationMode)rotationMode outputScale:(CGFloat)outputScale useCurrentFrameBuffer:(BOOL)useCurrentFrameBuffer lockFrameRendering:(BOOL)lockFrameRendering;

- (UIImage *)buildOutputImage:(UIImage *)image enhance:(BOOL)enhance filter:(STFilter *)currentFilter extendingFilters:(NSArray *)extendingFilters rotationMode:(GPUImageRotationMode)rotationMode outputScale:(CGFloat)outputScale useCurrentFrameBuffer:(BOOL)useCurrentFrameBuffer;

- (STFilter *)enhanceFilter;

- (GPUImageFilterGroup *)tiltShiftFilter:(CGSize)sourceImageSize location:(CGPoint)point normalizedWidth:(CGFloat)width;

- (GPUImageFilterGroup *)tiltShiftFilterForFace:(CGSize)sourceImageSize normalizedFaceRect:(CGRect)faceRect;

- (M13OrderedDictionary *)getSampleFilteredImages:(NSUInteger)groupIndex productId:(NSString *)productId;
@end
