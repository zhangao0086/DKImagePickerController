//
// Created by BLACKGENE on 2015. 7. 29..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STUIView.h"


@interface STUIContentAlignmentView : STUIView
@property (nonatomic, readwrite) UIView *contentView;
@property (nonatomic, assign) UIEdgeInsets contentViewInsets;
@property (nonatomic, assign) UIControlContentHorizontalAlignment contentViewHorizontalAlignment;
@property (nonatomic, assign) UIControlContentVerticalAlignment contentViewVerticalAlignment;
@end