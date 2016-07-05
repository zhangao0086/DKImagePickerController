//
// Created by BLACKGENE on 2016. 3. 13..
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STExportLoginContentView.h"
#import "JVFloatLabeledTextField.h"
#import "UIView+STUtil.h"
#import "SVGKImage.h"
#import "SVGKImage+STUtil.h"
#import "STExporter+Config.h"

@implementation STExportLoginContentView {
    JVFloatLabeledTextField * idText;
    JVFloatLabeledTextField * pwText;
    UIImageView * _titleImageView;
}

const static CGFloat kJVFieldHeight = 44.0f;
const static CGFloat kJVFieldHMargin = 10.0f;

const static CGFloat kJVFieldFontSize = 16.0f;

const static CGFloat kJVFieldFloatingLabelFontSize = 11.0f;

//https://github.com/jverdi/JVFloatLabeledTextField/blob/master/JVFloatLabeledTextField/JVFloatLabeledTextFieldViewController.m
- (void)loadContents{
    [super loadContents];

    //set tilte image name
    NSString * titleImageName = [STExporter iconImageName:self.exporter.type];
    if(titleImageName){
        UIImage * image = [SVGKImage imageNamedNoCache:titleImageName widthSizeWidth:self.width/3].UIImage;
        if(!_titleImageView){
            _titleImageView = [[UIImageView alloc] initWithImage:image];
            [self addSubview:_titleImageView];
        }else{
            _titleImageView.image = image;
        }
        [_titleImageView sizeToFit];

    }else{
        [_titleImageView clearAllOwnedImagesIfNeededAndRemoveFromSuperview:NO];
        _titleImageView = nil;
    }


    //id/pw
    UIColor *floatingLabelColor = [UIColor brownColor];

    //id
    idText = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectZero];
    idText.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    idText.tagName = @"id";
    idText.attributedPlaceholder =
            [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Account", @"")
                                            attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    idText.floatingLabelFont = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
    idText.floatingLabelTextColor = floatingLabelColor;
    idText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self addSubview:idText];
    idText.keepBaseline = YES;

    UIView *div1 = [UIView new];
    div1.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self addSubview:div1];

    //password
    pwText = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectZero];
    pwText.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    pwText.tagName = @"pw";
    pwText.attributedPlaceholder =
            [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Password", @"")
                                            attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    pwText.floatingLabelFont = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
    pwText.floatingLabelTextColor = floatingLabelColor;
    pwText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self addSubview:pwText];
    pwText.keepBaseline = YES;

    UIView *div2 = [UIView new];
    div2.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self addSubview:div2];

    idText.size = CGSizeMake(self.width*.9f, kJVFieldHeight);
    [idText centerToParentHorizontal];
    idText.bottom = self.centerY;
    [idText layoutIfNeeded];
    div1.width = idText.size.width;
    div1.bottom = idText.bottom;

    pwText.size = CGSizeMake(self.width*.9f, kJVFieldHeight);
    [pwText centerToParentHorizontal];
    pwText.top = self.centerY;
    [pwText layoutIfNeeded];
    div2.width = pwText.size.width;
    div2.top = pwText.top;

    idText.delegate = pwText.delegate = self;

//    [idText becomeFirstResponder];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [_titleImageView centerToParentHorizontal];
    _titleImageView.y = self.height / 12;

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    if([textField isEqual:idText]){
        [pwText becomeFirstResponder];
    }

    if([textField isEqual:pwText]){
        [self returnInputResults];
    }

    return NO;

}

- (void)returnInputResults{
    if([idText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length==0){
        [STStandardUX expressDenied:idText];
        return;
    }
    [idText resignFirstResponder];

    if([pwText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length==0){
        [STStandardUX expressDenied:pwText];
        return;
    }
    [pwText resignFirstResponder];

    !_didReturnInputBlock?:_didReturnInputBlock(idText.text, pwText.text);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    UITouch *touch = [[event allTouches] anyObject];

    [self st_eachSubviews:^(UIView *view, NSUInteger index) {
        if ([view isKindOfClass:JVFloatLabeledTextField.class] && [view isFirstResponder] && [touch view] != view) {
            [view resignFirstResponder];
        }
    }];

    [super touchesBegan:touches withEvent:event];
}
@end