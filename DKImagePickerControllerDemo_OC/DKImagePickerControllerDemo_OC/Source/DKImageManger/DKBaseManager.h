//
//  DKBaseManager.h
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/7/6.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DKBaseManager : NSObject
@property (nonatomic, strong) NSHashTable * observers;

- (void)addObserver:(id)object;
- (void)removeObserver:(id)object;
- (void)notifyObserversWithSelector:(SEL)sel
                             object:(id)object;
- (void)notifyObserversWithSelector:(SEL)selector
                             object:(id)object
                          objectTwo:(id)objectTwo;


@end
