//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STExportControlView.h"
#import "STExportSelectView.h"
#import "UIView+STUtil.h"
#import "STStandardButton.h"
#import "R.h"
#import "iCarousel.h"
#import "STCarouselController.h"
#import "STPhotoSelector.h"
#import "STMainControl.h"

@implementation STExportControlView {
    STStandardButton *_backButton;
    STExportSelectView * _exportSelectView;

}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        CGFloat padding = [STStandardLayout widthBullet];

        //left button
        _backButton = [STStandardButton subSmallSize];
        _backButton.preferredIconImagePadding = _backButton.height/4;
        [_backButton setButtons:@[[R go_back]] style:STStandardButtonStylePTTP];
        [_backButton whenSelected:^(STSelectableView *selectedView, NSInteger index) {
            [[STMainControl sharedInstance] back];
        }];
        _backButton.x = padding;
        _backButton.bottom = self.height - padding;

        //export view
        _exportSelectView = [[STExportSelectView alloc] initWithSize:CGSizeMake(self.width, self.height - (_backButton.height + padding *2))];
    }

    return self;
}

- (void)setExporterTypes:(NSArray *)exporterTypes {
    _exportSelectView.exporterTypes = exporterTypes;

    
    [[STMainControl sharedInstance] tryExportByType:STExportTypeShare];
}

- (NSArray *)exporterTypes {
    return _exportSelectView.exporterTypes;
}

- (void)createContent {
    [super createContent];

    [self addSubview:_backButton];
    [self addSubview:_exportSelectView];
}

@end