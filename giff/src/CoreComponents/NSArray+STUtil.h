//
// Created by BLACKGENE on 2015. 1. 3..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (STUtil)
@property (nonatomic, assign) NSUInteger pointedIndex;

- (NSInteger)st_boundSafetyIndex:(NSInteger)index;

- (id)st_boundSafetyObjectAtIndex:(NSInteger)index;

- (id)st_objectOrNilAtIndex:(NSUInteger)index;

- (NSArray *)shift;

- (NSArray *)mapWithIndex:(id (^)(id object, NSInteger index))block;

- (NSArray *)mapWithOriginal:(id (^)(NSArray *originalArray, id object, NSInteger index))block;

- (NSArray *)mapWithItemsKeyPath:(NSString *)keypath3;

- (NSArray *)mapWithItemsKeyPath:(NSString *)keypath3 orDefaultKeypath:(NSString *)defaultKeypath;

- (CGSize)findMatchedSizeForItemsKeyPath:(NSString *)keypath3 matchingBlock:(BOOL(^)(CGSize sizeOfLatestMatchedItem, CGSize sizeOfCurrentItem))block;

- (CGSize)findMaxSizeByAreaForItemsKeyPath:(NSString *)keypath3;

- (CGSize)findSizeByMaxSideLengthForItemsKeyPath:(NSString *)keypath3;

- (CGSize)findMinSizeByAreaForItemsKeyPath:(NSString *)keypath3;

- (CGSize)findSizeByMinSideLengthForItemsKeyPath:(NSString *)keypath3;

- (void)eachViewsWithIndex:(void (^)(UIView *view, NSUInteger index))block;

- (void)eachLayersWithIndex:(void (^)(CALayer *layer, NSUInteger index))block;

- (void)eachWithIndexMatchClass:(Class)Class1 block:(void (^)(id, NSUInteger))block;

- (NSUInteger)findIntegerItemRecursivelyAt:(NSUInteger)index;

- (NSUInteger)totalUnsignedIntegerItemsRecursively;

- (NSArray *(^)(NSUInteger, NSUInteger))slice;

- (NSArray *(^)(NSUInteger))chunk;

- (NSArray *)subarrayForChunk:(NSUInteger)chunk length:(NSUInteger)length;

- (NSArray *)chunkifyWithMaxSize:(NSUInteger)size;

- (NSUInteger)containsNull;

- (BOOL)containsAllItemsNull;

- (NSArray *)replaceFromOtherArray:(NSArray *)otherArray inRange:(NSRange)range;

- (NSArray *)replaceFromOtherArray:(NSArray *)otherArray locationFrom:(NSUInteger)location;

- (NSArray *)arrayByInterpolatingRemappedCount:(NSUInteger)newCount;
@end