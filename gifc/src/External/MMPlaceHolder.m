//
//  MMPlaceHolder.m
//  driving
//
//  Created by Ralph Li on 8/11/14.
//  Copyright (c) 2014 LJC. All rights reserved.
//

#import "MMPlaceHolder.h"

@interface  MMPlaceHolderConfig()

@end

@implementation MMPlaceHolderConfig


- (id)init
{
    self = [super init];

    if (self) {

        self.lineColor = [UIColor whiteColor];
        self.backColor = [UIColor clearColor];
        self.arrowSize = 3;
        self.lineWidth = 1;
    }

    return self;
}

+ (MMPlaceHolderConfig *)defaultConfig
{
    static dispatch_once_t  onceQueue;
    static MMPlaceHolderConfig *appInstance;

    dispatch_once(&onceQueue, ^{
        appInstance = [[MMPlaceHolderConfig alloc] init];
    });
    return appInstance;
}

@end

@interface MMPlaceHolder()


@end

@implementation MMPlaceHolder

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeRedraw;
        self.userInteractionEnabled = NO;

        self.lineColor = [MMPlaceHolderConfig defaultConfig].lineColor;
        self.backColor = [MMPlaceHolderConfig defaultConfig].backColor;
        self.arrowSize = [MMPlaceHolderConfig defaultConfig].arrowSize;
        self.lineWidth = [MMPlaceHolderConfig defaultConfig].lineWidth;

        self.tag = [NSStringFromClass([self class]) hash];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code

    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;

    CGFloat fontSize = 4 + (MIN(width,height))/10;
    CGFloat arrowSize = self.arrowSize;
    CGFloat lineWidth = self.lineWidth;

    UIFont *font = [UIFont systemFontOfSize:fontSize];

    //fill the back
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, self.backColor.CGColor);
    CGContextFillRect(ctx, rect);

    //strike lines & arrows
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetStrokeColorWithColor(ctx, self.lineColor.CGColor);

    CGContextMoveToPoint(ctx, width/2, 0);
    CGContextAddLineToPoint(ctx, width/2, height);
    CGContextMoveToPoint(ctx, width/2, 0);
    CGContextAddLineToPoint(ctx, width/2-arrowSize, arrowSize);
    CGContextMoveToPoint(ctx, width/2, 0);
    CGContextAddLineToPoint(ctx, width/2+arrowSize, arrowSize);
    CGContextMoveToPoint(ctx, width/2, height);
    CGContextAddLineToPoint(ctx, width/2-arrowSize, height-arrowSize);
    CGContextMoveToPoint(ctx, width/2, height);
    CGContextAddLineToPoint(ctx, width/2+arrowSize, height-arrowSize);

    CGContextMoveToPoint(ctx, 0, height/2);
    CGContextAddLineToPoint(ctx, width, height/2);
    CGContextMoveToPoint(ctx, 0, height/2);
    CGContextAddLineToPoint(ctx, arrowSize, height/2-arrowSize);
    CGContextMoveToPoint(ctx, 0, height/2);
    CGContextAddLineToPoint(ctx, arrowSize, height/2+arrowSize);
    CGContextMoveToPoint(ctx, width, height/2);
    CGContextAddLineToPoint(ctx, width-arrowSize, height/2-arrowSize);
    CGContextMoveToPoint(ctx, width, height/2);
    CGContextAddLineToPoint(ctx, width-arrowSize, height/2+arrowSize);

    CGContextStrokePath(ctx);

    //calculate the text area
    NSString *strLabel = [NSString stringWithFormat:@"%.0f X %.0f",width, height];


#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    const CGSize labelSize = [strLabel sizeWithFont:font forWidth:CGFLOAT_MAX lineBreakMode:NSLineBreakByClipping];

    CGFloat rectWidth = roundf(labelSize.width)+4;
    CGFloat rectHeight = roundf(labelSize.height)+4;

    //clear the area behind the textz
    CGRect strRect = CGRectMake(width/2-rectWidth/2, height/2-rectHeight/2, rectWidth, rectHeight);
    CGContextClearRect(ctx, strRect);
    CGContextSetFillColorWithColor(ctx, self.backColor.CGColor);
    CGContextFillRect(ctx, strRect);

    //draw text
    CGContextSetFillColorWithColor(ctx, self.lineColor.CGColor);
    [strLabel drawInRect:CGRectInset(strRect, 0, 2) withFont:font lineBreakMode:NSLineBreakByTruncatingMiddle alignment:NSTextAlignmentCenter];
#pragma GCC diagnostic warning "-Wdeprecated-declarations"
}


@end


@interface UIView ()
@end

@implementation UIView(MMPlaceHolder)

- (void)showPlaceHolder
{
    [self showPlaceHolderWithLineColor:[MMPlaceHolderConfig defaultConfig].lineColor];
}

- (void)showPlaceHolderWithAllSubviews
{
    [self showPlaceHolderWithAllSubviews:NSIntegerMax];
}

- (void)showPlaceHolderWithAllSubviews:(NSInteger)maxDepth
{
    if ( maxDepth > 0 )
    {
        for ( UIView *v in self.subviews )
        {
            [v showPlaceHolderWithAllSubviews:maxDepth-1];
        }
    }

    [self showPlaceHolder];

}

- (void)showPlaceHolderWithLineColor:(UIColor *)lineColor
{
    [self showPlaceHolderWithLineColor:lineColor backColor:[MMPlaceHolderConfig defaultConfig].backColor];
}

- (void)showPlaceHolderWithLineColor:(UIColor *)lineColor backColor:(UIColor *)backColor
{
    [self showPlaceHolderWithLineColor:lineColor backColor:backColor arrowSize:[MMPlaceHolderConfig defaultConfig].arrowSize];
}


- (void)showPlaceHolderWithLineColor:(UIColor *)lineColor backColor:(UIColor *)backColor arrowSize:(CGFloat)arrowSize
{
    [self showPlaceHolderWithLineColor:lineColor backColor:backColor arrowSize:arrowSize lineWidth:[MMPlaceHolderConfig defaultConfig].lineWidth];
}

- (void)showPlaceHolderWithLineColor:(UIColor *)lineColor backColor:(UIColor *)backColor arrowSize:(CGFloat)arrowSize lineWidth:(CGFloat)lineWidth
{

#if RELEASE

#else
    MMPlaceHolder *placeHolder = [[MMPlaceHolder alloc] initWithFrame:self.bounds];
    placeHolder.lineColor = lineColor;
    placeHolder.backColor = backColor;
    placeHolder.arrowSize = arrowSize;
    placeHolder.lineWidth = lineWidth;

    [self addSubview:placeHolder];

#endif
}

- (MMPlaceHolder *)getPlaceHolder
{
    return (MMPlaceHolder*)[self viewWithTag:[NSStringFromClass([MMPlaceHolder class]) hash]];
}

- (void)hidePlaceHolder
{
    MMPlaceHolder *placeHolder = [self getPlaceHolder];

    if ( placeHolder )
    {
        [placeHolder removeFromSuperview];
    }
}

@end
