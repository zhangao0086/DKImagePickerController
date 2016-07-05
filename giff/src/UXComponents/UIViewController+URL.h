//
// Created by BLACKGENE on 15. 9. 2..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIViewController (URL)
- (BOOL)openURL:(NSString *)url fallbackUrl:(NSString *)fallbackUrl relatedView:(UIView *)relatedView;
@end