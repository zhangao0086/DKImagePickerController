//
// Created by BLACKGENE on 2015. 3. 21..
// Copyright (c) 2015 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCMeshTransformView.h"

typedef NS_ENUM(NSInteger, STMeshTransformType) {
    STMeshTransformTypeCylinderVertical,
    STMeshTransformTypeCylinderHorizontal,
    STMeshTransformType_count
};

@interface STMeshTransformView : BCMeshTransformView

- (void)setCylinderVertical;

- (void)setCylinderHorizontal;

- (void)clearMeshTransform;
@end