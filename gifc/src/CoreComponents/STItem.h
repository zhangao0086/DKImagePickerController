//
// Created by BLACKGENE on 2014. 9. 11..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface STItem : NSObject{
@protected
    NSString * _uuid;
}
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) NSInteger id;
@property (atomic, readwrite, nullable) NSString * uuid;

- (instancetype)initWithIndex:(NSUInteger)index;

+ (instancetype)itemWithIndex:(NSUInteger)index;

@end