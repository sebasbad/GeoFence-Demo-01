//
//  ReverseGeocoder.h
//  GeoFenceDemo01
//
//  Created by Sebastián Badea on 14/5/16.
//  Copyright © 2016 Sebastian Badea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReverseGeocoder : NSObject

+ (instancetype)sharedInstance;

- (void)takeOff;

- (void)startReverseGeocodeWithLatitude:(double)latitude andLongitude:(double)longitude andCompletion:(void (^)(NSString* title, NSString* subtitle))completion;

@end
