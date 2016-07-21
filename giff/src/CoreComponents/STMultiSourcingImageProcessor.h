//
// Created by BLACKGENE on 7/14/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"

@interface STMultiSourcingImageProcessor : STItem
@property (nonatomic, assign) BOOL fitOutputSizeToSourceImage;

- (UIImage * __nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages;

- (NSUInteger)supportedNumberOfSourceImages;
@end