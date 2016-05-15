//
//  ViewController+LocationManager.m
//  GeoFenceDemo01
//
//  Created by Sebastián Badea on 13/5/16.
//  Copyright © 2016 Sebastian Badea. All rights reserved.
//

#import <objc/runtime.h>
#import "SystemVersionVerificationHelper.h"
#import "ViewController+MapView.h"
#import "ViewController+LocationManager.h"

@implementation ViewController (LocationManager)

@dynamic locationManager;
@dynamic currentLocationAnnotation;

# pragma mark - category properties getters and setters

- (CLLocationManager *) locationManager {
    return objc_getAssociatedObject(self, @selector(locationManager));
}

- (void)setLocationManager: (CLLocationManager *) locationManager {
    objc_setAssociatedObject(self, @selector(locationManager), locationManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MKPointAnnotation *) currentLocationAnnotation {
    return objc_getAssociatedObject(self, @selector(currentLocationAnnotation));
}

- (void)setCurrentLocationAnnotation: (MKPointAnnotation *) currentLocationAnnotation {
    objc_setAssociatedObject(self, @selector(currentLocationAnnotation), currentLocationAnnotation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

# pragma mark - current location annotation

- (void)addCurrentLocationAnnotation {
    self.currentLocationAnnotation = [[MKPointAnnotation alloc] init];
    self.currentLocationAnnotation.coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
    self.currentLocationAnnotation.title = @"My Location";
}

# pragma mark - location manager helper methods

- (void)configureLocationManager {
    // Set up the location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        self.locationManager.allowsBackgroundLocationUpdates = YES;
    }
    self.locationManager.pausesLocationUpdatesAutomatically= YES;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // minimum increment of distance in meters, to be notified that location has changed
    self.locationManager.distanceFilter = 3;
}

- (void)locationManager:(CLLocationManager *)manager requestStateForRegions:(NSDictionary<NSString *,CLCircularRegion *> *)circularGeoRegions {
    
    for (id item in [circularGeoRegions allValues]) {
        CLCircularRegion *circularRegion = (CLCircularRegion *)item;
        [manager requestStateForRegion:circularRegion];
    }
}

# pragma mark - location manager monitoring helper methods

- (void)locationManager:(CLLocationManager *)manager stopMonitoringForRegions:(NSDictionary<NSString *,CLCircularRegion *> *)circularGeoRegions {
    
    for (id item in [circularGeoRegions allValues]) {
        CLCircularRegion *circularRegion = (CLCircularRegion *)item;
        [manager stopMonitoringForRegion:circularRegion];
    }
}

- (void)locationManager:(CLLocationManager *)manager startMonitoringForRegions:(NSDictionary<NSString *,CLCircularRegion *> *)circularGeoRegions {
    
    for (id item in [circularGeoRegions allValues]) {
        CLCircularRegion *circularRegion = (CLCircularRegion *)item;
        [manager startMonitoringForRegion:circularRegion];
    }
}

# pragma mark - location manager authorization methods and callbacks

- (void)configureGeoLocationAuthorization {
    // Check if the device can do geofences
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
        if (kCLAuthorizationStatusAuthorizedWhenInUse == authorizationStatus || kCLAuthorizationStatusAuthorizedAlways == authorizationStatus) {
            [self enableActivateSwitch];
        }
        else {
            // If not authorized, try and get it authorized
            [self.locationManager requestAlwaysAuthorization];
        }
        
        // Ask for notifications permissions if the app is in the background
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    } else {
        [self setStatusLabelText:@"GeoRegions not supported"];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusAuthorizedWhenInUse == authorizationStatus || kCLAuthorizationStatusAuthorizedAlways == authorizationStatus) {
        [self enableActivateSwitch];
    }
}

#pragma mark - location manager callbacks

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.currentLocationAnnotation.coordinate = locations.lastObject.coordinate;
    
    if (!self.mapIsMoving) {
        [self centerMapView:self.currentLocationAnnotation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    
    if (CLRegionStateUnknown == state) {
        [self setStatusLabelText:@"Unknown"];
    } else if (CLRegionStateInside == state) {
        [self setStatusLabelText:@"Inside"];
    } else if (CLRegionStateOutside == state) {
        [self setStatusLabelText:@"Outside"];
    } else {
        [self setStatusLabelText:@"Mistery"];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    
    GeoFence *geoFence;
    
    if ([region isKindOfClass:[CLCircularRegion class]]) {
        
        CLCircularRegion *circularRegion = (CLCircularRegion *)region;
        
        NSLog(@"Did enter circularRegion.center.latitude: %f, circularRegion.center.longitude: %f", circularRegion.center.latitude, circularRegion.center.longitude);
        
        geoFence = [self findFirstGeoFenceWithLatitude:circularRegion.center.latitude andLongitude: circularRegion.center.longitude];
    }
    
    UILocalNotification *locationNotification = [[UILocalNotification alloc] init];
    locationNotification.fireDate = nil;
    locationNotification.repeatInterval = 0;
    
    NSString *notificationAlertTitle = [NSString stringWithFormat:@"Geofence Alert: %@ !", nil != geoFence ? geoFence.identifier :  @"Unknown"];
    NSString *notificationAlertBody = [NSString stringWithFormat:@"You entered: %@", nil != geoFence ? [NSString stringWithFormat:@"%@, %@", geoFence.title, geoFence.subtitle] : @"Unknown"];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
        locationNotification.alertTitle = notificationAlertTitle;
    }
    
    locationNotification.alertBody = notificationAlertBody;
    [[UIApplication sharedApplication] scheduleLocalNotification:locationNotification];
    
    [self setStatusLabelText:@"Entered"];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    
    GeoFence *geoFence;
    
    if ([region isKindOfClass:[CLCircularRegion class]]) {
        
        CLCircularRegion *circularRegion = (CLCircularRegion *)region;
        
        NSLog(@"Did exit circularRegion.center.latitude: %f, circularRegion.center.longitude: %f", circularRegion.center.latitude, circularRegion.center.longitude);
        
        geoFence = [self findFirstGeoFenceWithLatitude:circularRegion.center.latitude andLongitude: circularRegion.center.longitude];
    }
    
    UILocalNotification *locationNotification = [[UILocalNotification alloc] init];
    locationNotification.fireDate = nil;
    locationNotification.repeatInterval = 0;
    
    NSString *notificationAlertTitle = [NSString stringWithFormat:@"Geofence Alert: %@ !", nil != geoFence ? geoFence.identifier :  @"Unknown"];
    NSString *notificationAlertBody = [NSString stringWithFormat:@"You left: %@", nil != geoFence ? [NSString stringWithFormat:@"%@, %@", geoFence.title, geoFence.subtitle] : @"Unknown"];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
        locationNotification.alertTitle = notificationAlertTitle;
    }
    
    locationNotification.alertBody = [NSString stringWithFormat:notificationAlertBody];
    [[UIApplication sharedApplication] scheduleLocalNotification:locationNotification];
    [self setStatusLabelText:@"Exited"];
}


@end
