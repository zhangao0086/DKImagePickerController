//
// Created by BLACKGENE on 7/27/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <GPUImage/GPUImageOutput.h>
#import "STCapturedImageSetDisplayLayerSet.h"
#import "STCapturedImageSetGPUDisplayProcessor.h"
#import "STMultiSourcingImageProcessor.h"
#import "NSArray+STUtil.h"
#import "STCapturedImageSet.h"
#import "STMultiSourcingGPUImageProcessor.h"


@implementation STCapturedImageSetGPUDisplayProcessor {

}

- (BOOL)processForImageInput:(NSArray<id<GPUImageInput>> *)inputs {
    NSAssert(self.targetLayerSet.layers.count,@"_targetLayer.layers is empty.");
    NSAssert([self.targetLayerSet.effect isKindOfClass:STMultiSourcingGPUImageProcessor.class],@"self.targetLayerSet.effect must be implemented STMultiSourcingGPUImageProcessor");

    STMultiSourcingGPUImageProcessor * effect = (STMultiSourcingGPUImageProcessor *) self.targetLayerSet.effect;

    Weaks
    if(effect){
        for(NSArray *resourceSet in self.resourcesSetToProcessFromSourceLayers){
            NSUInteger indexOfResourceItemSet = [self.resourcesSetToProcessFromSourceLayers indexOfObject:resourceSet];
            NSAssert([[resourceSet firstObject] isKindOfClass:NSURL.class], @"only NSURL was allowed.");
            @autoreleasepool {
                //newly create
                NSArray * imagesToProcessEffect = [resourceSet mapWithIndex:^id(NSURL * imageUrl, NSInteger index) {
                    @autoreleasepool {
                        NSAssert([imageUrl isKindOfClass:NSURL.class],@"resource type was supported only as NSURL");
                        NSAssert([[NSFileManager defaultManager] fileExistsAtPath:imageUrl.path], @"file does not exists.");
                        return [UIImage imageWithContentsOfFile:imageUrl.path];
                    }
                }];

                BOOL containsNullInImages = [imagesToProcessEffect containsNull]>0;
                NSAssert(!containsNullInImages, @"imagesToProcessEffect contains null. check fileExistsAtPath.");

                if(!containsNullInImages){
                    BOOL vailedLayerNumbers = imagesToProcessEffect.count <= [Wself.targetLayerSet.effect supportedNumberOfSourceImages];
                    NSAssert(vailedLayerNumbers, ([NSString stringWithFormat:@"%@ - Only %d source image sets supported",NSStringFromClass(Wself.targetLayerSet.effect.class), [Wself.targetLayerSet.effect supportedNumberOfSourceImages]]));

                    id<GPUImageInput> imageInput = [inputs st_objectOrNilAtIndex:indexOfResourceItemSet];
                    NSAssert(imageInput, @"not found imageInput in inputs, it's nil");

                    if(vailedLayerNumbers && imageInput){
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