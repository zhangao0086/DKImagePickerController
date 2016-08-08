//
// Created by BLACKGENE on 8/8/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImage+Extension.h"
#import "BlocksKit.h"
#import "NSString+STUtil.h"

@interface STCapturedImage(Private)
- (NSString *)_createResizedImage:(NSString *)path suffix:(NSString *)suffix sizeInScreen:(CGSize)sizeInScreen quality:(float const)quality;
@end

@implementation STCapturedImage (Extension)


DEFINE_ASSOCIATOIN_KEY(kTempImageUrl)
- (BOOL)createTempImage:(CGSize)sizeToResize caching:(BOOL)caching {
    NSURL * tempImageUrl = self.tempImageUrl;
    if(tempImageUrl && caching){
        if([[NSFileManager defaultManager] fileExistsAtPath:tempImageUrl.path]){
            return YES;
        }
    }
    tempImageUrl = [[self _createResizedImage:nil suffix:@"_temp" sizeInScreen:sizeToResize quality:.5] fileURL];
    [self bk_associateValue:tempImageUrl withKey:kTempImageUrl];
    return tempImageUrl != nil;
}

- (NSURL *)tempImageUrl {
    return [self bk_associatedValueForKey:kTempImageUrl];
}


@end