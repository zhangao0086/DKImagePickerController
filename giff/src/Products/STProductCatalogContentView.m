//
// Created by BLACKGENE on 2016. 2. 2..
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STProductCatalogContentView.h"
#import "STApp+Products.h"
#import "STStandardButton.h"
#import "TTTAttributedLabel.h"
#import "UIView+STUtil.h"
#import "NSString+STUtil.h"
#import "SVGKImage.h"
#import "NSObject+STUtil.h"
#import "SVGKFastImageView.h"
#import "M13OrderedDictionary.h"
#import "SVGKFastImageView+STUtil.h"
#import "NSObject+STThreadUtil.h"
#import "STProductCatalogView.h"
#import "DFAnimatedImageView.h"
#import <DFImageManager/DFImageManagerKit+UI.h>
#import <DFImageManager/DFImageTask.h>

//https://rawgit.com/
//http://blog.davidebbo.com/2014/11/using-issues-for-github-pages-screenshots.html
//https://developer.github.com/changes/2014-04-25-user-content-security/

@implementation STProductCatalogContentView {
    TTTAttributedLabel * _titleLabel;
    TTTAttributedLabel * _descLabel;
    DFAnimatedImageView * _backgroundView;

    STProductItem * _productItem;
    M13OrderedDictionary * _productIconImages;
}

- (void)createContent {
    [super createContent];
}

- (void)setProductItem:(STProductItem *)productItem {
    _productItem = productItem;

    [self setContents];

    Weaks
    if(_productItem){
        [_productItem loadCatalogImages:NO completion:^(NSArray *contentImageUrls) {
            [Wself setContents];
            [Wself setContentImages:contentImageUrls];
            [Wself layoutIfNeeded];
        }];
    }else{
        [self setContentImages:nil];
    }

    [self layoutIfNeeded];
}

- (void)setContents {
    //refresh values

    //set title
    NSString * titleText = _productItem.localizedTitle;
    if(titleText){
        if(!_titleLabel){
            _titleLabel = [[TTTAttributedLabel alloc] initWithSizeWidth:self.width*.9f];
            _titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:24.0f];
            _titleLabel.textColor = [STStandardUI textColorLighten];
            _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _titleLabel.userInteractionEnabled = NO;
            _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _titleLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:_titleLabel];
        }

        if(![_titleLabel.text isEqualToString:titleText]){
            _titleLabel.numberOfLines = 2;
        }

        _titleLabel.text = titleText;

    }else{
        [_titleLabel removeFromSuperview];
        _titleLabel = nil;
    }

    //set description
    NSString * desc = _productItem.localizedDescription;
    if(desc){
        if(!_descLabel){
            _descLabel = [[TTTAttributedLabel alloc] initWithSizeWidth:self.width*.85f];
            _descLabel.font = [UIFont fontWithName:@"Avenir-Light" size:16.0f];
            _descLabel.textColor = [STStandardUI textColorLighten];
            _descLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _descLabel.userInteractionEnabled = NO;
            _descLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _descLabel.textAlignment = NSTextAlignmentNatural;
            _descLabel.clipsToBounds = NO;
            [self addSubview:_descLabel];
        }

        _descLabel.text = desc;
        _descLabel.numberOfLines = 20;

    }else{
        [_descLabel removeFromSuperview];
        _descLabel = nil;
    }
}

