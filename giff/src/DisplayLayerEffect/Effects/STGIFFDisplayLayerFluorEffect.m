//
// Created by BLACKGENE on 7/20/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerFluorEffect.h"
#import "GPUImageChromaKeyBlendFilter.h"
#import "GPUImagePicture.h"
#import "UIColor+BFPaperColors.h"
#import "Colours.h"
#import "GPUImageSoftLightBlendFilter.h"
#import "GPUImageTransformFilter.h"
#import "STFilter.h"
#import "STFilterManager.h"
#import "UIImage+STUtil.h"
#import "STGPUImageOutputComposeItem.h"
#import "GPUImageRGBFilter+STGPUImageFilter.h"
#import "NYXImagesKit.h"
#import "UIImage+ImageEffects.h"

// chroma key black / white -> add

@implementation STGIFFDisplayLayerFluorEffect {

}


- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {
    @autoreleasepool {
        NSMutableArray * composers = [NSMutableArray array];

//        //0
        STGPUImageOutputComposeItem * composeItem0 = [STGPUImageOutputComposeItem new];
        composeItem0.source = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:NO];
        composeItem0.composer = [[GPUImageLightenBlendFilter alloc] init];

        GPUImageBrightnessFilter * brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
        brightnessFilter.brightness = -.5f;

        GPUImageSaturationFilter * saturationFilter = [[GPUImageSaturationFilter alloc] init];
        saturationFilter.saturation = .4;

        composeItem0.filters = @[
                brightnessFilter
                ,saturationFilter
        ];
        [composers addObject:composeItem0];

        //1
        STGPUImageOutputComposeItem * composeItem1 = [STGPUImageOutputComposeItem new];
        GPUImageSobelEdgeDetectionFilter * edgeDetectionFilter = [[GPUImageSobelEdgeDetectionFilter alloc] init];
        edgeDetectionFilter.edgeStrength = 1.5f;

        GPUImageContrastFilter * contrastFilter = GPUImageContrastFilter.new;
        contrastFilter.contrast = 3.0;

        GPUImageTransformFilter * scaleFilter2 = [[GPUImageTransformFilter alloc] init];
//        scaleFilter2.affineTransform = CGAffineTransformMakeTranslation(-0.01f,0);
//        scaleFilter2.affineTransform = CGAffineTransformScale(scaleFilter2.affineTransform, 1.11f,1.11f);

//        composeItem1.composer = [[GPUImageLightenBlendFilter alloc] init];
        composeItem1.source = [[GPUImagePicture alloc] initWithImage:sourceImages[1] smoothlyScaleOutput:YES];
        composeItem1.filters = @[
                edgeDetectionFilter
                ,contrastFilter
                , [GPUImageRGBFilter rgbColor:UIColorFromRGB(0xffffff)]
//                ,scaleFilter2
        ];
        [composers addObject:composeItem1];


//        //2
//        STGPUImageOutputComposeItem * composeItem2 = [STGPUImageOutputComposeItem new];
//        GPUImageSobelEdgeDetectionFilter * edgeDetectionFilter2 = [[GPUImageSobelEdgeDetectionFilter alloc] init];
//        edgeDetectionFilter2.edgeStrength = 2;
//
//        GPUImageContrastFilter * contrastFilter2 = GPUImageContrastFilter.new;
//        contrastFilter2.contrast = 3.0;
//
//        GPUImageTransformFilter * scaleFilter3 = [[GPUImageTransformFilter alloc] init];
//        scaleFilter3.affineTransform = CGAffineTransformMakeTranslation(-0.01f,0);
//        scaleFilter3.affineTransform = CGAffineTransformScale(scaleFilter2.affineTransform, 1.11f,1.11f);
//
//        composeItem1.composer = [[GPUImageLightenBlendFilter alloc] init];
//        composeItem2.source = [[GPUImagePicture alloc] initWithImage:sourceImages[1] smoothlyScaleOutput:YES];
//        composeItem2.filters = @[
//                edgeDetectionFilter2
//                ,contrastFilter2
//                ,[GPUImageRGBFilter filterWithColor:UIColorFromRGB(0x00ff00)]
//                ,scaleFilter3
//        ];
//        [composers addObject:composeItem2];
//
//        //3
//        STGPUImageOutputComposeItem * composeItem3 = [STGPUImageOutputComposeItem new];
//        GPUImageSobelEdgeDetectionFilter * edgeDetectionFilter3 = [[GPUImageSobelEdgeDetectionFilter alloc] init];
//        edgeDetectionFilter3.edgeStrength = 2;
//
//        GPUImageContrastFilter * contrastFilter3 = GPUImageContrastFilter.new;
//        contrastFilter3.contrast = 3.0;
//
//        GPUImageTransformFilter * scaleFilter4 = [[GPUImageTransformFilter alloc] init];
//        scaleFilter4.affineTransform = CGAffineTransformMakeTranslation(0.02f,0);
//        scaleFilter4.affineTransform = CGAffineTransformScale(scaleFilter2.affineTransform, 1.115f,1.115f);
//
////        composeItem1.composer = [[GPUImageLightenBlendFilter alloc] init];
//        composeItem3.source = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:YES];
//        composeItem3.filters = @[
//                edgeDetectionFilter3
//                ,contrastFilter3
//                ,[GPUImageRGBFilter filterWithColor:UIColorFromRGB(0x0000ff)]
//                ,scaleFilter4
//        ];
//        [composers addObject:composeItem3];

////        //2
//        STGPUImageOutputComposeItem * composeItem3 = STGPUImageOutputComposeItem.new;
//        composeItem3.source = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:YES];
//        composeItem3.filters = @[
////                scaleFilter2
//        ];
//        [composers addObject:composeItem3];

        return [composers reverse];//[image gaussianBlurWithBias:255];
    }
}

- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage {
    @autoreleasepool {
        NSMutableArray * composers = [NSMutableArray array];

//        //0
        STGPUImageOutputComposeItem * composeItem0 = [STGPUImageOutputComposeItem new];
        composeItem0.source = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:NO];
        composeItem0.composer = [[GPUImageLightenBlendFilter alloc] init];

        GPUImageBrightnessFilter * brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
        brightnessFilter.brightness = -.5f;
        composeItem0.filters = @[
                brightnessFilter
        ];
        [composers addObject:composeItem0];

        //1
        STGPUImageOutputComposeItem * composeItem1 = [STGPUImageOutputComposeItem new];
        GPUImageSobelEdgeDetectionFilter * edgeDetectionFilter = [[GPUImageSobelEdgeDetectionFilter alloc] init];
        edgeDetectionFilter.edgeStrength = 1.5f;

        GPUImageContrastFilter * contrastFilter = GPUImageContrastFilter.new;
        contrastFilter.contrast = 3.0;

        GPUImageTransformFilter * scaleFilter2 = [[GPUImageTransformFilter alloc] init];
//        scaleFilter2.affineTransform = CGAffineTransformMakeTranslation(-0.01f,0);
//        scaleFilter2.affineTransform = CGAffineTransformScale(scaleFilter2.affineTransform, 1.11f,1.11f);

//        composeItem1.composer = [[GPUImageLightenBlendFilter alloc] init];
        composeItem1.source = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:YES];
        composeItem1.filters = @[
                edgeDetectionFilter
                ,contrastFilter
                , [GPUImageRGBFilter rgbColor:UIColorFromRGB(0xffffff)]
//                ,scaleFilter2
        ];
        [composers addObject:composeItem1];


//        //2
//        STGPUImageOutputComposeItem * composeItem2 = [STGPUImageOutputComposeItem new];
//        GPUImageSobelEdgeDetectionFilter * edgeDetectionFilter2 = [[GPUImageSobelEdgeDetectionFilter alloc] init];
//        edgeDetectionFilter2.edgeStrength = 2;
//
//        GPUImageContrastFilter * contrastFilter2 = GPUImageContrastFilter.new;
//        contrastFilter2.contrast = 3.0;
//
//        GPUImageTransformFilter * scaleFilter3 = [[GPUImageTransformFilter alloc] init];
//        scaleFilter3.affineTransform = CGAffineTransformMakeTranslation(-0.01f,0);
//        scaleFilter3.affineTransform = CGAffineTransformScale(scaleFilter2.affineTransform, 1.11f,1.11f);
//
//        composeItem1.composer = [[GPUImageLightenBlendFilter alloc] init];
//        composeItem2.source = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:YES];
//        composeItem2.filters = @[
//                edgeDetectionFilter2
//                ,contrastFilter2
//                ,[GPUImageRGBFilter filterWithColor:UIColorFromRGB(0x00ff00)]
//                ,scaleFilter3
//        ];
//        [composers addObject:composeItem2];
//
//        //3
//        STGPUImageOutputComposeItem * composeItem3 = [STGPUImageOutputComposeItem new];
//        GPUImageSobelEdgeDetectionFilter * edgeDetectionFilter3 = [[GPUImageSobelEdgeDetectionFilter alloc] init];
//        edgeDetectionFilter3.edgeStrength = 2;
//
//        GPUImageContrastFilter * contrastFilter3 = GPUImageContrastFilter.new;
//        contrastFilter3.contrast = 3.0;
//
//        GPUImageTransformFilter * scaleFilter4 = [[GPUImageTransformFilter alloc] init];
//        scaleFilter4.affineTransform = CGAffineTransformMakeTranslation(0.02f,0);
//        scaleFilter4.affineTransform = CGAffineTransformScale(scaleFilter2.affineTransform, 1.115f,1.115f);
//
////        composeItem1.composer = [[GPUImageLightenBlendFilter alloc] init];
//        composeItem3.source = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:YES];
//        composeItem3.filters = @[
//                edgeDetectionFilter3
//                ,contrastFilter3
//                ,[GPUImageRGBFilter filterWithColor:UIColorFromRGB(0x0000ff)]
//                ,scaleFilter4
//        ];
//        [composers addObject:composeItem3];

////        //2
//        STGPUImageOutputComposeItem * composeItem3 = STGPUImageOutputComposeItem.new;
//        composeItem3.source = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:YES];
//        composeItem3.filters = @[
////                scaleFilter2
//        ];
//        [composers addObject:composeItem3];

        return [composers reverse];//[image gaussianBlurWithBias:255];
    }
}

 
@end