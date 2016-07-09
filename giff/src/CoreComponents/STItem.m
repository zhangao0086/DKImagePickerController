//
// Created by BLACKGENE on 2014. 9. 11..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import "STItem.h"


@implementation STItem {

}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.uuid = [decoder decodeObjectForKey:@keypath(self.uuid)];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.uuid forKey:@keypath(self.uuid)];
}

- (id)init; {
    self = [super init];
    if (self) {
        _id = self.hash;
    }
    return self;
}

- (void)setUuid:(NSString *)uuid {
    _uuid = uuid;
}

- (NSString *)uuid {
    return _uuid ?: (_uuid = [[NSUUID UUID] UUIDString]);
}

- (instancetype)initWithIndex:(NSUInteger)index; {
    self = [self init];
    if (self) {
        self.index = index;
    }

    return self;
}

+ (instancetype)itemWithIndex:(NSUInteger)index; {
    return [[self alloc] initWithIndex:index];
}
@end