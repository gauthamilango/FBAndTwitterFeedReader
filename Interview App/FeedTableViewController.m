//
//  FeedTableViewController.m
//  Interview App
//
//  Created by Gautham Ilango on 10/01/15.
//  Copyright (c) 2015 Gautham Ilango. All rights reserved.
//

#import <CCBottomRefreshControl/UIScrollView+BottomRefreshControl.h>
#import "FeedTableViewController.h"
#import "LoginViewController.h"
#import "FacebookFeedsWebInterface.h"
#import "Feed+Util.h"
#import "BasicFeedCell.h"
#import "NSMOCManager.h"
#import "PhotoFeedCell.h"
#import "LinkFeedCell.h"
#import "WebViewController.h"
#import "TwitterWebInterface.h"

@interface FeedTableViewController ()
@property (nonatomic,strong) NSMutableArray *feeds;
@property (nonatomic,strong) NSString *fbUserId;
@property (nonatomic,strong) NSString *twitterUserId;
@property (nonatomic,strong) UIRefreshControl *bottomRefreshControl;
@property (nonatomic,strong) NSManagedObjectContext *moc;
@property (nonatomic,strong) NSTimer *reloadTimer;
@property (nonatomic) BOOL FBNotLoggedIn;
@property (nonatomic) BOOL TwitterNotLoggedIn;

@end

