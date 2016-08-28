//
// Created by BLACKGENE on 5/3/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <UIColor+BFPaperColors/UIColor+BFPaperColors.h>
#import "STGIFFStandardColor.h"


@implementation STGIFFStandardColor {

}
- (UIColor *)foregroundColor {
    return nil;
}

- (UIColor *)backgroundColor {
    return UIColorFromRGB(0xe6e6e6);
}

- (UIColor *)buttonColorFront {
    return UIColorFromRGB(0xeffbff);
}

- (UIColor *)buttonColorBack {
    return [UIColor paperColorGray50];
}

//collectable backgroud
- (UIColor *)buttonColorBackgroundAssistance; {
    return [self buttonColorBack];
}

//collectable icon color
- (UIColor *)buttonColorForegroundAssistance {
    return [self pointColorLighten];
}

- (UIColor *)buttonColorFrontSecondary; {
    return [UIColor paperColorGray200];
}

- (UIColor *)buttonColorBackSecondary; {
    return self.pointColor;
}

- (UIColor *)pointColor {
    return UIColorFromRGB(0xD7DAFF);
}

- (UIColor *)pointColorDarken {
    //0xa999b2
    return UIColorFromRGB(0x8a7e90);
}

- (UIColor *)pointColorLighten {
    return UIColorFromRGB(0xD7DAFF);
}

//+ (UIColor *)strokeColorProgressFront {
//    return [self pointColor];
//}

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