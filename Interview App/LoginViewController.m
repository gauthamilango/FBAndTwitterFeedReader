//
//  ViewController.m
//  Interview App
//
//  Created by Gautham Ilango on 29/12/14.
//  Copyright (c) 2014 Gautham Ilango. All rights reserved.
//

#import "LoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <STTwitter.h>
#import "FeedTableViewController.h"
#import "TwitterWebInterface.h"
#import <SVProgressHUD.h>

@interface LoginViewController ()
@property (strong,nonatomic) id<FBGraphUser> loggedInUser;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getFeedButtonTapped:(id)sender {
    [FBRequestConnection startWithGraphPath:@"/me/home"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              FBGraphObject *result,
                                              NSError *error
                                              ) {
                              if (!error) {
                                  NSLog(@"Result %@",result);
                              }
                              else
                              {
                                  NSLog(@"%@",error.description);
                              }
                              /* handle the result */
                          }];
    
}
- (IBAction)twitterLoginButtonTapped:(id)sender {
    
    [[TwitterWebInterface sharedInterface] loginTwitter];
//    [SVProgressHUD showWithStatus:@"Loading..."];
//    STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:@"R3T5vY6nFzxJNVybYclogaioG"
//                                                 consumerSecret:@"ulCPiQZCbApC4HY7lbrBjm2b1Pu2x2ClJksLphmwoVMgSRsVVh"];
//    
//    [twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
//        NSLog(@"-- url: %@", url);
//        NSLog(@"-- oauthToken: %@", oauthToken);
//        
////        [SVProgressHUD showWithStatus:@"Loading..."];
//        [SVProgressHUD dismiss];
//        [[UIApplication sharedApplication] openURL:url];
//        
//    } authenticateInsteadOfAuthorize:NO
//                        forceLogin:@(YES)
//                        screenName:nil
//                     oauthCallback:@"noahTestApp://twitter_access_tokens/"
//                        errorBlock:^(NSError *error) {
//                            NSLog(@"-- error: %@", error);
//                        }];
    
}

- (IBAction)facebookLoginButtonTapped:(id)sender {
   
    
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
                  [((FeedTableViewController*)([(UINavigationController*)self.presentingViewController viewControllers][0])) sessionStateChanged:session state:state error:error];
                 
                 [self dismissViewControllerAnimated:YES completion:nil];
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
