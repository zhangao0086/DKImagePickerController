//
// Created by BLACKGENE on 5/9/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STExportSelectView.h"
#import "SCGridView.h"
#import "STExporter.h"
#import "NSArray+STUtil.h"
#import "STStandardButton.h"
#import "STExporter+Config.h"
#import "UIView+STUtil.h"
#import "STUIContentAlignmentView.h"
#import "STMainControl.h"
#import "SVGKFastImageView.h"
#import "SVGKFastImageView+STUtil.h"

@implementation STExportSelectView {
    SCGridView * _gridView;
}

- (void)createContent {
    [super createContent];
}

- (void)setExporterTypes:(NSArray *)exporterTypes {
    if(!_gridView){
        [self st_coverBlur:NO styleDark:NO completion:nil];

        _gridView = [[SCGridView alloc] initWithFrame:self.bounds];
        _gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _gridView.schemaShouldEqualToCells = NO;
        _gridView.schema = @[@4, @4, @4];
        _gridView.delegate = self;
        [self addSubview:_gridView];
        [_gridView centerToParent];
    }

    _exporterTypes = exporterTypes;
    [_gridView reloadData];

    _gridView.alpha = 0;
    [UIView animateWithDuration:.3 animations:^{
        _gridView.alpha=1;
    } completion:^(BOOL finished) {
        [_gridView.cells eachViewsWithIndex:^(UIView *view, NSUInteger index) {
            [view animateWithReverse:@keypath(view.alpha) to:.3 duration:.3 delay:.1*index completion:nil];
        }];
    }];
}

CGFloat const AlphaForUnselected = .47;
CGFloat const AlphaForSelected = .8;

- (UIView *)viewAtPosition:(NSUInteger)position inGridView:(SCGridView *)gridView coordinates:(CGPoint)coordinates size:(CGSize)size {
    id typeObject = [self.exporterTypes st_objectOrNilAtIndex:position];
    if(!typeObject){
        return nil;
    }


    NSInteger type = [typeObject integerValue];
    STExportType exportType = (STExportType)type;

    CGSize cellSize = CGSizeMake(gridView.width / [[gridView.schema firstObject] integerValue], gridView.height / [[gridView.schema firstObject] integerValue]);

    STUIContentAlignmentView * cellView = [[STUIContentAlignmentView alloc] initWithSize:cellSize];
    cellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    cellView.touchInsidePolicy = STUIViewTouchInsidePolicyNone;
    cellView.contentView = [SVGKFastImageView viewWithImageNamed:[STExporter iconImageName:exportType] sizeWidth:cellSize.width/1.5f];
    cellView.backgroundColor = [[STExporter iconImageBackgroundColor:exportType] colorWithAlphaComponent:AlphaForUnselected];

    UIColor * iconBackgroundColor = [STExporter iconImageBackgroundColor:exportType];
    UIColor * iconBackgroundColorSelected = [iconBackgroundColor colorWithAlphaComponent:AlphaForSelected];
    UIColor * iconBackgroundColorUnSelected = [iconBackgroundColor colorWithAlphaComponent:AlphaForUnselected];

    Weaks
    [cellView whenLongTapAsTapDownUp:^(UILongPressGestureRecognizer *sender, CGPoint location) {
        cellView.backgroundColor = iconBackgroundColorSelected;

    } changed:^(UILongPressGestureRecognizer *sender, CGPoint location) {
        BOOL touchInside = CGPointLengthBetween_AGK(sender.view.st_halfXY, location) <= sender.view.width;
        UIColor * color = touchInside ? iconBackgroundColorSelected : iconBackgroundColorUnSelected;
        if(![color isEqual:cellView.backgroundColor]){
            cellView.backgroundColor = color;
        }

    } ended:^(UILongPressGestureRecognizer *sender, CGPoint location) {
        BOOL touchInside = CGPointLengthBetween_AGK(sender.view.st_halfXY, location) <= sender.view.width;

        if(touchInside){
            [[STMainControl sharedInstance] tryExportByType:exportType];
        }
        cellView.backgroundColor = iconBackgroundColorUnSelected;

    }].delaysTouchesEnded = YES;

    return cellView;
}


@end