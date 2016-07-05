//
// Created by BLACKGENE on 2014. 10. 14..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import "NSIndexPath+STIndexPathForSingleSection.h"


@implementation NSIndexPath (STIndexPathForSingleSection)

+ (NSArray *)itemPaths:(NSInteger) index{
    return @[[NSIndexPath itemPath:index]];
}

+ (NSIndexPath *)itemPath:(NSInteger) index{
    return [NSIndexPath indexPathForItem:index inSection:0];
}
@end