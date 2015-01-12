//
//  FeedTableViewController.h
//  Interview App
//
//  Created by Gautham Ilango on 10/01/15.
//  Copyright (c) 2015 Gautham Ilango. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FeedTableViewController : UITableViewController
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
- (void)twitterUserLoggedInWithUserID: (NSString*)userID;
@end
