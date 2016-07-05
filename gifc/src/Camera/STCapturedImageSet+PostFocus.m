//
// Created by BLACKGENE on 5/9/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImageSet+PostFocus.h"
#import "STCapturedImageSetProtected.h"

@implementation STCapturedImageSet (PostFocus)
- (STPostFocusMode)postFocusMode{
    if(self.type == STCapturedImageSetTypePostFocus && self.count){
        if(self.focusPointsOfInterestSet.count==3){
            return STPostFocusModeVertical3Points;

        }else if(self.focusPointsOfInterestSet.count==5){
            return STPostFocusMode5Points;

        }else if(!self.focusPointsOfInterestSet.count){
            return STPostFocusModeFullRange;
        }

        NSAssert(NO, @"Not supported postFocusMode");
        return STPostFocusModeNone;

    }else{
        return STPostFocusModeNone;
    }
}
@end