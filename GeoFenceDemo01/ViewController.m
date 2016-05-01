//
//  ViewController.m
//  GeoFenceDemo01
//
//  Created by Sebastián Badea on 5/4/16.
//  Copyright © 2016 Sebastian Badea. All rights reserved.
//

#import "MapKit/MapKit.h"
#import "ViewController.h"

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *activateSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *statusCheckBarButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) MKPointAnnotation *currentAnnotation;

@property (strong, nonatomic) CLCircularRegion *circularGeoRegion;

@property (nonatomic, assign) BOOL mapIsMoving;

@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGestureRecognizer;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    
    self.mapIsMoving = NO;
    
    [self configureLocationManager];
    
    [self zoomInWithWidth:500 andHeight:500];
    
    // Create an annotation for the user's location
    [self addCurrentAnnotation];
    
    // Set up a georegion
    [self setUpGeoRegion];
    
    [self configureGeoLocationAuthorization];
}

- (void)zoomInWithWidth:(NSInteger)latitudinalMeters andHeight:(NSInteger)longitudinalMeters {
    // Zoom the map very close
    CLLocationCoordinate2D noLocation;
    // 500 by 500 meters view region
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, latitudinalMeters, longitudinalMeters);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
}

- (void)configureLocationManager {
    // Set up the location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    self.locationManager.pausesLocationUpdatesAutomatically= YES;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // minimum increment of distance in meters, to be notified that location has changed
    self.locationManager.distanceFilter = 3;
}

- (void)configureUI {
    // Turn off the User Interface until permission is obtained
    self.activateSwitch.enabled = NO;
    self.statusCheckBarButton.enabled = NO;
}

- (void)configureGeoLocationAuthorization {
    // Check if the device can do geofences
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
        if (kCLAuthorizationStatusAuthorizedWhenInUse == authorizationStatus || kCLAuthorizationStatusAuthorizedAlways == authorizationStatus) {
            self.activateSwitch.enabled = YES;
        }
        else {
            // If not authorized, try and get it authorized
            [self.locationManager requestAlwaysAuthorization];
        }
        
        // Ask for notifications permissions if the app is in the background
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    } else {
        self.statusLabel.text = @"GeoRegions not supported";
    }

}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusAuthorizedWhenInUse == authorizationStatus || kCLAuthorizationStatusAuthorizedAlways == authorizationStatus) {
        self.activateSwitch.enabled = YES;
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    self.mapIsMoving = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.mapIsMoving = NO;
}

- (void)setUpGeoRegion {
    // Create the geographic region to be monitored
    self.circularGeoRegion = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(30.021720, 31.250567) radius:3 identifier:@"MyRegionIdentifier"];
    
    // Add an annotation
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(30.021720, 31.250567);
    point.title = @"Where am I?";
    point.subtitle = @"I'm here!!!";
    
    [self.mapView addAnnotation:point];
}

- (IBAction)switchTapped:(id)sender {
    
    if (self.activateSwitch.isOn) {
        self.mapView.showsUserLocation = YES;
        [self.locationManager startUpdatingLocation];
        [self.locationManager startMonitoringForRegion:self.circularGeoRegion];
        self.statusCheckBarButton.enabled = YES;
    } else {
        self.statusCheckBarButton.enabled = NO;
        [self.locationManager stopMonitoringForRegion:self.circularGeoRegion];
        [self.locationManager stopUpdatingLocation];
        self.mapView.showsUserLocation = NO;
    }
}

- (IBAction)statusCheckTapped:(id)sender {
    [self.locationManager requestStateForRegion:self.circularGeoRegion];
}

- (void)addCurrentAnnotation {
    self.currentAnnotation = [[MKPointAnnotation alloc] init];
    self.currentAnnotation.coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
    self.currentAnnotation.title = @"My Location";
}

- (void)centerMap:(MKPointAnnotation *)centerPoint {
    [self.mapView setCenterCoordinate:centerPoint.coordinate animated:YES];
}

#pragma mark - long press gesture recognizer

- (IBAction)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    MKPointAnnotation *point1 = [[MKPointAnnotation alloc] init];
    point1.coordinate = touchMapCoordinate;
    
    [self.mapView addAnnotation:point1];
}

#pragma mark - location callbacks

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.currentAnnotation.coordinate = locations.lastObject.coordinate;
    
    if (!self.mapIsMoving) {
        [self centerMap:self.currentAnnotation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    
    if (CLRegionStateUnknown == state) {
        self.statusLabel.text = @"Unknown";
    } else if (CLRegionStateInside == state) {
        self.statusLabel.text = @"Inside";
    } else if (CLRegionStateOutside == state) {
        self.statusLabel.text = @"Outside";
    } else {
        self.statusLabel.text = @"Mistery";
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    UILocalNotification *locationNotification = [[UILocalNotification alloc] init];
    locationNotification.fireDate = nil;
    locationNotification.repeatInterval = 0;
    locationNotification.alertTitle = @"Geofence Alert!";
    locationNotification.alertBody = [NSString stringWithFormat:@"You entered a geofence"];
    [[UIApplication sharedApplication] scheduleLocalNotification:locationNotification];
    self.eventLabel.text = @"Entered";
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    UILocalNotification *locationNotification = [[UILocalNotification alloc] init];
    locationNotification.fireDate = nil;
    locationNotification.repeatInterval = 0;
    locationNotification.alertTitle = @"Geofence Alert!";
    locationNotification.alertBody = [NSString stringWithFormat:@"You left a geofence"];
    [[UIApplication sharedApplication] scheduleLocalNotification:locationNotification];
    self.eventLabel.text = @"Exited";

}

@end