- (void)setContentImages:(NSArray *)imageUrls {
    /*
     * background images
     */
    [_backgroundView prepareForReuse];

    if(imageUrls){
        Weaks
        if(!_backgroundView){
            _backgroundView = [[DFAnimatedImageView alloc] initWithSize:self.size];
            _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
            [self insertSubview:_backgroundView atIndex:0];
            [_backgroundView st_coverBlur:NO styleDark:YES completion:nil];
        }
        _backgroundView.st_coveredView.alpha = 0;
        _backgroundView.alpha = 0;
        _backgroundView.allowsAnimations = NO;
        [_backgroundView setImageWithRequest:[DFImageRequest requestWithResource:[[imageUrls firstObject] URL]]];
        [_backgroundView.imageTask whenNewValueOnceOf:@"state" changed:^(id value, id _weakSelf) {
            Strongs
            WeakAssign(Sself)
            if(DFImageTaskStateCompleted == [value unsignedIntegerValue]){
                [Sself st_runAsMainQueueAsyncWithSelf:^(id selfObject) {
                    [UIView animateWithDuration:4 animations:^{
                        _backgroundView.alpha = 1;
                        _backgroundView.st_coveredView.alpha = [STStandardUI alphaForDimming];
                    }];

                    [weak_Sself whenLongTouchAsTapDownUp:^(UITouchLongPressGestureRecognizer *sender, CGPoint location) {
                        StrongsAssign(weak_Sself)
                        [UIView animateWithDuration:.5 animations:^{
                            [strong_weak_Sself showOnlyBackground:YES];
                        }];

                    } changed:nil ended:^(UITouchLongPressGestureRecognizer *sender, CGPoint location) {
                        StrongsAssign(weak_Sself)
                        [UIView animateWithDuration:.8 animations:^{
                            [strong_weak_Sself showOnlyBackground:NO];
                        }];
                    }];
                }];
            }
        }];

    }else{
        [self showOnlyBackground:NO];
        [self whenLongTapped:nil];
        [_backgroundView.imageTask cancel];
        [_backgroundView.imageManager stopPreheatingImagesForAllRequests];
        [_backgroundView.imageManager removeAllCachedImages];
        [_backgroundView.imageTask st_removeAllKeypathListeners];
        [_backgroundView st_coverRemove:NO];
        [_backgroundView displayImage:nil];
        [_backgroundView clearAllOwnedImagesIfNeededAndRemoveFromSuperview:NO];
        _backgroundView = nil;
    }
}

- (void)showOnlyBackground:(BOOL)show{
    Weaks
    [self st_eachSubviews:^(UIView *view, NSUInteger index) {
        Strongs
        if(![view isEqual:Sself->_backgroundView]){
            view.alpha = show ? 0 : 1;
        }
    }];
    STProductCatalogView * catalogView = [Wself.superview isKindOfClass:STProductCatalogView.class] ? (STProductCatalogView *)Wself.superview : nil;
    catalogView.closeButton.alpha =
            catalogView.purchaseButton.alpha =
                    catalogView.restoreButton.alpha = show ? 0 : 1;
    _backgroundView.st_coveredView.alpha = show ? [STStandardUI alphaForDimmingGhostly] : [STStandardUI alphaForDimming];
}

