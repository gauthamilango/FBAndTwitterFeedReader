//
//  Feed+Util.h
//  Interview App
//
//  Created by Gautham Ilango on 06/01/15.
//  Copyright (c) 2015 Gautham Ilango. All rights reserved.
//

#import "Feed.h"

@interface Feed (Util)

+ (NSArray*) allEntitiesWithoutFullPictureInContext: (NSManagedObjectContext*)moc;
+ (NSArray*) allEntitiesInContext: (NSManagedObjectContext*)moc;
+ (NSArray*) allFacebookEntitiesForUserID:(NSString*)userID InContext:(NSManagedObjectContext*)moc;
+ (NSArray*) allTwitterEntitiesForUserID:(NSString*)userID InContext:(NSManagedObjectContext*)moc;
+ (instancetype) feedFromFBWithId:(NSString*)objectID inContext:(NSManagedObjectContext*)moc;
@end
