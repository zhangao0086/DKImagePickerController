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

#import "SCGridView.h"
#import "UIView+STUtil.h"
#import "NSArray+STUtil.h"

@interface SCGridView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation SCGridView

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapPerformed:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        self.tapGesture = tap;
    }
    return self;
}

- (NSUInteger)numberOfRows{
    if(self.schemaShouldEqualToCells){
        return [self.schema count];

    } else{
        NSUInteger numberOfRows = [self.schema count];
        NSInteger tailCellsCount = [self.cells count]-[self.schema totalUnsignedIntegerItemsRecursively];
        if(tailCellsCount>0){
            NSUInteger lastRowsColCount = [[self.schema last] unsignedIntegerValue];
            NSUInteger appendNumberOfRows = (NSUInteger) ceilf((CGFloat)tailCellsCount/(CGFloat)lastRowsColCount);
            return numberOfRows + appendNumberOfRows;
        }else{
            return numberOfRows;
        }
    }
}

- (NSInteger)numberOfColsAtRow:(NSUInteger)row{
    if(self.schemaShouldEqualToCells){
        return [self.schema[row] integerValue];
    }else{
        return [(self.schema.count <= row ? [self.schema last] : self.schema[row]) integerValue];
    }
}

- (void)layoutSubviews {
    NSUInteger numberOfRows = [self numberOfRows];
    CGFloat totalOutsetHeight = 0;
    if (numberOfRows > 0) {
        CGFloat totalRowSpacing = (numberOfRows - 1) * self.rowSpacing;
        NSUInteger rowHeight = (NSUInteger) floorf((self.bounds.size.height - totalRowSpacing) / numberOfRows);
        NSUInteger cellNumber = 0;
        CGFloat y = 0.0f;
        for (NSUInteger row = 0; row < numberOfRows; ++row) {
            if (cellNumber >= [self.cells count]) {
                break;
            }
            CGFloat outsetRowHeight = (!_blockForOutsetRowHeight ? 0 : _blockForOutsetRowHeight(rowHeight, row));
            BOOL isLastRow = (row+1 == numberOfRows);
            if (isLastRow) {
                // to correct for rounding
                rowHeight = (NSUInteger) (self.bounds.size.height - y);
            }
            NSInteger numberOfCols = [self numberOfColsAtRow:row];
            if (numberOfCols > 0) {
                CGFloat totalColSpacing = (numberOfCols - 1) * self.colSpacing;
                NSUInteger colWidth = (NSUInteger) floorf((self.bounds.size.width - totalColSpacing) / numberOfCols);
                CGFloat x = 0.0f;
                for (NSUInteger col = 0; col < numberOfCols; ++col) {
                    if (cellNumber >= [self.cells count]) {
                        break;
                    }
                    CGFloat outsetColWidth = (!_blockForOutsetColWidth ? 0 : _blockForOutsetColWidth(colWidth, col));
                    BOOL isLastCol = (col+1 == numberOfCols);
                    if (isLastCol) {
                        // to correct for rounding
                        colWidth = (NSUInteger) (self.bounds.size.width - x);
                    }
                    UIView *cell = self.cells[cellNumber];
                    CGRect cellFrameInGrid = CGRectMake(x, y, colWidth, rowHeight+ outsetRowHeight);
                    CGRect delegatedFrame = _blockForSetCellViewsFrame ? _blockForSetCellViewsFrame(cellFrameInGrid, cellNumber) : CGRectNull;
                    cell.frame = CGRectIsEmpty(delegatedFrame) ? cellFrameInGrid : delegatedFrame;
                    x += (colWidth + self.colSpacing + outsetColWidth);
                    cellNumber++;
                }
            }
            y += (rowHeight + self.rowSpacing + outsetRowHeight);
        }
    }
}

#pragma mark - Grid View

- (NSUInteger)size {
    NSUInteger result = 0;
    for (NSNumber *row in self.schema) {
        result += [row integerValue];
    }
    return result;
}

// [1,2,1]... [2,1,2];
- (void)setSchema:(NSArray *)schema {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[schema count]];
    for (id obj in schema) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            [result addObject:obj];
        }
    }
    _schema = [result copy];
}

- (void)reloadData {
    NSMutableArray *cells = [NSMutableArray array];
    if ([self.delegate respondsToSelector:@selector(viewAtPosition:inGridView:coordinates:size:)]) {
        NSInteger position = 0;
        NSInteger numberOfRows = [self numberOfRows];
        if (numberOfRows > 0) {
            for (int row = 0; row < numberOfRows; ++row) {
                NSInteger numberOfCols = [self numberOfColsAtRow:(NSUInteger) row];
                if (numberOfCols > 0) {
                    CGSize size = CGSizeMake(numberOfRows, numberOfCols);
                    for (int col = 0; col < numberOfCols; ++col) {
                        UIView *cell = [self.delegate viewAtPosition:position inGridView:self coordinates:CGPointMake(row, col) size:size];
                        if (!cell) {
                            // blank view
                            cell = [[UIView alloc] init];
                        }
                        [cells addObject:cell];
                        ++position;
                    }
                }
            }
        }
    }
    self.cells = cells;
}

- (void)setCells:(NSArray *)cells {
    for (UIView *view in _cells) {
        [view removeFromSuperview];
    }
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[cells count]];
    for (id obj in cells) {
        if ([obj isKindOfClass:[UIView class]]) {
            UIView *view = obj;
            view.autoresizingMask = UIViewAutoresizingNone;
            [result addObject:view];
            [self addSubview:view];
        }
    }
    _cells = result;
    [self setNeedsLayout];
}

#pragma mark - Tap Gesture

- (void)_tapPerformed:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)gestureRecognizer;
        if (tap.state == UIGestureRecognizerStateEnded) {
            if ([self.delegate respondsToSelector:@selector(gridView:didSelectCell:atIndex:)]) {
                CGPoint location = [tap locationInView:self];
                for (int i = 0; i < [self.cells count]; ++i) {
                    UIView * view = [self.cells objectAtIndex:i];
                    CGPoint local = [view convertPoint:location fromView:self];
                    if ([view pointInside:local withEvent:nil]) {
                        [self.delegate gridView:self didSelectCell:view atIndex:i];
                        break;
                    }
                }
            }
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return ![[self hitTest:[touch locationInView:self] withEvent:nil] isKindOfClass:[UIControl class]];
}

@end
