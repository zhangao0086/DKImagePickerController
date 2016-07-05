//
// Created by BLACKGENE on 2015. 3. 19..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <BlocksKit/NSObject+BKBlockObservation.h>
#import "STStandardCollectableButton.h"
#import "NSString+STUtil.h"
#import "UIView+STUtil.h"
#import "NSArray+STUtil.h"
#import "STStandardLayout.h"
#import "STStandardUX.h"


@implementation STStandardCollectableButton {
    void (^_whenCollectableSelected)(STStandardButton * button, NSUInteger index);
}

- (instancetype)initWithFrame:(CGRect)frame; {
    self = [super initWithFrame:frame];
    if (self) {
        _autoUXLayoutWhenExpanding = YES;
        _collectablesUserInteractionEnabled = YES;
    }
    return self;
}

- (void)clearCollectableViews {
    _currentCollectableButton = nil;
    [super clearCollectableViews];
}

- (void)clearViews; {
    [self _setSynchronizeCollectableSelection:NO];
    [super clearViews];
}

- (void)setCollectableViews:(NSArray *)views; {
    [super setCollectableViews:views];

    [self _setAutoUXLayoutWhenExpanding:self.autoUXLayoutWhenExpanding];
    [self _setSynchronizeCollectableSelection:self.synchronizeCollectableSelection];
    [self setUserInteractionToSelectCollectables];

    _currentCollectableButton = !views || !views.count ? nil : [views st_objectOrNilAtIndex:self.currentCollectableIndex];
}

#pragma mark Impl.
+ (instancetype)setButtonsWithCollectables:(NSArray *)imageNames size:(CGSize)buttonSize colllectableIcons:(NSArray *)colllectableIcons colllectableSize:(CGSize)radialSize maskColors:(NSArray *)colors; {
    return [self setButtonsWithCollectables:imageNames size:buttonSize colllectableIcons:colllectableIcons colllectableSize:radialSize maskColors:colors bgColors:nil];
}

+ (instancetype)setButtonsWithCollectables:(NSArray *)imageNames size:(CGSize)buttonSize colllectableIcons:(NSArray *)colllectableIcons colllectableSize:(CGSize)radialSize maskColors:(NSArray *)colors bgColors:(NSArray *)bgColors; {
    STStandardCollectableButton* button = [[STStandardCollectableButton alloc] initWithFrame:CGRectMakeWithSize_AGK(buttonSize)];
    [button setButtonsWithCollectables:imageNames size:buttonSize colllectableIcons:colllectableIcons colllectableSize:radialSize maskColors:colors bgColors:bgColors];
    return button;
}

- (instancetype)setButtonsWithCollectables:(NSArray *)imageNames
                                      size:(CGSize)buttonSize
                         colllectableIcons:(NSArray *)colllectableIcons
                          colllectableSize:(CGSize)radialSize
                                maskColors:(NSArray *)colors
                                  bgColors:(NSArray *)bgColors; {

    [self setButtons:imageNames colors:colors bgColors:bgColors];
    [self setCollectables:colllectableIcons colors:[colors copy] bgColors:bgColors size:radialSize];
    return self;
}

- (instancetype)setCollectablesAsDefault:(NSArray *)imageNames{
    return [self setCollectables:imageNames colors:nil size:[STStandardLayout sizeSubAssistance]];
}

- (instancetype)setCollectables:(NSArray *)imageNames colors:(NSArray *)colors size:(CGSize)size; {
    return [self setCollectables:imageNames colors:colors bgColors:nil size:size];
}

- (instancetype)setCollectables:(NSArray *)imageNames colors:(NSArray *)colors bgColors:(NSArray *)bgColors size:(CGSize)size; {
    return [self setCollectables:imageNames colors:colors bgColors:bgColors size:size style:STStandardButtonStylePTBT];
}

- (instancetype)setCollectables:(NSArray *)imageNames colors:(NSArray *)colors bgColors:(NSArray *)bgColors size:(CGSize)size style:(STStandardButtonStyle)style; {
    NSAssert(imageNames.count || colors.count, @"must filled item's count in imageNames or colors higher than 0 at least.");

    NSArray * targetSource = imageNames ? imageNames : colors;
    [self setCollectableViews:[targetSource mapWithIndex:^id(id object, NSInteger index) {
        STStandardButton *button = [[STStandardButton alloc] initWithFrame:CGRectMakeWithSize_AGK(size)];
        NSString * image = [imageNames st_objectOrNilAtIndex:index];
        UIColor * color = [colors st_objectOrNilAtIndex:index];
        UIColor * bgcolor = [bgColors st_objectOrNilAtIndex:index];
        button.autoAdjustVectorIconImagePaddingIfNeeded = NO;
        [button setButtons:image ? @[image] : nil
                    colors:color ? @[color] : nil
                  bgColors:bgcolor ? @[bgcolor] : nil
                     style:style];

        return button;
    }]];
    return self;
}

