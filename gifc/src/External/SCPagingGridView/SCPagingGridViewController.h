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

#import "SCPageViewController.h"
#import "SCGridViewDelegate.h"

@interface SCPagingGridViewController : SCPageViewController<SCGridViewDelegate>

/* The schema determines how the GridView pages will be laid out.
 *
 * This property must be set to an array of integer arrays. The paging gridview
 * will cycle through the schema array, using the first entry for the first page,
 * the second entry for the second page, etc. When it reaches the end of the 
 * schema array, it repeats the cycle from the beginning.
 *
 * Example 1:
 *     self.schema =  @[ @[@(2), @(2)], @[@(1), @(3)] ];
 * The first page will be a grid with 2 rows, each row has 2 columns.
 * The second page will be a grid with 2 rows, the first row has 1 column. The second row has 3 columns.
 * The third page will have the same schema as the first.
 *
 * Example 2:
 *     self.schema =  @[ @[@(1), @(3), @(2)] ];
 * Every page will have 3 rows. The first row has 1 column, the second row has 3 columns,
 * the third row has 2 columns.
 *
 */
@property (nonatomic, strong) NSArray *schema;

// optional, ignored if less than or equal to zero
@property (nonatomic, assign) NSUInteger maxNumberOfPages;

@property (nonatomic, assign, readonly) NSUInteger totalPageSizes;

#pragma mark - Calculations

- (NSUInteger)offsetForPageNumber:(NSUInteger)pageNumber;
- (NSNumber *)sizeForPageSchema:(NSArray *)schema;
- (NSArray *)schemaForPageNumber:(NSUInteger)pageNumber;

#pragma mark - Cells

- (NSInteger)numberOfCellsInPageView:(SCPageView *)pageView;

#pragma mark - Subclass Override Methods

- (void)configureGridView:(SCGridView *)gridView forPageNumber:(NSUInteger)pageNumber;
- (NSArray *)schemaForShortPage:(NSUInteger)pageNumber numberOfCells:(NSUInteger)numberOfCells originalSchema:(NSArray *)original inGridView:(SCGridView *)gridView;
- (Class)cellClass;
- (void)configureCell:(UIView *)cell atPosition:(NSUInteger)position;
- (void)didSelectCell:(UIView *)cell atPosition:(NSUInteger)position;

@end
