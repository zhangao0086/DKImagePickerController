//
// Created by BLACKGENE on 4/29/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"


@interface STCapturedResource : STItem
@property(nonatomic, assign) NSTimeInterval createdTime;
@property(nonatomic, assign) NSTimeInterval savedTime;
@property(nonatomic, readonly, getter=isSaved) BOOL saved;
@end