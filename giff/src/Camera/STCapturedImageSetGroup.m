//
// Created by BLACKGENE on 7/8/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImageSetGroup.h"
#import "STCapturedImageSet.h"
#import "NSArray+STUtil.h"


@implementation STCapturedImageSetGroup {

}

- (instancetype)initWithImageSets:(NSMutableArray *)imageSets {
    self = [super init];
    if (self) {
        _imageSets = imageSets;
    }

    return self;
}

+ (instancetype)groupWithImageSets:(NSMutableArray *)imageSets {
    return [[self alloc] initWithImageSets:imageSets];
}

- (STCapturedImageSet *)defaultImageSet {
    return [[self imageSets] st_objectOrNilAtIndex:self.indexOfDefaultImageSet];
}


@end