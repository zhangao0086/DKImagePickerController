//
// Created by BLACKGENE on 2014. 9. 23..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <BlocksKit/NSArray+BlocksKit.h>
#import "NSNumber+STUtil.h"

@implementation NSNumber (STUtil)

- (NSArray *)st_intArray {
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:self.integerValue];
    for(NSInteger i=0; i<self.integerValue; i++){
        [array addObject:@(i)];
    }
    return array;
}

- (NSArray *)st_timesMapWithIndex:(id (^)(NSUInteger))block {
    return [[self st_intArray] bk_map:^id(id obj) {
        return block([obj unsignedIntegerValue]);
    }];
}

//FIXME: 이게 왜 안되는 거지???
- (NSArray *)st_arrayAsStringWithFormat:(NSString *)format {
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:self.unsignedIntegerValue];
    for(NSInteger i=0; i<array.count; i++){
        BOOL contains = [format rangeOfString:@"%d" options:NSCaseInsensitiveSearch].location != NSNotFound;
        [array addObject: [NSString stringWithFormat:format, i]];
    }
    return array;
}

- (NSArray *)st_arrayAsString{
    return [self st_arrayAsStringWithFormat:@"%d"];
}

- (NSString *)st_firstDecimalPointedAsString{
    return [NSString stringWithFormat:@"%.1f", [self floatValue]];
}

- (NSString *)st_firstDecimalPointedAsStringWithZeroTrimmed{
    return [NSString stringWithFormat: @"%g", [[self st_firstDecimalPointedAsString] floatValue]];
}

- (NSString *)st_decimalPointedAsString:(NSUInteger)decimalPosition{
    return [NSString stringWithFormat:@"%.*f", decimalPosition, [self floatValue]];
}
@end