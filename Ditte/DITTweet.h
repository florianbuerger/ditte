//
//  DITTweet.h
//  Ditte
//
//  Created by Florian Bürger on 16/05/14.
//  Copyright (c) 2014 keslcod. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MapKit;

#import "DITTweetAnnotation.h"

@interface DITTweet : NSObject <DITTweetAnnotation>

@property(nonatomic, copy, readonly) CLLocation *location;
@property (nonatomic, copy, readonly) NSString *geoHash;
@property(nonatomic, copy, readonly) NSString *username;
@property(nonatomic, copy, readonly) NSString *userFirstName;
@property(nonatomic, copy, readonly) NSString *userLastName;
@property(nonatomic, copy, readonly) NSString *userFullName;
@property(nonatomic, copy, readonly) NSURL *profileImageURL;


@property(nonatomic, strong) UIImage *profileImage;

+ (instancetype)tweetFromDictionary:(NSDictionary *)tweetDictionary;

@end
