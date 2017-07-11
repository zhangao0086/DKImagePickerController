//
//  DKAssetGroupDetailImageCell.m
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/6/26.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKAssetGroupDetailImageCell.h"
#import "DKImageResource.h"
@interface DKImageCheckView()
@property (nonatomic, strong) UIImageView * checkImageView;
@property (nonatomic, strong) UILabel * checkLabel;
@end

@implementation DKImageCheckView
- (UIImageView *)checkImageView{
    if (!_checkImageView) {
        _checkImageView = [[UIImageView alloc] initWithImage:[[DKImageResource checkedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    }
    return _checkImageView;
}

- (UILabel *)checkLabel{
    if (!_checkLabel) {
        _checkLabel = [[UILabel alloc] init];
        _checkLabel.textAlignment = NSTextAlignmentRight;
    }
    return _checkLabel;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.checkImageView];
        [self addSubview:self.checkLabel];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.checkImageView.frame = self.bounds;
    self.checkLabel.frame = CGRectMake(0, 5, self.bounds.size.width - 5, 20);
}

@end



@interface DKAssetGroupDetailImageCell()
@property (nonatomic, strong) UIImageView * thumbnailImageView;
@property (nonatomic, strong) DKImageCheckView * checkView;
@end

@implementation DKAssetGroupDetailImageCell
+ (NSString *)cellReuseIdentifier{
    return @"DKImageAssetIdentifier";
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.thumbnailImageView.frame = self.bounds;
        self.thumbnailImageView.backgroundColor = [UIColor yellowColor];
        self.thumbnailImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.thumbnailImageView];
        
        self.checkView = [DKImageCheckView new];
        self.checkView.frame = self.bounds;
        self.checkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.checkView.checkImageView.tintColor = nil;
        self.checkView.checkLabel.font = [UIFont boldSystemFontOfSize:14];
        self.checkView.checkLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.checkView];

    }
    return self;
}

- (UIImageView *)thumbnailImageView{
    if (!_thumbnailImageView) {
        _thumbnailImageView = [[UIImageView alloc] init];
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailImageView.clipsToBounds = YES;
    }
    return _thumbnailImageView;
}
- (void)setThumbnailImage:(UIImage *)thumbnailImage{
    if (self.thumbnailImage != thumbnailImage) {
        super.thumbnailImage = thumbnailImage;
        self.thumbnailImageView.image = thumbnailImage;
    }
}

- (void)setIndex:(NSInteger)index{
    super.index = index;
    self.checkView.checkLabel.text = [NSString stringWithFormat:@"%ld", self.index + 1];
}

- (void)setSelected:(BOOL)selected{
    super.selected = selected;
    self.checkView.hidden = !selected;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
