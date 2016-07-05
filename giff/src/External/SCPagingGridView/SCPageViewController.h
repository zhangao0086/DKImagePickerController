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

#import "SCPageViewDelegate.h"
#import "SCViewController.h"

@class SCPageIndicatorView;

@interface SCPageViewController : SCViewController<UIScrollViewDelegate, SCPageViewDelegate>

@property (nonatomic, weak, readonly) SCPageView *pageView;
@property (nonatomic, weak, readonly) SCPageIndicatorView *pageIndicator;
@property (nonatomic, strong) NSArray *pages;

- (void)showPageIndicator;
- (void)hidePageIndicator;
- (SCPageIndicatorView *)createPageIndicatorWithFrame:(CGRect)frame;
- (void)configurePageIndicator:(SCPageIndicatorView *)pageIndicatorView;

- (UIViewController *)controllerAtPageNumber:(NSUInteger)pageNumber;

@end

@interface UIViewController (SCPageViewControllerAdditions)

@property (nonatomic, weak, readonly) SCPageViewController *pageViewController;

@end