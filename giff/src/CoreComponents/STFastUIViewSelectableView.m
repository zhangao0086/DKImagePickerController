//
// Created by BLACKGENE on 7/27/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STFastUIViewSelectableView.h"
#import "NSArray+STUtil.h"
#import "UIView+STUtil.h"


@interface STSelectableView ()
- (void)setButtonDrawable:(UIImageView *)view set:(id)object;
@end

@implementation STFastUIViewSelectableView {

}
- (void)setButtonDrawable:(UIImageView *)view set:(id)object{
    if([object isKindOfClass:UIView.class]){
        if(![[view subviews] containsObject:object]){
            [view addSubview:object];
        }
        [[view subviews] eachViewsWithIndex:^(UIView *v, NSUInteger index) {
            [v isEqual:object] ? [v unlockVisible] : [v lockVisibleToHide];
        }];
    }else{
        [super setButtonDrawable:view set:object];
    }
}

@end