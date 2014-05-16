//
//  DITMapViewController.m
//  Ditte
//
//  Created by Florian Bürger on 16/05/14.
//  Copyright (c) 2014 keslcod. All rights reserved.
//

#import "DITMapViewController.h"
#import <AKLocationManager/AKLocationManager.h>


@interface DITMapViewController () <MKMapViewDelegate, UITextFieldDelegate>
@property MKMapView *mapView;
@property UITextField *searchField;
@end

@implementation DITMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpUserInterface];
    
    [AKLocationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [AKLocationManager startLocatingWithUpdateBlock:^(CLLocation *location) {
        [self zoomToLocation:location];
    } failedBlock:^(NSError *error) {
        if (error) {
            DDLogError(@"Unable to start location updates. %@", error);
        }
    }];
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

#pragma mark - Setup

- (void)setUpUserInterface {
    CGFloat inset = 8.0f;
    CGRect fieldFrame = { {inset, 20.0f}, {CGRectGetWidth(self.view.bounds) - 2 * inset, 37.0f}};
    fieldFrame = CGRectInset(fieldFrame, inset, 0);
    UITextField *searchField = [[UITextField alloc] initWithFrame:fieldFrame];
    searchField.delegate = self;
    [self.view addSubview:searchField];
    self.searchField = searchField;
    
    CGRect mapViewFrame = { {0, CGRectGetMaxY(fieldFrame)}, {CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetHeight(fieldFrame)} };
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:mapViewFrame];
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    [self.view addSubview:mapView];
    self.mapView = mapView;
}

@end
