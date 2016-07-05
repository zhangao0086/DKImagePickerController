#import "STCoreLocationWhenInUsePermission.h"
@import CoreLocation;

@interface STCoreLocationWhenInUsePermission () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) STPermissionEmptyBlock locationStatusChangeBlock;
@end

@implementation STCoreLocationWhenInUsePermission

+(instancetype)permissionWithLabelText:(NSString*)labelText{
    return [[super alloc] initWithType:STCoreLocationWhenInUserPermissionType labelText:labelText];
}


-(void)updatePermissionStatus{
    if(![CLLocationManager significantLocationChangeMonitoringAvailable]){
        self.status = STPermissionStatusServiceNotAvailable;
    } else {        
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if(status == kCLAuthorizationStatusAuthorizedWhenInUse){
            self.status = STPermissionStatusAuthorized;
        } else if(status == kCLAuthorizationStatusAuthorizedAlways){
            self.status = STPermissionStatusDenied;
        } else if(status == kCLAuthorizationStatusNotDetermined) {
            self.status = STPermissionStatusNotDetermined;
        } else if(status == kCLAuthorizationStatusDenied) {
            self.status = STPermissionStatusDenied;
        } else if(status == kCLAuthorizationStatusRestricted) {
            self.status = STPermissionStatusRestricted;
        }
    }
}

-(void)presentSystemPromtWithCompletionBlock:(STPermissionEmptyBlock)completionBlock{
    self.locationStatusChangeBlock = completionBlock;
    if(self.locationManager == nil){
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
    }
    
    
    [self.locationManager requestWhenInUseAuthorization];
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    self.locationStatusChangeBlock();
}


@end
