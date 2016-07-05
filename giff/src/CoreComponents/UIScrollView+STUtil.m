//
// Created by BLACKGENE on 2016. 1. 8..
// Copyright (c) 2016 stells. All rights reserved.
//

#import "UIScrollView+STUtil.h"


@implementation UIScrollView (STUtil)

- (void)contentOffsetsToCenter{
    self.contentOffset = CGPointMake((self.contentSize.width - self.bounds.size.width)/2,(self.contentSize.height - self.bounds.size.height)/2);
}

- (void)contentViewToCenter:(UIView *)subview{
    CGFloat offsetX = (CGFloat) MAX((self.bounds.size.width - self.contentSize.width) * 0.5f, 0.0);
    CGFloat offsetY = (CGFloat) MAX((self.bounds.size.height - self.contentSize.height) * 0.5f, 0.0);
    subview.center = CGPointMake(self.contentSize.width * 0.5f + offsetX, self.contentSize.height * 0.5f + offsetY);
}
@end