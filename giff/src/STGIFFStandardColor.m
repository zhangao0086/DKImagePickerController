//
// Created by BLACKGENE on 5/3/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <UIColor+BFPaperColors/UIColor+BFPaperColors.h>
#import "STGIFFStandardColor.h"


@implementation STGIFFStandardColor {

}
- (UIColor *)foregroundColor {
    return UIColorFromRGB(0x9D96D4);
}

- (UIColor *)backgroundColor {
    return UIColorFromRGB(0x1B192B);
}

- (UIColor *)buttonColorFront {
    return self.foregroundColor;
}

- (UIColor *)buttonColorBack {
    return self.backgroundColor;
}

- (UIColor *)buttonColorForegroundAssistance {
    return UIColorFromRGB(0xFDFDFD);
}

- (UIColor *)buttonColorBackgroundAssistance; {
    return self.pointColorDarken;
}

- (UIColor *)buttonColorFrontSecondary; {
    return self.buttonColorForegroundAssistance;
}

- (UIColor *)buttonColorBackSecondary; {
    return self.buttonColorBackgroundAssistance;
}

- (UIColor *)buttonColorBackgroundOverlay {
    return self.buttonColorFront;
}

- (UIColor *)pointColor {
    return UIColorFromRGB(0xA44EFF);
}

- (UIColor *)pointColorDarken {
    //0xa999b2
    return UIColorFromRGB(0x863ED3);
}

- (UIColor *)pointColorLighten {
    return self.pointColor;
}

- (UIColor *)strokeColorProgressBackground {
    return [UIColor clearColor];
}

- (UIColor *)negativeColor {
    return UIColorFromRGB(0xffceee);
}

- (UIColor *)blankBackgroundColor {

    return UIColorFromRGB(0xccd3d9);
}

- (UIColor *)blankObjectColor {
    return UIColorFromRGB(0xe9e9e9);
}

+ (UIColor *)frameEditHighlightColor {
    static UIColor * _frameEditHighlightColor;
    BlockOnce(^{
        _frameEditHighlightColor = [STStandardUI iOSSystemCameraHighlightColor];
    });
    return _frameEditHighlightColor;
}


@end