#pragma mark UserInteraction
- (void)setUserInteractionToSelectCollectables {
    Weaks
    for(STStandardButton * button in self.collectableView.itemViews){
        if(_collectablesUserInteractionEnabled){
            button.userInteractionEnabled = YES;
            [button whenSelected:^(STSelectableView *selectedView, NSInteger index) {
                if(Wself.collectableToggleEnabled){
                    Wself.collectableSelectedState = !Wself.collectableSelectedState;
                }else{
                    Wself.currentCollectableIndex = [Wself.collectableView.itemViews indexOfObject:selectedView];
                }
                [Wself dispatchCollectableSelected];
            }];

        }else{
            button.userInteractionEnabled = NO;
            [button whenSelected:nil];
        }
    }
}

- (void)setCollectablesUserInteractionEnabled:(BOOL)collectablesUserInteractionEnabled {
    if(_collectablesUserInteractionEnabled != collectablesUserInteractionEnabled){
        _collectablesUserInteractionEnabled = collectablesUserInteractionEnabled;
        [self setUserInteractionToSelectCollectables];
    }
}

- (void)setCollectablesSelectAsIndependent:(BOOL)collectablesSelectAsIndependent; {
    if(_collectablesSelectAsIndependent != collectablesSelectAsIndependent){
        _collectablesSelectAsIndependent = collectablesSelectAsIndependent;
        [self setUserInteractionToSelectCollectables];
    }
}

- (void)setAutoUXLayoutWhenExpanding:(BOOL)autoUXLayoutWhenExpanding; {
    [self _setAutoUXLayoutWhenExpanding:autoUXLayoutWhenExpanding];

    if(_autoUXLayoutWhenExpanding != autoUXLayoutWhenExpanding){
        _autoUXLayoutWhenExpanding = autoUXLayoutWhenExpanding;
        [self setUserInteractionToSelectCollectables];
    }
}

- (void)_setAutoUXLayoutWhenExpanding:(BOOL)autoUXLayoutWhenExpanding; {
    Weaks
    CGFloat itemHeight = self.collectableView.itemViews.count ? [self.collectableView itemViewAtIndex:0].height : 0;

    if(autoUXLayoutWhenExpanding){

        self.collectableView.blockForWillRetract = ^(BOOL animation){
            CGFloat _y = Wself.initialFrame.origin.y;
            if([Wself st_isSuperviewsVisible]){
                [STStandardUX setAnimationFeelsToFastShortSpring:Wself];
                Wself.spring.y=_y;

            }else {
                Wself.y=_y;
            }
        };

        self.collectableView.blockForWillExpand = ^(BOOL animation){
            // 1 item + top button only
            if(Wself.collectableView.itemViews.count==1 && Wself.collectableView.startDegree == 0){
                CGFloat _y = Wself.initialFrame.origin.y + (itemHeight+Wself.collectableView.paddingForAutofitDistance)*.5f;
                if([Wself st_isSuperviewsVisible]){
                    [STStandardUX setAnimationFeelsToFastShortSpring:Wself];
                    Wself.spring.y=_y;

                }else {
                    Wself.y=_y;
                }
            }
        };

        if(self.collectableView.isExpanded){
            !self.collectableView.blockForWillExpand ?:self.collectableView.blockForWillExpand(NO);
        }
    }
}

- (void)setSynchronizeCollectableSelection:(BOOL)synchronizeCollectableSelection; {
    if(_synchronizeCollectableSelection != synchronizeCollectableSelection){
        [self _setSynchronizeCollectableSelection:synchronizeCollectableSelection];
        _synchronizeCollectableSelection = synchronizeCollectableSelection;
    }
    self.subtitleLabelSyncWhenSelected = synchronizeCollectableSelection;
}

