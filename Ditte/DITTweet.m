//
//  DITTweet.m
//  Ditte
//
//  Created by Florian Bürger on 16/05/14.
//  Copyright (c) 2014 keslcod. All rights reserved.
//

#import "DITTweet.h"

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

@end
