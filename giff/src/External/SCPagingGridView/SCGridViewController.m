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

#import "SCGridViewController.h"
#import "SCGridView.h"

@interface SCGridViewController () {
    BOOL _dataLoaded;
}

@property (nonatomic, weak) SCGridView *gridView;

@end

@implementation SCGridViewController

#pragma mark - UIViewController

- (void)loadView {
    SCGridView *view = [[SCGridView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.gridView = view;
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataLoaded = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_dataLoaded) {
        _dataLoaded = YES;
        [self.gridView reloadData];
    }
}

#pragma mark - Grid View

- (void)setGridView:(SCGridView *)gridView {
    if (gridView != _gridView) {
        _gridView.delegate = nil;
        _gridView = gridView;
        _gridView.delegate = self;
    }
}

#pragma mark - SCGridViewDelegate

- (UIView *)viewAtPosition:(NSUInteger)position inGridView:(SCGridView *)gridView coordinates:(CGPoint)coordinates size:(CGSize)size {
    return nil;
}

@end