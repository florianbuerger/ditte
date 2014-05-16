//
//  DITTweet.m
//  Ditte
//
//  Created by Florian Bürger on 16/05/14.
//  Copyright (c) 2014 keslcod. All rights reserved.
//

#import "DITTweet.h"

@interface DITTweet ()

@property (nonatomic, copy, readwrite) CLLocation *location;

@end

@implementation DITTweet


- (CLLocationCoordinate2D)coordinate {
    return self.location.coordinate;
}

- (NSString *)title {
    return [[self.userFirstName stringByAppendingString:@" "] stringByAppendingString:self.userLastName];
}

- (NSString *)subtitle {
    return self.username;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[%@: {location = %@}]", self.class, self.location];
}

+ (instancetype)tweetFromDictionary:(NSDictionary *)tweetDictionary {
    DITTweet *tweet = [DITTweet new];

    NSDictionary *coordinateDictionary = tweetDictionary[@"coordinates"];
    NSArray *coordinates = coordinateDictionary[@"coordinates"];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[coordinates[0] doubleValue] longitude:[coordinates[1] doubleValue]];
    tweet.location = location;

    return tweet;
}

@end
