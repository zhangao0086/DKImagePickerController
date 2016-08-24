//
// Created by BLACKGENE on 8/23/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "NSArray+STGPUImageOutputComposeItem.h"
#import "STGPUImageOutputComposeItem.h"
#import "NSNumber+STUtil.h"
#import "NSArray+STUtil.h"


@implementation NSArray (STGPUImageOutputComposeItem)

- (NSArray <STGPUImageOutputComposeItem *> *)composeItemsByCategory:(STGPUImageOutputComposeItemCategory)category{
    NSMutableArray * composers = [NSMutableArray arrayWithCapacity:self.count];
    for(STGPUImageOutputComposeItem * sourceImageComposeItem in self){
        if(sourceImageComposeItem.category == category){
            [composers addObject:sourceImageComposeItem];
        }
    }
    return composers;
}


- (NSArray<STGPUImageOutputComposeItem *> *)concatOtherComposers:(NSArray<STGPUImageOutputComposeItem *> *)otherComposers
                                                         blender:(GPUImageTwoInputFilter *)filter
                                                      orderByMix:(BOOL)orderByMix{
    if(!otherComposers.count){
        return self;
    }

    NSParameterAssert(filter);
    STGPUImageOutputComposeItem * composers1_firstItem = [otherComposers firstObject];
    composers1_firstItem.composer = filter;

    if(orderByMix){
        NSMutableArray * resultComposers = [NSMutableArray array];
        [self eachWithIndex:^(STGPUImageOutputComposeItem * item, NSUInteger index) {
            //self
            [resultComposers addObject:item];

            //other
            STGPUImageOutputComposeItem * item1 = [otherComposers st_objectOrNilAtIndex:index];
            if(item1){
                [resultComposers addObject:item1];
            }
        }];

        return resultComposers;
    }else{
        return [self arrayByAddingObjectsFromArray:otherComposers];
    }
}
@end