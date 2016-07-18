//
// Created by BLACKGENE on 7/18/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImageSetDisplayableMultiSourceProcessor.h"


@implementation STCapturedImageSetDisplayableMultiSourceProcessor {

}


- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.fitOutputSizeToSourceImage = [decoder decodeBoolForKey:@keypath(self.fitOutputSizeToSourceImage)];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeBool:self.fitOutputSizeToSourceImage forKey:@keypath(self.fitOutputSizeToSourceImage)];
}
@end