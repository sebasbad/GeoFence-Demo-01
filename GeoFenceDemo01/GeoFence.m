//
//  GeoFence.m
//  GeoFenceDemo01
//
//  Created by Sebastián Badea on 4/5/16.
//  Copyright © 2016 Sebastian Badea. All rights reserved.
//

#import "GeoFence.h"


@implementation GeoFence

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeDouble:self.centerLatitude forKey:@"centerLatitude"];
    [encoder encodeDouble:self.centerLongitude forKey:@"centerLongitude"];
    [encoder encodeDouble:self.radius forKey:@"radius"];
    [encoder encodeObject:self.identifier forKey:@"identifier"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.subtitle forKey:@"subtitle"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if (self = [super init]) {
        self.centerLatitude = [decoder decodeDoubleForKey:@"centerLatitude"];
        self.centerLongitude = [decoder decodeDoubleForKey:@"centerLongitude"];
        self.radius = [decoder decodeDoubleForKey:@"radius"];
        self.identifier = [decoder decodeObjectForKey:@"identifier"];
        self.title = [decoder decodeObjectForKey:@"title"];
        self.subtitle = [decoder decodeObjectForKey:@"subtitle"];
    }
    
    return self;
}


@end
