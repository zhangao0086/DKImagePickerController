//
// Created by BLACKGENE on 2016. 1. 29..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STExporter;
@class STStandardButton;
@class STStandardReachableButton;
@class STExportContentView;

@interface STExportView : STUIView
@property (nonatomic, readonly) STStandardReachableButton *okButton;
@property (nonatomic, readonly) UIView *optionView;
@property (nonatomic, readonly) STExportContentView *contentView;

+ (void)open:(STStandardButton *)targetItemButton
      target:(STExporter *)exporter
  optionView:(UIView *)optionView
        cancelOptionsIcons:(NSArray *)cancelOptionIconNames
        cancelOptionSelected:(void (^)(STStandardButton *collecableButton, NSUInteger index))cancelOptionSelectedBlock
        willOpen:(void (^)(STExportView *))willOpenBlock
        didOpen:(void (^)(STExportView *))didOpenBlock
        tried:(void (^)(void))tried
        canceled:(void (^)(void))failedBlock
        willClose:(void (^)(BOOL))willCloseBlock
        didClose:(void (^)(BOOL))didClosedBlock;

+ (void)close:(BOOL)success;

+ (void)close:(BOOL)success finshed:(void (^)(void))block;

+ (void)enableGIFExport:(BOOL)enable;

+ (void)setProgress:(CGFloat)progress;

+ (void)startSpinProgressOfOkButton;

+ (void)stopSpinProgressOfOkButton;

+ (STExportView *)view;
@end
