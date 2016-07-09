//
// Created by BLACKGENE on 7/9/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"


@interface STAfterImageLayerItem : STItem
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, assign) NSInteger frameIndexOffset;
@property (nonatomic, assign) NSString * filterId;

@end