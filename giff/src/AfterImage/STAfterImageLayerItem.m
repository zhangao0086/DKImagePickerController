//
// Created by BLACKGENE on 7/9/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STAfterImageLayerItem.h"
#import "STAfterImageLayerEffect.h"
#import "NSString+STUtil.h"
#import "NSArray+STUtil.h"
#import "STCapturedImageSet.h"
#import "STCapturedImage.h"

@interface STAfterImageLayerItem(Private)
@property (nonatomic, readwrite) STAfterImageLayerItem * superlayer;
@end

@implementation STAfterImageLayerItem

- (instancetype)init {
    self = [super init];
    if (self) {
        self.scale = 1;
        self.alpha = 1;
    }
    return self;
}


- (instancetype)initWithSourceImageSets:(NSArray *)sourceImageSets {
    self = [self init];
    self.sourceImageSets = sourceImageSets;
    return self;
}

+ (instancetype)itemWithSourceImageSets:(NSArray *)sourceImageSets {
    return [[self alloc] initWithSourceImageSets:sourceImageSets];
}

- (void)setSourceImageSets:(NSArray *)sourceImageSets {
    NSAssert(sourceImageSets.count, @"empty sourceImageSets is not allowed.");
    STCapturedImageSet * imageSet0 = [sourceImageSets firstObject];
    NSArray * arrayOfImageSetsCount = [sourceImageSets mapWithItemsKeyPath:@keypath(imageSet0.count)];
    NSAssert(sourceImageSets.count == [[NSCountedSet setWithArray:arrayOfImageSetsCount] countForObject:@(imageSet0.count)],
            @"all source image set's count is must be same");
    _sourceImageSets = sourceImageSets;
}

//- (void)setLayers:(NSArray<STAfterImageLayerItem *> *)layers {
//    for(STAfterImageLayerItem * layer in layers){
//        NSAssert([layer isKindOfClass:[STAfterImageLayerItem class]], @"elements of layers is not STAfterImageLayerItem");
//        layer.superlayer = self;
//    }
//    _layers = layers;
//}
//
//- (instancetype)initWithLayers:(NSArray *)layers {
//    self = [super init];
//    if (self) {
//        self.layers = layers;
//    }
//    return self;
//}
//
//+ (instancetype)itemWithLayers:(NSArray *)layers {
//    return [[self alloc] initWithLayers:layers];
//}

- (NSArray *)processResources {
    NSAssert(self.sourceImageSets.count,@"self.sourceImageSets is empty.");

    Weaks
    NSArray * processedResources = nil;
    if(self.effect){
        processedResources = [self.resourcesSetToProcessFromSourceImageSets mapWithIndex:^id(NSArray *resourceItemSet, NSInteger indexOfResourceItemSet) {
            NSAssert([[resourceItemSet firstObject] isKindOfClass:NSURL.class], @"only NSURL was allowed.");

            @autoreleasepool {
                NSURL * tempURLToApplyEffect = [[NSString stringWithFormat:@"l_%@_e_%@_f_%d",
                                                                           Wself.uuid,
                                                                           Wself.effect.uuid,
                                                                           indexOfResourceItemSet
                ] URLForTemp:@"filter_applied_after_image" extension:@"jpg"];

                if([[NSFileManager defaultManager] fileExistsAtPath:tempURLToApplyEffect.path]){
                    //cached
                    return tempURLToApplyEffect;

                }else{
                    //newly create
                    NSArray * imagesToProcessEffect = [resourceItemSet mapWithIndex:^id(NSURL * imageUrl, NSInteger index) {
                        @autoreleasepool {
                            NSAssert([imageUrl isKindOfClass:NSURL.class],@"resource type was supported only as NSURL");
                            NSAssert([[NSFileManager defaultManager] fileExistsAtPath:imageUrl.path], @"file does not exists.");
                            return [UIImage imageWithContentsOfFile:imageUrl.path];
                        }
                    }];

                    BOOL containsNullInImages = [imagesToProcessEffect containsNull]>0;
                    NSAssert(!containsNullInImages, @"imagesToProcessEffect contains null. check fileExistsAtPath.");
                    if(!containsNullInImages){
                        if([UIImageJPEGRepresentation([Wself.effect processEffect:imagesToProcessEffect], 1)
                                writeToURL:tempURLToApplyEffect
                                atomically:NO]){
                            return tempURLToApplyEffect;
                        }
                    }
                }
                return nil;
            }
        }];

    }else{
        //TODO: effect가 없으면서 sourceImageSets이 2이상 (즉 이미지 레벨에서 겹치길 원한다는 의미)일때는 기본 알파 블렌딩?
        processedResources = [self resourcesToProcessFromSourceImageSet:[self.sourceImageSets firstObject]];
    }

    NSAssert(processedResources.count, @"processedResources is empty");
    NSAssert([processedResources containsNull]==0, @"processedResources contained null");
    return processedResources;
}

