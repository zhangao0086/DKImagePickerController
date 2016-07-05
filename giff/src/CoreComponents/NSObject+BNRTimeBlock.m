//
// Created by BLACKGENE on 2014. 9. 26..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import "NSObject+BNRTimeBlock.h"
@implementation NSObject (BNRTimeBlock)

CGFloat checkTime(void (^block)(void)) {
    mach_timebase_info_data_t info;
    if (mach_timebase_info(&info) != KERN_SUCCESS) return -1.0;

    uint64_t start = mach_absolute_time ();
    block ();
    uint64_t end = mach_absolute_time ();
    uint64_t elapsed = end - start;

    uint64_t nanos = elapsed * info.numer / info.denom;
    return (CGFloat)nanos / NSEC_PER_SEC;

} // BNRTimeBlock

- (CGFloat)ckTime:(void (^)(void))block symbol:(NSString *)symbol {
    CGFloat time = checkTime(block);
#ifdef DEBUG
    CALLER_INFO
    NSLog(@"%@ > performed : %fs at %@", symbol, time, __caller_info__[CALLER_INFO_INDEX_FUNCTION]);
#endif
    return time;
}

- (CGFloat)ckTime:(void (^)(void))block {
    return [self ckTime:block symbol:nil];
}

@end

