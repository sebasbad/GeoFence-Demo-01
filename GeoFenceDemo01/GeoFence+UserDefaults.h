//
//  GeoFence+UserDefaults.h
//  GeoFenceDemo01
//
//  Created by Sebastián Badea on 13/5/16.
//  Copyright © 2016 Sebastian Badea. All rights reserved.
//

#import "GeoFence.h"

@interface GeoFence (UserDefaults) <NSCoding>

+ (void)saveGeoFences:(NSDictionary<NSString *, GeoFence *> *)geoFences;
+ (NSDictionary<NSString *, GeoFence *> *)loadGeoFences;

- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;

@end