//
// Created by BLACKGENE on 4/22/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"

@class STCaptureRequest;
@class STCapturedImage;
@class STOrientationItem;
@class STCapturedImageSet;;

@interface STCaptureResponse : STItem{
@protected
    STCaptureRequest * _request;
}

@property (nonatomic, readonly, nullable) STCaptureRequest * request;
@property (nonatomic, readwrite, nullable) STOrientationItem * orientation;
@property (nonatomic, readwrite, nullable) NSDictionary * metaData;
@property (nonatomic, readwrite, nullable) STCapturedImageSet * imageSet;

- (instancetype)initWithRequest:(STCaptureRequest *)request;

+ (instancetype)responseWithRequest:(STCaptureRequest *)request;

- (UIImage *)createNeededImageFromRequest;

- (void)response;

- (void)dispose;
@end
