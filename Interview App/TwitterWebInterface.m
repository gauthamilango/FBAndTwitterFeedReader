//
//  TwitterFeedsWebInterface.m
//  Interview App
//
//  Created by Gautham Ilango on 11/01/15.
//  Copyright (c) 2015 Gautham Ilango. All rights reserved.
//

#import <STTwitter.h>
#import <SVProgressHUD.h>
#import "TwitterWebInterface.h"
#import "FeedTableViewController.h"
#import "Feed+Util.h"
#import "NSMOCManager.h"
#import "NSEntityDescription+Util.h"
#import "AppDelegate.h"

typedef void(^block)(void);

@interface TwitterWebInterface ()
@property (nonatomic, strong) NSManagedObjectContext* moc;
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) NSString *sinceTweetID;
@property (nonatomic, strong) NSString *maxTweetID;
@property (nonatomic, strong) block onMainLoginBlock;
@end

@implementation TwitterWebInterface

+ (instancetype)sharedInterface {
    static TwitterWebInterface *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _moc = [[NSMOCManager sharedManager] managedObjectContext];
    }
    return self;
}

- (void)loginTwitter
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:kTwitterConsumerAPIKey
                                                 consumerSecret:kTwitterConsumerAPIKeySecret];
    
    [self.twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
        [SVProgressHUD dismiss];
            [[UIApplication sharedApplication] openURL:url];
        
    } authenticateInsteadOfAuthorize:NO
                    forceLogin:@(YES)
                    screenName:nil
                 oauthCallback:@"noahTestApp://twitter_access_tokens/"
                    errorBlock:^(NSError *error) {
                        NSLog(@"-- error: %@", error);
                    }];
}

- (void)loginTwitter:(block)block
{
    [self loginTwitter];
    self.onMainLoginBlock = block;
}

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    
    // in case the user has just authenticated through WebViewVC
    
    [_twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        NSLog(@"-- screenName: %@", screenName);
        
        [[NSUserDefaults standardUserDefaults] setObject:oauthToken forKey:kUserDefaultsTwitterOAuthAccessToken];
        [[NSUserDefaults standardUserDefaults] setObject:oauthTokenSecret forKey:kUserDefaultsTwitterOAuthAccessTokenSecret];
        [[NSUserDefaults standardUserDefaults] setObject:screenName forKey:kUserDefaultsTwitterUserID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [((FeedTableViewController*)(((UINavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController).viewControllers[0])) twitterUserLoggedInWithUserID:screenName];
        
        /*
         At this point, the user can use the API and you can read his access tokens with:
         
         _twitter.oauthAccessToken;
         _twitter.oauthAccessTokenSecret;
         
         You can store these tokens (in user default, or in keychain) so that the user doesn't need to authenticate again on next launches.
         
         Next time, just instanciate STTwitter with the class method:
         
         +[STTwitterAPI twitterAPIWithOAuthConsumerKey:consumerSecret:oauthToken:oauthTokenSecret:]
         
         Don't forget to call the -[STTwitter verifyCredentialsWithSuccessBlock:errorBlock:] after that.
         */
        
    } errorBlock:^(NSError *error) {
                NSLog(@"-- %@", [error localizedDescription]);
    }];
}

- (void)startLoadingFeeds
{
    
        
        NSString *oAuthToken = [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsTwitterOAuthAccessToken];
        NSString *oAuthTokenSecret = [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsTwitterOAuthAccessTokenSecret];
        self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:kTwitterConsumerAPIKey consumerSecret:kTwitterConsumerAPIKeySecret oauthToken:oAuthToken oauthTokenSecret:oAuthTokenSecret];
        
        [self.twitter verifyCredentialsWithSuccessBlock:^(NSString* userName){
            [self.twitter getStatusesHomeTimelineWithCount:@"100" sinceID:nil maxID:nil trimUser:nil excludeReplies:@YES contributorDetails:nil includeEntities:nil successBlock:^(NSArray *tweets){
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                df.dateFormat = @"EEE MMM dd HH:mm:ss ZZZ yyyy";
                
                
                NSDictionary *firstTweet = tweets.firstObject;
                NSDictionary *lastTweet = tweets.lastObject;
                
                self.sinceTweetID = firstTweet[@"id_str"];
                self.maxTweetID = lastTweet[@"id_str"];
                for (NSDictionary *tweet in tweets) {
                    
                    NSDictionary *user = tweet[@"user"];
                    Feed *feed = (Feed*)[NSEntityDescription insertOrUpdateObjectWithID:tweet[@"id_str"] userID:userName socialNetworkType:FeedNetworkTypeTwitter forEntityForName:@"Feed" inManagedObjectContext:self.moc];
                    feed.feed_id = tweet[@"id_str"];
                    feed.message = tweet[@"text"];
                    feed.feedNetwork = FeedNetworkTypeTwitter;
                    feed.favorite_count = tweet[@"favorite_count"];
                    feed.retweet_count = tweet[@"retweet_count"];
                    
                    feed.created_time = [df dateFromString:tweet[@"created_at"]];
                    feed.type = @"status";
                    if (tweet[@"entities"][@"media"][0]) {
                        NSDictionary *media = tweet[@"entities"][@"media"][0];
                        feed.type = media[@"type"];
                        feed.picture = media[@"media_url"];
                    }
                    
                    feed.user_id = self.twitter.userName;
                    feed.from_id = user[@"id_str"];
                    feed.userImageUrl = user[@"profile_image_url"];
                    feed.from = user[@"name"];
                    feed.withFullPicture = @YES;
                    
                    
                }
                
                [self.moc save:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFeedsUpdated object:nil];
                
            } errorBlock:^(NSError *error){
                NSLog(@"%@",error.description);
            }];
            

            
            
        
        } errorBlock:^(NSError *error)
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFeedsUpdated object:nil];
             NSLog(@"%@",error.description);
         }];

}

