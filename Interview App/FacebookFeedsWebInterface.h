//
//  FacebookFeedsWebInterface.h
//  Interview App
//
//  Created by Gautham Ilango on 05/01/15.
//  Copyright (c) 2015 Gautham Ilango. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookFeedsWebInterface : NSObject

@property (nonatomic,strong) NSString *userID;
//Public Methods
+ (instancetype)sharedInterface;
- (void)startLoadingFeeds;
- (void)loadNext;
- (void)loadPrevious;

@end
