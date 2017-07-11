//
//  CustomGroupDetailImageCell.m
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/7/10.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "CustomGroupDetailImageCell.h"
#import "DKImageResource.h"
@interface CustomGroupDetailImageCell()
@property (nonatomic, strong) UIImageView * thumbnailImageView;
@property (nonatomic, strong) UIImageView * checkView;
@end


@implementation CustomGroupDetailImageCell
+ (NSString *)cellReuseIdentifier{
    return @"CustomGroupDetailImageCell";
}

- (UIImageView *)thumbnailImageView{
    if (!_thumbnailImageView) {
        _thumbnailImageView = [UIImageView new];
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailImageView.clipsToBounds = YES;
    }
    
    return _thumbnailImageView;
    
}

- (UIImageView *)checkView{
    if (!_checkView) {
        _checkView = [[UIImageView alloc] initWithImage:[DKImageResource blueTickImage]];
        _checkView.contentMode = UIViewContentModeCenter;
    }
    return _checkView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.thumbnailImageView.frame = self.bounds;
        self.thumbnailImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.contentView addSubview:self.thumbnailImageView];
        
        self.checkView.frame = self.bounds;
        self.checkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.contentView addSubview:self.checkView];
        
    }
    return self;
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage{
    super.thumbnailImage = thumbnailImage;
    self.thumbnailImageView.image = thumbnailImage;
}
- (void)setSelected:(BOOL)selected{
    super.selected = selected;
    if (super.selected) {
        self.thumbnailImageView.alpha = 0.5;
        self.checkView.hidden = NO;
    }else{
        self.thumbnailImageView.alpha = 1;
        self.checkView.hidden = YES;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
