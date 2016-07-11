//
// Created by BLACKGENE on 2016. 3. 31..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STPhotoItem.h"

@interface STPhotoItem (STExporterIO)
@property (nonatomic, assign) BOOL exporting;
@property (nonatomic, assign) BOOL exportAsOnlyDefaultImageOfImageSet;
@property (nonatomic, readwrite, nullable) NSURL *exportedTempFileURL;
@end