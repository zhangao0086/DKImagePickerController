//
// Created by BLACKGENE on 2014. 10. 14..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexPath (STIndexPathForSingleSection)

+ (NSArray *)itemPaths:(NSInteger)index;
+ (NSIndexPath *)itemPath:(NSInteger)index;

@end