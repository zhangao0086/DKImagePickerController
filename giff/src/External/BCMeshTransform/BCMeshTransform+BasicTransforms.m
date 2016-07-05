//
//  BCMutableMeshTransform+BasicTransforms.m
//  BCMeshTransformView
//
//  Copyright (c) 2014 Bartosz Ciechanowski. All rights reserved.
//

#import "BCMeshTransform+BasicTransforms.h"
#import "BCMutableMeshTransform+Convenience.h"

@implementation BCMeshTransform (BasicTransforms)

+ (instancetype)curtainMeshTransformAtPoint:(CGPoint)point boundsSize:(CGSize)boundsSize
{
    const float Frills = 3;
    
    point.x = MIN(point.x, boundsSize.width);
    
    BCMutableMeshTransform *transform = [BCMutableMeshTransform identityMeshTransformWithNumberOfRows:20 numberOfColumns:50];
    
    CGPoint np = CGPointMake(point.x/boundsSize.width, point.y/boundsSize.height);
    
    [transform mapVerticesUsingBlock:^BCMeshVertex(BCMeshVertex vertex, NSUInteger vertexIndex) {
        float dy = vertex.to.y - np.y;
        float bend = 0.25f * (1.0f - expf(-dy * dy * 10.0f));
        
        float x = vertex.to.x;
        
        vertex.to.z = 0.1 + 0.1f * sin(-1.4f * cos(x * x * Frills * 2.0 * M_PI)) * (1.0 - np.x);
        vertex.to.x = (vertex.to.x) * np.x + vertex.to.x * bend * (1.0 - np.x);
        
        return vertex;
    }];
    
    return transform;
}


+ (instancetype)buldgeMeshTransformAtPoint:(CGPoint)point
                                     withRadius:(CGFloat)radius
                                     boundsSize:(CGSize)size
{
    const CGFloat Bulginess = 0.4;
    
    BCMutableMeshTransform *transform = [BCMutableMeshTransform identityMeshTransformWithNumberOfRows:36 numberOfColumns:36];
    
    CGFloat rMax = radius/size.width;
    
    CGFloat yScale = size.height/size.width;
    
    CGFloat x = point.x/size.width;
    CGFloat y = point.y/size.height;
    
    NSUInteger vertexCount = transform.vertexCount;
    
    for (int i = 0; i < vertexCount; i++) {
        BCMeshVertex v = [transform vertexAtIndex:i];
        
        CGFloat dx = v.to.x - x;
        CGFloat dy = (v.to.y - y) * yScale;
        
        CGFloat r = sqrt(dx*dx + dy*dy);
        
        if (r > rMax) {
            continue;
        }
        
        CGFloat t = r/rMax;
        
        CGFloat scale = Bulginess*(cos(t * M_PI) + 1.0);
        
        v.to.x += dx * scale;
        v.to.y += dy * scale / yScale;
        v.to.z = scale * 0.2;
        [transform replaceVertexAtIndex:i withVertex:v];
    }
    
    return transform;
}

+ (instancetype)shiverTransformWithPhase:(CGFloat)phase magnitude:(CGFloat)magnitude
{
    const int Slices = 100;

    const float R = M_SQRT2/2.0;
    
    BCMutableMeshTransform *transform = [BCMutableMeshTransform new];
    
    for (int i = 0; i < Slices; i++) {
        float t = (float)i / (Slices);
        float angle = t * 2.0 * M_PI;
        
        float r = R + magnitude * sin(M_PI * cos(t * 2.0 * M_PI * 2 + phase)) * cos(M_PI * t * 2 + phase);
        
        BCMeshVertex v;
        v.from.x = 0.5 + R * sinf(angle);
        v.from.y = 0.5 + R * cosf(angle);
        
        v.to.x = 0.5 + r * sinf(angle);
        v.to.y = 0.5 + r * cosf(angle);
        v.to.z = 0.0;
        
        [transform addVertex:v];
    }
    
    BCMeshVertex center = (BCMeshVertex) {
        .from = CGPointMake(0.5, 0.5),
        .to = BCPoint3DMake(0.5 + 0.02 * cos(phase), 0.5 + 0.02 * sin(phase), 0.0)
    };
    
    [transform addVertex:center];
    
    for (int i = 0; i < Slices / 2; i++) {
        BCMeshFace face = (BCMeshFace) {
            .indices = {(2*i + 1) % Slices, 2*i, Slices, (2*i + 2) % Slices}
        };
        [transform addFace:face];
    }
    
    return transform;
}


+ (instancetype)ellipseMeshTransform
{
    BCMutableMeshTransform *transform = [BCMutableMeshTransform identityMeshTransformWithNumberOfRows:30 numberOfColumns:30];
    
    [transform mapVerticesUsingBlock:^BCMeshVertex(BCMeshVertex vertex, NSUInteger vertexIndex) {
        float x = 2.0 * (vertex.from.x - 0.5f);
        float y = 2.0 * (vertex.from.y - 0.5f);
        
        vertex.to.x = 0.5f + 0.5 * x * sqrt(1.0f - 0.5 * y * y);
        vertex.to.y = 0.5f + 0.5 * y * sqrt(1.0f - 0.5 * x * x);
        return vertex;
        
    }];
    
    return transform;
}


+ (instancetype)rippleMeshTransform
{
    BCMutableMeshTransform *transform = [BCMutableMeshTransform identityMeshTransformWithNumberOfRows:50 numberOfColumns:50];
    
    [transform mapVerticesUsingBlock:^BCMeshVertex(BCMeshVertex vertex, NSUInteger vertexIndex) {
        
        float x = vertex.from.x - 0.5f;
        float y = vertex.from.y - 0.5f;
        
        float r = sqrtf(x * x + y * y);
        
        vertex.to.z = 0.05 * sinf(r * 2.0 * M_PI * 4.0);
        
        return vertex;
    }];
    
    return transform;
}





@end
