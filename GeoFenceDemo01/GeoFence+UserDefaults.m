//
//  GeoFence+UserDefaults.m
//  GeoFenceDemo01
//
//  Created by Sebastián Badea on 13/5/16.
//  Copyright © 2016 Sebastian Badea. All rights reserved.
//

#import "GeoFence+UserDefaults.h"

@implementation GeoFence (UserDefaults)

NSString *const geoFencesDataKey = @"geoFencesData";

#pragma mark - user defaults

+ (void)saveGeoFences:(NSDictionary<NSString *, GeoFence *> *)geoFences {
    NSData *geoFencesData = [NSKeyedArchiver archivedDataWithRootObject:geoFences];
    [[NSUserDefaults standardUserDefaults] setObject:geoFencesData forKey:geoFencesDataKey];
}

+ (NSDictionary<NSString *, GeoFence *> *)loadGeoFences {
    NSData *geoFencesData = [[NSUserDefaults standardUserDefaults] objectForKey:geoFencesDataKey];
    NSDictionary<NSString *,GeoFence *> *geoFencesDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:geoFencesData];
    return geoFencesDictionary;
}

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