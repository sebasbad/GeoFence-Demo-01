//
//  ViewController+LocationManager.m
//  GeoFenceDemo01
//
//  Created by Sebastián Badea on 13/5/16.
//  Copyright © 2016 Sebastian Badea. All rights reserved.
//

#import <objc/runtime.h>
#import "ViewController+LocationManager.h"

@implementation ViewController (LocationManager)

# pragma mark - category properties getters and setters

- (CLLocationManager *) locationManager {
    return objc_getAssociatedObject(self, @selector(locationManager));
}

- (void)setLocationManager: (CLLocationManager *) locationManager {
    objc_setAssociatedObject(self, @selector(locationManager), locationManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
