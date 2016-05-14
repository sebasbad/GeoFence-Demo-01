//
//  ViewController+LocationManager.m
//  GeoFenceDemo01
//
//  Created by Sebastián Badea on 13/5/16.
//  Copyright © 2016 Sebastian Badea. All rights reserved.
//

#import <objc/runtime.h>
#import "SystemVersionVerificationHelper.h"
#import "ViewController+LocationManager.h"

@implementation ViewController (LocationManager)

# pragma mark - category properties getters and setters

- (CLLocationManager *) locationManager {
    return objc_getAssociatedObject(self, @selector(locationManager));
}

- (void)setLocationManager: (CLLocationManager *) locationManager {
    objc_setAssociatedObject(self, @selector(locationManager), locationManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

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

@end
