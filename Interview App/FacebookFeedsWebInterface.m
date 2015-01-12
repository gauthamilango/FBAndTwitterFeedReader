//
//  FacebookFeedsWebInterface.m
//  Interview App
//
//  Created by Gautham Ilango on 05/01/15.
//  Copyright (c) 2015 Gautham Ilango. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "FacebookFeedsWebInterface.h"
#import "Feed+Util.h"
#import "NSMOCManager.h"
#import "NSEntityDescription+Util.h"

@interface FacebookFeedsWebInterface()

@property(nonatomic,strong) NSManagedObjectContext* moc;
@end

@implementation FacebookFeedsWebInterface

+ (instancetype)sharedInterface {
    static FacebookFeedsWebInterface *sharedInstance = nil;
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

- (void)startLoadingFeeds
{
    [FBRequestConnection startWithGraphPath:@"/me/home"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              FBGraphObject *result,
                                              NSError *error
                                              ) {
                              if (!error) {
                                  NSDictionary *pagingDictionary = [result objectForKey:@"paging"];
                                  if (pagingDictionary) {
                                      [[NSUserDefaults standardUserDefaults] setURL:[NSURL URLWithString:pagingDictionary[@"previous"]] forKey:kUserDefaultsFBPreviousUrl];
                                      [[NSUserDefaults standardUserDefaults] setURL:[NSURL URLWithString:pagingDictionary[@"next"]] forKey:kUserDefaultsFBNextUrl];
                                      [[NSUserDefaults standardUserDefaults] synchronize];
                                  }
                                  NSArray *postArray = [result objectForKey:@"data"];
                                  if (postArray.count == 0) {
                                      [self getFullPicturesForEntitiesWithoutFullPictures];
                                      return;
                                  }
                                  NSDateFormatter *df = [[NSDateFormatter alloc] init];
                                  df.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZ";
                                  for(FBGraphObject* post in postArray)
                                  {
                                      Feed *feed = (Feed*)[NSEntityDescription insertOrUpdateObjectWithID:[post objectForKey:@"id"] userID:self.userID socialNetworkType:FeedNetworkTypeFacebook forEntityForName:@"Feed" inManagedObjectContext:self.moc];
                                      feed.feedNetwork = FeedNetworkTypeFacebook;
                                      feed.user_id = self.userID;
                                      feed.feed_id = [post objectForKey:@"id"];
                                      feed.from = [[post objectForKey:@"from"] objectForKey:@"name"];
                                      feed.from_id = [[post objectForKey:@"from"] objectForKey:@"id"];
                                      feed.type = [post objectForKey:@"type"];
                                      if ([post objectForKey:@"status_type"]) {
                                          feed.story = [post objectForKey:@"status_type"];
                                      }
                                      else
                                      {
                                          feed.story = [post objectForKey:@"story"];
                                      }
                                      
                                      feed.updated_time = [df dateFromString:[post objectForKey:@"updated_time"]];
                                      feed.created_time = [df dateFromString:[post objectForKey:@"created_time"]];
                                      
                                      if ([feed.type isEqualToString:@"photo"]) {
                                          
                                          feed.message = [post objectForKey:@"message"];
                                          feed.picture = [post objectForKey:@"picture"];
                                          
                                      }
                                      else if([feed.type isEqualToString:@"video"])
                                      {
                                          feed.message = [post objectForKey:@"message"];
                                          feed.picture = [post objectForKey:@"picture"];
                                          feed.video_source = [post objectForKey:@"source"];
                                      }
                                      else if([feed.type isEqualToString:@"status"])
                                      {
                                          feed.message = [post objectForKey:@"message"];
                                          if (feed.message != nil) {
                                              feed.withFullPicture = @YES;
                                          }
                                          else
                                          {
                                              [self.moc deleteObject:feed];
                                          }
                                          
                                          
                                      }
                                      else if([feed.type isEqualToString:@"link"])
                                      {
                                          feed.message = [post objectForKey:@"message"];
                                          feed.link = [post objectForKey:@"link"];
                                          feed.picture = [post objectForKey:@"picture"];
                                          feed.feed_description = [post objectForKey:@"description"];
                                          feed.caption = [post objectForKey:@"caption"];
                                      }
                                  }
                                  [self.moc save:&error];
                                  if (error) {
                                      NSLog(@"%@",error.description);
                                  }
                                  [self getFullPicturesForEntitiesWithoutFullPictures];
                              }
                              else
                              {
                                  NSLog(@"%@",error.description);
                              }
                              /* handle the result */
                          }];
    
   
    
    
    
}

- (void)getFullPicturesForEntitiesWithoutFullPictures
{
//     NSArray *feedsWithoutFullPicture = [Feed allEntitiesWithoutFullPictureInContext:self.moc];
    if (YES) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFeedsUpdated object:nil];
        return;
    }
    
