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
#import "Geocoder.h"
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
    
    self.mapIsMoving = NO;
    [self configureUI];
    
    [self configureLocationManager];
    [self mapView:self.mapView zoomInWithWidth:500 andHeight:500];
    
    [self configureGeoLocationAuthorization];
    
    // Create an annotation for the user's location
    [self addCurrentLocationAnnotation];
    
    [self loadCircularRegions];
    [self drawGeoFencesOnMapView:self.mapView];
}

# pragma mark - geocoder delegate method

- (void)parseGeocoderResultForLocation:(CLLocation *)location withPlacemarks:(NSArray *)placemarks orError:(NSError *)error {
    
    if (error) {
        
        NSLog(@"There was a problem reverse geocoding");
        NSLog([error localizedDescription]);
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"There was a problem reverse geocoding" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"Ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"Ok action");
            [self createCustomGeoFenceWithLocation:location andPlacemarks:nil];
        }];
        
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self createCustomGeoFenceWithLocation:location andPlacemarks:placemarks];
    }
}

- (void)createCustomGeoFenceWithLocation:(CLLocation *)location andPlacemarks:(NSArray *)placemarks {
    NSString *addressName;
    NSString *administrativeAreaName;
    NSString *countryName;
    
    for (CLPlacemark *placemark in placemarks) {
        if (nil != placemark.name) {
            addressName = placemark.name;
        }
        if (nil != placemark.administrativeArea) {
            administrativeAreaName = placemark.administrativeArea;
        }
        if (nil != placemark.country) {
            countryName = placemark.country;
        }
        
        break;
    }
    
    NSString *subtitle = nil == administrativeAreaName && nil == countryName ? nil : [NSString stringWithFormat:@"%@, %@", administrativeAreaName, countryName];
    
    [self createCustomGeoFenceWithLatitude:location.coordinate.latitude andLongitude:location.coordinate.longitude andTitle:addressName andSubtitle:subtitle];
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

- (IBAction)statusCheckTapped:(id)sender {
    [self locationManager:self.locationManager requestStateForRegions:self.circularGeoRegions];
}

#pragma mark - long press gesture recognizer

- (IBAction)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    __weak typeof(self)weakSelf = self;
    [[Geocoder sharedInstance] startReverseGeocodeWithLatitude:touchMapCoordinate.latitude andLongitude:touchMapCoordinate.longitude andDelegate:weakSelf];
}

# pragma mark - map view category methods proxy

- (void)centerMapView:(MKPointAnnotation *)centerPoint {
    [self centerMapView:self.mapView atCenterPoint:centerPoint];
}

# pragma mark - geo fence creation and management methods

- (void)createCustomGeoFenceWithLatitude:(double)latitude andLongitude:(double)longitude {
    
    [self createCustomGeoFenceWithLatitude:latitude andLongitude:longitude andTitle:nil andSubtitle:nil];
}
- (void)createCustomGeoFenceWithLatitude:(double)latitude andLongitude:(double)longitude andTitle:(NSString *)title andSubtitle:(NSString *)subtitle {
    
    NSString *alertTitle = @"New Geo Fence";
    NSString *alertMessage = @"Fill in the Geo Fence data";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [NSDate date];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    // http://useyourloaf.com/blog/uialertcontroller-changes-in-ios-8/
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"IdentifierPlaceholder", @"Identifier");
        textField.text = [NSString stringWithFormat:@"GeoFenceId:%@:%f,%f", formattedDateString, latitude ,longitude];
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"TitlePlaceholder", @"Title");
        textField.text = nil == title ? @"Where am I?" : title;
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"SubtitlePlaceholder", @"Subtitle");
        textField.text = nil == subtitle ? @"I'm here!!!" : subtitle;
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
        
        GeoFence *geoFence = [self createGeoFenceWithLatitude:latitude andLongitude:longitude andRadiusInMeters:radius andIdentifier:identifier andTitle:title andSubtitle:subtitle];
        
        [self drawGeoFence:geoFence onMapView:self.mapView];
        
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
