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
#import "AsyncImageView.h"
#import "DITTweetCluster.h"
#import "DITTweetClusterDetailViewController.h"
#import "DITTweetDetailViewController.h"
#import <AKLocationManager/AKLocationManager.h>
#import <SVProgressHUD/SVProgressHUD.h>

static NSString *const DITAnnotationViewIdentifier = @"DITTweetAnnotationViewIdentifier";
static NSString *const DITClusterAnnotationIdentifier = @"DITClusterAnnotationIdentifier";

@interface DITMapViewController () <MKMapViewDelegate, UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UITextField *searchField;
@end

@implementation DITMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [AKLocationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [AKLocationManager startLocatingWithUpdateBlock:^(CLLocation *location) {
        [self zoomToLocation:location];
    } failedBlock:^(NSError *error) {
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
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, location.horizontalAccuracy * 10000, location.verticalAccuracy * 10000);
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];

    DDLogVerbose(@"Zooming to location %@", location);
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL isValid = [self validateInputInTextField:textField];
    if (isValid) {
        [self handOffSearch:textField.text];
    }
    return YES;
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
            AsyncImageView *asyncImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 64.0f, 64.0f)];
            asyncImageView.showActivityIndicator = YES;
            annotationView.leftCalloutAccessoryView = asyncImageView;
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }

        annotationView.annotation = annotation;
        AsyncImageView *imageView = (AsyncImageView *) annotationView.leftCalloutAccessoryView;
        imageView.imageURL = [(DITTweet *) annotation profileImageURL];

        return annotationView;
    }
    
    if ([annotation isKindOfClass:[DITTweetCluster class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:DITClusterAnnotationIdentifier];
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:DITAnnotationViewIdentifier];
            annotationView.animatesDrop = YES;
            annotationView.canShowCallout = YES;
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        annotationView.annotation = annotation;
        return annotationView;
    }

    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    id tweetOrCluster = view.annotation;
    UIViewController *detailController;
    if ([tweetOrCluster isKindOfClass:[DITTweetCluster class]]) {
        detailController = [self.storyboard instantiateViewControllerWithIdentifier:@"DITTweetClusterDetailViewController"];
        ((DITTweetClusterDetailViewController *)detailController).tweetCluster = tweetOrCluster;
    } else {
        detailController = [self.storyboard instantiateViewControllerWithIdentifier:@"DITTweetDetailViewController"];
        ((DITTweetDetailViewController *)detailController).tweet = tweetOrCluster;
    }
    [self.navigationController pushViewController:detailController animated:YES];
}


#pragma mark - Searching

- (void)handOffSearch:(NSString *)searchTerm {
    [SVProgressHUD showWithStatus:@"Searching…" maskType:SVProgressHUDMaskTypeClear];
    [[DITTwitterSearcher sharedSearcher] askTwitterAPIWithSearchTerm:searchTerm completion:^(NSArray *tweets) {
        [SVProgressHUD popActivity];
        [self.mapView addAnnotations:tweets];
    } error:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"IT FAILED"];
    }];
}

@end
