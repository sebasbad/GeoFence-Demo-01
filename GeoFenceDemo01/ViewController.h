//
//  ViewController.h
//  GeoFenceDemo01
//
//  Created by Sebastián Badea on 5/4/16.
//  Copyright © 2016 Sebastian Badea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (void)enableActivateSwitch;
- (void)setStatusLabelText:(NSString *)text;

- (void)centerMapView:(MKPointAnnotation *)centerPoint;

- (void)editCustomGeoFenceWithLatitude:(double)latitude andLongitude:(double)longitude;

@end

