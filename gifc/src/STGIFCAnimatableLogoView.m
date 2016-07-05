//
// Created by BLACKGENE on 5/4/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFCAnimatableLogoView.h"
#import "SVGKFastImageView.h"
#import "SVGKFastImageView+STUtil.h"
#import "R.h"
#import "NSArray+STUtil.h"


@implementation STGIFCAnimatableLogoView{
    NSInteger _indicatingPhase;
}

- (void)createContent {
    [super createContent];

    SVGKFastImageView * part0 = [SVGKFastImageView viewWithImageNamed:[R logo_part_0] sizeWidth:self.width];
    SVGKFastImageView * part1 = [SVGKFastImageView viewWithImageNamed:[R logo_part_1] sizeWidth:self.width];
    SVGKFastImageView * part2 = [SVGKFastImageView viewWithImageNamed:[R logo_part_2] sizeWidth:self.width];

    [self addSubview:part0];
    [self addSubview:part1];
    [self addSubview:part2];

    [self stopIndicating];
}

- (void)startIndicating{
    _indicating = YES;
    _indicatingPhase = -1;

    [[self subviews] eachViewsWithIndex:^(UIView *view, NSUInteger index) {
        [UIView animateWithDuration:.3 delay:.15*index options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
            view.alpha = [STStandardUI alphaForDimmingGlass];
        } completion:nil];
    }];
}

- (void)stopIndicating{
    _indicating = NO;
    _indicatingPhase = -1;

    [[self subviews] eachViewsWithIndex:^(UIView *view, NSUInteger index) {
        [view.layer removeAllAnimations];
        view.alpha = 1;
    }];
}

- (void)prepareIndicating{
    _indicating = NO;
    _indicatingPhase = -1;

    [[self subviews] eachViewsWithIndex:^(UIView *view, NSUInteger index) {
        [view.layer removeAllAnimations];
        view.alpha = [STStandardUI alphaForDimmingWeak];
    }];
}

- (void)highlightIndicating {
    [self stopIndicating];

    [[self subviews] eachViewsWithIndex:^(UIView *view, NSUInteger index) {
        view.alpha = 0;
    }];
    [[self subviews] eachViewsWithIndex:^(UIView *view, NSUInteger index) {
        [UIView animateWithDuration:1 delay:.25*index options:UIViewAnimationOptionCurveLinear animations:^{
            view.alpha = 1;
        } completion:nil];
    }];
}

- (void)setProgress:(CGFloat)progress{
    if(progress==0){
        [self prepareIndicating];
        return;
    }
    if(progress==1){
        [self stopIndicating];
        return;
    }

    NSUInteger phase = 0;
    if(progress<=.3){}
    else if(progress<=.6){
        phase = 1;
    }else if(progress<1){
        phase = 2;
    }

    _indicating = NO;

    if(_indicatingPhase != phase){

        [[self subviews] eachViewsWithIndex:^(UIView *view, NSUInteger index) {
            if(progress>0 && phase==index){
                _indicating = YES;

                if(view.alpha==1){
                    view.alpha=[STStandardUI alphaForDimmingWeak];
                }
                [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
                    [view setAlpha:1];
                } completion:nil];

            }else if(index<phase){
                [view.layer removeAllAnimations];
                view.alpha = 1;

            }else{
                [view.layer removeAllAnimations];
                view.alpha = [STStandardUI alphaForDimmingWeak];
            }
        }];
    }

    _indicatingPhase = phase;
}

@end