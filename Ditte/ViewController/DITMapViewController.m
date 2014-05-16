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
@end

@implementation DITMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat inset = 8.0f;
    CGRect fieldFrame = { {inset, 20.0f}, {CGRectGetWidth(self.view.bounds) - 2 * inset, 37.0f}};
    fieldFrame = CGRectInset(fieldFrame, inset, 0);
    UITextField *searchField = [[UITextField alloc] initWithFrame:fieldFrame];
    searchField.delegate = self;
    [self.view addSubview:searchField];
    
    CGRect mapViewFrame = { {0, CGRectGetMaxY(fieldFrame)}, {CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetHeight(fieldFrame)} };
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:mapViewFrame];
    mapView.delegate = self;
    [self.view addSubview:mapView];
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


@end
