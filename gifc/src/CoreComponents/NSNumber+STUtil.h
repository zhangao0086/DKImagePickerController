//
// Created by BLACKGENE on 2014. 9. 23..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (STUtil)

- (NSArray *)st_intArray;

- (NSArray *)st_timesMapWithIndex:(id (^)(NSUInteger))block;

- (NSArray *)st_arrayAsStringWithFormat:(NSString *)format;

- (NSString *)st_firstDecimalPointedAsString;

- (NSString *)st_firstDecimalPointedAsStringWithZeroTrimmed;

- (NSString *)st_decimalPointedAsString:(NSUInteger)decimalPosition;
@end