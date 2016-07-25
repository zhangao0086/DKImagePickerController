//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STEditControlView.h"
#import "STStandardButton.h"
#import "R.h"


@implementation STEditControlView {
    STStandardButton *_backButton;

    STStandardButton *_exportButton;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
    }

    return self;
}

- (void)createContent {
    [super createContent];

    [self createEditControls];
    [self createEffectSelector];
    [self createSourceControls];

    CGFloat padding = [STStandardLayout widthSubAssistance];

    [self addSubview:_backButton];
    _backButton.x = padding;
    _backButton.bottom = self.height - padding;

    [self addSubview:_exportButton];
    _exportButton.right = self.width-padding;
    _exportButton.bottom = self.height-padding;
}

- (void)createEffectSelector {

}

- (void)createEditControls {

}


- (void)createSourceControls {

    //left button
    _backButton = [STStandardButton subSmallSize];
    _backButton.preferredIconImagePadding = self.height/4;
    [_backButton setButtons:@[[R set_info_indicator_bullet]] colors:nil];
    [_backButton whenSelected:^(STSelectableView *selectedView, NSInteger index) {

    }];

    //right button
    _exportButton = [STStandardButton subSmallSize];
    _exportButton.allowSelectAsTap = YES;
    _exportButton.preferredIconImagePadding = self.height/4;
    [_exportButton setButtons:@[[R go_roll]] colors:nil];
    [_exportButton whenSelected:^(STSelectableView *selectedView, NSInteger index) {

    }];
}

@end