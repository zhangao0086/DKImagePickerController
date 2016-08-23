//
// Created by BLACKGENE on 8/11/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "GPUImageOutput.h"
#import "STMultiSourcingGPUImageComposerProcessor.h"
#import "STFilterManager.h"
#import "STGPUImageOutputComposeItem.h"

@implementation STMultiSourcingGPUImageComposerProcessor {

}

- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    NSArray * composers = [self composersToProcess:sourceImages];
    if(composers.count){
        return [self processComposers:composers];
    }else{
        return [super processImages:sourceImages];
    }
}

- (UIImage *__nullable)processComposers:(NSArray<STGPUImageOutputComposeItem *> *__nullable)composers {
    if(composers.count){
        return [[[STFilterManager sharedManager] buildTerminalOutputToComposeMultiSource:composers forInput:nil] imageFromCurrentFramebuffer];
    }else{
        return nil;
    }
}

- (NSArray *)composersToProcess:(NSArray<UIImage *> *__nullable)sourceImages {
    return sourceImages.count==1 || [self.class maxSupportedNumberOfSourceImages]==1 ? [self composersToProcessSingle:sourceImages[0]] : [self composersToProcessMultiple:sourceImages];
}

- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {
    return nil;
}

- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage {
    return nil;
}
@end