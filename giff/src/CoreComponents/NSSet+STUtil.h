//
// Created by BLACKGENE on 2015. 2. 25..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSet (STUtil)


- (NSSet *)st_intersectsSet:(NSSet *)otherSet;

- (NSSet *)st_minusSet:(NSSet *)otherSet;

- (NSSet *)st_unionSet:(NSSet *)otherSet;

- (NSSet *)st_unionAndXORSet:(NSSet *)otherSet;

- (NSArray *)st_sortBySimilarSet:(NSArray *)otherSets;

- (NSSet *)st_mostSimilarSet:(NSArray *)otherSets;
@end