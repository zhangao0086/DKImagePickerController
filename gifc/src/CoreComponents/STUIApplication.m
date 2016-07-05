//
// Created by BLACKGENE on 15. 10. 5..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STUIApplication.h"

NSString * const STGlobalUITouchEndNotification = @"com.stells.notification.globaltouch.end";

@implementation STUIApplication {

}

+ (instancetype)sharedApplication {
    return (STUIApplication *) [super sharedApplication];
}

- (void)endIgnoringInteractionEvents {
    [super endIgnoringInteractionEvents];
}

- (void)beginIgnoringInteractionEvents {
    if(self.isIgnoringInteractionEvents){
        [[NSRunLoop currentRunLoop] cancelPerformSelector:@selector(beginIgnoringInteractionEvents) target:self argument:nil];
    }else{
        [super beginIgnoringInteractionEvents];
    }
}

- (void)sendEvent:(UIEvent *)event {
    [super sendEvent:event];

    if (_trackingGlobalTouches && event.type == UIEventTypeTouches) {
        NSSet* allTouches = [event allTouches];
        UITouch* touch = [allTouches anyObject];

        if(touch.phase == UITouchPhaseEnded){
            [[NSNotificationCenter defaultCenter] postNotificationName:STGlobalUITouchEndNotification object:touch];
        }
    }
}
@end