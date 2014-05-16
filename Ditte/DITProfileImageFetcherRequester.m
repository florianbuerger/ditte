//
// Created by Florian Bürger on 16/05/14.
// Copyright (c) 2014 keslcod. All rights reserved.
//

#import "DITProfileImageFetcherRequester.h"
#import "DITTweet.h"


@interface DITProfileImageFetcherRequester ()
@property(nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation DITProfileImageFetcherRequester

+ (instancetype)sharedImageFetcherRequester {
    static DITProfileImageFetcherRequester *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DITProfileImageFetcherRequester alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
    }

    return self;
}

- (void)fetchProfileImage:(DITTweet *)tweet {
    [self.operationQueue addOperationWithBlock:^{
        NSURLRequest *request = [NSURLRequest requestWithURL:tweet.profileImageURL];
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        DDLogVerbose(@"Download finished. Response object %@", response);
        if (!imageData) {
            DDLogError(@"Failed to download image. %@", error);
        }
        tweet.profileImage = [UIImage imageWithData:imageData];
    }];
}


@end