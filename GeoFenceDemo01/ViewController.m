//
//  ViewController.m
//  GeoFenceDemo01
//
//  Created by Sebastián Badea on 5/4/16.
//  Copyright © 2016 Sebastian Badea. All rights reserved.
//

#import "MapKit/MapKit.h"
#import "ViewController.h"
#import "SystemVersionVerificationHelper.h"
#import "GeoFence.h"

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *activateSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *statusCheckBarButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) MKPointAnnotation *currentAnnotation;

@property (strong, nonatomic) NSMutableDictionary<NSString *, CLCircularRegion *> *circularGeoRegions;
@property (strong, nonatomic) NSMutableDictionary<NSString *, GeoFence *> *geoFences;

@property (nonatomic, assign) BOOL mapIsMoving;

@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGestureRecognizer;


@end

@implementation ViewController

NSString *const geoFencesDataKey = @"geoFencesData";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadCircularRegions];
    
    [self configureUI];
    
    self.mapIsMoving = NO;
    
    [self configureLocationManager];
    
    [self zoomInWithWidth:500 andHeight:500];
    
    // Create an annotation for the user's location
    [self addCurrentAnnotation];
    
    [self configureGeoLocationAuthorization];
    
    [self drawGeoFencesOnMap];
}

- (void)loadCircularRegions {
    self.geoFences = [[NSMutableDictionary<NSString *,GeoFence *> alloc] init];
    [self.geoFences addEntriesFromDictionary: [ViewController loadGeoFences]];
    
    self.circularGeoRegions = [[NSMutableDictionary<NSString *, CLCircularRegion *> alloc] init];
    
    for (id item in self.geoFences) {
        GeoFence *geoFence = (GeoFence *)item;
        
        CLLocationCoordinate2D locationCoordinate2D = CLLocationCoordinate2DMake(geoFence.centerLongitude, geoFence.centerLatitude);
        CLCircularRegion *circularRegion = [[CLCircularRegion alloc] initWithCenter:locationCoordinate2D radius:geoFence.radius identifier:geoFence.identifier];
        
        [self.circularGeoRegions setObject:circularRegion forKey:geoFence.identifier];
    }
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
   
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        self.locationManager.allowsBackgroundLocationUpdates = YES;
    }
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

- (void)drawGeoFencesOnMap {
    for (id item in self.geoFences) {
        GeoFence *geoFence = (GeoFence *)item;
        
        [self drawGeoFence:geoFence onMapView:self.mapView];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusAuthorizedWhenInUse == authorizationStatus || kCLAuthorizationStatusAuthorizedAlways == authorizationStatus) {
        self.activateSwitch.enabled = YES;
    }
}

- (GeoFence *)setUpCircularGeoRegionWithLatitude:(double)latitude andLongitude:(double)longitude andRadiusInMeters:(NSInteger)radius andIdentifier:(NSString *)identifier andTitle:(NSString *)title andSubtitle:(NSString *)subtitle {
    
    NSString *geoFenceIdentifier = [NSString stringWithFormat:@"%lu.%@", self.geoFences.count, identifier];
    NSString *geoFenceTitle = [NSString stringWithFormat:@"%lu.%@", self.geoFences.count, title];
    NSString *geoFenceSubtitle = [NSString stringWithFormat:@"%lu.%@", self.geoFences.count, subtitle];
    
    // Create geo fence
    GeoFence *geoFence = [[GeoFence alloc] initWithLatitude:latitude andLongitude:longitude andRadius:radius andIdentifier:geoFenceIdentifier andTitle:geoFenceTitle andSubtitle:geoFenceSubtitle];
    
    // Create the geographic region to be monitored
    CLCircularRegion *circularGeoRegion = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(latitude, longitude) radius:radius identifier:geoFenceIdentifier];
    
    [self.circularGeoRegions setObject:circularGeoRegion forKey:geoFence.identifier];
    [self.geoFences setObject:geoFence forKey:geoFence.identifier];
    
    [ViewController saveGeoFences:self.geoFences];
    
    return geoFence;
}

