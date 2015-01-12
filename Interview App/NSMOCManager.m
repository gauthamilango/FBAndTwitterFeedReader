//
//  NSMOCManager.m
//  Interview App
//
//  Created by Gautham Ilango on 06/01/15.
//  Copyright (c) 2015 Gautham Ilango. All rights reserved.
//

#import "NSMOCManager.h"
#import "AppDelegate.h"

@implementation NSMOCManager
@synthesize managedObjectContext = _managedObjectContext;

+ (instancetype) sharedManager
{
    static NSMOCManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (NSManagedObjectContext *) managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    _managedObjectContext = [((AppDelegate*)[UIApplication sharedApplication].delegate) managedObjectContext];
    
    return _managedObjectContext;
}


@end
