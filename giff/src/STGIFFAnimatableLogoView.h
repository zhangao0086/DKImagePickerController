//
// Created by BLACKGENE on 5/4/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface STGIFFAnimatableLogoView : STUIView

@property (nonatomic, readonly) BOOL indicating;

- (void)startIndicating;

- (void)stopIndicating;

- (void)prepareIndicating;

- (void)highlightIndicating;

- (void)setProgress:(CGFloat)progress;
@end