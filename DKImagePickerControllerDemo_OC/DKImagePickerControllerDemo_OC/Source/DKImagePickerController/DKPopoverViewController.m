//
//  DKPopoverViewController.m
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/7/3.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKPopoverViewController.h"

@interface DKPopoverView : UIView
@property (nonatomic, strong) UIView * contentView;
@property (nonatomic, assign) CGFloat arrowWidth;
@property (nonatomic, assign) CGFloat arrowHeight;
@property (nonatomic, strong) UIImageView * arrowImageView;
@end

@implementation DKPopoverView
- (instancetype)init{
    if (self = [super init]) {
        _arrowWidth = 20;
        _arrowHeight = 10;
        _arrowImageView = [UIImageView new];
        _arrowImageView.image = [self arrowImage];
        [self addSubview:_arrowImageView];
    }
    return self;
}

- (UIImage *)arrowImage{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(_arrowWidth, _arrowHeight), NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor clearColor] setFill];
    CGContextFillRect(context, CGRectMake(0, 0, _arrowWidth, _arrowHeight));
    CGMutablePathRef arrowPath = CGPathCreateMutable();
    
    CGPathMoveToPoint(arrowPath, nil, _arrowWidth/2, 0);
    
    CGPoint points[] = {CGPointMake(_arrowWidth, _arrowHeight)};
    CGPathAddLines(arrowPath, nil, points, 1);
    
    CGPoint points1[] = {CGPointMake(0, _arrowHeight)};
    CGPathAddLines(arrowPath, nil, points1, 1);
    
    CGPathCloseSubpath(arrowPath);
    
    CGContextAddPath(context, arrowPath);
    
    CGContextSetFillColor(context, CGColorGetComponents([UIColor redColor].CGColor));
    CGContextDrawPath(context, kCGPathFill);
    UIImage * arrowImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return arrowImage;
}

- (void)setContentView:(UIView *)contentView{
    if (_contentView != contentView) {
        _contentView = contentView;
        _contentView.layer.cornerRadius = 5;
        _contentView.clipsToBounds = YES;
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_contentView];

    }
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.arrowImageView.frame = CGRectMake((self.bounds.size.width - self.arrowWidth) / 2, 0, _arrowWidth, _arrowHeight);
    self.contentView.frame = CGRectMake(0, self.arrowHeight, self.bounds.size.width, self.bounds.size.height - _arrowHeight);
}








@end






@interface DKPopoverViewController ()
@property (nonatomic, strong) UIViewController * contentViewController;
@property (nonatomic, strong) UIView * fromView;
@property (nonatomic, strong) DKPopoverView * popoverView;
@end

@implementation DKPopoverViewController
+ (void)popoverViewController:(UIViewController *)viewController
                     fromView:(UIView *)fromView{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    DKPopoverViewController * popoverViewController = [self new];
    popoverViewController.contentViewController = viewController;
    popoverViewController.fromView = fromView;
    
    [popoverViewController showInView:window];
    [window.rootViewController addChildViewController:popoverViewController];
}


+ (void)dismissPopoverViewController{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    for (UIViewController * vc in window.rootViewController.childViewControllers) {
        if ([vc isKindOfClass:[DKPopoverViewController class]]) {
            [(DKPopoverViewController * )vc dismiss];
        }
    }
}
- (instancetype)init{
    if (self = [super init]) {
        _popoverView = [DKPopoverView new];
    }
    return self;
}
- (void)loadView{
    [super loadView];
    UIControl * backgroundView = [[UIControl alloc] initWithFrame:self.view.bounds];
    backgroundView.backgroundColor = [UIColor clearColor];
    [backgroundView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    backgroundView.autoresizingMask = self.view.autoresizingMask;
    self.view = backgroundView;
}
- (void)dismiss{
    [UIView animateWithDuration:0.2 animations:^{
        CGAffineTransform form = CGAffineTransformTranslate(self.popoverView.transform, 0, -(self.popoverView.bounds.size.height/2));
        self.popoverView.transform = CGAffineTransformScale(form, 0.01, 0.01);
        
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}
- (void)showInView:(UIView *)view{
    [view addSubview:self.view];
    self.popoverView.contentView = self.contentViewController.view;
    self.popoverView.frame = [self calculatePopoverViewFrame];
    
    CGAffineTransform form = CGAffineTransformTranslate(self.popoverView.transform, 0, -(self.popoverView.bounds.size.height/2));
    self.popoverView.transform = CGAffineTransformScale(form, 0.1, 0.1);
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.3 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.popoverView.transform = CGAffineTransformIdentity;
        self.view.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.4];
    } completion:^(BOOL finished) {
        
    }];
}

- (CGRect)calculatePopoverViewFrame{
    CGFloat popoverY = [self.fromView convertPoint:self.fromView.frame.origin toView:self.view].y + self.fromView.bounds.size.height;
    CGFloat popoverWidth = self.contentViewController.preferredContentSize.width;
    if (popoverWidth == UIViewNoIntrinsicMetric) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            popoverWidth = self.view.bounds.size.width * 0.6;
        }else{
            popoverWidth = self.view.bounds.size.width;
        }
    }
    CGFloat popoverHeight = MIN(self.contentViewController.preferredContentSize.height + self.popoverView.arrowHeight, self.view.bounds.size.height - popoverY - 40);
    
    return CGRectMake((self.view.bounds.size.width - popoverWidth)/2, popoverY, popoverWidth, popoverHeight);
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.popoverView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
