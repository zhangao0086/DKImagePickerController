//
// Created by BLACKGENE on 2014. 9. 26..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach_time.h>  // for mach_absolute_time()

@interface NSObject (BNRTimeBlock)

#define BEGIN_CHECK_TIME mach_timebase_info_data_t info; \
uint64_t start = mach_absolute_time ();

#define END_CHECK_TIME uint64_t end = mach_absolute_time ();\
uint64_t elapsed = end - start;\
uint64_t nanos = elapsed * info.numer / info.denom;\
NSLog(@"%fs at %@", ((CGFloat)nanos / NSEC_PER_SEC));

- (CGFloat)ckTime:(void (^)(void))block symbol:(NSString *)symbol;
- (CGFloat)ckTime:(void (^)(void))block;
@end