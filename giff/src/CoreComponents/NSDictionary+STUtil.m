//
// Created by BLACKGENE on 4/21/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "NSDictionary+STUtil.h"
#import "NSObject+BKAssociatedObjects.h"

@implementation NSDictionary (STUtil)

DEFINE_ASSOCIATOIN_KEY(kPointedKey)
- (NSString *)pointedKey {
    return [self bk_associatedValueForKey:kPointedKey];
}

- (void)setPointedKey:(NSString *)pointedKey {
    NSAssert(self[pointedKey],@"given pointedKey is no member of this dict.");
    [self bk_associateValue:pointedKey withKey:kPointedKey];
}
@end