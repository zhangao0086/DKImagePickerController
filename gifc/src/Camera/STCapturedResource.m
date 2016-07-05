//
// Created by BLACKGENE on 4/29/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedResource.h"


@implementation STCapturedResource {

}
- (BOOL)isSaved {
    return self.savedTime>0 && _uuid;
}

@end