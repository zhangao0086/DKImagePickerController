//
// Created by BLACKGENE on 2015. 4. 3..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STStandardCollectableButton.h"

typedef STStandardButton *(^STStandardNavigationButtonCreateBackgroundBlock)(STStandardButton * __weak Self, NSArray * colors);

@interface STStandardNavigationButton : STStandardCollectableButton
@property(nonatomic, copy, nullable) STStandardNavigationButtonCreateBackgroundBlock collectableBackgroundCreateBlock;
@property(nonatomic, assign) CGFloat alphaCollectableBackground;
@property(nonatomic, assign) BOOL shadowEnabledCollectableBackground;
@property(nonatomic, assign) BOOL invertMaskInButtonAreaForCollectableBackground;
@property(nonatomic, assign) CGFloat shadowOffsetCollectableBackground;
@property(nonatomic, assign) CGFloat progressCollectableBackground;

+ (UIColor *)defaultCollectableBackgroundImageColor;

+ (UIColor *)defaultCollectableForegroundImageColor;

- (instancetype)setCollectables:(NSArray *)imageNames colors:(NSArray *)colors bgColors:(NSArray *)bgColors size:(CGSize)size style:(STStandardButtonStyle)style backgroundStyle:(STStandardButtonStyle)backgroundStyle;

- (instancetype)setCollectablesAsButtons:(NSArray *)buttons;

- (instancetype)setCollectablesAsButtons:(NSArray *)buttons backgroundStyle:(STStandardButtonStyle)backgroundStyle;
@end