- (void)drawGeoFence:(GeoFence *)geoFence onMapView:(MKMapView *)mapView{
    
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


- (IBAction)switchTapped:(id)sender {
    
    if (self.activateSwitch.isOn) {
        self.mapView.showsUserLocation = YES;
        [self.locationManager startUpdatingLocation];
        [self locationManager:self.locationManager startMonitoringForRegions:self.circularGeoRegions];
        self.statusCheckBarButton.enabled = YES;
    } else {
        self.statusCheckBarButton.enabled = NO;
        [self locationManager:self.locationManager stopMonitoringForRegions:self.circularGeoRegions];
        [self.locationManager stopUpdatingLocation];
        self.mapView.showsUserLocation = NO;
    }
}

- (void)locationManager:(CLLocationManager *)manager stopMonitoringForRegions:(NSDictionary<NSString *,CLCircularRegion *> *)circularGeoRegions {
    
    for (id item in circularGeoRegions) {
        CLCircularRegion *circularRegion = (CLCircularRegion *)item;
        [manager stopMonitoringForRegion:circularRegion];
    }
}

- (void)locationManager:(CLLocationManager *)manager startMonitoringForRegions:(NSDictionary<NSString *,CLCircularRegion *> *)circularGeoRegions {
    
    for (id item in circularGeoRegions) {
        CLCircularRegion *circularRegion = (CLCircularRegion *)item;
        [manager startMonitoringForRegion:circularRegion];
    }
}

- (void)locationManager:(CLLocationManager *)manager requestStateForRegions:(NSDictionary<NSString *,CLCircularRegion *> *)circularGeoRegions {
    
    for (id item in circularGeoRegions) {
        CLCircularRegion *circularRegion = (CLCircularRegion *)item;
        [manager requestStateForRegion:circularRegion];
    }
}

- (IBAction)statusCheckTapped:(id)sender {
    [self locationManager:self.locationManager requestStateForRegions:self.circularGeoRegions];
}

- (void)addCurrentAnnotation {
    self.currentAnnotation = [[MKPointAnnotation alloc] init];
    self.currentAnnotation.coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
    self.currentAnnotation.title = @"My Location";
}

- (void)centerMap:(MKPointAnnotation *)centerPoint {
    [self.mapView setCenterCoordinate:centerPoint.coordinate animated:YES];
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
    customPinView.pinColor = MKPinAnnotationColorPurple;
    customPinView.animatesDrop = YES;
    customPinView.canShowCallout = YES;
    
    // Because this is an iOS app, add the detail disclosure button to display details about the annotation in another view.
    
    // Add a custom image to the left side of the callout.
//    UIImageView *myCustomImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MyCustomImage.png"]];
//    customPinView.leftCalloutAccessoryView = myCustomImage;
    UIButton *moreInfoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [moreInfoButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    customPinView.rightCalloutAccessoryView = moreInfoButton;
    
    UIImage *trashBinImage = [UIImage imageNamed:@"trash_bin"];
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [moreInfoButton setImage:trashBinImage forState:UIControlStateNormal];
    customPinView.leftCalloutAccessoryView = moreInfoButton;
    
    return customPinView;
}

#pragma mark - mapview callbacks

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

#pragma mark - long press gesture recognizer

- (IBAction)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
    pointAnnotation.coordinate = touchMapCoordinate;
    
    [self.mapView addAnnotation:pointAnnotation];
    
    GeoFence *geoFence = [self setUpCircularGeoRegionWithLatitude:touchMapCoordinate.latitude andLongitude:touchMapCoordinate.longitude andRadiusInMeters:10 andIdentifier:@"MyRegionIdentifier" andTitle:@"Where am I?" andSubtitle:@"I'm here!!!"];
    
    [self drawGeoFence:geoFence onMapView:self.mapView];
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

@end
