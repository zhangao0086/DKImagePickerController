//
// Created by BLACKGENE on 8/11/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <GPUImage/GPUImageOutput.h>
#import "STMultiSourcingComposerProcessor.h"
#import "STFilterManager.h"
#import "STGPUImageOutputComposeItem.h"


@implementation STMultiSourcingComposerProcessor {

}

- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    NSArray * composers = sourceImages.count==1 ? [self composersToProcessSingle:sourceImages[0]] : [self composersToProcessMultiple:sourceImages];

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

- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {
    return nil;
}

- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage {
    return nil;
}
@end