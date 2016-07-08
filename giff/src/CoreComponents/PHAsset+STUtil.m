//
// Created by BLACKGENE on 2016. 3. 28..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <BlocksKit/NSArray+BlocksKit.h>
#import "PHAsset+STUtil.h"
#import "NSString+STUtil.h"
#import "NSObject+STThreadUtil.h"


@implementation PHAsset (STUtil)

- (BOOL)isLivePhoto{
    return self.mediaSubtypes & PHAssetMediaSubtypePhotoLive;
}

- (void)exportFileTo:(NSURL *)url completion:(void(^)(NSURL * tempFileURL))block{
    //automatic detect by own mediaType and subtype, resource type
}

- (BOOL)exportLivePhotoVideoFile:(void(^)(NSURL * tempFileURL))block{
    NSAssert(self.isLivePhoto, @"this asset is not a LivePhoto.");
    if(self.isLivePhoto){
        [self exportFileByResourceType:PHAssetResourceTypePairedVideo to:nil completion:block];
        return YES;
    }
    return NO;
}

- (void)exportFileByResourceType:(PHAssetResourceType)type completion:(void(^)(NSURL * tempFileURL))block{
    return [self exportFileByResourceType:type to:nil completion:block];
}

- (void)exportFileByResourceType:(PHAssetResourceType)type to:(NSURL *)fileURL completion:(void(^)(NSURL * tempFileURL))block{
    [self exportFileByResourceType:type to:fileURL forceReload:NO completion:block];
}

- (void)exportFileByResourceType:(PHAssetResourceType)type to:(NSURL *)fileURL forceReload:(BOOL)reload completion:(void(^)(NSURL * tempFileURL))block{
    NSParameterAssert(block);

    NSArray * resources = [PHAssetResource assetResourcesForAsset:self];
    PHAssetResource * targetResource = [resources bk_match:^BOOL(PHAssetResource *r) {
        return r.type == type;
    }];

    NSURL * targetURL = fileURL?:[targetResource.originalFilename URLForTemp];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[targetURL path]];
    BOOL existsButForcefullyNeededWrite = reload && exists && [[NSFileManager defaultManager] removeItemAtURL:targetURL error:nil];

    if(!exists || existsButForcefullyNeededWrite){
        Weaks
        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:targetResource toFile:targetURL options:nil completionHandler:^(NSError *error) {
            [Wself st_runAsMainQueueAsyncWithoutDeadlocking:^{
                if(!error){
                    block(targetURL);
                }else{
                    block(nil);
                }
            }];
        }];
    }else{
        block(targetURL);
    }
}

@end