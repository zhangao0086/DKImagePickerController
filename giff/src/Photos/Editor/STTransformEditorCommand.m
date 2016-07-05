//
// Created by BLACKGENE on 2015. 2. 27..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STTransformEditorCommand.h"


@implementation STTransformEditorCommand {

}


- (instancetype)rotateLeft; {
    if(_rotation==0 || fabsf(_rotation == (CGFloat)M_PI*2)){
        _rotation = (CGFloat) -M_PI_2;

    }else if(_rotation==-M_PI_2){
        _rotation = (CGFloat) -M_PI;

    }else if(_rotation==-M_PI){
        _rotation = (CGFloat) M_PI_2;

    }else if(_rotation==M_PI_2){
        _rotation = 0;
    }

    self.rotationLeft = YES;

    return self;
}

- (instancetype)square; {
    self.aspectRatio = 1;
    return self;
}

- (instancetype)defaultAspectRatio; {
    self.aspectRatioAsDefault = YES;
    return self;
}

- (instancetype)reset; {
    self.shouldReset = YES;
    return self;
}

- (void)setAspectRatioAsSquare:(BOOL)aspectRatioAsSquare; {
    self.aspectRatio = aspectRatioAsSquare ? 1 : 0;
}

- (BOOL)aspectRatioAsSquare; {
    return self.aspectRatio==1;
}

@end