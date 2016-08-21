//
// Created by BLACKGENE on 8/21/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerEffectSharedUtil.h"
#import "LEColorPicker.h"


@implementation STGIFFDisplayLayerEffectSharedUtil {

}

+ (LEColorPicker *)colorPicker {
    static LEColorPicker * colorPicker;
    BlockOnce(^{
        colorPicker = LEColorPicker.new;
    })
    return colorPicker;
}

@end