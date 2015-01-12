//
//  BasicFeedCell.m
//  Interview App
//
//  Created by Gautham Ilango on 09/01/15.
//  Copyright (c) 2015 Gautham Ilango. All rights reserved.
//

#import "BasicFeedCell.h"
#import <UIImageView+WebCache.h>

@interface BasicFeedCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *feedPostInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fromUserImageView;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;

@end

@implementation BasicFeedCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
            
- (void)setFeed:(Feed *)feed
{
    
    if ([feed.feedNetwork isEqualToString:FeedNetworkTypeFacebook]) {
        [self.fromUserImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",feed.from_id]]
                                  placeholderImage:nil
                                           options:SDWebImageRefreshCached];
    }else
    {
        [self.fromUserImageView sd_setImageWithURL:[NSURL URLWithString:feed.userImageUrl]];
    }

    self.messageLabel.numberOfLines = 5;
    self.nameLabel.text = feed.from;
    self.messageLabel.text = feed.message;
    NSTimeInterval timeInterval = [feed.created_time timeIntervalSinceNow];
    if (timeInterval<0) {
        timeInterval = timeInterval*-1;
    }
    NSString *feedPostInfo;
    double minutes = floorf(timeInterval/60.0);
    if (minutes < 2) {
        feedPostInfo = [NSString stringWithFormat:@"%.0f minute ago",minutes];
        
    }
    else
    {
        feedPostInfo = [NSString stringWithFormat:@"%.0f minutes ago",minutes];
        
    }
    if (minutes>59) {
        double hours = minutes/60.0;
        if (hours < 2) {
            feedPostInfo = [NSString stringWithFormat:@"%.0f hour ago",hours];
        }
        else
        {
            feedPostInfo = [NSString stringWithFormat:@"%.0f hours ago",hours];
        }
        
        if (hours>23.9) {
            double days = hours/24.0;
            if (days < 2) {
                feedPostInfo = [NSString stringWithFormat:@"%.0f day ago",days];
                
            }
            else
            {
                feedPostInfo = [NSString stringWithFormat:@"%.0f days ago",days];
                
            }
            if (days>10) {
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                
                
                NSDateComponents *presentDayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
                NSDateComponents *feedCreatedDayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:feed.created_time];
                if (presentDayComponents.year!=feedCreatedDayComponents.year) {
                    df.dateFormat = @"MMMM d, YYYY";
                }
                else
                {
                    df.dateFormat = @"MMMM d";
                }
                feedPostInfo = [df stringFromDate:feed.created_time];
            }
        }
    }
    self.feedPostInfoLabel.text = feedPostInfo;
    
    if ([feed.feedNetwork isEqualToString:FeedNetworkTypeTwitter]) {
        
    
    if (feed.favorite_count.integerValue == 0) {
        self.favoriteCountLabel.text = @"";
    }
    else
    {
        self.favoriteCountLabel.text = [NSString stringWithFormat:@"%@",feed.favorite_count];
    }
    
    if (feed.retweet_count.integerValue == 0) {
        self.retweetCountLabel.text = @"";
    }
    else
    {
        self.retweetCountLabel.text = [NSString stringWithFormat:@"%@",feed.retweet_count];
    }
    }
    self.fromUserImageView.layer.cornerRadius = 4;
    self.fromUserImageView.layer.masksToBounds = YES;
  
}
@end
