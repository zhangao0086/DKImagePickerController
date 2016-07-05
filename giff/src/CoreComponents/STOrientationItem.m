//
// Created by BLACKGENE on 2015. 7. 3..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STOrientationItem.h"


@implementation STOrientationItem {

}

- (instancetype)initWithDeviceOrientation:(UIDeviceOrientation)deviceOrientation interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation imageOrientation:(UIImageOrientation)imageOrientation {
    self = [super init];
    if (self) {
        self.deviceOrientation = deviceOrientation;
        self.interfaceOrientation = interfaceOrientation;
        self.imageOrientation = imageOrientation;
    }

    return self;
}

+ (instancetype)itemWith:(UIDeviceOrientation)deviceOrientation interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation imageOrientation:(UIImageOrientation)imageOrientation {
    return [[self alloc] initWithDeviceOrientation:deviceOrientation interfaceOrientation:interfaceOrientation imageOrientation:imageOrientation];
}

@end