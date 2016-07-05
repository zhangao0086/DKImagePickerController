//
// Created by BLACKGENE on 2015. 2. 25..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STPhotoItem;


@interface STEditorCommand : NSObject

+ (instancetype)create;

+ (instancetype)getLast:(STPhotoItem *)photoItem;
@end