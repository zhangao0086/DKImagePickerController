//
// Created by BLACKGENE on 2014. 10. 30..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STSelectableView.h"

@class STStandardButton;
@class STStandardButton;
@class STStandardNavigationButton;


@interface STSubControl : STUIView <STSeletableViewDelegate>

@property (nonatomic, readonly) STStandardButton *leftButton;
@property (nonatomic, readonly) STStandardButton *rightButton;

- (void)layoutSubviewsByMode:(STControlDisplayMode)mode previousMode:(STControlDisplayMode)previousMode;

- (void)setVisibleWithEffect:(BOOL)visible effect:(STSubControlVisibleEffect)effect;

- (void)setVisibleWithEffect:(BOOL)visible effect:(STSubControlVisibleEffect)effect relationView:(UIView *)view completion:(void (^)(POPAnimation *anim, BOOL finished))completion;

- (void)setBadgeToLeft:(NSString *)text mode:(STControlDisplayMode)mode;

- (void)setBadgeToRight:(NSString *)text mode:(STControlDisplayMode)mode;

- (void)resetBadgeNumberToRight;

- (void)incrementBadgeNumberToRight:(STControlDisplayMode)mode;

- (void)expandCollectablesContextNeeded;

- (void)retractCollectablesContextNeeded;

- (void)setNeedsStateByCurrentModeIfNeeded;

@end