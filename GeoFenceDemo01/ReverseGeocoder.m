//
//  ReverseGeocoder.m
//  GeoFenceDemo01
//
//  Created by Sebastián Badea on 14/5/16.
//  Copyright © 2016 Sebastian Badea. All rights reserved.
//

#import "MapKit/MapKit.h"
#import "ReverseGeocoder.h"

@interface ReverseGeocoder ()

@property (strong, nonatomic) CLGeocoder *geocoder;

@end

@implementation ReverseGeocoder

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)initWithGeocoder:(CLGeocoder *)geocoder {
    self = [super init];
    if (self) {
        [self setGeocoder:geocoder];
    }
    return self;
}

- (void)takeOff {
    self.geocoder = [[CLGeocoder alloc] init];
}

- (void)startReverseGeocodeWithLatitude:(double)latitude andLongitude:(double)longitude andCompletion:(void (^)(NSString* title, NSString* subtitle))completion {
    
    NSLog(@"1");
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
//    @synchronized (self) {
    
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            
//            @synchronized (self) {
            
                NSLog(@"2");
                
                NSString *title;
                NSString *subtitle;
                
                if (error) {
                    
                    title = @"There was a problem reverse geocoding";
                    subtitle = [error localizedDescription];
                    
                } else {
                    NSString *addressName;
                    NSString *administrativeAreaName;
                    NSString *countryName;
                    
                    for (CLPlacemark *placemark in placemarks) {
                        if (nil != placemark.name) {
                            addressName = placemark.name;
                        }
                        if (nil != placemark.administrativeArea) {
                            administrativeAreaName = placemark.administrativeArea;
                        }
                        if (nil != placemark.country) {
                            countryName = placemark.country;
                        }
                        
                        break;
                    }
                    
                    title = addressName;
                    subtitle = nil == administrativeAreaName && nil == countryName ? nil : [NSString stringWithFormat:@"%@, %@", administrativeAreaName, countryName];
                }
                
                NSLog(@"3");
                
                if (completion) {
                    
                    NSLog(@"4");
                    
                    completion(title, subtitle);
                }
//            }
        }];
//    }
}

@end
