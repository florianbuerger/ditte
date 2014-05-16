//
// Created by Florian Bürger on 16/05/14.
// Copyright (c) 2014 keslcod. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DITTweet;
@import MapKit;

@interface DITTweetCluster : NSObject <MKAnnotation>

- (void)addTweetToCluster:(DITTweet *)tweet;

@end