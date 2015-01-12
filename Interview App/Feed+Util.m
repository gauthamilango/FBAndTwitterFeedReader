//
//  Feed+Util.m
//  Interview App
//
//  Created by Gautham Ilango on 06/01/15.
//  Copyright (c) 2015 Gautham Ilango. All rights reserved.
//

#import "Feed+Util.h"
#import "NSMOCManager.h"

@implementation Feed (Util)

+ (NSArray*) allEntitiesWithoutFullPictureInContext: (NSManagedObjectContext*)moc
{
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Feed" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate;
    
        predicate = [NSPredicate predicateWithFormat:@"(withFullPicture == %@) OR (withFullPicture == nil)",@NO];
    
    [request setPredicate:predicate];
    NSError *error;
    NSArray *allObjects = [moc executeFetchRequest:request error:&error];
    
    return allObjects;
}

+ (NSArray*) allEntitiesInContext: (NSManagedObjectContext*)moc
{
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Feed" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSError *error;
    NSArray *allObjects = [moc executeFetchRequest:request error:&error];
    return allObjects;
}

+ (NSArray*) allFacebookEntitiesForUserID:(NSString*)userID InContext:(NSManagedObjectContext*)moc
{
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Feed" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *predicate;
    
    predicate = [NSPredicate predicateWithFormat:
                 @" (%K == %@) AND (%K == %@)",@"feedNetwork", FeedNetworkTypeFacebook,@"user_id",userID];
    
    [request setPredicate:predicate];
    NSError *error;
    NSArray *allObjects = [moc executeFetchRequest:request error:&error];
    return allObjects;
}

+ (NSArray*) allTwitterEntitiesForUserID:(NSString*)userID InContext:(NSManagedObjectContext*)moc
{
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Feed" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate;
    
    predicate = [NSPredicate predicateWithFormat:
                 @" (%K == %@) AND (%K == %@)",@"feedNetwork", FeedNetworkTypeTwitter,@"user_id",userID];
    
    [request setPredicate:predicate];
    NSError *error;
    NSArray *allObjects = [moc executeFetchRequest:request error:&error];
    return allObjects;
}

+ (instancetype)feedFromFBWithId:(NSString*)objectID inContext:(NSManagedObjectContext*)moc
{
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Feed" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate;
    
    predicate = [NSPredicate predicateWithFormat:
                 @" (%K == %@) AND (%K == %@)",@"feedNetwork", FeedNetworkTypeFacebook,@"feed_id",objectID];
    
    [request setPredicate:predicate];
    NSError *error;
    NSArray *allObjects = [moc executeFetchRequest:request error:&error];
    
    return allObjects[0];
}



@end
