//
//  ViewController+MapView.m
//  GeoFenceDemo01
//
//  Created by Sebastián Badea on 13/5/16.
//  Copyright © 2016 Sebastian Badea. All rights reserved.
//

#import "ViewController+LocationManager.h"
#import "ViewController+MapView.h"

@implementation ViewController (MapView)

// http://nshipster.com/associated-objects/
// http://blog.carbonfive.com/2012/11/27/monkey-patching-ios-with-objective-c-categories-part-ii-adding-instance-properties/

@dynamic circularGeoRegions;
@dynamic geoFences;
@dynamic mapIsMoving;

# pragma mark - category properties getters and setters

- (NSMutableDictionary<NSString *, CLCircularRegion *> *) circularGeoRegions {
    return objc_getAssociatedObject(self, @selector(circularGeoRegions));
}

- (void)setCircularGeoRegions: (NSMutableDictionary<NSString *, CLCircularRegion *> *) circularGeoRegions {
    objc_setAssociatedObject(self, @selector(circularGeoRegions), circularGeoRegions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSString *, GeoFence *> *) geoFences {
    return objc_getAssociatedObject(self, @selector(geoFences));
}

- (void)setGeoFences: (NSMutableDictionary<NSString *, GeoFence *> *) geoFences {
    objc_setAssociatedObject(self, @selector(geoFences), geoFences, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// http://stackoverflow.com/questions/9776811/how-to-add-bool-property-to-a-category

- (BOOL) mapIsMoving {
    NSNumber *numberMapIsMoving = objc_getAssociatedObject(self, @selector(mapIsMoving));
    return [numberMapIsMoving boolValue];
}

- (void)setMapIsMoving: (BOOL) mapIsMoving {
    NSNumber *numberMapIsMoving = [NSNumber numberWithBool: mapIsMoving];
    objc_setAssociatedObject(self, @selector(mapIsMoving), numberMapIsMoving, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

# pragma mark - mapview helper methods

- (void)mapView:(MKMapView *)mapView zoomInWithWidth:(NSInteger)latitudinalMeters andHeight:(NSInteger)longitudinalMeters {
    // Zoom the map very close
    CLLocationCoordinate2D noLocation;
    // 500 by 500 meters view region
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, latitudinalMeters, longitudinalMeters);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:YES];
}

- (void)drawGeoFencesOnMapView:mapView {
    for (id item in [self.geoFences allValues]) {
        GeoFence *geoFence = (GeoFence *)item;
        
        [self drawGeoFence:geoFence onMapView:mapView];
    }
}

- (void)drawGeoFence:(GeoFence *)geoFence onMapView:(MKMapView *)mapView {
    
    // Add an annotation
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(geoFence.centerLatitude, geoFence.centerLongitude);
    point.title = geoFence.title;
    point.subtitle = geoFence.subtitle;
    
    [mapView addAnnotation:point];
    
    // 5. setup circle
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:point.coordinate radius:geoFence.radius];
    [mapView addOverlay:circle];
}

- (void)centerMapView:(MKMapView *)mapView atCenterPoint:(MKPointAnnotation *)centerPoint {
    [mapView setCenterCoordinate:centerPoint.coordinate animated:YES];
}

# pragma mark - mapview callbacks

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    double annotationLatitude = view.annotation.coordinate.latitude;
    double annotationLongitude = view.annotation.coordinate.longitude;
    
    NSLog(@"annotationLatitude: %f, annotationLongitude: %f", annotationLatitude, annotationLongitude);
    NSLog(@"%@",view.annotation.title);
    NSLog(@"%@",view.annotation.subtitle);
    NSLog(@"%@", control);
    
    if (1 == control.tag) {
        
        [self deleteGeoFenceWithLatitude:annotationLatitude andLongitude:annotationLongitude andLocationManager:self.locationManager fromMapView:mapView];
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    self.mapIsMoving = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.mapIsMoving = NO;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
    circleRenderer.strokeColor = [UIColor redColor];
    circleRenderer.fillColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.2];
    circleRenderer.lineWidth = 1.0;
    return circleRenderer;
}

# pragma mark - geo fence find methods

- (GeoFence *)findFirstGeoFenceWithLatitude:(double)latitude andLongitude:(double)longitude {
    
    GeoFence *foundGeoFence;
    
    // Find "first" geo fence with the given center latitude and longitude
    
    for (id item in [self.geoFences allKeys]) {
        NSString *geoFenceKey = (NSString *)item;
        GeoFence *geoFence = (GeoFence *)self.geoFences[geoFenceKey];
        
        if (latitude == geoFence.centerLatitude && longitude == geoFence.centerLongitude) {
            
            foundGeoFence = geoFence;
            break;
        }
    }
    
    return foundGeoFence;
}

# pragma mark - geo fence removal methods

- (void)deleteGeoFenceWithLatitude:(double)latitude andLongitude:(double)longitude andLocationManager:(CLLocationManager *)locationManager fromMapView:(MKMapView *)mapView {
    
    // Delete "first" geo fence with the given center latitude and longitude
    
    for (id item in [self.geoFences allKeys]) {
        NSString *geoFenceKey = (NSString *)item;
        GeoFence *geoFence = (GeoFence *)self.geoFences[geoFenceKey];
        
        if (latitude == geoFence.centerLatitude && longitude == geoFence.centerLongitude) {
            
            [self deleteRegionWithLatitude:latitude andLongitude:longitude andLocationManager:locationManager];
            [ViewController mapView:mapView removeOverlayWithLatitude:latitude andLongitude:longitude];
            [ViewController mapView:mapView removeAnnotationWithLatitude:latitude andLongitude:longitude];
            
            NSLog(@"Deleting geo fence with center latitude: %f, longitude: %f", geoFence.centerLatitude, geoFence.centerLongitude);
            
            [self.geoFences removeObjectForKey:geoFenceKey];
            break;
        }
    }
}

- (void)deleteRegionWithLatitude:(double)latitude andLongitude:(double)longitude andLocationManager:(CLLocationManager *)locationManager {
    
    // Delete "first" circular region with the given center latitude and longitude
    
    for (id item in [self.circularGeoRegions allKeys]) {
        NSString *circularRegionKey = (NSString *)item;
        CLCircularRegion *circularRegion = (CLCircularRegion *)self.circularGeoRegions[circularRegionKey];
        
        if (latitude == circularRegion.center.latitude && longitude == circularRegion.center.longitude) {
            
            NSLog(@"Deleting circular region with key: %@ center.latitude: %f, center.longitude: %f", circularRegionKey, circularRegion.center.latitude, circularRegion.center.longitude);
            
            [locationManager stopMonitoringForRegion:circularRegion];
            [self.circularGeoRegions removeObjectForKey:circularRegionKey];
            break;
        }
    }
}

+ (void)mapView:(MKMapView *)mapView removeOverlayWithLatitude:(double)latitude andLongitude:(double)longitude {
    
    // Remove first map overlay with the given center latitude and longitude
    
    for (id<MKOverlay> item in [mapView overlays]) {
        id<MKOverlay> overlay = (id<MKOverlay>)item;
        
        if (latitude == overlay.coordinate.latitude && longitude == overlay.coordinate.longitude) {
            
            NSLog(@"Removing map view overlay with coordinate.latitude: %f, coordinate.longitude: %f", overlay.coordinate.latitude, overlay.coordinate.longitude);
            
            [mapView removeOverlay:overlay];
            break;
        }
    }
}

+ (void)mapView:(MKMapView *)mapView removeAnnotationWithLatitude:(double)latitude andLongitude:(double)longitude {
    
    // Remove first map pin annotation with the given center latitude and longitude
    
    for (id<MKAnnotation> item in [mapView annotations]) {
        id<MKAnnotation> annotation = (id<MKAnnotation>)item;
        
        if (latitude == annotation.coordinate.latitude && longitude == annotation.coordinate.longitude) {
            
            NSLog(@"Removing annotation annotation with coordinate.latitude: %f, coordinate.longitude: %f", annotation.coordinate.latitude, annotation.coordinate.longitude);
            
            [mapView removeAnnotation:annotation];
            break;
        }
    }
}

#pragma mark - mapview annotation callback

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    // If the annotation is the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Try to dequeue an existing pin view first.
    MKPinAnnotationView* pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
    
    if (pinView) {
        pinView.annotation = annotation;
        return pinView;
    }
    
    // If no pin view already exists, create a new one.
    MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                          initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
    customPinView.pinColor = MKPinAnnotationColorGreen;
    customPinView.animatesDrop = YES;
    customPinView.canShowCallout = YES;
    
    // Because this is an iOS app, add the detail disclosure button to display details about the annotation in another view.
    UIImage *trashBinImage = [UIImage imageNamed:@"trash_bin"];
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [deleteButton setImage:trashBinImage forState:UIControlStateNormal];
    [deleteButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    deleteButton.tag = 1;
    customPinView.leftCalloutAccessoryView = deleteButton;
    
    UIButton *moreInfoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [moreInfoButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    moreInfoButton.tag = 2;
    customPinView.rightCalloutAccessoryView = moreInfoButton;
    
    return customPinView;
}

@end
