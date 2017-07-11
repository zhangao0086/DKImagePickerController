//
//  DKImageResource.h
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/6/26.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>




@interface NSBundle (DKExtension)
+ (NSBundle *)imagePickerControllerBundle;
@end


@interface DKImageResource : NSObject

+ (UIImage *)checkedImage;
+ (UIImage *)blueTickImage;
+ (UIImage *)cameraImage;
+ (UIImage *)videoCameraIcon;
+ (UIImage *)emptyAlbumIcon;

@end

@interface DKImageLocalizedString : NSObject
+ (NSString *)localizedStringForKey:(NSString *)key;
@end

