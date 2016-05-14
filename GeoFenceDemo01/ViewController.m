//
//  ViewController.m
//  GeoFenceDemo01
//
//  Created by Sebastián Badea on 5/4/16.
//  Copyright © 2016 Sebastian Badea. All rights reserved.
//

#import "MapKit/MapKit.h"
#import "ViewController.h"
#import "GeoFence+UserDefaults.h"
#import "ViewController+LocationManager.h"
#import "ViewController+MapView.h"
#import "SystemVersionVerificationHelper.h"
#import "GeoFence.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *activateSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *statusCheckBarButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadCircularRegions];
    
    [self configureUI];
    
    self.mapIsMoving = NO;
    
    [self configureLocationManager];
    
    [self mapView:self.mapView zoomInWithWidth:500 andHeight:500];
    
    // Create an annotation for the user's location
    [self addCurrentLocationAnnotation];
    
    [self configureGeoLocationAuthorization];
    
    [self drawGeoFencesOnMapView:self.mapView];
}

# pragma mark - UI methods

- (void)configureUI {
    // Turn off the User Interface until permission is obtained
    self.activateSwitch.enabled = NO;
    self.statusCheckBarButton.enabled = NO;
}

- (void)enableActivateSwitch {
    self.activateSwitch.enabled = YES;
}

- (void)setStatusLabelText:(NSString *)text {
    self.statusLabel.text = text;
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

- (void)loadCircularRegions {
    self.geoFences = [[NSMutableDictionary<NSString *,GeoFence *> alloc] init];
    [self.geoFences addEntriesFromDictionary: [GeoFence loadGeoFences]];
    
    self.circularGeoRegions = [[NSMutableDictionary<NSString *, CLCircularRegion *> alloc] init];
    
    for (id item in [self.geoFences allValues]) {
        GeoFence *geoFence = (GeoFence *)item;
        
        CLLocationCoordinate2D locationCoordinate2D = CLLocationCoordinate2DMake(geoFence.centerLatitude, geoFence.centerLongitude);
        CLCircularRegion *circularRegion = [[CLCircularRegion alloc] initWithCenter:locationCoordinate2D radius:geoFence.radius identifier:geoFence.identifier];
        
        [self.circularGeoRegions setObject:circularRegion forKey:geoFence.identifier];
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
    
    [GeoFence saveGeoFences:self.geoFences];
    
    return geoFence;
}

- (IBAction)statusCheckTapped:(id)sender {
    [self locationManager:self.locationManager requestStateForRegions:self.circularGeoRegions];
}

# pragma mark - map view category methods proxy

- (void)centerMapView:(MKPointAnnotation *)centerPoint {
    [self centerMapView:self.mapView atCenterPoint:centerPoint];
}

# pragma mark - geo fence creation and management methods

- (void)createCustomGeoFenceWithLatitude:(double)latitude andLongitude:(double)longitude {
    
    NSString *alertTitle = @"New Geo Fence";
    NSString *alertMessage = @"Fill in the Geo Fence data";
    
    // http://useyourloaf.com/blog/uialertcontroller-changes-in-ios-8/
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"IdentifierPlaceholder", @"Identifier");
        textField.text = @"MyRegionIdentifier";
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"TitlePlaceholder", @"Title");
        textField.text = @"Where am I?";
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"SubtitlePlaceholder", @"Subtitle");
        textField.text = @"I'm here!!!";
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"RadiusPlaceholder", @"Radius in meters");
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.text = @"3";
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"Cancel action");
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UITextField *identifierTextField = alertController.textFields.firstObject;
        UITextField *titleTextField = alertController.textFields[1];
        UITextField *subtitleTextField = alertController.textFields[2];
        UITextField *radiusTextField = alertController.textFields.lastObject;
        
        NSString *identifier = nil == identifierTextField.text ? @"MyRegionIdentifier" : identifierTextField.text;
        NSString *title = nil == titleTextField.text ? @"MyRegionIdentifier" : titleTextField.text;
        NSString *subtitle = nil == subtitleTextField.text ? @"I'm here!!!" : subtitleTextField.text;
        
        NSNumber *radiusNumber = [[[NSNumberFormatter alloc] init] numberFromString:radiusTextField.text];
        NSInteger radius = [radiusNumber integerValue];
        radius = radius <= 0 ? 3 : radius;
        
        GeoFence *geoFence = [self setUpCircularGeoRegionWithLatitude:latitude andLongitude:longitude andRadiusInMeters:radius andIdentifier:identifier andTitle:title andSubtitle:subtitle];
        
        [self drawGeoFence:geoFence onMapView:self.mapView];
        
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - long press gesture recognizer

- (IBAction)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    [self createCustomGeoFenceWithLatitude:touchMapCoordinate.latitude andLongitude:touchMapCoordinate.longitude];
}

@end
