//
//  DKAssetGroupDetailVideoCell.m
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/6/26.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKAssetGroupDetailVideoCell.h"
#import "DKImageResource.h"
@interface DKAssetGroupDetailVideoCell()

@property (nonatomic, strong) UIView * videoInfoView;

@end


@implementation DKAssetGroupDetailVideoCell
+ (NSString *)cellReuseIdentifier{
    return @"DKVideoAssetIdentifier";
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame: frame]) {
        [self.contentView addSubview:self.videoInfoView];
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat height = 30;
    self.videoInfoView.frame = CGRectMake(0, self.contentView.bounds.size.height - height, self.contentView.bounds.size.width, height);
}

- (void)setAsset:(DKAsset *)asset{
    if (self.asset != asset) {
        super.asset = asset;
        UILabel * videoDurationLabel = [self.videoInfoView viewWithTag:-1];
        NSInteger minutes = asset.duration / 60;
        NSInteger tem = round(asset.duration);
        NSInteger seconds = tem % 60;
        videoDurationLabel.text = [NSString stringWithFormat:@"%ld:%02ld", minutes, seconds];
    }
}

- (void)setSelected:(BOOL)selected{
    super.selected = selected;
    if (selected) {
        self.videoInfoView.backgroundColor = [UIColor colorWithRed:20/255 green:129/255 blue:252/255 alpha:1];
    }else{
        self.videoInfoView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    }
}

- (UIView *)videoInfoView{
    if (!_videoInfoView) {
        _videoInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 0)];
        UIImageView * videoImageView = [[UIImageView alloc] initWithImage:[DKImageResource videoCameraIcon]];
        [_videoInfoView addSubview:videoImageView];
        videoImageView.center = CGPointMake(videoImageView.bounds.size.width/2 + 7, _videoInfoView.bounds.size.height/2);
        videoImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        UILabel * videoDurationLabel = [UILabel new];
        videoDurationLabel.tag = -1;
        videoDurationLabel.textAlignment = NSTextAlignmentRight;
        videoDurationLabel.font = [UIFont systemFontOfSize:12];
        videoDurationLabel.textColor = [UIColor whiteColor];
        [_videoInfoView addSubview:videoDurationLabel];
        videoDurationLabel.frame = CGRectMake(0, 0, _videoInfoView.bounds.size.width - 7, _videoInfoView.bounds.size.height);
        videoDurationLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _videoInfoView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
