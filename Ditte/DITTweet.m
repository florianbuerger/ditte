//
//  DITTweet.m
//  Ditte
//
//  Created by Florian Bürger on 16/05/14.
//  Copyright (c) 2014 keslcod. All rights reserved.
//

#import "DITTweet.h"
#import <objc-geohash/GeoHash.h>

@interface DITTweet ()

@property(nonatomic, copy, readwrite) NSString *username;
@property (nonatomic, copy, readwrite) NSString *userFullName;
@property (nonatomic, copy, readwrite) CLLocation *location;
@property (nonatomic, copy, readwrite) NSString *geoHash;
@property (nonatomic, copy, readwrite) NSURL *profileImageURL;

@end

@implementation DITTweet


- (CLLocationCoordinate2D)coordinate {
    return self.location.coordinate;
}

- (NSString *)title {
    return self.userFullName;
}

- (NSString *)subtitle {
    return self.username;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[%@: {username = %@, userFullName = %@, location = %@, profileImageURL = %@}]", self.class, self.username, self.userFullName, self.location, self.profileImageURL];
}

+ (instancetype)tweetFromDictionary:(NSDictionary *)tweetDictionary {
    DITTweet *tweet = [DITTweet new];

    NSDictionary *userDetailsDictionary = tweetDictionary[@"user"];

    tweet.username = [NSString stringWithFormat:@"@%@", userDetailsDictionary[@"screen_name"]];
    tweet.userFullName = userDetailsDictionary[@"name"];
    tweet.profileImageURL = [[NSURL alloc] initWithString:userDetailsDictionary[@"profile_image_url"]];

    NSDictionary *coordinateDictionary = tweetDictionary[@"coordinates"];
    NSArray *coordinates = coordinateDictionary[@"coordinates"];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[coordinates[1] doubleValue] longitude:[coordinates[0] doubleValue]];
    tweet.location = location;

    NSString *geoHash = [GeoHash hashForLatitude:location.coordinate.latitude
                                       longitude:location.coordinate.longitude
                                          length:12];
    tweet.geoHash = geoHash;

    return tweet;
}

- (NSString *)userFirstName {
    return [[self.userFullName componentsSeparatedByString:@" "] firstObject];
}

- (NSString *)userLastName {
    return [[self.userFullName componentsSeparatedByString:@" "] lastObject];
}

@end
