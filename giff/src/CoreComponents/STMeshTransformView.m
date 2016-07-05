//
// Created by BLACKGENE on 2015. 3. 21..
// Copyright (c) 2015 Bartosz Ciechanowski. All rights reserved.
//

#import "STMeshTransformView.h"

@implementation STMeshTransformView {
    STMeshTransformType _currentType;
}


- (instancetype)initWithFrame:(CGRect)frame; {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)addSubview:(UIView *)view; {
    [self.contentView addSubview:view];
}

- (void)setMeshTransformByType:(STMeshTransformType)type; {
    _currentType = type;

    switch (type){
        case STMeshTransformTypeCylinderVertical:
            self.meshTransform = [self.class cylinderMeshTransformAtPoint:self.contentView.center curve:-.2f diameter:self.bounds.size.width boundsSize:self.bounds.size vertical:YES];
            break;

        case STMeshTransformTypeCylinderHorizontal:
            self.meshTransform = [self.class cylinderMeshTransformAtPoint:self.contentView.center curve:-.2f diameter:self.bounds.size.height boundsSize:self.bounds.size vertical:NO];
            break;
    }
}

- (void)setCylinderVertical {
    [self setMeshTransformByType:STMeshTransformTypeCylinderVertical];
}

- (void)setCylinderHorizontal{
    [self setMeshTransformByType:STMeshTransformTypeCylinderHorizontal];
}

- (void)clearMeshTransform{
    self.meshTransform = [BCMutableMeshTransform identityMeshTransformWithNumberOfRows:1 numberOfColumns:1];
}

- (BOOL)isClearedMeshTransform{
    return self.meshTransform.faceCount<=1;
}

+ (BCMutableMeshTransform *)cylinderMeshTransformAtPoint:(CGPoint)point
                                       curve:(CGFloat)curve
                                    diameter:(CGFloat)diameter
                                  boundsSize:(CGSize)size
                                    vertical:(BOOL)vertical {

    BCMutableMeshTransform *transform = [BCMutableMeshTransform identityMeshTransformWithNumberOfRows:36 numberOfColumns:36];

    CGFloat xMax = diameter/size.width;
    CGFloat yMax = diameter/size.height;

    CGFloat xScale = size.width/size.height;
    CGFloat yScale = size.height/size.width;

    CGFloat x = point.x/size.width;
    CGFloat y = point.y/size.height;

    NSUInteger vertexCount = transform.vertexCount;

    for (int i = 0; i < vertexCount; i++) {
        BCMeshVertex  v = [transform vertexAtIndex:i];

        if(vertical){
            CGFloat dx = v.to.x - x;
            CGFloat dy = (v.to.y - y) * yScale;

            if (dx > xMax || dx < -xMax) {
                continue;
            }

            CGFloat t = dx / xMax;
            CGFloat scale = (CGFloat) (curve *(cos(t * M_PI) - 1.0));

            v.to.y += dy * scale / yScale;
            v.to.z = scale * .1f;

        }else{

            CGFloat dx = (v.to.x - x) * xScale;
            CGFloat dy = v.to.y - y;

            if (dy > yMax || dy < -yMax) {
                continue;
            }

            CGFloat t = dy / yMax;
            CGFloat scale = (CGFloat) (curve *(cos(t * M_PI) - 1.0));

            v.to.x += dx * scale / xScale;
            v.to.z = scale * .1f;
        }

        [transform replaceVertexAtIndex:i withVertex:v];
    }

    return transform;
}

@end