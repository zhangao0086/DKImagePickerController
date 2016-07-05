//
// Created by BLACKGENE on 2015. 3. 19..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "STStandardButton.h"


@interface STStandardCollectableButton : STStandardButton
@property (nonatomic, assign) NSUInteger currentCollectableIndex;
@property (nonatomic, readonly) STStandardButton *currentCollectableButton;
@property (nonatomic, assign) BOOL collectablesUserInteractionEnabled;
@property (nonatomic, assign) BOOL collectablesSelectAsIndependent;
@property (nonatomic, assign) BOOL collectableSelectedState;
@property (nonatomic, assign) BOOL collectableToggleEnabled;
@property (nonatomic, assign) BOOL synchronizeCollectableSelection;
@property (nonatomic, assign) BOOL autoUXLayoutWhenExpanding;
@property (nonatomic, assign) BOOL autoRetractWhenSelectCollectableItem;

+ (instancetype)setButtonsWithCollectables:(NSArray *)imageNames size:(CGSize)buttonSize colllectableIcons:(NSArray *)colllectableIcons colllectableSize:(CGSize)radialSize maskColors:(NSArray *)colors;

+ (instancetype)setButtonsWithCollectables:(NSArray *)imageNames size:(CGSize)buttonSize colllectableIcons:(NSArray *)colllectableIcons colllectableSize:(CGSize)radialSize maskColors:(NSArray *)colors bgColors:(NSArray *)bgColors;

- (instancetype)setButtonsWithCollectables:(NSArray *)imageNames size:(CGSize)buttonSize colllectableIcons:(NSArray *)colllectableIcons colllectableSize:(CGSize)radialSize maskColors:(NSArray *)colors bgColors:(NSArray *)bgColors;

- (instancetype)setCollectablesAsDefault:(NSArray *)imageNames;

- (instancetype)setCollectables:(NSArray *)imageNames colors:(NSArray *)colors size:(CGSize)size;

- (instancetype)setCollectables:(NSArray *)imageNames colors:(NSArray *)colors bgColors:(NSArray *)bgColors size:(CGSize)size;

- (instancetype)setCollectables:(NSArray *)imageNames colors:(NSArray *)colors bgColors:(NSArray *)bgColors size:(CGSize)size style:(STStandardButtonStyle)style;

- (void)whenCollectableSelected:(void (^)(STStandardButton *collectaleButton, NSUInteger index))block;

@end