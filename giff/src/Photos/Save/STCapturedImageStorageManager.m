//
// Created by BLACKGENE on 4/29/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImageStorageManager.h"
#import "STCapturedImage.h"
#import "RLMCapturedImage.h"
#import <Realm/Realm.h>
#import "STCapturedImageSet.h"
#import "NSArray+STUtil.h"

//https://realm.io/docs/objc/latest/#filtering

@implementation STCapturedImageStorageManager {

}

+ (STCapturedImageStorageManager *)sharedManager {
    static STCapturedImageStorageManager *_instance = nil;
    BlockOnce(^{
        _instance = [[self alloc] init];

        RLMMigrationBlock migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {

        };
        RLMRealmConfiguration *configuration = [RLMRealmConfiguration defaultConfiguration];
        configuration.schemaVersion = 7;
        configuration.migrationBlock = migrationBlock;

        [RLMRealmConfiguration setDefaultConfiguration:configuration];
        [RLMRealm defaultRealm];
    });
    return _instance;
}

- (BOOL)saveSet:(STCapturedImageSet *)imageSet{
    if(imageSet){
        RLMCapturedImageSet * rlm_imageSet = [[RLMCapturedImageSet alloc] initWithCapturedImageSet:imageSet];
        if([rlm_imageSet writeFile]){
            imageSet.savedTime = rlm_imageSet.savedTime;

            [[RLMRealm defaultRealm] beginWriteTransaction];
            [[RLMRealm defaultRealm] addOrUpdateObject:rlm_imageSet];
            NSError * error;
            [[RLMRealm defaultRealm] commitWriteTransaction:&error];
            return error==nil;
        }
    }
    return NO;
}

- (BOOL)removeSets:(NSArray<STCapturedImageSet *>*)imageSets{
    if(imageSets.count){
        NSArray<RLMCapturedImageSet *>* deletingRLMImageSet = [imageSets mapWithIndex:^id(STCapturedImageSet * imageSet, NSInteger index) {
            return [RLMCapturedImageSet objectForPrimaryKey:imageSet.uuid];
        }];

        [[RLMRealm defaultRealm] beginWriteTransaction];
        NSArray<RLMCapturedImageSet *>* _deletingRLMImageSet = [deletingRLMImageSet copy];
        for(RLMCapturedImageSet * deletingSet in _deletingRLMImageSet){
            [deletingSet deleteFile];
        }
        [[RLMRealm defaultRealm] deleteObjects:_deletingRLMImageSet];
        NSError * error;
        [[RLMRealm defaultRealm] commitWriteTransaction:&error];

        return error==nil;
    }
    return NO;
}

- (BOOL)removeAllSets{
    [[RLMRealm defaultRealm] beginWriteTransaction];
    RLMResults * targetSets = [RLMCapturedImageSet allObjects];
    for(RLMCapturedImageSet * imageSet in targetSets){
        [imageSet deleteFile];
    }
    NSError * error;
    [[RLMRealm defaultRealm] deleteObjects:targetSets];
    [[RLMRealm defaultRealm] commitWriteTransaction:&error];

    return error==nil;
}

- (STCapturedImageSet *)loadSet:(NSString *)uuid{
    return [[RLMCapturedImageSet objectForPrimaryKey:uuid] fetchImageSet];
}

- (NSArray<STCapturedImageSet *>*)loadAllSets{
    NSMutableArray * imageSetsArr = [NSMutableArray array];
    NSMutableArray * imageSetsFileBroken = [NSMutableArray array];
    for(RLMCapturedImageSet * imageSet in [RLMCapturedImageSet allObjects]){
        [[imageSet isFileExist] ? imageSetsArr : imageSetsFileBroken addObject:imageSet];
    }
    if(imageSetsFileBroken.count){
        [[RLMRealm defaultRealm] beginWriteTransaction];
        [[RLMRealm defaultRealm] deleteObjects:imageSetsFileBroken];
        [[RLMRealm defaultRealm] commitWriteTransaction:NULL];
    }
    return imageSetsArr;
}

@end