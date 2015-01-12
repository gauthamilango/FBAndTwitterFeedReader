//
//  NSEntityDescription+Util.h
//  Interview App
//
//  Created by Gautham Ilango on 06/01/15.
//  Copyright (c) 2015 Gautham Ilango. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSEntityDescription (Util)
+ (NSManagedObject *) insertOrUpdateObjectWithID:(NSString *) oid userID:(NSString*)userID socialNetworkType:(NSString*)socialNetworkType forEntityForName:(NSString *) name inManagedObjectContext:(NSManagedObjectContext*) objectcontext;
@end
