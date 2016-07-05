//
// Created by BLACKGENE on 4/30/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCapturedImageSet.h"

@interface STCapturedImageSet()
@property (nonatomic, assign) NSUInteger indexOfDefaultImage;
@property (nonatomic, assign) NSUInteger indexOfFocusPointsOfInterestSet;
@property (nonatomic, readwrite) NSArray * focusPointsOfInterestSet;
@property (nonatomic, assign) CGSize outputSizeForFocusPoints;

@property(nonatomic, assign) STCapturedImageSetType type;
@end