@implementation FeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.moc = [[NSMOCManager sharedManager] managedObjectContext];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    [self.refreshControl addTarget:self action:@selector(startRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    [self setRefreshControl:self.refreshControl];
    
    self.bottomRefreshControl = [[UIRefreshControl alloc] init];
    [self.bottomRefreshControl addTarget:self action:@selector(startRefreshing:) forControlEvents:UIControlEventValueChanged];
    self.tableView.bottomRefreshControl = self.bottomRefreshControl;
    
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        NSLog(@"Found a cached session");
        self.fbUserId = [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsFacebookUserID];
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithPermissions:@[@"public_profile",@"read_stream"]
                                       allowLoginUI:NO
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      // Handler for session state changes
                                      // This method will be called EACH time the session state changes,
                                      // also for intermediate states and NOT just when the session open
                                      [self sessionStateChanged:session state:state error:error];
                                      
                                  }];
        
        
        
        // If there's no cached session, we will show a login button
    } else {
            self.FBNotLoggedIn = YES;
    }
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsTwitterOAuthAccessToken] && [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsTwitterOAuthAccessTokenSecret]) {
        self.TwitterNotLoggedIn = NO;
        self.twitterUserId = [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsTwitterUserID];
        [[TwitterWebInterface sharedInterface] startLoadingFeeds];
    }
    else
    {
        self.TwitterNotLoggedIn = YES;
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created_time" ascending:NO];

    self.feeds = [@[] mutableCopy];
    if (!self.FBNotLoggedIn) {
        
        [self.feeds addObjectsFromArray:[Feed allFacebookEntitiesForUserID:self.fbUserId InContext:self.moc]];
    }
    if (!self.TwitterNotLoggedIn) {
        [self.feeds addObjectsFromArray:[Feed allTwitterEntitiesForUserID:self.twitterUserId InContext:self.moc]];
    }
    self.feeds = [[self.feeds sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reload:)
                                                 name:kNotificationFeedsUpdated
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    
      if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
          self.FBNotLoggedIn = NO;
      }
    if ([[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsTwitterOAuthAccessToken] && [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsTwitterOAuthAccessTokenSecret]) {
        
        self.TwitterNotLoggedIn = NO;
    }
    
    
    if (self.FBNotLoggedIn && self.TwitterNotLoggedIn) {
        LoginViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self presentViewController:lvc animated:NO completion:nil];
    }
    else if(self.FBNotLoggedIn)
    {
        UIBarButtonItem *loginFB = [[UIBarButtonItem alloc] initWithTitle:@"Login FB" style:UIBarButtonItemStylePlain target:self action:@selector(loginFacebook)];
        self.navigationItem.rightBarButtonItem = loginFB;
    }
    else if(self.TwitterNotLoggedIn)
    {
        UIBarButtonItem *loginTwitter = [[UIBarButtonItem alloc] initWithTitle:@"Login Twitter" style:UIBarButtonItemStylePlain target:[TwitterWebInterface sharedInterface] action:@selector(loginTwitter)];
        self.navigationItem.rightBarButtonItem = loginTwitter;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.feeds.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Feed *feed = self.feeds[indexPath.row];
    UITableViewCell *defaultCell = [[UITableViewCell alloc] init];
    
    if ([feed.feedNetwork isEqualToString:FeedNetworkTypeTwitter]) {

        if ([feed.type isEqualToString:@"status"]) {
            BasicFeedCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BasicTweetCell"];
            cell.feed = feed;
            return cell;
        }
        else if([feed.type isEqualToString:@"photo"])
        {
            PhotoFeedCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PhotoTweetCell"];
            cell.feed = feed;
            return cell;
        }
    }
    
    if ([feed.type isEqualToString:@"status"]) {
        BasicFeedCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BasicFeedCell"];
        cell.feed = feed;
        return cell;
    }
    else if([feed.type isEqualToString:@"photo"])
    {
        PhotoFeedCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PhotoFeedCell"];
        cell.feed = feed;
        return cell;
    }
    else if([feed.type isEqualToString:@"link"])
    {
        LinkFeedCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LinkFeedCell"];
        cell.feed = feed;
        return cell;
    }
    else if ([feed.type isEqualToString:@"video"])
    {
        PhotoFeedCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PhotoFeedCell"];
        cell.feed = feed;
        return cell;
    }
    defaultCell.textLabel.text = feed.type;
    return defaultCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Feed *feed = ((Feed*)(self.feeds[indexPath.row]));
    if ([feed.type isEqualToString:@"status"]) {
        if ([feed.feedNetwork isEqualToString:FeedNetworkTypeTwitter]) {
            return 150;
        }
        return 116;
    }else if ([feed.type isEqualToString:@"photo"])
    {
        if ([feed.feedNetwork isEqualToString:FeedNetworkTypeTwitter]) {
            return 374;
        }
    return 340;
    }
    return 434;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Feed *feed = self.feeds[indexPath.row];
    if ([feed.type isEqualToString:@"link"]) {
        WebViewController *wvc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        wvc.url = [NSURL URLWithString:feed.link];
        [self.navigationController showViewController:wvc sender:nil];
    }
    if ([feed.type isEqualToString:@"video"]) {
        WebViewController *wvc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        wvc.url = [NSURL URLWithString:feed.video_source];
        [self.navigationController showViewController:wvc sender:nil];
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions

- (IBAction)logoutBarButtonItemTapped:(id)sender {
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        // If the session state is not any of the two "open" states when the button is clicked
    }
    
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsTwitterOAuthAccessToken];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsTwitterOAuthAccessTokenSecret];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsTwitterUserID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsFacebookUserID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    LoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:loginViewController animated:YES completion:nil];
}

#pragma mark - Public methods

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

- (void)twitterUserLoggedInWithUserID: (NSString*)userID
{
    self.twitterUserId = userID;
    self.TwitterNotLoggedIn = NO;
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    [[TwitterWebInterface sharedInterface] startLoadingFeeds];
}

#pragma mark - Private methods

- (void)userLoggedOut
{
    LoginViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:lvc animated:YES completion:nil];
}

// Show the user the logged-in UI
- (void)userLoggedIn
{
    self.FBNotLoggedIn = NO;
    [[FBRequest requestForMe] startWithCompletionHandler:
     ^(FBRequestConnection *connection,
       NSDictionary<FBGraphUser> *user,
       NSError *error) {
         if (!error) {
             
             [[NSUserDefaults standardUserDefaults] setObject:user.objectID forKey:kUserDefaultsFacebookUserID];
             self.fbUserId = user.objectID;
             [self inititiateRequestForFeeds];
             
         }
     }];
    
    // Set the button title as "Log out"
    
}

// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
}

