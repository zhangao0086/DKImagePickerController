//
// Created by BLACKGENE on 8/11/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <GPUImage/GPUImageOutput.h>
#import "STGIFFDisplayLayerProcessingComposersEffect.h"
#import "STFilterManager.h"
#import "STGPUImageOutputComposeItem.h"


@implementation STGIFFDisplayLayerProcessingComposersEffect {

}

- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    NSArray * composers = sourceImages.count==1 ? [self composersToProcessSingle:sourceImages[0]] : [self composersToProcessMultiple:sourceImages];

    if(composers.count){
        return [self processImagesAsComposers:composers];
    }else{
        return [super processImages:sourceImages];
    }
}

- (UIImage *__nullable)processImagesAsComposers:(NSArray<STGPUImageOutputComposeItem *> *__nullable)composers {
    if(composers.count){
        return [[[STFilterManager sharedManager] buildTerminalOutputToComposeMultiSource:composers forInput:nil] imageFromCurrentFramebuffer];
    }else{
        return nil;
    }
}

- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {
    return nil;
}

- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage {
    return nil;
}
@end