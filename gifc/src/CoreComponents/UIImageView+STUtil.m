//
// Created by BLACKGENE on 15. 11. 17..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "UIImageView+STUtil.h"


@implementation UIImageView (STUtil)

+ (UIImageView *)viewIfNot:(UIImageView *)instance image:(UIImage *)image;{
    if(!instance){
        return [[UIImageView alloc] initWithImage:image];
    }

    instance.image = image;
    return instance;
}

@end