//
//  DITTweet.h
//  Ditte
//
//  Created by Florian Bürger on 16/05/14.
//  Copyright (c) 2014 keslcod. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MapKit;

@interface DITTweet : NSObject <MKAnnotation>

@property(nonatomic, copy, readonly) CLLocation *location;
@property(nonatomic, copy, readonly) NSString *username;
@property(nonatomic, copy, readonly) NSString *userFirstName;
@property(nonatomic, copy, readonly) NSString *userLastName;

+ (instancetype)tweetFromDictionary:(NSDictionary *)tweetDictionary;

@end
