//
// Created by BLACKGENE on 2015. 1. 3..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "NSArray+STUtil.h"
#import "NSObject+BKAssociatedObjects.h"

@implementation NSArray (STUtil)

DEFINE_ASSOCIATOIN_KEY(kPointedIndex)
- (NSUInteger)pointedIndex {
    return [[self bk_associatedValueForKey:kPointedIndex] unsignedIntValue];
}

- (void)setPointedIndex:(NSUInteger)pointedIndex {
    NSAssert(pointedIndex < self.count,@"given pointedIndex is higher than this.count.");
    [self bk_associateValue:@(pointedIndex) withKey:kPointedIndex];
}

- (NSInteger)st_boundSafetyIndex:(NSInteger) index{
    if(index >= self.count && self.count > 0) return self.count-1;
    else if(index < 0) return 0;
    return index;
}

- (id)st_boundSafetyObjectAtIndex:(NSInteger) index{
    return self[[self st_boundSafetyIndex:index]];
}

- (id)st_objectOrNilAtIndex:(NSUInteger)index{
    return index >= self.count ? nil : self[index];
}

- (NSArray *)shift{
    NSAssert(self.count, @"must not not be empty Array.");

    if(self.count==1){
        return self;
    }

    return [self subarrayWithRange:NSMakeRange(0, 1)];
}

- (NSArray *)mapWithIndex:(id (^)(id object, NSInteger index))block {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];

    for (id object in self) {
        id newObject = block(object, [self indexOfObject:object]) ?: [NSNull null];
        if (newObject) {
            [array addObject:newObject];
        }
    }

    return array;
}

- (NSArray *)mapWithOriginal:(id (^)(NSArray *originalArray, id object, NSInteger index))block {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];

    for (id object in self) {
        id newObject = block(self, object, [self indexOfObject:object]);
        if (newObject) {
            [array addObject:newObject];
        }
    }

    return array;
}

- (NSArray *)mapWithItemsKeyPath:(NSString *)keypath {
    return [self mapWithItemsKeyPath:keypath orDefaultKeypath:nil];
}

- (NSArray *)mapWithItemsKeyPath:(NSString *)keypath orDefaultKeypath:(NSString *)defaultKeypath{
    NSParameterAssert(keypath);
    NSParameterAssert(![keypath isEqualToString:defaultKeypath]);

    if([[self firstObject] valueForKeyPath:keypath] || [[self firstObject] valueForKeyPath:defaultKeypath]){
        return [self mapWithIndex:^id(id object, NSInteger index) {
            return [object valueForKeyPath:keypath] ?: (defaultKeypath ? [object valueForKeyPath:defaultKeypath] : [NSNull null]);
        }];
    }
    return nil;
}

- (void)eachViewsWithIndex:(void (^)(UIView * view, NSUInteger  index))block {
    [self eachWithIndexMatchClass:UIView.class block:^(id o, NSUInteger i) {
        block(o, i);
    }];
}

- (void)eachLayersWithIndex:(void (^)(CALayer * layer, NSUInteger  index))block {
    [self eachWithIndexMatchClass:CALayer.class block:^(id o, NSUInteger i) {
        block(o, i);
    }];
}

- (void)eachWithIndexMatchClass:(Class)Class block:(void (^)(id object, NSUInteger index))block {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:Class]){
            block(obj, idx);
        }
    }];
}

- (NSUInteger)findIntegerItemRecursivelyAt:(NSUInteger)index{
    __block NSUInteger count = 0;
    __block NSUInteger foundItem = NSNotFound;
    [[self flatten] each:^(id object) {
        NSUInteger col = [object unsignedIntegerValue];
        count += col;
        if(foundItem==NSNotFound && count>=index && index<count){
            foundItem = col;
        }else{
            return;
        }
    }];
    return foundItem;
}

- (NSUInteger)totalUnsignedIntegerItemsRecursively{
    __block NSUInteger count = 0;
    [[self flatten] each:^(id object) {
        count += [object unsignedIntegerValue];
    }];
    return count;
}

#pragma mark chunck
- (NSArray *(^)(NSUInteger, NSUInteger))slice {
    return ^id(NSUInteger start, NSUInteger length) {
        NSUInteger const N = self.count;

        if (N == 0)
            return self;

        // forgive
        if (start > N - 1) start = N - 1;
        if (start + length > N) length = N - start;

        return [self subarrayWithRange:NSMakeRange(start, length)];
    };
}

- (NSArray *(^)(NSUInteger))chunk {
    return ^(NSUInteger size){
        id aa = [NSMutableArray new];
        const NSUInteger n = self.count / size;
        for (int x = 0; x < n; ++x)
            [aa addObject:self.slice(x*size, size)];
        return aa;
    };
}

- (NSArray *)subarrayForChunk:(NSUInteger)chunk length:(NSUInteger)length {
    NSRange chunkRange = NSMakeRange(chunk * length, length);
    NSRange allObjectsRange = NSMakeRange(0, self.count);

    NSRange intersectionRange = NSIntersectionRange(chunkRange, allObjectsRange);

    if (intersectionRange.length > 0) {
        return [self subarrayWithRange:intersectionRange];
    } else {
        return nil;
    }
}

- (NSArray *)chunkifyWithMaxSize:(NSUInteger)size {
    NSUInteger chunk = 0;
    NSMutableArray *chunks = @[].mutableCopy;
    while (1) {
        NSArray *chunkArray = [self subarrayForChunk:chunk++ length:size];
        if (chunkArray.count == 0) break;

        [chunks addObject:chunkArray];
    }
    return chunks;
}

@end