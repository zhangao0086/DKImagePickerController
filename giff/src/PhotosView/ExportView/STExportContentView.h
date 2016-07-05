//
// Created by BLACKGENE on 2016. 2. 2..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STExportView.h"
#import "STExporter.h"

@interface STExportContentView : STUIView
@property (nonatomic, readonly) UIView *iconImageViewContainer;
@property (nonatomic, readwrite) STExporter *exporter;

- (void)loadContents;

- (void)unloadContents;

- (void)loadContentsLazily;

- (void)unloadContentsLazily:(void(^)(BOOL finished))block;

- (void)reloadContents;
@end