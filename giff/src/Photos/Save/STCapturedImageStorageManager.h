//
// Created by BLACKGENE on 4/29/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STCapturedImage;
@class STCapturedImageSet;


@interface STCapturedImageStorageManager : NSObject
+ (STCapturedImageStorageManager *)sharedManager;

- (BOOL)saveSet:(STCapturedImageSet *)imageSet;

- (BOOL)removeSets:(NSArray<STCapturedImageSet *>*)imageSets;

- (BOOL)removeAllSets;

- (STCapturedImageSet *)loadSet:(NSString *)uuid;

- (NSArray<STCapturedImageSet *>*)loadAllSets;
@end