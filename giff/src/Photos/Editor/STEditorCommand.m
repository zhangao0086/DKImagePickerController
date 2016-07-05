//
// Created by BLACKGENE on 2015. 2. 25..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STEditorCommand.h"
#import "STPhotoItem.h"


@implementation STEditorCommand {

}

+ (instancetype)create {
    return [[self alloc] init];
}

+ (instancetype)getLast:(STPhotoItem *)photoItem; {
    return [self.class isKindOfClass:photoItem.lastToolCommand.class] ? photoItem.lastToolCommand : [self.class create];
}
@end