//
//  GeoFence.h
//  GeoFenceDemo01
//
//  Created by Sebastián Badea on 4/5/16.
//  Copyright © 2016 Sebastian Badea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoFence : NSObject <NSCoding>

@property (nonatomic, assign) double centerLatitude;
@property (nonatomic, assign) double centerLongitude;
@property (nonatomic, assign) double radius;
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;

- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;

@end
