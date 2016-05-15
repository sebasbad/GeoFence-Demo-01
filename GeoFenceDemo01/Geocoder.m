//
//  Geocoder.m
//  GeoFenceDemo01
//
//  Created by Sebastián Badea on 14/5/16.
//  Copyright © 2016 Sebastian Badea. All rights reserved.
//

#import "MapKit/MapKit.h"
#import "GeocoderDelegate.h"
#import "Geocoder.h"

@interface Geocoder ()

@property (strong, nonatomic) CLGeocoder *geocoder;

@end

@implementation Geocoder

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)takeOff {
    self.geocoder = [[CLGeocoder alloc] init];
}

- (void)startReverseGeocodeWithLatitude:(double)latitude andLongitude:(double)longitude andDelegate:(id<GeocoderDelegate>)delegate {
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        [delegate parseGeocoderResultForLocation:location withPlacemarks:placemarks orError:error];
    }];
}

@end
