//
//  DKBaseManager.m
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/7/6.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKBaseManager.h"

@interface DKBaseManager()

@end
@implementation DKBaseManager
- (instancetype)init{
    if (self = [super init]) {
        _observers = [NSHashTable weakObjectsHashTable];
    }
    return self;
    
}


- (void)addObserver:(id)object{
    [self.observers addObject:object];
}

- (void)removeObserver:(id)object{
    [self.observers removeObject:object];
}

- (void)notifyObserversWithSelector:(SEL)sel
                             object:(id)object{
    [self notifyObserversWithSelector:sel object:object objectTwo:nil];
    
}



#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)notifyObserversWithSelector:(SEL)selector
                             object:(id)object
                          objectTwo:(id)objectTwo{
    if (self.observers.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id anyObject in self.observers.allObjects) {
                if ([anyObject respondsToSelector:selector]) {
                   [anyObject performSelector:selector withObject:object withObject:objectTwo];
                }
            }
        });
    }
}


@end
