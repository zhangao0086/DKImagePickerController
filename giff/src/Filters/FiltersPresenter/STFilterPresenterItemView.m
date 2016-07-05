//
// Created by BLACKGENE on 2014. 10. 3..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import "STFilterPresenterItemView.h"
#import "STFilterItem.h"
#import "TTTAttributedLabel.h"
#import "UIView+STUtil.h"

@implementation STFilterPresenterItemView {
    GPUImageView * _gpuView;
    TTTAttributedLabel * _debugFilterInfoLabel;
}

+ (GPUImageFillModeType)fillMode; {
    return kGPUImageFillModePreserveAspectRatioAndFill;
}

- (void)usingGPUImage {
    if(!_gpuView){
        _gpuView = [[GPUImageView alloc] init];
        _gpuView.fillMode = [STFilterPresenterItemView fillMode];
        [self insertSubview:_gpuView atIndex:0];
    }
}

- (void)layoutSubviews; {
    [super layoutSubviews];
    [_gpuView setFrame:self.bounds];

    [self setTargetFilterItem:_targetFilterItem];
}

- (void)describeFilterInfoForDebug:(STFilterItem *)filterItem {
    if(filterItem){
        if(!_debugFilterInfoLabel){
            _debugFilterInfoLabel = [[TTTAttributedLabel alloc] initWithSizeWidth:[self st_subviewsUnionFrame].size.width];
            _debugFilterInfoLabel.font = [STStandardUI defaultFontForLabel];
            _debugFilterInfoLabel.textColor = [STStandardUI textColorLighten];
            _debugFilterInfoLabel.lineBreakMode = NSLineBreakByClipping;
            _debugFilterInfoLabel.userInteractionEnabled = NO;
            _debugFilterInfoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _debugFilterInfoLabel.textAlignment = NSTextAlignmentCenter;
            _debugFilterInfoLabel.numberOfLines = 1;
            [self addSubview:_debugFilterInfoLabel];
        }

        _debugFilterInfoLabel.text = [NSString stringWithFormat:@"%d, %@, %d",filterItem.indexOfColor,filterItem.uid_short, filterItem.type];
        [_debugFilterInfoLabel sizeToFit];
        [_debugFilterInfoLabel centerToParentHorizontal];
        _debugFilterInfoLabel.bottom = self.height;

    }else{
        [_debugFilterInfoLabel removeFromSuperview];
        _debugFilterInfoLabel = nil;
    }
}

- (void)removeFromSuperview {
    self.image = nil;
    [super removeFromSuperview];
}


- (void)dealloc; {
    self.image = nil;
    
    [_gpuView removeFromSuperview];
    _gpuView = nil;
}

@end