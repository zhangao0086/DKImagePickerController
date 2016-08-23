//
// Created by BLACKGENE on 8/1/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"


@interface STGIFFDisplayLayerEffectItem : STItem
@property (nonatomic, readonly) Class classObj;
@property (nonatomic, readonly) NSUInteger maxSupportedNumberOfSourceImages;
@property (nonatomic, readwrite) NSString * imageName;
@property (nonatomic, readwrite) NSDictionary * valuesForKeysToApply;

- (instancetype)initWithClass:(Class)classObj imageName:(NSString *)imageName valuesForKeysToApply:(NSDictionary *)valuesForKeysToApply;

+ (instancetype)itemWithClass:(Class)classObj imageName:(NSString *)imageName;

+ (instancetype)itemWithClass:(Class)classObj imageName:(NSString *)imageName valuesForKeysToApply:(NSDictionary *)valuesForKeysToApply;
@end