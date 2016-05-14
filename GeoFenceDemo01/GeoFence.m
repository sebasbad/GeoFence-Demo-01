//
//  GeoFence.m
//  GeoFenceDemo01
//
//  Created by Sebastián Badea on 4/5/16.
//  Copyright © 2016 Sebastian Badea. All rights reserved.
//

#import "GeoFence.h"


@implementation GeoFence

- (id)initWithLatitude:(double)latitude andLongitude:(double)longitude andRadius:(double)radius andIdentifier:(NSString *)identifier andTitle:(NSString *)title andSubtitle:(NSString *)subtitle {
    
    if (self = [super init]) {
        self.centerLatitude = latitude;
        self.centerLongitude = longitude;
        self.radius = radius;
        self.identifier = identifier;
        self.title = title;
        self.subtitle = subtitle;
    }
    
    return self;
}


@end
