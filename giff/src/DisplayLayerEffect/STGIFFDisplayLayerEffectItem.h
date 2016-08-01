//
// Created by BLACKGENE on 8/1/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"


@interface STGIFFDisplayLayerEffectItem : STItem
@property (nonatomic, readwrite) NSString * className;
@property (nonatomic, readwrite) NSString * imageName;

- (instancetype)initWithClassName:(NSString *)className imageName:(NSString *)imageName;

+ (instancetype)itemWithClassName:(NSString *)className imageName:(NSString *)imageName;

+ (instancetype)itemWithClass:(Class)classObj imageName:(NSString *)imageName;


@end