//
//  DITMapViewController.m
//  Ditte
//
//  Created by Florian Bürger on 16/05/14.
//  Copyright (c) 2014 keslcod. All rights reserved.
//

#import "DITMapViewController.h"
#import "DITTwitterSearcher.h"
#import "DITTweet.h"
#import <AKLocationManager/AKLocationManager.h>
#import <SVProgressHUD/SVProgressHUD.h>

static NSString *const DITAnnotationViewIdentifier = @"DITTweetAnnotationViewIdentifier";

@interface DITMapViewController () <MKMapViewDelegate, UITextFieldDelegate>
@property MKMapView *mapView;
@property UITextField *searchField;
@end

@implementation DITMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUpUserInterface];

    [AKLocationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [AKLocationManager startLocatingWithUpdateBlock:^(CLLocation *location) {
        [self zoomToLocation:location];
    }                                   failedBlock:^(NSError *error) {
        if (error) {
            DDLogError(@"Unable to start location updates. %@", error);
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.searchField becomeFirstResponder];
}

- (void)zoomToLocation:(CLLocation *)location {
    MKCoordinateRegion region;
    region.center = location.coordinate;
    region.span = MKCoordinateSpanMake(location.horizontalAccuracy / 111, location.verticalAccuracy / 111);
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];

    DDLogVerbose(@"Zooming to location %@", location);
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    BOOL isValid = [self validateInputInTextField:textField];
    if (isValid) {
        [self handOffSearch:textField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL isValid = [self validateInputInTextField:textField];
    [textField resignFirstResponder];
    return isValid;
}

- (BOOL)validateInputInTextField:(UITextField *)textField {
    NSString *searchTerm = textField.text;
    if (searchTerm.length <= 2) {
        DDLogWarn(@"The user should enter a search term that is longer than 2 characters.");
        return NO;
    }
    return YES;
}

#pragma mark - MKMapViewDelegate

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    DDLogVerbose(@"MapView %@ willStartLoadingMap", mapView);
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    DDLogVerbose(@"MapView %@ mapViewDidFinishLoadingMap", mapView);
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    DDLogVerbose(@"MapView %@ mapViewDidFailLoadingMap", mapView);
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    if ([annotation isKindOfClass:[DITTweet class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:DITAnnotationViewIdentifier];
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:DITAnnotationViewIdentifier];
            annotationView.animatesDrop = YES;
            annotationView.canShowCallout = YES;
        }
        annotationView.annotation = annotation;

        return annotationView;
    }
    return nil;
}

#pragma mark - Setup

- (void)handOffSearch:(NSString *)searchTerm {
    [SVProgressHUD showWithStatus:@"Searching…" maskType:SVProgressHUDMaskTypeClear];
    [[DITTwitterSearcher sharedSearcher] askTwitterAPIWithSearchTerm:searchTerm completion:^(NSArray *tweets) {
        [SVProgressHUD popActivity];
        [self.mapView addAnnotations:tweets];
    } error:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"IT FAILED"];
    }];
}

- (void)setUpUserInterface {
    CGFloat inset = 8.0f;
    CGRect fieldFrame = {{inset, 20.0f}, {CGRectGetWidth(self.view.bounds) - 2 * inset, 37.0f}};
    fieldFrame = CGRectInset(fieldFrame, inset, 0);
    UITextField *searchField = [[UITextField alloc] initWithFrame:fieldFrame];
    searchField.delegate = self;
    searchField.returnKeyType = UIReturnKeySearch;
    searchField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchField.autocorrectionType = UITextAutocorrectionTypeNo;
    searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchField.text = @"#uikonf";
    [self.view addSubview:searchField];
    self.searchField = searchField;

    CGRect mapViewFrame = {{0, CGRectGetMaxY(fieldFrame)}, {CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetHeight(fieldFrame)}};
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:mapViewFrame];
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    [self.view addSubview:mapView];
    self.mapView = mapView;
}

@end
