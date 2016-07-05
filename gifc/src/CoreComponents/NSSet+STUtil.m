//
// Created by BLACKGENE on 2015. 2. 25..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "NSSet+STUtil.h"


@implementation NSSet (STUtil)

- (NSSet *)st_intersectsSet:(NSSet *)otherSet; {
    NSMutableSet * set = [self mutableCopy];
    [set intersectSet:otherSet];
    return set;
}

- (NSSet *)st_minusSet:(NSSet *)otherSet; {
    NSMutableSet * set = [self mutableCopy];
    [set minusSet:otherSet];
    return set;
}

- (NSSet *)st_unionSet:(NSSet *)otherSet; {
    NSMutableSet * set = [self mutableCopy];
    [set unionSet:otherSet];
    return set;
}

- (NSSet *)st_unionAndXORSet:(NSSet *)otherSet; {
    NSMutableSet * unioned = [[self st_unionSet:otherSet] mutableCopy];
    NSMutableSet * intersection = [[self st_intersectsSet:otherSet] mutableCopy];
    [unioned minusSet:intersection];
    return unioned;
}

- (NSArray *)st_sortBySimilarSet:(NSArray *)otherSets{
    return [otherSets sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        BOOL orderDescending = NO;
        BOOL primarySet1 = obj1 && [obj1 intersectsSet:self];
        BOOL primarySet2 = obj2 && [obj2 intersectsSet:self];
        orderDescending |= !primarySet1 && primarySet2; //supported?
        orderDescending |= (primarySet1 && primarySet2) && [obj2 st_intersectsSet:self].count > [obj1 st_intersectsSet:self].count; //more wide if both supported?

        return orderDescending ? NSOrderedDescending : NSOrderedSame;
    }];
}

- (NSSet *)st_mostSimilarSet:(NSArray *)otherSets{
    return [self st_sortBySimilarSet:otherSets].first;
}

@end