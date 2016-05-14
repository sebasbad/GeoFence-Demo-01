//
//  ViewController+MapView.h
//  GeoFenceDemo01
//
//  Created by Sebastián Badea on 13/5/16.
//  Copyright © 2016 Sebastian Badea. All rights reserved.
//

#import <objc/runtime.h>
#import "MapKit/MapKit.h"
#import "GeoFence.h"
#import "ViewController.h"

@interface ViewController (MapView) <MKMapViewDelegate>

@property (strong, nonatomic) NSMutableDictionary<NSString *, CLCircularRegion *> *circularGeoRegions;
@property (strong, nonatomic) NSMutableDictionary<NSString *, GeoFence *> *geoFences;

@property (nonatomic, assign) BOOL mapIsMoving;

- (void)mapView:(MKMapView *)mapView zoomInWithWidth:(NSInteger)latitudinalMeters andHeight:(NSInteger)longitudinalMeters;

- (void)centerMapView:(MKMapView *)mapView atCenterPoint:(MKPointAnnotation *)centerPoint;

- (void)drawGeoFencesOnMapView:mapView;
- (void)drawGeoFence:(GeoFence *)geoFence onMapView:(MKMapView *)mapView;

- (GeoFence *)createGeoFenceWithLatitude:(double)latitude andLongitude:(double)longitude andRadiusInMeters:(NSInteger)radius andIdentifier:(NSString *)identifier andTitle:(NSString *)title andSubtitle:(NSString *)subtitle;

- (GeoFence *)findFirstGeoFenceWithLatitude:(double)latitude andLongitude:(double)longitude;

- (void)loadCircularRegions;



@end
