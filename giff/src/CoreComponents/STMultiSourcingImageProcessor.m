//
// Created by BLACKGENE on 7/14/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STMultiSourcingImageProcessor.h"

@implementation STMultiSourcingImageProcessor{
}

#pragma mark Process

+ (NSUInteger)maxSupportedNumberOfSourceImages {
    return 2;
}

- (UIImage *)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    return [sourceImages firstObject];
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