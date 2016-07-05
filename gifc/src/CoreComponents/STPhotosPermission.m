#import "STPhotosPermission.h"
@import Photos;

@implementation STPhotosPermission

+(instancetype)permissionWithLabelText:(NSString*)labelText{
    return [[super alloc] initWithType:STPhotosPermissionType labelText:labelText];
}


-(void)updatePermissionStatus{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if(status == PHAuthorizationStatusAuthorized){
        self.status = STPermissionStatusAuthorized;
    } else if(status == PHAuthorizationStatusNotDetermined) {
        self.status = STPermissionStatusNotDetermined;
    } else if(status == PHAuthorizationStatusDenied) {
        self.status = STPermissionStatusDenied;
    } else if(status == PHAuthorizationStatusRestricted) {
        self.status = STPermissionStatusRestricted;
    }
}

-(void)presentSystemPromtWithCompletionBlock:(STPermissionEmptyBlock)completionBlock{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        completionBlock();
    }];
}
@end
