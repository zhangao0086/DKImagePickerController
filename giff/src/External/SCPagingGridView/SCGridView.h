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

#import <UIKit/UIKit.h>

#import "SCGridViewDelegate.h"

@interface SCGridView : UIView

/* The schema determines how the GridView will be laid out.
 *
 * This property must be set to an array of integers. Each integer in the array
 * constitutes a new row in the grid and the value of the integer decides the number
 * of columns in that row.
 *
 * Example 1:
 *     self.schema =  @[@(2), @(2)];
 * This creates a gridView with 2 rows. Each row has 2 columns.
 *
 * Example 2:
 *     self.schema =  @[@(3), @(2), @(5)];
 * This creates a gridView with 3 rows. The first row has 3 columns. The second row
 * has 2 columns. The third row has 5 columns.
 *
 */
@property (nonatomic, strong) NSArray *schema;

@property (nonatomic, assign) BOOL schemaShouldEqualToCells;

@property (nonatomic, weak) id<SCGridViewDelegate>delegate;

@property (copy) CGRect (^blockForSetCellViewsFrame)(CGRect frameInGrid, NSUInteger index);

@property (copy) CGFloat (^blockForOutsetColWidth)(CGFloat colWidth, NSUInteger indexOfCol);

@property (copy) CGFloat (^blockForOutsetRowHeight)(CGFloat rowHeight, NSUInteger indexOfRow);

// The amount of space between each row
@property (nonatomic, assign) CGFloat rowSpacing;

// The amount of space between each column
@property (nonatomic, assign) CGFloat colSpacing;

// An array of UIViews. The views will be laid out starting at the top left of the grid
// and then right & down. Alternatively, instead of setting cells directly,
// the gridView delegate can provide cells.
@property (nonatomic, strong) NSArray *cells;

// Force the gridview to ask its delegate for new cells, if it has a delegate.
- (void)reloadData;

- (NSUInteger)numberOfRows;

- (NSInteger)numberOfColsAtRow:(NSUInteger)row;

//TODO: - (NSArray *)cellsAtRow:(NSUInteger)row;

// The total number of cells in the gridview
- (NSUInteger)size;

@end
