//
// Created by BLACKGENE on 2014. 9. 11..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STSegmentedSliderView.h"


@interface STStandardSegmentationSelector : STSegmentedSliderView <STSegmentedSliderControlDelegate>
@property (nonatomic, assign) BOOL rollingThumbAnimationEnabled;
@property (nonatomic, assign) BOOL multipleSelection;

- (void)setSegmentationViewsFromButtons:(NSArray *)buttons;

- (void)setSegmentationsForSelector:(NSArray *)imageNames maskColors:(NSArray *)colors;

- (void)setSegmentationsForSlider:(NSArray *)imageNames maskColors:(NSArray *)colors;

- (void)deselectStateAll;
@end