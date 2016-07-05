#import "STCameraPermission.h"
@import AVFoundation;

@interface STCameraPermission ()

@end

@implementation STCameraPermission

+(instancetype)permissionWithLabelText:(NSString*)labelText{
    return [[super alloc] initWithType:STCameraPermissionType labelText:labelText];
}

-(void)updatePermissionStatus{
    // Check for availablity
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if(videoDevices.count == 0){
        self.status = STPermissionStatusServiceNotAvailable;
    } else {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(status == AVAuthorizationStatusNotDetermined){
            self.status = STPermissionStatusNotDetermined;
        } else if(status == AVAuthorizationStatusAuthorized){
            self.status = STPermissionStatusAuthorized;
        } else if(status == AVAuthorizationStatusDenied) {
            self.status = STPermissionStatusDenied;
        } else if(status == AVAuthorizationStatusRestricted) {
            self.status = STPermissionStatusRestricted;
        }
    }
}

-(void)presentSystemPromtWithCompletionBlock:(STPermissionEmptyBlock)completionBlock{
    dispatch_async(dispatch_get_main_queue(), ^{
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            completionBlock();
        }];
    });
}

@end