- (void)_setSynchronizeCollectableSelection:(BOOL)syncWhenSelected; {
    NSString * t_currentButtonIndex = [@"syncWhenSelected" st_add:@keypath(self.currentCollectableIndex)];
    NSString * t_currentIndex = [@"syncWhenSelected" st_add:@keypath(self.currentIndex)];

    if(syncWhenSelected){
        self.currentCollectableIndex = self.currentIndex;

        Weaks
        [self bk_addObserverForKeyPath:@keypath(self.currentCollectableIndex) identifier:t_currentButtonIndex options:NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
            if([obj currentCollectableIndex]==[obj currentIndex]){
                return;
            }
            NSAssert(Wself.synchronizeCollectableSelection ? Wself.collectableView.count == Wself.count : YES,@"must be same item count. check 'syncWhenSelected'.");
            [obj setCurrentIndex:[obj currentCollectableIndex]];
        }];

        [self bk_addObserverForKeyPath:@keypath(self.currentIndex) identifier:t_currentIndex options:NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
            if([obj currentCollectableIndex]==[obj currentIndex]){
                return;
            }
            NSAssert(Wself.synchronizeCollectableSelection ? Wself.collectableView.count == Wself.count : YES ,@"must be same item count. check 'syncWhenSelected'.");
            [obj setCurrentCollectableIndex:[obj currentIndex]];
        }];
    }else{
        [self bk_removeObserversWithIdentifier:t_currentButtonIndex];
        [self bk_removeObserversWithIdentifier:t_currentIndex];
    }
}

- (void)setCurrentCollectableIndex:(NSUInteger)currentCollectableIndex; {
    if(!self.collectableView.count){
        return;
    }

    NSAssert(currentCollectableIndex < self.collectableView.count, @"currentRadialButtonIndex < self.collectableView.count");

    _currentCollectableButton = (STStandardButton *) [self.collectableView itemViewAtIndex:currentCollectableIndex];

    if(self.collectablesSelectAsIndependent){

    }else{
        if(self.collectableView.count>1){
            self.collectableSelectedState = YES;
        }
    }
}

- (NSUInteger)currentCollectableIndex; {
    if(_currentCollectableButton && self.collectableView.count){
        NSAssert([self.collectableView.itemViews containsObject:_currentCollectableButton], @"_currentCollectableButton must contains in self.collectableView.itemViews");
        return [self.collectableView.itemViews indexOfObject:_currentCollectableButton];
    }
    return 0;
}

- (void)setCollectableSelectedState:(BOOL)collectableSelectedState; {
    NSAssert(!self.collectablesSelectAsIndependent, @"can't use this when self.selectCollectablesAsIndependent==YES");

    _collectableSelectedState = collectableSelectedState;

    [self _setCollectableButtonSelectedState:collectableSelectedState];
}

- (void)_setCollectableButtonSelectedState:(BOOL)collectableButtonSelectedState; {
    if(self.collectablesSelectAsIndependent){
        return;
    }

    [self _clearCollectableButtonSelectedState];
    _currentCollectableButton.selectedState = collectableButtonSelectedState;
}

- (void)_clearCollectableButtonSelectedState {
    [self.collectableView.itemViews eachWithIndexMatchClass:STStandardButton.class block:^(STStandardButton *button, NSUInteger index) {
        button.selectedState = NO;
    }];
}

- (void)setCollectableToggleEnabled:(BOOL)collectableToggleEnabled; {
    NSAssert(!self.collectablesSelectAsIndependent, @"can't use this when self.selectCollectablesAsIndependent==YES");

    _collectableToggleEnabled = collectableToggleEnabled;
    [self _setCollectableButtonToggleEnabled:collectableToggleEnabled];
}

- (void)_setCollectableButtonToggleEnabled:(BOOL)collectableButtonToggleEnabled;  {
    if(self.collectablesSelectAsIndependent){
        return;
    }

    [self.collectableView.itemViews eachWithIndexMatchClass:STStandardButton.class block:^(STStandardButton *button, NSUInteger index) {
        button.toggleEnabled = collectableButtonToggleEnabled;
    }];
}

#pragma mark Selection
- (void)whenCollectableSelected:(void (^)(STStandardButton *button, NSUInteger index))block; {
    _whenCollectableSelected = block;
}

- (void)dispatchCollectableSelected {
    !_whenCollectableSelected ?: _whenCollectableSelected(_currentCollectableButton, self.currentCollectableIndex);

    if(self.autoRetractWhenSelectCollectableItem){
        [self retract];
    }
}

@end