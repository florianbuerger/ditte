//
//  DITMapViewController.m
//  Ditte
//
//  Created by Florian Bürger on 16/05/14.
//  Copyright (c) 2014 keslcod. All rights reserved.
//

#import "DITMapViewController.h"
#import <AKLocationManager/AKLocationManager.h>

@import Social;
@import Accounts;

@interface DITMapViewController () <MKMapViewDelegate, UITextFieldDelegate>
@property MKMapView *mapView;
@property UITextField *searchField;
@property ACAccountStore *accountStore;
@end

@implementation DITMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpUserInterface];
    [self setUpTwitter];
    
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

- (BOOL)userHasAccessToTwitter {
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)setUpTwitter {
    if (![self userHasAccessToTwitter]) {
        DDLogWarn(@"There are no twitter accounts configured.");
        return;
    }

    self.accountStore = [[ACAccountStore alloc] init];
    AGAssert(self.accountStore, @"Account store must not be nil.");
    
    ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [self.accountStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error) {
        if (!granted) {
            DDLogError(@"User did not grant access to Twitter accounts.");
        } else {
            [self askTwitterAPIWithSearchTerm:@"#uikonf"];
        }
    }];
}

- (void)askTwitterAPIWithSearchTerm:(NSString *)searchTerm {
    ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
    NSString *encodedSearchTerm = [searchTerm stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSDictionary *params = @{@"q" : encodedSearchTerm, @"count" : @"25"};
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
    ACAccount *twitterAccount = twitterAccounts.lastObject;
    AGAssert(twitterAccount, @"There must be a Twitter account.");
    request.account = twitterAccount;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData) {
            if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                NSError *jsonError;
                NSDictionary *timelineData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                if (timelineData) {
                    DDLogVerbose(@"Search response: %@\n", timelineData);
                } else {
                    // Our JSON deserialization went awry
                    DDLogError(@"JSON Error: %@", [jsonError localizedDescription]);
                }
            } else {
                // The server did not respond ... were we rate-limited?
                DDLogError(@"The response status code is %d", urlResponse.statusCode);
            }
        }
    }];
}

@end
