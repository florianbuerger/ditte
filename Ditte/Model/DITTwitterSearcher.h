//
//  DITTwitterSearcher.h
//  Ditte
//
//  Created by Florian Bürger on 16/05/14.
//  Copyright (c) 2014 keslcod. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DITTwitterSearcher : NSObject

+ (instancetype)sharedSearcher;
- (void)askTwitterAPIWithSearchTerm:(NSString *)searchTerm completion:(void (^)(NSArray *tweets))completion error:(void (^)(NSError *error))error;

@end
