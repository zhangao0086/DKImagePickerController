//
// Created by BLACKGENE on 2016. 3. 15..
// Copyright (c) 2016 stells. All rights reserved.
//

#import "UIViewController+STUtil.h"
#import "NSNotificationCenter+STFXNotificationsShortHand.h"
#import "NSObject+STUtil.h"

@implementation STKeyBoardStatusInfo
- (instancetype)initWithFrameBegin:(CGRect)frameBegin frameEnd:(CGRect)frameEnd animationDuration:(NSTimeInterval)animationDuration animationCurve:(NSUInteger)animationCurve local:(BOOL)local {
    self = [super init];
    if (self) {
        _frameBegin = frameBegin;
        _frameEnd = frameEnd;
        _animationDuration = animationDuration;
        _animationCurve = animationCurve;
        _local = local;
    }
    return self;
}

+ (instancetype)infoWithFrameBegin:(CGRect)frameBegin frameEnd:(CGRect)frameEnd animationDuration:(NSTimeInterval)animationDuration animationCurve:(NSUInteger)animationCurve local:(BOOL)local {
    return [[self alloc] initWithFrameBegin:frameBegin frameEnd:frameEnd animationDuration:animationDuration animationCurve:animationCurve local:local];
}
@end


@implementation UIViewController (STUtil)

- (void)whenChangeKeyBoardStatus:(id)observer didShow:(void (^)(STKeyBoardStatusInfo *showInfo))didShow willHide:(void(^)(STKeyBoardStatusInfo * hideInfo))willHide{
    if(didShow){
        [[NSNotificationCenter defaultCenter] st_addObserverWithMainQueue:observer forName:UIKeyboardDidShowNotification usingBlock:^(NSNotification *note, id observer) {
            NSDictionary *info = [note userInfo];
            STKeyBoardStatusInfo *resultInfo = [STKeyBoardStatusInfo infoWithFrameBegin:[info[UIKeyboardFrameBeginUserInfoKey] CGRectValue]
                                                                               frameEnd:[info[UIKeyboardFrameBeginUserInfoKey] CGRectValue]
                                                                      animationDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                                                                         animationCurve:[info[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue]
                                                                                  local:[info[UIKeyboardIsLocalUserInfoKey] boolValue]];
            didShow(resultInfo);
        }];
    }else{
        [[NSNotificationCenter defaultCenter] st_removeObserverWithMainQueue:observer forName:UIKeyboardDidShowNotification];
    }


    if(willHide){
        [[NSNotificationCenter defaultCenter] st_addObserverWithMainQueue:observer forName:UIKeyboardWillHideNotification usingBlock:^(NSNotification *note, id observer) {
            NSDictionary *info = [note userInfo];
            STKeyBoardStatusInfo *resultInfo = [STKeyBoardStatusInfo infoWithFrameBegin:[info[UIKeyboardFrameBeginUserInfoKey] CGRectValue]
                                                                               frameEnd:[info[UIKeyboardFrameBeginUserInfoKey] CGRectValue]
                                                                      animationDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                                                                         animationCurve:[info[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue]
                                                                                  local:[info[UIKeyboardIsLocalUserInfoKey] boolValue]];
            willHide(resultInfo);
        }];
    }else{
        [[NSNotificationCenter defaultCenter] st_removeObserverWithMainQueue:observer forName:UIKeyboardWillHideNotification];
    }
}

- (void)removeAllChangeKeyBoardStatusObservations:(id)observer {
    [self whenChangeKeyBoardStatus:observer didShow:nil willHide:nil];
}
@end