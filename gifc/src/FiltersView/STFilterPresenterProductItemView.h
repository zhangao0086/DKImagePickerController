//
// Created by BLACKGENE on 2016. 2. 11..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STFilterPresenterItemView.h"


@interface STFilterPresenterProductItemView : STFilterPresenterItemView
@property (nonatomic, readwrite) NSString * productIconImageName;
@property (nonatomic, readonly) UIImageView * productIconView;
@end