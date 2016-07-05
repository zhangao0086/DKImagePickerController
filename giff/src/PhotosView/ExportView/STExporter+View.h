//
// Created by BLACKGENE on 2016. 4. 5..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STExporter.h"

@class STExporterViewSelectionOptionItem;
@class STStandardButton;

typedef void (^ STExporterViewOptionCancelHandler)(NSUInteger);

@interface STExporterViewOption : STItem
@property (nonatomic, readwrite, nullable) STStandardButton * relatedButton;
@property (nonatomic, readwrite, nullable) NSArray *exportOptionItems;
@property (nonatomic, assign) NSUInteger selectedExportOptionIndex;
@property (nonatomic, readwrite, nullable) NSArray *cancelIconImageNames;
@property (nonatomic, copy, nullable) STExporterViewOptionCancelHandler cancelHandler;
@property (nonatomic, assign) BOOL exportingGIFButtonDisabled;
@end

@interface STExporterViewSelectionOptionItem : STItem
@property (nonatomic, readwrite, nullable) NSString *label;
@property (nonatomic, readwrite, nullable) NSURL *thumbnailAsURL;
@property (nonatomic, readwrite, nullable) UIImage *thumbnailAsImage;
@property (nonatomic, readwrite, nullable) NSString *thumbnailAsImageName;
@end

@interface STExporter (View)
@property (nonatomic, readonly, nullable) STExporterViewSelectionOptionItem * selectedOptionItem;

- (void)openExporterView:(void (^)(void))tryExportBlock;

- (void)openExporterView:(STExporterViewOption *)option
               tryExport:(void (^)(void))tryExportBlock;

- (void)exportAndPresentGIFsInView:(BOOL)export
                          progress:(void (^)(CGFloat))progressBlock
                        completion:(void (^)(NSArray *gifURLs, NSArray *succeedItems, NSArray *errorItems))completionBlock;
@end
