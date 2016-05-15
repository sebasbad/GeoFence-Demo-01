//
//  ViewController.h
//  GeoFenceDemo01
//
//  Created by Sebastián Badea on 5/4/16.
//  Copyright © 2016 Sebastian Badea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReverseGeocoderDelegate.h"

@interface ViewController : UIViewController <ReverseGeocoderDelegate>

- (void)enableActivateSwitch;
- (void)setStatusLabelText:(NSString *)text;

- (void)centerMapView:(MKPointAnnotation *)centerPoint;

@end

