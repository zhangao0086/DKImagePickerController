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
//  SOFTWARE.
//

#import <UIKit/UIKit.h>

#import "SCPageViewDelegate.h"

@class SCPageContainerView;

typedef enum _SCPageViewState {
    SCPageViewStateResting = 0,
    SCPageViewStateTransitionPrevious,
    SCPageViewStateTransitionPreviousImmediately,
    SCPageViewStateTransitionNext,
    SCPageViewStateTransitionNextImmediately,
    SCPageViewStateTransitionInterrupted
} SCPageViewState;

@interface SCPageView : UIScrollView

// configuration
@property (nonatomic, weak) id<SCPageViewDelegate> pageDelegate;
@property (nonatomic, assign) CGFloat pagingThresholdPercent;
@property (nonatomic, assign) CGFloat pagingThresholdMinimum;
@property (nonatomic, assign) SCPagingDirection direction; // defaults to vertical
@property (nonatomic, assign) CGFloat gapBetweenPages; // defaults to 0.0f
@property (nonatomic, strong, readonly) UIView *nextGapView;
@property (nonatomic, strong, readonly) UIView *previousGapView;
@property (nonatomic, assign, readonly) NSUInteger numberOfPages;

// inner workings
@property (nonatomic, assign, readonly) NSUInteger currentPageNumber;
@property (nonatomic, assign, readonly) SCPageViewState pageViewState;

- (void)reloadData;
- (void)setCurrentPageNumber:(NSUInteger)currentPageNumber animated:(BOOL)animated fast:(BOOL)fastAnimation;

@end