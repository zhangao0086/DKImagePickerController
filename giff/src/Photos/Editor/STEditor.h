//
// Created by BLACKGENE on 2015. 1. 27..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STPhotoItem;
@class STEditorResult;
@class STEditorCommand;

typedef NS_ENUM(NSInteger, STPreviewEditorToolCommand) {
    STPreviewEditorToolCommandRotation
};

@protocol STEditor <NSObject>
@required
- (void)open:(UIImage *)targetImage view:(UIView *)view;
- (void)reset;
- (STEditorResult *)apply;
- (void)applyAsync:(void(^)(STEditorResult *))block;
- (void)dismiss;
- (BOOL)isOpened;
- (BOOL)isModified;
@optional
- (BOOL)command:(STEditorCommand *)command;
@end