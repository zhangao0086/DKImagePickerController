//
//  Created by Jesse Andersen on 11/1/12.
//  Copyright (c) 2012 Scribd. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "SCViewRecycler.h"
#import "SCSwizzle.h"

@implementation UIView (SCViewRecycling)

- (void)SCViewRecycling_willMoveToSuperview:(UIView *)view {
    // call kvo method
    [self willChangeValueForKey:@"superview"];
    // call through to original
    [self SCViewRecycling_willMoveToSuperview:view];
}

- (void)SCViewRecycling_didMoveToSuperview {
    // call through to original
    [self SCViewRecycling_didMoveToSuperview];
    // call kvo method
    [self didChangeValueForKey:@"superview"];
}

@end

@interface SCViewRecycler () {
    Class _klass;
}

@property (nonatomic, strong) NSMutableArray *availableQueue;
@property (nonatomic, strong) NSMutableArray *unavailableQueue;

@end

@implementation SCViewRecycler

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    // unhook KVO
    for (id obj in _availableQueue) {
        if ([obj isKindOfClass:[UIView class]]) {
            [obj removeObserver:self forKeyPath:@"superview"];
        }
    }
    
    for (id obj in _unavailableQueue) {
        if ([obj isKindOfClass:[UIView class]]) {
            [obj removeObserver:self forKeyPath:@"superview"];
        }
    }
}

- (id)initWithViewClass:(Class)klass {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_memoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
        _klass = klass;
        [self _swizzleClass:_klass];
        
        _availableQueue = [NSMutableArray arrayWithCapacity:20];
        _unavailableQueue = [NSMutableArray arrayWithCapacity:20];
    }
    return self;
}

#pragma mark - public methods

- (void)_swizzleClass:(Class)klass {
    // must, must, must ensure this method is run on main thread or we risk swizzling the same class multiple times
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _swizzleClass:klass];
        });
        return;
    }
    
    static NSMutableArray *swizzled;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzled = [NSMutableArray array];
    });
    
    if (![swizzled containsObject:klass]) {
        MethodSwizzle(klass, @selector(willMoveToSuperview:), @selector(SCViewRecycling_willMoveToSuperview:));
        MethodSwizzle(klass, @selector(didMoveToSuperview), @selector(SCViewRecycling_didMoveToSuperview));
        [swizzled addObject:klass];
    }
}

- (id)generateView {
    id result = nil;
    if ([self.availableQueue count] > 0) {
        NSUInteger last = [self.availableQueue count] - 1;
        id object = [self.availableQueue objectAtIndex:last];
        [self.availableQueue removeObjectAtIndex:last];
        if ([object isKindOfClass:_klass]) {
            result = object;
        }
    }
    if (!result) {
        result = [[_klass alloc] init];
        [result addObserver:self forKeyPath:@"superview" options:0 context:nil];
    }
    [self.unavailableQueue addObject:result];
    return result;
}

- (void)clearCache {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self clearCache];
        });
        return;
    }
    
    for (id obj in self.availableQueue) {
        if ([obj isKindOfClass:[UIView class]]) {
            [obj removeObserver:self forKeyPath:@"superview"];
        }
    }
    
    [self.availableQueue removeAllObjects];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"superview"] && [object isKindOfClass:[UIView class]]) {
        UIView *view = object;
        if (!view.superview) {
            [self.unavailableQueue removeObject:view];
            [self.availableQueue addObject:view];
        }
    }
}

#pragma mark - memory warning

- (void)_memoryWarning:(NSNotification *)notification {
    [self clearCache];
}

@end
