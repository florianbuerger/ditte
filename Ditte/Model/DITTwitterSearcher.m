//
//  DITTwitterSearcher.m
//  Ditte
//
//  Created by Florian Bürger on 16/05/14.
//  Copyright (c) 2014 keslcod. All rights reserved.
//

#import "DITTwitterSearcher.h"
#import "DITTweet.h"
#import "DITProfileImageFetcherRequester.h"

@import Social;
@import Accounts;

@interface DITTwitterSearcher ()
@property ACAccountStore *accountStore;
@property(nonatomic, strong) NSCache *cache;
@end

@implementation DITTwitterSearcher

+ (instancetype)sharedSearcher {
    static DITTwitterSearcher *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DITTwitterSearcher alloc] init];
    });
    return instance;
}

- (id)init {
    if ((self = [super init])) {
        [self setUpTwitter];
        _cache = [[NSCache alloc] init];
    }
    return self;
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
            DDLogError(@"User did not grant access to Twitter accounts. This won't work now.");
        }
    }];
}

- (void)askTwitterAPIWithSearchTerm:(NSString *)searchTerm completion:(void (^)(NSArray *tweets))completionHandler error:(void (^)(NSError *error))errorHandler {
    ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
    NSString *encodedSearchTerm = [searchTerm stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSDictionary *params = @{@"q" : encodedSearchTerm, @"count" : @"500"};
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
    ACAccount *twitterAccount = twitterAccounts.lastObject;
    AGAssert(twitterAccount, @"There must be a Twitter account.");
    request.account = twitterAccount;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData) {
            if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                NSError *jsonError;
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                if (data) {

                    NSMutableArray *tweets = [NSMutableArray array];
                    NSArray *statuses = data[@"statuses"];
                    for (NSDictionary *statusDictionary in statuses) {

                        NSDictionary *coordinates = statusDictionary[@"coordinates"];
                        if (![coordinates isEqual:[NSNull null]]) {
                            DITTweet *tweet = [DITTweet tweetFromDictionary:statusDictionary];
                            [[DITProfileImageFetcherRequester sharedImageFetcherRequester] fetchProfileImage:tweet];
                            [tweets addObject:tweet];
                        }
                    }

                    if (completionHandler) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionHandler(tweets);
                        });
                    }

                } else {
                    // Our JSON deserialization went awry
                    DDLogError(@"JSON Error: %@", [jsonError localizedDescription]);
                    if (errorHandler) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            errorHandler(jsonError);
                        });
                    }
                }
            } else {
                // The server did not respond ... were we rate-limited?
                DDLogError(@"The response status code is %d", urlResponse.statusCode);
            }
        }
    }];
}

@end
