//
// Created by BLACKGENE on 2014. 9. 11..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import "STMenuItemView.h"

@implementation STMenuItemView {
    UIImageView * _imageView;
}

- (id)initWithFrame:(CGRect)frame; {
    self = [super initWithFrame:frame];
    if (self) {

        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.fillColor = self.tintColor.CGColor;
        layer.strokeColor = self.tintColor.CGColor;
        layer.lineWidth = 1;
        layer.opacity = 1.0;
        layer.shouldRasterize = YES;
        layer.rasterizationScale = [UIScreen mainScreen].scale;
        layer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.bounds.size.width/2].CGPath;

        [self.layer addSublayer:layer];

    }
    return self;
}

- (void)setIconImage:(UIImage *)image{
    if(!_imageView){
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.contentMode = UIViewContentModeScaleAspectFit | UIViewContentModeCenter;
        [self addSubview:_imageView];
        _imageView.centerX = self.width/2;
        _imageView.centerY = self.height/2;
    }
    _imageView.image = image;
}

@end