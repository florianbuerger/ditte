//
// Created by Florian Bürger on 16/05/14.
// Copyright (c) 2014 keslcod. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "DITTweetCluster.h"
#import "DITTweet.h"


@interface DITTweetCluster ()
@property(nonatomic, strong) NSMutableArray *tweets;
@end

@implementation DITTweetCluster

- (id)init {
    self = [super init];
    if (self) {
        _tweets = [[NSMutableArray alloc] init];
    }
}

- (CLLocationCoordinate2D)coordinate {
    DITTweet *aTweet = self.tweets.lastObject;
    return aTweet.location.coordinate;
}

- (NSString *)title {
    return [NSString stringWithFormat:@"%d People tweeted here", self.tweets.count];
}

- (void)addTweetToCluster:(DITTweet *)tweet {
    [self.tweets addObject:tweet];
}


@end