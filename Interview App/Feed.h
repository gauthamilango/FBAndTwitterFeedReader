//
//  Feed.h
//  Interview App
//
//  Created by Gautham Ilango on 12/01/15.
//  Copyright (c) 2015 Gautham Ilango. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Feed : NSManagedObject

@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSDate * created_time;
@property (nonatomic, retain) NSString * feed_description;
@property (nonatomic, retain) NSString * feed_id;
@property (nonatomic, retain) NSString * feedNetwork;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * from_id;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * picture;
@property (nonatomic, retain) NSString * place;
@property (nonatomic, retain) NSString * story;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * updated_time;
@property (nonatomic, retain) NSString * user_id;
@property (nonatomic, retain) NSString * video_source;
@property (nonatomic, retain) NSNumber * withFullPicture;
@property (nonatomic, retain) NSNumber * retweet_count;
@property (nonatomic, retain) NSNumber * favorite_count;
@property (nonatomic, retain) NSString * userImageUrl;

@end
