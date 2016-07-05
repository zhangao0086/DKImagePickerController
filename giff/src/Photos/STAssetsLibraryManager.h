//
//  SPAssetsLibraryManager.h
//  prism
//
//  Created by Hyojin Mo on 2014. 5. 13..
//  Copyright (c) 2014년 Starpret. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface STAssetsLibraryManager : NSObject

+ (ALAssetsLibrary *)sharedManager;

+ (void)resetPhotosEnumerater;

+ (void)enumerateNextGroupSavedPhotos:(ALAssetsGroupEnumerationResultsBlock)enumerationBlock completion:(void (^)(void))block;

+ (BOOL)hasNextPhotos;

+ (void)checkLast:(void (^)(ALAsset *result))block;
@end
