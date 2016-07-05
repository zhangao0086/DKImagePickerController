//
// Created by BLACKGENE on 2014. 9. 18..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import "STCarouselHolder.h"


@implementation STCarouselHolder {

}

- (id)init; {
    self = [super init];
    if (self) {
        _centerItemWhenSelected = YES;
        _items = [NSMutableArray array];
    }
    return self;
}
@end