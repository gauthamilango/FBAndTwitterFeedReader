//
//  TwitterFeedsWebInterface.h
//  Interview App
//
//  Created by Gautham Ilango on 11/01/15.
//  Copyright (c) 2015 Gautham Ilango. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterWebInterface : NSObject
@property (nonatomic,strong) NSString *userID;
//Public Methods
+ (instancetype)sharedInterface;
- (void)loginTwitter;
- (void)loginTwitter:(void(^)(void))block;
- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier;
- (void)startLoadingFeeds;
- (void)loadNext;
- (void)loadPrevious;
@end
