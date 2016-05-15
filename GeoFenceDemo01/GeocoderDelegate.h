//
//  GeocoderDelegate.h
//  GeoFenceDemo01
//
//  Created by Sebastián Badea on 14/5/16.
//  Copyright © 2016 Sebastian Badea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapKit/MapKit.h"

@protocol GeocoderDelegate <NSObject>

- (void)parseGeocoderResultForLocation:(CLLocation *)location withPlacemarks:(NSArray *)placemarks orError:(NSError *)error;

@end