- (NSArray<id> *)resourcesToProcessFromSourceImageSet:(STCapturedImageSet *)imageSet{
    NSAssert(imageSet.images.count, @"imageSet's count of SourceImageSets is must be higer than 0 ");
    if(imageSet.images.count){
        STCapturedImage * anyImage = [imageSet.images firstObject];
        NSAssert(anyImage.imageUrl, @"STCapturedImage's imageUrl does not exist.");
        return [imageSet.images mapWithItemsKeyPath:@keypath(anyImage.fullScreenUrl) orDefaultKeypath:@keypath(anyImage.imageUrl)];
    }
    return nil;
}

- (NSArray<NSArray *> *)resourcesSetToProcessFromSourceImageSets{
    NSArray * results = [self.sourceImageSets mapWithIndex:^id(STCapturedImageSet * imageSet, NSInteger index) {
        return [self resourcesToProcessFromSourceImageSet:imageSet];
    }];

    BOOL containsNull = [results containsNull]>0;
    NSAssert(!containsNull, @"result resource array contains NSNull.");
    if(containsNull){
        return nil;
    }

    //[[resource....],[resource....]] -> [ [resources_item0,resources_item1], ...]
    NSArray * resourceSets0 = [results firstObject];
    NSMutableArray * rejoinResults = [NSMutableArray arrayWithCapacity:resourceSets0.count];
    [results eachWithIndex:^(NSArray * resourceSets, NSUInteger index) {
        [resourceSets eachWithIndex:^(id object, NSUInteger subindex) {
            if(![rejoinResults st_objectOrNilAtIndex:subindex]) {
                [rejoinResults addObject:[NSMutableArray arrayWithCapacity:resourceSets.count]];
            }
            
            if(![rejoinResults[subindex] st_objectOrNilAtIndex:index]){
                [rejoinResults[subindex] addObject:[NSMutableArray arrayWithCapacity:results.count]];
            }
            rejoinResults[subindex][index] = object;
        }];
    }];
    return rejoinResults;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
//        self.layers = [decoder decodeObjectForKey:@keypath(self.layers)];
        self.alpha = [decoder decodeFloatForKey:@keypath(self.alpha)];
        self.scale = [decoder decodeFloatForKey:@keypath(self.scale)];
        self.frameIndexOffset = [decoder decodeIntegerForKey:@keypath(self.frameIndexOffset)];
        self.effect = [decoder decodeObjectForKey:@keypath(self.effect)];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
//    [encoder encodeObject:self.layers forKey:@keypath(self.layers)];
    [encoder encodeFloat:self.alpha forKey:@keypath(self.alpha)];
    [encoder encodeFloat:self.scale forKey:@keypath(self.scale)];
    [encoder encodeInteger:self.frameIndexOffset forKey:@keypath(self.frameIndexOffset)];
    [encoder encodeObject:self.effect forKey:@keypath(self.effect)];
}
@end