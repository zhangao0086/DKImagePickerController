//
//  CustomCamera.m
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/7/7.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "CustomCamera.h"

@interface CustomCamera ()


@end

@implementation CustomCamera

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    // Do any additional setup after loading the view.
}


#pragma mark -- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString * mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage * image = info[UIImagePickerControllerOriginalImage];
        if (self.didFinishCapturingImage) {
            self.didFinishCapturingImage(image);
        }
    }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
        NSURL * videoURL = info[UIImagePickerControllerMediaURL];
        if (self.didFinishCapturingVideo) {
            self.didFinishCapturingVideo(videoURL);
        }
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    if (self.didCancel) {
        self.didCancel();
    }
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
