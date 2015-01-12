//
//  NSEntityDescription+Util.m
//  Interview App
//
//  Created by Gautham Ilango on 06/01/15.
//  Copyright (c) 2015 Gautham Ilango. All rights reserved.
//

#import "NSEntityDescription+Util.h"

@implementation NSEntityDescription (Util)

+ (NSManagedObject *) insertOrUpdateObjectWithID:(NSString *) oid userID:(NSString*)userID socialNetworkType:(NSString*)socialNetworkType forEntityForName:(NSString *) name inManagedObjectContext:(NSManagedObjectContext*) objectcontext
{
    
    NSString *firstChar = [name substringWithRange:NSMakeRange(0, 1)];
    firstChar = [firstChar lowercaseString];
    NSString *lowerName = [name stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstChar];
    
    NSString *objectIDKey = [lowerName stringByAppendingString:@"_id"];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:name inManagedObjectContext:objectcontext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                             @"(%K == %@) AND (%K == %@) AND (%K == %@)",@"feedNetwork", socialNetworkType,@"user_id",userID,objectIDKey,oid];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [objectcontext executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"%@",error.description);
    }
    
    if(array && [array count] > 0)
    {
        return array[0];
    }
    else
    {
        return [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:objectcontext];
    }
}

@end