//     __block NSUInteger fullPictureProcessCompleted = 0;
//    for (Feed *feed in feedsWithoutFullPicture) {
//        
//       
//        if ([feed.type isEqualToString:@"photo"] || [feed.type isEqualToString:@"video"] || [feed.type isEqualToString:@"link"]) {
//            
//            [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@?fields=full_picture",feed.feed_id]
//                                         parameters:nil
//                                         HTTPMethod:@"GET"
//                                  completionHandler:^(
//                                                      FBRequestConnection *connection,
//                                                      FBGraphObject *result,
//                                                      NSError *error
//                                                      ){
//                                      fullPictureProcessCompleted++;
//                                      if (!error && [result objectForKey:@"full_picture"]) {
////                                          NSManagedObjectContext *moc = [[NSMOCManager sharedManager] managedObjectContext];
////                                          Feed *editingFeed = [Feed feedFromFBWithId:feed.feed_id inContext:moc];
////                                          NSLog(@"%lu",(unsigned long)fullPictureProcessCompleted);
////                                          editingFeed.picture = [result objectForKey:@"full_picture"];
////                                          editingFeed.withFullPicture = @YES;
////                                          [moc save:&error];
//                                          dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                                              NSError* error;
//                                              NSManagedObjectContext *moc = [[NSMOCManager sharedManager] managedObjectContext];
//                                              Feed *editingFeed = [Feed feedFromFBWithId:feed.feed_id inContext:moc];
//                                              NSLog(@"%@ %@ %@",editingFeed.feed_id,editingFeed.picture,[result objectForKey:@"full_picture"]);
//                                              editingFeed.picture = [result objectForKey:@"full_picture"];
//                                              editingFeed.withFullPicture = @YES;
//                                              [moc save:&error];
//                                              if (error) {
//                                                  NSLog(@"error: %@",error.description);
//                                              }
//                                          });
//                                         
//                                      } else if (error)
//                                      {
//                                          NSLog(@"error: %@",error.description);
//                                      }
//                                      
//                                      if (fullPictureProcessCompleted == feedsWithoutFullPicture.count) {
//                                           [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFeedsUpdated object:nil];
//                                      }
//                                      
//                                      
//                                  }];
//            
//        }
//    }
    
    

}

- (void)loadNext
{

    
    NSURLRequest *request = [NSURLRequest requestWithURL:[[NSUserDefaults standardUserDefaults] URLForKey:kUserDefaultsFBNextUrl]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if (!error) {
                         NSDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
                            NSDictionary *pagingDictionary = [resultDictionary objectForKey:@"paging"];
                            if (pagingDictionary) {
                                [[NSUserDefaults standardUserDefaults] setURL:[NSURL URLWithString:pagingDictionary[@"previous"]] forKey:kUserDefaultsFBPreviousUrl];
                                [[NSUserDefaults standardUserDefaults] setURL:[NSURL URLWithString:pagingDictionary[@"next"]] forKey:kUserDefaultsFBNextUrl];
                                [[NSUserDefaults standardUserDefaults] synchronize];

                            }
                            NSArray *postArray = [resultDictionary objectForKey:@"data"];
                            if (postArray.count == 0) {
                                [self getFullPicturesForEntitiesWithoutFullPictures];
                                return;
                            }
                            for(FBGraphObject* post in postArray)
                            {
                                Feed *feed = (Feed*)[NSEntityDescription insertOrUpdateObjectWithID:[post objectForKey:@"id"] userID:self.userID socialNetworkType:FeedNetworkTypeFacebook forEntityForName:@"Feed" inManagedObjectContext:self.moc];
                                feed.feedNetwork = FeedNetworkTypeFacebook;
                                feed.user_id = self.userID;
                                feed.feed_id = [post objectForKey:@"id"];
                                feed.from = [[post objectForKey:@"from"] objectForKey:@"name"];
                                feed.from_id = [[post objectForKey:@"from"] objectForKey:@"id"];
                                feed.type = [post objectForKey:@"type"];
                                if ([post objectForKey:@"status_type"]) {
                                    feed.story = [post objectForKey:@"status_type"];
                                }
                                else
                                {
                                    feed.story = [post objectForKey:@"story"];
                                }
                                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                                df.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZ";
                                feed.updated_time = [df dateFromString:[post objectForKey:@"updated_time"]];
                                feed.created_time = [df dateFromString:[post objectForKey:@"created_time"]];
                                
                                if ([feed.type isEqualToString:@"photo"]) {
                                    
                                    feed.message = [post objectForKey:@"message"];
                                    feed.picture = [post objectForKey:@"picture"];
                                    
                                }
                                else if([feed.type isEqualToString:@"video"])
                                {
                                    feed.message = [post objectForKey:@"message"];
                                    feed.picture = [post objectForKey:@"picture"];
                                    feed.video_source = [post objectForKey:@"source"];
                                }
                                else if([feed.type isEqualToString:@"status"])
                                {
                                    feed.message = [post objectForKey:@"message"];
                                    if (feed.message != nil) {
                                        feed.withFullPicture = @YES;
                                    }
                                    else
                                    {
                                        [self.moc deleteObject:feed];
                                    }
                                    
                                    
                                }
                                else if([feed.type isEqualToString:@"link"])
                                {
                                    feed.message = [post objectForKey:@"message"];
                                    feed.link = [post objectForKey:@"link"];
                                    feed.picture = [post objectForKey:@"picture"];
                                    feed.feed_description = [post objectForKey:@"description"];
                                    feed.caption = [post objectForKey:@"caption"];
                                }
                            }
                            [self.moc save:&error];
                            if (error) {
                                NSLog(@"%@",error.description);
                            }
                            [self getFullPicturesForEntitiesWithoutFullPictures];
                    
                        
                    }
                    else
                    {
                        NSLog(@"%@",error.description);
                    }
                   
                    
                    
                }] resume];
}

