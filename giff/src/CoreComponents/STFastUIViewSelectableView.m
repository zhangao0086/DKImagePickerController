//
// Created by BLACKGENE on 7/27/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STFastUIViewSelectableView.h"
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
        [view st_eachSubviews:^(UIView *_view, NSUInteger index) {
            _view.visible = [object isEqual:_view];
        }];
    }else{
        [super setButtonDrawable:view set:object];
    }
}

@end