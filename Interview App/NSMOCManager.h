//
//  NSMOCManager.h
//  Interview App
//
//  Created by Gautham Ilango on 06/01/15.
//  Copyright (c) 2015 Gautham Ilango. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NSMOCManager : NSObject
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (instancetype) sharedManager;
@end
