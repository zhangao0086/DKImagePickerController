//
// Created by BLACKGENE on 2015. 7. 29..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STUIContentAlignmentView.h"
#import "NSString+STUtil.h"
#import "UIView+STUtil.h"

@implementation STUIContentAlignmentView {
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.touchInsidePolicy = STUIViewTouchInsidePolicyContentInside;
    }
    return self;
}

- (void)dealloc {
    oo([@"dealloc _ " st_add:@"STControlBoardItemCellView"]);
    self.contentView = nil;
}

- (void)setContentView:(UIView *)contentView {
    if(![_contentView isEqual:contentView]){
        [_contentView removeFromSuperview];
        if((_contentView = contentView)){
            [self addSubview:contentView];
        }
    }
}

- (void)createContent {
    if(_contentView && !_contentView.superview){
        [self addSubview:_contentView];
    }
    [super createContent];

}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect bounds = self.bounds;
    CGRect contentViewBounds = self.contentView.bounds;
    CGPoint isCenter = CGPointZero;
    CGPoint isFill = CGPointZero;

    switch(self.contentViewHorizontalAlignment){
        case UIControlContentHorizontalAlignmentCenter:
            isCenter.x = 1;
            break;
        case UIControlContentHorizontalAlignmentLeft:
            contentViewBounds.origin.x = 0;
            break;
        case UIControlContentHorizontalAlignmentRight:
            contentViewBounds.origin.x = bounds.size.width-contentViewBounds.size.width;
            break;
        case UIControlContentHorizontalAlignmentFill:
            contentViewBounds.size.width = bounds.size.width;
            isFill.x = 1;
            break;
    }

    switch(self.contentViewVerticalAlignment){
        case UIControlContentVerticalAlignmentCenter:
            isCenter.y = 1;
            break;
        case UIControlContentVerticalAlignmentTop:
            contentViewBounds.origin.y = 0;
            break;
        case UIControlContentVerticalAlignmentBottom:
            contentViewBounds.origin.y = bounds.size.height-contentViewBounds.size.height;
            break;
        case UIControlContentVerticalAlignmentFill:
            contentViewBounds.size.height = bounds.size.height;
            isFill.y = 1;
            break;
    }

    //position
    if(isCenter.x==1 && isCenter.y==1){
        [self.contentView centerToParent];

    }else if(isCenter.x==1){
        [self.contentView centerToParentHorizontal];
        self.contentView.y = contentViewBounds.origin.y;

    }else if(isCenter.y==1){
        [self.contentView centerToParentVertical];
        self.contentView.x = contentViewBounds.origin.x;

    }else{
        self.contentView.origin = contentViewBounds.origin;
    }

    //size if auto resize none
    if(!self.contentView.autoresizesSubviews || !self.contentView.autoresizingMask==UIViewAutoresizingNone){
        if(isFill.x==1 && isFill.y==1){
            self.contentView.size = contentViewBounds.size;

        }else if(isFill.x==1){
            self.contentView.size = CGSizeMake(contentViewBounds.size.width, self.contentView.size.height);

        }else if(isFill.y==1){
            self.contentView.size = CGSizeMake(self.contentView.size.width, contentViewBounds.size.height);
        }
    }

    //apply edge inset
    if(!UIEdgeInsetsEqualToEdgeInsets(_contentViewInsets, UIEdgeInsetsZero)){
        self.contentView.frame = UIEdgeInsetsInsetRect(self.contentView.frame, _contentViewInsets);
    }
}

@end