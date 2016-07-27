//
// Created by BLACKGENE on 7/27/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImageSetDisplayProcessor+GPUImage.h"
#import <GPUImage/GPUImageOutput.h>
#import "STCapturedImageSetDisplayLayerSet.h"
#import "STMultiSourcingImageProcessor.h"
#import "NSArray+STUtil.h"
#import "STMultiSourcingGPUImageProcessor.h"

@implementation STCapturedImageSetDisplayProcessor (GPUImage)

- (BOOL)processForImageInput:(NSArray<id<GPUImageInput>> *)inputs {
    NSAssert(self.layerSet.layers.count,@"_targetLayer.layers is empty.");
    NSAssert([self.layerSet.effect isKindOfClass:STMultiSourcingGPUImageProcessor.class],@"self.targetLayerSet.effect must be implemented STMultiSourcingGPUImageProcessor");

    STMultiSourcingGPUImageProcessor * effect = (STMultiSourcingGPUImageProcessor *) self.layerSet.effect;

    Weaks
    if(effect){
        NSAssert(self.sourceSetOfImagesForLayerSet.count==inputs.count,@"Count of resourcesSetToProcessFromSourceLayers and inputs must be same.");

        for(NSArray *resourceSet in self.sourceSetOfImagesForLayerSet){
            NSUInteger indexOfResourceItemSet = [self.sourceSetOfImagesForLayerSet indexOfObject:resourceSet];
            NSAssert([[resourceSet firstObject] isKindOfClass:NSURL.class], @"only NSURL was allowed.");
            @autoreleasepool {
                //newly create
                NSArray<UIImage *> * imagesToProcessEffect = [self loadImagesFromSourceSet:resourceSet];

                if(imagesToProcessEffect.count){
                    id<GPUImageInput> imageInput = [inputs st_objectOrNilAtIndex:indexOfResourceItemSet];
                    NSAssert(imageInput, @"not found imageInput in inputs, it's nil");

                    if(imageInput){
                        [[effect outputToProcess:imagesToProcessEffect forImage:NO] addTarget:imageInput];
                        return YES;
                    }
                }
            }
        }
    }

    return NO;
}
@end