//
// Created by BLACKGENE on 7/27/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STFastUIViewSelectableView.h"


@interface STSelectableView ()
- (void)setButtonDrawable:(UIImageView *)view set:(id)object;
@end

@implementation STFastUIViewSelectableView {

}
- (void)setButtonDrawable:(UIImageView *)view set:(id)object{
    if([object isKindOfClass:UIView.class]){
        if(![[view subviews] containsObject:object]){
            [view addSubview:object];
        }else{
            [view bringSubviewToFront:object];
        }
    }else{
        [super setButtonDrawable:view set:object];
    }
}

@end