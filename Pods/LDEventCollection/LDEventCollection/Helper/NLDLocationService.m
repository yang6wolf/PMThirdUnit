//
//  NLDLocationService.m
//  Pods
//
//  Created by 高振伟 on 16/11/1.
//
//

#import "NLDLocationService.h"
#import <CoreLocation/CoreLocation.h>
#import "NLDMacroDef.h"
#import "NSNotificationCenter+NLDEventCollection.h"

NLDNotificationNameDefine(NLDNotificationLocationUpload)

@interface NLDLocationService ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) void (^completionHandler)(NSString *longitude, NSString *latitude, NSString *altitude);

@end

@implementation NLDLocationService

+ (instancetype)sharedService
{
    static NLDLocationService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.enableLocation = NO;
    }
    return self;
}

- (void)setEnableLocation:(BOOL)enableLocation
{
    _enableLocation = enableLocation;
    if (enableLocation) {
        if (!self.locationManager) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
            
            // 自动触发一次定位，模拟冷启动
            [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationLocationUpload object:nil userInfo:nil];
        }
    }
}

- (void)startUpdateLocationWithCompletionHandler:(void(^)(NSString *longitude, NSString *latitude, NSString *altitude))completionBlock
{
    [self.locationManager startUpdatingLocation];
    self.completionHandler = completionBlock;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    CLLocationCoordinate2D coordinate = currentLocation.coordinate;
    NSString *longitude = [NSString stringWithFormat:@"%f", coordinate.longitude];
    NSString *latitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
    NSString *altitude = [NSString stringWithFormat:@"%f", currentLocation.altitude];
    
    if (self.completionHandler) {
        self.completionHandler(longitude, latitude, altitude);
        self.completionHandler = nil;
    }
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorDenied) {
        LDECLog(@"Access to location has been denied by the user");
    }
}

- (void)dealloc
{
    self.locationManager.delegate = nil;
}

@end