- (void)loadNext
{
    if (!self.twitter) {
        NSString *oAuthToken = [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsTwitterOAuthAccessToken];
        NSString *oAuthTokenSecret = [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsTwitterOAuthAccessTokenSecret];
        self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:kTwitterConsumerAPIKey consumerSecret:kTwitterConsumerAPIKeySecret oauthToken:oAuthToken oauthTokenSecret:oAuthTokenSecret];
    }
    
    [self.twitter verifyCredentialsWithSuccessBlock:^(NSString* userName){
        [self.twitter getStatusesHomeTimelineWithCount:@"100" sinceID:self.sinceTweetID maxID:nil trimUser:nil excludeReplies:@YES contributorDetails:nil includeEntities:nil successBlock:^(NSArray *tweets){
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"EEE MMM dd HH:mm:ss ZZZ yyyy";
            
            
            NSDictionary *firstTweet = tweets.firstObject;
            
            self.sinceTweetID = firstTweet[@"id_str"];
            for (NSDictionary *tweet in tweets) {
                
                NSDictionary *user = tweet[@"user"];
                Feed *feed = (Feed*)[NSEntityDescription insertOrUpdateObjectWithID:tweet[@"id_str"] userID:userName socialNetworkType:FeedNetworkTypeTwitter forEntityForName:@"Feed" inManagedObjectContext:self.moc];
                feed.feed_id = tweet[@"id_str"];
                feed.message = tweet[@"text"];
                feed.feedNetwork = FeedNetworkTypeTwitter;
                feed.favorite_count = tweet[@"favorite_count"];
                feed.retweet_count = tweet[@"retweet_count"];
                
                feed.created_time = [df dateFromString:tweet[@"created_at"]];
                feed.type = @"status";
                if (tweet[@"entities"][@"media"][0]) {
                    NSDictionary *media = tweet[@"entities"][@"media"][0];
                    feed.type = media[@"type"];
                    feed.picture = media[@"media_url"];
                }
                
                feed.user_id = self.twitter.userName;
                feed.from_id = user[@"id_str"];
                feed.userImageUrl = user[@"profile_image_url"];
                feed.from = user[@"name"];
                feed.withFullPicture = @YES;
                
                
            }
            
            [self.moc save:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFeedsUpdated object:nil];
            
        } errorBlock:^(NSError *error){
            NSLog(@"%@",error.description);
        }];
        
      
        
        
        
    } errorBlock:^(NSError *error)
     {
         [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFeedsUpdated object:nil];
         NSLog(@"%@",error.description);
     }];
}

- (void)loadPrevious
{
    if (!self.twitter) {
        NSString *oAuthToken = [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsTwitterOAuthAccessToken];
        NSString *oAuthTokenSecret = [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsTwitterOAuthAccessTokenSecret];
        self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:kTwitterConsumerAPIKey consumerSecret:kTwitterConsumerAPIKeySecret oauthToken:oAuthToken oauthTokenSecret:oAuthTokenSecret];
    }
    
    [self.twitter verifyCredentialsWithSuccessBlock:^(NSString* userName){
        [self.twitter getStatusesHomeTimelineWithCount:@"100" sinceID:nil maxID:self.maxTweetID trimUser:nil excludeReplies:@YES contributorDetails:nil includeEntities:nil successBlock:^(NSArray *tweets){
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"EEE MMM dd HH:mm:ss ZZZ yyyy";
            
            
            NSDictionary *lastTweet = tweets.lastObject;
            
            self.maxTweetID = lastTweet[@"id_str"];
            for (NSDictionary *tweet in tweets) {
                
                NSDictionary *user = tweet[@"user"];
                Feed *feed = (Feed*)[NSEntityDescription insertOrUpdateObjectWithID:tweet[@"id_str"] userID:userName socialNetworkType:FeedNetworkTypeTwitter forEntityForName:@"Feed" inManagedObjectContext:self.moc];
                feed.feed_id = tweet[@"id_str"];
                feed.message = tweet[@"text"];
                feed.feedNetwork = FeedNetworkTypeTwitter;
                feed.favorite_count = tweet[@"favorite_count"];
                feed.retweet_count = tweet[@"retweet_count"];
                
                feed.created_time = [df dateFromString:tweet[@"created_at"]];
                feed.type = @"status";
                if (tweet[@"entities"][@"media"][0]) {
                    NSDictionary *media = tweet[@"entities"][@"media"][0];
                    feed.type = media[@"type"];
                    feed.picture = media[@"media_url"];
                }
                
                feed.user_id = self.twitter.userName;
                feed.from_id = user[@"id_str"];
                feed.userImageUrl = user[@"profile_image_url"];
                feed.from = user[@"name"];
                feed.withFullPicture = @YES;
                
                
            }
            
            [self.moc save:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFeedsUpdated object:nil];
            
        } errorBlock:^(NSError *error){
            NSLog(@"%@",error.description);
        }];
        
        
        
        
    } errorBlock:^(NSError *error)
     {
         [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFeedsUpdated object:nil];
         NSLog(@"%@",error.description);
     }];
}

@end
