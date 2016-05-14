//
//  ViewController+LocationManager.h
//  GeoFenceDemo01
//
//  Created by Sebastián Badea on 13/5/16.
//  Copyright © 2016 Sebastian Badea. All rights reserved.
//

#import "MapKit/MapKit.h"
#import "ViewController.h"

@interface ViewController (LocationManager) <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

- (void)configureLocationManager;

@end