- (void)reload:(NSNotification*)notification
{
    if (self.tableView.isDragging || self.tableView.isDecelerating) {
        if (!self.reloadTimer) {
             self.reloadTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(reload:) userInfo:nil repeats:YES];
        }
        return;
    }
    
    
    [self.reloadTimer performSelectorOnMainThread:@selector(invalidate)
                                             withObject:nil waitUntilDone:YES];
    
    self.reloadTimer = nil;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created_time"
                                                                   ascending:NO];
    
    self.feeds = [@[] mutableCopy];
    if (!self.FBNotLoggedIn) {
        
        [self.feeds addObjectsFromArray:[Feed allFacebookEntitiesForUserID:self.fbUserId InContext:self.moc]];
    }
    if (!self.TwitterNotLoggedIn) {
        [self.feeds addObjectsFromArray:[Feed allTwitterEntitiesForUserID:self.twitterUserId InContext:self.moc]];
    }
    self.feeds = [[self.feeds sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
    [self.tableView reloadData];
    if([self.refreshControl isRefreshing])
    {
        [self.refreshControl endRefreshing];
    }
    
    if([self.bottomRefreshControl isRefreshing])
    {
        [self.bottomRefreshControl endRefreshing];
    }
}

- (void)inititiateRequestForFeeds
{
    if (self.fbUserId) {
        [FacebookFeedsWebInterface sharedInterface].userID = self.fbUserId;
        [[FacebookFeedsWebInterface sharedInterface] startLoadingFeeds];
    }
    else
    {
        [self userLoggedIn];
    }
}

- (void)startRefreshing: (UIRefreshControl*)refreshControl
{
    if (refreshControl == self.refreshControl) {
        [[FacebookFeedsWebInterface sharedInterface] loadPrevious];
        [[TwitterWebInterface sharedInterface] loadNext];
    }
    if (refreshControl == self.bottomRefreshControl) {
        [[FacebookFeedsWebInterface sharedInterface] loadNext];
        [[TwitterWebInterface sharedInterface] loadPrevious];

    }
    

}

- (void)loginFacebook
{
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"read_stream"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         __block NSString *alertText;
         __block NSString *alertTitle;
         if (!error){
             // If the session was opened successfully
             if (state == FBSessionStateOpen){
                 // Your code here
                 NSLog(@"Logged In");
                 [self sessionStateChanged:session state:state error:error];
                 
             } else {
                 // There was an error, handle it
                 if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
                     // Error requires people using an app to make an action outside of the app to recover
                     // The SDK will provide an error message that we have to show the user
                     alertTitle = @"Something went wrong";
                     alertText = [FBErrorUtility userMessageForError:error];
                     [[[UIAlertView alloc] initWithTitle:alertTitle
                                                 message:alertText
                                                delegate:self
                                       cancelButtonTitle:@"OK!"
                                       otherButtonTitles:nil] show];
                     
                 } else {
                     // If the user cancelled login
                     if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                         alertTitle = @"Login cancelled";
                         alertText = @"Your cannot view your feed because you didn't grant the permission.";
                         [[[UIAlertView alloc] initWithTitle:alertTitle
                                                     message:alertText
                                                    delegate:self
                                           cancelButtonTitle:@"OK!"
                                           otherButtonTitles:nil] show];
                         
                     } else {
                         if([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryInvalid)
                         {
                             return ;
                         }
                         // For simplicity, in this sample, for all other errors we show a generic message
                         // You can read more about how to handle other errors in our Handling errors guide
                         // https://developers.facebook.com/docs/ios/errors/
                         NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"]
                                                            objectForKey:@"body"]
                                                           objectForKey:@"error"];
                         alertTitle = @"Something went wrong";
                         alertText = [NSString stringWithFormat:@"Please retry. \n If the problem persists contact us and mention this error code: %@",[errorInformation objectForKey:@"message"]];
                         [[[UIAlertView alloc] initWithTitle:alertTitle
                                                     message:alertText
                                                    delegate:self
                                           cancelButtonTitle:@"OK!"
                                           otherButtonTitles:nil] show];
                     }
                 }
             }
         }
     }];
}



@end