- (void)loadPrevious
{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[[NSUserDefaults standardUserDefaults] URLForKey:kUserDefaultsFBPreviousUrl]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if (!error) {
                        NSDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        
                        NSDictionary *pagingDictionary = [resultDictionary objectForKey:@"paging"];
                        if (pagingDictionary) {
                            [[NSUserDefaults standardUserDefaults] setURL:[NSURL URLWithString:pagingDictionary[@"previous"]] forKey:kUserDefaultsFBPreviousUrl];
                            [[NSUserDefaults standardUserDefaults] setURL:[NSURL URLWithString:pagingDictionary[@"next"]] forKey:kUserDefaultsFBNextUrl];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                      }
                        NSArray *postArray = [resultDictionary objectForKey:@"data"];
                        if (postArray.count == 0) {
                            [self getFullPicturesForEntitiesWithoutFullPictures];
                            return;
                        }
                        for(FBGraphObject* post in postArray)
                        {
                            Feed *feed = (Feed*)[NSEntityDescription insertOrUpdateObjectWithID:[post objectForKey:@"id"] userID:self.userID socialNetworkType:FeedNetworkTypeFacebook forEntityForName:@"Feed" inManagedObjectContext:self.moc];
                            feed.feedNetwork = FeedNetworkTypeFacebook;
                            feed.user_id = self.userID;
                            feed.feed_id = [post objectForKey:@"id"];
                            feed.from = [[post objectForKey:@"from"] objectForKey:@"name"];
                            feed.from_id = [[post objectForKey:@"from"] objectForKey:@"id"];
                            feed.type = [post objectForKey:@"type"];
                            if ([post objectForKey:@"status_type"]) {
                                feed.story = [post objectForKey:@"status_type"];
                            }
                            else
                            {
                                feed.story = [post objectForKey:@"story"];
                            }
                            NSDateFormatter *df = [[NSDateFormatter alloc] init];
                            df.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZ";
                            feed.updated_time = [df dateFromString:[post objectForKey:@"updated_time"]];
                            feed.created_time = [df dateFromString:[post objectForKey:@"created_time"]];
                            
                            if ([feed.type isEqualToString:@"photo"]) {
                                
                                feed.message = [post objectForKey:@"message"];
                                feed.picture = [post objectForKey:@"picture"];
                                
                            }
                            else if([feed.type isEqualToString:@"video"])
                            {
                                feed.message = [post objectForKey:@"message"];
                                feed.picture = [post objectForKey:@"picture"];
                                feed.video_source = [post objectForKey:@"source"];
                            }
                            else if([feed.type isEqualToString:@"status"])
                            {
                                feed.message = [post objectForKey:@"message"];
                                if (feed.message != nil) {
                                    feed.withFullPicture = @YES;
                                }
                                else
                                {
                                    [self.moc deleteObject:feed];
                                }
                                
                                
                            }
                            else if([feed.type isEqualToString:@"link"])
                            {
                                feed.message = [post objectForKey:@"message"];
                                feed.link = [post objectForKey:@"link"];
                                feed.picture = [post objectForKey:@"picture"];
                                feed.feed_description = [post objectForKey:@"description"];
                                feed.caption = [post objectForKey:@"caption"];
                            }
                        }
                        [self.moc save:&error];
                        if (error) {
                            NSLog(@"%@",error.description);
                        }
                        [self getFullPicturesForEntitiesWithoutFullPictures];
                        
                        
                    }
                    else
                    {
                        NSLog(@"%@",error.description);
                    }
                    
                    
                    
                }] resume];
}




@end
