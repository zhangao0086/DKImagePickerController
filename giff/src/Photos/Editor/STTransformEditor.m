//
// Created by BLACKGENE on 2015. 1. 27..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STTransformEditor.h"
#import "STEditorResult.h"
#import "STEditorCommand.h"
#import "STTransformEditorView.h"
#import "STTransformEditorResult.h"
#import "STTransformEditorCommand.h"
#import "STMainControl.h"
#import "NSObject+STUtil.h"


@implementation STTransformEditor {
    STTransformEditorView *_toolView;
}

- (void)dealloc {
    [self dismiss];
}


- (BOOL)isOpened; {
    return _toolView !=nil;
}

- (BOOL)isModified; {
    return self.isOpened && _toolView.modified;
}

- (void)open:(UIImage *)targetImage view:(UIView *)view; {
    NSParameterAssert(targetImage);

    _toolView = [[STTransformEditorView alloc] initWithFrame:view.bounds];
    [view addSubview:_toolView];

    _toolView.image = targetImage;

    [_toolView setEditing:YES animated:NO];

    Weaks
    [_toolView whenValueOf:@keypath(_toolView.modified) id:@"transform.tool.modified" changed:^(id value, id _weakSelf) {
        [Wself didChanged];
    }];
}

- (void)didChanged {
    if(self.isModified) {
        [[STMainControl sharedInstance] showContextNeededResetButton];
    }else{
        [[STMainControl sharedInstance] hideContextNeededResetButton];
    }
}

- (void)reset; {
    [_toolView setEditing:NO];
}

- (STEditorResult *)apply; {
    STTransformEditorResult * result = [_toolView cropResult];
    result.modified = _toolView.modified;
    return result.modified ? result : nil;
}

- (void)applyAsync:(void (^)(STEditorResult *))block; {
    NSParameterAssert(block);

    block([self apply]);
}

- (void)dismiss; {
    [_toolView whenValueOf:@keypath(_toolView.modified) id:@"transform.tool.modified" changed:nil];
    _toolView.image = nil;
    [_toolView removeFromSuperview];
    _toolView = nil;
}

- (BOOL)command:(STEditorCommand *)command; {
    BOOL succeed = NO;

    if([command isKindOfClass:STTransformEditorCommand.class]){
        STTransformEditorCommand *_command = (STTransformEditorCommand *) command;

        if(_command.shouldReset && _toolView.modified){
            [_toolView reset:YES];

            succeed = YES;
        }else{

            if(_command.aspectRatio > 0){
                [_toolView constrain:_command.aspectRatio animated:YES];
                succeed = YES;
            }else if(_command.aspectRatioAsDefault){
                [_toolView constrain:(CGFloat) CGSizeAspectRatio_AGK(_toolView.image.size) animated:YES];
                succeed = YES;
            }

            if(_command.rotationLeft){
                [_toolView rotateLeft:YES];
                succeed = YES;
            }
        }

        [self didChanged];
    }

    return succeed;
}

@end