- (void)setProductIconImages:(M13OrderedDictionary *)productIconImages {
    _productIconImages = productIconImages;

#if DEBUG
    if(_productIconImages.count>20){
        oo(@"[!] WARNING : max pretty layout count is over.");
    }
#endif

    /*
     * icons
     */
    if(_productIconImages){
        if(!_iconImageViewContainer){
            _iconImageViewContainer = [[UIView alloc] initWithFrame:self.bounds];
            _iconImageViewContainer.contentMode = UIViewContentModeScaleAspectFit;
        }

        NSMutableDictionary *labelImageNames = [NSMutableDictionary dictionary];
        for(NSString * label in _productIconImages){
            id item = _productIconImages[label];
            if([item isKindOfClass:NSDictionary.class]){
                [labelImageNames addEntriesFromDictionary:((NSDictionary *)item)];
            }else{
                [labelImageNames addEntriesFromDictionary:@{label : item}];
            }
        }

        NSUInteger setCount = labelImageNames.count;
        BOOL multiple = setCount % 2 == 0;
        //기기별 달라야 할 수도
        CGFloat paddingHorizontal;
        NSUInteger colCount;
        CGFloat paddingEachW;
        CGFloat paddingEachH;
        CGFloat colWidth;

        //FIXME : 이게 뭐냐 일관된 로직으로 변경 -> 라이브러리화
        //filter
        if(labelImageNames.count>=20){
            colCount = labelImageNames.count>=30? 6 : 5;
            paddingHorizontal = self.width/14;
            colWidth = (self.width/colCount)-paddingHorizontal;
            paddingEachW = colWidth/3.6f;
            paddingEachH = colWidth/3.6f;
        }//settings
        else{
            colCount = multiple && setCount<5 ? 2 : 3;
            paddingHorizontal = colCount==2 ? 100 : 50;
            paddingEachW = paddingHorizontal/(setCount>3 ? 2 : 1.5f);
            paddingEachH = paddingHorizontal/(setCount>3 && colCount==2 ? 5 : 1.5f);
            colWidth = (self.width/colCount)-paddingHorizontal;
        }

        [self addSubview:_iconImageViewContainer];

        for(id label in labelImageNames){
            @autoreleasepool {
                id imageSource = labelImageNames[label];
                UIView * iconImageView = nil;

                if([imageSource isKindOfClass:NSString.class] && [((NSString *) imageSource).pathExtension isEqualToString:@"svg"]){
                    //TODO: 메모리 비교를 해봄
                    //iconImageView = [[UIImageView alloc] initWithImage:[[SVGKImage imageNamedNoCache:labelImageNames[label] widthSizeWidth:colWidth] UIImage]];
                    iconImageView = [SVGKFastImageView viewWithImageNamedNoCache:labelImageNames[label] sizeWidth:colWidth];
                }else{
                    iconImageView = [UIView st_createViewFromPresentableObject:imageSource];
                    iconImageView.size = CGSizeMakeValue(colWidth);
                }

                [_iconImageViewContainer addSubview:iconImageView];
#if DEBUG
                [self attachLabelToContentItemViewForDebug:iconImageView label:label];
#endif
            }
        }
        [_iconImageViewContainer sizeToFitSubviewsUnionSize];
        [_iconImageViewContainer st_gridSubviewsAsCenter:paddingEachW rowHeight:colWidth + paddingEachH column:colCount];
        [_iconImageViewContainer centerToParentHorizontal];

    }else{
        [_iconImageViewContainer clearAllOwnedImagesIfNeededAndRemoveFromSuperview:NO];
        _iconImageViewContainer = nil;
    }

    [self layoutIfNeeded];
}

- (CGFloat)st_maxSubviewWidth {
    return self.width-60*2;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [_titleLabel sizeToFit];
    [_titleLabel centerToParentHorizontal];
    _titleLabel.y = self.height/14;

    [_descLabel sizeToFit];
    [_descLabel centerToParentHorizontal];

    if(_iconImageViewContainer){
        _iconImageViewContainer.y = _titleLabel.bottom + _titleLabel.y;
        _descLabel.y = _iconImageViewContainer.bottom + _titleLabel.y;
    }else{
        _descLabel.y = _titleLabel.bottom + _titleLabel.height*1.2f;
    }
}

- (void)attachLabelToContentItemViewForDebug:(UIView *)itemView label:(NSString *)label {
    TTTAttributedLabel * _debugFilterInfoLabel;
    _debugFilterInfoLabel = [[TTTAttributedLabel alloc] initWithSizeWidth:itemView.width];
    _debugFilterInfoLabel.font = [UIFont systemFontOfSize:6];
    _debugFilterInfoLabel.textColor = [STStandardUI textColorLighten];
    _debugFilterInfoLabel.lineBreakMode = NSLineBreakByClipping;
    _debugFilterInfoLabel.userInteractionEnabled = NO;
    _debugFilterInfoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _debugFilterInfoLabel.textAlignment = NSTextAlignmentCenter;
    _debugFilterInfoLabel.numberOfLines = 1;

    [itemView addSubview:_debugFilterInfoLabel];
    itemView.clipsToBounds = NO;

    _debugFilterInfoLabel.text = label;
    [_debugFilterInfoLabel sizeToFit];
    [_debugFilterInfoLabel centerToParentHorizontal];
    _debugFilterInfoLabel.top = 0;
}
@end
